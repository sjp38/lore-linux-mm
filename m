Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 73A396B0034
	for <linux-mm@kvack.org>; Sat, 11 May 2013 13:42:09 -0400 (EDT)
Received: by mail-da0-f46.google.com with SMTP id e20so2810628dak.5
        for <linux-mm@kvack.org>; Sat, 11 May 2013 10:42:08 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part3 13/16] mm: correctly update zone->mamaged_pages
Date: Sun, 12 May 2013 01:34:46 +0800
Message-Id: <1368293689-16410-14-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368293689-16410-1-git-send-email-jiang.liu@huawei.com>
References: <1368293689-16410-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, virtualization@lists.linux-foundation.org, xen-devel@lists.xensource.com

Enhance adjust_managed_page_count() to adjust totalhigh_pages for
highmem pages. And change code which directly adjusts totalram_pages
to use adjust_managed_page_count() because it adjusts totalram_pages,
totalhigh_pages and zone->managed_pages altogether in a safe way.

Remove inc_totalhigh_pages() and dec_totalhigh_pages() from xen/balloon
driver bacause adjust_managed_page_count() has already adjusted
totalhigh_pages.

This patch also fixes two bugs:
1) enhances virtio_balloon driver to adjust totalhigh_pages when
   reserve/unreserve pages.
2) enhance memory_hotplug.c to adjust totalhigh_pages when hot-removing
   memory.

We still need to deal with modifications of totalram_pages in file
arch/powerpc/platforms/pseries/cmm.c, but need help from PPC experts.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org
Cc: xen-devel@lists.xensource.com
Cc: linux-mm@kvack.org
---
 drivers/virtio/virtio_balloon.c |  8 +++++---
 drivers/xen/balloon.c           | 23 +++++------------------
 mm/hugetlb.c                    |  2 +-
 mm/memory_hotplug.c             | 15 +++------------
 mm/page_alloc.c                 | 10 +++++-----
 5 files changed, 19 insertions(+), 39 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index bd3ae32..6649968 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -148,7 +148,7 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 		}
 		set_page_pfns(vb->pfns + vb->num_pfns, page);
 		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
-		totalram_pages--;
+		adjust_managed_page_count(page, -1);
 	}
 
 	/* Did we get any? */
@@ -160,11 +160,13 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
 {
 	unsigned int i;
+	struct page *page;
 
 	/* Find pfns pointing at start of each page, get pages and free them. */
 	for (i = 0; i < num; i += VIRTIO_BALLOON_PAGES_PER_PAGE) {
-		balloon_page_free(balloon_pfn_to_page(pfns[i]));
-		totalram_pages++;
+		page = balloon_pfn_to_page(pfns[i]);
+		balloon_page_free(page);
+		adjust_managed_page_count(page, 1);
 	}
 }
 
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index d42da3b..a453c05 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -89,14 +89,6 @@ EXPORT_SYMBOL_GPL(balloon_stats);
 /* We increase/decrease in batches which fit in a page */
 static xen_pfn_t frame_list[PAGE_SIZE / sizeof(unsigned long)];
 
-#ifdef CONFIG_HIGHMEM
-#define inc_totalhigh_pages() (totalhigh_pages++)
-#define dec_totalhigh_pages() (totalhigh_pages--)
-#else
-#define inc_totalhigh_pages() do {} while (0)
-#define dec_totalhigh_pages() do {} while (0)
-#endif
-
 /* List of ballooned pages, threaded through the mem_map array. */
 static LIST_HEAD(ballooned_pages);
 
@@ -132,9 +124,7 @@ static void __balloon_append(struct page *page)
 static void balloon_append(struct page *page)
 {
 	__balloon_append(page);
-	if (PageHighMem(page))
-		dec_totalhigh_pages();
-	totalram_pages--;
+	adjust_managed_page_count(page, -1);
 }
 
 /* balloon_retrieve: rescue a page from the balloon, if it is not empty. */
@@ -151,13 +141,12 @@ static struct page *balloon_retrieve(bool prefer_highmem)
 		page = list_entry(ballooned_pages.next, struct page, lru);
 	list_del(&page->lru);
 
-	if (PageHighMem(page)) {
+	if (PageHighMem(page))
 		balloon_stats.balloon_high--;
-		inc_totalhigh_pages();
-	} else
+	else
 		balloon_stats.balloon_low--;
 
-	totalram_pages++;
+	adjust_managed_page_count(page, 1);
 
 	return page;
 }
@@ -374,9 +363,7 @@ static enum bp_state increase_reservation(unsigned long nr_pages)
 #endif
 
 		/* Relinquish the page back to the allocator. */
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
+		__free_reserved_page(page);
 	}
 
 	balloon_stats.current_pages += rc;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f8feeec..95c5a6b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1246,7 +1246,7 @@ static void __init gather_bootmem_prealloc(void)
 		 * side-effects, like CommitLimit going negative.
 		 */
 		if (h->order > (MAX_ORDER - 1))
-			totalram_pages += 1 << h->order;
+			adjust_managed_page_count(page, 1 << h->order);
 	}
 }
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c291295..304ada7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -769,20 +769,13 @@ EXPORT_SYMBOL_GPL(__online_page_set_limits);
 
 void __online_page_increment_counters(struct page *page)
 {
-	totalram_pages++;
-
-#ifdef CONFIG_HIGHMEM
-	if (PageHighMem(page))
-		totalhigh_pages++;
-#endif
+	adjust_managed_page_count(page, 1);
 }
 EXPORT_SYMBOL_GPL(__online_page_increment_counters);
 
 void __online_page_free(struct page *page)
 {
-	ClearPageReserved(page);
-	init_page_count(page);
-	__free_page(page);
+	__free_reserved_page(page);
 }
 EXPORT_SYMBOL_GPL(__online_page_free);
 
@@ -979,7 +972,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 		return ret;
 	}
 
-	zone->managed_pages += onlined_pages;
 	zone->present_pages += onlined_pages;
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 	if (onlined_pages) {
@@ -1563,10 +1555,9 @@ repeat:
 	/* reset pagetype flags and makes migrate type to be MOVABLE */
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 	/* removal success */
-	zone->managed_pages -= offlined_pages;
+	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
 	zone->present_pages -= offlined_pages;
 	zone->zone_pgdat->node_present_pages -= offlined_pages;
-	totalram_pages -= offlined_pages;
 
 	init_per_zone_wmark_min();
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a07e70a..56b0097 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -780,11 +780,7 @@ void __init init_cma_reserved_pageblock(struct page *page)
 	set_page_refcounted(page);
 	set_pageblock_migratetype(page, MIGRATE_CMA);
 	__free_pages(page, pageblock_order);
-	totalram_pages += pageblock_nr_pages;
-#ifdef CONFIG_HIGHMEM
-	if (PageHighMem(page))
-		totalhigh_pages += pageblock_nr_pages;
-#endif
+	adjust_managed_page_count(page, pageblock_nr_pages);
 }
 #endif
 
@@ -5189,6 +5185,10 @@ void adjust_managed_page_count(struct page *page, long count)
 	spin_lock(&managed_page_count_lock);
 	page_zone(page)->managed_pages += count;
 	totalram_pages += count;
+#ifdef	CONFIG_HIGHMEM
+	if (PageHighMem(page))
+		totalhigh_pages += count;
+#endif
 	spin_unlock(&managed_page_count_lock);
 }
 EXPORT_SYMBOL(adjust_managed_page_count);
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
