Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 6C89B6B00AA
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 19:50:00 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v3 4/4] mm: add vm event counters for balloon pages compaction
Date: Tue,  3 Jul 2012 20:48:52 -0300
Message-Id: <6145b865655933ffdcb8f1e7c9732539ee098bf2.1341353014.git.aquini@redhat.com>
In-Reply-To: <cover.1341353014.git.aquini@redhat.com>
References: <cover.1341353014.git.aquini@redhat.com>
In-Reply-To: <cover.1341353014.git.aquini@redhat.com>
References: <cover.1341353014.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@redhat.com>

This patch is only for testing report purposes and shall be dropped in case of
the rest of this patchset getting accepted for merging.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 drivers/virtio/virtio_balloon.c |    1 +
 include/linux/vm_event_item.h   |    2 ++
 mm/compaction.c                 |    1 +
 mm/migrate.c                    |    6 ++++--
 mm/vmstat.c                     |    4 ++++
 5 files changed, 12 insertions(+), 2 deletions(-)

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
index 887d0fc..8f7df01 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -72,6 +72,7 @@ static bool isolate_balloon_page(struct page *page)
 			if (is_balloon_page(page) && (page_count(page) == 2)) {
 				__isolate_balloon_page(page);
 				unlock_page(page);
+				count_vm_event(COMPACTBALLOONISOLATED);
 				return true;
 			}
 			unlock_page(page);
diff --git a/mm/migrate.c b/mm/migrate.c
index 59c7bc5..5838719 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -78,9 +78,10 @@ void putback_lru_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (unlikely(is_balloon_page(page)))
+		if (unlikely(is_balloon_page(page))) {
+			count_vm_event(COMPACTBALLOONFAILED);
 			WARN_ON(!putback_balloon_page(page));
-		else
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
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
