Date: Fri, 28 Mar 2008 04:00:23 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/2]: introduce fast_gup
Message-ID: <20080328030023.GC8083@wotan.suse.de>
References: <20080328025455.GA8083@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080328025455.GA8083@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: shaggy@austin.ibm.com, axboe@kernel.dk, linux-mm@kvack.org, linux-arch@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Introduce a new "fast_gup" (for want of a better name right now) which
is basically a get_user_pages with a less general API (but still tends to
be suited to the common case):

- task and mm are always current and current->mm
- force is always 0
- pages is always non-NULL
- don't pass back vmas

This restricted API can be implemented in a much more scalable way when
the ptes are present, by walking the page tables locklessly.

Before anybody asks; it is impossible to just "detect" such a situation in the
existing get_user_pages call, and branch to a fastpath in that case, because
get_user_pages requres the mmap_sem is held over the call, wheras fast_gup does
not.

This patch implements fast_gup as a generic function that falls back to
get_user_pages. It converts key direct IO (and splice, for fun) callsites.
It also implements an optimised version on x86, which does not take any
locks in the fastpath.

On x86, we do an optimistic lockless pagetable walk, without taking any page
table locks or even mmap_sem. Page table existence is guaranteed by turning
interrupts off (combined with the fact that we're always looking up the current
mm, means we can do the lockless page table walk within the constraints of the
TLB shootdown design). Basically we can do this lockless pagetable walk in a
similar manner to the way the CPU's pagetable walker does not have to take any
locks to find present ptes.

Many other architectures could do the same thing. Those that don't IPI
could potentially RCU free the page tables and do speculative references
on the pages (a la lockless pagecache) to achieve a lockless fast_gup. I
have actually got an implementation of this for powerpc.

This patch was found to give about 10% performance improvement on a 2 socket
8 core Intel Xeon system running an OLTP workload on DB2 v9.5

 "To test the effects of the patch, an OLTP workload was run on an IBM
 x3850 M2 server with 2 processors (quad-core Intel Xeon processors at
 2.93 GHz) using IBM DB2 v9.5 running Linux 2.6.24rc7 kernel. Comparing
 runs with and without the patch resulted in an overall performance
 benefit of ~9.8%. Correspondingly, oprofiles showed that samples from
 __up_read and __down_read routines that is seen during thread contention
 for system resources was reduced from 2.8% down to .05%. Monitoring
 the /proc/vmstat output from the patched run showed that the counter for
 fast_gup contained a very high number while the fast_gup_slow value was
 zero."

(fast_gup_slow is a counter we had for the number of times the slowpath
was invoked).

The main reason for the improvement is that DB2 has multiple threads each
issuing direct-IO. Direct-IO uses get_user_pages, and thus the threads
contend the mmap_sem cacheline, and can also contend on page table locks.

I would anticipate larger performance gains on larger systems, however I
think DB2 uses an adaptive mix of threads and processes, so it could be
that thread contention remains pretty constant as machine size increases.
In which case, we stuck with "only" a 10% gain.

Lots of other code could use this too (eg. grep drivers/)

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 arch/x86/mm/Makefile      |    2 
 arch/x86/mm/gup.c         |  193 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/bio.c                  |    8 -
 fs/direct-io.c            |   10 --
 fs/splice.c               |   41 ---------
 include/asm-x86/uaccess.h |    5 +
 include/linux/mm.h        |   19 ++++
 7 files changed, 225 insertions(+), 53 deletions(-)

Index: linux-2.6/fs/bio.c
===================================================================
--- linux-2.6.orig/fs/bio.c
+++ linux-2.6/fs/bio.c
@@ -637,12 +637,8 @@ static struct bio *__bio_map_user_iov(st
 		const int local_nr_pages = end - start;
 		const int page_limit = cur_page + local_nr_pages;
 		
-		down_read(&current->mm->mmap_sem);
-		ret = get_user_pages(current, current->mm, uaddr,
-				     local_nr_pages,
-				     write_to_vm, 0, &pages[cur_page], NULL);
-		up_read(&current->mm->mmap_sem);
-
+		ret = fast_gup(uaddr, local_nr_pages,
+				write_to_vm, &pages[cur_page]);
 		if (ret < local_nr_pages) {
 			ret = -EFAULT;
 			goto out_unmap;
Index: linux-2.6/fs/direct-io.c
===================================================================
--- linux-2.6.orig/fs/direct-io.c
+++ linux-2.6/fs/direct-io.c
@@ -150,17 +150,11 @@ static int dio_refill_pages(struct dio *
 	int nr_pages;
 
 	nr_pages = min(dio->total_pages - dio->curr_page, DIO_PAGES);
-	down_read(&current->mm->mmap_sem);
-	ret = get_user_pages(
-		current,			/* Task for fault acounting */
-		current->mm,			/* whose pages? */
+	ret = fast_gup(
 		dio->curr_user_address,		/* Where from? */
 		nr_pages,			/* How many pages? */
 		dio->rw == READ,		/* Write to memory? */
-		0,				/* force (?) */
-		&dio->pages[0],
-		NULL);				/* vmas */
-	up_read(&current->mm->mmap_sem);
+		&dio->pages[0]);		/* Put results here */
 
 	if (ret < 0 && dio->blocks_available && (dio->rw & WRITE)) {
 		struct page *page = ZERO_PAGE(0);
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
@@ -1170,36 +1170,6 @@ static long do_splice(struct file *in, l
 }
 
 /*
- * Do a copy-from-user while holding the mmap_semaphore for reading, in a
- * manner safe from deadlocking with simultaneous mmap() (grabbing mmap_sem
- * for writing) and page faulting on the user memory pointed to by src.
- * This assumes that we will very rarely hit the partial != 0 path, or this
- * will not be a win.
- */
-static int copy_from_user_mmap_sem(void *dst, const void __user *src, size_t n)
-{
-	int partial;
-
-	if (!access_ok(VERIFY_READ, src, n))
-		return -EFAULT;
-
-	pagefault_disable();
-	partial = __copy_from_user_inatomic(dst, src, n);
-	pagefault_enable();
-
-	/*
-	 * Didn't copy everything, drop the mmap_sem and do a faulting copy
-	 */
-	if (unlikely(partial)) {
-		up_read(&current->mm->mmap_sem);
-		partial = copy_from_user(dst, src, n);
-		down_read(&current->mm->mmap_sem);
-	}
-
-	return partial;
-}
-
-/*
  * Just copy the data to user space
  */
 static int pipe_to_user_copy(struct pipe_inode_info *pipe,
@@ -1424,8 +1394,6 @@ static int get_iovec_page_array(const st
 {
 	int buffers = 0, error = 0;
 
-	down_read(&current->mm->mmap_sem);
-
 	while (nr_vecs) {
 		unsigned long off, npages;
 		struct iovec entry;
@@ -1434,7 +1402,7 @@ static int get_iovec_page_array(const st
 		int i;
 
 		error = -EFAULT;
-		if (copy_from_user_mmap_sem(&entry, iov, sizeof(entry)))
+		if (copy_from_user(&entry, iov, sizeof(entry)))
 			break;
 
 		base = entry.iov_base;
@@ -1468,9 +1436,8 @@ static int get_iovec_page_array(const st
 		if (npages > PIPE_BUFFERS - buffers)
 			npages = PIPE_BUFFERS - buffers;
 
-		error = get_user_pages(current, current->mm,
-				       (unsigned long) base, npages, 0, 0,
-				       &pages[buffers], NULL);
+		error = fast_gup((unsigned long)base, npages,
+					0, &pages[buffers]);
 
 		if (unlikely(error <= 0))
 			break;
@@ -1509,8 +1476,6 @@ static int get_iovec_page_array(const st
 		iov++;
 	}
 
-	up_read(&current->mm->mmap_sem);
-
 	if (buffers)
 		return buffers;
 
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -12,6 +12,7 @@
 #include <linux/prio_tree.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
+#include <linux/uaccess.h> /* for __HAVE_ARCH_FAST_GUP */
 
 struct mempolicy;
 struct anon_vma;
@@ -795,6 +796,24 @@ extern int mprotect_fixup(struct vm_area
 			  struct vm_area_struct **pprev, unsigned long start,
 			  unsigned long end, unsigned long newflags);
 
+#ifndef __HAVE_ARCH_FAST_GUP
+/* Should be moved to asm-generic, and architectures can include it if they
+ * don't implement their own fast_gup.
+ */
+#define fast_gup(start, nr_pages, write, pages)			\
+({								\
+	struct mm_struct *mm = current->mm;			\
+	int ret;						\
+								\
+	down_read(&mm->mmap_sem);				\
+	ret = get_user_pages(current, mm, start, nr_pages,	\
+					write, 0, pages, NULL);	\
+	up_read(&mm->mmap_sem);					\
+								\
+	ret;							\
+})
+#endif
+
 /*
  * A callback you can register to apply pressure to ageable caches.
  *
Index: linux-2.6/arch/x86/mm/Makefile
===================================================================
--- linux-2.6.orig/arch/x86/mm/Makefile
+++ linux-2.6/arch/x86/mm/Makefile
@@ -1,4 +1,4 @@
-obj-y	:=  init_$(BITS).o fault.o ioremap.o extable.o pageattr.o mmap.o
+obj-y	:=  init_$(BITS).o fault.o ioremap.o extable.o pageattr.o mmap.o gup.o
 
 obj-$(CONFIG_X86_32)		+= pgtable_32.o
 
Index: linux-2.6/arch/x86/mm/gup.c
===================================================================
--- /dev/null
+++ linux-2.6/arch/x86/mm/gup.c
@@ -0,0 +1,198 @@
+/*
+ * Lockless fast_gup for x86
+ *
+ * Copyright (C) 2007 Nick Piggin
+ * Copyright (C) 2007 Novell Inc.
+ */
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/vmstat.h>
+#include <asm/pgtable.h>
+
+/*
+ * The performance critical leaf functions are made noinline otherwise gcc
+ * inlines everything into a single function which results in too much
+ * register pressure.
+ */
+static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
+		unsigned long end, int write, struct page **pages, int *nr)
+{
+	unsigned long mask, result;
+	pte_t *ptep;
+
+	result = _PAGE_PRESENT|_PAGE_USER;
+	if (write)
+		result |= _PAGE_RW;
+	mask = result | _PAGE_SPECIAL;
+
+	ptep = pte_offset_map(&pmd, addr);
+	do {
+		/*
+		 * XXX: careful. On 3-level 32-bit, the pte is 64 bits, and
+		 * we need to make sure we load the low word first, then the
+		 * high. This means _PAGE_PRESENT should be clear if the high
+		 * word was not valid. Currently, the C compiler can issue
+		 * the loads in any order, and I don't know of a wrapper
+		 * function that will do this properly, so it is broken on
+		 * 32-bit 3-level for the moment.
+		 */
+		pte_t pte = *ptep;
+		struct page *page;
+
+		if ((pte_val(pte) & mask) != result)
+			return 0;
+		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+		page = pte_page(pte);
+		get_page(page);
+		pages[*nr] = page;
+		(*nr)++;
+
+	} while (ptep++, addr += PAGE_SIZE, addr != end);
+	pte_unmap(ptep - 1);
+
+	return 1;
+}
+
+static inline void get_head_page_multiple(struct page *page, int nr)
+{
+	VM_BUG_ON(page != compound_head(page));
+	VM_BUG_ON(page_count(page) == 0);
+	atomic_add(nr, &page->_count);
+}
+
+static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
+		unsigned long end, int write, struct page **pages, int *nr)
+{
+	unsigned long mask;
+	pte_t pte = *(pte_t *)&pmd;
+	struct page *head, *page;
+	int refs;
+
+	mask = _PAGE_PRESENT|_PAGE_USER;
+	if (write)
+		mask |= _PAGE_RW;
+	if ((pte_val(pte) & mask) != mask)
+		return 0;
+	/* hugepages are never "special" */
+	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+
+	refs = 0;
+	head = pte_page(pte);
+	page = head + ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
+	do {
+		VM_BUG_ON(compound_head(page) != head);
+		pages[*nr] = page;
+		(*nr)++;
+		page++;
+		refs++;
+	} while (addr += PAGE_SIZE, addr != end);
+	get_head_page_multiple(head, refs);
+
+	return 1;
+}
+
+static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
+		int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	pmd_t *pmdp;
+
+	pmdp = pmd_offset(&pud, addr);
+	do {
+		pmd_t pmd = *pmdp;
+
+		next = pmd_addr_end(addr, end);
+		if (pmd_none(pmd))
+			return 0;
+		if (unlikely(pmd_large(pmd))) {
+			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
+				return 0;
+		} else {
+			if (!gup_pte_range(pmd, addr, next, write, pages, nr))
+				return 0;
+		}
+	} while (pmdp++, addr = next, addr != end);
+
+	return 1;
+}
+
+static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end, int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	pud_t *pudp;
+
+	pudp = pud_offset(&pgd, addr);
+	do {
+		pud_t pud = *pudp;
+
+		next = pud_addr_end(addr, end);
+		if (pud_none(pud))
+			return 0;
+		if (!gup_pmd_range(pud, addr, next, write, pages, nr))
+			return 0;
+	} while (pudp++, addr = next, addr != end);
+
+	return 1;
+}
+
+int fast_gup(unsigned long start, int nr_pages, int write, struct page **pages)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long end = start + (nr_pages << PAGE_SHIFT);
+	unsigned long addr = start;
+	unsigned long next;
+	pgd_t *pgdp;
+	int nr = 0;
+
+	/*
+	 * XXX: batch / limit 'nr', to avoid huge latency
+	 * needs some instrumenting to determine the common sizes used by
+	 * important workloads (eg. DB2), and whether limiting the batch size
+	 * will decrease performance.
+	 *
+	 * At the moment we're pretty well in the clear: direct-IO only does
+	 * 64 pages at a time here, so this is only a theoretical concern. It
+	 * is possible that for simplicity here, we should just ask that
+	 * callers limit their nr_pages?
+	 */
+	/*
+	 * This doesn't prevent pagetable teardown, but does prevent
+	 * the pagetables and pages from being freed on x86.
+	 *
+	 * So long as we atomically load page table pointers versus teardown
+	 * (which we do on x86), we can follow the address down to the the
+	 * page and take a ref on it.
+	 */
+	local_irq_disable();
+	pgdp = pgd_offset(mm, addr);
+	do {
+		pgd_t pgd = *pgdp;
+
+		next = pgd_addr_end(addr, end);
+		if (pgd_none(pgd))
+			goto slow;
+		if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
+			goto slow;
+	} while (pgdp++, addr = next, addr != end);
+	local_irq_enable();
+
+	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
+	return nr;
+
+slow:
+	{
+		int i, ret;
+
+		local_irq_enable();
+		/* Could optimise this more by keeping what we've already got */
+		for (i = 0; i < nr; i++)
+			put_page(pages[i]);
+
+		down_read(&mm->mmap_sem);
+		ret = get_user_pages(current, mm, start,
+			(end - start) >> PAGE_SHIFT, write, 0, pages, NULL);
+		up_read(&mm->mmap_sem);
+
+		return ret;
+	}
+}
Index: linux-2.6/include/asm-x86/uaccess.h
===================================================================
--- linux-2.6.orig/include/asm-x86/uaccess.h
+++ linux-2.6/include/asm-x86/uaccess.h
@@ -3,3 +3,8 @@
 #else
 # include "uaccess_64.h"
 #endif
+
+#define __HAVE_ARCH_FAST_GUP
+struct page;
+int fast_gup(unsigned long start, int nr_pages, int write, struct page **pages);
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
