Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 4FA9D6B0074
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 08:48:22 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v8 5/5] mm: add vm event counters for balloon pages compaction
Date: Tue, 21 Aug 2012 09:47:48 -0300
Message-Id: <d0f95add5e2d9b05abd5c4205f98c91a1d48bcf6.1345519422.git.aquini@redhat.com>
In-Reply-To: <cover.1345519422.git.aquini@redhat.com>
References: <cover.1345519422.git.aquini@redhat.com>
In-Reply-To: <cover.1345519422.git.aquini@redhat.com>
References: <cover.1345519422.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@redhat.com>

This patch introduces a new set of vm event counters to keep track of
ballooned pages compaction activity.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 drivers/virtio/virtio_balloon.c |  2 ++
 include/linux/vm_event_item.h   |  8 +++++++-
 mm/balloon_compaction.c         |  6 ++++--
 mm/migrate.c                    |  1 +
 mm/vmstat.c                     | 10 +++++++++-
 5 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index bda7bb0..c358ed3 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -449,6 +449,8 @@ int virtballoon_migratepage(struct address_space *mapping,
 	set_page_pfns(vb->pfns, page);
 	tell_host(vb, vb->deflate_vq);
 
+	/* perform vm accountability on this successful page migration */
+	count_balloon_event(COMPACTBALLOONMIGRATED);
 	mutex_unlock(&vb->balloon_lock);
 	return 0;
 }
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 57f7b10..6868aba 100644
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
+		COMPACTBALLOONRETURNED, /* putback to pagelist, not-migrated */
+		COMPACTBALLOONRELEASED, /* old-page released after migration */
+#endif /* CONFIG_BALLOON_COMPACTION */
+#endif /* CONFIG_COMPACTION */
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
 #endif
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index d79f13d..9186000 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -114,6 +114,7 @@ bool isolate_balloon_page(struct page *page)
 			    (page_count(page) == 2)) {
 				if (__isolate_balloon_page(page)) {
 					unlock_page(page);
+					count_vm_event(COMPACTBALLOONISOLATED);
 					return true;
 				}
 			}
@@ -137,9 +138,10 @@ void putback_balloon_page(struct page *page)
 	 * concurrent isolation threads attempting to re-isolate it.
 	 */
 	lock_page(page);
-	if (movable_balloon_page(page))
+	if (movable_balloon_page(page)) {
 		__putback_balloon_page(page);
-
+		count_vm_event(COMPACTBALLOONRETURNED);
+	}
 	unlock_page(page);
 }
 #endif /* CONFIG_BALLOON_COMPACTION */
diff --git a/mm/migrate.c b/mm/migrate.c
index 0bf2caf..052e59a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -893,6 +893,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 				    page_is_file_cache(page));
 		put_page(page);
 		__free_page(page);
+		count_balloon_event(COMPACTBALLOONRELEASED);
 		return rc;
 	}
 out:
diff --git a/mm/vmstat.c b/mm/vmstat.c
index df7a674..c7919c4 100644
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
+	"compact_balloon_returned",
+	"compact_balloon_released",
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
