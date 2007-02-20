Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id l1K5UOHe008667
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Feb 2007 14:30:25 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BD9E41B801E
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 14:30:24 +0900 (JST)
Received: from s11.gw.fujitsu.co.jp (s11.gw.fujitsu.co.jp [10.0.50.81])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9492A2DC032
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 14:30:24 +0900 (JST)
Received: from s11.gw.fujitsu.co.jp (s11 [127.0.0.1])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id 77719161C007
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 14:30:24 +0900 (JST)
Received: from fjm501.ms.jp.fujitsu.com (fjm501.ms.jp.fujitsu.com [10.56.99.71])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id B021A161C00B
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 14:30:23 +0900 (JST)
Received: from fjmscan503.ms.jp.fujitsu.com (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm501.ms.jp.fujitsu.com with ESMTP id l1K5UCwW029299
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 14:30:12 +0900
Received: from unknown ([10.124.100.187])
	by fjmscan503.ms.jp.fujitsu.com (8.13.1/8.12.11) with SMTP id l1K5U1Sf026329
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 14:30:12 +0900
Date: Tue, 20 Feb 2007 14:30:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] zone configration check function [1/2]
Message-Id: <20070220143010.6caf8cd9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

An idea for remove #ifdefs...

This defines not configured zones ids as ids bigger than MAX_NR_ZONES.
We can use is_cofigured_zone(zone_id) for accessing specific zones
instead of inserting #ifdefs in the middle of funcs.

(*)MAX_NR_ZONES means as it does now.

This patch is against 2.6.20.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezaw.hiroyu@jp.fujitsu.com>


Index: linux-2.6.20-devel/include/linux/mmzone.h
===================================================================
--- linux-2.6.20-devel.orig/include/linux/mmzone.h
+++ linux-2.6.20-devel/include/linux/mmzone.h
@@ -136,9 +136,23 @@ enum zone_type {
 	 */
 	ZONE_HIGHMEM,
 #endif
-	MAX_NR_ZONES
+	MAX_NR_ZONES,
+	/* Below is invalid zone ids depends on config */
+#ifndef CONFIG_ZONE_DMA32
+	ZONE_DMA32,
+#endif
+#ifndef CONFIG_ZONE_HIGHMEM
+	ZONE_HIGHMEM,
+#endif
+	ALL_POSSIBLE_ZONES
+#
 };
 
+static inline int is_configured_zone(enum zone_type id)
+{
+	return (id < MAX_NR_ZONES);
+}
+
 /*
  * When a memory allocation must conform to specific limitations (such
  * as being suitable for DMA) the caller will pass in hints to the
@@ -480,11 +494,9 @@ static inline int populated_zone(struct 
 
 static inline int is_highmem_idx(enum zone_type idx)
 {
-#ifdef CONFIG_HIGHMEM
+	if (!is_configured_zone(ZONE_HIGHMEM))
+		return 0;
 	return (idx == ZONE_HIGHMEM);
-#else
-	return 0;
-#endif
 }
 
 static inline int is_normal_idx(enum zone_type idx)
@@ -500,11 +512,9 @@ static inline int is_normal_idx(enum zon
  */
 static inline int is_highmem(struct zone *zone)
 {
-#ifdef CONFIG_HIGHMEM
+	if (!is_configured_zone(ZONE_HIGHMEM))
+		return 0;
 	return zone == zone->zone_pgdat->node_zones + ZONE_HIGHMEM;
-#else
-	return 0;
-#endif
 }
 
 static inline int is_normal(struct zone *zone)
@@ -514,11 +524,9 @@ static inline int is_normal(struct zone 
 
 static inline int is_dma32(struct zone *zone)
 {
-#ifdef CONFIG_ZONE_DMA32
+	if (!is_configured_zone(ZONE_DMA32))
+		return 0;
 	return zone == zone->zone_pgdat->node_zones + ZONE_DMA32;
-#else
-	return 0;
-#endif
 }
 
 static inline int is_dma(struct zone *zone)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
