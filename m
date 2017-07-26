Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0AA16B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 19:40:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 72so119834258pfl.12
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 16:40:30 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id s138si10259678pgs.270.2017.07.26.16.40.27
        for <linux-mm@kvack.org>;
        Wed, 26 Jul 2017 16:40:28 -0700 (PDT)
Date: Thu, 27 Jul 2017 08:40:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170726234025.GA4491@bbox>
References: <20170720074342.otez35bme5gytnxl@suse.de>
 <BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com>
 <20170724095832.vgvku6vlxkv75r3k@suse.de>
 <20170725073748.GB22652@bbox>
 <20170725085132.iysanhtqkgopegob@suse.de>
 <20170725091115.GA22920@bbox>
 <20170725100722.2dxnmgypmwnrfawp@suse.de>
 <20170726054306.GA11100@bbox>
 <20170726092228.pyjxamxweslgaemi@suse.de>
 <A300D14C-D7EE-4A26-A7CF-A7643F1A61BA@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A300D14C-D7EE-4A26-A7CF-A7643F1A61BA@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Hello Nadav,

On Wed, Jul 26, 2017 at 12:18:37PM -0700, Nadav Amit wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Wed, Jul 26, 2017 at 02:43:06PM +0900, Minchan Kim wrote:
> >>> I'm relying on the fact you are the madv_free author to determine if
> >>> it's really necessary. The race in question is CPU 0 running madv_free
> >>> and updating some PTEs while CPU 1 is also running madv_free and looking
> >>> at the same PTEs. CPU 1 may have writable TLB entries for a page but fail
> >>> the pte_dirty check (because CPU 0 has updated it already) and potentially
> >>> fail to flush. Hence, when madv_free on CPU 1 returns, there are still
> >>> potentially writable TLB entries and the underlying PTE is still present
> >>> so that a subsequent write does not necessarily propagate the dirty bit
> >>> to the underlying PTE any more. Reclaim at some unknown time at the future
> >>> may then see that the PTE is still clean and discard the page even though
> >>> a write has happened in the meantime. I think this is possible but I could
> >>> have missed some protection in madv_free that prevents it happening.
> >> 
> >> Thanks for the detail. You didn't miss anything. It can happen and then
> >> it's really bug. IOW, if application does write something after madv_free,
> >> it must see the written value, not zero.
> >> 
> >> How about adding [set|clear]_tlb_flush_pending in tlb batchin interface?
> >> With it, when tlb_finish_mmu is called, we can know we skip the flush
> >> but there is pending flush, so flush focefully to avoid madv_dontneed
> >> as well as madv_free scenario.
> > 
> > I *think* this is ok as it's simply more expensive on the KSM side in
> > the event of a race but no other harmful change is made assuming that
> > KSM is the only race-prone. The check for mm_tlb_flush_pending also
> > happens under the PTL so there should be sufficient protection from the
> > mm struct update being visible at teh right time.
> > 
> > Check using the test program from "mm: Always flush VMA ranges affected
> > by zap_page_range v2" if it handles the madvise case as well as that
> > would give some degree of safety. Make sure it's tested against 4.13-rc2
> > instead of mmotm which already includes the madv_dontneed fix. If yours
> > works for both then it supersedes the mmotm patch.
> > 
> > It would also be interesting if Nadav would use his slowdown hack to see
> > if he can still force the corruption.
> 
> The proposed fix for the KSM side is likely to work (I will try later), but
> on the tlb_finish_mmu() side, I think there is a problem, since if any TLB
> flush is performed by tlb_flush_mmu(), flush_tlb_mm_range() will not be
> executed. This means that tlb_finish_mmu() may flush one TLB entry, leave
> another one stale and not flush it.

Okay, I will change that part like this to avoid partial flush problem.

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 1c42d69490e4..87d0ebac6605 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -529,10 +529,13 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
  * The barriers below prevent the compiler from re-ordering the instructions
  * around the memory barriers that are already present in the code.
  */
-static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
+static inline int mm_tlb_flush_pending(struct mm_struct *mm)
 {
+	int nr_pending;
+
 	barrier();
-	return atomic_read(&mm->tlb_flush_pending) > 0;
+	nr_pending = atomic_read(&mm->tlb_flush_pending);
+	return nr_pending;
 }
 static inline void set_tlb_flush_pending(struct mm_struct *mm)
 {
diff --git a/mm/memory.c b/mm/memory.c
index d5c5e6497c70..b5320e96ec51 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -286,11 +286,15 @@ bool tlb_flush_mmu(struct mmu_gather *tlb)
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
 	struct mmu_gather_batch *batch, *next;
-	bool flushed = tlb_flush_mmu(tlb);
 
+	if (!tlb->fullmm && !tlb->need_flush_all &&
+			mm_tlb_flush_pending(tlb->mm) > 1) {
+		tlb->start = min(start, tlb->start);
+		tlb->end = max(end, tlb->end);
+	}
+
+	tlb_flush_mmu(tlb);
 	clear_tlb_flush_pending(tlb->mm);
-	if (!flushed && mm_tlb_flush_pending(tlb->mm))
-		flush_tlb_mm_range(tlb->mm, start, end, 0UL);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
> 
> Note also that the use of set/clear_tlb_flush_pending() is only applicable
> following my pending fix that changes the pending indication from bool to
> atomic_t.

Sure, I saw it in current mmots. Without your good job, my patch never work. :)
Thanks for the head up.

> 
> For the record here is my test, followed by the patch to add latency. There
> are some magic numbers that may not apply to your system (I got tired of
> trying to time the system). If you run the test in a VM, the pause-loop
> exiting can potentially prevent the issue from appearing.

Thanks for the sharing. I will try it, too.

> 
> --
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <pthread.h>
> #include <string.h>
> #include <assert.h>
> #include <unistd.h>
> #include <fcntl.h>
> #include <pthread.h>
> #include <stdint.h>
> #include <stdbool.h>
> #include <sys/mman.h>
> #include <sys/types.h>
> 
> #define PAGE_SIZE		(4096)
> #define N_PAGES			(65536ull * 16)
> 
> #define CHANGED_VAL		(7)
> #define BASE_VAL		(9)
> 
> #define max(a,b) \
> 	({ __typeof__ (a) _a = (a); \
> 	  __typeof__ (b) _b = (b); \
> 	  _a > _b ? _a : _b; })
> 
> #define STEP_HELPERS_RUN	(1)
> #define STEP_DONTNEED_DONE	(2)
> #define STEP_ACCESS_PAUSED	(4)
> 
> volatile int sync_step = STEP_ACCESS_PAUSED;
> volatile char *p;
> int dirty_fd, ksm_sharing_fd, ksm_run_fd;
> uint64_t soft_dirty_time, madvise_time, soft_dirty_delta, madvise_delta;
> 
> static inline unsigned long rdtsc()
> {
> 	unsigned long hi, lo;
> 
> 	__asm__ __volatile__ ("rdtsc" : "=a"(lo), "=d"(hi));
> 	 return lo | (hi << 32);
> }
> 
> static inline void wait_rdtsc(unsigned long cycles)
> {
> 	unsigned long tsc = rdtsc();
> 
> 	while (rdtsc() - tsc < cycles)
> 		__asm__ __volatile__ ("rep nop" ::: "memory");
> }
> 
> static void break_sharing(void)
> {
> 	char buf[20];
> 
> 	pwrite(ksm_run_fd, "2", 1, 0);
> 
> 	printf("waiting for page sharing to be broken\n");
> 	do {
> 		pread(ksm_sharing_fd, buf, sizeof(buf), 0);
> 	} while (strtoul(buf, NULL, sizeof(buf)));
> }
> 
> 
> static inline void wait_step(unsigned int step)
> {
> 	while (!(sync_step & step))
> 		asm volatile ("rep nop":::"memory");
> }
> 
> static void *big_madvise_thread(void *ign)
> {
> 	while (1) {
> 		uint64_t tsc;
> 
> 		wait_step(STEP_HELPERS_RUN);
> 		wait_rdtsc(madvise_delta);
> 		tsc = rdtsc();
> 		madvise((void*)p, PAGE_SIZE * N_PAGES, MADV_FREE);
> 		madvise_time = rdtsc() - tsc;
> 		sync_step = STEP_DONTNEED_DONE;
> 	}
> }
> 
> static void *soft_dirty_thread(void *ign)
> {
> 	while (1) {
> 		int r;
> 		uint64_t tsc;
> 
> 		wait_step(STEP_HELPERS_RUN | STEP_DONTNEED_DONE);
> 		wait_rdtsc(soft_dirty_delta);
> 
> 		tsc = rdtsc();
> 		r = pwrite(dirty_fd, "4", 1, 0);
> 		assert(r == 1);
> 		soft_dirty_time = rdtsc() - tsc;
> 		wait_step(STEP_DONTNEED_DONE);
> 		sync_step = STEP_ACCESS_PAUSED;
> 	}
> }
> 
> void main(void)
> {
> 	pthread_t aux_thread, aux_thread2;
> 	char pathname[256];
> 	long i;
> 	volatile char c;
> 
> 	sprintf(pathname, "/proc/%d/clear_refs", getpid());
> 	dirty_fd = open(pathname, O_RDWR);
> 
> 	ksm_sharing_fd = open("/sys/kernel/mm/ksm/pages_sharing", O_RDONLY);
> 	assert(ksm_sharing_fd >= 0);
> 
> 	ksm_run_fd = open("/sys/kernel/mm/ksm/run", O_RDWR);
> 	assert(ksm_run_fd >= 0);
> 
> 	pwrite(ksm_run_fd, "0", 1, 0);
> 
> 	p = mmap(0, PAGE_SIZE * N_PAGES, PROT_READ|PROT_WRITE,
> 		 MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
> 	assert(p != MAP_FAILED);
> 	madvise((void*)p, PAGE_SIZE * N_PAGES, MADV_MERGEABLE);
> 
> 	memset((void*)p, BASE_VAL, PAGE_SIZE * 2);
> 	for (i = 2; i < N_PAGES; i++)
> 		c = p[PAGE_SIZE * i];
> 
> 	pthread_create(&aux_thread, NULL, big_madvise_thread, NULL);
> 	pthread_create(&aux_thread2, NULL, soft_dirty_thread, NULL);
> 
> 	while (1) {
> 		break_sharing();
> 		*(p + 64) = BASE_VAL;		// cache in TLB and break KSM
> 		pwrite(ksm_run_fd, "1", 1, 0);
> 
> 		wait_rdtsc(0x8000000ull);
> 		sync_step = STEP_HELPERS_RUN;
> 		wait_rdtsc(0x4000000ull);
> 
> 		*(p+64) = CHANGED_VAL;
> 
> 		wait_step(STEP_ACCESS_PAUSED);		// wait for TLB to be flushed
> 		if (*(p+64) != CHANGED_VAL ||
> 		    *(p + PAGE_SIZE + 64) == CHANGED_VAL) {
> 			printf("KSM error\n");
> 			exit(EXIT_FAILURE);
> 		}
> 
> 		printf("No failure yet\n");
> 
> 		soft_dirty_delta = max(0, (long)madvise_time - (long)soft_dirty_time);
> 		madvise_delta = max(0, (long)soft_dirty_time - (long)madvise_time);
> 	}
> }
> 
> -- 8< --
> 
> Subject: [PATCH] TLB flush delay to trigger failure
> 
> ---
>  fs/proc/task_mmu.c | 2 ++
>  mm/ksm.c           | 2 ++
>  mm/madvise.c       | 2 ++
>  3 files changed, 6 insertions(+)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 520802da059c..c13259251210 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -16,6 +16,7 @@
>  #include <linux/mmu_notifier.h>
>  #include <linux/page_idle.h>
>  #include <linux/shmem_fs.h>
> +#include <linux/delay.h>
>  
>  #include <asm/elf.h>
>  #include <linux/uaccess.h>
> @@ -1076,6 +1077,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
>  		if (type == CLEAR_REFS_SOFT_DIRTY)
>  			mmu_notifier_invalidate_range_end(mm, 0, -1);
> +		msleep(5);
>  		flush_tlb_mm(mm);
>  		up_read(&mm->mmap_sem);
>  out_mm:
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 216184af0e19..317adbb48b0f 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -39,6 +39,7 @@
>  #include <linux/freezer.h>
>  #include <linux/oom.h>
>  #include <linux/numa.h>
> +#include <linux/delay.h>
>  
>  #include <asm/tlbflush.h>
>  #include "internal.h"
> @@ -960,6 +961,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
>  	mmun_end   = addr + PAGE_SIZE;
>  	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>  
> +	msleep(5);
>  	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
>  	if (!pte_same(*ptep, orig_pte)) {
>  		pte_unmap_unlock(ptep, ptl);
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 25b78ee4fc2c..e4c852360f2c 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -23,6 +23,7 @@
>  #include <linux/swapops.h>
>  #include <linux/shmem_fs.h>
>  #include <linux/mmu_notifier.h>
> +#include <linux/delay.h>
>  
>  #include <asm/tlb.h>
>  
> @@ -472,6 +473,7 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
>  	mmu_notifier_invalidate_range_start(mm, start, end);
>  	madvise_free_page_range(&tlb, vma, start, end);
>  	mmu_notifier_invalidate_range_end(mm, start, end);
> +	msleep(5);
>  	tlb_finish_mmu(&tlb, start, end);
>  
>  	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
