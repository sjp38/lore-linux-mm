Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 3FDE76B0068
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 22:06:47 -0500 (EST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v11 6/7] mm: introduce putback_movable_pages()
Date: Wed,  7 Nov 2012 01:05:53 -0200
Message-Id: <639cdcd9df56b22e2d46c6aecb3e4dda8fef9ee6.1352256088.git.aquini@redhat.com>
In-Reply-To: <cover.1352256081.git.aquini@redhat.com>
References: <cover.1352256081.git.aquini@redhat.com>
In-Reply-To: <cover.1352256081.git.aquini@redhat.com>
References: <cover.1352256081.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, aquini@redhat.com

The PATCH "mm: introduce compaction and migration for virtio ballooned pages"
hacks around putback_lru_pages() in order to allow ballooned pages to be
re-inserted on balloon page list as if a ballooned page was like a LRU page.

As ballooned pages are not legitimate LRU pages, this patch introduces
putback_movable_pages() to properly cope with cases where the isolated
pageset contains ballooned pages and LRU pages, thus fixing the mentioned
inelegant hack around putback_lru_pages().

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 include/linux/migrate.h |  2 ++
 mm/compaction.c         |  6 +++---
 mm/migrate.c            | 20 ++++++++++++++++++++
 mm/page_alloc.c         |  2 +-
 4 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index e570c3c..ff074a4 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -27,6 +27,7 @@ typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 #ifdef CONFIG_MIGRATION
 
 extern void putback_lru_pages(struct list_head *l);
+extern void putback_movable_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
 extern int migrate_pages(struct list_head *l, new_page_t x,
@@ -50,6 +51,7 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 #else
 
 static inline void putback_lru_pages(struct list_head *l) {}
+static inline void putback_movable_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
 		enum migrate_mode mode) { return -ENOSYS; }
diff --git a/mm/compaction.c b/mm/compaction.c
index 76abd84..f268bd8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -995,7 +995,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		switch (isolate_migratepages(zone, cc)) {
 		case ISOLATE_ABORT:
 			ret = COMPACT_PARTIAL;
-			putback_lru_pages(&cc->migratepages);
+			putback_movable_pages(&cc->migratepages);
 			cc->nr_migratepages = 0;
 			goto out;
 		case ISOLATE_NONE:
@@ -1018,9 +1018,9 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		trace_mm_compaction_migratepages(nr_migrate - nr_remaining,
 						nr_remaining);
 
-		/* Release LRU pages not migrated */
+		/* Release isolated pages not migrated */
 		if (err) {
-			putback_lru_pages(&cc->migratepages);
+			putback_movable_pages(&cc->migratepages);
 			cc->nr_migratepages = 0;
 			if (err == -ENOMEM) {
 				ret = COMPACT_PARTIAL;
diff --git a/mm/migrate.c b/mm/migrate.c
index 87ffe54..adb3d44 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -80,6 +80,26 @@ void putback_lru_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
+			putback_lru_page(page);
+	}
+}
+
+/*
+ * Put previously isolated pages back onto the appropriate lists
+ * from where they were once taken off for compaction/migration.
+ *
+ * This function shall be used instead of putback_lru_pages(),
+ * whenever the isolated pageset has been built by isolate_migratepages_range()
+ */
+void putback_movable_pages(struct list_head *l)
+{
+	struct page *page;
+	struct page *page2;
+
+	list_for_each_entry_safe(page, page2, l, lru) {
+		list_del(&page->lru);
+		dec_zone_page_state(page, NR_ISOLATED_ANON +
+				page_is_file_cache(page));
 		if (unlikely(balloon_page_movable(page)))
 			balloon_page_putback(page);
 		else
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5b74de6..1cb0f93 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5710,7 +5710,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 				    0, false, MIGRATE_SYNC);
 	}
 
-	putback_lru_pages(&cc->migratepages);
+	putback_movable_pages(&cc->migratepages);
 	return ret > 0 ? 0 : ret;
 }
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
