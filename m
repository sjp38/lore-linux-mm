Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id AF83B6B0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 00:17:01 -0500 (EST)
Message-ID: <5111E6EE.6080708@cn.fujitsu.com>
Date: Wed, 06 Feb 2013 13:15:26 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/7] mm: fix return type for functions nr_free_*_pages
References: <5111E612.4010907@cn.fujitsu.com>
In-Reply-To: <5111E612.4010907@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Currently, the amount of RAM that functions nr_free_*_pages return
is held in unsigned int. But in machines with big memory (exceeding
16TB), the amount may be incorrect because of overflow, so fix it.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/swap.h |    4 ++--
 mm/page_alloc.c      |    8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 68df9c1..c238323 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -216,8 +216,8 @@ struct swap_list_t {
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
 extern unsigned long dirty_balance_reserve;
-extern unsigned int nr_free_buffer_pages(void);
-extern unsigned int nr_free_pagecache_pages(void);
+extern unsigned long nr_free_buffer_pages(void);
+extern unsigned long nr_free_pagecache_pages(void);
 
 /* Definition of global_page_state not available yet */
 #define nr_free_pages() global_page_state(NR_FREE_PAGES)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df2022f..4acf733 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2785,13 +2785,13 @@ void free_pages_exact(void *virt, size_t size)
 }
 EXPORT_SYMBOL(free_pages_exact);
 
-static unsigned int nr_free_zone_pages(int offset)
+static unsigned long nr_free_zone_pages(int offset)
 {
 	struct zoneref *z;
 	struct zone *zone;
 
 	/* Just pick one node, since fallback list is circular */
-	unsigned int sum = 0;
+	unsigned long sum = 0;
 
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
 
@@ -2808,7 +2808,7 @@ static unsigned int nr_free_zone_pages(int offset)
 /*
  * Amount of free RAM allocatable within ZONE_DMA and ZONE_NORMAL
  */
-unsigned int nr_free_buffer_pages(void)
+unsigned long nr_free_buffer_pages(void)
 {
 	return nr_free_zone_pages(gfp_zone(GFP_USER));
 }
@@ -2817,7 +2817,7 @@ EXPORT_SYMBOL_GPL(nr_free_buffer_pages);
 /*
  * Amount of free RAM allocatable within all zones
  */
-unsigned int nr_free_pagecache_pages(void)
+unsigned long nr_free_pagecache_pages(void)
 {
 	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER_MOVABLE));
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
