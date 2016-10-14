Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 657216B0253
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 23:03:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 128so97878809pfz.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:03:12 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id lm5si13999874pab.26.2016.10.13.20.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 20:03:11 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id os4so1422725pac.3
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:03:11 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v6 1/6] mm/page_alloc: don't reserve ZONE_HIGHMEM for ZONE_MOVABLE request
Date: Fri, 14 Oct 2016 12:03:11 +0900
Message-Id: <1476414196-3514-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
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

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h |  2 +-
 mm/page_alloc.c        | 11 ++++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7f2ae99..bd30fc1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -889,7 +889,7 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
-extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
+extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES];
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1790391..92b68cc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -198,17 +198,18 @@ bool pm_suspended_storage(void)
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
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
