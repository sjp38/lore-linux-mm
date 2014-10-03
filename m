Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id C01E76B006C
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 14:03:21 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id z107so1272672qgd.41
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 11:03:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 91si13614238qgb.33.2014.10.03.11.03.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 11:03:20 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 12/17] mm: sys_remap_anon_pages
Date: Fri,  3 Oct 2014 19:08:02 +0200
Message-Id: <1412356087-16115-13-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

This new syscall will move anon pages across vmas, atomically and
without touching the vmas.

It only works on non shared anonymous pages because those can be
relocated without generating non linear anon_vmas in the rmap code.

It is the ideal mechanism to handle userspace page faults. Normally
the destination vma will have VM_USERFAULT set with
madvise(MADV_USERFAULT) while the source vma will normally have
VM_DONTCOPY set with madvise(MADV_DONTFORK).

MADV_DONTFORK set in the source vma avoids remap_anon_pages to fail if
the process forks during the userland page fault.

The thread triggering the sigbus signal handler by touching an
unmapped hole in the MADV_USERFAULT region, should take care to
receive the data belonging in the faulting virtual address in the
source vma. The data can come from the network, storage or any other
I/O device. After the data has been safely received in the private
area in the source vma, it will call remap_anon_pages to map the page
in the faulting address in the destination vma atomically. And finally
it will return from the signal handler.

It is an alternative to mremap.

It only works if the vma protection bits are identical from the source
and destination vma.

It can remap non shared anonymous pages within the same vma too.

If the source virtual memory range has any unmapped holes, or if the
destination virtual memory range is not a whole unmapped hole,
remap_anon_pages will fail respectively with -ENOENT or -EEXIST. This
provides a very strict behavior to avoid any chance of memory
corruption going unnoticed if there are userland race conditions. Only
one thread should resolve the userland page fault at any given time
for any given faulting address. This means that if two threads try to
both call remap_anon_pages on the same destination address at the same
time, the second thread will get an explicit error from this syscall.

The syscall retval will return "len" is succesful. The syscall however
can be interrupted by fatal signals or errors. If interrupted it will
return the number of bytes successfully remapped before the
interruption if any, or the negative error if none. It will never
return zero. Either it will return an error or an amount of bytes
successfully moved. If the retval reports a "short" remap, the
remap_anon_pages syscall should be repeated by userland with
src+retval, dst+reval, len-retval if it wants to know about the error
that interrupted it.

The RAP_ALLOW_SRC_HOLES flag can be specified to prevent -ENOENT
errors to materialize if there are holes in the source virtual range
that is being remapped. The holes will be accounted as successfully
remapped in the retval of the syscall. This is mostly useful to remap
hugepage naturally aligned virtual regions without knowing if there
are transparent hugepage in the regions or not, but preventing the
risk of having to split the hugepmd during the remap.

The main difference with mremap is that if used to fill holes in
unmapped anonymous memory vmas (if used in combination with
MADV_USERFAULT) remap_anon_pages won't create lots of unmergeable
vmas. mremap instead would create lots of vmas (because of non linear
vma->vm_pgoff) leading to -ENOMEM failures (the number of vmas is
limited).

MADV_USERFAULT and remap_anon_pages() can be tested with a program
like below:

===
 #define _GNU_SOURCE
 #include <sys/mman.h>
 #include <pthread.h>
 #include <strings.h>
 #include <stdlib.h>
 #include <unistd.h>
 #include <stdio.h>
 #include <errno.h>
 #include <string.h>
 #include <signal.h>
 #include <sys/syscall.h>
 #include <sys/types.h>

 #define USE_USERFAULT
 #define THP

 #define MADV_USERFAULT	18

 #define SIZE (1024*1024*1024)

 #define SYS_remap_anon_pages 321

 static volatile unsigned char *c, *tmp;

 void userfault_sighandler(int signum, siginfo_t *info, void *ctx)
 {
 	unsigned char *addr = info->si_addr;
 	int len = 4096;
 	int ret;

 	addr = (unsigned char *) ((unsigned long) addr & ~((getpagesize())-1));
 #ifdef THP
 	addr = (unsigned char *) ((unsigned long) addr & ~((2*1024*1024)-1));
 	len = 2*1024*1024;
 #endif
 	if (addr >= c && addr < c + SIZE) {
 		unsigned long offset = addr - c;
 		ret = syscall(SYS_remap_anon_pages, c+offset, tmp+offset, len, 0);
 		if (ret != len)
 			perror("sigbus remap_anon_pages"), exit(1);
 		//printf("sigbus offset %lu\n", offset);
 		return;
 	}

 	printf("sigbus error addr %p c %p tmp %p\n", addr, c, tmp), exit(1);
 }

 int main()
 {
 	struct sigaction sa;
 	int ret;
 	unsigned long i;
 #ifndef THP
 	/*
 	 * Fails with THP due lack of alignment because of memset
 	 * pre-filling the destination
 	 */
 	c = mmap(0, SIZE, PROT_READ|PROT_WRITE,
 		 MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
 	if (c == MAP_FAILED)
 		perror("mmap"), exit(1);
 	tmp = mmap(0, SIZE, PROT_READ|PROT_WRITE,
 		   MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
 	if (tmp == MAP_FAILED)
 		perror("mmap"), exit(1);
 #else
 	ret = posix_memalign((void **)&c, 2*1024*1024, SIZE);
 	if (ret)
 		perror("posix_memalign"), exit(1);
 	ret = posix_memalign((void **)&tmp, 2*1024*1024, SIZE);
 	if (ret)
 		perror("posix_memalign"), exit(1);
 #endif
 	/*
 	 * MADV_USERFAULT must run before memset, to avoid THP 2m
 	 * faults to map memory into "tmp", if "tmp" isn't allocated
 	 * with hugepage alignment.
 	 */
 	if (madvise((void *)c, SIZE, MADV_USERFAULT))
 		perror("madvise"), exit(1);
 	memset((void *)tmp, 0xaa, SIZE);

 	sa.sa_sigaction = userfault_sighandler;
 	sigemptyset(&sa.sa_mask);
 	sa.sa_flags = SA_SIGINFO;
 	sigaction(SIGBUS, &sa, NULL);

 #ifndef USE_USERFAULT
 	ret = syscall(SYS_remap_anon_pages, c, tmp, SIZE, 0);
 	if (ret != SIZE)
 		perror("remap_anon_pages"), exit(1);
 #endif

 	for (i = 0; i < SIZE; i += 4096) {
 		if ((i/4096) % 2) {
 			/* exercise read and write MADV_USERFAULT */
 			c[i+1] = 0xbb;
 		}
 		if (c[i] != 0xaa)
 			printf("error %x offset %lu\n", c[i], i), exit(1);
 	}
 	printf("remap_anon_pages functions correctly\n");

 	return 0;
 }
===

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/syscalls/syscall_32.tbl |   1 +
 arch/x86/syscalls/syscall_64.tbl |   1 +
 include/linux/huge_mm.h          |   7 +
 include/linux/syscalls.h         |   4 +
 kernel/sys_ni.c                  |   1 +
 mm/fremap.c                      | 477 +++++++++++++++++++++++++++++++++++++++
 mm/huge_memory.c                 | 110 +++++++++
 7 files changed, 601 insertions(+)

diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/syscall_32.tbl
index 028b781..2d0594c 100644
--- a/arch/x86/syscalls/syscall_32.tbl
+++ b/arch/x86/syscalls/syscall_32.tbl
@@ -363,3 +363,4 @@
 354	i386	seccomp			sys_seccomp
 355	i386	getrandom		sys_getrandom
 356	i386	memfd_create		sys_memfd_create
+357	i386	remap_anon_pages	sys_remap_anon_pages
diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index 35dd922..41e8f3e 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -327,6 +327,7 @@
 318	common	getrandom		sys_getrandom
 319	common	memfd_create		sys_memfd_create
 320	common	kexec_file_load		sys_kexec_file_load
+321	common	remap_anon_pages	sys_remap_anon_pages
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 3aa10e0..8a85fc9 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -33,6 +33,13 @@ extern int move_huge_pmd(struct vm_area_struct *vma,
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
 			int prot_numa);
+extern int remap_anon_pages_huge_pmd(struct mm_struct *mm,
+				     pmd_t *dst_pmd, pmd_t *src_pmd,
+				     pmd_t dst_pmdval,
+				     struct vm_area_struct *dst_vma,
+				     struct vm_area_struct *src_vma,
+				     unsigned long dst_addr,
+				     unsigned long src_addr);
 
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 0f86d85..3d4bb05 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -451,6 +451,10 @@ asmlinkage long sys_mremap(unsigned long addr,
 asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 			unsigned long prot, unsigned long pgoff,
 			unsigned long flags);
+asmlinkage long sys_remap_anon_pages(unsigned long dst_start,
+				     unsigned long src_start,
+				     unsigned long len,
+				     unsigned long flags);
 asmlinkage long sys_msync(unsigned long start, size_t len, int flags);
 asmlinkage long sys_fadvise64(int fd, loff_t offset, size_t len, int advice);
 asmlinkage long sys_fadvise64_64(int fd, loff_t offset, loff_t len, int advice);
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 391d4dd..2bc7bef 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -178,6 +178,7 @@ cond_syscall(sys_mincore);
 cond_syscall(sys_madvise);
 cond_syscall(sys_mremap);
 cond_syscall(sys_remap_file_pages);
+cond_syscall(sys_remap_anon_pages);
 cond_syscall(compat_sys_move_pages);
 cond_syscall(compat_sys_migrate_pages);
 
diff --git a/mm/fremap.c b/mm/fremap.c
index 1e509f7..9337637 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -310,3 +310,480 @@ void double_pt_unlock(spinlock_t *ptl1,
 	if (ptl1 != ptl2)
 		spin_unlock(ptl2);
 }
+
+#define RAP_ALLOW_SRC_HOLES (1UL<<0)
+
+/*
+ * The mmap_sem for reading is held by the caller. Just move the page
+ * from src_pmd to dst_pmd if possible, and return true if succeeded
+ * in moving the page.
+ */
+static int remap_anon_pages_pte(struct mm_struct *mm,
+				pte_t *dst_pte, pte_t *src_pte, pmd_t *src_pmd,
+				struct vm_area_struct *dst_vma,
+				struct vm_area_struct *src_vma,
+				unsigned long dst_addr,
+				unsigned long src_addr,
+				spinlock_t *dst_ptl,
+				spinlock_t *src_ptl,
+				unsigned long flags)
+{
+	struct page *src_page;
+	swp_entry_t entry;
+	pte_t orig_src_pte, orig_dst_pte;
+	struct anon_vma *src_anon_vma, *dst_anon_vma;
+
+	spin_lock(dst_ptl);
+	orig_dst_pte = *dst_pte;
+	spin_unlock(dst_ptl);
+	if (!pte_none(orig_dst_pte))
+		return -EEXIST;
+
+	spin_lock(src_ptl);
+	orig_src_pte = *src_pte;
+	spin_unlock(src_ptl);
+	if (pte_none(orig_src_pte)) {
+		if (!(flags & RAP_ALLOW_SRC_HOLES))
+			return -ENOENT;
+		else
+			/* nothing to do to remap an hole */
+			return 0;
+	}
+
+	if (pte_present(orig_src_pte)) {
+		/*
+		 * Pin the page while holding the lock to be sure the
+		 * page isn't freed under us
+		 */
+		spin_lock(src_ptl);
+		if (!pte_same(orig_src_pte, *src_pte)) {
+			spin_unlock(src_ptl);
+			return -EAGAIN;
+		}
+		src_page = vm_normal_page(src_vma, src_addr, orig_src_pte);
+		if (!src_page || !PageAnon(src_page) ||
+		    page_mapcount(src_page) != 1) {
+			spin_unlock(src_ptl);
+			return -EBUSY;
+		}
+
+		get_page(src_page);
+		spin_unlock(src_ptl);
+
+		/* block all concurrent rmap walks */
+		lock_page(src_page);
+
+		/*
+		 * page_referenced_anon walks the anon_vma chain
+		 * without the page lock. Serialize against it with
+		 * the anon_vma lock, the page lock is not enough.
+		 */
+		src_anon_vma = page_get_anon_vma(src_page);
+		if (!src_anon_vma) {
+			/* page was unmapped from under us */
+			unlock_page(src_page);
+			put_page(src_page);
+			return -EAGAIN;
+		}
+		anon_vma_lock_write(src_anon_vma);
+
+		double_pt_lock(dst_ptl, src_ptl);
+
+		if (!pte_same(*src_pte, orig_src_pte) ||
+		    !pte_same(*dst_pte, orig_dst_pte) ||
+		    page_mapcount(src_page) != 1) {
+			double_pt_unlock(dst_ptl, src_ptl);
+			anon_vma_unlock_write(src_anon_vma);
+			put_anon_vma(src_anon_vma);
+			unlock_page(src_page);
+			put_page(src_page);
+			return -EAGAIN;
+		}
+
+		BUG_ON(!PageAnon(src_page));
+		/* the PT lock is enough to keep the page pinned now */
+		put_page(src_page);
+
+		dst_anon_vma = (void *) dst_vma->anon_vma + PAGE_MAPPING_ANON;
+		ACCESS_ONCE(src_page->mapping) = ((struct address_space *)
+						  dst_anon_vma);
+		ACCESS_ONCE(src_page->index) = linear_page_index(dst_vma,
+								 dst_addr);
+
+		if (!pte_same(ptep_clear_flush(src_vma, src_addr, src_pte),
+			      orig_src_pte))
+			BUG();
+
+		orig_dst_pte = mk_pte(src_page, dst_vma->vm_page_prot);
+		orig_dst_pte = maybe_mkwrite(pte_mkdirty(orig_dst_pte),
+					     dst_vma);
+
+		set_pte_at(mm, dst_addr, dst_pte, orig_dst_pte);
+
+		double_pt_unlock(dst_ptl, src_ptl);
+
+		anon_vma_unlock_write(src_anon_vma);
+		put_anon_vma(src_anon_vma);
+
+		/* unblock rmap walks */
+		unlock_page(src_page);
+
+		mmu_notifier_invalidate_page(mm, src_addr);
+	} else {
+		if (pte_file(orig_src_pte))
+			return -EFAULT;
+
+		entry = pte_to_swp_entry(orig_src_pte);
+		if (non_swap_entry(entry)) {
+			if (is_migration_entry(entry)) {
+				migration_entry_wait(mm, src_pmd, src_addr);
+				return -EAGAIN;
+			}
+			return -EFAULT;
+		}
+
+		if (swp_entry_swapcount(entry) != 1)
+			return -EBUSY;
+
+		double_pt_lock(dst_ptl, src_ptl);
+
+		if (!pte_same(*src_pte, orig_src_pte) ||
+		    !pte_same(*dst_pte, orig_dst_pte) ||
+		    swp_entry_swapcount(entry) != 1) {
+			double_pt_unlock(dst_ptl, src_ptl);
+			return -EAGAIN;
+		}
+
+		if (pte_val(ptep_get_and_clear(mm, src_addr, src_pte)) !=
+		    pte_val(orig_src_pte))
+			BUG();
+		set_pte_at(mm, dst_addr, dst_pte, orig_src_pte);
+
+		double_pt_unlock(dst_ptl, src_ptl);
+	}
+
+	return 0;
+}
+
+static pmd_t *mm_alloc_pmd(struct mm_struct *mm, unsigned long address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd = NULL;
+
+	pgd = pgd_offset(mm, address);
+	pud = pud_alloc(mm, pgd, address);
+	if (pud)
+		/*
+		 * Note that we didn't run this because the pmd was
+		 * missing, the *pmd may be already established and in
+		 * turn it may also be a trans_huge_pmd.
+		 */
+		pmd = pmd_alloc(mm, pud, address);
+	return pmd;
+}
+
+/**
+ * sys_remap_anon_pages - remap arbitrary anonymous pages of an existing vma
+ * @dst_start: start of the destination virtual memory range
+ * @src_start: start of the source virtual memory range
+ * @len: length of the virtual memory range
+ *
+ * sys_remap_anon_pages remaps arbitrary anonymous pages atomically in
+ * zero copy. It only works on non shared anonymous pages because
+ * those can be relocated without generating non linear anon_vmas in
+ * the rmap code.
+ *
+ * It is the ideal mechanism to handle userspace page faults. Normally
+ * the destination vma will have VM_USERFAULT set with
+ * madvise(MADV_USERFAULT) while the source vma will have VM_DONTCOPY
+ * set with madvise(MADV_DONTFORK).
+ *
+ * The thread receiving the page during the userland page fault
+ * (MADV_USERFAULT) will receive the faulting page in the source vma
+ * through the network, storage or any other I/O device (MADV_DONTFORK
+ * in the source vma avoids remap_anon_pages to fail with -EBUSY if
+ * the process forks before remap_anon_pages is called), then it will
+ * call remap_anon_pages to map the page in the faulting address in
+ * the destination vma.
+ *
+ * This syscall works purely via pagetables, so it's the most
+ * efficient way to move physical non shared anonymous pages across
+ * different virtual addresses. Unlike mremap()/mmap()/munmap() it
+ * does not create any new vmas. The mapping in the destination
+ * address is atomic.
+ *
+ * It only works if the vma protection bits are identical from the
+ * source and destination vma.
+ *
+ * It can remap non shared anonymous pages within the same vma too.
+ *
+ * If the source virtual memory range has any unmapped holes, or if
+ * the destination virtual memory range is not a whole unmapped hole,
+ * remap_anon_pages will fail respectively with -ENOENT or
+ * -EEXIST. This provides a very strict behavior to avoid any chance
+ * of memory corruption going unnoticed if there are userland race
+ * conditions. Only one thread should resolve the userland page fault
+ * at any given time for any given faulting address. This means that
+ * if two threads try to both call remap_anon_pages on the same
+ * destination address at the same time, the second thread will get an
+ * explicit error from this syscall.
+ *
+ * The syscall retval will return "len" is succesful. The syscall
+ * however can be interrupted by fatal signals or errors. If
+ * interrupted it will return the number of bytes successfully
+ * remapped before the interruption if any, or the negative error if
+ * none. It will never return zero. Either it will return an error or
+ * an amount of bytes successfully moved. If the retval reports a
+ * "short" remap, the remap_anon_pages syscall should be repeated by
+ * userland with src+retval, dst+reval, len-retval if it wants to know
+ * about the error that interrupted it.
+ *
+ * The RAP_ALLOW_SRC_HOLES flag can be specified to prevent -ENOENT
+ * errors to materialize if there are holes in the source virtual
+ * range that is being remapped. The holes will be accounted as
+ * successfully remapped in the retval of the syscall. This is mostly
+ * useful to remap hugepage naturally aligned virtual regions without
+ * knowing if there are transparent hugepage in the regions or not,
+ * but preventing the risk of having to split the hugepmd during the
+ * remap.
+ *
+ * If there's any rmap walk that is taking the anon_vma locks without
+ * first obtaining the page lock (for example split_huge_page and
+ * page_referenced_anon), they will have to verify if the
+ * page->mapping has changed after taking the anon_vma lock. If it
+ * changed they should release the lock and retry obtaining a new
+ * anon_vma, because it means the anon_vma was changed by
+ * remap_anon_pages before the lock could be obtained. This is the
+ * only additional complexity added to the rmap code to provide this
+ * anonymous page remapping functionality.
+ */
+SYSCALL_DEFINE4(remap_anon_pages,
+		unsigned long, dst_start, unsigned long, src_start,
+		unsigned long, len, unsigned long, flags)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *src_vma, *dst_vma;
+	long err = -EINVAL;
+	pmd_t *src_pmd, *dst_pmd;
+	pte_t *src_pte, *dst_pte;
+	spinlock_t *dst_ptl, *src_ptl;
+	unsigned long src_addr, dst_addr;
+	int thp_aligned = -1;
+	long moved = 0;
+
+	/*
+	 * Sanitize the syscall parameters:
+	 */
+	if (src_start & ~PAGE_MASK)
+		return err;
+	if (dst_start & ~PAGE_MASK)
+		return err;
+	if (len & ~PAGE_MASK)
+		return err;
+	if (flags & ~RAP_ALLOW_SRC_HOLES)
+		return err;
+
+	/* Does the address range wrap, or is the span zero-sized? */
+	if (unlikely(src_start + len <= src_start))
+		return err;
+	if (unlikely(dst_start + len <= dst_start))
+		return err;
+
+	down_read(&mm->mmap_sem);
+
+	/*
+	 * Make sure the vma is not shared, that the src and dst remap
+	 * ranges are both valid and fully within a single existing
+	 * vma.
+	 */
+	src_vma = find_vma(mm, src_start);
+	if (!src_vma || (src_vma->vm_flags & VM_SHARED))
+		goto out;
+	if (src_start < src_vma->vm_start ||
+	    src_start + len > src_vma->vm_end)
+		goto out;
+
+	dst_vma = find_vma(mm, dst_start);
+	if (!dst_vma || (dst_vma->vm_flags & VM_SHARED))
+		goto out;
+	if (dst_start < dst_vma->vm_start ||
+	    dst_start + len > dst_vma->vm_end)
+		goto out;
+
+	if (pgprot_val(src_vma->vm_page_prot) !=
+	    pgprot_val(dst_vma->vm_page_prot))
+		goto out;
+
+	/* only allow remapping if both are mlocked or both aren't */
+	if ((src_vma->vm_flags & VM_LOCKED) ^ (dst_vma->vm_flags & VM_LOCKED))
+		goto out;
+
+	/*
+	 * Ensure the dst_vma has a anon_vma or this page
+	 * would get a NULL anon_vma when moved in the
+	 * dst_vma.
+	 */
+	err = -ENOMEM;
+	if (unlikely(anon_vma_prepare(dst_vma)))
+		goto out;
+
+	for (src_addr = src_start, dst_addr = dst_start;
+	     src_addr < src_start + len; ) {
+		spinlock_t *ptl;
+		pmd_t dst_pmdval;
+		BUG_ON(dst_addr >= dst_start + len);
+		src_pmd = mm_find_pmd(mm, src_addr);
+		if (unlikely(!src_pmd)) {
+			if (!(flags & RAP_ALLOW_SRC_HOLES)) {
+				err = -ENOENT;
+				break;
+			} else {
+				src_pmd = mm_alloc_pmd(mm, src_addr);
+				if (unlikely(!src_pmd)) {
+					err = -ENOMEM;
+					break;
+				}
+			}
+		}
+		dst_pmd = mm_alloc_pmd(mm, dst_addr);
+		if (unlikely(!dst_pmd)) {
+			err = -ENOMEM;
+			break;
+		}
+
+		dst_pmdval = pmd_read_atomic(dst_pmd);
+		/*
+		 * If the dst_pmd is mapped as THP don't
+		 * override it and just be strict.
+		 */
+		if (unlikely(pmd_trans_huge(dst_pmdval))) {
+			err = -EEXIST;
+			break;
+		}
+		if (pmd_trans_huge_lock(src_pmd, src_vma, &ptl) == 1) {
+			/*
+			 * Check if we can move the pmd without
+			 * splitting it. First check the address
+			 * alignment to be the same in src/dst.  These
+			 * checks don't actually need the PT lock but
+			 * it's good to do it here to optimize this
+			 * block away at build time if
+			 * CONFIG_TRANSPARENT_HUGEPAGE is not set.
+			 */
+			if (thp_aligned == -1)
+				thp_aligned = ((src_addr & ~HPAGE_PMD_MASK) ==
+					       (dst_addr & ~HPAGE_PMD_MASK));
+			if (!thp_aligned || (src_addr & ~HPAGE_PMD_MASK) ||
+			    !pmd_none(dst_pmdval) ||
+			    src_start + len - src_addr < HPAGE_PMD_SIZE) {
+				spin_unlock(ptl);
+				/* Fall through */
+				split_huge_page_pmd(src_vma, src_addr,
+						    src_pmd);
+			} else {
+				BUG_ON(dst_addr & ~HPAGE_PMD_MASK);
+				err = remap_anon_pages_huge_pmd(mm,
+								dst_pmd,
+								src_pmd,
+								dst_pmdval,
+								dst_vma,
+								src_vma,
+								dst_addr,
+								src_addr);
+				cond_resched();
+
+				if (!err) {
+					dst_addr += HPAGE_PMD_SIZE;
+					src_addr += HPAGE_PMD_SIZE;
+					moved += HPAGE_PMD_SIZE;
+				}
+
+				if ((!err || err == -EAGAIN) &&
+				    fatal_signal_pending(current))
+					err = -EINTR;
+
+				if (err && err != -EAGAIN)
+					break;
+
+				continue;
+			}
+		}
+
+		if (pmd_none(*src_pmd)) {
+			if (!(flags & RAP_ALLOW_SRC_HOLES)) {
+				err = -ENOENT;
+				break;
+			} else {
+				if (unlikely(__pte_alloc(mm, src_vma, src_pmd,
+							 src_addr))) {
+					err = -ENOMEM;
+					break;
+				}
+			}
+		}
+
+		/*
+		 * We held the mmap_sem for reading so MADV_DONTNEED
+		 * can zap transparent huge pages under us, or the
+		 * transparent huge page fault can establish new
+		 * transparent huge pages under us.
+		 */
+		if (unlikely(pmd_trans_unstable(src_pmd))) {
+			err = -EFAULT;
+			break;
+		}
+
+		if (unlikely(pmd_none(dst_pmdval)) &&
+		    unlikely(__pte_alloc(mm, dst_vma, dst_pmd,
+					 dst_addr))) {
+			err = -ENOMEM;
+			break;
+		}
+		/* If an huge pmd materialized from under us fail */
+		if (unlikely(pmd_trans_huge(*dst_pmd))) {
+			err = -EFAULT;
+			break;
+		}
+
+		BUG_ON(pmd_none(*dst_pmd));
+		BUG_ON(pmd_none(*src_pmd));
+		BUG_ON(pmd_trans_huge(*dst_pmd));
+		BUG_ON(pmd_trans_huge(*src_pmd));
+
+		dst_pte = pte_offset_map(dst_pmd, dst_addr);
+		src_pte = pte_offset_map(src_pmd, src_addr);
+		dst_ptl = pte_lockptr(mm, dst_pmd);
+		src_ptl = pte_lockptr(mm, src_pmd);
+
+		err = remap_anon_pages_pte(mm,
+					   dst_pte, src_pte, src_pmd,
+					   dst_vma, src_vma,
+					   dst_addr, src_addr,
+					   dst_ptl, src_ptl, flags);
+
+		pte_unmap(dst_pte);
+		pte_unmap(src_pte);
+		cond_resched();
+
+		if (!err) {
+			dst_addr += PAGE_SIZE;
+			src_addr += PAGE_SIZE;
+			moved += PAGE_SIZE;
+		}
+
+		if ((!err || err == -EAGAIN) &&
+		    fatal_signal_pending(current))
+			err = -EINTR;
+
+		if (err && err != -EAGAIN)
+			break;
+	}
+
+out:
+	up_read(&mm->mmap_sem);
+	BUG_ON(moved < 0);
+	BUG_ON(err > 0);
+	BUG_ON(!moved && !err);
+	return moved ? moved : err;
+}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4277ed7..9c66428 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1555,6 +1555,116 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 }
 
 /*
+ * The PT lock for src_pmd and the mmap_sem for reading are held by
+ * the caller, but it must return after releasing the
+ * page_table_lock. We're guaranteed the src_pmd is a pmd_trans_huge
+ * until the PT lock of the src_pmd is released. Just move the page
+ * from src_pmd to dst_pmd if possible. Return zero if succeeded in
+ * moving the page, -EAGAIN if it needs to be repeated by the caller,
+ * or other errors in case of failure.
+ */
+int remap_anon_pages_huge_pmd(struct mm_struct *mm,
+			      pmd_t *dst_pmd, pmd_t *src_pmd,
+			      pmd_t dst_pmdval,
+			      struct vm_area_struct *dst_vma,
+			      struct vm_area_struct *src_vma,
+			      unsigned long dst_addr,
+			      unsigned long src_addr)
+{
+	pmd_t _dst_pmd, src_pmdval;
+	struct page *src_page;
+	struct anon_vma *src_anon_vma, *dst_anon_vma;
+	spinlock_t *src_ptl, *dst_ptl;
+	pgtable_t pgtable;
+
+	src_pmdval = *src_pmd;
+	src_ptl = pmd_lockptr(mm, src_pmd);
+
+	BUG_ON(!pmd_trans_huge(src_pmdval));
+	BUG_ON(pmd_trans_splitting(src_pmdval));
+	BUG_ON(!pmd_none(dst_pmdval));
+	BUG_ON(!spin_is_locked(src_ptl));
+	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+
+	src_page = pmd_page(src_pmdval);
+	BUG_ON(!PageHead(src_page));
+	BUG_ON(!PageAnon(src_page));
+	if (unlikely(page_mapcount(src_page) != 1)) {
+		spin_unlock(src_ptl);
+		return -EBUSY;
+	}
+
+	get_page(src_page);
+	spin_unlock(src_ptl);
+
+	mmu_notifier_invalidate_range_start(mm, src_addr,
+					    src_addr + HPAGE_PMD_SIZE);
+
+	/* block all concurrent rmap walks */
+	lock_page(src_page);
+
+	/*
+	 * split_huge_page walks the anon_vma chain without the page
+	 * lock. Serialize against it with the anon_vma lock, the page
+	 * lock is not enough.
+	 */
+	src_anon_vma = page_get_anon_vma(src_page);
+	if (!src_anon_vma) {
+		unlock_page(src_page);
+		put_page(src_page);
+		mmu_notifier_invalidate_range_end(mm, src_addr,
+						  src_addr + HPAGE_PMD_SIZE);
+		return -EAGAIN;
+	}
+	anon_vma_lock_write(src_anon_vma);
+
+	dst_ptl = pmd_lockptr(mm, dst_pmd);
+	double_pt_lock(src_ptl, dst_ptl);
+	if (unlikely(!pmd_same(*src_pmd, src_pmdval) ||
+		     !pmd_same(*dst_pmd, dst_pmdval) ||
+		     page_mapcount(src_page) != 1)) {
+		double_pt_unlock(src_ptl, dst_ptl);
+		anon_vma_unlock_write(src_anon_vma);
+		put_anon_vma(src_anon_vma);
+		unlock_page(src_page);
+		put_page(src_page);
+		mmu_notifier_invalidate_range_end(mm, src_addr,
+						  src_addr + HPAGE_PMD_SIZE);
+		return -EAGAIN;
+	}
+
+	BUG_ON(!PageHead(src_page));
+	BUG_ON(!PageAnon(src_page));
+	/* the PT lock is enough to keep the page pinned now */
+	put_page(src_page);
+
+	dst_anon_vma = (void *) dst_vma->anon_vma + PAGE_MAPPING_ANON;
+	ACCESS_ONCE(src_page->mapping) = (struct address_space *) dst_anon_vma;
+	ACCESS_ONCE(src_page->index) = linear_page_index(dst_vma, dst_addr);
+
+	if (!pmd_same(pmdp_clear_flush(src_vma, src_addr, src_pmd),
+		      src_pmdval))
+		BUG();
+	_dst_pmd = mk_huge_pmd(src_page, dst_vma->vm_page_prot);
+	_dst_pmd = maybe_pmd_mkwrite(pmd_mkdirty(_dst_pmd), dst_vma);
+	set_pmd_at(mm, dst_addr, dst_pmd, _dst_pmd);
+
+	pgtable = pgtable_trans_huge_withdraw(mm, src_pmd);
+	pgtable_trans_huge_deposit(mm, dst_pmd, pgtable);
+	double_pt_unlock(src_ptl, dst_ptl);
+
+	anon_vma_unlock_write(src_anon_vma);
+	put_anon_vma(src_anon_vma);
+
+	/* unblock rmap walks */
+	unlock_page(src_page);
+
+	mmu_notifier_invalidate_range_end(mm, src_addr,
+					  src_addr + HPAGE_PMD_SIZE);
+	return 0;
+}
+
+/*
  * Returns 1 if a given pmd maps a stable (not under splitting) thp.
  * Returns -1 if it maps a thp under splitting. Returns 0 otherwise.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
