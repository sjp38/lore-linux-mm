From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:55:19 -0400
Message-Id: <20070914205519.6536.84023.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 12/14] Reclaim Scalability:  Non-reclaimable Mlock'ed pages
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

PATCH/RFC 12/14 Reclaim Scalability:  Non-reclaimable Mlock'ed pages

Against:  2.6.23-rc4-mm1

Rework of a patch by Nick Piggin -- part 1 of 2.

This patch:

1) defines the [CONFIG_]NORECLAIM_MLOCK sub-option and the
   stub version of the mlock/noreclaim APIs when it's
   not configured.  Depends on [CONFIG_]NORECLAIM.

2) add yet another page flag--PG_mlocked--to indicate that
   the page is locked for efficient testing in vmscan and,
   optionally, fault path.  This allows early culling of
   nonreclaimable pages, preventing them from getting to
   page_referenced()/try_to_unmap().

   Uses a bit available only to 64-bit systems.

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

Note: most of my recent testing of the noreclaim infrastructure
has been with mlocked pages.  I'm seeing gigabytes of memory
left nonreclaimable, according to my vmstats, when the tests
finish.  I don't know if this is just a statistics glitch, or
if I'm leaking mlocked pages.  Under investigation.

mm/internal.h and mm/mlock.c changes:
Originally Signed-off-by: Nick Piggin <npiggin@suse.de>

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/page-flags.h |   21 +++-
 include/linux/rmap.h       |   12 ++
 mm/Kconfig                 |   13 ++
 mm/internal.h              |   50 +++++++++
 mm/migrate.c               |    2 
 mm/mlock.c                 |  227 ++++++++++++++++++++++++++++++++++++++++++---
 mm/rmap.c                  |  167 ++++++++++++++++++++++++++++-----
 mm/vmscan.c                |    9 +
 8 files changed, 459 insertions(+), 42 deletions(-)

Index: Linux/mm/Kconfig
===================================================================
--- Linux.orig/mm/Kconfig	2007-09-14 10:23:53.000000000 -0400
+++ Linux/mm/Kconfig	2007-09-14 10:23:55.000000000 -0400
@@ -226,3 +226,16 @@ config NORECLAIM_NO_SWAP
 	  non-reclaimable for this reason will become reclaimable again when/if
 	  sufficient swap space is added to the system.
 
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
Index: Linux/mm/internal.h
===================================================================
--- Linux.orig/mm/internal.h	2007-09-14 10:17:54.000000000 -0400
+++ Linux/mm/internal.h	2007-09-14 10:23:55.000000000 -0400
@@ -36,6 +36,56 @@ static inline void __put_page(struct pag
 
 extern int isolate_lru_page(struct page *page);
 
+#ifdef CONFIG_NORECLAIM_MLOCK
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
+ */
+static inline void munlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end)
+{
+	vma->vm_flags &= ~VM_LOCKED;	/* try_to_unlock() needs this */
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
+
 extern void fastcall __init __free_pages_bootmem(struct page *page,
 						unsigned int order);
 
Index: Linux/mm/mlock.c
===================================================================
--- Linux.orig/mm/mlock.c	2007-09-14 10:17:54.000000000 -0400
+++ Linux/mm/mlock.c	2007-09-14 10:23:55.000000000 -0400
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
@@ -23,19 +29,213 @@ int can_do_mlock(void)
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
+ * add isolated page to appropriate LRU list, adjusting stats as needed.
+ * Page may still be non-reclaimable for other reasons.
+//TODO:  move to vmscan.c as global along with isolate_lru_page()?
+ */
+static void putback_lru_page(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	VM_BUG_ON(PageLRU(page));
+
+	ClearPageNoreclaim(page);
+	ClearPageActive(page);
+	lru_cache_add_active_or_noreclaim(page, NULL);
+}
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
+ * called from munlock()/munmap() path.
+ * If page on LRU, isolate and putback to move from noreclaim list.
+ */
+static void munlock_vma_page(struct page *page)
+{
+	int ret;
+	BUG_ON(!PageLocked(page));
+
+	if (PageMlocked(page)) {
+		ret = try_to_unlock(page);	/* walks rmap */
+		if (ret != SWAP_MLOCK && !isolate_lru_page(page))
+				putback_lru_page(page);
+	}
+}
+
+/*
+ * Called in fault path via page_reclaimable() for a new page
+ * to determine if it's being mapped into a LOCKED vma.
+ * If so, mark page as mlocked.
+ * TODO:  do I really need to try to lock the page?  We have added
+ *        the new page to the rmap before calling page_reclaimable().
+ *        Could another task have found it?  If not, no need to
+ *        [try to] lock page here.
+ *        Also, we're just setting a page flag now.
+ */
+int is_mlocked_vma(struct vm_area_struct *vma, struct page *page)
+{
+	VM_BUG_ON(PageMlocked(page));	// TODO:  needed?
+	VM_BUG_ON(PageLRU(page));
+
+	if (likely(!(vma->vm_flags & VM_LOCKED)) || TestSetPageLocked(page))
+		return 0;
+
+	SetPageMlocked(page);
+	unlock_page(page);
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
+			addr += PAGE_SIZE;
+			nr_pages--;
+		}
+	}
+	return ret;
+}
+
+#else /* CONFIG_NORECLAIM_MLOCK */
+
+/*
+ * Just make pages present
+ */
+void __mlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end, int lock)
+{
+	int ret = 0;
+
+	if (vma->vm_flags & VM_IO)
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
@@ -59,24 +259,25 @@ static int mlock_fixup(struct vm_area_st
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
Index: Linux/mm/vmscan.c
===================================================================
--- Linux.orig/mm/vmscan.c	2007-09-14 10:23:53.000000000 -0400
+++ Linux/mm/vmscan.c	2007-09-14 10:23:55.000000000 -0400
@@ -2165,13 +2165,13 @@ int anon_vma_reclaim_limit = DEFAULT_ANO
  *
  * @page       - page to test
  * @vma        - vm area in which page is/will be mapped.  May be NULL.
- *               If !NULL, called from fault path.
+ *               If !NULL, called from fault path for a new page.
  *
  * Reasons page might not be reclaimable:
  * 1) page's mapping marked non-reclaimable
  * 2) anon/shmem/tmpfs page, but no swap space avail
  * 3) anon_vma [if any] has too many related vmas
- * [more TBD.  e.g., page mlocked, ...]
+ * 4) page is mlock'ed into memory.
  *
  * TODO:  specify locking assumptions
  */
@@ -2201,7 +2201,10 @@ int page_reclaimable(struct page *page, 
 			return 0;
 	}
 #endif
-	/* TODO:  test page [!]reclaimable conditions */
+#ifdef CONFIG_NORECLAIM_MLOCK
+	if (PageMlocked(page) || (vma && is_mlocked_vma(vma, page)))
+		return 0;
+#endif
 
 	return 1;
 }
Index: Linux/include/linux/page-flags.h
===================================================================
--- Linux.orig/include/linux/page-flags.h	2007-09-14 10:21:48.000000000 -0400
+++ Linux/include/linux/page-flags.h	2007-09-14 10:23:55.000000000 -0400
@@ -110,6 +110,7 @@
 #define PG_uncached		31	/* Page has been mapped as uncached */
 
 #define PG_noreclaim		30	/* Page is "non-reclaimable"  */
+#define PG_mlocked		29	/* Page is vma mlocked */
 #endif
 
 /*
@@ -163,6 +164,8 @@ static inline void SetPageUptodate(struc
 #define SetPageActive(page)	set_bit(PG_active, &(page)->flags)
 #define ClearPageActive(page)	clear_bit(PG_active, &(page)->flags)
 #define __ClearPageActive(page)	__clear_bit(PG_active, &(page)->flags)
+#define TestSetPageActive(page) test_and_set_bit(PG_active, &(page)->flags)
+#define TestClearPageActive(page) test_and_clear_bit(PG_active, &(page)->flags)
 
 #define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
 #define __SetPageSlab(page)	__set_bit(PG_slab, &(page)->flags)
@@ -269,8 +272,15 @@ static inline void __ClearPageTail(struc
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
+#endif
 #else
 #define PageNoreclaim(page)	0
 #define SetPageNoreclaim(page)
@@ -278,6 +288,13 @@ static inline void __ClearPageTail(struc
 #define __ClearPageNoreclaim(page)
 #define TestClearPageNoreclaim(page) 0
 #endif
+#ifndef CONFIG_NORECLAIM_MLOCK
+#define PageMlock(page)	0
+#define SetPageMlock(page)
+#define ClearPageMlock(page)
+#define __ClearPageMlock(page)
+#define TestSetPageMlocked(page) 0
+#endif
 
 #define PageUncached(page)	test_bit(PG_uncached, &(page)->flags)
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
Index: Linux/include/linux/rmap.h
===================================================================
--- Linux.orig/include/linux/rmap.h	2007-09-14 10:23:52.000000000 -0400
+++ Linux/include/linux/rmap.h	2007-09-14 10:23:55.000000000 -0400
@@ -171,6 +171,17 @@ unsigned long page_address_in_vma(struct
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
@@ -194,5 +205,6 @@ static inline int page_mkclean(struct pa
 #define SWAP_SUCCESS	0
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
+#define SWAP_MLOCK	3
 
 #endif	/* _LINUX_RMAP_H */
Index: Linux/mm/rmap.c
===================================================================
--- Linux.orig/mm/rmap.c	2007-09-14 10:23:52.000000000 -0400
+++ Linux/mm/rmap.c	2007-09-14 10:23:55.000000000 -0400
@@ -52,6 +52,8 @@
 
 #include <asm/tlbflush.h>
 
+#include "internal.h"
+
 struct kmem_cache *anon_vma_cachep;
 
 /* This must be called under the mmap_sem. */
@@ -292,6 +294,14 @@ static int page_referenced_one(struct pa
 	if (!pte)
 		goto out;
 
+	/*
+	 * Don't want to elevate referenced for mlocked page that gets this far,
+	 * in order that it progresses to try_to_unmap and is moved to the
+	 * noreclaim list.
+	 */
+	if (vma->vm_flags & VM_LOCKED)
+		goto out_unmap;
+
 	if (ptep_clear_flush_young(vma, address, pte))
 		referenced++;
 
@@ -301,6 +311,7 @@ static int page_referenced_one(struct pa
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced++;
 
+out_unmap:
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
 out:
@@ -389,11 +400,6 @@ static int page_referenced_file(struct p
 		 */
 		if (mem_cont && (mm_container(vma->vm_mm) != mem_cont))
 			continue;
-		if ((vma->vm_flags & (VM_LOCKED|VM_MAYSHARE))
-				  == (VM_LOCKED|VM_MAYSHARE)) {
-			referenced++;
-			break;
-		}
 		referenced += page_referenced_one(page, vma, &mapcount);
 		if (!mapcount)
 			break;
@@ -715,10 +721,15 @@ static int try_to_unmap_one(struct page 
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
@@ -800,6 +811,10 @@ out:
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
@@ -871,10 +886,28 @@ static void try_to_unmap_cluster(unsigne
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
@@ -882,25 +915,53 @@ static int try_to_unmap_anon(struct page
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
@@ -911,20 +972,47 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
+	unsigned int mlocked = 0;
 
 	read_lock(&mapping->i_mmap_lock);
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
+				break;	/* stop on 1st mlocked vma */
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
+		if (TRY_TO_UNLOCK && unlikely(unlock)) {
+			if (!(vma->vm_flags & VM_LOCKED))
+				continue;	/* must visit all vmas */
+			mlocked++;
+			goto out;		/* no need to look further */
+		}
+		if (!migration && (vma->vm_flags & VM_LOCKED))
 			continue;
 		cursor = (unsigned long) vma->vm_private_data;
 		if (cursor > max_nl_cursor)
@@ -958,8 +1046,6 @@ static int try_to_unmap_file(struct page
 	do {
 		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-			if ((vma->vm_flags & VM_LOCKED) && !migration)
-				continue;
 			cursor = (unsigned long) vma->vm_private_data;
 			while ( cursor < max_nl_cursor &&
 				cursor < vma->vm_end - vma->vm_start) {
@@ -984,6 +1070,10 @@ static int try_to_unmap_file(struct page
 		vma->vm_private_data = NULL;
 out:
 	read_unlock(&mapping->i_mmap_lock);
+	if (mlocked)
+		ret = SWAP_MLOCK;
+	else if (ret == SWAP_MLOCK)
+		ret = SWAP_AGAIN;
 	return ret;
 }
 
@@ -998,6 +1088,7 @@ out:
  * SWAP_SUCCESS	- we succeeded in removing all mappings
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
+ * SWAP_MLOCK	- page is mlocked.
  */
 int try_to_unmap(struct page *page, int migration)
 {
@@ -1006,12 +1097,40 @@ int try_to_unmap(struct page *page, int 
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
+	int ret;
+
+	BUG_ON(!PageLocked(page));
+
+	if (PageAnon(page))
+		ret = try_to_unmap_anon(page, 1, 0);
+	else
+		ret = try_to_unmap_file(page, 1, 0);
+
+	if (ret != SWAP_MLOCK) {
+		ClearPageMlocked(page);	/* no VM_LOCKED vmas */
+		ret = SWAP_SUCCESS;
+	}
+	return ret;
+}
+#endif
Index: Linux/mm/migrate.c
===================================================================
--- Linux.orig/mm/migrate.c	2007-09-14 10:21:48.000000000 -0400
+++ Linux/mm/migrate.c	2007-09-14 10:23:55.000000000 -0400
@@ -354,6 +354,8 @@ static void migrate_page_copy(struct pag
 		SetPageActive(newpage);
 	} else if (PageNoreclaim(page))
 		SetPageNoreclaim(newpage);
+	if (PageMlocked(page))
+		SetPageMlocked(newpage);
 	if (PageChecked(page))
 		SetPageChecked(newpage);
 	if (PageMappedToDisk(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
