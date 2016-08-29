Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id CBAFD830DE
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 01:07:49 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id vd14so249389425pab.3
        for <linux-mm@kvack.org>; Sun, 28 Aug 2016 22:07:49 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id gc14si37034617pac.142.2016.08.28.22.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Aug 2016 22:07:48 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id vy10so8282921pac.0
        for <linux-mm@kvack.org>; Sun, 28 Aug 2016 22:07:48 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v5 1/6] mm/page_alloc: don't reserve ZONE_HIGHMEM for ZONE_MOVABLE request
Date: Mon, 29 Aug 2016 14:07:30 +0900
Message-Id: <1472447255-10584-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h | 2 +-
 mm/page_alloc.c        | 7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d572b78..e3f39af 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -877,7 +877,7 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
-extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
+extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES];
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4f7d5d7..a8310de 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -198,17 +198,18 @@ static void __free_pages_ok(struct page *page, unsigned int order);
  * TBD: should special case ZONE_DMA32 machines here - in those we normally
  * don't need any ZONE_NORMAL reservation
  */
-int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
+int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES] = {
 #ifdef CONFIG_ZONE_DMA
 	 256,
 #endif
 #ifdef CONFIG_ZONE_DMA32
 	 256,
 #endif
-#ifdef CONFIG_HIGHMEM
 	 32,
+#ifdef CONFIG_HIGHMEM
+	 INT_MAX,
 #endif
-	 32,
+	 INT_MAX,
 };
 
 EXPORT_SYMBOL(totalram_pages);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
