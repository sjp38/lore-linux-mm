Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 6DB8F6B006C
	for <linux-mm@kvack.org>; Sun, 11 Nov 2012 14:02:12 -0500 (EST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v12 7/7] mm: add vm event counters for balloon pages compaction
Date: Sun, 11 Nov 2012 17:01:20 -0200
Message-Id: <005a797720c0759e73f83db0d4fc02d511e484f6.1352656285.git.aquini@redhat.com>
In-Reply-To: <cover.1352656285.git.aquini@redhat.com>
References: <cover.1352656285.git.aquini@redhat.com>
In-Reply-To: <cover.1352656285.git.aquini@redhat.com>
References: <cover.1352656285.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "Michael S. Tsirkin" <mst@redhat.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, aquini@redhat.com

This patch introduces a new set of vm event counters to keep track of
ballooned pages compaction activity.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 include/linux/balloon_compaction.h | 7 +++++++
 include/linux/vm_event_item.h      | 7 ++++++-
 mm/balloon_compaction.c            | 2 ++
 mm/migrate.c                       | 1 +
 mm/vmstat.c                        | 9 ++++++++-
 5 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index 2e63d94..68893bc 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -197,8 +197,15 @@ static inline bool balloon_compaction_check(void)
 	return true;
 }
 
+static inline void balloon_event_count(enum vm_event_item item)
+{
+	count_vm_event(item);
+}
 #else /* !CONFIG_BALLOON_COMPACTION */
 
+/* A macro, to avoid generating references to the undefined COMPACTBALLOON* */
+#define balloon_event_count(item) do { } while (0)
+
 static inline void *balloon_mapping_alloc(void *balloon_device,
 				const struct address_space_operations *a_ops)
 {
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 3d31145..bd67c3f 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -41,7 +41,12 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #ifdef CONFIG_COMPACTION
 		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
-#endif
+#ifdef CONFIG_BALLOON_COMPACTION
+		COMPACTBALLOONISOLATED, /* isolated from balloon pagelist */
+		COMPACTBALLOONMIGRATED, /* balloon page sucessfully migrated */
+		COMPACTBALLOONRETURNED, /* putback to pagelist, not-migrated */
+#endif /* CONFIG_BALLOON_COMPACTION */
+#endif /* CONFIG_COMPACTION */
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
 #endif
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 07dbc8e..2c8ce49 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -242,6 +242,7 @@ bool balloon_page_isolate(struct page *page)
 			if (__is_movable_balloon_page(page) &&
 			    page_count(page) == 2) {
 				__isolate_balloon_page(page);
+				balloon_event_count(COMPACTBALLOONISOLATED);
 				unlock_page(page);
 				return true;
 			}
@@ -265,6 +266,7 @@ void balloon_page_putback(struct page *page)
 		__putback_balloon_page(page);
 		/* drop the extra ref count taken for page isolation */
 		put_page(page);
+		balloon_event_count(COMPACTBALLOONRETURNED);
 	} else {
 		WARN_ON(1);
 		dump_page(page);
diff --git a/mm/migrate.c b/mm/migrate.c
index 107a281..ecae213 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -894,6 +894,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				    page_is_file_cache(page));
 		balloon_page_free(page);
+		balloon_event_count(COMPACTBALLOONMIGRATED);
 		return MIGRATEPAGE_SUCCESS;
 	}
 out:
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c737057..18a76ea 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -781,7 +781,14 @@ const char * const vmstat_text[] = {
 	"compact_stall",
 	"compact_fail",
 	"compact_success",
-#endif
+
+#ifdef CONFIG_BALLOON_COMPACTION
+	"compact_balloon_isolated",
+	"compact_balloon_migrated",
+	"compact_balloon_returned",
+#endif /* CONFIG_BALLOON_COMPACTION */
+
+#endif /* CONFIG_COMPACTION */
 
 #ifdef CONFIG_HUGETLB_PAGE
 	"htlb_buddy_alloc_success",
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
