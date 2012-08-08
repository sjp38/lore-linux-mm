Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id B6C356B0070
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 18:53:50 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v6 3/3] mm: add vm event counters for balloon pages compaction
Date: Wed,  8 Aug 2012 19:53:21 -0300
Message-Id: <768e09520a249fd78f706cd8ae53d511f9db0aaa.1344463786.git.aquini@redhat.com>
In-Reply-To: <cover.1344463786.git.aquini@redhat.com>
References: <cover.1344463786.git.aquini@redhat.com>
In-Reply-To: <cover.1344463786.git.aquini@redhat.com>
References: <cover.1344463786.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@redhat.com>

This patch is only for testing report purposes and shall be dropped in case of
the rest of this patchset getting accepted for merging.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 drivers/virtio/virtio_balloon.c | 1 +
 include/linux/vm_event_item.h   | 2 ++
 mm/compaction.c                 | 1 +
 mm/migrate.c                    | 6 ++++--
 mm/vmstat.c                     | 4 ++++
 5 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 7c937a0..b8f7ea5 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -414,6 +414,7 @@ int virtballoon_migratepage(struct address_space *mapping,
 
 	mutex_unlock(&balloon_lock);
 
+	count_vm_event(COMPACTBALLOONMIGRATED);
 	return 0;
 }
 
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 57f7b10..a632a5d 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -41,6 +41,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #ifdef CONFIG_COMPACTION
 		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
+		COMPACTBALLOONMIGRATED, COMPACTBALLOONFAILED,
+		COMPACTBALLOONISOLATED, COMPACTBALLOONFREED,
 #endif
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
diff --git a/mm/compaction.c b/mm/compaction.c
index 7372592..5d6a344 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -77,6 +77,7 @@ bool isolate_balloon_page(struct page *page)
 			    (page_count(page) == 2)) {
 				__isolate_balloon_page(page);
 				unlock_page(page);
+				count_vm_event(COMPACTBALLOONISOLATED);
 				return true;
 			}
 			unlock_page(page);
diff --git a/mm/migrate.c b/mm/migrate.c
index 871a304..4115875 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -79,9 +79,10 @@ void putback_lru_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (unlikely(movable_balloon_page(page)))
+		if (unlikely(movable_balloon_page(page))) {
+			count_vm_event(COMPACTBALLOONFAILED);
 			WARN_ON(!putback_balloon_page(page));
-		else
+		} else
 			putback_lru_page(page);
 	}
 }
@@ -872,6 +873,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 				    page_is_file_cache(page));
 		put_page(page);
 		__free_page(page);
+		count_vm_event(COMPACTBALLOONFREED);
 		return rc;
 	}
 out:
diff --git a/mm/vmstat.c b/mm/vmstat.c
index df7a674..8d80f60 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -768,6 +768,10 @@ const char * const vmstat_text[] = {
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
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
