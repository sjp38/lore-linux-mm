Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 6CFDC6B0080
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 02:41:14 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [PATCH v3 8/9] memory-hotplug: fix NR_FREE_PAGES mismatch
Date: Fri, 19 Oct 2012 14:46:41 +0800
Message-Id: <1350629202-9664-9-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com>
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>, Christoph Lameter <cl@linux.com>

From: Wen Congyang <wency@cn.fujitsu.com>

NR_FREE_PAGES will be wrong after offlining pages. We add/dec NR_FREE_PAGES
like this now:
1. mova all pages in buddy system to MIGRATE_ISOLATE, and dec NR_FREE_PAGES
2. don't add NR_FREE_PAGES when it is freed and the migratetype is MIGRATE_ISOLATE
3. dec NR_FREE_PAGES when offlining isolated pages.
4. add NR_FREE_PAGES when undoing isolate pages.

When we come to step 3, all pages are in MIGRATE_ISOLATE list, and NR_FREE_PAGES
are right. When we come to step4, all pages are not in buddy system, so we don't
change NR_FREE_PAGES in this step, but we change NR_FREE_PAGES in step3. So
NR_FREE_PAGES is wrong after offlining pages. So there is no need to change
NR_FREE_PAGES in step3.

This patch also fixs a problem in step2: if the migratetype is MIGRATE_ISOLATE,
we should not add NR_FRR_PAGES when we remove pages from pcppages.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/page_alloc.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e33d0fb..9aa9490 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -667,11 +667,13 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
-			if (is_migrate_cma(mt))
-				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
+			if (likely(mt != MIGRATE_ISOLATE)) {
+				__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
+				if (is_migrate_cma(mt))
+					__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
+			}
 		} while (--to_free && --batch_free && !list_empty(list));
 	}
-	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
 	spin_unlock(&zone->lock);
 }
 
@@ -6006,8 +6008,6 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		list_del(&page->lru);
 		rmv_page_order(page);
 		zone->free_area[order].nr_free--;
-		__mod_zone_page_state(zone, NR_FREE_PAGES,
-				      - (1UL << order));
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
