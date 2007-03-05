Date: Mon, 5 Mar 2007 17:17:46 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 2/2] mm: mlocked pages off LRU
Message-ID: <20070305161746.GD8128@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

This is a competing implementation of the mlocked stuff that has been going
on, because I don't really like those patches and I found that it went
beyond just simple coding style issues.

While I think this patchset is functionally more capable (for the reasons
listed below), I don't really care about that aspect so much as the
cleanliness of the implementation, which I think is better in mine.

This is against 2.6.21-rc2 + my nopage vs invalidate patches, because
they actually fix real bugs, some of which affect this mlock patch. I can
repost those if anyone wants.

This is not heavily tested at thist stage. A very slightly older patch
boots and runs here, but I'm posting this now to ask for comments.

Nick
--

Remove mlocked pages from the LRU. Use PageMLocked page flag, and when that
is set, page->lru.next becomes the mlock_count (conservative count of VM_LOCKED
vmas that reference this page). Based on idea from Christoph Hellwig.

This patch has a number of advantages over Christoph Lameter's scheme.
- munlock doesn't put pages back onto LRU lists if they are still mlocked
- PageMLock explicitly elevates the page's refcount, so PageMLock pages
  don't ever get freed (thus requires less awareness in the rest of mm).

Since I change a few things in install_arg_page, I'll finally move it to
mm/memory.c where it belongs, and rename it to install_new_anon_page.

 fs/exec.c                  |   52 ++-----------
 include/linux/mm.h         |    2 
 include/linux/page-flags.h |    5 +
 include/linux/rmap.h       |    1 
 mm/internal.h              |   32 ++++++++
 mm/memory.c                |   63 +++++++++++++++
 mm/mlock.c                 |  180 ++++++++++++++++++++++++++++++++++++++++++---
 mm/mmap.c                  |    6 +
 mm/mremap.c                |    8 +-
 mm/page_alloc.c            |    9 +-
 mm/rmap.c                  |   57 +++++++++-----
 mm/vmscan.c                |    5 +
 12 files changed, 339 insertions(+), 81 deletions(-)

Index: linux-2.6/mm/mlock.c
===================================================================
--- linux-2.6.orig/mm/mlock.c
+++ linux-2.6/mm/mlock.c
@@ -8,16 +8,199 @@
 #include <linux/capability.h>
 #include <linux/mman.h>
 #include <linux/mm.h>
+#include <linux/swap.h>
+#include <linux/pagemap.h>
 #include <linux/mempolicy.h>
 #include <linux/syscalls.h>
 
+#include "internal.h"
+
+#define page_mlock_count(page)		(*(unsigned long *)&(page)->lru.next)
+#define set_page_mlock_count(page, v)	(page_mlock_count(page) = (v))
+#define inc_page_mlock_count(page)	(page_mlock_count(page)++)
+#define dec_page_mlock_count(page)	(page_mlock_count(page)--)
+
+/*
+ * A page's mlock_count is kept in page->lru.next as an unsigned long.
+ * Access to this count is serialised with the page lock (or, in the
+ * case of mlock_page, virtue that there are no other references to
+ * the page).
+ *
+ * mlock counts are incremented at mlock, mmap, mremap, and new anon page
+ * faults, and lazily via vmscan. Decremented at munlock, munmap, and exit.
+ * mlock is not inherited across fork or exec, so we're safe there.
+ *
+ * If PageMLock is set, then the page is removed from the LRU list, and
+ * has its refcount incremented. This increment prevents the page from being
+ * freed until the mlock_count is decremented to zero and PageMLock is cleared.
+ */
+
+/*
+ * Marks a page, belonging to the given mlocked vma, as mlocked.
+ *
+ * The page must be either locked or new, and must not be on the LRU.
+ */
+void set_page_mlock(struct page *page, unsigned long count)
+{
+	BUG_ON(PageLRU(page));
+	BUG_ON(PageMLock(page));
+	/* BUG_ON(!list_empty(&page->lru)); -- if we always did list_del_init */
+
+	SetPageMLock(page);
+	get_page(page);
+	set_page_mlock_count(page, count);
+}
+
+static void __clear_page_mlock(struct page *page)
+{
+	BUG_ON(!PageMLock(page));
+	BUG_ON(PageLRU(page));
+	BUG_ON(page_mlock_count(page));
+
+	ClearPageMLock(page);
+
+	/*
+	 * Could just do a put_page here, however this special
+	 * case prevents anonymous mlocked pages from being put
+	 * on the LRU, then removed from the LRU when we
+	 * put_page.
+	 *
+	 * It is a little bit naughty to open-code this here.
+	 */
+	if (put_page_testzero(page))
+		free_hot_page(page);
+	else
+		lru_cache_add_active(page);
+}
+
+/*
+ * Zero the page's mlock_count. This can be useful in a situation where
+ * we want to unconditionally remove a page from the pagecache.
+ *
+ * It is not illegal to call this function for any page, mlocked or not.
+ * If called for a page that is still mapped by mlocked vmas, all we do
+ * is revert to lazy LRU behaviour -- semantics are not broken.
+ */
+void clear_page_mlock(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+
+	if (likely(!PageMLock(page)))
+		return;
+	BUG_ON(!page_mlock_count(page));
+	set_page_mlock_count(page, 0);
+	__clear_page_mlock(page);
+}
+
+static void inc_page_mlock(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+
+	if (!PageMLock(page)) {
+		if (!isolate_lru_page(page)) {
+			SetPageMLock(page);
+			get_page(page);
+			set_page_mlock_count(page, 1);
+		}
+	} else if (PageMLock(page)) {
+		BUG_ON(!page_mlock_count(page));
+		inc_page_mlock_count(page);
+	}
+}
+
+static void dec_page_mlock(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+
+	if (PageMLock(page)) {
+		BUG_ON(!page_mlock_count(page));
+		dec_page_mlock_count(page);
+		if (page_mlock_count(page) == 0)
+			__clear_page_mlock(page);
+	} /* else page was not able to be removed from the lru when mlocked */
+}
+
+/*
+ * Increment or decrement the mlock count for a range of pages in the vma
+ * depending on whether lock is 1 or 0, respectively.
+ *
+ * This takes care of making the pages present too.
+ *
+ * vma->vm_mm->mmap_sem must be held for read or write.
+ */
+void __mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end, int lock)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long addr = start;
+	struct page *pages[16]; /* 16 gives a reasonable batch */
+	int write = !!(vma->vm_flags & VM_WRITE);
+	int nr_pages;
+
+	BUG_ON(start & ~PAGE_MASK || end & ~PAGE_MASK);
+
+	if (vma->vm_flags & VM_IO)
+		return;
+
+	nr_pages = (end - start) >> PAGE_SHIFT;
+
+	while (nr_pages > 0) {
+		int ret, i;
+
+		cond_resched();
+
+		/*
+		 * get_user_pages makes pages present if we are
+		 * setting mlock.
+		 */
+		ret = get_user_pages(current, mm, addr, nr_pages,
+				write, 0, pages, NULL);
+		if (ret < 0)
+			break;
+		if (ret == 0) {
+			/*
+			 * We know the vma is there, so the only time
+			 * we cannot get a single page should be an
+			 * error (ret < 0) case.
+			 */
+			WARN_ON(1);
+			ret = -EFAULT;
+			break;
+		}
+
+		for (i = 0; i < ret; i++) {
+			struct page *page = pages[i];
+			lock_page(page);
+			if (lock) {
+				/*
+				 * Anonymous pages may have already been
+				 * mlocked by get_user_pages->handle_mm_fault.
+				 * Be conservative and don't count these:
+				 * We can underestimate the mlock_count because
+				 * that will just cause the page to be added
+				 * to the lru then lazily removed again.
+				 * However if we overestimate the count, the
+				 * page will become unfreeable.
+				 */
+				if (vma->vm_file || !PageMLock(page))
+					inc_page_mlock(page);
+			} else
+				dec_page_mlock(page);
+			unlock_page(page);
+			put_page(page);
+
+			addr += PAGE_SIZE;
+			nr_pages--;
+		}
+	}
+}
 
 static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	unsigned long start, unsigned long end, unsigned int newflags)
 {
-	struct mm_struct * mm = vma->vm_mm;
+	struct mm_struct *mm = vma->vm_mm;
 	pgoff_t pgoff;
-	int pages;
+	int nr_pages;
 	int ret = 0;
 
 	if (newflags == vma->vm_flags) {
@@ -51,21 +234,21 @@ success:
 	/*
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 * It's okay if try_to_unmap_one unmaps a page just after we
-	 * set VM_LOCKED, make_pages_present below will bring it back.
+	 * set VM_LOCKED, get_user_pages below will bring it back.
 	 */
 	vma->vm_flags = newflags;
 
 	/*
 	 * Keep track of amount of locked VM.
 	 */
-	pages = (end - start) >> PAGE_SHIFT;
-	if (newflags & VM_LOCKED) {
-		pages = -pages;
-		if (!(newflags & VM_IO))
-			ret = make_pages_present(start, end);
-	}
+	nr_pages = (end - start) >> PAGE_SHIFT;
+	if (newflags & VM_LOCKED)
+		nr_pages = -nr_pages;
+	mm->locked_vm -= nr_pages;
+
+	/* Mlock or unlock all pages in range, including anon pages */
+	__mlock_vma_pages_range(vma, start, end, !!(newflags & VM_LOCKED));
 
-	mm->locked_vm -= pages;
 out:
 	if (ret == -ENOMEM)
 		ret = -EAGAIN;
Index: linux-2.6/mm/internal.h
===================================================================
--- linux-2.6.orig/mm/internal.h
+++ linux-2.6/mm/internal.h
@@ -36,6 +36,36 @@ static inline void __put_page(struct pag
 
 extern int isolate_lru_page(struct page *page);
 
+extern void set_page_mlock(struct page *page, unsigned long count);
+extern void clear_page_mlock(struct page *page);
+
+static inline void mlock_new_page(struct page *page)
+{
+	set_page_mlock(page, 1);
+}
+
+extern void __mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end, int lock);
+
+/*
+ * mlock all pages in this vma range.
+ */
+static inline void mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+	__mlock_vma_pages_range(vma, start, end, 1);
+}
+
+/*
+ * munlock pages.
+ */
+static inline void munlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+	__mlock_vma_pages_range(vma, start, end, 0);
+}
+
+
 extern void fastcall __init __free_pages_bootmem(struct page *page,
 						unsigned int order);
 
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -51,6 +51,8 @@
 
 #include <asm/tlbflush.h>
 
+#include "internal.h"
+
 struct kmem_cache *anon_vma_cachep;
 
 static inline void validate_anon_vma(struct vm_area_struct *find_vma)
@@ -301,6 +303,13 @@ static int page_referenced_one(struct pa
 	if (!pte)
 		goto out;
 
+	/*
+	 * Don't want to elevate mlocked refcount, in order that it
+	 * progresses to try_to_unmap and is removed from the LRU
+	 */
+	if (vma->vm_flags & VM_LOCKED)
+		goto out_unmap;
+
 	if (ptep_clear_flush_young(vma, address, pte))
 		referenced++;
 
@@ -310,6 +319,7 @@ static int page_referenced_one(struct pa
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced++;
 
+out_unmap:
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
 out:
@@ -381,11 +391,6 @@ static int page_referenced_file(struct p
 	mapcount = page_mapcount(page);
 
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
-		if ((vma->vm_flags & (VM_LOCKED|VM_MAYSHARE))
-				  == (VM_LOCKED|VM_MAYSHARE)) {
-			referenced++;
-			break;
-		}
 		referenced += page_referenced_one(page, vma, &mapcount);
 		if (!mapcount)
 			break;
@@ -631,10 +636,15 @@ static int try_to_unmap_one(struct page 
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
 	 */
-	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young(vma, address, pte)))) {
-		ret = SWAP_FAIL;
-		goto out_unmap;
+	if (!migration) {
+		if (vma->vm_flags & VM_LOCKED) {
+			ret = SWAP_MLOCK;
+			goto out_unmap;
+		}
+		if (ptep_clear_flush_young(vma, address, pte)) {
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
 	}
 
 	/* Nuke the page table entry. */
@@ -716,6 +726,9 @@ out:
  * For very sparsely populated VMAs this is a little inefficient - chances are
  * there there won't be many ptes located within the scan cluster.  In this case
  * maybe we could scan further - to the end of the pte page, perhaps.
+ *
+ * Mlocked pages also aren't handled very well at the moment: they aren't
+ * moved off the LRU like they are for linear pages.
  */
 #define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
 #define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
@@ -787,7 +800,8 @@ static void try_to_unmap_cluster(unsigne
 	pte_unmap_unlock(pte - 1, ptl);
 }
 
-static int try_to_unmap_anon(struct page *page, int migration)
+static int try_to_unmap_anon(struct page *page, int migration,
+						unsigned int *mlocked)
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
@@ -801,6 +815,8 @@ static int try_to_unmap_anon(struct page
 		ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
 			break;
+		if (ret == SWAP_MLOCK)
+			(*mlocked)++;
 	}
 	spin_unlock(&anon_vma->lock);
 	return ret;
@@ -815,7 +831,8 @@ static int try_to_unmap_anon(struct page
  *
  * This function is only called from try_to_unmap for object-based pages.
  */
-static int try_to_unmap_file(struct page *page, int migration)
+static int try_to_unmap_file(struct page *page, int migration,
+						unsigned int *mlocked)
 {
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -832,6 +849,8 @@ static int try_to_unmap_file(struct page
 		ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
 			goto out;
+		if (ret == SWAP_MLOCK)
+			(*mlocked)++;
 	}
 
 	if (list_empty(&mapping->i_mmap_nonlinear))
@@ -839,7 +858,7 @@ static int try_to_unmap_file(struct page
 
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-		if ((vma->vm_flags & VM_LOCKED) && !migration)
+		if (!migration && (vma->vm_flags & VM_LOCKED))
 			continue;
 		cursor = (unsigned long) vma->vm_private_data;
 		if (cursor > max_nl_cursor)
@@ -873,8 +892,6 @@ static int try_to_unmap_file(struct page
 	do {
 		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-			if ((vma->vm_flags & VM_LOCKED) && !migration)
-				continue;
 			cursor = (unsigned long) vma->vm_private_data;
 			while ( cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
@@ -917,15 +934,19 @@ out:
 int try_to_unmap(struct page *page, int migration)
 {
 	int ret;
+	unsigned int mlocked = 0;
 
 	BUG_ON(!PageLocked(page));
 
 	if (PageAnon(page))
-		ret = try_to_unmap_anon(page, migration);
+		ret = try_to_unmap_anon(page, migration, &mlocked);
 	else
-		ret = try_to_unmap_file(page, migration);
-
-	if (!page_mapped(page))
+		ret = try_to_unmap_file(page, migration, &mlocked);
+	if (mlocked) {
+		/* Lazily move the page off the LRU list */
+		set_page_mlock(page, mlocked);
+		ret = SWAP_MLOCK;
+	} else if (!page_mapped(page))
 		ret = SWAP_SUCCESS;
 	return ret;
 }
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -30,6 +30,8 @@
 #include <asm/cacheflush.h>
 #include <asm/tlb.h>
 
+#include "internal.h"
+
 #ifndef arch_mmap_check
 #define arch_mmap_check(addr, len, flags)	(0)
 #endif
@@ -1145,7 +1147,7 @@ out:	
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		mlock_vma_pages_range(vma, addr, addr + len);
 	}
 	if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
 		make_pages_present(addr, addr + len);
@@ -1958,7 +1960,7 @@ out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		mlock_vma_pages_range(vma, addr, addr + len);
 	}
 	return addr;
 }
Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c
+++ linux-2.6/mm/mremap.c
@@ -23,6 +23,8 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
+#include "internal.h"
+
 static pmd_t *get_old_pmd(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
@@ -232,8 +234,8 @@ static unsigned long move_vma(struct vm_
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += new_len >> PAGE_SHIFT;
 		if (new_len > old_len)
-			make_pages_present(new_addr + old_len,
-					   new_addr + new_len);
+			mlock_vma_pages_range(vma, new_addr + old_len,
+						   new_addr + new_len);
 	}
 
 	return new_addr;
@@ -369,7 +371,7 @@ unsigned long do_mremap(unsigned long ad
 			vm_stat_account(mm, vma->vm_flags, vma->vm_file, pages);
 			if (vma->vm_flags & VM_LOCKED) {
 				mm->locked_vm += pages;
-				make_pages_present(addr + old_len,
+				mlock_vma_pages_range(vma, addr + old_len,
 						   addr + new_len);
 			}
 			ret = addr;
Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h
+++ linux-2.6/include/linux/rmap.h
@@ -134,5 +134,6 @@ static inline int page_mkclean(struct pa
 #define SWAP_SUCCESS	0
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
+#define SWAP_MLOCK	3
 
 #endif	/* _LINUX_RMAP_H */
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -60,6 +60,8 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 
+#include "internal.h"
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
@@ -855,6 +857,9 @@ unsigned long unmap_vmas(struct mmu_gath
 
 			tlb_finish_mmu(*tlbp, tlb_start, start);
 
+			if (vma->vm_flags & VM_LOCKED)
+				munlock_vma_pages_range(vma, start, end);
+
 			if (need_resched() ||
 				(i_mmap_lock && need_lockbreak(i_mmap_lock))) {
 				if (i_mmap_lock) {
@@ -1655,7 +1660,10 @@ gotten:
 		ptep_clear_flush(vma, address, page_table);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
-		lru_cache_add_active(new_page);
+		if (!(vma->vm_flags & VM_LOCKED))
+			lru_cache_add_active(new_page);
+		else
+			mlock_new_page(new_page);
 		page_add_new_anon_rmap(new_page, vma, address);
 
 		/* Free the old page.. */
@@ -2119,6 +2127,49 @@ out_nomap:
 }
 
 /*
+ * This routine is used to map in an anonymous page into an address space:
+ * needed by execve() for the initial stack and environment pages.
+ *
+ * vma->vm_mm->mmap_sem must be held.
+ *
+ * Returns 0 on success, otherwise the failure code.
+ *
+ * The routine consumes the reference on the page if it is successful,
+ * otherwise the caller must free it.
+ */
+int install_new_anon_page(struct vm_area_struct *vma,
+			struct page *page, unsigned long address)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t * pte;
+	spinlock_t *ptl;
+
+	if (unlikely(anon_vma_prepare(vma)))
+		return -ENOMEM;
+
+	flush_dcache_page(page);
+	pte = get_locked_pte(mm, address, &ptl);
+	if (!pte)
+		return -ENOMEM;
+	if (!pte_none(*pte)) {
+		pte_unmap_unlock(pte, ptl);
+		return -EEXIST;
+	}
+	inc_mm_counter(mm, anon_rss);
+	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
+					page, vma->vm_page_prot))));
+	if (!(vma->vm_flags & VM_LOCKED))
+		lru_cache_add_active(page);
+	else
+		mlock_new_page(page);
+	page_add_new_anon_rmap(page, vma, address);
+	pte_unmap_unlock(pte, ptl);
+
+	/* no need for flush_tlb */
+	return 0;
+}
+
+/*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
@@ -2148,7 +2199,10 @@ static int do_anonymous_page(struct mm_s
 		if (!pte_none(*page_table))
 			goto release;
 		inc_mm_counter(mm, anon_rss);
-		lru_cache_add_active(page);
+		if (!(vma->vm_flags & VM_LOCKED))
+			lru_cache_add_active(page);
+		else
+			mlock_new_page(page);
 		page_add_new_anon_rmap(page, vma, address);
 	} else {
 		/* Map the ZERO_PAGE - vm_page_prot is readonly */
@@ -2291,7 +2345,10 @@ static int __do_fault(struct mm_struct *
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
                         inc_mm_counter(mm, anon_rss);
-                        lru_cache_add_active(page);
+			if (!(vma->vm_flags & VM_LOCKED))
+				lru_cache_add_active(page);
+			else
+				mlock_new_page(page);
                         page_add_new_anon_rmap(page, vma, address);
 		} else {
 			inc_mm_counter(mm, file_rss);
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -512,6 +512,8 @@ static unsigned long shrink_page_list(st
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
+			case SWAP_MLOCK:
+				goto mlocked;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -594,6 +596,9 @@ keep_locked:
 keep:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page));
+		continue;
+mlocked:
+		unlock_page(page);
 	}
 	list_splice(&ret_pages, page_list);
 	if (pagevec_count(&freed_pvec))
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -91,6 +91,7 @@
 #define PG_nosave_free		18	/* Used for system suspend/resume */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
+#define PG_mlock		20	/* Page has mlocked vmas */
 
 #if (BITS_PER_LONG > 32)
 /*
@@ -247,6 +248,10 @@ static inline void SetPageUptodate(struc
 #define PageSwapCache(page)	0
 #endif
 
+#define PageMLock(page)		test_bit(PG_mlock, &(page)->flags)
+#define SetPageMLock(page)	set_bit(PG_mlock, &(page)->flags)
+#define ClearPageMLock(page)	clear_bit(PG_mlock, &(page)->flags)
+
 #define PageUncached(page)	test_bit(PG_uncached, &(page)->flags)
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -203,7 +203,8 @@ static void bad_page(struct page *page)
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
-			1 << PG_buddy );
+			1 << PG_buddy |
+			1 << PG_mlock );
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
 	page->mapping = NULL;
@@ -438,7 +439,8 @@ static inline int free_pages_check(struc
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
-			1 << PG_buddy ))))
+			1 << PG_buddy |
+			1 << PG_mlock ))))
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
@@ -588,7 +590,8 @@ static int prep_new_page(struct page *pa
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
-			1 << PG_buddy ))))
+			1 << PG_buddy |
+			1 << PG_mlock ))))
 		bad_page(page);
 
 	/*
Index: linux-2.6/fs/exec.c
===================================================================
--- linux-2.6.orig/fs/exec.c
+++ linux-2.6/fs/exec.c
@@ -297,44 +297,6 @@ int copy_strings_kernel(int argc,char **
 EXPORT_SYMBOL(copy_strings_kernel);
 
 #ifdef CONFIG_MMU
-/*
- * This routine is used to map in a page into an address space: needed by
- * execve() for the initial stack and environment pages.
- *
- * vma->vm_mm->mmap_sem is held for writing.
- */
-void install_arg_page(struct vm_area_struct *vma,
-			struct page *page, unsigned long address)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	pte_t * pte;
-	spinlock_t *ptl;
-
-	if (unlikely(anon_vma_prepare(vma)))
-		goto out;
-
-	flush_dcache_page(page);
-	pte = get_locked_pte(mm, address, &ptl);
-	if (!pte)
-		goto out;
-	if (!pte_none(*pte)) {
-		pte_unmap_unlock(pte, ptl);
-		goto out;
-	}
-	inc_mm_counter(mm, anon_rss);
-	lru_cache_add_active(page);
-	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
-					page, vma->vm_page_prot))));
-	page_add_new_anon_rmap(page, vma, address);
-	pte_unmap_unlock(pte, ptl);
-
-	/* no need for flush_tlb */
-	return;
-out:
-	__free_page(page);
-	force_sig(SIGKILL, current);
-}
-
 #define EXTRA_STACK_VM_PAGES	20	/* random */
 
 int setup_arg_pages(struct linux_binprm *bprm,
@@ -438,17 +400,25 @@ int setup_arg_pages(struct linux_binprm 
 		mm->stack_vm = mm->total_vm = vma_pages(mpnt);
 	}
 
+	ret = 0;
 	for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
 		struct page *page = bprm->page[i];
 		if (page) {
 			bprm->page[i] = NULL;
-			install_arg_page(mpnt, page, stack_base);
+			if (!ret)
+				ret = install_new_anon_page(mpnt, page,
+								stack_base);
+			if (ret)
+				put_page(page);
 		}
 		stack_base += PAGE_SIZE;
 	}
 	up_write(&mm->mmap_sem);
-	
-	return 0;
+
+	if (ret)
+		do_munmap(mm, mpnt->vm_start, mpnt->vm_start - mpnt->vm_end);
+
+	return ret;
 }
 
 EXPORT_SYMBOL(setup_arg_pages);
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -791,7 +791,7 @@ static inline int handle_mm_fault(struct
 
 extern int make_pages_present(unsigned long addr, unsigned long end);
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
-void install_arg_page(struct vm_area_struct *, struct page *, unsigned long);
+int install_new_anon_page(struct vm_area_struct *, struct page *, unsigned long);
 
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm, unsigned long start,
 		int len, int write, int force, struct page **pages, struct vm_area_struct **vmas);
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -2179,8 +2179,16 @@ generic_file_direct_IO(int rw, struct ki
 	 */
 	if (rw == WRITE) {
 		write_len = iov_length(iov, nr_segs);
-	       	if (mapping_mapped(mapping))
+	       	if (mapping_mapped(mapping)) {
+			/*
+			 * Calling unmap_mapping_range like this is wrong,
+			 * because it can lead to mlocked pages being
+			 * discarded (this is true even before the PageMLock
+			 * work). direct-IO vs pagecache is a load of junk
+			 * anyway, so who cares.
+			 */
 			unmap_mapping_range(mapping, offset, write_len, 0);
+		}
 	}
 
 	retval = filemap_write_and_wait(mapping);
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c
+++ linux-2.6/mm/truncate.c
@@ -16,6 +16,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
+#include "internal.h"
 
 
 /**
@@ -99,6 +100,7 @@ truncate_complete_page(struct address_sp
 	if (PagePrivate(page))
 		do_invalidatepage(page, 0);
 
+	clear_page_mlock(page);
 	ClearPageUptodate(page);
 	ClearPageMappedToDisk(page);
 	remove_from_page_cache(page);
@@ -124,6 +126,7 @@ invalidate_complete_page(struct address_
 	if (PagePrivate(page) && !try_to_release_page(page, 0))
 		return 0;
 
+	clear_page_mlock(page);
 	ret = remove_mapping(mapping, page);
 
 	return ret;
@@ -342,6 +345,7 @@ invalidate_complete_page2(struct address
 	if (PageDirty(page))
 		goto failed;
 
+	clear_page_mlock(page);
 	BUG_ON(PagePrivate(page));
 	__remove_from_page_cache(page);
 	write_unlock_irq(&mapping->tree_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
