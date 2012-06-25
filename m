Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id A5EF56B03B7
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 19:26:15 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH 4/4] mm: add vm event counters for balloon pages compaction
Date: Mon, 25 Jun 2012 20:25:59 -0300
Message-Id: <da3d24a93ea248a7bbe107846385428b0cf6f8a6.1340665087.git.aquini@redhat.com>
In-Reply-To: <cover.1340665087.git.aquini@redhat.com>
References: <cover.1340665087.git.aquini@redhat.com>
In-Reply-To: <cover.1340665087.git.aquini@redhat.com>
References: <cover.1340665087.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>

This patch is only for testing report purposes and shall be dropped in case of
the rest of this patchset getting accepted for merging.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 drivers/virtio/virtio_balloon.c |    1 +
 include/linux/vm_event_item.h   |    2 ++
 mm/compaction.c                 |    4 +++-
 mm/migrate.c                    |    6 ++++--
 mm/vmstat.c                     |    4 ++++
 5 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 53386aa..c4a929d 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -406,6 +406,7 @@ int virtballoon_migratepage(struct address_space *mapping,
 	spin_unlock(&vb->pfn_list_lock);
 	tell_host(vb, vb->deflate_vq, &sg);
 
+	count_vm_event(COMPACTBALLOONMIGRATED);
 	return 0;
 }
 
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 06f8e38..e330c5a 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -40,6 +40,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #ifdef CONFIG_COMPACTION
 		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
+		COMPACTBALLOONMIGRATED, COMPACTBALLOONFAILED,
+		COMPACTBALLOONISOLATED, COMPACTBALLOONFREED,
 #endif
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
diff --git a/mm/compaction.c b/mm/compaction.c
index 8835d55..cf250b8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -318,8 +318,10 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		 * for PageLRU, as well as skip the LRU page isolation steps.
 		 */
 		if (PageBalloon(page))
-			if (isolate_balloon_page(page))
+			if (isolate_balloon_page(page)) {
+				count_vm_event(COMPACTBALLOONISOLATED);
 				goto isolated_balloon_page;
+		}
 
 		if (!PageLRU(page))
 			continue;
diff --git a/mm/migrate.c b/mm/migrate.c
index ffc02a4..3dbca33 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -78,9 +78,10 @@ void putback_lru_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (unlikely(PageBalloon(page)))
+		if (unlikely(PageBalloon(page))) {
 			VM_BUG_ON(!putback_balloon_page(page));
-		else
+			count_vm_event(COMPACTBALLOONFAILED);
+		} else
 			putback_lru_page(page);
 	}
 }
@@ -878,6 +879,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 				    page_is_file_cache(page));
 		put_page(page);
 		__free_page(page);
+		count_vm_event(COMPACTBALLOONFREED);
 		return rc;
 	}
 out:
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1bbbbd9..3b7109f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -767,6 +767,10 @@ const char * const vmstat_text[] = {
 	"compact_stall",
 	"compact_fail",
 	"compact_success",
+	"compact_balloon_migrated",
+	"compact_balloon_failed",
+	"compact_balloon_isolated",
+	"compact_balloon_freed",
 #endif
 
 #ifdef CONFIG_HUGETLB_PAGE
-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
