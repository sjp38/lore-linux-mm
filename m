From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070618092921.7790.78151.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/7] Introduce isolate_lru_page_nolock() as a lockless version of isolate_lru_page()
Date: Mon, 18 Jun 2007 10:29:21 +0100 (IST)
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
 mm/migrate.c            |   36 +++++++++++++++++++++++++++---------
 2 files changed, 34 insertions(+), 10 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-015_migration_flatmem/include/linux/migrate.h linux-2.6.22-rc4-mm2-020_isolate_nolock/include/linux/migrate.h
--- linux-2.6.22-rc4-mm2-015_migration_flatmem/include/linux/migrate.h	2007-06-15 16:25:37.000000000 +0100
+++ linux-2.6.22-rc4-mm2-020_isolate_nolock/include/linux/migrate.h	2007-06-15 16:25:46.000000000 +0100
@@ -27,6 +27,8 @@ static inline int vma_migratable(struct 
 #endif
 
 #ifdef CONFIG_MIGRATION
+extern int locked_isolate_lru_page(struct zone *zone, struct page *p,
+						struct list_head *pagelist);
 extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
@@ -41,7 +43,11 @@ extern int migrate_vmas(struct mm_struct
 		const nodemask_t *from, const nodemask_t *to,
 		unsigned long flags);
 #else
-
+static inline int locked_isolate_lru_page(struct zone *zone, struct page *p,
+						struct list_head *list)
+{
+	return -ENOSYS;
+}
 static inline int isolate_lru_page(struct page *p, struct list_head *list)
 					{ return -ENOSYS; }
 static inline int putback_lru_pages(struct list_head *l) { return 0; }
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-015_migration_flatmem/mm/migrate.c linux-2.6.22-rc4-mm2-020_isolate_nolock/mm/migrate.c
--- linux-2.6.22-rc4-mm2-015_migration_flatmem/mm/migrate.c	2007-06-15 16:25:31.000000000 +0100
+++ linux-2.6.22-rc4-mm2-020_isolate_nolock/mm/migrate.c	2007-06-15 16:25:46.000000000 +0100
@@ -41,6 +41,32 @@
  *  -EBUSY: page not on LRU list
  *  0: page removed from LRU list and added to the specified list.
  */
+int locked_isolate_lru_page(struct zone *zone, struct page *page,
+						struct list_head *pagelist)
+{
+	int ret = -EBUSY;
+
+	if (PageLRU(page) && get_page_unless_zero(page)) {
+		ret = 0;
+		ClearPageLRU(page);
+		if (PageActive(page))
+			del_page_from_active_list(zone, page);
+		else
+			del_page_from_inactive_list(zone, page);
+		list_add_tail(&page->lru, pagelist);
+	}
+
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
@@ -49,15 +75,7 @@ int isolate_lru_page(struct page *page, 
 		struct zone *zone = page_zone(page);
 
 		spin_lock_irq(&zone->lru_lock);
-		if (PageLRU(page) && get_page_unless_zero(page)) {
-			ret = 0;
-			ClearPageLRU(page);
-			if (PageActive(page))
-				del_page_from_active_list(zone, page);
-			else
-				del_page_from_inactive_list(zone, page);
-			list_add_tail(&page->lru, pagelist);
-		}
+		ret = locked_isolate_lru_page(zone, page, pagelist);
 		spin_unlock_irq(&zone->lru_lock);
 	}
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
