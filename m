From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070312042620.5536.55886.sendpatchset@linux.site>
In-Reply-To: <20070312042553.5536.73828.sendpatchset@linux.site>
References: <20070312042553.5536.73828.sendpatchset@linux.site>
Subject: [patch 3/4] mm: move mlocked pages off the LRU
Date: Mon, 12 Mar 2007 07:39:02 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Remove mlocked pages from the LRU. Use PageMLocked page flag, and when that
is set, page->lru.next becomes the mlock_count (conservative count of VM_LOCKED
vmas that reference this page). Based on idea from Christoph Hellwig.

Signed-off-by: Nick Piggin <npiggin@suse.de>

 include/linux/page-flags.h |    6 +
 include/linux/rmap.h       |    1 
 mm/filemap.c               |   10 +-
 mm/internal.h              |   34 +++++++
 mm/memory.c                |   22 +++-
 mm/mempolicy.c             |   28 +++++
 mm/migrate.c               |   17 +++
 mm/mlock.c                 |  212 ++++++++++++++++++++++++++++++++++++++++++---
 mm/mmap.c                  |   22 ++++
 mm/mremap.c                |    8 +
 mm/page_alloc.c            |    9 +
 mm/rmap.c                  |   73 ++++++++++++---
 mm/truncate.c              |    4 
 mm/vmscan.c                |    5 +
 14 files changed, 405 insertions(+), 46 deletions(-)

Index: linux-2.6/mm/mlock.c
===================================================================
--- linux-2.6.orig/mm/mlock.c
+++ linux-2.6/mm/mlock.c
@@ -8,17 +8,202 @@
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
+ *
+ * When lazy incrementing via vmscan, it is important to ensure that the
+ * vma's VM_LOCKED status is not concurrently being modified, otherwise we
+ * may have elevated mlock_count of a page that is being munlocked. So lazy
+ * mlocked must take the mmap_sem for read, and verify that the vma really
+ * is locked (see mm/rmap.c).
+ */
+
+/*
+ * Marks a page, belonging to the given mlocked vma, as mlocked.
+ *
+ * The page must be either locked or new, and must not be on the LRU.
+ */
+static void __set_page_mlock(struct page *page)
+{
+	BUG_ON(PageLRU(page));
+	BUG_ON(PageMLock(page));
+	/* BUG_ON(!list_empty(&page->lru)); -- if we always did list_del_init */
+
+	SetPageMLock(page);
+	get_page(page);
+	set_page_mlock_count(page, 1);
+}
+
+static void __clear_page_mlock(struct page *page)
+{
+	BUG_ON(!PageMLock(page));
+	BUG_ON(PageLRU(page));
+	BUG_ON(page_mlock_count(page));
+
+	ClearPageMLock(page);
+	lru_cache_add_active(page);
+	put_page(page);
+}
+
+/*
+ * Zero the page's mlock_count. This can be useful in a situation where
+ * we want to unconditionally remove a page from the pagecache.
+ *
+ * It is legal to call this function for any page, mlocked or not.
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
+void mlock_vma_page(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+
+	if (!PageMLock(page)) {
+		if (!isolate_lru_page(page)) {
+			if (PageActive(page))
+				ClearPageActive(page);
+			__set_page_mlock(page);
+		}
+	} else {
+		BUG_ON(!page_mlock_count(page));
+		inc_page_mlock_count(page);
+	}
+}
+
+void mlock_new_vma_page(struct page *page)
+{
+	__set_page_mlock(page);
+}
+
+static void munlock_vma_page(struct page *page)
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
+ * vma->vm_mm->mmap_sem must be held for write.
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
+	nr_pages = (end - start) / PAGE_SIZE;
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
+		ret = get_user_pages(current, mm, addr,
+				min_t(int, nr_pages, ARRAY_SIZE(pages)),
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
+					mlock_vma_page(page);
+			} else
+				munlock_vma_page(page);
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
+	int lock;
 
 	if (newflags == vma->vm_flags) {
 		*prev = vma;
@@ -48,24 +233,25 @@ static int mlock_fixup(struct vm_area_st
 	}
 
 success:
+	lock = !!(newflags & VM_LOCKED);
+
+	/*
+	 * Keep track of amount of locked VM.
+	 */
+	nr_pages = (end - start) >> PAGE_SHIFT;
+	if (!lock)
+		nr_pages = -nr_pages;
+	mm->locked_vm += nr_pages;
+
 	/*
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 * It's okay if try_to_unmap_one unmaps a page just after we
-	 * set VM_LOCKED, make_pages_present below will bring it back.
+	 * set VM_LOCKED, __mlock_vma_pages_range will bring it back.
 	 */
 	vma->vm_flags = newflags;
 
-	/*
-	 * Keep track of amount of locked VM.
-	 */
-	pages = (end - start) >> PAGE_SHIFT;
-	if (newflags & VM_LOCKED) {
-		pages = -pages;
-		if (!(newflags & VM_IO))
-			ret = make_pages_present(start, end);
-	}
+	__mlock_vma_pages_range(vma, start, end, lock);
 
-	mm->locked_vm -= pages;
 out:
 	if (ret == -ENOMEM)
 		ret = -EAGAIN;
Index: linux-2.6/mm/internal.h
===================================================================
--- linux-2.6.orig/mm/internal.h
+++ linux-2.6/mm/internal.h
@@ -36,6 +36,40 @@ static inline void __put_page(struct pag
 
 extern int isolate_lru_page(struct page *page);
 
+/*
+ * must be called with vma's mmap_sem held for read, and page locked.
+ */
+extern void mlock_vma_page(struct page *page);
+
+/*
+ * must be called with a new page (before being inserted into locked vma).
+ */
+extern void mlock_new_vma_page(struct page *page);
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
+extern void clear_page_mlock(struct page *page);
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
@@ -308,6 +310,13 @@ static int page_referenced_one(struct pa
 	if (!pte)
 		goto out;
 
+	/*
+	 * Don't want to elevate referenced for mlocked, in order that it
+	 * progresses to try_to_unmap and is removed from the LRU
+	 */
+	if (vma->vm_flags & VM_LOCKED)
+		goto out_unmap;
+
 	if (ptep_clear_flush_young(vma, address, pte))
 		referenced++;
 
@@ -317,6 +326,7 @@ static int page_referenced_one(struct pa
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced++;
 
+out_unmap:
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
 out:
@@ -389,11 +399,6 @@ static int page_referenced_file(struct p
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
@@ -689,10 +694,15 @@ static int try_to_unmap_one(struct page 
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
@@ -774,6 +784,9 @@ out:
  * For very sparsely populated VMAs this is a little inefficient - chances are
  * there there won't be many ptes located within the scan cluster.  In this case
  * maybe we could scan further - to the end of the pte page, perhaps.
+ *
+ * Mlocked pages also aren't handled very well at the moment: they aren't
+ * moved off the LRU like they are for linear pages.
  */
 #define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
 #define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
@@ -849,6 +862,7 @@ static int try_to_unmap_anon(struct page
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
+	unsigned int mlocked = 0;
 	int ret = SWAP_AGAIN;
 
 	anon_vma = page_lock_anon_vma(page);
@@ -859,9 +873,23 @@ static int try_to_unmap_anon(struct page
 		ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
 			break;
+		if (ret == SWAP_MLOCK) {
+			if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
+				if (vma->vm_flags & VM_LOCKED) {
+					mlock_vma_page(page);
+					mlocked++;
+				}
+				up_read(&vma->vm_mm->mmap_sem);
+			}
+		}
 	}
-
 	page_unlock_anon_vma(anon_vma);
+
+	if (mlocked)
+		ret = SWAP_MLOCK;
+	else if (ret == SWAP_MLOCK)
+		ret = SWAP_AGAIN;
+
 	return ret;
 }
 
@@ -884,21 +912,33 @@ static int try_to_unmap_file(struct page
 	unsigned long cursor;
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
-	unsigned int mapcount;
+	unsigned int mapcount, mlocked = 0;
 
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
 			goto out;
+		if (ret == SWAP_MLOCK) {
+			if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
+				if (vma->vm_flags & VM_LOCKED) {
+					mlock_vma_page(page);
+					mlocked++;
+				}
+				up_read(&vma->vm_mm->mmap_sem);
+			}
+		}
 	}
 
+	if (mlocked)
+		goto out;
+
 	if (list_empty(&mapping->i_mmap_nonlinear))
 		goto out;
 
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-		if ((vma->vm_flags & VM_LOCKED) && !migration)
+		if (!migration && (vma->vm_flags & VM_LOCKED))
 			continue;
 		cursor = (unsigned long) vma->vm_private_data;
 		if (cursor > max_nl_cursor)
@@ -932,8 +972,6 @@ static int try_to_unmap_file(struct page
 	do {
 		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-			if ((vma->vm_flags & VM_LOCKED) && !migration)
-				continue;
 			cursor = (unsigned long) vma->vm_private_data;
 			while ( cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
@@ -958,6 +996,10 @@ static int try_to_unmap_file(struct page
 		vma->vm_private_data = NULL;
 out:
 	spin_unlock(&mapping->i_mmap_lock);
+	if (mlocked)
+		ret = SWAP_MLOCK;
+	else if (ret == SWAP_MLOCK)
+		ret = SWAP_AGAIN;
 	return ret;
 }
 
@@ -983,8 +1025,7 @@ int try_to_unmap(struct page *page, int 
 		ret = try_to_unmap_anon(page, migration);
 	else
 		ret = try_to_unmap_file(page, migration);
-
-	if (!page_mapped(page))
+	if (ret != SWAP_MLOCK && !page_mapped(page))
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
@@ -1147,7 +1149,7 @@ out:	
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		mlock_vma_pages_range(vma, addr, addr + len);
 	}
 	if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
 		make_pages_present(addr, addr + len);
@@ -1686,6 +1688,15 @@ static void unmap_region(struct mm_struc
 	struct mmu_gather *tlb;
 	unsigned long nr_accounted = 0;
 
+	if (mm->locked_vm) {
+		struct vm_area_struct *tmp = vma;
+		while (tmp && tmp->vm_start < end) {
+			if (tmp->vm_flags & VM_LOCKED)
+				munlock_vma_pages_range(tmp, tmp->vm_start, tmp->vm_end);
+			tmp = tmp->vm_next;
+		}
+	}
+
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
@@ -1960,7 +1971,7 @@ out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
-		make_pages_present(addr, addr + len);
+		mlock_vma_pages_range(vma, addr, addr + len);
 	}
 	return addr;
 }
@@ -1971,10 +1982,21 @@ EXPORT_SYMBOL(do_brk);
 void exit_mmap(struct mm_struct *mm)
 {
 	struct mmu_gather *tlb;
-	struct vm_area_struct *vma = mm->mmap;
+	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
 
+	if (mm->locked_vm) {
+		vma = mm->mmap;
+		while (vma) {
+			if (vma->vm_flags & VM_LOCKED)
+				munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
+			vma = vma->vm_next;
+		}
+	}
+
+	vma = mm->mmap;
+
 	lru_add_drain();
 	flush_cache_mm(mm);
 	tlb = tlb_gather_mmu(mm, 1);
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
@@ -123,5 +123,6 @@ static inline int page_mkclean(struct pa
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
@@ -1655,7 +1657,10 @@ gotten:
 		ptep_clear_flush(vma, address, page_table);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
-		lru_cache_add_active(new_page);
+		if (!(vma->vm_flags & VM_LOCKED))
+			lru_cache_add_active(new_page);
+		else
+			mlock_new_vma_page(new_page);
 		page_add_new_anon_rmap(new_page, vma, address);
 
 		/* Free the old page.. */
@@ -2159,7 +2164,10 @@ int install_new_anon_page(struct vm_area
 	inc_mm_counter(mm, anon_rss);
 	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
 					page, vma->vm_page_prot))));
-	lru_cache_add_active(page);
+	if (!(vma->vm_flags & VM_LOCKED))
+		lru_cache_add_active(page);
+	else
+		mlock_new_vma_page(page);
 	page_add_new_anon_rmap(page, vma, address);
 	pte_unmap_unlock(pte, ptl);
 
@@ -2197,7 +2205,10 @@ static int do_anonymous_page(struct mm_s
 		if (!pte_none(*page_table))
 			goto release;
 		inc_mm_counter(mm, anon_rss);
-		lru_cache_add_active(page);
+		if (!(vma->vm_flags & VM_LOCKED))
+			lru_cache_add_active(page);
+		else
+			mlock_new_vma_page(page);
 		page_add_new_anon_rmap(page, vma, address);
 	} else {
 		/* Map the ZERO_PAGE - vm_page_prot is readonly */
@@ -2340,7 +2351,10 @@ static int __do_fault(struct mm_struct *
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
                         inc_mm_counter(mm, anon_rss);
-                        lru_cache_add_active(page);
+			if (!(vma->vm_flags & VM_LOCKED))
+				lru_cache_add_active(page);
+			else
+				mlock_new_vma_page(page);
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
@@ -597,6 +599,9 @@ keep_locked:
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
@@ -91,6 +91,8 @@
 #define PG_nosave_free		18	/* Used for system suspend/resume */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
+#define PG_mlock		20	/* Page has mlocked vmas */
+
 /* PG_owner_priv_1 users should have descriptive aliases */
 #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
 
@@ -249,6 +251,10 @@ static inline void SetPageUptodate(struc
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
@@ -253,7 +253,8 @@ static void bad_page(struct page *page)
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
-			1 << PG_buddy );
+			1 << PG_buddy |
+			1 << PG_mlock );
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
 	page->mapping = NULL;
@@ -488,7 +489,8 @@ static inline int free_pages_check(struc
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
-			1 << PG_buddy ))))
+			1 << PG_buddy |
+			1 << PG_mlock ))))
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
@@ -639,7 +641,8 @@ static int prep_new_page(struct page *pa
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
-			1 << PG_buddy ))))
+			1 << PG_buddy |
+			1 << PG_mlock ))))
 		bad_page(page);
 
 	/*
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -2206,8 +2206,16 @@ generic_file_direct_IO(int rw, struct ki
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
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -272,6 +272,11 @@ static int migrate_page_move_mapping(str
 		return 0;
 	}
 
+	if (PageMLock(page)) {
+		clear_page_mlock(page);
+		lru_add_drain();
+	}
+
 	write_lock_irq(&mapping->tree_lock);
 
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
@@ -775,6 +780,18 @@ static int do_move_pages(struct mm_struc
 				!migrate_all)
 			goto put_and_set;
 
+		/*
+		 * Just do the simple thing and put back mlocked pages onto
+		 * the LRU list so they can be taken off again (inefficient
+		 * but not a big deal).
+		 */
+		if (PageMLock(page)) {
+			lock_page(page);
+			clear_page_mlock(page);
+			unlock_page(page);
+			lru_add_drain();
+		}
+
 		err = isolate_lru_page(page);
 		if (err) {
 put_and_set:
Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c
+++ linux-2.6/mm/mempolicy.c
@@ -89,6 +89,8 @@
 #include <linux/migrate.h>
 #include <linux/rmap.h>
 #include <linux/security.h>
+#include <linux/pagemap.h>
+#include <linux/pagevec.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -224,6 +226,11 @@ static int check_pte_range(struct vm_are
 	pte_t *orig_pte;
 	pte_t *pte;
 	spinlock_t *ptl;
+	struct pagevec migrate;
+	int i;
+
+resume:
+	pagevec_init(&migrate, 0);
 
 	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	do {
@@ -254,12 +261,26 @@ static int check_pte_range(struct vm_are
 
 		if (flags & MPOL_MF_STATS)
 			gather_stats(page, private, pte_dirty(*pte));
-		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
-			migrate_page_add(page, private, flags);
-		else
+		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
+			if (!pagevec_add(&migrate, page)) {
+				pte_unmap_unlock(orig_pte, ptl);
+				for (i = 0; i < pagevec_count(&migrate); i++) {
+					struct page *page = migrate.pages[i];
+					if (PageMLock(page)) {
+						lock_page(page);
+						clear_page_mlock(page);
+						unlock_page(page);
+						lru_add_drain();
+					}
+					migrate_page_add(page, private, flags);
+				}
+				goto resume;
+			}
+		} else
 			break;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	pte_unmap_unlock(orig_pte, ptl);
+
 	return addr != end;
 }
 
@@ -363,6 +384,7 @@ check_range(struct mm_struct *mm, unsign
 				endvma = end;
 			if (vma->vm_start > start)
 				start = vma->vm_start;
+
 			err = check_pgd_range(vma, start, endvma, nodes,
 						flags, private);
 			if (err) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
