Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 1A9EA6B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 12:51:21 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v4 1/3] mm: introduce compaction and migration for virtio ballooned pages
Date: Tue, 17 Jul 2012 13:50:41 -0300
Message-Id: <49f828a9331c9b729fcf77226006921ec5bc52fa.1342485774.git.aquini@redhat.com>
In-Reply-To: <cover.1342485774.git.aquini@redhat.com>
References: <cover.1342485774.git.aquini@redhat.com>
In-Reply-To: <cover.1342485774.git.aquini@redhat.com>
References: <cover.1342485774.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@linux.com>, Rafael Aquini <aquini@redhat.com>

This patch introduces the helper functions as well as the necessary changes
to teach compaction and migration bits how to cope with pages which are
part of a guest memory balloon, in order to make them movable by memory
compaction procedures.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 include/linux/mm.h |   15 +++++++
 mm/compaction.c    |  126 ++++++++++++++++++++++++++++++++++++++++++++--------
 mm/migrate.c       |   30 ++++++++++++-
 3 files changed, 151 insertions(+), 20 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b36d08c..3112198 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1629,5 +1629,20 @@ static inline unsigned int debug_guardpage_minorder(void) { return 0; }
 static inline bool page_is_guard(struct page *page) { return false; }
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
+#if (defined(CONFIG_VIRTIO_BALLOON) || \
+	defined(CONFIG_VIRTIO_BALLOON_MODULE)) && defined(CONFIG_COMPACTION)
+extern bool putback_balloon_page(struct page *);
+extern struct address_space *balloon_mapping;
+
+static inline bool is_balloon_page(struct page *page)
+{
+	return (page->mapping == balloon_mapping) ? true : false;
+}
+#else
+static inline bool is_balloon_page(struct page *page)       { return false; }
+static inline bool isolate_balloon_page(struct page *page)  { return false; }
+static inline bool putback_balloon_page(struct page *page)  { return false; }
+#endif /* (VIRTIO_BALLOON || VIRTIO_BALLOON_MODULE) && COMPACTION */
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/mm/compaction.c b/mm/compaction.c
index 2f42d95..51eac0c 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -14,6 +14,7 @@
 #include <linux/backing-dev.h>
 #include <linux/sysctl.h>
 #include <linux/sysfs.h>
+#include <linux/export.h>
 #include "internal.h"
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
@@ -21,6 +22,85 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/compaction.h>
 
+#if defined(CONFIG_VIRTIO_BALLOON) || defined(CONFIG_VIRTIO_BALLOON_MODULE)
+/*
+ * Balloon pages special page->mapping.
+ * Users must properly allocate and initialize an instance of balloon_mapping,
+ * and set it as the page->mapping for balloon enlisted page instances.
+ * There is no need on utilizing struct address_space locking schemes for
+ * balloon_mapping as, once it gets initialized at balloon driver, it will
+ * remain just like a static reference that helps us on identifying a guest
+ * ballooned page by its mapping, as well as it will keep the 'a_ops' callback
+ * pointers to the functions that will execute the balloon page mobility tasks.
+ *
+ * address_space_operations necessary methods for ballooned pages:
+ *   .migratepage    - used to perform balloon's page migration (as is)
+ *   .invalidatepage - used to isolate a page from balloon's page list
+ *   .freepage       - used to reinsert an isolated page to balloon's page list
+ */
+struct address_space *balloon_mapping;
+EXPORT_SYMBOL_GPL(balloon_mapping);
+
+static inline void __isolate_balloon_page(struct page *page)
+{
+	page->mapping->a_ops->invalidatepage(page, 0);
+}
+
+static inline void __putback_balloon_page(struct page *page)
+{
+	page->mapping->a_ops->freepage(page);
+}
+
+/* __isolate_lru_page() counterpart for a ballooned page */
+static bool isolate_balloon_page(struct page *page)
+{
+	if (WARN_ON(!is_balloon_page(page)))
+		return false;
+
+	if (likely(get_page_unless_zero(page))) {
+		/*
+		 * We can race against move_to_new_page() & __unmap_and_move().
+		 * If we stumble across a locked balloon page and succeed on
+		 * isolating it, the result tends to be disastrous.
+		 */
+		if (likely(trylock_page(page))) {
+			/*
+			 * A ballooned page, by default, has just one refcount.
+			 * Prevent concurrent compaction threads from isolating
+			 * an already isolated balloon page.
+			 */
+			if (is_balloon_page(page) && (page_count(page) == 2)) {
+				__isolate_balloon_page(page);
+				unlock_page(page);
+				return true;
+			}
+			unlock_page(page);
+		}
+		/* Drop refcount taken for this already isolated page */
+		put_page(page);
+	}
+	return false;
+}
+
+/* putback_lru_page() counterpart for a ballooned page */
+bool putback_balloon_page(struct page *page)
+{
+	if (WARN_ON(!is_balloon_page(page)))
+		return false;
+
+	if (likely(trylock_page(page))) {
+		if (is_balloon_page(page)) {
+			__putback_balloon_page(page);
+			put_page(page);
+			unlock_page(page);
+			return true;
+		}
+		unlock_page(page);
+	}
+	return false;
+}
+#endif /* CONFIG_VIRTIO_BALLOON || CONFIG_VIRTIO_BALLOON_MODULE */
+
 static unsigned long release_freepages(struct list_head *freelist)
 {
 	struct page *page, *next;
@@ -312,32 +392,40 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			continue;
 		}
 
-		if (!PageLRU(page))
-			continue;
-
 		/*
-		 * PageLRU is set, and lru_lock excludes isolation,
-		 * splitting and collapsing (collapsing has already
-		 * happened if PageLRU is set).
+		 * It is possible to migrate LRU pages and balloon pages.
+		 * Skip any other type of page.
 		 */
-		if (PageTransHuge(page)) {
-			low_pfn += (1 << compound_order(page)) - 1;
-			continue;
-		}
+		if (PageLRU(page)) {
+			/*
+			 * PageLRU is set, and lru_lock excludes isolation,
+			 * splitting and collapsing (collapsing has already
+			 * happened if PageLRU is set).
+			 */
+			if (PageTransHuge(page)) {
+				low_pfn += (1 << compound_order(page)) - 1;
+				continue;
+			}
 
-		if (!cc->sync)
-			mode |= ISOLATE_ASYNC_MIGRATE;
+			if (!cc->sync)
+				mode |= ISOLATE_ASYNC_MIGRATE;
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+			lruvec = mem_cgroup_page_lruvec(page, zone);
 
-		/* Try isolate the page */
-		if (__isolate_lru_page(page, mode) != 0)
-			continue;
+			/* Try isolate the page */
+			if (__isolate_lru_page(page, mode) != 0)
+				continue;
+
+			VM_BUG_ON(PageTransCompound(page));
 
-		VM_BUG_ON(PageTransCompound(page));
+			/* Successfully isolated */
+			del_page_from_lru_list(page, lruvec, page_lru(page));
+		} else if (is_balloon_page(page)) {
+			if (!isolate_balloon_page(page))
+				continue;
+		} else
+			continue;
 
-		/* Successfully isolated */
-		del_page_from_lru_list(page, lruvec, page_lru(page));
 		list_add(&page->lru, migratelist);
 		cc->nr_migratepages++;
 		nr_isolated++;
diff --git a/mm/migrate.c b/mm/migrate.c
index be26d5c..59c7bc5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -78,7 +78,10 @@ void putback_lru_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		putback_lru_page(page);
+		if (unlikely(is_balloon_page(page)))
+			WARN_ON(!putback_balloon_page(page));
+		else
+			putback_lru_page(page);
 	}
 }
 
@@ -783,6 +786,17 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 	}
 
+	if (is_balloon_page(page)) {
+		/*
+		 * A ballooned page does not need any special attention from
+		 * physical to virtual reverse mapping procedures.
+		 * Skip any attempt to unmap PTEs or to remap swap cache,
+		 * in order to avoid burning cycles at rmap level.
+		 */
+		remap_swapcache = 0;
+		goto skip_unmap;
+	}
+
 	/*
 	 * Corner case handling:
 	 * 1. When a new swap-cache page is read into, it is added to the LRU
@@ -852,6 +866,20 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 			goto out;
 
 	rc = __unmap_and_move(page, newpage, force, offlining, mode);
+
+	if (is_balloon_page(newpage)) {
+		/*
+		 * A ballooned page has been migrated already. Now, it is the
+		 * time to wrap-up counters, handle the old page back to Buddy
+		 * and return.
+		 */
+		list_del(&page->lru);
+		dec_zone_page_state(page, NR_ISOLATED_ANON +
+				    page_is_file_cache(page));
+		put_page(page);
+		__free_page(page);
+		return rc;
+	}
 out:
 	if (rc != -EAGAIN) {
 		/*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
