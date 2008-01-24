From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
Date: Thu, 24 Jan 2008 18:06:52 +1100
References: <20071008225234.GC27824@linux-os.sc.intel.com> <200712121640.17077.nickpiggin@yahoo.com.au> <1200513482.6935.15.camel@norville.austin.ibm.com>
In-Reply-To: <1200513482.6935.15.camel@norville.austin.ibm.com>
MIME-Version: 1.0
Message-Id: <200801241806.52370.nickpiggin@yahoo.com.au>
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_MkDmHeKePKgmSXh"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Ken Chen <kenchen@google.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com, Adam Litke <agl@us.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--Boundary-00=_MkDmHeKePKgmSXh
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday 17 January 2008 06:58, Dave Kleikamp wrote:

> We weren't able to get in any runs before the holidays, but we finally
> have some good news from our performance team:
>
> "To test the effects of the patch, an OLTP workload was run on an IBM
> x3850 M2 server with 2 processors (quad-core Intel Xeon processors at
> 2.93 GHz) using IBM DB2 v9.5 running Linux 2.6.24rc7 kernel. Comparing
> runs with and without the patch resulted in an overall performance
> benefit of ~9.8%. Correspondingly, oprofiles showed that samples from
> __up_read and __down_read routines that is seen during thread contention
> for system resources was reduced from 2.8% down to .05%. Monitoring
> the /proc/vmstat output from the patched run showed that the counter for
> fast_gup contained a very high number while the fast_gup_slow value was
> zero."

Just for reference, I've attached a more complete patch for x86,
which has to be applied on top of the pte_special patch posted in
another thread.

No need to test anything at this point... the generated code for
this version is actually slightly better than the last one despite
the extra condition being tested for. With a few tweak I was
actually able to reduce the number of tests in the inner loop, and
adding noinline to the leaf functions helps keep them in registers.

I'm currently having a look at an initial powerpc 64 patch,
hopefully we'll see similar improvements there. Will post that when
I get further along with it.

Thanks,
Nick

--Boundary-00=_MkDmHeKePKgmSXh
Content-Type: text/x-diff;
  charset="utf-8";
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
@@ -0,0 +1,189 @@
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
+static noinline int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end, int write, struct page **pages, int *nr)
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
+static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr, unsigned long end, int write, struct page **pages, int *nr)
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
+	/*
+	 * XXX: batch / limit 'nr', to avoid huge latency
+	 * needs some instrumenting to determine the common sizes used by
+	 * important workloads (eg. DB2), and whether limiting the batch size
+	 * will decrease performance.
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
Index: linux-2.6/include/asm-x86/uaccess_64.h
===================================================================
--- linux-2.6.orig/include/asm-x86/uaccess_64.h
+++ linux-2.6/include/asm-x86/uaccess_64.h
@@ -381,4 +381,8 @@ static inline int __copy_from_user_inato
 	return __copy_user_nocache(dst, src, size, 0);
 }
 
+#define __HAVE_ARCH_FAST_GUP
+struct page;
+int fast_gup(unsigned long start, int nr_pages, int write, struct page **pages);
+
 #endif /* __X86_64_UACCESS_H */
Index: linux-2.6/fs/bio.c
===================================================================
--- linux-2.6.orig/fs/bio.c
+++ linux-2.6/fs/bio.c
@@ -637,12 +637,7 @@ static struct bio *__bio_map_user_iov(st
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
 		struct page *page = ZERO_PAGE(0);
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
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
@@ -1257,9 +1228,7 @@ static int get_iovec_page_array(const st
 		if (npages > PIPE_BUFFERS - buffers)
 			npages = PIPE_BUFFERS - buffers;
 
-		error = get_user_pages(current, current->mm,
-				       (unsigned long) base, npages, 0, 0,
-				       &pages[buffers], NULL);
+		error = fast_gup((unsigned long)base, npages, 0, &pages[buffers]);
 
 		if (unlikely(error <= 0))
 			break;
@@ -1298,8 +1267,6 @@ static int get_iovec_page_array(const st
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
@@ -13,6 +13,7 @@
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
 #include <linux/security.h>
+#include <linux/uaccess.h> /* for __HAVE_ARCH_FAST_GUP */
 
 struct mempolicy;
 struct anon_vma;
@@ -767,6 +768,24 @@ extern int mprotect_fixup(struct vm_area
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

--Boundary-00=_MkDmHeKePKgmSXh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
