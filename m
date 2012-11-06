Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 6F3BE6B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 20:32:34 -0500 (EST)
From: Jiang Liu <jiang.liu@huawei.com>
Subject: [PATCH] mm: fix a regression with HIGHMEM introduced by changeset 7f1290f2f2a4d
Date: Tue, 6 Nov 2012 09:31:57 +0800
Message-ID: <1352165517-9732-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Maciej Rutecki <maciej.rutecki@gmail.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Jianguo Wu <wujianguo@huawei.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Changeset 7f1290f2f2 tries to fix a issue when calculating
zone->present_pages, but it causes a regression to 32bit systems with
HIGHMEM. With that changeset, function reset_zone_present_pages()
resets all zone->present_pages to zero, and fixup_zone_present_pages()
is called to recalculate zone->present_pages when boot allocator frees
core memory pages into buddy allocator. Because highmem pages are not
freed by bootmem allocator, all highmem zones' present_pages becomes
zero.

Actually there's no need to recalculate present_pages for highmem zone
because bootmem allocator never allocates pages from them. So fix the
regression by skipping highmem in function reset_zone_present_pages()
and fixup_zone_present_pages().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
Reported-by: Maciej Rutecki <maciej.rutecki@gmail.com>
Tested-by: Maciej Rutecki <maciej.rutecki@gmail.com>
Cc: Chris Clayton <chris2553@googlemail.com>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

---

Hi Maciej,
	Thanks for reporting and bisecting. We have analyzed the regression
and worked out a patch for it. Could you please help to verify whether it
fix the regression?
	Thanks!
	Gerry

---
 mm/page_alloc.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5b74de6..2311f15 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6108,7 +6108,8 @@ void reset_zone_present_pages(void)
 	for_each_node_state(nid, N_HIGH_MEMORY) {
 		for (i = 0; i < MAX_NR_ZONES; i++) {
 			z = NODE_DATA(nid)->node_zones + i;
-			z->present_pages = 0;
+			if (!is_highmem(z))
+				z->present_pages = 0;
 		}
 	}
 }
@@ -6123,10 +6124,11 @@ void fixup_zone_present_pages(int nid, unsigned long start_pfn,
 
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		z = NODE_DATA(nid)->node_zones + i;
+		if (is_highmem(z))
+			continue;
+
 		zone_start_pfn = z->zone_start_pfn;
 		zone_end_pfn = zone_start_pfn + z->spanned_pages;
-
-		/* if the two regions intersect */
 		if (!(zone_start_pfn >= end_pfn	|| zone_end_pfn <= start_pfn))
 			z->present_pages += min(end_pfn, zone_end_pfn) -
 					    max(start_pfn, zone_start_pfn);
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
