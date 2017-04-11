Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D34766B0397
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 23:17:39 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x125so134624104pgb.5
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 20:17:39 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id z33si15449177plb.36.2017.04.10.20.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 20:17:39 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id g2so27963500pge.2
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 20:17:39 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v7 1/7] mm/page_alloc: don't reserve ZONE_HIGHMEM for ZONE_MOVABLE request
Date: Tue, 11 Apr 2017 12:17:14 +0900
Message-Id: <1491880640-9944-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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
index ebaccd4..96194bf 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -869,7 +869,7 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
-extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
+extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES];
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 32b31d6..60ffa4e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -203,17 +203,18 @@ static void __free_pages_ok(struct page *page, unsigned int order);
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
