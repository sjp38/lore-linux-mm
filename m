Date: Tue, 15 Jul 2008 04:19:07 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH 5/9] mlock-mlocked-pages-are-unevictable.patch
In-Reply-To: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080715041349.F6FE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Patch name: mlock-mlocked-pages-are-unevictable.patch
Against: mmotm Jul 14


unevictable-lru-infrastructure-putback_lru_page-rework.patch and unevictable-lru-infrastructure-kill-unnecessary-lock_page.patch
makes following patch failure.
So, remove its hunk. (latter patch restore it)

	----------------------------------------
	@@ -570,11 +570,8 @@ static unsigned long shrink_page_list(st
	
	                sc->nr_scanned++;
	
	-               if (unlikely(!page_evictable(page, NULL))) {
	-                       if (putback_lru_page(page))
	-                               unlock_page(page);
	-                       continue;
	-               }
	+               if (unlikely(!page_evictable(page, NULL)))
	+                       goto cull_mlocked;
	
	                if (!sc->may_swap && page_mapped(page))
	                        goto keep_locked;
	----------------------------------


==========================================
From: Nick Piggin <npiggin@suse.de>

Make sure that mlocked pages also live on the unevictable LRU, so kswapd
will not scan them over and over again.

This is achieved through various strategies:

1) add yet another page flag--PG_mlocked--to indicate that
   the page is locked for efficient testing in vmscan and,
   optionally, fault path.  This allows early culling of
   unevictable pages, preventing them from getting to
   page_referenced()/try_to_unmap().  Also allows separate
   accounting of mlock'd pages, as Nick's original patch
   did.

   Note:  Nick's original mlock patch used a PG_mlocked
   flag.  I had removed this in favor of the PG_unevictable
   flag + an mlock_count [new page struct member].  I
   restored the PG_mlocked flag to eliminate the new
   count field.

2) add the mlock/unevictable infrastructure to mm/mlock.c,
   with internal APIs in mm/internal.h.  This is a rework
   of Nick's original patch to these files, taking into
   account that mlocked pages are now kept on unevictable
   LRU list.

3) update vmscan.c:page_evictable() to check PageMlocked()
   and, if vma passed in, the vm_flags.  Note that the vma
   will only be passed in for new pages in the fault path;
   and then only if the "cull unevictable pages in fault
   path" patch is included.

4) add try_to_unlock() to rmap.c to walk a page's rmap and
   ClearPageMlocked() if no other vmas have it mlocked.
   Reuses as much of try_to_unmap() as possible.  This
   effectively replaces the use of one of the lru list links
   as an mlock count.  If this mechanism let's pages in mlocked
   vmas leak through w/o PG_mlocked set [I don't know that it
   does], we should catch them later in try_to_unmap().  One
   hopes this will be rare, as it will be relatively expensive.

5) Kosaki:  added munlock page table walk to avoid using
   get_user_pages() for unlock.  get_user_pages() is unreliable
   for some vma protections.
   Lee:  modified to wait for in-flight migration to complete
   to close munlock/migration race that could strand pages.

Original mm/internal.h, mm/rmap.c and mm/mlock.c changes:
Signed-off-by: Nick Piggin <npiggin@suse.de>

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mm.h         |    5 
 include/linux/page-flags.h |   11 +
 include/linux/rmap.h       |   14 +
 mm/internal.h              |   63 +++++++
 mm/memory.c                |   19 ++
 mm/migrate.c               |    2 
 mm/mlock.c                 |  382 ++++++++++++++++++++++++++++++++++++++++++---
 mm/mmap.c                  |    2 
 mm/page_alloc.c            |    6 
 mm/rmap.c                  |  257 +++++++++++++++++++++++++-----
 mm/swap.c                  |    2 
 mm/vmscan.c                |   29 ++-
 12 files changed, 727 insertions(+), 65 deletions(-)

Index: b/include/linux/mm.h
===================================================================
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -130,6 +130,11 @@ extern unsigned int kobjsize(const void 
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
Index: b/include/linux/page-flags.h
===================================================================
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -96,6 +96,7 @@ enum pageflags {
 	PG_swapbacked,		/* Page is backed by RAM/swap */
 #ifdef CONFIG_UNEVICTABLE_LRU
 	PG_unevictable,		/* Page is "unevictable"  */
+	PG_mlocked,		/* Page is vma mlocked */
 #endif
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 	PG_uncached,		/* Page has been mapped as uncached */
@@ -232,7 +233,17 @@ PAGEFLAG_FALSE(SwapCache)
 #ifdef CONFIG_UNEVICTABLE_LRU
 PAGEFLAG(Unevictable, unevictable) __CLEARPAGEFLAG(Unevictable, unevictable)
 	TESTCLEARFLAG(Unevictable, unevictable)
+
+#define MLOCK_PAGES 1
+PAGEFLAG(Mlocked, mlocked) __CLEARPAGEFLAG(Mlocked, mlocked)
+	TESTSCFLAG(Mlocked, mlocked)
+
 #else
+
+#define MLOCK_PAGES 0
+PAGEFLAG_FALSE(Mlocked)
+	SETPAGEFLAG_NOOP(Mlocked) TESTCLEARFLAG_FALSE(Mlocked)
+
 PAGEFLAG_FALSE(Unevictable) TESTCLEARFLAG_FALSE(Unevictable)
 	SETPAGEFLAG_NOOP(Unevictable) CLEARPAGEFLAG_NOOP(Unevictable)
 	__CLEARPAGEFLAG_NOOP(Unevictable)
Index: b/include/linux/rmap.h
===================================================================
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -117,6 +117,19 @@ unsigned long page_address_in_vma(struct
  */
 int page_mkclean(struct page *);
 
+#ifdef CONFIG_UNEVICTABLE_LRU
+/*
+ * called in munlock()/munmap() path to check for other vmas holding
+ * the page mlocked.
+ */
+int try_to_munlock(struct page *);
+#else
+static inline int try_to_munlock(struct page *page)
+{
+	return 0;	/* a.k.a. SWAP_SUCCESS */
+}
+#endif
+
 #else	/* !CONFIG_MMU */
 
 #define anon_vma_init()		do {} while (0)
@@ -140,5 +153,6 @@ static inline int page_mkclean(struct pa
 #define SWAP_SUCCESS	0
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
+#define SWAP_MLOCK	3
 
 #endif	/* _LINUX_RMAP_H */
Index: b/mm/internal.h
===================================================================
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -61,6 +61,10 @@ static inline unsigned long page_order(s
 	return page_private(page);
 }
 
+extern int mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end);
+extern void munlock_vma_pages_all(struct vm_area_struct *vma);
+
 #ifdef CONFIG_UNEVICTABLE_LRU
 /*
  * unevictable_migrate_page() called only from migrate_page_copy() to
@@ -79,6 +83,65 @@ static inline void unevictable_migrate_p
 }
 #endif
 
+#ifdef CONFIG_UNEVICTABLE_LRU
+/*
+ * Called only in fault path via page_evictable() for a new page
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
+#else /* CONFIG_UNEVICTABLE_LRU */
+static inline int is_mlocked_vma(struct vm_area_struct *v, struct page *p)
+{
+	return 0;
+}
+static inline void clear_page_mlock(struct page *page) { }
+static inline void mlock_vma_page(struct page *page) { }
+static inline void mlock_migrate_page(struct page *new, struct page *old) { }
+
+#endif /* CONFIG_UNEVICTABLE_LRU */
 
 /*
  * FLATMEM and DISCONTIGMEM configurations use alloc_bootmem_node,
Index: b/mm/memory.c
===================================================================
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -64,6 +64,8 @@
 
 #include "internal.h"
 
+#include "internal.h"
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
@@ -1859,6 +1861,15 @@ gotten:
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
 
@@ -2326,7 +2337,7 @@ static int do_swap_page(struct mm_struct
 	page_add_anon_rmap(page, vma, address);
 
 	swap_free(entry);
-	if (vm_swap_full())
+	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
 		remove_exclusive_swap_page(page);
 	unlock_page(page);
 
@@ -2466,6 +2477,12 @@ static int __do_fault(struct mm_struct *
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
Index: b/mm/migrate.c
===================================================================
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -377,6 +377,8 @@ static void migrate_page_copy(struct pag
 		__set_page_dirty_nobuffers(newpage);
  	}
 
+	mlock_migrate_page(newpage, page);
+
 #ifdef CONFIG_SWAP
 	if (PageSwapCache(page)) {
 		ClearPageSwapCache(page);
Index: b/mm/mlock.c
===================================================================
--- a/mm/mlock.c
+++ b/mm/mlock.c
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
@@ -23,17 +31,350 @@ int can_do_mlock(void)
 }
 EXPORT_SYMBOL(can_do_mlock);
 
+#ifdef CONFIG_UNEVICTABLE_LRU
+/*
+ * Mlocked pages are marked with PageMlocked() flag for efficient testing
+ * in vmscan and, possibly, the fault path; and to support semi-accurate
+ * statistics.
+ *
+ * An mlocked page [PageMlocked(page)] is unevictable.  As such, it will
+ * be placed on the LRU "unevictable" list, rather than the [in]active lists.
+ * The unevictable list is an LRU sibling list to the [in]active lists.
+ * PageUnevictable is set to indicate the unevictable state.
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
+	VM_BUG_ON(!PageLocked(page));	/* for LRU isolate/putback */
+
+	if (!isolate_lru_page(page)) {
+		putback_lru_page(page);
+	} else {
+		/*
+		 * Page not on the LRU yet.  Flush all pagevecs and retry.
+		 */
+		lru_add_drain_all();
+		if (!isolate_lru_page(page))
+			putback_lru_page(page);
+	}
+}
+
+/*
+ * Mark page as mlocked if not already.
+ * If page on LRU, isolate and putback to move to unevictable list.
+ */
+void mlock_vma_page(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+
+	if (!TestSetPageMlocked(page) && !isolate_lru_page(page))
+		putback_lru_page(page);
+}
+
+/*
+ * called from munlock()/munmap() path with page supposedly on the LRU.
+ *
+ * Note:  unlike mlock_vma_page(), we can't just clear the PageMlocked
+ * [in try_to_munlock()] and then attempt to isolate the page.  We must
+ * isolate the page to keep others from messing with its unevictable
+ * and mlocked state while trying to munlock.  However, we pre-clear the
+ * mlocked state anyway as we might lose the isolation race and we might
+ * not get another chance to clear PageMlocked.  If we successfully
+ * isolate the page and try_to_munlock() detects other VM_LOCKED vmas
+ * mapping the page, it will restore the PageMlocked state, unless the page
+ * is mapped in a non-linear vma.  So, we go ahead and SetPageMlocked(),
+ * perhaps redundantly.
+ * If we lose the isolation race, and the page is mapped by other VM_LOCKED
+ * vmas, we'll detect this in vmscan--via try_to_munlock() or try_to_unmap()
+ * either of which will restore the PageMlocked state by calling
+ * mlock_vma_page() above, if it can grab the vma's mmap sem.
+ */
+static void munlock_vma_page(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+
+	if (TestClearPageMlocked(page) && !isolate_lru_page(page)) {
+		try_to_munlock(page);
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
+	walk_page_range(mm, start, end, &munlock_page_walk, &mpw);
+	lru_add_drain_all();	/* to update stats */
+}
+
+#else /* CONFIG_UNEVICTABLE_LRU */
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
+#endif /* CONFIG_UNEVICTABLE_LRU */
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
+	if (!((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
+			is_vm_hugetlb_page(vma) ||
+			vma == get_gate_vma(current)))
+		return __mlock_vma_pages_range(vma, start, end);
+
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
@@ -44,8 +385,6 @@ static int mlock_fixup(struct vm_area_st
 		goto success;
 	}
 
-	*prev = vma;
-
 	if (start != vma->vm_start) {
 		ret = split_vma(mm, vma, start, 1);
 		if (ret)
@@ -60,24 +399,31 @@ static int mlock_fixup(struct vm_area_st
 
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
Index: b/mm/mmap.c
===================================================================
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -662,8 +662,6 @@ again:			remove_next = 1 + (end > next->
  * If the vma has a ->close operation then the driver probably needs to release
  * per-vma resources, so we don't attempt to merge those.
  */
-#define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_RESERVED | VM_PFNMAP)
-
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
 			struct file *file, unsigned long vm_flags)
 {
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -613,7 +613,11 @@ static int prep_new_page(struct page *pa
 
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_reclaim |
 			1 << PG_referenced | 1 << PG_arch_1 |
-			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
+			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk
+#ifdef CONFIG_UNEVICTABLE_LRU
+			| 1 << PG_mlocked
+#endif
+			);
 	set_page_private(page, 0);
 	set_page_refcounted(page);
 
Index: b/mm/rmap.c
===================================================================
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -53,6 +53,8 @@
 
 #include <asm/tlbflush.h>
 
+#include "internal.h"
+
 struct kmem_cache *anon_vma_cachep;
 
 /* This must be called under the mmap_sem. */
@@ -264,6 +266,32 @@ pte_t *page_check_address(struct page *p
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
@@ -285,10 +313,17 @@ static int page_referenced_one(struct pa
 	if (!pte)
 		goto out;
 
+	/*
+	 * Don't want to elevate referenced for mlocked page that gets this far,
+	 * in order that it progresses to try_to_unmap and is moved to the
+	 * unevictable list.
+	 */
 	if (vma->vm_flags & VM_LOCKED) {
-		referenced++;
 		*mapcount = 1;	/* break early from loop */
-	} else if (ptep_clear_flush_young_notify(vma, address, pte))
+		goto out_unmap;
+	}
+
+	if (ptep_clear_flush_young_notify(vma, address, pte))
 		referenced++;
 
 	/* Pretend the page is referenced if the task has the
@@ -297,6 +332,7 @@ static int page_referenced_one(struct pa
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced++;
 
+out_unmap:
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
 out:
@@ -386,11 +422,6 @@ static int page_referenced_file(struct p
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
@@ -705,11 +736,16 @@ static int try_to_unmap_one(struct page 
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
 	 */
-	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young_notify(vma, address, pte)))) {
-		ret = SWAP_FAIL;
-		goto out_unmap;
-	}
+	if (!migration) {
+		if (vma->vm_flags & VM_LOCKED) {
+			ret = SWAP_MLOCK;
+			goto out_unmap;
+		}
+		if (ptep_clear_flush_young_notify(vma, address, pte)) {
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
+  	}
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
@@ -790,12 +826,17 @@ out:
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
@@ -807,6 +848,8 @@ static void try_to_unmap_cluster(unsigne
 	struct page *page;
 	unsigned long address;
 	unsigned long end;
+	int ret = SWAP_AGAIN;
+	int locked_vma = 0;
 
 	address = (vma->vm_start + cursor) & CLUSTER_MASK;
 	end = address + CLUSTER_SIZE;
@@ -817,15 +860,26 @@ static void try_to_unmap_cluster(unsigne
 
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
 
@@ -838,6 +892,13 @@ static void try_to_unmap_cluster(unsigne
 		page = vm_normal_page(vma, address, *pte);
 		BUG_ON(!page || PageAnon(page));
 
+		if (locked_vma) {
+			mlock_vma_page(page);   /* no-op if already mlocked */
+			if (page == check_page)
+				ret = SWAP_MLOCK;
+			continue;	/* don't unmap */
+		}
+
 		if (ptep_clear_flush_young_notify(vma, address, pte))
 			continue;
 
@@ -859,39 +920,104 @@ static void try_to_unmap_cluster(unsigne
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
+ * This function is only called from try_to_unmap/try_to_munlock for
+ * anonymous pages.
+ * When called from try_to_munlock(), the mmap_sem of the mm containing the vma
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
+		ret = SWAP_SUCCESS;	/* default for try_to_munlock() */
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
+ * This function is only called from try_to_unmap/try_to_munlock for
+ * object-based pages.
+ * When called from try_to_munlock(), the mmap_sem of the mm containing the vma
+ * where the page was found will be held for write.  So, we won't recheck
+ * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
+ * 'LOCKED.
  */
-static int try_to_unmap_file(struct page *page, int migration)
+static int try_to_unmap_file(struct page *page, int unlock, int migration)
 {
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -902,20 +1028,44 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
+	unsigned int mlocked = 0;
+
+	if (MLOCK_PAGES && unlikely(unlock))
+		ret = SWAP_SUCCESS;	/* default for try_to_munlock() */
 
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
@@ -925,7 +1075,7 @@ static int try_to_unmap_file(struct page
 			max_nl_size = cursor;
 	}
 
-	if (max_nl_size == 0) {	/* any nonlinears locked or reserved */
+	if (max_nl_size == 0) {	/* all nonlinears locked or reserved ? */
 		ret = SWAP_FAIL;
 		goto out;
 	}
@@ -949,12 +1099,16 @@ static int try_to_unmap_file(struct page
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
@@ -975,6 +1129,10 @@ static int try_to_unmap_file(struct page
 		vma->vm_private_data = NULL;
 out:
 	spin_unlock(&mapping->i_mmap_lock);
+	if (mlocked)
+		ret = SWAP_MLOCK;	/* actually mlocked the page */
+	else if (ret == SWAP_MLOCK)
+		ret = SWAP_AGAIN;	/* saw VM_LOCKED vma */
 	return ret;
 }
 
@@ -990,6 +1148,7 @@ out:
  * SWAP_SUCCESS	- we succeeded in removing all mappings
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
+ * SWAP_MLOCK	- page is mlocked.
  */
 int try_to_unmap(struct page *page, int migration)
 {
@@ -998,12 +1157,36 @@ int try_to_unmap(struct page *page, int 
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
 
+#ifdef CONFIG_UNEVICTABLE_LRU
+/**
+ * try_to_munlock - try to munlock a page
+ * @page: the page to be munlocked
+ *
+ * Called from munlock code.  Checks all of the VMAs mapping the page
+ * to make sure nobody else has this page mlocked. The page will be
+ * returned with PG_mlocked cleared if no other vmas have it mlocked.
+ *
+ * Return values are:
+ *
+ * SWAP_SUCCESS	- no vma's holding page mlocked.
+ * SWAP_AGAIN	- page mapped in mlocked vma -- couldn't acquire mmap sem
+ * SWAP_MLOCK	- page is now mlocked.
+ */
+int try_to_munlock(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
+
+	if (PageAnon(page))
+		return try_to_unmap_anon(page, 1, 0);
+	else
+		return try_to_unmap_file(page, 1, 0);
+}
+#endif
Index: b/mm/swap.c
===================================================================
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -278,7 +278,7 @@ void lru_add_drain(void)
 	put_cpu();
 }
 
-#ifdef CONFIG_NUMA
+#if defined(CONFIG_NUMA) || defined(CONFIG_UNEVICTABLE_LRU)
 static void lru_add_drain_per_cpu(struct work_struct *dummy)
 {
 	lru_add_drain();
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -619,9 +619,19 @@ static unsigned long shrink_page_list(st
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page))
+		if (PageAnon(page) && !PageSwapCache(page)) {
+			switch (try_to_munlock(page)) {
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
@@ -636,6 +646,8 @@ static unsigned long shrink_page_list(st
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
+			case SWAP_MLOCK:
+				goto cull_mlocked;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -726,6 +738,11 @@ free_it:
 		}
 		continue;
 
+cull_mlocked:
+		if (putback_lru_page(page))
+			unlock_page(page);
+		continue;
+
 activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
 		if (PageSwapCache(page) && vm_swap_full())
@@ -737,7 +754,7 @@ keep_locked:
 		unlock_page(page);
 keep:
 		list_add(&page->lru, &ret_pages);
-		VM_BUG_ON(PageLRU(page));
+		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 	list_splice(&ret_pages, page_list);
 	if (pagevec_count(&freed_pvec))
@@ -2360,12 +2377,13 @@ int zone_reclaim(struct zone *zone, gfp_
  * @vma: the VMA in which the page is or will be mapped, may be NULL
  *
  * Test whether page is evictable--i.e., should be placed on active/inactive
- * lists vs unevictable list.
+ * lists vs unevictable list.  The vma argument is !NULL when called from the
+ * fault path to determine how to instantate a new page.
  *
  * Reasons page might not be evictable:
  * (1) page's mapping marked unevictable
+ * (2) page is part of an mlocked VMA
  *
- * TODO - later patches
  */
 int page_evictable(struct page *page, struct vm_area_struct *vma)
 {
@@ -2373,7 +2391,8 @@ int page_evictable(struct page *page, st
 	if (mapping_unevictable(page_mapping(page)))
 		return 0;
 
-	/* TODO:  test page [!]evictable conditions */
+	if (PageMlocked(page) || (vma && is_mlocked_vma(vma, page)))
+		return 0;
 
 	return 1;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
