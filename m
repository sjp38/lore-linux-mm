Date: Tue, 15 Jul 2008 04:09:20 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH 1/9] putback_lru_page()/unevictable page handling rework.
In-Reply-To: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080715040715.F6F2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Patch title: unevictable-lru-infrastructure-putback_lru_page-rework.patch
Against mmotm Jul 14
Applies after unevictable-lru-infrastructure-remove-redundant-page-mapping-check.patch


Changelog
================
V4 -> V5
   o splited several patches for easy reviewable.

V3 -> V4
   o fix broken recheck logic in putback_lru_page().
   o fix shmem_lock() prototype.

V2 -> V3
   o remove lock_page() from scan_mapping_unevictable_pages() and
     scan_zone_unevictable_pages().
   o revert ipc/shm.c mm/shmem.c change of SHMEM unevictable patch.
     it become unnecessary by this patch.

V1 -> V2
   o undo unintented comment killing.
   o move putback_lru_page() from move_to_new_page() to unmap_and_move().
   o folded depend patch
       http://marc.info/?l=linux-mm&m=121337119621958&w=2
       http://marc.info/?l=linux-kernel&m=121362782406478&w=2
       http://marc.info/?l=linux-mm&m=121377572909776&w=2


Now, putback_lru_page() requires that the page is locked.
And in some special case, implicitly unlock it.

This patch tries to make putback_lru_pages() to be lock_page() free.
(Of course, some callers must take the lock.)

The main reason that putback_lru_page() assumes that page is locked
is to avoid the change in page's status among Mlocked/Not-Mlocked.

Once it is added to unevictable list, the page is removed from
unevictable list only when page is munlocked. (there are other special
case. but we ignore the special case.)
So, status change during putback_lru_page() is fatal and page should 
be locked.

putback_lru_page() in this patch has a new concepts.
When it adds page to unevictable list, it checks the status is 
changed or not again. if changed, retry to putback.

This patche doesn't remove caller's lock_page.
latter patches do it.



Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/internal.h |    2 -
 mm/migrate.c  |   33 +++++++++++----------
 mm/vmscan.c   |   88 ++++++++++++++++++++++++++++++++++------------------------
 3 files changed, 72 insertions(+), 51 deletions(-)

Index: linux-2.6.26-rc9-mmotm-putback/mm/vmscan.c
===================================================================
--- linux-2.6.26-rc9-mmotm-putback.orig/mm/vmscan.c
+++ linux-2.6.26-rc9-mmotm-putback/mm/vmscan.c
@@ -478,30 +478,20 @@ int remove_mapping(struct address_space 
  * Page may still be unevictable for other reasons.
  *
  * lru_lock must not be held, interrupts must be enabled.
- * Must be called with page locked.
- *
- * return 1 if page still locked [not truncated], else 0
  */
-int putback_lru_page(struct page *page)
+#ifdef CONFIG_UNEVICTABLE_LRU
+void putback_lru_page(struct page *page)
 {
 	int lru;
 	int ret = 1;
 
-	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageLRU(page));
 
+redo:
 	lru = !!TestClearPageActive(page);
-	ClearPageUnevictable(page);	/* for page_evictable() */
+	ClearPageUnevictable(page);
 
-	if (unlikely(!page->mapping)) {
-		/*
-		 * page truncated.  drop lock as put_page() will
-		 * free the page.
-		 */
-		VM_BUG_ON(page_count(page) != 1);
-		unlock_page(page);
-		ret = 0;
-	} else if (page_evictable(page, NULL)) {
+	if (page_evictable(page, NULL)) {
 		/*
 		 * For evictable pages, we can use the cache.
 		 * In event of a race, worst case is we end up with an
@@ -510,20 +500,50 @@ int putback_lru_page(struct page *page)
 		 */
 		lru += page_is_file_cache(page);
 		lru_cache_add_lru(page, lru);
-		mem_cgroup_move_lists(page, lru);
 	} else {
 		/*
 		 * Put unevictable pages directly on zone's unevictable
 		 * list.
 		 */
+		lru = LRU_UNEVICTABLE;
 		add_page_to_unevictable_list(page);
-		mem_cgroup_move_lists(page, LRU_UNEVICTABLE);
+	}
+	mem_cgroup_move_lists(page, lru);
+
+	/*
+	 * page's status can change while we move it among lru. If an evictable
+	 * page is on unevictable list, it never be freed. To avoid that,
+	 * check after we added it to the list, again.
+	 */
+	if (lru == LRU_UNEVICTABLE && page_evictable(page, NULL)) {
+		if (!isolate_lru_page(page)) {
+			put_page(page);
+			goto redo;
+		}
+		/* This means someone else dropped this page from LRU
+		 * So, it will be freed or putback to LRU again. There is
+		 * nothing to do here.
+		 */
 	}
 
 	put_page(page);		/* drop ref from isolate */
-	return ret;		/* ret => "page still locked" */
 }
 
+#else /* CONFIG_UNEVICTABLE_LRU */
+
+void putback_lru_page(struct page *page)
+{
+	int lru;
+	VM_BUG_ON(PageLRU(page));
+
+	lru = !!TestClearPageActive(page) + page_is_file_cache(page);
+	lru_cache_add_lru(page, lru);
+	mem_cgroup_move_lists(page, lru);
+	put_page(page);
+}
+#endif /* CONFIG_UNEVICTABLE_LRU */
+
+
 /*
  * Cull page that shrink_*_list() has detected to be unevictable
  * under page lock to close races with other tasks that might be making
@@ -532,11 +552,14 @@ int putback_lru_page(struct page *page)
  */
 static void cull_unevictable_page(struct page *page)
 {
+	get_page(page);
 	lock_page(page);
-	if (putback_lru_page(page))
-		unlock_page(page);
+	putback_lru_page(page);
+	unlock_page(page);
+	put_page(page);
 }
 
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -571,8 +594,8 @@ static unsigned long shrink_page_list(st
 		sc->nr_scanned++;
 
 		if (unlikely(!page_evictable(page, NULL))) {
-			if (putback_lru_page(page))
-				unlock_page(page);
+			unlock_page(page);
+			putback_lru_page(page);
 			continue;
 		}
 
@@ -2361,8 +2384,6 @@ int zone_reclaim(struct zone *zone, gfp_
 int page_evictable(struct page *page, struct vm_area_struct *vma)
 {
 
-	VM_BUG_ON(PageUnevictable(page));
-
 	/* TODO:  test page [!]evictable conditions */
 
 	return 1;
Index: linux-2.6.26-rc9-mmotm-putback/mm/internal.h
===================================================================
--- linux-2.6.26-rc9-mmotm-putback.orig/mm/internal.h
+++ linux-2.6.26-rc9-mmotm-putback/mm/internal.h
@@ -43,7 +43,7 @@ static inline void __put_page(struct pag
  * in mm/vmscan.c:
  */
 extern int isolate_lru_page(struct page *page);
-extern int putback_lru_page(struct page *page);
+extern void putback_lru_page(struct page *page);
 
 /*
  * in mm/page_alloc.c
Index: linux-2.6.26-rc9-mmotm-putback/mm/migrate.c
===================================================================
--- linux-2.6.26-rc9-mmotm-putback.orig/mm/migrate.c
+++ linux-2.6.26-rc9-mmotm-putback/mm/migrate.c
@@ -67,9 +67,11 @@ int putback_lru_pages(struct list_head *
 
 	list_for_each_entry_safe(page, page2, l, lru) {
 		list_del(&page->lru);
+		get_page(page);
 		lock_page(page);
-		if (putback_lru_page(page))
-			unlock_page(page);
+		putback_lru_page(page);
+		unlock_page(page);
+		put_page(page);
 		count++;
 	}
 	return count;
@@ -577,9 +579,10 @@ static int fallback_migrate_page(struct 
 static int move_to_new_page(struct page *newpage, struct page *page)
 {
 	struct address_space *mapping;
-	int unlock = 1;
 	int rc;
 
+	get_page(newpage); /* for prevent page release under lock_page() */
+
 	/*
 	 * Block others from accessing the page when we get around to
 	 * establishing additional references. We are the only one
@@ -612,16 +615,12 @@ static int move_to_new_page(struct page 
 
 	if (!rc) {
 		remove_migration_ptes(page, newpage);
-		/*
-		 * Put back on LRU while holding page locked to
-		 * handle potential race with, e.g., munlock()
-		 */
-		unlock = putback_lru_page(newpage);
+		putback_lru_page(newpage);
 	} else
 		newpage->mapping = NULL;
 
-	if (unlock)
-		unlock_page(newpage);
+	unlock_page(newpage);
+	put_page(newpage);
 
 	return rc;
 }
@@ -638,14 +637,17 @@ static int unmap_and_move(new_page_t get
 	struct page *newpage = get_new_page(page, private, &result);
 	int rcu_locked = 0;
 	int charge = 0;
-	int unlock = 1;
 
 	if (!newpage)
 		return -ENOMEM;
 
-	if (page_count(page) == 1)
+	if (page_count(page) == 1) {
 		/* page was freed from under us. So we are done. */
+		get_page(page);
 		goto end_migration;
+	}
+
+	get_page(page);
 
 	charge = mem_cgroup_prepare_migration(page, newpage);
 	if (charge == -ENOMEM) {
@@ -728,13 +730,14 @@ unlock:
  		 * restored.
  		 */
  		list_del(&page->lru);
-		unlock = putback_lru_page(page);
+		putback_lru_page(page);
 	}
 
-	if (unlock)
-		unlock_page(page);
+	unlock_page(page);
 
 end_migration:
+	put_page(page);
+
 	if (!charge)
 		mem_cgroup_end_migration(newpage);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
