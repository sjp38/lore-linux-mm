Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 6EDE36B0062
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 09:57:36 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v5 3/3] mm: add vm event counters for balloon pages compaction
Date: Mon,  6 Aug 2012 10:56:52 -0300
Message-Id: <aa36210e84544ae4d91fc1f94c7d7816595cb29e.1344259054.git.aquini@redhat.com>
In-Reply-To: <cover.1344259054.git.aquini@redhat.com>
References: <cover.1344259054.git.aquini@redhat.com>
In-Reply-To: <cover.1344259054.git.aquini@redhat.com>
References: <cover.1344259054.git.aquini@redhat.com>
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
index 9499d85..4e2e46a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -76,6 +76,7 @@ bool isolate_balloon_page(struct page *page)
 			if (is_balloon_page(page) && (page_count(page) == 2)) {
 				__isolate_balloon_page(page);
 				unlock_page(page);
+				count_vm_event(COMPACTBALLOONISOLATED);
 				return true;
 			}
 			unlock_page(page);
diff --git a/mm/migrate.c b/mm/migrate.c
index fc56968..f98804a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -80,9 +80,10 @@ void putback_lru_pages(struct list_head *l)
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
 		if (unlikely(is_balloon_page(page) &&
-		    balloon_compaction_enabled()))
+		    balloon_compaction_enabled())) {
+			count_vm_event(COMPACTBALLOONFAILED);
 			WARN_ON(!putback_balloon_page(page));
-		else
+		} else
 			putback_lru_page(page);
 	}
 }
@@ -874,6 +875,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
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
