Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C74C36B0260
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 18:49:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f85so875909pfe.7
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 15:49:31 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTPS id 92si2153599plw.30.2017.10.25.15.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Oct 2017 15:49:30 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 1/2] mm: extract common code for calculating total memory size
Date: Thu, 26 Oct 2017 06:48:59 +0800
Message-Id: <1508971740-118317-2-git-send-email-yang.s@alibaba-inc.com>
In-Reply-To: <1508971740-118317-1-git-send-email-yang.s@alibaba-inc.com>
References: <1508971740-118317-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Total memory size is needed by unreclaimable slub oom to check if
significant memory is used by a single slab. But, the caculation work is
done in show_mem(), so extracting the common code in order to share with
others.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
 include/linux/mm.h | 25 +++++++++++++++++++++++++
 lib/show_mem.c     | 20 +-------------------
 2 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 935c4d4..e21b81e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2050,6 +2050,31 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn,
 static inline void zero_resv_unavail(void) {}
 #endif
 
+static inline void calc_mem_size(unsigned long *total, unsigned long *reserved,
+				 unsigned long *highmem)
+{
+	pg_data_t *pgdat;
+
+	for_each_online_pgdat(pgdat) {
+		unsigned long flags;
+		int zoneid;
+
+		pgdat_resize_lock(pgdat, &flags);
+		for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+			struct zone *zone = &pgdat->node_zones[zoneid];
+			if (!populated_zone(zone))
+				continue;
+
+			*total += zone->present_pages;
+			*reserved += zone->present_pages - zone->managed_pages;
+
+			if (is_highmem_idx(zoneid))
+				*highmem += zone->present_pages;
+		}
+		pgdat_resize_unlock(pgdat, &flags);
+	}
+}
+
 extern void set_dma_reserve(unsigned long new_dma_reserve);
 extern void memmap_init_zone(unsigned long, int, unsigned long,
 				unsigned long, enum memmap_context);
diff --git a/lib/show_mem.c b/lib/show_mem.c
index 0beaa1d..115475e 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -11,30 +11,12 @@
 
 void show_mem(unsigned int filter, nodemask_t *nodemask)
 {
-	pg_data_t *pgdat;
 	unsigned long total = 0, reserved = 0, highmem = 0;
 
 	printk("Mem-Info:\n");
 	show_free_areas(filter, nodemask);
 
-	for_each_online_pgdat(pgdat) {
-		unsigned long flags;
-		int zoneid;
-
-		pgdat_resize_lock(pgdat, &flags);
-		for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
-			struct zone *zone = &pgdat->node_zones[zoneid];
-			if (!populated_zone(zone))
-				continue;
-
-			total += zone->present_pages;
-			reserved += zone->present_pages - zone->managed_pages;
-
-			if (is_highmem_idx(zoneid))
-				highmem += zone->present_pages;
-		}
-		pgdat_resize_unlock(pgdat, &flags);
-	}
+	calc_mem_size(&total, &reserved, &highmem);
 
 	printk("%lu pages RAM\n", total);
 	printk("%lu pages HighMem/MovableOnly\n", highmem);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
