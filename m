Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBALVOcX017236
	for <linux-mm@kvack.org>; Mon, 10 Dec 2007 16:31:24 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBALVGrB464192
	for <linux-mm@kvack.org>; Mon, 10 Dec 2007 16:31:24 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBALVGot021793
	for <linux-mm@kvack.org>; Mon, 10 Dec 2007 16:31:16 -0500
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <200710152225.11433.nickpiggin@yahoo.com.au>
References: <20071008225234.GC27824@linux-os.sc.intel.com>
	 <200710141101.02649.nickpiggin@yahoo.com.au>
	 <20071014181929.GA19902@linux-os.sc.intel.com>
	 <200710152225.11433.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Mon, 10 Dec 2007 15:30:57 -0600
Message-Id: <1197322257.11805.15.camel@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Ken Chen <kenchen@google.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com, Adam Litke <agl@us.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-10-15 at 22:25 +1000, Nick Piggin wrote:
> On Monday 15 October 2007 04:19, Siddha, Suresh B wrote:
> > On Sun, Oct 14, 2007 at 11:01:02AM +1000, Nick Piggin wrote:

> > > This is just a really quick hack, untested ATM, but one that
> > > has at least a chance of working (on x86).
> >
> > When we fall back to slow mode, we should decrement the ref counts
> > on the pages we got so far in the fast mode.
> 
> Here is something that is actually tested and works (not
> tested with hugepages yet, though).
> 
> However it's not 100% secure at the moment. It's actually
> not completely trivial; I think we need to use an extra bit
> in the present pte in order to exclude "not normal" pages,
> if we want fast_gup to work on small page mappings too. I
> think this would be possible to do on most architectures, but
> I haven't done it here obviously.
> 
> Still, it should be enough to test the design. I've added
> fast_gup and fast_gup_slow to /proc/vmstat, which count the
> number of times fast_gup was called, and the number of times
> it dropped into the slowpath. It would be interesting to know
> how it performs compared to your granular hugepage ptl...

Nick,
I've played with the fast_gup patch a bit.  I was able to find a problem
in follow_hugetlb_page() that Adam Litke fixed.  I'm haven't been brave
enough to implement it on any other architectures, but I did add  a
default that takes mmap_sem and calls the normal get_user_pages() if the
architecture doesn't define fast_gup().  I put it in linux/mm.h, for
lack of a better place, but it's a little kludgy since I didn't want
mm.h to have to include sched.h.  This patch is against 2.6.24-rc4.
It's not ready for inclusion yet, of course.

I haven't done much benchmarking.  The one test I was looking at didn't
show much of a change.

 ==============================================
Introduce a new "fast_gup" (for want of a better name right now) which
is basically a get_user_pages with a less general API that is more suited
to the common case.

- task and mm are always current and current->mm
- force is always 0
- pages is always non-NULL
- don't pass back vmas

This allows (at least on x86), an optimistic lockless pagetable walk,
without taking any page table locks or even mmap_sem. Page table existence
is guaranteed by turning interrupts off (combined with the fact that we're
always looking up the current mm, which would need an IPI before its
pagetables could be shot down from another CPU).

Many other architectures could do the same thing. Those that don't IPI
could potentially RCU free the page tables and do speculative references
on the pages (a la lockless pagecache) to achieve a lockless fast_gup.

Originally by Nick Piggin <nickpiggin@yahoo.com.au>
---
 arch/x86/lib/Makefile_64     |    2 
 arch/x86/lib/gup_64.c        |  188 +++++++++++++++++++++++++++++++++++++++++++
 fs/bio.c                     |    8 -
 fs/block_dev.c               |    5 -
 fs/direct-io.c               |   10 --
 fs/splice.c                  |   38 --------
 include/asm-x86/uaccess_64.h |    4 
 include/linux/mm.h           |   26 +++++
 include/linux/vmstat.h       |    1 
 mm/vmstat.c                  |    3 
 10 files changed, 231 insertions(+), 54 deletions(-)

diff -Nurp linux-2.6.24-rc4/arch/x86/lib/Makefile_64 linux/arch/x86/lib/Makefile_64
--- linux-2.6.24-rc4/arch/x86/lib/Makefile_64	2007-12-04 08:44:34.000000000 -0600
+++ linux/arch/x86/lib/Makefile_64	2007-12-10 15:01:17.000000000 -0600
@@ -10,4 +10,4 @@ obj-$(CONFIG_SMP)	+= msr-on-cpu.o
 lib-y := csum-partial_64.o csum-copy_64.o csum-wrappers_64.o delay_64.o \
 	usercopy_64.o getuser_64.o putuser_64.o  \
 	thunk_64.o clear_page_64.o copy_page_64.o bitstr_64.o bitops_64.o
-lib-y += memcpy_64.o memmove_64.o memset_64.o copy_user_64.o rwlock_64.o copy_user_nocache_64.o
+lib-y += memcpy_64.o memmove_64.o memset_64.o copy_user_64.o rwlock_64.o copy_user_nocache_64.o gup_64.o
diff -Nurp linux-2.6.24-rc4/arch/x86/lib/gup_64.c linux/arch/x86/lib/gup_64.c
--- linux-2.6.24-rc4/arch/x86/lib/gup_64.c	1969-12-31 18:00:00.000000000 -0600
+++ linux/arch/x86/lib/gup_64.c	2007-12-10 15:01:17.000000000 -0600
@@ -0,0 +1,188 @@
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
+static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
+			 int write, struct page **pages, int *nr)
+{
+	pte_t *ptep;
+
+	/* XXX: this won't work for 32-bit (must map pte) */
+	ptep = (pte_t *)pmd_page_vaddr(pmd) + pte_index(addr);
+	do {
+		pte_t pte = *ptep;
+		unsigned long pfn;
+		struct page *page;
+
+		if ((pte_val(pte) & (_PAGE_PRESENT|_PAGE_USER)) !=
+		    (_PAGE_PRESENT|_PAGE_USER))
+			return 0;
+
+		if (write && !pte_write(pte))
+			return 0;
+
+		/* XXX: really need new bit in pte to denote normal page */
+		pfn = pte_pfn(pte);
+		if (unlikely(!pfn_valid(pfn)))
+			return 0;
+
+		page = pfn_to_page(pfn);
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
+static int gup_huge_pmd(pmd_t pmd, unsigned long addr, unsigned long end,
+			int write, struct page **pages, int *nr)
+{
+	pte_t pte = *(pte_t *)&pmd;
+	struct page *head, *page;
+	int refs;
+
+	if ((pte_val(pte) & _PAGE_USER) != _PAGE_USER)
+		return 0;
+
+	BUG_ON(!pfn_valid(pte_pfn(pte)));
+
+	if (write && !pte_write(pte))
+		return 0;
+
+	refs = 0;
+	head = pte_page(pte);
+	page = head + ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
+	do {
+		pages[*nr] = page;
+		(*nr)++;
+		page++;
+		refs++;
+	} while (addr += PAGE_SIZE, addr != end);
+
+	get_head_page_multiple(head, refs);
+
+	return 1;
+}
+
+static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
+			 int write, struct page **pages, int *nr)
+{
+	static int count = 50;
+	unsigned long next;
+	pmd_t *pmdp;
+
+	pmdp = (pmd_t *)pud_page_vaddr(pud) + pmd_index(addr);
+	do {
+		pmd_t pmd = *pmdp;
+
+		next = pmd_addr_end(addr, end);
+		if (pmd_none(pmd))
+			return 0;
+		if (unlikely(pmd_large(pmd))) {
+			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr)) {
+				if (count) {
+					printk(KERN_ERR
+						"pmd = 0x%lx, addr = 0x%lx\n",
+						pmd.pmd, addr);
+					count--;
+				}
+				return 0;
+			}
+		} else {
+			if (!gup_pte_range(pmd, addr, next, write, pages, nr))
+				return 0;
+		}
+	} while (pmdp++, addr = next, addr != end);
+
+	return 1;
+}
+
+static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
+			 int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	pud_t *pudp;
+
+	pudp = (pud_t *)pgd_page_vaddr(pgd) + pud_index(addr);
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
+	/* XXX: batch / limit 'nr', to avoid huge latency */
+	/*
+	 * This doesn't prevent pagetable teardown, but does prevent
+	 * the pagetables from being freed on x86-64.
+	 *
+	 * So long as we atomically load page table pointers versus teardown
+	 * (which we do on x86-64), we can follow the address down to the
+	 * the page.
+	 */
+	local_irq_disable();
+	__count_vm_event(FAST_GUP);
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
+	BUG_ON(nr != (end - start) >> PAGE_SHIFT);
+	return nr;
+
+slow:
+	{
+		int i, ret;
+
+		__count_vm_event(FAST_GUP_SLOW);
+		local_irq_enable();
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
diff -Nurp linux-2.6.24-rc4/fs/bio.c linux/fs/bio.c
--- linux-2.6.24-rc4/fs/bio.c	2007-12-04 08:44:49.000000000 -0600
+++ linux/fs/bio.c	2007-12-10 15:01:17.000000000 -0600
@@ -636,13 +636,9 @@ static struct bio *__bio_map_user_iov(st
 		unsigned long start = uaddr >> PAGE_SHIFT;
 		const int local_nr_pages = end - start;
 		const int page_limit = cur_page + local_nr_pages;
-		
-		down_read(&current->mm->mmap_sem);
-		ret = get_user_pages(current, current->mm, uaddr,
-				     local_nr_pages,
-				     write_to_vm, 0, &pages[cur_page], NULL);
-		up_read(&current->mm->mmap_sem);
 
+		ret = fast_gup(uaddr, local_nr_pages, write_to_vm,
+			       &pages[cur_page]);
 		if (ret < local_nr_pages) {
 			ret = -EFAULT;
 			goto out_unmap;
diff -Nurp linux-2.6.24-rc4/fs/block_dev.c linux/fs/block_dev.c
--- linux-2.6.24-rc4/fs/block_dev.c	2007-12-04 08:44:49.000000000 -0600
+++ linux/fs/block_dev.c	2007-12-10 15:01:17.000000000 -0600
@@ -221,10 +221,7 @@ static struct page *blk_get_page(unsigne
 	if (pvec->idx == pvec->nr) {
 		nr_pages = PAGES_SPANNED(addr, count);
 		nr_pages = min(nr_pages, VEC_SIZE);
-		down_read(&current->mm->mmap_sem);
-		ret = get_user_pages(current, current->mm, addr, nr_pages,
-				     rw == READ, 0, pvec->page, NULL);
-		up_read(&current->mm->mmap_sem);
+		ret = fast_gup(addr, nr_pages, rw == READ, pvec->page);
 		if (ret < 0)
 			return ERR_PTR(ret);
 		pvec->nr = ret;
diff -Nurp linux-2.6.24-rc4/fs/direct-io.c linux/fs/direct-io.c
--- linux-2.6.24-rc4/fs/direct-io.c	2007-12-04 08:44:49.000000000 -0600
+++ linux/fs/direct-io.c	2007-12-10 15:01:17.000000000 -0600
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
diff -Nurp linux-2.6.24-rc4/fs/splice.c linux/fs/splice.c
--- linux-2.6.24-rc4/fs/splice.c	2007-12-04 08:44:50.000000000 -0600
+++ linux/fs/splice.c	2007-12-10 15:01:17.000000000 -0600
@@ -1174,33 +1174,6 @@ static long do_splice(struct file *in, l
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
  * Map an iov into an array of pages and offset/length tupples. With the
  * partial_page structure, we can map several non-contiguous ranges into
  * our ones pages[] map instead of splitting that operation into pieces.
@@ -1213,8 +1186,6 @@ static int get_iovec_page_array(const st
 {
 	int buffers = 0, error = 0;
 
-	down_read(&current->mm->mmap_sem);
-
 	while (nr_vecs) {
 		unsigned long off, npages;
 		struct iovec entry;
@@ -1223,7 +1194,7 @@ static int get_iovec_page_array(const st
 		int i;
 
 		error = -EFAULT;
-		if (copy_from_user_mmap_sem(&entry, iov, sizeof(entry)))
+		if (copy_from_user(&entry, iov, sizeof(entry)))
 			break;
 
 		base = entry.iov_base;
@@ -1257,9 +1228,8 @@ static int get_iovec_page_array(const st
 		if (npages > PIPE_BUFFERS - buffers)
 			npages = PIPE_BUFFERS - buffers;
 
-		error = get_user_pages(current, current->mm,
-				       (unsigned long) base, npages, 0, 0,
-				       &pages[buffers], NULL);
+		error = fast_gup((unsigned long)base, npages, 0,
+				 &pages[buffers]);
 
 		if (unlikely(error <= 0))
 			break;
@@ -1298,8 +1268,6 @@ static int get_iovec_page_array(const st
 		iov++;
 	}
 
-	up_read(&current->mm->mmap_sem);
-
 	if (buffers)
 		return buffers;
 
diff -Nurp linux-2.6.24-rc4/include/asm-x86/uaccess_64.h linux/include/asm-x86/uaccess_64.h
--- linux-2.6.24-rc4/include/asm-x86/uaccess_64.h	2007-12-04 08:44:54.000000000 -0600
+++ linux/include/asm-x86/uaccess_64.h	2007-12-10 15:01:17.000000000 -0600
@@ -381,4 +381,8 @@ static inline int __copy_from_user_inato
 	return __copy_user_nocache(dst, src, size, 0);
 }
 
+#define __HAVE_ARCH_FAST_GUP
+struct page;
+int fast_gup(unsigned long start, int nr_pages, int write, struct page **pages);
+
 #endif /* __X86_64_UACCESS_H */
diff -Nurp linux-2.6.24-rc4/include/linux/mm.h linux/include/linux/mm.h
--- linux-2.6.24-rc4/include/linux/mm.h	2007-12-04 08:44:56.000000000 -0600
+++ linux/include/linux/mm.h	2007-12-10 15:01:17.000000000 -0600
@@ -12,6 +12,7 @@
 #include <linux/prio_tree.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
+#include <linux/uaccess.h>	/* for __HAVE_ARCH_FAST_GUP */
 
 struct mempolicy;
 struct anon_vma;
@@ -750,6 +751,31 @@ extern int mprotect_fixup(struct vm_area
 			  unsigned long end, unsigned long newflags);
 
 /*
+ * Architecture may implement efficient get_user_pages to avoid having to
+ * take the mmap sem
+ */
+#ifndef __HAVE_ARCH_FAST_GUP
+static inline int __fast_gup(struct mm_struct *mm, unsigned long start,
+			     int nr_pages, int write, struct page **pages)
+{
+	int ret;
+
+	down_read(&mm->mmap_sem);
+	ret = get_user_pages(current, mm, start, nr_pages, write,
+			     0, pages, NULL);
+	up_read(&mm->mmap_sem);
+
+	return ret;
+}
+/*
+ * This macro avoids having to include sched.h in this header to
+ * dereference current->mm.
+ */
+#define fast_gup(start, nr_pages, write, pages) \
+	__fast_gup(current->mm, start, nr_pages, write, pages)
+#endif
+
+/*
  * A callback you can register to apply pressure to ageable caches.
  *
  * 'shrink' is passed a count 'nr_to_scan' and a 'gfpmask'.  It should
diff -Nurp linux-2.6.24-rc4/include/linux/vmstat.h linux/include/linux/vmstat.h
--- linux-2.6.24-rc4/include/linux/vmstat.h	2007-10-09 15:31:38.000000000 -0500
+++ linux/include/linux/vmstat.h	2007-12-10 15:01:17.000000000 -0600
@@ -37,6 +37,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		FOR_ALL_ZONES(PGSCAN_DIRECT),
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+		FAST_GUP, FAST_GUP_SLOW,
 		NR_VM_EVENT_ITEMS
 };
 
diff -Nurp linux-2.6.24-rc4/mm/vmstat.c linux/mm/vmstat.c
--- linux-2.6.24-rc4/mm/vmstat.c	2007-12-04 08:45:01.000000000 -0600
+++ linux/mm/vmstat.c	2007-12-10 15:01:17.000000000 -0600
@@ -642,6 +642,9 @@ static const char * const vmstat_text[] 
 	"allocstall",
 
 	"pgrotated",
+	"fast_gup",
+	"fast_gup_slow",
+
 #endif
 };
 

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
