From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
Date: Mon, 15 Oct 2007 22:25:11 +1000
References: <20071008225234.GC27824@linux-os.sc.intel.com> <200710141101.02649.nickpiggin@yahoo.com.au> <20071014181929.GA19902@linux-os.sc.intel.com>
In-Reply-To: <20071014181929.GA19902@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_nw1EH1QlB02vnxv"
Message-Id: <200710152225.11433.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Cc: Ken Chen <kenchen@google.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

--Boundary-00=_nw1EH1QlB02vnxv
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Monday 15 October 2007 04:19, Siddha, Suresh B wrote:
> On Sun, Oct 14, 2007 at 11:01:02AM +1000, Nick Piggin wrote:
> > On Sunday 14 October 2007 09:27, Nick Piggin wrote:
> > > On Saturday 13 October 2007 06:34, Siddha, Suresh B wrote:
> > > > sounds like two birds in one shot, I think.
> > >
> > > OK, I'll flesh it out a bit more and see if I can actually get
> > > something working (and working with hugepages too).
> >
> > This is just a really quick hack, untested ATM, but one that
> > has at least a chance of working (on x86).
>
> When we fall back to slow mode, we should decrement the ref counts
> on the pages we got so far in the fast mode.

Here is something that is actually tested and works (not
tested with hugepages yet, though).

However it's not 100% secure at the moment. It's actually
not completely trivial; I think we need to use an extra bit
in the present pte in order to exclude "not normal" pages,
if we want fast_gup to work on small page mappings too. I
think this would be possible to do on most architectures, but
I haven't done it here obviously.

Still, it should be enough to test the design. I've added
fast_gup and fast_gup_slow to /proc/vmstat, which count the
number of times fast_gup was called, and the number of times
it dropped into the slowpath. It would be interesting to know
how it performs compared to your granular hugepage ptl...

--Boundary-00=_nw1EH1QlB02vnxv
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="mm-get_user_pages-fast.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="mm-get_user_pages-fast.patch"

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


---
Index: linux-2.6/arch/x86/lib/Makefile_64
===================================================================
--- linux-2.6.orig/arch/x86/lib/Makefile_64
+++ linux-2.6/arch/x86/lib/Makefile_64
@@ -10,4 +10,4 @@ obj-$(CONFIG_SMP)	+= msr-on-cpu.o
 lib-y := csum-partial_64.o csum-copy_64.o csum-wrappers_64.o delay_64.o \
 	usercopy_64.o getuser_64.o putuser_64.o  \
 	thunk_64.o clear_page_64.o copy_page_64.o bitstr_64.o bitops_64.o
-lib-y += memcpy_64.o memmove_64.o memset_64.o copy_user_64.o rwlock_64.o copy_user_nocache_64.o
+lib-y += memcpy_64.o memmove_64.o memset_64.o copy_user_64.o rwlock_64.o copy_user_nocache_64.o gup.o
Index: linux-2.6/arch/x86/lib/gup.c
===================================================================
--- /dev/null
+++ linux-2.6/arch/x86/lib/gup.c
@@ -0,0 +1,168 @@
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
+static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end, int write, struct page **pages, int *nr)
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
+		if ((pte_val(pte) & (_PAGE_PRESENT|_PAGE_USER)) != (_PAGE_PRESENT|_PAGE_USER))
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
+static int gup_huge_pmd(pmd_t pmd, unsigned long addr, unsigned long end, int write, struct page **pages, int *nr)
+{
+	pte_t pte = *(pte_t *)&pmd;
+	struct page *page;
+
+	if ((pte_val(pte) & _PAGE_USER) != _PAGE_USER)
+		return 0;
+
+	BUG_ON(!pfn_valid(pte_pfn(pte)));
+
+	if (write && !pte_write(pte))
+		return 0;
+
+	page = pte_page(pte);
+	do {
+		unsigned long pfn_offset;
+		struct page *p;
+
+		pfn_offset = (addr & ~HPAGE_MASK) >> PAGE_SHIFT;
+		p = page + pfn_offset;
+		get_page(page);
+		pages[*nr] = page;
+		(*nr)++;
+
+	} while (addr += PAGE_SIZE, addr != end);
+
+	return 1;
+}
+
+static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end, int write, struct page **pages, int *nr)
+{
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
Index: linux-2.6/include/asm-x86/uaccess_64.h
===================================================================
--- linux-2.6.orig/include/asm-x86/uaccess_64.h
+++ linux-2.6/include/asm-x86/uaccess_64.h
@@ -381,4 +381,7 @@ static inline int __copy_from_user_inato
 	return __copy_user_nocache(dst, src, size, 0);
 }
 
+struct page;
+int fast_gup(unsigned long start, int nr_pages, int write, struct page **pages);
+
 #endif /* __X86_64_UACCESS_H */
Index: linux-2.6/fs/bio.c
===================================================================
--- linux-2.6.orig/fs/bio.c
+++ linux-2.6/fs/bio.c
@@ -646,12 +646,7 @@ static struct bio *__bio_map_user_iov(st
 		const int local_nr_pages = end - start;
 		const int page_limit = cur_page + local_nr_pages;
 		
-		down_read(&current->mm->mmap_sem);
-		ret = get_user_pages(current, current->mm, uaddr,
-				     local_nr_pages,
-				     write_to_vm, 0, &pages[cur_page], NULL);
-		up_read(&current->mm->mmap_sem);
-
+		ret = fast_gup(uaddr, local_nr_pages, write_to_vm, &pages[cur_page]);
 		if (ret < local_nr_pages) {
 			ret = -EFAULT;
 			goto out_unmap;
Index: linux-2.6/fs/block_dev.c
===================================================================
--- linux-2.6.orig/fs/block_dev.c
+++ linux-2.6/fs/block_dev.c
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
 		struct page *page = ZERO_PAGE(dio->curr_user_address);
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
@@ -1224,33 +1224,6 @@ static long do_splice(struct file *in, l
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
@@ -1263,8 +1236,6 @@ static int get_iovec_page_array(const st
 {
 	int buffers = 0, error = 0;
 
-	down_read(&current->mm->mmap_sem);
-
 	while (nr_vecs) {
 		unsigned long off, npages;
 		struct iovec entry;
@@ -1273,7 +1244,7 @@ static int get_iovec_page_array(const st
 		int i;
 
 		error = -EFAULT;
-		if (copy_from_user_mmap_sem(&entry, iov, sizeof(entry)))
+		if (copy_from_user(&entry, iov, sizeof(entry)))
 			break;
 
 		base = entry.iov_base;
@@ -1307,9 +1278,7 @@ static int get_iovec_page_array(const st
 		if (npages > PIPE_BUFFERS - buffers)
 			npages = PIPE_BUFFERS - buffers;
 
-		error = get_user_pages(current, current->mm,
-				       (unsigned long) base, npages, 0, 0,
-				       &pages[buffers], NULL);
+		error = fast_gup((unsigned long)base, npages, 0, &pages[buffers]);
 
 		if (unlikely(error <= 0))
 			break;
@@ -1348,8 +1317,6 @@ static int get_iovec_page_array(const st
 		iov++;
 	}
 
-	up_read(&current->mm->mmap_sem);
-
 	if (buffers)
 		return buffers;
 

--Boundary-00=_nw1EH1QlB02vnxv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
