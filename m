Message-Id: <20080606202859.522708682@redhat.com>
References: <20080606202838.390050172@redhat.com>
Date: Fri, 06 Jun 2008 16:28:55 -0400
From: Rik van Riel <riel@redhat.com>
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 17/25] Mlocked Pages are non-reclaimable
Content-Disposition: inline; filename=rvr-17-lts-noreclaim-handle-mlocked-pages-during-map-unmap.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Originally
From: Nick Piggin <npiggin@suse.de>

Against:  2.6.26-rc2-mm1

This patch:

1) defines the [CONFIG_]NORECLAIM_MLOCK sub-option and the
   stub version of the mlock/noreclaim APIs when it's
   not configured.  Depends on [CONFIG_]NORECLAIM_LRU.

2) add yet another page flag--PG_mlocked--to indicate that
   the page is locked for efficient testing in vmscan and,
   optionally, fault path.  This allows early culling of
   nonreclaimable pages, preventing them from getting to
   page_referenced()/try_to_unmap().  Also allows separate
   accounting of mlock'd pages, as Nick's original patch
   did.

   Note:  Nick's original mlock patch used a PG_mlocked
   flag.  I had removed this in favor of the PG_noreclaim
   flag + an mlock_count [new page struct member].  I
   restored the PG_mlocked flag to eliminate the new
   count field.  

3) add the mlock/noreclaim infrastructure to mm/mlock.c,
   with internal APIs in mm/internal.h.  This is a rework
   of Nick's original patch to these files, taking into
   account that mlocked pages are now kept on noreclaim
   LRU list.

4) update vmscan.c:page_reclaimable() to check PageMlocked()
   and, if vma passed in, the vm_flags.  Note that the vma
   will only be passed in for new pages in the fault path;
   and then only if the "cull nonreclaimable pages in fault
   path" patch is included.

5) add try_to_unlock() to rmap.c to walk a page's rmap and
   ClearPageMlocked() if no other vmas have it mlocked.  
   Reuses as much of try_to_unmap() as possible.  This
   effectively replaces the use of one of the lru list links
   as an mlock count.  If this mechanism let's pages in mlocked
   vmas leak through w/o PG_mlocked set [I don't know that it
   does], we should catch them later in try_to_unmap().  One
   hopes this will be rare, as it will be relatively expensive.

6) Kosaki:  added munlock page table walk to avoid using
   get_user_pages() for unlock.  get_user_pages() is unreliable
   for some vma protections.
   Lee:  modified to wait for in-flight migration to complete
   to close munlock/migration race that could strand pages.

Original mm/internal.h, mm/rmap.c and mm/mlock.c changes:
Signed-off-by: Nick Piggin <npiggin@suse.de>

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

---

V8:
+ more refinement of rmap interaction, including attempt to
  handle mlocked pages in non-linear mappings.
+ cleanup of lockdep reported errors.
+ enhancement of munlock page table walker to detect and 
  handle pages under migration [migration ptes].

V6:
+ Kosaki-san and Rik van Riel:  added check for "page mapped
  in vma" to try_to_unlock() processing in try_to_unmap_anon().
+ Kosaki-san added munlock page table walker to avoid use of
  get_user_pages() for munlock.  get_user_pages() proved to be
  unreliable for some types of vmas.
+ added filtering of "special" vmas.  Some [_IO||_PFN] we skip
  altogether.  Others, we just "make_pages_present" to simulate
  old behavior--i.e., populate page tables.  Clear/don't set
  VM_LOCKED in non-mlockable vmas so that we don't try to unlock
  at exit/unmap time.
+ rework PG_mlock page flag definitions for new page flags
  macros.
+ Clear PageMlocked when COWing a page into a VM_LOCKED vma
  so we don't leave an mlocked page in another non-mlocked
  vma.  If the other vma[s] had the page mlocked, we'll re-mlock
  it if/when we try to reclaim it.  This is less expensive than
  walking the rmap in the COW/fault path.
+ in vmscan:shrink_page_list(), avoid  adding anon page to
  the swap cache if it's in a VM_LOCKED vma, even tho'
  PG_mlocked might not be set.  Call try_to_unlock() to
  determine this.  As a result, we'll never try to unmap
  an mlocked anon page.
+ in support of the above change, updated try_to_unlock()
  to use same logic as try_to_unmap() when it encounters a
  VM_LOCKED vma--call mlock_vma_page() directly.  Added
  stub try_to_unlock() for vmscan when NORECLAIM_MLOCK
  not configured.

V4 -> V5:
+ fixed problem with placement of #ifdef CONFIG_NORECLAIM_MLOCK
  in prep_new_page() [Thanks, minchan Kim!].

V3 -> V4:
+ Added #ifdef CONFIG_NORECLAIM_MLOCK, #endif around use of
  PG_mlocked in free_page_check(), et al.  Not defined for
  32-bit builds.

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split lru series
+ fix page flags macros for *PageMlocked() when not configured.
+ ensure lru_add_drain_all() runs on all cpus when NORECLAIM_MLOCK
  configured.  Was just for NUMA.

V1 -> V2:
+ moved this patch [and related patches] up to right after
  ramdisk/ramfs and SHM_LOCKed patches.
+ add [back] missing put_page() in putback_lru_page().
  This solved page leakage as seen by stats in previous
  version.
+ fix up munlock_vma_page() to isolate page from lru
  before calling try_to_unlock().  Think I detected a
  race here.
+ use TestClearPageMlock() on old page in migrate.c's
  migrate_page_copy() to clean up old page.
+ live dangerously:  remove TestSetPageLocked() in 
  is_mlocked_vma()--should only be called on new pages in
  the fault path--iff we chose to cull there [later patch].
+ Add PG_mlocked to free_pages_check() etc to detect mlock
  state mismanagement.
  NOTE:  temporarily [???] commented out--tripping over it
  under load.  Why?

Rework of Nick Piggins's "mm: move mlocked pages off the LRU" patch
 -- part 1 of 2.

 include/linux/mm.h         |    5 
 include/linux/page-flags.h |   16 +
 include/linux/rmap.h       |   14 +
 mm/Kconfig                 |   14 +
 mm/internal.h              |   70 ++++++++
 mm/memory.c                |   19 ++
 mm/migrate.c               |    2 
 mm/mlock.c                 |  386 ++++++++++++++++++++++++++++++++++++++++++---
 mm/mmap.c                  |    1 
 mm/page_alloc.c            |   15 +
 mm/rmap.c                  |  252 +++++++++++++++++++++++++----
 mm/swap.c                  |    2 
 mm/vmscan.c                |   40 +++-
 13 files changed, 767 insertions(+), 69 deletions(-)

Index: linux-2.6.26-rc2-mm1/mm/Kconfig
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/Kconfig	2008-06-06 16:05:15.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/Kconfig	2008-06-06 16:06:28.000000000 -0400
@@ -215,3 +215,17 @@ config NORECLAIM_LRU
 	  may be non-reclaimable because:  they are locked into memory, they
 	  are anonymous pages for which no swap space exists, or they are anon
 	  pages that are expensive to unmap [long anon_vma "related vma" list.]
+
+config NORECLAIM_MLOCK
+	bool "Exclude mlock'ed pages from reclaim"
+	depends on NORECLAIM_LRU
+	help
+	  Treats mlock'ed pages as no-reclaimable.  Removing these pages from
+	  the LRU [in]active lists avoids the overhead of attempting to reclaim
+	  them.  Pages marked non-reclaimable for this reason will become
+	  reclaimable again when the last mlock is removed.
+	  when no swap space exists.  Removing these pages from the LRU lists
+	  avoids the overhead of attempting to reclaim them.  Pages marked
+	  non-reclaimable for this reason will become reclaimable again when/if
+	  sufficient swap space is added to the system.
+
Index: linux-2.6.26-rc2-mm1/mm/internal.h
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/internal.h	2008-06-06 16:05:15.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/internal.h	2008-06-06 16:06:28.000000000 -0400
@@ -56,6 +56,17 @@ static inline unsigned long page_order(s
 	return page_private(page);
 }
 
+/*
+ * mlock all pages in this vma range.  For mmap()/mremap()/...
+ */
+extern int mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end);
+
+/*
+ * munlock all pages in vma.   For munmap() and exit().
+ */
+extern void munlock_vma_pages_all(struct vm_area_struct *vma);
+
 #ifdef CONFIG_NORECLAIM_LRU
 /*
  * noreclaim_migrate_page() called only from migrate_page_copy() to
@@ -74,6 +85,65 @@ static inline void noreclaim_migrate_pag
 }
 #endif
 
+#ifdef CONFIG_NORECLAIM_MLOCK
+/*
+ * Called only in fault path via page_reclaimable() for a new page
+ * to determine if it's being mapped into a LOCKED vma.
+ * If so, mark page as mlocked.
+ */
+static inline int is_mlocked_vma(struct vm_area_struct *vma, struct page *page)
+{
+	VM_BUG_ON(PageLRU(page));
+
+	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
+		return 0;
+
+	SetPageMlocked(page);
+	return 1;
+}
+
+/*
+ * must be called with vma's mmap_sem held for read, and page locked.
+ */
+extern void mlock_vma_page(struct page *page);
+
+/*
+ * Clear the page's PageMlocked().  This can be useful in a situation where
+ * we want to unconditionally remove a page from the pagecache -- e.g.,
+ * on truncation or freeing.
+ *
+ * It is legal to call this function for any page, mlocked or not.
+ * If called for a page that is still mapped by mlocked vmas, all we do
+ * is revert to lazy LRU behaviour -- semantics are not broken.
+ */
+extern void __clear_page_mlock(struct page *page);
+static inline void clear_page_mlock(struct page *page)
+{
+	if (unlikely(TestClearPageMlocked(page)))
+		__clear_page_mlock(page);
+}
+
+/*
+ * mlock_migrate_page - called only from migrate_page_copy() to
+ * migrate the Mlocked page flag
+ */
+static inline void mlock_migrate_page(struct page *newpage, struct page *page)
+{
+	if (TestClearPageMlocked(page))
+		SetPageMlocked(newpage);
+}
+
+
+#else /* CONFIG_NORECLAIM_MLOCK */
+static inline int is_mlocked_vma(struct vm_area_struct *v, struct page *p)
+{
+	return 0;
+}
+static inline void clear_page_mlock(struct page *page) { }
+static inline void mlock_vma_page(struct page *page) { }
+static inline void mlock_migrate_page(struct page *new, struct page *old) { }
+
+#endif /* CONFIG_NORECLAIM_MLOCK */
 
 /*
  * FLATMEM and DISCONTIGMEM configurations use alloc_bootmem_node,
Index: linux-2.6.26-rc2-mm1/mm/mlock.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/mlock.c	2008-05-15 11:20:15.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/mlock.c	2008-06-06 16:06:28.000000000 -0400
@@ -8,10 +8,18 @@
 #include <linux/capability.h>
 #include <linux/mman.h>
 #include <linux/mm.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+#include <linux/pagemap.h>
 #include <linux/mempolicy.h>
 #include <linux/syscalls.h>
 #include <linux/sched.h>
 #include <linux/module.h>
+#include <linux/rmap.h>
+#include <linux/mmzone.h>
+#include <linux/hugetlb.h>
+
+#include "internal.h"
 
 int can_do_mlock(void)
 {
@@ -23,17 +31,354 @@ int can_do_mlock(void)
 }
 EXPORT_SYMBOL(can_do_mlock);
 
+#ifdef CONFIG_NORECLAIM_MLOCK
+/*
+ * Mlocked pages are marked with PageMlocked() flag for efficient testing
+ * in vmscan and, possibly, the fault path; and to support semi-accurate
+ * statistics.
+ *
+ * An mlocked page [PageMlocked(page)] is non-reclaimable.  As such, it will
+ * be placed on the LRU "noreclaim" list, rather than the [in]active lists.
+ * The noreclaim list is an LRU sibling list to the [in]active lists.
+ * PageNoreclaim is set to indicate the non-reclaimable state.
+ *
+ * When lazy mlocking via vmscan, it is important to ensure that the
+ * vma's VM_LOCKED status is not concurrently being modified, otherwise we
+ * may have mlocked a page that is being munlocked. So lazy mlock must take
+ * the mmap_sem for read, and verify that the vma really is locked
+ * (see mm/rmap.c).
+ */
+
+/*
+ *  LRU accounting for clear_page_mlock()
+ */
+void __clear_page_mlock(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page));	/* for LRU islolate/putback */
+
+	if (!isolate_lru_page(page)) {
+		putback_lru_page(page);
+	} else {
+		/*
+		 * Try hard not to leak this page ...
+		 */
+		lru_add_drain_all();
+		if (!isolate_lru_page(page))
+			putback_lru_page(page);
+	}
+}
+
+/*
+ * Mark page as mlocked if not already.
+ * If page on LRU, isolate and putback to move to noreclaim list.
+ */
+void mlock_vma_page(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+
+	if (!TestSetPageMlocked(page) && !isolate_lru_page(page))
+			putback_lru_page(page);
+}
+
+/*
+ * called from munlock()/munmap() path with page supposedly on the LRU.
+ *
+ * Note:  unlike mlock_vma_page(), we can't just clear the PageMlocked
+ * [in try_to_unlock()] and then attempt to isolate the page.  We must
+ * isolate the page() to keep others from messing with its noreclaim
+ * and mlocked state while trying to unlock.  However, we pre-clear the
+ * mlocked state anyway as we might lose the isolation race and we might
+ * not get another chance to clear PageMlocked.  If we successfully
+ * isolate the page and try_to_unlock() detects other VM_LOCKED vmas
+ * mapping the page, it will restore the PageMlocked state, unless the page
+ * is mapped in a non-linear vma.  So, we go ahead and SetPageMlocked(),
+ * perhaps redundantly.
+ * If we lose the isolation race, and the page is mapped by other VM_LOCKED
+ * vmas, we'll detect this in vmscan--via try_to_unlock() or try_to_unmap()
+ * either of which will restore the PageMlocked state by calling
+ * mlock_vma_page() above, if it can grab the vma's mmap sem.
+ */
+static void munlock_vma_page(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+
+	if (TestClearPageMlocked(page) && !isolate_lru_page(page)) {
+		try_to_unlock(page);
+		putback_lru_page(page);
+	}
+}
+
+/*
+ * mlock a range of pages in the vma.
+ *
+ * This takes care of making the pages present too.
+ *
+ * vma->vm_mm->mmap_sem must be held for write.
+ */
+static int __mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long addr = start;
+	struct page *pages[16]; /* 16 gives a reasonable batch */
+	int write = !!(vma->vm_flags & VM_WRITE);
+	int nr_pages = (end - start) / PAGE_SIZE;
+	int ret;
+
+	VM_BUG_ON(start & ~PAGE_MASK || end & ~PAGE_MASK);
+	VM_BUG_ON(start < vma->vm_start || end > vma->vm_end);
+	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
+
+	lru_add_drain_all();	/* push cached pages to LRU */
+
+	while (nr_pages > 0) {
+		int i;
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
+		/*
+		 * This can happen for, e.g., VM_NONLINEAR regions before
+		 * a page has been allocated and mapped at a given offset,
+		 * or for addresses that map beyond end of a file.
+		 * We'll mlock the the pages if/when they get faulted in.
+		 */
+		if (ret < 0)
+			break;
+		if (ret == 0) {
+			/*
+			 * We know the vma is there, so the only time
+			 * we cannot get a single page should be an
+			 * error (ret < 0) case.
+			 */
+			WARN_ON(1);
+			break;
+		}
+
+		lru_add_drain();	/* push cached pages to LRU */
+
+		for (i = 0; i < ret; i++) {
+			struct page *page = pages[i];
+
+			/*
+			 * page might be truncated or migrated out from under
+			 * us.  Check after acquiring page lock.
+			 */
+			lock_page(page);
+			if (page->mapping)
+				mlock_vma_page(page);
+			unlock_page(page);
+			put_page(page);		/* ref from get_user_pages() */
+
+			/*
+			 * here we assume that get_user_pages() has given us
+			 * a list of virtually contiguous pages.
+			 */
+			addr += PAGE_SIZE;	/* for next get_user_pages() */
+			nr_pages--;
+		}
+	}
+
+	lru_add_drain_all();	/* to update stats */
+
+	return 0;	/* count entire vma as locked_vm */
+}
+
+/*
+ * private structure for munlock page table walk
+ */
+struct munlock_page_walk {
+	struct vm_area_struct *vma;
+	pmd_t                 *pmd; /* for migration_entry_wait() */
+};
+
+/*
+ * munlock normal pages for present ptes
+ */
+static int __munlock_pte_handler(pte_t *ptep, unsigned long addr,
+				   unsigned long end, void *private)
+{
+	struct munlock_page_walk *mpw = private;
+	swp_entry_t entry;
+	struct page *page;
+	pte_t pte;
+
+retry:
+	pte = *ptep;
+	/*
+	 * If it's a swap pte, we might be racing with page migration.
+	 */
+	if (unlikely(!pte_present(pte))) {
+		if (!is_swap_pte(pte))
+			goto out;
+		entry = pte_to_swp_entry(pte);
+		if (is_migration_entry(entry)) {
+			migration_entry_wait(mpw->vma->vm_mm, mpw->pmd, addr);
+			goto retry;
+		}
+		goto out;
+	}
+
+	page = vm_normal_page(mpw->vma, addr, pte);
+	if (!page)
+		goto out;
+
+	lock_page(page);
+	if (!page->mapping) {
+		unlock_page(page);
+		goto retry;
+	}
+	munlock_vma_page(page);
+	unlock_page(page);
+
+out:
+	return 0;
+}
+
+/*
+ * Save pmd for pte handler for waiting on migration entries
+ */
+static int __munlock_pmd_handler(pmd_t *pmd, unsigned long addr,
+				 unsigned long end, void *private)
+{
+	struct munlock_page_walk *mpw = private;
+
+	mpw->pmd = pmd;
+	return 0;
+}
+
+static struct mm_walk munlock_page_walk = {
+	.pmd_entry = __munlock_pmd_handler,
+	.pte_entry = __munlock_pte_handler,
+};
+
+/*
+ * munlock a range of pages in the vma using standard page table walk.
+ *
+ * vma->vm_mm->mmap_sem must be held for write.
+ */
+static void __munlock_vma_pages_range(struct vm_area_struct *vma,
+			      unsigned long start, unsigned long end)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct munlock_page_walk mpw;
+
+	VM_BUG_ON(start & ~PAGE_MASK || end & ~PAGE_MASK);
+	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
+	VM_BUG_ON(start < vma->vm_start);
+	VM_BUG_ON(end > vma->vm_end);
+
+	lru_add_drain_all();	/* push cached pages to LRU */
+	mpw.vma = vma;
+	(void)walk_page_range(mm, start, end, &munlock_page_walk, &mpw);
+	lru_add_drain_all();	/* to update stats */
+
+}
+
+#else /* CONFIG_NORECLAIM_MLOCK */
+
+/*
+ * Just make pages present if VM_LOCKED.  No-op if unlocking.
+ */
+static int __mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+	if (vma->vm_flags & VM_LOCKED)
+		make_pages_present(start, end);
+	return 0;
+}
+
+/*
+ * munlock a range of pages in the vma -- no-op.
+ */
+static void __munlock_vma_pages_range(struct vm_area_struct *vma,
+			      unsigned long start, unsigned long end)
+{
+}
+#endif /* CONFIG_NORECLAIM_MLOCK */
+
+/*
+ * mlock all pages in this vma range.  For mmap()/mremap()/...
+ */
+int mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+	int nr_pages = (end - start) / PAGE_SIZE;
+	BUG_ON(!(vma->vm_flags & VM_LOCKED));
+
+	/*
+	 * filter unlockable vmas
+	 */
+	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
+		goto no_mlock;
+
+	if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
+			is_vm_hugetlb_page(vma) ||
+			vma == get_gate_vma(current))
+		goto make_present;
+
+	return __mlock_vma_pages_range(vma, start, end);
+
+make_present:
+	/*
+	 * User mapped kernel pages or huge pages:
+	 * make these pages present to populate the ptes, but
+	 * fall thru' to reset VM_LOCKED--no need to unlock, and
+	 * return nr_pages so these don't get counted against task's
+	 * locked limit.  huge pages are already counted against
+	 * locked vm limit.
+	 */
+	make_pages_present(start, end);
+
+no_mlock:
+	vma->vm_flags &= ~VM_LOCKED;	/* and don't come back! */
+	return nr_pages;		/* pages NOT mlocked */
+}
+
+
+/*
+ * munlock all pages in vma.   For munmap() and exit().
+ */
+void munlock_vma_pages_all(struct vm_area_struct *vma)
+{
+	vma->vm_flags &= ~VM_LOCKED;
+	__munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
+}
+
+/*
+ * mlock_fixup  - handle mlock[all]/munlock[all] requests.
+ *
+ * Filters out "special" vmas -- VM_LOCKED never gets set for these, and
+ * munlock is a no-op.  However, for some special vmas, we go ahead and
+ * populate the ptes via make_pages_present().
+ *
+ * For vmas that pass the filters, merge/split as appropriate.
+ */
 static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	unsigned long start, unsigned long end, unsigned int newflags)
 {
-	struct mm_struct * mm = vma->vm_mm;
+	struct mm_struct *mm = vma->vm_mm;
 	pgoff_t pgoff;
-	int pages;
+	int nr_pages;
 	int ret = 0;
+	int lock = newflags & VM_LOCKED;
 
-	if (newflags == vma->vm_flags) {
-		*prev = vma;
-		goto out;
+	if (newflags == vma->vm_flags ||
+			(vma->vm_flags & (VM_IO | VM_PFNMAP)))
+		goto out;	/* don't set VM_LOCKED,  don't count */
+
+	if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
+			is_vm_hugetlb_page(vma) ||
+			vma == get_gate_vma(current)) {
+		if (lock)
+			make_pages_present(start, end);
+		goto out;	/* don't set VM_LOCKED,  don't count */
 	}
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
@@ -44,8 +389,6 @@ static int mlock_fixup(struct vm_area_st
 		goto success;
 	}
 
-	*prev = vma;
-
 	if (start != vma->vm_start) {
 		ret = split_vma(mm, vma, start, 1);
 		if (ret)
@@ -60,24 +403,31 @@ static int mlock_fixup(struct vm_area_st
 
 success:
 	/*
+	 * Keep track of amount of locked VM.
+	 */
+	nr_pages = (end - start) >> PAGE_SHIFT;
+	if (!lock)
+		nr_pages = -nr_pages;
+	mm->locked_vm += nr_pages;
+
+	/*
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
+	if (lock) {
+		ret = __mlock_vma_pages_range(vma, start, end);
+		if (ret > 0) {
+			mm->locked_vm -= ret;
+			ret = 0;
+		}
+	} else
+		__munlock_vma_pages_range(vma, start, end);
 
-	mm->locked_vm -= pages;
 out:
+	*prev = vma;
 	if (ret == -ENOMEM)
 		ret = -EAGAIN;
 	return ret;
Index: linux-2.6.26-rc2-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/vmscan.c	2008-06-06 16:06:24.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/vmscan.c	2008-06-06 16:06:28.000000000 -0400
@@ -537,11 +537,8 @@ static unsigned long shrink_page_list(st
 
 		sc->nr_scanned++;
 
-		if (unlikely(!page_reclaimable(page, NULL))) {
-			if (putback_lru_page(page))
-				unlock_page(page);
-			continue;
-		}
+		if (unlikely(!page_reclaimable(page, NULL)))
+			goto cull_mlocked;
 
 		if (!sc->may_swap && page_mapped(page))
 			goto keep_locked;
@@ -578,9 +575,19 @@ static unsigned long shrink_page_list(st
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page))
+		if (PageAnon(page) && !PageSwapCache(page)) {
+			switch (try_to_unlock(page)) {
+			case SWAP_FAIL:		/* shouldn't happen */
+			case SWAP_AGAIN:
+				goto keep_locked;
+			case SWAP_MLOCK:
+				goto cull_mlocked;
+			case SWAP_SUCCESS:
+				; /* fall thru'; add to swap cache */
+			}
 			if (!add_to_swap(page, GFP_ATOMIC))
 				goto activate_locked;
+		}
 #endif /* CONFIG_SWAP */
 
 		mapping = page_mapping(page);
@@ -595,6 +602,8 @@ static unsigned long shrink_page_list(st
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
+			case SWAP_MLOCK:
+				goto cull_mlocked;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -667,6 +676,11 @@ free_it:
 			__pagevec_release_nonlru(&freed_pvec);
 		continue;
 
+cull_mlocked:
+		if (putback_lru_page(page))
+			unlock_page(page);
+		continue;
+
 activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
 		if (PageSwapCache(page) && vm_swap_full())
@@ -678,7 +692,7 @@ keep_locked:
 		unlock_page(page);
 keep:
 		list_add(&page->lru, &ret_pages);
-		VM_BUG_ON(PageLRU(page));
+		VM_BUG_ON(PageLRU(page) || PageNoreclaim(page));
 	}
 	list_splice(&ret_pages, page_list);
 	if (pagevec_count(&freed_pvec))
@@ -2308,12 +2322,13 @@ int zone_reclaim(struct zone *zone, gfp_
  * @vma: the VMA in which the page is or will be mapped, may be NULL
  *
  * Test whether page is reclaimable--i.e., should be placed on active/inactive
- * lists vs noreclaim list.
+ * lists vs noreclaim list.  The vma argument is !NULL when called from the
+ * fault path to determine how to instantate a new page.
  *
  * Reasons page might not be reclaimable:
  * (1) page's mapping marked non-reclaimable
+ * (2) page is part of an mlocked VMA
  *
- * TODO - later patches
  */
 int page_reclaimable(struct page *page, struct vm_area_struct *vma)
 {
@@ -2323,13 +2338,16 @@ int page_reclaimable(struct page *page, 
 	if (mapping_non_reclaimable(page_mapping(page)))
 		return 0;
 
-	/* TODO:  test page [!]reclaimable conditions */
+#ifdef CONFIG_NORECLAIM_MLOCK
+	if (PageMlocked(page) || (vma && is_mlocked_vma(vma, page)))
+		return 0;
+#endif
 
 	return 1;
 }
 
 /**
- * check_move_noreclaim_page - check page for reclaimability and move to appropriate zone lru list
+ * check_move_noreclaim_page - check page for reclaimability and move to appropriate lru list
  * @page: page to check reclaimability and move to appropriate lru list
  * @zone: zone page is in
  *
Index: linux-2.6.26-rc2-mm1/include/linux/page-flags.h
===================================================================
--- linux-2.6.26-rc2-mm1.orig/include/linux/page-flags.h	2008-06-06 16:05:15.000000000 -0400
+++ linux-2.6.26-rc2-mm1/include/linux/page-flags.h	2008-06-06 16:06:28.000000000 -0400
@@ -96,6 +96,9 @@ enum pageflags {
 	PG_swapbacked,		/* Page is backed by RAM/swap */
 #ifdef CONFIG_NORECLAIM_LRU
 	PG_noreclaim,		/* Page is "non-reclaimable"  */
+#ifdef CONFIG_NORECLAIM_MLOCK
+	PG_mlocked,		/* Page is vma mlocked */
+#endif
 #endif
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 	PG_uncached,		/* Page has been mapped as uncached */
@@ -210,12 +213,25 @@ PAGEFLAG_FALSE(SwapCache)
 #ifdef CONFIG_NORECLAIM_LRU
 PAGEFLAG(Noreclaim, noreclaim) __CLEARPAGEFLAG(Noreclaim, noreclaim)
 	TESTCLEARFLAG(Noreclaim, noreclaim)
+
+#ifdef CONFIG_NORECLAIM_MLOCK
+#define MLOCK_PAGES 1
+PAGEFLAG(Mlocked, mlocked) __CLEARPAGEFLAG(Mlocked, mlocked)
+	TESTSCFLAG(Mlocked, mlocked)
+#endif
+
 #else
 PAGEFLAG_FALSE(Noreclaim) TESTCLEARFLAG_FALSE(Noreclaim)
 	SETPAGEFLAG_NOOP(Noreclaim) CLEARPAGEFLAG_NOOP(Noreclaim)
 	__CLEARPAGEFLAG_NOOP(Noreclaim)
 #endif
 
+#if !defined(CONFIG_NORECLAIM_MLOCK)
+#define MLOCK_PAGES 0
+PAGEFLAG_FALSE(Mlocked)
+	SETPAGEFLAG_NOOP(Mlocked) TESTCLEARFLAG_FALSE(Mlocked)
+#endif
+
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 PAGEFLAG(Uncached, uncached)
 #else
Index: linux-2.6.26-rc2-mm1/include/linux/rmap.h
===================================================================
--- linux-2.6.26-rc2-mm1.orig/include/linux/rmap.h	2008-05-15 11:21:11.000000000 -0400
+++ linux-2.6.26-rc2-mm1/include/linux/rmap.h	2008-06-06 16:06:28.000000000 -0400
@@ -97,6 +97,19 @@ unsigned long page_address_in_vma(struct
  */
 int page_mkclean(struct page *);
 
+#ifdef CONFIG_NORECLAIM_MLOCK
+/*
+ * called in munlock()/munmap() path to check for other vmas holding
+ * the page mlocked.
+ */
+int try_to_unlock(struct page *);
+#else
+static inline int try_to_unlock(struct page *page)
+{
+	return 0;	/* a.k.a. SWAP_SUCCESS */
+}
+#endif
+
 #else	/* !CONFIG_MMU */
 
 #define anon_vma_init()		do {} while (0)
@@ -120,5 +133,6 @@ static inline int page_mkclean(struct pa
 #define SWAP_SUCCESS	0
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
+#define SWAP_MLOCK	3
 
 #endif	/* _LINUX_RMAP_H */
Index: linux-2.6.26-rc2-mm1/mm/rmap.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/rmap.c	2008-05-15 11:21:11.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/rmap.c	2008-06-06 16:06:28.000000000 -0400
@@ -52,6 +52,8 @@
 
 #include <asm/tlbflush.h>
 
+#include "internal.h"
+
 static struct kmem_cache *anon_vma_cachep;
 
 static inline struct anon_vma *anon_vma_alloc(void)
@@ -273,6 +275,32 @@ pte_t *page_check_address(struct page *p
 	return NULL;
 }
 
+/**
+ * page_mapped_in_vma - check whether a page is really mapped in a VMA
+ * @page: the page to test
+ * @vma: the VMA to test
+ *
+ * Returns 1 if the page is mapped into the page tables of the VMA, 0
+ * if the page is not mapped into the page tables of this VMA.  Only
+ * valid for normal file or anonymous VMAs.
+ */
+static int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
+{
+	unsigned long address;
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	address = vma_address(page, vma);
+	if (address == -EFAULT)		/* out of vma range */
+		return 0;
+	pte = page_check_address(page, vma->vm_mm, address, &ptl);
+	if (!pte)			/* the page is not in this mm */
+		return 0;
+	pte_unmap_unlock(pte, ptl);
+
+	return 1;
+}
+
 /*
  * Subfunctions of page_referenced: page_referenced_one called
  * repeatedly from either page_referenced_anon or page_referenced_file.
@@ -294,10 +322,17 @@ static int page_referenced_one(struct pa
 	if (!pte)
 		goto out;
 
+	/*
+	 * Don't want to elevate referenced for mlocked page that gets this far,
+	 * in order that it progresses to try_to_unmap and is moved to the
+	 * noreclaim list.
+	 */
 	if (vma->vm_flags & VM_LOCKED) {
-		referenced++;
 		*mapcount = 1;	/* break early from loop */
-	} else if (ptep_clear_flush_young(vma, address, pte))
+		goto out_unmap;
+	}
+
+	if (ptep_clear_flush_young(vma, address, pte))
 		referenced++;
 
 	/* Pretend the page is referenced if the task has the
@@ -306,6 +341,7 @@ static int page_referenced_one(struct pa
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced++;
 
+out_unmap:
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
 out:
@@ -395,11 +431,6 @@ static int page_referenced_file(struct p
 		 */
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
-		if ((vma->vm_flags & (VM_LOCKED|VM_MAYSHARE))
-				  == (VM_LOCKED|VM_MAYSHARE)) {
-			referenced++;
-			break;
-		}
 		referenced += page_referenced_one(page, vma, &mapcount);
 		if (!mapcount)
 			break;
@@ -726,10 +757,15 @@ static int try_to_unmap_one(struct page 
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
@@ -811,12 +847,17 @@ out:
  * For very sparsely populated VMAs this is a little inefficient - chances are
  * there there won't be many ptes located within the scan cluster.  In this case
  * maybe we could scan further - to the end of the pte page, perhaps.
+ *
+ * Mlocked pages:  check VM_LOCKED under mmap_sem held for read, if we can
+ * acquire it without blocking.  If vma locked, mlock the pages in the cluster,
+ * rather than unmapping them.  If we encounter the "check_page" that vmscan is
+ * trying to unmap, return SWAP_MLOCK, else default SWAP_AGAIN.
  */
 #define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
 #define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
 
-static void try_to_unmap_cluster(unsigned long cursor,
-	unsigned int *mapcount, struct vm_area_struct *vma)
+static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
+		struct vm_area_struct *vma, struct page *check_page)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
@@ -828,6 +869,8 @@ static void try_to_unmap_cluster(unsigne
 	struct page *page;
 	unsigned long address;
 	unsigned long end;
+	int ret = SWAP_AGAIN;
+	int locked_vma = 0;
 
 	address = (vma->vm_start + cursor) & CLUSTER_MASK;
 	end = address + CLUSTER_SIZE;
@@ -838,15 +881,26 @@ static void try_to_unmap_cluster(unsigne
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
-		return;
+		return ret;
 
 	pud = pud_offset(pgd, address);
 	if (!pud_present(*pud))
-		return;
+		return ret;
 
 	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
-		return;
+		return ret;
+
+	/*
+	 * MLOCK_PAGES => feature is configured.
+	 * if we can acquire the mmap_sem for read, and vma is VM_LOCKED,
+	 * keep the sem while scanning the cluster for mlocking pages.
+	 */
+	if (MLOCK_PAGES && down_read_trylock(&vma->vm_mm->mmap_sem)) {
+		locked_vma = (vma->vm_flags & VM_LOCKED);
+		if (!locked_vma)
+			up_read(&vma->vm_mm->mmap_sem); /* don't need it */
+	}
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 
@@ -859,6 +913,13 @@ static void try_to_unmap_cluster(unsigne
 		page = vm_normal_page(vma, address, *pte);
 		BUG_ON(!page || PageAnon(page));
 
+		if (locked_vma) {
+			mlock_vma_page(page);   /* no-op if already mlocked */
+			if (page == check_page)
+				ret = SWAP_MLOCK;
+			continue;	/* don't unmap */
+		}
+
 		if (ptep_clear_flush_young(vma, address, pte))
 			continue;
 
@@ -880,39 +941,104 @@ static void try_to_unmap_cluster(unsigne
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
+	if (locked_vma)
+		up_read(&vma->vm_mm->mmap_sem);
+	return ret;
 }
 
-static int try_to_unmap_anon(struct page *page, int migration)
+/*
+ * common handling for pages mapped in VM_LOCKED vmas
+ */
+static int try_to_mlock_page(struct page *page, struct vm_area_struct *vma)
+{
+	int mlocked = 0;
+
+	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
+		if (vma->vm_flags & VM_LOCKED) {
+			mlock_vma_page(page);
+			mlocked++;	/* really mlocked the page */
+		}
+		up_read(&vma->vm_mm->mmap_sem);
+	}
+	return mlocked;
+}
+
+/**
+ * try_to_unmap_anon - unmap or unlock anonymous page using the object-based
+ * rmap method
+ * @page: the page to unmap/unlock
+ * @unlock:  request for unlock rather than unmap [unlikely]
+ * @migration:  unmapping for migration - ignored if @unlock
+ *
+ * Find all the mappings of a page using the mapping pointer and the vma chains
+ * contained in the anon_vma struct it points to.
+ *
+ * This function is only called from try_to_unmap/try_to_unlock for
+ * anonymous pages.
+ * When called from try_to_unlock(), the mmap_sem of the mm containing the vma
+ * where the page was found will be held for write.  So, we won't recheck
+ * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
+ * 'LOCKED.
+ */
+static int try_to_unmap_anon(struct page *page, int unlock, int migration)
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
+	unsigned int mlocked = 0;
 	int ret = SWAP_AGAIN;
 
+	if (MLOCK_PAGES && unlikely(unlock))
+		ret = SWAP_SUCCESS;	/* default for try_to_unlock() */
+
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
 		return ret;
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
-		ret = try_to_unmap_one(page, vma, migration);
-		if (ret == SWAP_FAIL || !page_mapped(page))
-			break;
+		if (MLOCK_PAGES && unlikely(unlock)) {
+			if (!((vma->vm_flags & VM_LOCKED) &&
+			      page_mapped_in_vma(page, vma)))
+				continue;  /* must visit all unlocked vmas */
+			ret = SWAP_MLOCK;  /* saw at least one mlocked vma */
+		} else {
+			ret = try_to_unmap_one(page, vma, migration);
+			if (ret == SWAP_FAIL || !page_mapped(page))
+				break;
+		}
+		if (ret == SWAP_MLOCK) {
+			mlocked = try_to_mlock_page(page, vma);
+			if (mlocked)
+				break;	/* stop if actually mlocked page */
+		}
 	}
 
 	page_unlock_anon_vma(anon_vma);
+
+	if (mlocked)
+		ret = SWAP_MLOCK;	/* actually mlocked the page */
+	else if (ret == SWAP_MLOCK)
+		ret = SWAP_AGAIN;	/* saw VM_LOCKED vma */
+
 	return ret;
 }
 
 /**
- * try_to_unmap_file - unmap file page using the object-based rmap method
- * @page: the page to unmap
- * @migration: migration flag
+ * try_to_unmap_file - unmap/unlock file page using the object-based rmap method
+ * @page: the page to unmap/unlock
+ * @unlock:  request for unlock rather than unmap [unlikely]
+ * @migration:  unmapping for migration - ignored if @unlock
  *
  * Find all the mappings of a page using the mapping pointer and the vma chains
  * contained in the address_space struct it points to.
  *
- * This function is only called from try_to_unmap for object-based pages.
+ * This function is only called from try_to_unmap/try_to_unlock for
+ * object-based pages.
+ * When called from try_to_unlock(), the mmap_sem of the mm containing the vma
+ * where the page was found will be held for write.  So, we won't recheck
+ * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
+ * 'LOCKED.
  */
-static int try_to_unmap_file(struct page *page, int migration)
+static int try_to_unmap_file(struct page *page, int unlock, int migration)
 {
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -923,20 +1049,44 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
+	unsigned int mlocked = 0;
+
+	if (MLOCK_PAGES && unlikely(unlock))
+		ret = SWAP_SUCCESS;	/* default for try_to_unlock() */
 
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
-		ret = try_to_unmap_one(page, vma, migration);
-		if (ret == SWAP_FAIL || !page_mapped(page))
-			goto out;
+		if (MLOCK_PAGES && unlikely(unlock)) {
+			if (!(vma->vm_flags & VM_LOCKED))
+				continue;	/* must visit all vmas */
+			ret = SWAP_MLOCK;
+		} else {
+			ret = try_to_unmap_one(page, vma, migration);
+			if (ret == SWAP_FAIL || !page_mapped(page))
+				goto out;
+		}
+		if (ret == SWAP_MLOCK) {
+			mlocked = try_to_mlock_page(page, vma);
+			if (mlocked)
+				break;  /* stop if actually mlocked page */
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
+		if (MLOCK_PAGES && unlikely(unlock)) {
+			if (!(vma->vm_flags & VM_LOCKED))
+				continue;	/* must visit all vmas */
+			ret = SWAP_MLOCK;	/* leave mlocked == 0 */
+			goto out;		/* no need to look further */
+		}
+		if (!MLOCK_PAGES && !migration && (vma->vm_flags & VM_LOCKED))
 			continue;
 		cursor = (unsigned long) vma->vm_private_data;
 		if (cursor > max_nl_cursor)
@@ -946,7 +1096,7 @@ static int try_to_unmap_file(struct page
 			max_nl_size = cursor;
 	}
 
-	if (max_nl_size == 0) {	/* any nonlinears locked or reserved */
+	if (max_nl_size == 0) {	/* all nonlinears locked or reserved ? */
 		ret = SWAP_FAIL;
 		goto out;
 	}
@@ -970,12 +1120,16 @@ static int try_to_unmap_file(struct page
 	do {
 		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-			if ((vma->vm_flags & VM_LOCKED) && !migration)
+			if (!MLOCK_PAGES && !migration &&
+			    (vma->vm_flags & VM_LOCKED))
 				continue;
 			cursor = (unsigned long) vma->vm_private_data;
 			while ( cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
-				try_to_unmap_cluster(cursor, &mapcount, vma);
+				ret = try_to_unmap_cluster(cursor, &mapcount,
+								vma, page);
+				if (ret == SWAP_MLOCK)
+					mlocked = 2;	/* to return below */
 				cursor += CLUSTER_SIZE;
 				vma->vm_private_data = (void *) cursor;
 				if ((int)mapcount <= 0)
@@ -996,6 +1150,10 @@ static int try_to_unmap_file(struct page
 		vma->vm_private_data = NULL;
 out:
 	spin_unlock(&mapping->i_mmap_lock);
+	if (mlocked)
+		ret = SWAP_MLOCK;	/* actually mlocked the page */
+	else if (ret == SWAP_MLOCK)
+		ret = SWAP_AGAIN;	/* saw VM_LOCKED vma */
 	return ret;
 }
 
@@ -1011,6 +1169,7 @@ out:
  * SWAP_SUCCESS	- we succeeded in removing all mappings
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
+ * SWAP_MLOCK	- page is mlocked.
  */
 int try_to_unmap(struct page *page, int migration)
 {
@@ -1019,12 +1178,33 @@ int try_to_unmap(struct page *page, int 
 	BUG_ON(!PageLocked(page));
 
 	if (PageAnon(page))
-		ret = try_to_unmap_anon(page, migration);
+		ret = try_to_unmap_anon(page, 0, migration);
 	else
-		ret = try_to_unmap_file(page, migration);
-
-	if (!page_mapped(page))
+		ret = try_to_unmap_file(page, 0, migration);
+	if (ret != SWAP_MLOCK && !page_mapped(page))
 		ret = SWAP_SUCCESS;
 	return ret;
 }
 
+#ifdef CONFIG_NORECLAIM_MLOCK
+/**
+ * try_to_unlock - Check page's rmap for other vma's holding page locked.
+ * @page: the page to be unlocked.   will be returned with PG_mlocked
+ * cleared if no vmas are VM_LOCKED.
+ *
+ * Return values are:
+ *
+ * SWAP_SUCCESS	- no vma's holding page locked.
+ * SWAP_AGAIN	- page mapped in mlocked vma -- couldn't acquire mmap sem
+ * SWAP_MLOCK	- page is now mlocked.
+ */
+int try_to_unlock(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
+
+	if (PageAnon(page))
+		return try_to_unmap_anon(page, 1, 0);
+	else
+		return try_to_unmap_file(page, 1, 0);
+}
+#endif
Index: linux-2.6.26-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/migrate.c	2008-06-06 16:05:15.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/migrate.c	2008-06-06 16:06:28.000000000 -0400
@@ -359,6 +359,8 @@ static void migrate_page_copy(struct pag
 		__set_page_dirty_nobuffers(newpage);
  	}
 
+	mlock_migrate_page(newpage, page);
+
 #ifdef CONFIG_SWAP
 	ClearPageSwapCache(page);
 #endif
Index: linux-2.6.26-rc2-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/page_alloc.c	2008-06-06 16:05:57.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/page_alloc.c	2008-06-06 16:06:28.000000000 -0400
@@ -258,6 +258,9 @@ static void bad_page(struct page *page)
 			1 << PG_active	|
 #ifdef CONFIG_NORECLAIM_LRU
 			1 << PG_noreclaim	|
+#ifdef CONFIG_NORECLAIM_MLOCK
+			1 << PG_mlocked |
+#endif
 #endif
 			1 << PG_dirty	|
 			1 << PG_reclaim |
@@ -497,6 +500,9 @@ static inline int free_pages_check(struc
 #ifdef CONFIG_NORECLAIM_LRU
 			1 << PG_noreclaim |
 #endif
+#ifdef CONFIG_NORECLAIM_MLOCK
+			1 << PG_mlocked |
+#endif
 			1 << PG_buddy ))))
 		bad_page(page);
 	if (PageDirty(page))
@@ -650,6 +656,9 @@ static int prep_new_page(struct page *pa
 			1 << PG_active	|
 #ifdef CONFIG_NORECLAIM_LRU
 			1 << PG_noreclaim	|
+#ifdef CONFIG_NORECLAIM_MLOCK
+			1 << PG_mlocked |
+#endif
 #endif
 			1 << PG_dirty	|
 			1 << PG_slab    |
@@ -669,7 +678,11 @@ static int prep_new_page(struct page *pa
 
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_reclaim |
 			1 << PG_referenced | 1 << PG_arch_1 |
-			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
+			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk
+#ifdef CONFIG_NORECLAIM_MLOCK
+			| 1 << PG_mlocked
+#endif
+			);
 	set_page_private(page, 0);
 	set_page_refcounted(page);
 
Index: linux-2.6.26-rc2-mm1/mm/swap.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/swap.c	2008-06-06 16:05:15.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/swap.c	2008-06-06 16:06:28.000000000 -0400
@@ -307,7 +307,7 @@ void lru_add_drain(void)
 	put_cpu();
 }
 
-#ifdef CONFIG_NUMA
+#if defined(CONFIG_NUMA) || defined(CONFIG_NORECLAIM_MLOCK)
 static void lru_add_drain_per_cpu(struct work_struct *dummy)
 {
 	lru_add_drain();
Index: linux-2.6.26-rc2-mm1/mm/memory.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/memory.c	2008-05-23 14:21:34.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/memory.c	2008-06-06 16:06:28.000000000 -0400
@@ -61,6 +61,8 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 
+#include "internal.h"
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
@@ -1734,6 +1736,15 @@ gotten:
 	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
 	if (!new_page)
 		goto oom;
+	/*
+	 * Don't let another task, with possibly unlocked vma,
+	 * keep the mlocked page.
+	 */
+	if (vma->vm_flags & VM_LOCKED) {
+		lock_page(old_page);	/* for LRU manipulation */
+		clear_page_mlock(old_page);
+		unlock_page(old_page);
+	}
 	cow_user_page(new_page, old_page, address, vma);
 	__SetPageUptodate(new_page);
 
@@ -2176,7 +2187,7 @@ static int do_swap_page(struct mm_struct
 	page_add_anon_rmap(page, vma, address);
 
 	swap_free(entry);
-	if (vm_swap_full())
+	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
 		remove_exclusive_swap_page(page);
 	unlock_page(page);
 
@@ -2316,6 +2327,12 @@ static int __do_fault(struct mm_struct *
 				ret = VM_FAULT_OOM;
 				goto out;
 			}
+			/*
+			 * Don't let another task, with possibly unlocked vma,
+			 * keep the mlocked page.
+			 */
+			if (vma->vm_flags & VM_LOCKED)
+				clear_page_mlock(vmf.page);
 			copy_user_highpage(page, vmf.page, address, vma);
 			__SetPageUptodate(page);
 		} else {
Index: linux-2.6.26-rc2-mm1/mm/mmap.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/mmap.c	2008-05-15 11:20:57.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/mmap.c	2008-06-06 16:06:28.000000000 -0400
@@ -652,7 +652,6 @@ again:			remove_next = 1 + (end > next->
  * If the vma has a ->close operation then the driver probably needs to release
  * per-vma resources, so we don't attempt to merge those.
  */
-#define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_RESERVED | VM_PFNMAP)
 
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
 			struct file *file, unsigned long vm_flags)
Index: linux-2.6.26-rc2-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.26-rc2-mm1.orig/include/linux/mm.h	2008-06-06 16:06:24.000000000 -0400
+++ linux-2.6.26-rc2-mm1/include/linux/mm.h	2008-06-06 16:06:28.000000000 -0400
@@ -126,6 +126,11 @@ extern unsigned int kobjsize(const void 
 #define VM_RandomReadHint(v)		((v)->vm_flags & VM_RAND_READ)
 
 /*
+ * special vmas that are non-mergable, non-mlock()able
+ */
+#define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_RESERVED | VM_PFNMAP)
+
+/*
  * mapping from the currently active vm_flags protection bits (the
  * low four bits) to a page protection mask..
  */

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
