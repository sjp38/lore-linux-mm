Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 216636B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 12:59:07 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so17036370pab.12
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 09:59:06 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id bf5si19091939pad.1.2014.02.18.09.59.05
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 09:59:06 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CA+55aFwz+36NOk=uanDvii7zn46-s1kpMT1Lt=C0hhhn9v6w-Q@mail.gmail.com>
References: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CA+55aFwz+36NOk=uanDvii7zn46-s1kpMT1Lt=C0hhhn9v6w-Q@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 0/2] mm: map few pages around fault address if they
 are in page cache
Content-Transfer-Encoding: 7bit
Message-Id: <20140218175900.8CF90E0090@blue.fi.intel.com>
Date: Tue, 18 Feb 2014 19:59:00 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Linus Torvalds wrote:
> On Mon, Feb 17, 2014 at 10:38 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >
> > Now we have ->fault_nonblock() to ask filesystem for a page, if it's
> > reachable without blocking. We request one page a time. It's not terribly
> > efficient and I will probably re-think the interface once again to expose
> > iterator or something...
> 
> Hmm. Yeah, clearly this isn't working, since the real workloads all
> end up looking like
> 
> >        115,493,976      minor-faults                                                  ( +-  0.00% ) [100.00%]
> >       59.686645587 seconds time elapsed                                          ( +-  0.30% )
>  becomes
> >         47,428,068      minor-faults                                                  ( +-  0.00% ) [100.00%]
> >       60.241766430 seconds time elapsed                                          ( +-  0.85% )
> 
> and
> 
> >        268,039,365      minor-faults                                                 [100.00%]
> >      132.830612471 seconds time elapsed
> becomes
> >        193,550,437      minor-faults                                                 [100.00%]
> >      132.851823758 seconds time elapsed
> 
> and
> 
> >          4,967,540      minor-faults                                                  ( +-  0.06% ) [100.00%]
> >       27.215434226 seconds time elapsed                                          ( +-  0.18% )
> becomes
> >          2,285,563      minor-faults                                                  ( +-  0.26% ) [100.00%]
> >       27.292854546 seconds time elapsed                                          ( +-  0.29% )
> 
> ie it shows a clear reduction in faults, but the added costs clearly
> eat up any wins and it all becomes (just _slightly_) slower.

I did an experement with setup pte directly in filemap_fault_nonblock() to
see how much we can get from it. And it helps:

git:		-1.21s
clean build:	-2.22s
rebuild:	-0.63s

Is it a layering violation to setup pte directly in ->fault_nonblock()?

perf stat and patch below.

Git test-suite make -j60 test:
 1,591,184,058,944      cycles                     ( +-  0.05% ) [100.00%]
   811,200,260,823      instructions              #    0.51  insns per cycle
                                                  #    3.24  stalled cycles per insn  ( +-  0.19% ) [100.00%]
 2,631,511,271,429      stalled-cycles-frontend   #  165.38% frontend cycles idle     ( +-  0.08% )
        47,305,697      minor-faults                                                  ( +-  0.00% ) [100.00%]
                 1      major-faults

      59.028360009 seconds time elapsed                                          ( +-  0.58% )

Run make -j60 on clean allmodconfig kernel tree:
19,163,958,689,310      cycles                    [100.00%]
17,446,888,861,177      instructions              #    0.91  insns per cycle
                                                  #    1.53  stalled cycles per insn [100.00%]
26,777,884,033,091      stalled-cycles-frontend   #  139.73% frontend cycles idle
       193,118,569      minor-faults                                                 [100.00%]
                 0      major-faults

     130.631767214 seconds time elapsed

Run make -j60 on already built allmodconfig kernel tree:
   282,398,537,719      cycles                     ( +-  0.03% ) [100.00%]
   385,807,937,931      instructions              #    1.37  insns per cycle
                                                  #    0.95  stalled cycles per insn  ( +-  0.01% ) [100.00%]
   365,940,576,310      stalled-cycles-frontend   #  129.58% frontend cycles idle     ( +-  0.07% )
         2,254,887      minor-faults                                                  ( +-  0.02% ) [100.00%]
                 0      major-faults

      26.660708754 seconds time elapsed                                          ( +-  0.29% )

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b9a688dbd62a..e671dd5abe27 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -221,8 +221,8 @@ struct vm_operations_struct {
 	void (*open)(struct vm_area_struct * area);
 	void (*close)(struct vm_area_struct * area);
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
-	void (*fault_nonblock)(struct vm_area_struct *vma,
-			struct vm_fault *vmf);
+	int (*fault_nonblock)(struct vm_area_struct *vma, struct vm_fault *vmf,
+		pgoff_t max_pgoff, int nr_pages, pte_t *pte);
 
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
@@ -1812,7 +1812,8 @@ extern void truncate_inode_pages_range(struct address_space *,
 
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
-extern void filemap_fault_nonblock(struct vm_area_struct *, struct vm_fault *);
+int filemap_fault_nonblock(struct vm_area_struct *vma, struct vm_fault *vmf,
+		pgoff_t max_pgoff, int nr_pages, pte_t *pte);
 extern int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
 
 /* mm/page-writeback.c */
diff --git a/mm/filemap.c b/mm/filemap.c
index 7b7c9c600544..0a8884efbcd8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -33,6 +33,7 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/cleancache.h>
+#include <linux/rmap.h>
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -134,6 +135,9 @@ void __delete_from_page_cache(struct page *page)
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	if (PageSwapBacked(page))
 		__dec_zone_page_state(page, NR_SHMEM);
+	if (page_mapped(page)) {
+		dump_page(page, "");
+	}
 	BUG_ON(page_mapped(page));
 
 	/*
@@ -1726,37 +1730,90 @@ page_not_uptodate:
 }
 EXPORT_SYMBOL(filemap_fault);
 
-void filemap_fault_nonblock(struct vm_area_struct *vma, struct vm_fault *vmf)
+void do_set_pte(struct vm_area_struct *vma, unsigned long address,
+		struct page *page, pte_t *pte, bool write, bool anon);
+int filemap_fault_nonblock(struct vm_area_struct *vma, struct vm_fault *vmf,
+		pgoff_t max_pgoff, int nr_pages, pte_t *pte)
 {
+	struct radix_tree_iter iter;
+	void **slot;
 	struct file *file = vma->vm_file;
 	struct address_space *mapping = file->f_mapping;
 	pgoff_t size;
 	struct page *page;
+	unsigned long address = (unsigned long) vmf->virtual_address;
+	unsigned long addr;
+	pte_t *_pte;
+	int ret = 0;
 
-	page = find_get_page(mapping, vmf->pgoff);
-	if (!page)
-		return;
-	if (PageReadahead(page) || PageHWPoison(page))
-		goto put;
-	if (!trylock_page(page))
-		goto put;
-	/* Truncated? */
-	if (unlikely(page->mapping != mapping))
-		goto unlock;
-	if (unlikely(!PageUptodate(page)))
-		goto unlock;
-	size = (i_size_read(mapping->host) + PAGE_CACHE_SIZE - 1)
-		>> PAGE_CACHE_SHIFT;
-	if (unlikely(page->index >= size))
-		goto unlock;
-	if (file->f_ra.mmap_miss > 0)
-		file->f_ra.mmap_miss--;
-	vmf->page = page;
-	return;
+	rcu_read_lock();
+restart:
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, vmf->pgoff) {
+repeat:
+		page = radix_tree_deref_slot(slot);
+
+		if (radix_tree_exception(page)) {
+			if (radix_tree_deref_retry(page)) {
+				/*
+				 * Transient condition which can only trigger
+				 * when entry at index 0 moves out of or back
+				 * to root: none yet gotten, safe to restart.
+				 */
+				WARN_ON(iter.index);
+				goto restart;
+			}
+			/*
+			 * Otherwise, shmem/tmpfs must be storing a swap entry
+			 * here as an exceptional entry: so skip over it -
+			 * we only reach this from invalidate_mapping_pages().
+			 */
+			continue;
+		}
+
+		if (!page_cache_get_speculative(page))
+			goto repeat;
+
+		/* Has the page moved? */
+		if (unlikely(page != *slot)) {
+			page_cache_release(page);
+			goto repeat;
+		}
+
+		if (page->index > max_pgoff) {
+			page_cache_release(page);
+			break;
+		}
+
+		if (PageReadahead(page) || PageHWPoison(page) ||
+				!PageUptodate(page))
+			goto skip;
+		if (!trylock_page(page))
+			goto skip;
+		if (page->mapping != mapping || !PageUptodate(page))
+			goto unlock;
+		size = (i_size_read(mapping->host) + PAGE_CACHE_SIZE - 1)
+			>> PAGE_CACHE_SHIFT;
+		if (page->index >= size)
+			goto unlock;
+		if (file->f_ra.mmap_miss > 0)
+			file->f_ra.mmap_miss--;
+		addr = address + (page->index - vmf->pgoff) * PAGE_SIZE;
+		_pte = pte + page->index - vmf->pgoff;
+		if (!pte_none(*_pte))
+			goto unlock;
+		do_set_pte(vma, addr, page, _pte, false, false);
+
+		unlock_page(page);
+		if (++ret == nr_pages || page->index == max_pgoff)
+			break;
+		continue;
 unlock:
-	unlock_page(page);
-put:
-	put_page(page);
+		unlock_page(page);
+skip:
+		page_cache_release(page);
+	}
+	rcu_read_unlock();
+	return ret;
 }
 EXPORT_SYMBOL(filemap_fault_nonblock);
 
diff --git a/mm/memory.c b/mm/memory.c
index f4990fb66770..1af0e3a3f0f1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3318,7 +3318,8 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	return ret;
 }
 
-static void do_set_pte(struct vm_area_struct *vma, unsigned long address,
+
+void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 		struct page *page, pte_t *pte, bool write, bool anon)
 {
 	pte_t entry;
@@ -3342,37 +3343,47 @@ static void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	update_mmu_cache(vma, address, pte);
 }
 
-#define FAULT_AROUND_ORDER 5
+#define FAULT_AROUND_ORDER 3
 #define FAULT_AROUND_PAGES (1UL << FAULT_AROUND_ORDER)
 #define FAULT_AROUND_MASK ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1)
 
 static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
 		pte_t *pte, pgoff_t pgoff, unsigned int flags)
 {
+	unsigned long start_addr;
+	pgoff_t max_pgoff;
 	struct vm_fault vmf;
-	unsigned long start_addr = address & FAULT_AROUND_MASK;
-	int off = (address - start_addr) >> PAGE_SHIFT;
-	int i;
-
-	for (i = 0; i < FAULT_AROUND_PAGES; i++) {
-		unsigned long addr = start_addr + i * PAGE_SIZE;
-		pte_t *_pte = pte - off +i;
+	int off, ret;
 
-		if (!pte_none(*_pte))
-			continue;
-		if (addr < vma->vm_start || addr >= vma->vm_end)
-			continue;
+	/* Do not cross vma or page table border */
+	max_pgoff = min(pgoff - pte_index(address) + PTRS_PER_PTE - 1,
+			vma_pages(vma) + vma->vm_pgoff - 1);
 
-		vmf.virtual_address = (void __user *) addr;
-		vmf.pgoff = pgoff - off + i;
-		vmf.flags = flags;
-		vmf.page = NULL;
-		vma->vm_ops->fault_nonblock(vma, &vmf);
-		if (!vmf.page)
-			continue;
-		do_set_pte(vma, addr, vmf.page, _pte, false, false);
-		unlock_page(vmf.page);
+	start_addr = max(address & FAULT_AROUND_MASK, vma->vm_start);
+	if ((start_addr & PMD_MASK) != (address & PMD_MASK))
+		BUG();
+	off = pte_index(start_addr) - pte_index(address);
+	pte += off;
+	pgoff += off;
+
+	/* Check if it makes any sense to call ->fault_nonblock */
+	while (!pte_none(*pte)) {
+		pte++;
+		pgoff++;
+		start_addr += PAGE_SIZE;
+		/* Do not cross vma or page table border */
+		if (!pte_index(start_addr) || start_addr >= vma->vm_end)
+			return;
+		if ((start_addr & PMD_MASK) != (address & PMD_MASK))
+			BUG();
 	}
+
+
+	vmf.virtual_address = (void __user *) start_addr;
+	vmf.pgoff = pgoff;
+	vmf.flags = flags;
+	ret = vma->vm_ops->fault_nonblock(vma, &vmf,
+			max_pgoff, FAULT_AROUND_PAGES, pte);
 }
 
 static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
