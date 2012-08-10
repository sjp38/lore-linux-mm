Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id B096C6B0062
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 13:55:42 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v7 4/4] mm: add vm event counters for balloon pages compaction
Date: Fri, 10 Aug 2012 14:55:17 -0300
Message-Id: <f7dbe40a97ed7af3bb7281ca1f7e4107ea2460d7.1344619987.git.aquini@redhat.com>
In-Reply-To: <cover.1344619987.git.aquini@redhat.com>
References: <cover.1344619987.git.aquini@redhat.com>
In-Reply-To: <cover.1344619987.git.aquini@redhat.com>
References: <cover.1344619987.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@redhat.com>

This patch introduces a new set of vm event counters to keep track of
ballooned pages compaction activity.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 drivers/virtio/virtio_balloon.c |  1 +
 include/linux/vm_event_item.h   |  8 +++++++-
 mm/compaction.c                 |  2 ++
 mm/migrate.c                    |  1 +
 mm/vmstat.c                     | 10 +++++++++-
 5 files changed, 20 insertions(+), 2 deletions(-)

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
index 57f7b10..b1841a2 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -41,7 +41,13 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #ifdef CONFIG_COMPACTION
 		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
-#endif
+#if defined(CONFIG_VIRTIO_BALLOON) || defined(CONFIG_VIRTIO_BALLOON_MODULE)
+		COMPACTBALLOONISOLATED, /* isolated from balloon pagelist */
+		COMPACTBALLOONMIGRATED, /* balloon page sucessfully migrated */
+		COMPACTBALLOONRETURNED, /* putback to pagelist, not-migrated */
+		COMPACTBALLOONRELEASED, /* old-page released after migration */
+#endif /* CONFIG_VIRTIO_BALLOON || CONFIG_VIRTIO_BALLOON_MODULE */
+#endif /* CONFIG_COMPACTION */
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
 #endif
diff --git a/mm/compaction.c b/mm/compaction.c
index 8567bb8..ff0f9ac 100644
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
@@ -97,6 +98,7 @@ void putback_balloon_page(struct page *page)
 	__putback_balloon_page(page);
 	put_page(page);
 	unlock_page(page);
+	count_vm_event(COMPACTBALLOONRETURNED);
 }
 #endif /* CONFIG_VIRTIO_BALLOON || CONFIG_VIRTIO_BALLOON_MODULE */
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 1165134..024566f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -892,6 +892,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 				    page_is_file_cache(page));
 		put_page(page);
 		__free_page(page);
+		count_vm_event(COMPACTBALLOONRELEASED);
 		return rc;
 	}
 out:
diff --git a/mm/vmstat.c b/mm/vmstat.c
index df7a674..ad5c4f1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -768,7 +768,15 @@ const char * const vmstat_text[] = {
 	"compact_stall",
 	"compact_fail",
 	"compact_success",
-#endif
+
+#if defined(CONFIG_VIRTIO_BALLOON) || defined(CONFIG_VIRTIO_BALLOON_MODULE)
+	"compact_balloon_isolated",
+	"compact_balloon_migrated",
+	"compact_balloon_returned",
+	"compact_balloon_released",
+#endif /* CONFIG_VIRTIO_BALLOON || CONFIG_VIRTIO_BALLOON_MODULE */
+
+#endif /* CONFIG_COMPACTION */
 
 #ifdef CONFIG_HUGETLB_PAGE
 	"htlb_buddy_alloc_success",
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
