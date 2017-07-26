Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C01D6B0292
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:18:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c87so18821730pfd.14
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:18:41 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id v4si4143977pgv.275.2017.07.26.12.18.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 12:18:39 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id m21so1818692pfj.3
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:18:39 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Potential race in TLB flush batching?
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170726092228.pyjxamxweslgaemi@suse.de>
Date: Wed, 26 Jul 2017 12:18:37 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <A300D14C-D7EE-4A26-A7CF-A7643F1A61BA@gmail.com>
References: <20170719225950.wfpfzpc6llwlyxdo@suse.de>
 <4DC97890-9FFA-4BA4-B300-B679BAB2136D@gmail.com>
 <20170720074342.otez35bme5gytnxl@suse.de>
 <BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com>
 <20170724095832.vgvku6vlxkv75r3k@suse.de> <20170725073748.GB22652@bbox>
 <20170725085132.iysanhtqkgopegob@suse.de> <20170725091115.GA22920@bbox>
 <20170725100722.2dxnmgypmwnrfawp@suse.de> <20170726054306.GA11100@bbox>
 <20170726092228.pyjxamxweslgaemi@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Mel Gorman <mgorman@suse.de> wrote:

> On Wed, Jul 26, 2017 at 02:43:06PM +0900, Minchan Kim wrote:
>>> I'm relying on the fact you are the madv_free author to determine if
>>> it's really necessary. The race in question is CPU 0 running =
madv_free
>>> and updating some PTEs while CPU 1 is also running madv_free and =
looking
>>> at the same PTEs. CPU 1 may have writable TLB entries for a page but =
fail
>>> the pte_dirty check (because CPU 0 has updated it already) and =
potentially
>>> fail to flush. Hence, when madv_free on CPU 1 returns, there are =
still
>>> potentially writable TLB entries and the underlying PTE is still =
present
>>> so that a subsequent write does not necessarily propagate the dirty =
bit
>>> to the underlying PTE any more. Reclaim at some unknown time at the =
future
>>> may then see that the PTE is still clean and discard the page even =
though
>>> a write has happened in the meantime. I think this is possible but I =
could
>>> have missed some protection in madv_free that prevents it happening.
>>=20
>> Thanks for the detail. You didn't miss anything. It can happen and =
then
>> it's really bug. IOW, if application does write something after =
madv_free,
>> it must see the written value, not zero.
>>=20
>> How about adding [set|clear]_tlb_flush_pending in tlb batchin =
interface?
>> With it, when tlb_finish_mmu is called, we can know we skip the flush
>> but there is pending flush, so flush focefully to avoid madv_dontneed
>> as well as madv_free scenario.
>=20
> I *think* this is ok as it's simply more expensive on the KSM side in
> the event of a race but no other harmful change is made assuming that
> KSM is the only race-prone. The check for mm_tlb_flush_pending also
> happens under the PTL so there should be sufficient protection from =
the
> mm struct update being visible at teh right time.
>=20
> Check using the test program from "mm: Always flush VMA ranges =
affected
> by zap_page_range v2" if it handles the madvise case as well as that
> would give some degree of safety. Make sure it's tested against =
4.13-rc2
> instead of mmotm which already includes the madv_dontneed fix. If =
yours
> works for both then it supersedes the mmotm patch.
>=20
> It would also be interesting if Nadav would use his slowdown hack to =
see
> if he can still force the corruption.

The proposed fix for the KSM side is likely to work (I will try later), =
but
on the tlb_finish_mmu() side, I think there is a problem, since if any =
TLB
flush is performed by tlb_flush_mmu(), flush_tlb_mm_range() will not be
executed. This means that tlb_finish_mmu() may flush one TLB entry, =
leave
another one stale and not flush it.

Note also that the use of set/clear_tlb_flush_pending() is only =
applicable
following my pending fix that changes the pending indication from bool =
to
atomic_t.

For the record here is my test, followed by the patch to add latency. =
There
are some magic numbers that may not apply to your system (I got tired of
trying to time the system). If you run the test in a VM, the pause-loop
exiting can potentially prevent the issue from appearing.

--

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include <assert.h>
#include <unistd.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/mman.h>
#include <sys/types.h>

#define PAGE_SIZE		(4096)
#define N_PAGES			(65536ull * 16)

#define CHANGED_VAL		(7)
#define BASE_VAL		(9)

#define max(a,b) \
	({ __typeof__ (a) _a =3D (a); \
	  __typeof__ (b) _b =3D (b); \
	  _a > _b ? _a : _b; })

#define STEP_HELPERS_RUN	(1)
#define STEP_DONTNEED_DONE	(2)
#define STEP_ACCESS_PAUSED	(4)

volatile int sync_step =3D STEP_ACCESS_PAUSED;
volatile char *p;
int dirty_fd, ksm_sharing_fd, ksm_run_fd;
uint64_t soft_dirty_time, madvise_time, soft_dirty_delta, madvise_delta;

static inline unsigned long rdtsc()
{
	unsigned long hi, lo;

	__asm__ __volatile__ ("rdtsc" : "=3Da"(lo), "=3Dd"(hi));
	 return lo | (hi << 32);
}

static inline void wait_rdtsc(unsigned long cycles)
{
	unsigned long tsc =3D rdtsc();

	while (rdtsc() - tsc < cycles)
		__asm__ __volatile__ ("rep nop" ::: "memory");
}

static void break_sharing(void)
{
	char buf[20];

	pwrite(ksm_run_fd, "2", 1, 0);

	printf("waiting for page sharing to be broken\n");
	do {
		pread(ksm_sharing_fd, buf, sizeof(buf), 0);
	} while (strtoul(buf, NULL, sizeof(buf)));
}


static inline void wait_step(unsigned int step)
{
	while (!(sync_step & step))
		asm volatile ("rep nop":::"memory");
}

static void *big_madvise_thread(void *ign)
{
	while (1) {
		uint64_t tsc;

		wait_step(STEP_HELPERS_RUN);
		wait_rdtsc(madvise_delta);
		tsc =3D rdtsc();
		madvise((void*)p, PAGE_SIZE * N_PAGES, MADV_FREE);
		madvise_time =3D rdtsc() - tsc;
		sync_step =3D STEP_DONTNEED_DONE;
	}
}

static void *soft_dirty_thread(void *ign)
{
	while (1) {
		int r;
		uint64_t tsc;

		wait_step(STEP_HELPERS_RUN | STEP_DONTNEED_DONE);
		wait_rdtsc(soft_dirty_delta);

		tsc =3D rdtsc();
		r =3D pwrite(dirty_fd, "4", 1, 0);
		assert(r =3D=3D 1);
		soft_dirty_time =3D rdtsc() - tsc;
		wait_step(STEP_DONTNEED_DONE);
		sync_step =3D STEP_ACCESS_PAUSED;
	}
}

void main(void)
{
	pthread_t aux_thread, aux_thread2;
	char pathname[256];
	long i;
	volatile char c;

	sprintf(pathname, "/proc/%d/clear_refs", getpid());
	dirty_fd =3D open(pathname, O_RDWR);

	ksm_sharing_fd =3D open("/sys/kernel/mm/ksm/pages_sharing", =
O_RDONLY);
	assert(ksm_sharing_fd >=3D 0);

	ksm_run_fd =3D open("/sys/kernel/mm/ksm/run", O_RDWR);
	assert(ksm_run_fd >=3D 0);

	pwrite(ksm_run_fd, "0", 1, 0);

	p =3D mmap(0, PAGE_SIZE * N_PAGES, PROT_READ|PROT_WRITE,
		 MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
	assert(p !=3D MAP_FAILED);
	madvise((void*)p, PAGE_SIZE * N_PAGES, MADV_MERGEABLE);

	memset((void*)p, BASE_VAL, PAGE_SIZE * 2);
	for (i =3D 2; i < N_PAGES; i++)
		c =3D p[PAGE_SIZE * i];

	pthread_create(&aux_thread, NULL, big_madvise_thread, NULL);
	pthread_create(&aux_thread2, NULL, soft_dirty_thread, NULL);

	while (1) {
		break_sharing();
		*(p + 64) =3D BASE_VAL;		// cache in TLB and =
break KSM
		pwrite(ksm_run_fd, "1", 1, 0);

		wait_rdtsc(0x8000000ull);
		sync_step =3D STEP_HELPERS_RUN;
		wait_rdtsc(0x4000000ull);

		*(p+64) =3D CHANGED_VAL;

		wait_step(STEP_ACCESS_PAUSED);		// wait for TLB =
to be flushed
		if (*(p+64) !=3D CHANGED_VAL ||
		    *(p + PAGE_SIZE + 64) =3D=3D CHANGED_VAL) {
			printf("KSM error\n");
			exit(EXIT_FAILURE);
		}

		printf("No failure yet\n");

		soft_dirty_delta =3D max(0, (long)madvise_time - =
(long)soft_dirty_time);
		madvise_delta =3D max(0, (long)soft_dirty_time - =
(long)madvise_time);
	}
}

-- 8< --

Subject: [PATCH] TLB flush delay to trigger failure

---
 fs/proc/task_mmu.c | 2 ++
 mm/ksm.c           | 2 ++
 mm/madvise.c       | 2 ++
 3 files changed, 6 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 520802da059c..c13259251210 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -16,6 +16,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/page_idle.h>
 #include <linux/shmem_fs.h>
+#include <linux/delay.h>
=20
 #include <asm/elf.h>
 #include <linux/uaccess.h>
@@ -1076,6 +1077,7 @@ static ssize_t clear_refs_write(struct file *file, =
const char __user *buf,
 		walk_page_range(0, mm->highest_vm_end, =
&clear_refs_walk);
 		if (type =3D=3D CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_end(mm, 0, -1);
+		msleep(5);
 		flush_tlb_mm(mm);
 		up_read(&mm->mmap_sem);
 out_mm:
diff --git a/mm/ksm.c b/mm/ksm.c
index 216184af0e19..317adbb48b0f 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -39,6 +39,7 @@
 #include <linux/freezer.h>
 #include <linux/oom.h>
 #include <linux/numa.h>
+#include <linux/delay.h>
=20
 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -960,6 +961,7 @@ static int replace_page(struct vm_area_struct *vma, =
struct page *page,
 	mmun_end   =3D addr + PAGE_SIZE;
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
=20
+	msleep(5);
 	ptep =3D pte_offset_map_lock(mm, pmd, addr, &ptl);
 	if (!pte_same(*ptep, orig_pte)) {
 		pte_unmap_unlock(ptep, ptl);
diff --git a/mm/madvise.c b/mm/madvise.c
index 25b78ee4fc2c..e4c852360f2c 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -23,6 +23,7 @@
 #include <linux/swapops.h>
 #include <linux/shmem_fs.h>
 #include <linux/mmu_notifier.h>
+#include <linux/delay.h>
=20
 #include <asm/tlb.h>
=20
@@ -472,6 +473,7 @@ static int madvise_free_single_vma(struct =
vm_area_struct *vma,
 	mmu_notifier_invalidate_range_start(mm, start, end);
 	madvise_free_page_range(&tlb, vma, start, end);
 	mmu_notifier_invalidate_range_end(mm, start, end);
+	msleep(5);
 	tlb_finish_mmu(&tlb, start, end);
=20
 	return 0;=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
