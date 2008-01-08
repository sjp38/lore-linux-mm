Message-Id: <20080108210013.474149527@redhat.com>
References: <20080108205939.323955454@redhat.com>
Date: Tue, 08 Jan 2008 15:59:54 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 15/19] non-reclaimable mlocked pages
Content-Disposition: inline; filename=noreclaim-04.1-prepare-for-mlocked-pages.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split lru series
+ fix page flags macros for *PageMlocked() when not configured.
+ ensure lru_add_drain_all() runs on all cpus when NORECLIM_MLOCK
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

Rework of a patch by Nick Piggin -- part 1 of 2.

This patch:

1) defines the [CONFIG_]NORECLAIM_MLOCK sub-option and the
   stub version of the mlock/noreclaim APIs when it's
   not configured.  Depends on [CONFIG_]NORECLAIM.

2) add yet another page flag--PG_mlocked--to indicate that
   the page is locked for efficient testing in vmscan and,
   optionally, fault path.  This allows early culling of
   nonreclaimable pages, preventing them from getting to
   page_referenced()/try_to_unmap().  Also allows separate
   accounting of mlock'd pages, as Nick's original patch
   did.

   Uses a bit available only to 64-bit systems.

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

mm/internal.h and mm/mlock.c changes:
Originally Signed-off-by: Nick Piggin <npiggin@suse.de>

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by:  Rik van Riel <riel@redhat.com>


Index: linux-2.6.24-rc6-mm1/mm/Kconfig
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/Kconfig	2008-01-08 12:17:10.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/Kconfig	2008-01-08 12:17:30.000000000 -0500
@@ -203,3 +203,17 @@ config NORECLAIM
 	  may be non-reclaimable because:  they are locked into memory, they
 	  are anonymous pages for which no swap space exists, or they are anon
 	  pages that are expensive to unmap [long anon_vma "related vma" list.]
+
+config NORECLAIM_MLOCK
+	bool "Exclude mlock'ed pages from reclaim"
+	depends on NORECLAIM
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
Index: linux-2.6.24-rc6-mm1/mm/internal.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/internal.h	2008-01-08 12:08:02.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/internal.h	2008-01-08 12:17:30.000000000 -0500
@@ -39,6 +39,64 @@ extern int isolate_lru_page(struct page 
 extern void __init __free_pages_bootmem(struct page *page,
 						unsigned int order);
 
+#ifdef CONFIG_NORECLAIM_MLOCK
+/*
+ * in mm/vmscan.c -- currently only used for NORECLAIM_MLOCK
+ */
+extern void putback_lru_page(struct page *page);
+
+/*
+ * called only for new pages in fault path
+ */
+extern int is_mlocked_vma(struct vm_area_struct *, struct page *);
+
+/*
+ * must be called with vma's mmap_sem held for read, and page locked.
+ */
+extern void mlock_vma_page(struct page *page);
+
+extern int __mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end, int lock);
+
+/*
+ * mlock all pages in this vma range.  For mmap()/mremap()/...
+ */
+static inline void mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+	__mlock_vma_pages_range(vma, start, end, 1);
+}
+
+/*
+ * munlock range of pages.   For munmap() and exit().
+ * Always called to operate on a full vma that is being unmapped.
+ */
+static inline void munlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+// TODO:  verify my assumption.  Should we just drop the start/end args?
+	VM_BUG_ON(start != vma->vm_start || end != vma->vm_end);
+
+	vma->vm_flags &= ~VM_LOCKED;    /* try_to_unlock() needs this */
+	__mlock_vma_pages_range(vma, start, end, 0);
+}
+
+extern void clear_page_mlock(struct page *page);
+
+#else /* CONFIG_NORECLAIM_MLOCK */
+static inline int is_mlocked_vma(struct vm_area_struct *v, struct page *p)
+{
+	return 0;
+}
+static inline void clear_page_mlock(struct page *page) { }
+static inline void mlock_vma_page(struct page *page) { }
+static inline void mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end) { }
+static inline void munlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end) { }
+
+#endif /* CONFIG_NORECLAIM_MLOCK */
+
 /*
  * function for dealing with page's order in buddy system.
  * zone->lock is already acquired when we use these.
Index: linux-2.6.24-rc6-mm1/mm/mlock.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/mlock.c	2008-01-08 12:08:02.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/mlock.c	2008-01-08 12:17:30.000000000 -0500
@@ -8,10 +8,16 @@
 #include <linux/capability.h>
 #include <linux/mman.h>
 #include <linux/mm.h>
+#include <linux/swap.h>
+#include <linux/pagemap.h>
 #include <linux/mempolicy.h>
 #include <linux/syscalls.h>
 #include <linux/sched.h>
 #include <linux/module.h>
+#include <linux/rmap.h>
+#include <linux/mmzone.h>
+
+#include "internal.h"
 
 int can_do_mlock(void)
 {
@@ -23,19 +29,209 @@ int can_do_mlock(void)
 }
 EXPORT_SYMBOL(can_do_mlock);
 
+#ifdef CONFIG_NORECLAIM_MLOCK
+/*
+ * Mlocked pages are marked with PageMlocked() flag for efficient testing
+ * in vmscan and, possibly, the fault path.
+ *
+ * An mlocked page [PageMlocked(page)] is non-reclaimable.  As such, it will
+ * be placed on the LRU "noreclaim" list, rather than the [in]active lists.
+ * The noreclaim list is an LRU sibling list to the [in]active lists.
+ * PageNoreclaim is set to indicate the non-reclaimable state.
+ *
+//TODO:  no longer counting, but does this still apply to lazy setting
+// of PageMlocked() ??
+ * When lazy incrementing via vmscan, it is important to ensure that the
+ * vma's VM_LOCKED status is not concurrently being modified, otherwise we
+ * may have elevated mlock_count of a page that is being munlocked. So lazy
+ * mlocked must take the mmap_sem for read, and verify that the vma really
+ * is locked (see mm/rmap.c).
+ */
+
+/*
+ * Clear the page's PageMlocked().  This can be useful in a situation where
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
+	if (likely(!PageMlocked(page)))
+		return;
+	ClearPageMlocked(page);
+	if (!isolate_lru_page(page))
+		putback_lru_page(page);
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
+ * mapping the page, we just restore the PageMlocked state.  If we lose
+ * the isolation race, and the page is mapped by other VM_LOCKED vmas,
+ * we'll detect this in try_to_unmap() and we'll call mlock_vma_page()
+ * above, if/when we try to reclaim the page.
+ */
+static void munlock_vma_page(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+
+	if (TestClearPageMlocked(page) && !isolate_lru_page(page)) {
+		if (try_to_unlock(page) == SWAP_MLOCK)
+			SetPageMlocked(page);	/* still VM_LOCKED */
+		putback_lru_page(page);
+	}
+}
+
+/*
+ * Called in fault path via page_reclaimable() for a new page
+ * to determine if it's being mapped into a LOCKED vma.
+ * If so, mark page as mlocked.
+ */
+int is_mlocked_vma(struct vm_area_struct *vma, struct page *page)
+{
+	VM_BUG_ON(PageMlocked(page));	// TODO:  needed?
+	VM_BUG_ON(PageLRU(page));
+
+	if (likely(!(vma->vm_flags & VM_LOCKED)))
+		return 0;
+
+	SetPageMlocked(page);
+	return 1;
+}
+
+/*
+ * mlock or munlock a range of pages in the vma depending on whether
+ * @lock is 1 or 0, respectively.  @lock must match vm_flags VM_LOCKED
+ * state.
+TODO:   we don't really need @lock, as we can determine it from vm_flags
+ *
+ * This takes care of making the pages present too.
+ *
+ * vma->vm_mm->mmap_sem must be held for write.
+ */
+int __mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end, int lock)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long addr = start;
+	struct page *pages[16]; /* 16 gives a reasonable batch */
+	int write = !!(vma->vm_flags & VM_WRITE);
+	int nr_pages;
+	int ret = 0;
+
+	BUG_ON(start & ~PAGE_MASK || end & ~PAGE_MASK);
+	VM_BUG_ON(lock != !!(vma->vm_flags & VM_LOCKED));
+
+	if (vma->vm_flags & VM_IO)
+		return ret;
+
+	lru_add_drain_all();	/* push cached pages to LRU */
+
+	nr_pages = (end - start) / PAGE_SIZE;
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
+		lru_add_drain();	/* push cached pages to LRU */
+
+		for (i = 0; i < ret; i++) {
+			struct page *page = pages[i];
+
+			lock_page(page);
+			if (lock)
+				mlock_vma_page(page);
+			else
+				munlock_vma_page(page);
+			unlock_page(page);
+			put_page(page);		/* ref from get_user_pages() */
+
+			addr += PAGE_SIZE;	/* for next get_user_pages() */
+			nr_pages--;
+		}
+	}
+
+	lru_add_drain_all();	/* to update stats */
+
+	return ret;
+}
+
+#else /* CONFIG_NORECLAIM_MLOCK */
+
+/*
+ * Just make pages present if @lock true.  No-op if unlocking.
+ */
+int __mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end, int lock)
+{
+	int ret = 0;
+
+	if (!lock || vma->vm_flags & VM_IO)
+		return ret;
+
+	return make_pages_present(start, end);
+}
+#endif /* CONFIG_NORECLAIM_MLOCK */
+
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
 		goto out;
 	}
 
+//TODO:  linear_page_index() ?   non-linear pages?
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
 			  vma->vm_file, pgoff, vma_policy(vma));
@@ -59,24 +255,25 @@ static int mlock_fixup(struct vm_area_st
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
Index: linux-2.6.24-rc6-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmscan.c	2008-01-08 12:17:25.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmscan.c	2008-01-08 12:17:30.000000000 -0500
@@ -887,6 +887,44 @@ int isolate_lru_page(struct page *page)
 	return ret;
 }
 
+#ifdef CONFIG_NORECLAIM_MLOCK
+/**
+ * putback_lru_page(@page)
+ *
+ * Add previously isolated @page to appropriate LRU list.
+ * Page may still be non-reclaimable for other reasons.
+ *
+ * The vmstat page counts corresponding to the list on which the page
+ * will be placed will be incremented.
+ *
+ * lru_lock must not be held, interrupts must be enabled.
+ */
+void putback_lru_page(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	int lru = LRU_INACTIVE_ANON;
+
+	VM_BUG_ON(PageLRU(page));
+
+	ClearPageNoreclaim(page);
+	ClearPageActive(page);
+
+	spin_lock_irq(&zone->lru_lock);
+	if (page_reclaimable(page, NULL)) {
+		lru += page_file_cache(page);
+	} else {
+		lru = LRU_NORECLAIM;
+		SetPageNoreclaim(page);
+	}
+
+	SetPageLRU(page);
+	add_page_to_lru_list(zone, page, lru);
+	put_page(page);		/* drop ref from isolate */
+
+	spin_unlock_irq(&zone->lru_lock);
+}
+#endif
+
 /*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
@@ -2255,10 +2293,11 @@ int zone_reclaim(struct zone *zone, gfp_
  *
  * @page       - page to test
  * @vma        - vm area in which page is/will be mapped.  May be NULL.
- *               If !NULL, called from fault path.
+ *               If !NULL, called from fault path for a new page.
  *
  * Reasons page might not be reclaimable:
- * + page's mapping marked non-reclaimable
+ * 1) page's mapping marked non-reclaimable
+ * 2) page is mlock'ed into memory.
  * TODO - later patches
  *
  * TODO:  specify locking assumptions
@@ -2271,6 +2310,11 @@ int page_reclaimable(struct page *page, 
 	if (mapping_non_reclaimable(page_mapping(page)))
 		return 0;
 
+#ifdef CONFIG_NORECLAIM_MLOCK
+	if (PageMlocked(page) || (vma && is_mlocked_vma(vma, page)))
+		return 0;
+#endif
+
 	/* TODO:  test page [!]reclaimable conditions */
 
 	return 1;
Index: linux-2.6.24-rc6-mm1/include/linux/page-flags.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/page-flags.h	2008-01-08 12:17:10.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/page-flags.h	2008-01-08 12:17:30.000000000 -0500
@@ -110,6 +110,7 @@
 #define PG_uncached		31	/* Page has been mapped as uncached */
 
 #define PG_noreclaim		30	/* Page is "non-reclaimable"  */
+#define PG_mlocked		29	/* Page is vma mlocked */
 #endif
 
 /*
@@ -163,6 +164,7 @@ static inline void SetPageUptodate(struc
 #define SetPageActive(page)	set_bit(PG_active, &(page)->flags)
 #define ClearPageActive(page)	clear_bit(PG_active, &(page)->flags)
 #define __ClearPageActive(page)	__clear_bit(PG_active, &(page)->flags)
+#define TestSetPageActive(page) test_and_set_bit(PG_active, &(page)->flags)
 #define TestClearPageActive(page) test_and_clear_bit(PG_active, &(page)->flags)
 
 #define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
@@ -270,8 +272,17 @@ static inline void __ClearPageTail(struc
 #define SetPageNoreclaim(page)	set_bit(PG_noreclaim, &(page)->flags)
 #define ClearPageNoreclaim(page) clear_bit(PG_noreclaim, &(page)->flags)
 #define __ClearPageNoreclaim(page) __clear_bit(PG_noreclaim, &(page)->flags)
-#define TestClearPageNoreclaim(page) test_and_clear_bit(PG_noreclaim, \
-							 &(page)->flags)
+#define TestClearPageNoreclaim(page) \
+				test_and_clear_bit(PG_noreclaim, &(page)->flags)
+#ifdef CONFIG_NORECLAIM_MLOCK
+#define PageMlocked(page)	test_bit(PG_mlocked, &(page)->flags)
+#define SetPageMlocked(page)	set_bit(PG_mlocked, &(page)->flags)
+#define ClearPageMlocked(page) clear_bit(PG_mlocked, &(page)->flags)
+#define __ClearPageMlocked(page) __clear_bit(PG_mlocked, &(page)->flags)
+#define TestSetPageMlocked(page) test_and_set_bit(PG_mlocked, &(page)->flags)
+#define TestClearPageMlocked(page) \
+				test_and_clear_bit(PG_mlocked, &(page)->flags)
+#endif
 #else
 #define PageNoreclaim(page)	0
 #define SetPageNoreclaim(page)
@@ -279,6 +290,14 @@ static inline void __ClearPageTail(struc
 #define __ClearPageNoreclaim(page)
 #define TestClearPageNoreclaim(page) 0
 #endif
+#ifndef CONFIG_NORECLAIM_MLOCK
+#define PageMlocked(page)	0
+#define SetPageMlocked(page)
+#define ClearPageMlocked(page)
+#define __ClearPageMlocked(page)
+#define TestSetPageMlocked(page) 0
+#define TestClearPageMlocked(page) 0
+#endif
 
 #define PageUncached(page)	test_bit(PG_uncached, &(page)->flags)
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
Index: linux-2.6.24-rc6-mm1/include/linux/rmap.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/rmap.h	2008-01-08 12:08:02.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/rmap.h	2008-01-08 12:17:30.000000000 -0500
@@ -109,6 +109,17 @@ unsigned long page_address_in_vma(struct
  */
 int page_mkclean(struct page *);
 
+#ifdef CONFIG_NORECLAIM_MLOCK
+/*
+ * called in munlock()/munmap() path to check for other vmas holding
+ * the page mlocked.
+ */
+int try_to_unlock(struct page *);
+#define TRY_TO_UNLOCK 1
+#else
+#define TRY_TO_UNLOCK 0		/* for compiler -- dead code elimination */
+#endif
+
 #else	/* !CONFIG_MMU */
 
 #define anon_vma_init()		do {} while (0)
@@ -132,5 +143,6 @@ static inline int page_mkclean(struct pa
 #define SWAP_SUCCESS	0
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
+#define SWAP_MLOCK	3
 
 #endif	/* _LINUX_RMAP_H */
Index: linux-2.6.24-rc6-mm1/mm/rmap.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/rmap.c	2008-01-08 12:08:02.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/rmap.c	2008-01-08 12:17:30.000000000 -0500
@@ -52,6 +52,8 @@
 
 #include <asm/tlbflush.h>
 
+#include "internal.h"
+
 struct kmem_cache *anon_vma_cachep;
 
 /* This must be called under the mmap_sem. */
@@ -284,10 +286,17 @@ static int page_referenced_one(struct pa
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
@@ -296,6 +305,7 @@ static int page_referenced_one(struct pa
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced++;
 
+out_unmap:
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
 out:
@@ -384,11 +394,6 @@ static int page_referenced_file(struct p
 		 */
 		if (mem_cont && (mm_cgroup(vma->vm_mm) != mem_cont))
 			continue;
-		if ((vma->vm_flags & (VM_LOCKED|VM_MAYSHARE))
-				  == (VM_LOCKED|VM_MAYSHARE)) {
-			referenced++;
-			break;
-		}
 		referenced += page_referenced_one(page, vma, &mapcount);
 		if (!mapcount)
 			break;
@@ -712,10 +717,15 @@ static int try_to_unmap_one(struct page 
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
@@ -797,6 +807,10 @@ out:
  * For very sparsely populated VMAs this is a little inefficient - chances are
  * there there won't be many ptes located within the scan cluster.  In this case
  * maybe we could scan further - to the end of the pte page, perhaps.
+ *
+TODO:  still accurate with noreclaim infrastructure?
+ * Mlocked pages also aren't handled very well at the moment: they aren't
+ * moved off the LRU like they are for linear pages.
  */
 #define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
 #define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
@@ -868,10 +882,28 @@ static void try_to_unmap_cluster(unsigne
 	pte_unmap_unlock(pte - 1, ptl);
 }
 
-static int try_to_unmap_anon(struct page *page, int migration)
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
 
 	anon_vma = page_lock_anon_vma(page);
@@ -879,25 +911,53 @@ static int try_to_unmap_anon(struct page
 		return ret;
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
-		ret = try_to_unmap_one(page, vma, migration);
+		if (TRY_TO_UNLOCK && unlikely(unlock)) {
+			if (!(vma->vm_flags & VM_LOCKED))
+				continue;	/* must visit all vmas */
+			mlocked++;
+			break;			/* no need to look further */
+		} else
+			ret = try_to_unmap_one(page, vma, migration);
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
 
 /**
- * try_to_unmap_file - unmap file page using the object-based rmap method
- * @page: the page to unmap
+ * try_to_unmap_file - unmap or unlock file page using the object-based
+ * rmap method
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
@@ -908,19 +968,46 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
+	unsigned int mlocked = 0;
 
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
-		ret = try_to_unmap_one(page, vma, migration);
+		if (TRY_TO_UNLOCK && unlikely(unlock)) {
+			if (!(vma->vm_flags & VM_LOCKED))
+				continue;	/* must visit all vmas */
+			mlocked++;
+			break;			/* no need to look further */
+		} else
+			ret = try_to_unmap_one(page, vma, migration);
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
+			if (unlikely(unlock))
+				break;  /* stop on 1st mlocked vma */
+		}
 	}
 
+	if (mlocked)
+		goto out;
+
 	if (list_empty(&mapping->i_mmap_nonlinear))
 		goto out;
 
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
+		if (TRY_TO_UNLOCK && unlikely(unlock)) {
+			if (!(vma->vm_flags & VM_LOCKED))
+				continue;	/* must visit all vmas */
+			mlocked++;
+			goto out;		/* no need to look further */
+		}
 		if ((vma->vm_flags & VM_LOCKED) && !migration)
 			continue;
 		cursor = (unsigned long) vma->vm_private_data;
@@ -955,8 +1042,6 @@ static int try_to_unmap_file(struct page
 	do {
 		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-			if ((vma->vm_flags & VM_LOCKED) && !migration)
-				continue;
 			cursor = (unsigned long) vma->vm_private_data;
 			while ( cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
@@ -981,6 +1066,10 @@ static int try_to_unmap_file(struct page
 		vma->vm_private_data = NULL;
 out:
 	spin_unlock(&mapping->i_mmap_lock);
+	if (mlocked)
+		ret = SWAP_MLOCK;
+	else if (ret == SWAP_MLOCK)
+		ret = SWAP_AGAIN;
 	return ret;
 }
 
@@ -995,6 +1084,7 @@ out:
  * SWAP_SUCCESS	- we succeeded in removing all mappings
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
+ * SWAP_MLOCK	- page is mlocked.
  */
 int try_to_unmap(struct page *page, int migration)
 {
@@ -1003,12 +1093,32 @@ int try_to_unmap(struct page *page, int 
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
+ * SWAP_MLOCK	- page is mlocked.
+ */
+int try_to_unlock(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
+
+	if (PageAnon(page))
+		return(try_to_unmap_anon(page, 1, 0));
+	else
+		return(try_to_unmap_file(page, 1, 0));
+}
+#endif
Index: linux-2.6.24-rc6-mm1/mm/migrate.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/migrate.c	2008-01-08 12:17:10.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/migrate.c	2008-01-08 12:17:30.000000000 -0500
@@ -366,6 +366,9 @@ static void migrate_page_copy(struct pag
 		set_page_dirty(newpage);
  	}
 
+	if (TestClearPageMlocked(page))
+		SetPageMlocked(newpage);
+
 #ifdef CONFIG_SWAP
 	ClearPageSwapCache(page);
 #endif
Index: linux-2.6.24-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/page_alloc.c	2008-01-08 12:17:14.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/page_alloc.c	2008-01-08 12:17:30.000000000 -0500
@@ -257,6 +257,7 @@ static void bad_page(struct page *page)
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_swapbacked |
+			1 << PG_mlocked |
 			1 << PG_buddy );
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
@@ -488,6 +489,9 @@ static inline int free_pages_check(struc
 #ifdef CONFIG_NORECLAIM
 			1 << PG_noreclaim |
 #endif
+// TODO:  always trip this under heavy workloads.
+//  Why isn't this being cleared on last unmap/unlock?
+//  			1 << PG_mlocked |
 			1 << PG_buddy ))))
 		bad_page(page);
 	if (PageDirty(page))
@@ -644,6 +648,8 @@ static int prep_new_page(struct page *pa
 			1 << PG_writeback |
 			1 << PG_reserved |
 			1 << PG_swapbacked |
+//TODO:  why hitting this?
+//			1 << PG_mlocked |
 			1 << PG_buddy ))))
 		bad_page(page);
 
@@ -656,7 +662,9 @@ static int prep_new_page(struct page *pa
 
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_readahead |
 			1 << PG_referenced | 1 << PG_arch_1 |
-			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
+			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk |
+//TODO take care of it here, for now.
+			1 << PG_mlocked );
 	set_page_private(page, 0);
 	set_page_refcounted(page);
 
Index: linux-2.6.24-rc6-mm1/mm/swap.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/swap.c	2008-01-08 12:17:10.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/swap.c	2008-01-08 12:17:30.000000000 -0500
@@ -346,7 +346,7 @@ void lru_add_drain(void)
 	put_cpu();
 }
 
-#ifdef CONFIG_NUMA
+#if defined(CONFIG_NUMA) || defined(CONFIG_NORECLAIM_MLOCK)
 static void lru_add_drain_per_cpu(struct work_struct *dummy)
 {
 	lru_add_drain();

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
