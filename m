Message-Id: <20080611184339.567696449@redhat.com>
References: <20080611184214.605110868@redhat.com>
Date: Wed, 11 Jun 2008 14:42:26 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 12/24] Unevictable LRU Infrastructure
Content-Disposition: inline; filename=vmscan-noreclaim-lru-infrastructure.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

When the system contains lots of mlocked or otherwise unevictable
pages, the pageout code (kswapd) can spend lots of time scanning
over these pages. Worse still, the presence of lots of unevictable
pages can confuse kswapd into thinking that more aggressive pageout
modes are required, resulting in all kinds of bad behaviour.

Infrastructure to manage pages excluded from reclaim--i.e., hidden
from vmscan.  Based on a patch by Larry Woodman of Red Hat. Reworked
to maintain "unevictable" pages on a separate per-zone LRU list,
to "hide" them from vmscan.

Kosaki Motohiro added the support for the memory controller unevictable
lru list.

Pages on the unevictable list have both PG_unevictable and PG_lru set.
Thus, PG_unevictable is analogous to and mutually exclusive with
PG_active--it specifies which LRU list the page is on.  

The unevictable infrastructure is enabled by a new mm Kconfig option
[CONFIG_]UNEVICTABLE_LRU.

A new function 'page_evictable(page, vma)' in vmscan.c tests whether
or not a page may be evictable.  Subsequent patches will add the various
!evictable tests.  We'll want to keep these tests light-weight for
use in shrink_active_list() and, possibly, the fault path.

To avoid races between tasks putting pages [back] onto an LRU list and
tasks that might be moving the page from non-evictable to evictable
state, one should test evictability under page lock and place
nonevictable pages directly on the unevictable list before dropping the
lock.  Otherwise, we risk "stranding" evictable pages on the unevictable
list.  It's OK to use the pagevec caches for evictable pages.  The new
function 'putback_lru_page()'--inverse to 'isolate_lru_page()'--handles
this transition, including potential page truncation while the page is
unlocked.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---

 include/linux/memcontrol.h |    1 
 include/linux/mm_inline.h  |   23 ++++--
 include/linux/mmzone.h     |   24 ++++++-
 include/linux/page-flags.h |   13 +++
 include/linux/pagevec.h    |    1 
 include/linux/swap.h       |   12 +++
 mm/Kconfig                 |   10 +++
 mm/internal.h              |   26 +++++++
 mm/memcontrol.c            |   73 +++++++++++++---------
 mm/mempolicy.c             |    2 
 mm/migrate.c               |   68 +++++++++++++-------
 mm/page_alloc.c            |    9 ++
 mm/swap.c                  |   40 ++++++++++--
 mm/vmscan.c                |  148 ++++++++++++++++++++++++++++++++++++++++-----
 14 files changed, 370 insertions(+), 80 deletions(-)

Index: linux-2.6.26-rc5-mm2/mm/Kconfig
===================================================================
--- linux-2.6.26-rc5-mm2.orig/mm/Kconfig	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/mm/Kconfig	2008-06-10 16:25:49.000000000 -0400
@@ -205,3 +205,13 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config UNEVICTABLE_LRU
+	bool "Add LRU list to track non-evictable pages"
+	default y
+	help
+	  Keeps unevictable pages off of the active and inactive pageout
+	  lists, so kswapd will not waste CPU time or have its balancing
+	  algorithms thrown off by scanning these pages.  Selecting this
+	  will use one page flag and increase the code size a little,
+	  say Y unless you know what you are doing.
Index: linux-2.6.26-rc5-mm2/include/linux/page-flags.h
===================================================================
--- linux-2.6.26-rc5-mm2.orig/include/linux/page-flags.h	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/include/linux/page-flags.h	2008-06-10 22:11:01.000000000 -0400
@@ -94,6 +94,9 @@ enum pageflags {
 	PG_reclaim,		/* To be reclaimed asap */
 	PG_buddy,		/* Page is free, on buddy lists */
 	PG_swapbacked,		/* Page is backed by RAM/swap */
+#ifdef CONFIG_UNEVICTABLE_LRU
+	PG_unevictable,		/* Page is "unevictable"  */
+#endif
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 	PG_uncached,		/* Page has been mapped as uncached */
 #endif
@@ -182,6 +185,7 @@ PAGEFLAG(Referenced, referenced) TESTCLE
 PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
 PAGEFLAG(LRU, lru) __CLEARPAGEFLAG(LRU, lru)
 PAGEFLAG(Active, active) __CLEARPAGEFLAG(Active, active)
+	TESTCLEARFLAG(Active, active)
 __PAGEFLAG(Slab, slab)
 PAGEFLAG(Checked, checked)		/* Used by some filesystems */
 PAGEFLAG(Pinned, pinned) TESTSCFLAG(Pinned, pinned)	/* Xen */
@@ -225,6 +229,15 @@ PAGEFLAG(SwapCache, swapcache)
 PAGEFLAG_FALSE(SwapCache)
 #endif
 
+#ifdef CONFIG_UNEVICTABLE_LRU
+PAGEFLAG(Unevictable, unevictable) __CLEARPAGEFLAG(Unevictable, unevictable)
+	TESTCLEARFLAG(Unevictable, unevictable)
+#else
+PAGEFLAG_FALSE(Unevictable) TESTCLEARFLAG_FALSE(Unevictable)
+	SETPAGEFLAG_NOOP(Unevictable) CLEARPAGEFLAG_NOOP(Unevictable)
+	__CLEARPAGEFLAG_NOOP(Unevictable)
+#endif
+
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 PAGEFLAG(Uncached, uncached)
 #else
Index: linux-2.6.26-rc5-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.26-rc5-mm2.orig/include/linux/mmzone.h	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/include/linux/mmzone.h	2008-06-10 22:11:01.000000000 -0400
@@ -86,6 +86,11 @@ enum zone_stat_item {
 	NR_ACTIVE_ANON,		/*  "     "     "   "       "         */
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
+#ifdef CONFIG_UNEVICTABLE_LRU
+	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
+#else
+	NR_UNEVICTABLE = NR_ACTIVE_FILE, /* avoid compiler errors in dead code */
+#endif
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
@@ -128,10 +133,18 @@ enum lru_list {
 	LRU_ACTIVE_ANON = LRU_BASE + LRU_ACTIVE,
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
-	NR_LRU_LISTS };
+#ifdef CONFIG_UNEVICTABLE_LRU
+	LRU_UNEVICTABLE,
+#else
+	LRU_UNEVICTABLE = LRU_ACTIVE_FILE, /* avoid compiler errors in dead code */
+#endif
+	NR_LRU_LISTS
+};
 
 #define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
 
+#define for_each_evictable_lru(l) for (l = 0; l <= LRU_ACTIVE_FILE; l++)
+
 static inline int is_file_lru(enum lru_list l)
 {
 	return (l == LRU_INACTIVE_FILE || l == LRU_ACTIVE_FILE);
@@ -142,6 +155,15 @@ static inline int is_active_lru(enum lru
 	return (l == LRU_ACTIVE_ANON || l == LRU_ACTIVE_FILE);
 }
 
+static inline int is_unevictable_lru(enum lru_list l)
+{
+#ifdef CONFIG_UNEVICTABLE_LRU
+	return (l == LRU_UNEVICTABLE);
+#else
+	return 0;
+#endif
+}
+
 struct per_cpu_pages {
 	int count;		/* number of pages in the list */
 	int high;		/* high watermark, emptying needed */
Index: linux-2.6.26-rc5-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.26-rc5-mm2.orig/mm/page_alloc.c	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/mm/page_alloc.c	2008-06-10 22:11:01.000000000 -0400
@@ -241,6 +241,9 @@ static void bad_page(struct page *page)
 			1 << PG_private |
 			1 << PG_locked	|
 			1 << PG_active	|
+#ifdef CONFIG_UNEVICTABLE_LRU
+			1 << PG_unevictable	|
+#endif
 			1 << PG_dirty	|
 			1 << PG_reclaim |
 			1 << PG_slab    |
@@ -474,6 +477,9 @@ static inline int free_pages_check(struc
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
+#ifdef CONFIG_UNEVICTABLE_LRU
+			1 << PG_unevictable |
+#endif
 			1 << PG_buddy ))))
 		bad_page(page);
 	if (PageDirty(page))
@@ -625,6 +631,9 @@ static int prep_new_page(struct page *pa
 			1 << PG_private	|
 			1 << PG_locked	|
 			1 << PG_active	|
+#ifdef CONFIG_UNEVICTABLE_LRU
+			1 << PG_unevictable	|
+#endif
 			1 << PG_dirty	|
 			1 << PG_slab    |
 			1 << PG_swapcache |
Index: linux-2.6.26-rc5-mm2/include/linux/mm_inline.h
===================================================================
--- linux-2.6.26-rc5-mm2.orig/include/linux/mm_inline.h	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/include/linux/mm_inline.h	2008-06-10 16:25:49.000000000 -0400
@@ -91,11 +91,16 @@ del_page_from_lru(struct zone *zone, str
 	enum lru_list l = LRU_BASE;
 
 	list_del(&page->lru);
-	if (PageActive(page)) {
-		__ClearPageActive(page);
-		l += LRU_ACTIVE;
+	if (PageUnevictable(page)) {
+		__ClearPageUnevictable(page);
+		l = LRU_UNEVICTABLE;
+	} else {
+		if (PageActive(page)) {
+			__ClearPageActive(page);
+			l += LRU_ACTIVE;
+		}
+		l += page_is_file_cache(page);
 	}
-	l += page_is_file_cache(page);
 	__dec_zone_state(zone, NR_LRU_BASE + l);
 }
 
@@ -110,9 +115,13 @@ static inline enum lru_list page_lru(str
 {
 	enum lru_list lru = LRU_BASE;
 
-	if (PageActive(page))
-		lru += LRU_ACTIVE;
-	lru += page_is_file_cache(page);
+	if (PageUnevictable(page))
+		lru = LRU_UNEVICTABLE;
+	else {
+		if (PageActive(page))
+			lru += LRU_ACTIVE;
+		lru += page_is_file_cache(page);
+	}
 
 	return lru;
 }
Index: linux-2.6.26-rc5-mm2/include/linux/swap.h
===================================================================
--- linux-2.6.26-rc5-mm2.orig/include/linux/swap.h	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/include/linux/swap.h	2008-06-10 22:11:01.000000000 -0400
@@ -180,6 +180,8 @@ extern int lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void swap_setup(void);
 
+extern void add_page_to_unevictable_list(struct page *page);
+
 /**
  * lru_cache_add: add a page to the page lists
  * @page: the page to add
@@ -228,6 +230,16 @@ static inline int zone_reclaim(struct zo
 }
 #endif
 
+#ifdef CONFIG_UNEVICTABLE_LRU
+extern int page_evictable(struct page *page, struct vm_area_struct *vma);
+#else
+static inline int page_evictable(struct page *page,
+						struct vm_area_struct *vma)
+{
+	return 1;
+}
+#endif
+
 extern int kswapd_run(int nid);
 
 #ifdef CONFIG_MMU
Index: linux-2.6.26-rc5-mm2/include/linux/pagevec.h
===================================================================
--- linux-2.6.26-rc5-mm2.orig/include/linux/pagevec.h	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/include/linux/pagevec.h	2008-06-10 16:25:49.000000000 -0400
@@ -101,7 +101,6 @@ static inline void __pagevec_lru_add_act
 	____pagevec_lru_add(pvec, LRU_ACTIVE_FILE);
 }
 
-
 static inline void pagevec_lru_add_file(struct pagevec *pvec)
 {
 	if (pagevec_count(pvec))
Index: linux-2.6.26-rc5-mm2/mm/swap.c
===================================================================
--- linux-2.6.26-rc5-mm2.orig/mm/swap.c	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/mm/swap.c	2008-06-10 22:11:01.000000000 -0400
@@ -136,7 +136,7 @@ static void pagevec_move_tail(struct pag
 void  rotate_reclaimable_page(struct page *page)
 {
 	if (!PageLocked(page) && !PageDirty(page) && !PageActive(page) &&
-	    PageLRU(page)) {
+	    !PageUnevictable(page) && PageLRU(page)) {
 		struct pagevec *pvec;
 		unsigned long flags;
 
@@ -157,7 +157,7 @@ void activate_page(struct page *page)
 	struct zone *zone = page_zone(page);
 
 	spin_lock_irq(&zone->lru_lock);
-	if (PageLRU(page) && !PageActive(page)) {
+	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		int file = page_is_file_cache(page);
 		int lru = LRU_BASE + file;
 		del_page_from_lru_list(zone, page, lru);
@@ -166,7 +166,7 @@ void activate_page(struct page *page)
 		lru += LRU_ACTIVE;
 		add_page_to_lru_list(zone, page, lru);
 		__count_vm_event(PGACTIVATE);
-		mem_cgroup_move_lists(page, true);
+		mem_cgroup_move_lists(page, lru);
 
 		zone->recent_rotated[!!file]++;
 		zone->recent_scanned[!!file]++;
@@ -183,7 +183,8 @@ void activate_page(struct page *page)
  */
 void mark_page_accessed(struct page *page)
 {
-	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
+	if (!PageActive(page) && !PageUnevictable(page) &&
+			PageReferenced(page) && PageLRU(page)) {
 		activate_page(page);
 		ClearPageReferenced(page);
 	} else if (!PageReferenced(page)) {
@@ -211,13 +212,38 @@ void __lru_cache_add(struct page *page, 
 void lru_cache_add_lru(struct page *page, enum lru_list lru)
 {
 	if (PageActive(page)) {
+		VM_BUG_ON(PageUnevictable(page));
 		ClearPageActive(page);
+	} else if (PageUnevictable(page)) {
+		VM_BUG_ON(PageActive(page));
+		ClearPageUnevictable(page);
 	}
 
-	VM_BUG_ON(PageLRU(page) || PageActive(page));
+	VM_BUG_ON(PageLRU(page) || PageActive(page) || PageUnevictable(page));
 	__lru_cache_add(page, lru);
 }
 
+/**
+ * add_page_to_unevictable_list - add a page to the unevictable list
+ * @page:  the page to be added to the unevictable list
+ *
+ * Add page directly to its zone's unevictable list.  To avoid races with
+ * tasks that might be making the page evictable, through eg. munlock,
+ * munmap or exit, while it's not on the lru, we want to add the page
+ * while it's locked or otherwise "invisible" to other tasks.  This is
+ * difficult to do when using the pagevec cache, so bypass that.
+ */
+void add_page_to_unevictable_list(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+
+	spin_lock_irq(&zone->lru_lock);
+	SetPageUnevictable(page);
+	SetPageLRU(page);
+	add_page_to_lru_list(zone, page, LRU_UNEVICTABLE);
+	spin_unlock_irq(&zone->lru_lock);
+}
+
 /*
  * Drain pages out of the cpu's pagevecs.
  * Either "cpu" is the current CPU, and preemption has already been
@@ -315,6 +341,7 @@ void release_pages(struct page **pages, 
 
 		if (PageLRU(page)) {
 			struct zone *pagezone = page_zone(page);
+
 			if (pagezone != zone) {
 				if (zone)
 					spin_unlock_irqrestore(&zone->lru_lock,
@@ -391,6 +418,7 @@ void ____pagevec_lru_add(struct pagevec 
 {
 	int i;
 	struct zone *zone = NULL;
+	VM_BUG_ON(is_unevictable_lru(lru));
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
@@ -402,6 +430,8 @@ void ____pagevec_lru_add(struct pagevec 
 			zone = pagezone;
 			spin_lock_irq(&zone->lru_lock);
 		}
+		VM_BUG_ON(PageActive(page));
+		VM_BUG_ON(PageUnevictable(page));
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		if (is_active_lru(lru))
Index: linux-2.6.26-rc5-mm2/mm/migrate.c
===================================================================
--- linux-2.6.26-rc5-mm2.orig/mm/migrate.c	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/mm/migrate.c	2008-06-10 22:11:01.000000000 -0400
@@ -53,14 +53,9 @@ int migrate_prep(void)
 	return 0;
 }
 
-static inline void move_to_lru(struct page *page)
-{
-	lru_cache_add_lru(page, page_lru(page));
-	put_page(page);
-}
-
 /*
- * Add isolated pages on the list back to the LRU.
+ * Add isolated pages on the list back to the LRU under page lock
+ * to avoid leaking evictable pages back onto unevictable list.
  *
  * returns the number of pages put back.
  */
@@ -72,7 +67,9 @@ int putback_lru_pages(struct list_head *
 
 	list_for_each_entry_safe(page, page2, l, lru) {
 		list_del(&page->lru);
-		move_to_lru(page);
+		lock_page(page);
+		if (putback_lru_page(page))
+			unlock_page(page);
 		count++;
 	}
 	return count;
@@ -338,8 +335,11 @@ static void migrate_page_copy(struct pag
 		SetPageReferenced(newpage);
 	if (PageUptodate(page))
 		SetPageUptodate(newpage);
-	if (PageActive(page))
+	if (TestClearPageActive(page)) {
+		VM_BUG_ON(PageUnevictable(page));
 		SetPageActive(newpage);
+	} else
+		unevictable_migrate_page(newpage, page);
 	if (PageChecked(page))
 		SetPageChecked(newpage);
 	if (PageMappedToDisk(page))
@@ -368,7 +368,6 @@ static void migrate_page_copy(struct pag
 		mem_cgroup_uncharge_page(page);
 	}
 #endif
-	ClearPageActive(page);
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
 	page->mapping = NULL;
@@ -547,10 +546,15 @@ static int fallback_migrate_page(struct 
  *
  * The new page will have replaced the old page if this function
  * is successful.
+ *
+ * Return value:
+ *   < 0 - error code
+ *  == 0 - success
  */
 static int move_to_new_page(struct page *newpage, struct page *page)
 {
 	struct address_space *mapping;
+	int unlock = 1;
 	int rc;
 
 	/*
@@ -585,10 +589,16 @@ static int move_to_new_page(struct page 
 
 	if (!rc) {
 		remove_migration_ptes(page, newpage);
+		/*
+		 * Put back on LRU while holding page locked to
+		 * handle potential race with, e.g., munlock()
+		 */
+		unlock = putback_lru_page(newpage);
 	} else
 		newpage->mapping = NULL;
 
-	unlock_page(newpage);
+	if (unlock)
+		unlock_page(newpage);
 
 	return rc;
 }
@@ -605,18 +615,19 @@ static int unmap_and_move(new_page_t get
 	struct page *newpage = get_new_page(page, private, &result);
 	int rcu_locked = 0;
 	int charge = 0;
+	int unlock = 1;
 
 	if (!newpage)
 		return -ENOMEM;
 
 	if (page_count(page) == 1)
 		/* page was freed from under us. So we are done. */
-		goto move_newpage;
+		goto end_migration;
 
 	charge = mem_cgroup_prepare_migration(page, newpage);
 	if (charge == -ENOMEM) {
 		rc = -ENOMEM;
-		goto move_newpage;
+		goto end_migration;
 	}
 	/* prepare cgroup just returns 0 or -ENOMEM */
 	BUG_ON(charge);
@@ -624,7 +635,7 @@ static int unmap_and_move(new_page_t get
 	rc = -EAGAIN;
 	if (TestSetPageLocked(page)) {
 		if (!force)
-			goto move_newpage;
+			goto end_migration;
 		lock_page(page);
 	}
 
@@ -686,8 +697,6 @@ rcu_unlock:
 
 unlock:
 
-	unlock_page(page);
-
 	if (rc != -EAGAIN) {
  		/*
  		 * A page that has been migrated has all references
@@ -696,17 +705,30 @@ unlock:
  		 * restored.
  		 */
  		list_del(&page->lru);
- 		move_to_lru(page);
+		if (!page->mapping) {
+			VM_BUG_ON(page_count(page) != 1);
+			unlock_page(page);
+			put_page(page);		/* just free the old page */
+			goto end_migration;
+		} else
+			unlock = putback_lru_page(page);
 	}
 
-move_newpage:
+	if (unlock)
+		unlock_page(page);
+
+end_migration:
 	if (!charge)
 		mem_cgroup_end_migration(newpage);
-	/*
-	 * Move the new page to the LRU. If migration was not successful
-	 * then this will free the page.
-	 */
-	move_to_lru(newpage);
+
+	if (!newpage->mapping) {
+		/*
+		 * Migration failed or was never attempted.
+		 * Free the newpage.
+		 */
+		VM_BUG_ON(page_count(newpage) != 1);
+		put_page(newpage);
+	}
 	if (result) {
 		if (rc)
 			*result = rc;
Index: linux-2.6.26-rc5-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.26-rc5-mm2.orig/mm/vmscan.c	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/mm/vmscan.c	2008-06-10 22:11:01.000000000 -0400
@@ -452,6 +452,73 @@ cannot_free:
 	return 0;
 }
 
+/**
+ * putback_lru_page - put previously isolated page onto appropriate LRU list
+ * @page: page to be put back to appropriate lru list
+ *
+ * Add previously isolated @page to appropriate LRU list.
+ * Page may still be unevictable for other reasons.
+ *
+ * lru_lock must not be held, interrupts must be enabled.
+ * Must be called with page locked.
+ *
+ * return 1 if page still locked [not truncated], else 0
+ */
+int putback_lru_page(struct page *page)
+{
+	int lru;
+	int ret = 1;
+
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(PageLRU(page));
+
+	lru = !!TestClearPageActive(page);
+	ClearPageUnevictable(page);	/* for page_evictable() */
+
+	if (unlikely(!page->mapping)) {
+		/*
+		 * page truncated.  drop lock as put_page() will
+		 * free the page.
+		 */
+		VM_BUG_ON(page_count(page) != 1);
+		unlock_page(page);
+		ret = 0;
+	} else if (page_evictable(page, NULL)) {
+		/*
+		 * For evictable pages, we can use the cache.
+		 * In event of a race, worst case is we end up with an
+		 * unevictable page on [in]active list.
+		 * We know how to handle that.
+		 */
+		lru += page_is_file_cache(page);
+		lru_cache_add_lru(page, lru);
+		mem_cgroup_move_lists(page, lru);
+	} else {
+		/*
+		 * Put unevictable pages directly on zone's unevictable
+		 * list.
+		 */
+		add_page_to_unevictable_list(page);
+		mem_cgroup_move_lists(page, LRU_UNEVICTABLE);
+	}
+
+	put_page(page);		/* drop ref from isolate */
+	return ret;		/* ret => "page still locked" */
+}
+
+/*
+ * Cull page that shrink_*_list() has detected to be unevictable
+ * under page lock to close races with other tasks that might be making
+ * the page evictable.  Avoid stranding an evictable page on the
+ * unevictable list.
+ */
+static void cull_unevictable_page(struct page *page)
+{
+	lock_page(page);
+	if (putback_lru_page(page))
+		unlock_page(page);
+}
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -485,6 +552,12 @@ static unsigned long shrink_page_list(st
 
 		sc->nr_scanned++;
 
+		if (unlikely(!page_evictable(page, NULL))) {
+			if (putback_lru_page(page))
+				unlock_page(page);
+			continue;
+		}
+
 		if (!sc->may_swap && page_mapped(page))
 			goto keep_locked;
 
@@ -584,7 +657,7 @@ static unsigned long shrink_page_list(st
 		 * possible for a page to have PageDirty set, but it is actually
 		 * clean (all its buffers are clean).  This happens if the
 		 * buffers were written out directly, with submit_bh(). ext3
-		 * will do this, as well as the blockdev mapping. 
+		 * will do this, as well as the blockdev mapping.
 		 * try_to_release_page() will discover that cleanness and will
 		 * drop the buffers and mark the page clean - it can be freed.
 		 *
@@ -616,6 +689,7 @@ activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
 		if (PageSwapCache(page) && vm_swap_full())
 			remove_exclusive_swap_page_ref(page);
+		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
@@ -665,6 +739,14 @@ int __isolate_lru_page(struct page *page
 	if (mode != ISOLATE_BOTH && (!page_is_file_cache(page) != !file))
 		return ret;
 
+	/*
+	 * When this function is being called for lumpy reclaim, we
+	 * initially look into all LRU pages, active, inactive and
+	 * unevictable; only give shrink_page_list evictable pages.
+	 */
+	if (PageUnevictable(page))
+		return ret;
+
 	ret = -EBUSY;
 	if (likely(get_page_unless_zero(page))) {
 		/*
@@ -776,7 +858,7 @@ static unsigned long isolate_lru_pages(u
 				/* else it is being freed elsewhere */
 				list_move(&cursor_page->lru, src);
 			default:
-				break;
+				break;	/* ! on LRU or wrong list */
 			}
 		}
 	}
@@ -836,8 +918,9 @@ static unsigned long clear_active_flags(
  * Returns -EBUSY if the page was not on an LRU list.
  *
  * The returned page will have PageLRU() cleared.  If it was found on
- * the active list, it will have PageActive set.  That flag may need
- * to be cleared by the caller before letting the page go.
+ * the active list, it will have PageActive set.  If it was found on
+ * the unevictable list, it will have the PageUnevictable bit set. That flag
+ * may need to be cleared by the caller before letting the page go.
  *
  * The vmstat statistic corresponding to the list on which the page was
  * found will be decremented.
@@ -858,11 +941,10 @@ int isolate_lru_page(struct page *page)
 
 		spin_lock_irq(&zone->lru_lock);
 		if (PageLRU(page) && get_page_unless_zero(page)) {
-			int lru = LRU_BASE;
+			int lru = page_lru(page);
 			ret = 0;
 			ClearPageLRU(page);
 
-			lru += page_is_file_cache(page) + !!PageActive(page);
 			del_page_from_lru_list(zone, page, lru);
 		}
 		spin_unlock_irq(&zone->lru_lock);
@@ -974,11 +1056,20 @@ static unsigned long shrink_inactive_lis
 		 * Put back any unfreeable pages.
 		 */
 		while (!list_empty(&page_list)) {
+			int lru;
 			page = lru_to_page(&page_list);
 			VM_BUG_ON(PageLRU(page));
-			SetPageLRU(page);
 			list_del(&page->lru);
-			add_page_to_lru_list(zone, page, page_lru(page));
+			if (unlikely(!page_evictable(page, NULL))) {
+				spin_unlock_irq(&zone->lru_lock);
+				cull_unevictable_page(page);
+				spin_lock_irq(&zone->lru_lock);
+				continue;
+			}
+			SetPageLRU(page);
+			lru = page_lru(page);
+			add_page_to_lru_list(zone, page, lru);
+			mem_cgroup_move_lists(page, lru);
 			if (PageActive(page) && scan_global_lru(sc)) {
 				int file = !!page_is_file_cache(page);
 				zone->recent_rotated[file]++;
@@ -1073,6 +1164,12 @@ static void shrink_active_list(unsigned 
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
+
+		if (unlikely(!page_evictable(page, NULL))) {
+			cull_unevictable_page(page);
+			continue;
+		}
+
 		if (page_referenced(page, 0, sc->mem_cgroup)) {
 			pgmoved++;
 			if (file) {
@@ -1118,7 +1215,7 @@ static void shrink_active_list(unsigned 
 		ClearPageActive(page);
 
 		list_move(&page->lru, &zone->lru[lru].list);
-		mem_cgroup_move_lists(page, false);
+		mem_cgroup_move_lists(page, lru);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
@@ -1149,7 +1246,7 @@ static void shrink_active_list(unsigned 
 		VM_BUG_ON(!PageActive(page));
 
 		list_move(&page->lru, &zone->lru[lru].list);
-		mem_cgroup_move_lists(page, true);
+		mem_cgroup_move_lists(page, lru);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
@@ -1289,7 +1386,7 @@ static unsigned long shrink_zone(int pri
 
 	get_scan_ratio(zone, sc, percent);
 
-	for_each_lru(l) {
+	for_each_evictable_lru(l) {
 		if (scan_global_lru(sc)) {
 			int file = is_file_lru(l);
 			int scan;
@@ -1319,7 +1416,7 @@ static unsigned long shrink_zone(int pri
 
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
-		for_each_lru(l) {
+		for_each_evictable_lru(l) {
 			if (nr[l]) {
 				nr_to_scan = min(nr[l],
 					(unsigned long)sc->swap_cluster_max);
@@ -1874,8 +1971,8 @@ static unsigned long shrink_all_zones(un
 		if (zone_is_all_unreclaimable(zone) && prio != DEF_PRIORITY)
 			continue;
 
-		for_each_lru(l) {
-			/* For pass = 0 we don't shrink the active list */
+		for_each_evictable_lru(l) {
+			/* For pass = 0, we don't shrink the active list */
 			if (pass == 0 &&
 				(l == LRU_ACTIVE || l == LRU_ACTIVE_FILE))
 				continue;
@@ -2212,3 +2309,26 @@ int zone_reclaim(struct zone *zone, gfp_
 	return ret;
 }
 #endif
+
+#ifdef CONFIG_UNEVICTABLE_LRU
+/*
+ * page_evictable - test whether a page is evictable
+ * @page: the page to test
+ * @vma: the VMA in which the page is or will be mapped, may be NULL
+ *
+ * Test whether page is evictable--i.e., should be placed on active/inactive
+ * lists vs unevictable list.
+ *
+ * Reasons page might not be evictable:
+ * TODO - later patches
+ */
+int page_evictable(struct page *page, struct vm_area_struct *vma)
+{
+
+	VM_BUG_ON(PageUnevictable(page));
+
+	/* TODO:  test page [!]evictable conditions */
+
+	return 1;
+}
+#endif
Index: linux-2.6.26-rc5-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.26-rc5-mm2.orig/mm/mempolicy.c	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/mm/mempolicy.c	2008-06-10 16:25:49.000000000 -0400
@@ -2199,7 +2199,7 @@ static void gather_stats(struct page *pa
 	if (PageSwapCache(page))
 		md->swapcache++;
 
-	if (PageActive(page))
+	if (PageActive(page) || PageUnevictable(page))
 		md->active++;
 
 	if (PageWriteback(page))
Index: linux-2.6.26-rc5-mm2/mm/internal.h
===================================================================
--- linux-2.6.26-rc5-mm2.orig/mm/internal.h	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/mm/internal.h	2008-06-10 22:11:01.000000000 -0400
@@ -39,8 +39,15 @@ static inline void __put_page(struct pag
 	atomic_dec(&page->_count);
 }
 
+/*
+ * in mm/vmscan.c:
+ */
 extern int isolate_lru_page(struct page *page);
+extern int putback_lru_page(struct page *page);
 
+/*
+ * in mm/page_alloc.c
+ */
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 
 /*
@@ -54,6 +61,25 @@ static inline unsigned long page_order(s
 	return page_private(page);
 }
 
+#ifdef CONFIG_UNEVICTABLE_LRU
+/*
+ * unevictable_migrate_page() called only from migrate_page_copy() to
+ * migrate unevictable flag to new page.
+ * Note that the old page has been isolated from the LRU lists at this
+ * point so we don't need to worry about LRU statistics.
+ */
+static inline void unevictable_migrate_page(struct page *new, struct page *old)
+{
+	if (TestClearPageUnevictable(old))
+		SetPageUnevictable(new);
+}
+#else
+static inline void unevictable_migrate_page(struct page *new, struct page *old)
+{
+}
+#endif
+
+
 /*
  * FLATMEM and DISCONTIGMEM configurations use alloc_bootmem_node,
  * so all functions starting at paging_init should be marked __init
Index: linux-2.6.26-rc5-mm2/mm/memcontrol.c
===================================================================
--- linux-2.6.26-rc5-mm2.orig/mm/memcontrol.c	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/mm/memcontrol.c	2008-06-10 22:11:01.000000000 -0400
@@ -160,9 +160,10 @@ struct page_cgroup {
 	struct mem_cgroup *mem_cgroup;
 	int flags;
 };
-#define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
-#define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
-#define PAGE_CGROUP_FLAG_FILE	(0x4)	/* page is file system backed */
+#define PAGE_CGROUP_FLAG_CACHE	   (0x1)	/* charged as cache */
+#define PAGE_CGROUP_FLAG_ACTIVE    (0x2)	/* page is active in this cgroup */
+#define PAGE_CGROUP_FLAG_FILE	   (0x4)	/* page is file system backed */
+#define PAGE_CGROUP_FLAG_UNEVICTABLE (0x8)	/* page is unevictableable */
 
 static int page_cgroup_nid(struct page_cgroup *pc)
 {
@@ -283,10 +284,14 @@ static void __mem_cgroup_remove_list(str
 {
 	int lru = LRU_BASE;
 
-	if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
-		lru += LRU_ACTIVE;
-	if (pc->flags & PAGE_CGROUP_FLAG_FILE)
-		lru += LRU_FILE;
+	if (pc->flags & PAGE_CGROUP_FLAG_UNEVICTABLE)
+		lru = LRU_UNEVICTABLE;
+	else {
+		if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
+			lru += LRU_ACTIVE;
+		if (pc->flags & PAGE_CGROUP_FLAG_FILE)
+			lru += LRU_FILE;
+	}
 
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
 
@@ -299,10 +304,14 @@ static void __mem_cgroup_add_list(struct
 {
 	int lru = LRU_BASE;
 
-	if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
-		lru += LRU_ACTIVE;
-	if (pc->flags & PAGE_CGROUP_FLAG_FILE)
-		lru += LRU_FILE;
+	if (pc->flags & PAGE_CGROUP_FLAG_UNEVICTABLE)
+		lru = LRU_UNEVICTABLE;
+	else {
+		if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
+			lru += LRU_ACTIVE;
+		if (pc->flags & PAGE_CGROUP_FLAG_FILE)
+			lru += LRU_FILE;
+	}
 
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
 	list_add(&pc->lru, &mz->lists[lru]);
@@ -310,21 +319,31 @@ static void __mem_cgroup_add_list(struct
 	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, true);
 }
 
-static void __mem_cgroup_move_lists(struct page_cgroup *pc, bool active)
+static void __mem_cgroup_move_lists(struct page_cgroup *pc, enum lru_list lru)
 {
 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
-	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
-	int file = pc->flags & PAGE_CGROUP_FLAG_FILE;
-	int lru = LRU_FILE * !!file + !!from;
+	int active    = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
+	int file      = pc->flags & PAGE_CGROUP_FLAG_FILE;
+	int unevictable = pc->flags & PAGE_CGROUP_FLAG_UNEVICTABLE;
+	enum lru_list from = unevictable ? LRU_UNEVICTABLE :
+				(LRU_FILE * !!file + !!active);
 
-	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
+	if (lru == from)
+		return;
 
-	if (active)
-		pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
-	else
+	MEM_CGROUP_ZSTAT(mz, from) -= 1;
+
+	if (is_unevictable_lru(lru)) {
 		pc->flags &= ~PAGE_CGROUP_FLAG_ACTIVE;
+		pc->flags |= PAGE_CGROUP_FLAG_UNEVICTABLE;
+	} else {
+		if (is_active_lru(lru))
+			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
+		else
+			pc->flags &= ~PAGE_CGROUP_FLAG_ACTIVE;
+		pc->flags &= ~PAGE_CGROUP_FLAG_UNEVICTABLE;
+	}
 
-	lru = LRU_FILE * !!file + !!active;
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
 	list_move(&pc->lru, &mz->lists[lru]);
 }
@@ -342,7 +361,7 @@ int task_in_mem_cgroup(struct task_struc
 /*
  * This routine assumes that the appropriate zone's lru lock is already held
  */
-void mem_cgroup_move_lists(struct page *page, bool active)
+void mem_cgroup_move_lists(struct page *page, enum lru_list lru)
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup_per_zone *mz;
@@ -362,7 +381,7 @@ void mem_cgroup_move_lists(struct page *
 	if (pc) {
 		mz = page_cgroup_zoneinfo(pc);
 		spin_lock_irqsave(&mz->lru_lock, flags);
-		__mem_cgroup_move_lists(pc, active);
+		__mem_cgroup_move_lists(pc, lru);
 		spin_unlock_irqrestore(&mz->lru_lock, flags);
 	}
 	unlock_page_cgroup(page);
@@ -460,12 +479,10 @@ unsigned long mem_cgroup_isolate_pages(u
 		/*
 		 * TODO: play better with lumpy reclaim, grabbing anything.
 		 */
-		if (PageActive(page) && !active) {
-			__mem_cgroup_move_lists(pc, true);
-			continue;
-		}
-		if (!PageActive(page) && active) {
-			__mem_cgroup_move_lists(pc, false);
+		if (PageUnevictable(page) ||
+		    (PageActive(page) && !active) ||
+		    (!PageActive(page) && active)) {
+			__mem_cgroup_move_lists(pc, page_lru(page));
 			continue;
 		}
 
Index: linux-2.6.26-rc5-mm2/include/linux/memcontrol.h
===================================================================
--- linux-2.6.26-rc5-mm2.orig/include/linux/memcontrol.h	2008-06-10 16:23:31.000000000 -0400
+++ linux-2.6.26-rc5-mm2/include/linux/memcontrol.h	2008-06-10 22:11:08.000000000 -0400
@@ -34,9 +34,9 @@ extern int mem_cgroup_charge(struct page
 				gfp_t gfp_mask);
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
+extern void mem_cgroup_move_lists(struct page *page, enum lru_list lru);
 extern void mem_cgroup_uncharge_page(struct page *page);
 extern void mem_cgroup_uncharge_cache_page(struct page *page);
-extern void mem_cgroup_move_lists(struct page *page, bool active);
 extern int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask);
 
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
