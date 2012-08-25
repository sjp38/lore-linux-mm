Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 3FB696B0062
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 01:25:35 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v9 5/5] mm: add vm event counters for balloon pages compaction
Date: Sat, 25 Aug 2012 02:25:00 -0300
Message-Id: <f2341d66d6db776cb143b0151ce16243ee6a39f2.1345869378.git.aquini@redhat.com>
In-Reply-To: <cover.1345869378.git.aquini@redhat.com>
References: <cover.1345869378.git.aquini@redhat.com>
In-Reply-To: <cover.1345869378.git.aquini@redhat.com>
References: <cover.1345869378.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rafael Aquini <aquini@redhat.com>

This patch introduces a new set of vm event counters to keep track of
ballooned pages compaction activity.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 drivers/virtio/virtio_balloon.c |  1 +
 include/linux/vm_event_item.h   |  8 +++++++-
 mm/balloon_compaction.c         |  2 ++
 mm/migrate.c                    |  1 +
 mm/vmstat.c                     | 10 +++++++++-
 5 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 9b0bc46..e1e8e30 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -528,6 +528,7 @@ int virtballoon_migratepage(struct address_space *mapping,
 
 	mutex_unlock(&vb->balloon_lock);
 	wake_up(&vb->config_change);
+	count_balloon_event(COMPACTBALLOONMIGRATED);
 
 	return BALLOON_MIGRATION_RETURN;
 }
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 57f7b10..13573fe 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -41,7 +41,13 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #ifdef CONFIG_COMPACTION
 		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
-#endif
+#ifdef CONFIG_BALLOON_COMPACTION
+		COMPACTBALLOONISOLATED, /* isolated from balloon pagelist */
+		COMPACTBALLOONMIGRATED, /* balloon page sucessfully migrated */
+		COMPACTBALLOONRELEASED, /* old-page released after migration */
+		COMPACTBALLOONRETURNED, /* putback to pagelist, not-migrated */
+#endif /* CONFIG_BALLOON_COMPACTION */
+#endif /* CONFIG_COMPACTION */
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
 #endif
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 86a3692..00e7ea9 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -110,6 +110,7 @@ bool isolate_balloon_page(struct page *page)
 			if (__is_movable_balloon_page(page) &&
 			    (page_count(page) == 2)) {
 				__isolate_balloon_page(page);
+				count_balloon_event(COMPACTBALLOONISOLATED);
 				unlock_page(page);
 				return true;
 			} else if (unlikely(!__is_movable_balloon_page(page))) {
@@ -139,6 +140,7 @@ void putback_balloon_page(struct page *page)
 	if (__is_movable_balloon_page(page)) {
 		__putback_balloon_page(page);
 		put_page(page);
+		count_balloon_event(COMPACTBALLOONRETURNED);
 	} else {
 		dump_page(page);
 		__WARN();
diff --git a/mm/migrate.c b/mm/migrate.c
index e47daf5..124b16b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -896,6 +896,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		list_del(&page->lru);
 		put_page(page);
 		__free_page(page);
+		count_balloon_event(COMPACTBALLOONRELEASED);
 		return 0;
 	}
 out:
diff --git a/mm/vmstat.c b/mm/vmstat.c
index df7a674..5824ad2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -768,7 +768,15 @@ const char * const vmstat_text[] = {
 	"compact_stall",
 	"compact_fail",
 	"compact_success",
-#endif
+
+#ifdef CONFIG_BALLOON_COMPACTION
+	"compact_balloon_isolated",
+	"compact_balloon_migrated",
+	"compact_balloon_released",
+	"compact_balloon_returned",
+#endif /* CONFIG_BALLOON_COMPACTION */
+
+#endif /* CONFIG_COMPACTION */
 
 #ifdef CONFIG_HUGETLB_PAGE
 	"htlb_buddy_alloc_success",
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
