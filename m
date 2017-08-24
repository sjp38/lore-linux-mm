Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 624CF2803BC
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 01:46:00 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y15so30457484pgc.3
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 22:46:00 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id c24si2205355pfk.197.2017.08.23.22.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 22:45:59 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id p14so2416913pgd.1
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 22:45:58 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH] mm/page_alloc: don't reserve ZONE_HIGHMEM for ZONE_MOVABLE request
Date: Thu, 24 Aug 2017 14:45:46 +0900
Message-Id: <1503553546-27450-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Freepage on ZONE_HIGHMEM doesn't work for kernel memory so it's not that
important to reserve. When ZONE_MOVABLE is used, this problem would
theorectically cause to decrease usable memory for GFP_HIGHUSER_MOVABLE
allocation request which is mainly used for page cache and anon page
allocation. So, fix it.

And, defining sysctl_lowmem_reserve_ratio array by MAX_NR_ZONES - 1 size
makes code complex. For example, if there is highmem system, following
reserve ratio is activated for *NORMAL ZONE* which would be easyily
misleading people.

 #ifdef CONFIG_HIGHMEM
 32
 #endif

This patch also fix this situation by defining sysctl_lowmem_reserve_ratio
array by MAX_NR_ZONES and place "#ifdef" to right place.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h |  2 +-
 mm/page_alloc.c        | 11 ++++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e7e92c8..e5f134b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -882,7 +882,7 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
-extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
+extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES];
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 90b1996..6faa53d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -202,17 +202,18 @@ static void __free_pages_ok(struct page *page, unsigned int order);
  * TBD: should special case ZONE_DMA32 machines here - in those we normally
  * don't need any ZONE_NORMAL reservation
  */
-int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
+int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES] = {
 #ifdef CONFIG_ZONE_DMA
-	 256,
+	[ZONE_DMA] = 256,
 #endif
 #ifdef CONFIG_ZONE_DMA32
-	 256,
+	[ZONE_DMA32] = 256,
 #endif
+	[ZONE_NORMAL] = 32,
 #ifdef CONFIG_HIGHMEM
-	 32,
+	[ZONE_HIGHMEM] = INT_MAX,
 #endif
-	 32,
+	[ZONE_MOVABLE] = INT_MAX,
 };
 
 EXPORT_SYMBOL(totalram_pages);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
