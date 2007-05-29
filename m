From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070529173730.1570.73196.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
References: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 4/7] Introduce isolate_lru_page_nolock() as a lockless version of isolate_lru_page()
Date: Tue, 29 May 2007 18:37:30 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Migration uses isolate_lru_page() to isolate an LRU page. This acquires
the zone->lru_lock to safely remove the page and place it on a private
list. However, this prevents the caller from batching up isolation of
multiple pages.  This patch introduces a nolock version of isolate_lru_page()
for callers that are aware of the locking requirements.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 include/linux/migrate.h |    8 +++++++-
 mm/migrate.c            |   37 +++++++++++++++++++++++++++----------
 2 files changed, 34 insertions(+), 11 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-015_migration_flatmem/include/linux/migrate.h linux-2.6.22-rc2-mm1-020_isolate_nolock/include/linux/migrate.h
--- linux-2.6.22-rc2-mm1-015_migration_flatmem/include/linux/migrate.h	2007-05-29 10:00:09.000000000 +0100
+++ linux-2.6.22-rc2-mm1-020_isolate_nolock/include/linux/migrate.h	2007-05-29 10:18:51.000000000 +0100
@@ -32,6 +32,8 @@ static inline int vma_migratable(struct 
 #endif
 
 #ifdef CONFIG_MIGRATION
+extern int isolate_lru_page_nolock(struct zone *zone, struct page *p,
+						struct list_head *pagelist);
 extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
@@ -47,7 +49,11 @@ extern int migrate_vmas(struct mm_struct
 		const nodemask_t *from, const nodemask_t *to,
 		unsigned long flags);
 #else
-
+static inline int isolate_lru_page_nolock(struct zone *zone, struct page *p,
+						struct list_head *list)
+{
+	return -ENOSYS;
+}
 static inline int isolate_lru_page(struct page *p, struct list_head *list)
 					{ return -ENOSYS; }
 static inline int putback_lru_pages(struct list_head *l) { return 0; }
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-015_migration_flatmem/mm/migrate.c linux-2.6.22-rc2-mm1-020_isolate_nolock/mm/migrate.c
--- linux-2.6.22-rc2-mm1-015_migration_flatmem/mm/migrate.c	2007-05-29 10:01:40.000000000 +0100
+++ linux-2.6.22-rc2-mm1-020_isolate_nolock/mm/migrate.c	2007-05-29 10:18:51.000000000 +0100
@@ -41,6 +41,32 @@
  *  -EBUSY: page not on LRU list
  *  0: page removed from LRU list and added to the specified list.
  */
+int isolate_lru_page_nolock(struct zone *zone, struct page *page,
+						struct list_head *pagelist)
+{
+	int ret = -EBUSY;
+
+	if (PageLRU(page)) {
+		ret = 0;
+		get_page(page);
+		ClearPageLRU(page);
+		if (PageActive(page))
+			del_page_from_active_list(zone, page);
+		else
+			del_page_from_inactive_list(zone, page);
+		list_add_tail(&page->lru, pagelist);
+	}
+	return ret;
+}
+
+/*
+ * Acquire the zone->lru_lock and isolate one page from the LRU lists. If
+ * successful put it onto the indicated list with elevated page count.
+ *
+ * Result:
+ *  -EBUSY: page not on LRU list
+ *  0: page removed from LRU list and added to the specified list.
+ */
 int isolate_lru_page(struct page *page, struct list_head *pagelist)
 {
 	int ret = -EBUSY;
@@ -49,16 +75,7 @@ int isolate_lru_page(struct page *page, 
 		struct zone *zone = page_zone(page);
 
 		spin_lock_irq(&zone->lru_lock);
-		if (PageLRU(page)) {
-			ret = 0;
-			get_page(page);
-			ClearPageLRU(page);
-			if (PageActive(page))
-				del_page_from_active_list(zone, page);
-			else
-				del_page_from_inactive_list(zone, page);
-			list_add_tail(&page->lru, pagelist);
-		}
+		ret = isolate_lru_page_nolock(zone, page, pagelist);
 		spin_unlock_irq(&zone->lru_lock);
 	}
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
