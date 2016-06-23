Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 345E4828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 06:10:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so20330007wmr.0
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 03:10:14 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.75])
        by mx.google.com with ESMTPS id i83si5429035wmf.117.2016.06.23.03.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 03:10:13 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [RFC, DEBUGGING 2/2] mm: add type checking for page state functions
Date: Thu, 23 Jun 2016 12:05:18 +0200
Message-Id: <20160623100518.156662-2-arnd@arndb.de>
In-Reply-To: <20160623100518.156662-1-arnd@arndb.de>
References: <20160623100518.156662-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>

We had a couple of bugs where we pass the incorrect 'enum' into
one of the statistics functions, and unfortunately gcc can only
warn about comparing distinct enum types rather than warning
about passing an enum of the wrong type into a function.

This wraps all the stats calls inside of macros that add the
type checking using a comparison. This is a fairly crude method,
but it helped uncover some issues for me.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/vmstat.h | 36 +++++++++++++++++++++++++++++++++++-
 1 file changed, 35 insertions(+), 1 deletion(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index c799073fe1c4..0328858894a5 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -116,6 +116,8 @@ static inline void zone_page_state_add(long x, struct zone *zone,
 	atomic_long_add(x, &zone->vm_stat[item]);
 	atomic_long_add(x, &vm_zone_stat[item]);
 }
+#define zone_page_state_add(x, zone, item) \
+	zone_page_state_add(x, zone, ((item) == (enum zone_stat_item )0) ? (item) : (item))
 
 static inline void node_page_state_add(long x, struct pglist_data *pgdat,
 				 enum node_stat_item item)
@@ -123,6 +125,8 @@ static inline void node_page_state_add(long x, struct pglist_data *pgdat,
 	atomic_long_add(x, &pgdat->vm_stat[item]);
 	atomic_long_add(x, &vm_node_stat[item]);
 }
+#define node_page_state_add(x, node, item) \
+	node_page_state_add(x, node, ((item) == (enum node_stat_item )0) ? (item) : (item))
 
 static inline unsigned long global_page_state(enum zone_stat_item item)
 {
@@ -133,6 +137,8 @@ static inline unsigned long global_page_state(enum zone_stat_item item)
 #endif
 	return x;
 }
+#define global_page_state(item) \
+	global_page_state(((item) == (enum zone_stat_item )0) ? (item) : (item))
 
 static inline unsigned long global_node_page_state(enum node_stat_item item)
 {
@@ -143,6 +149,8 @@ static inline unsigned long global_node_page_state(enum node_stat_item item)
 #endif
 	return x;
 }
+#define global_node_page_state(item) \
+	global_node_page_state(((item) == (enum node_stat_item )0) ? (item) : (item))
 
 static inline unsigned long zone_page_state(struct zone *zone,
 					enum zone_stat_item item)
@@ -154,6 +162,8 @@ static inline unsigned long zone_page_state(struct zone *zone,
 #endif
 	return x;
 }
+#define zone_page_state(zone, item) \
+	zone_page_state(zone, ((item) == (enum zone_stat_item )0) ? (item) : (item))
 
 /*
  * More accurate version that also considers the currently pending
@@ -176,6 +186,8 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
 #endif
 	return x;
 }
+#define zone_page_state_snapshot(zone, item) \
+	zone_page_state_snapshot(zone, ((item) == (enum zone_stat_item )0) ? (item) : (item))
 
 static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
 					enum zone_stat_item item)
@@ -192,7 +204,8 @@ static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
 #endif
 	return x;
 }
-
+#define node_page_state_snapshot(zone, item) \
+	node_page_state_snapshot(zone, ((item) == (enum node_stat_item )0) ? (item) : (item))
 
 #ifdef CONFIG_NUMA
 extern unsigned long sum_zone_node_page_state(int node,
@@ -341,6 +354,27 @@ static inline void drain_zonestat(struct zone *zone,
 			struct per_cpu_pageset *pset) { }
 #endif		/* CONFIG_SMP */
 
+#define __mod_zone_page_state(zone, item, delta) \
+	__mod_zone_page_state(zone, ((item) == (enum zone_stat_item )0) ? (item) : (item), delta)
+#define __mod_node_page_state(pgdat, item, delta) \
+	__mod_node_page_state(pgdat, ((item) == (enum node_stat_item )0) ? (item) : (item), delta)
+#define __inc_zone_state(zone, item) \
+	__inc_zone_state(zone, ((item) == (enum zone_stat_item )0) ? (item) : (item))
+#define __inc_node_state(pgdat, item) \
+	__inc_node_state(pgdat, ((item) == (enum node_stat_item )0) ? (item) : (item))
+#define __dec_zone_state(zone, item) \
+	__dec_zone_state(zone, ((item) == (enum zone_stat_item )0) ? (item) : (item))
+#define __dec_node_state(pgdat, item) \
+	__dec_node_state(pgdat, ((item) == (enum node_stat_item )0) ? (item) : (item))
+#define __inc_zone_page_state(page, item) \
+	__inc_zone_page_state(page, ((item) == (enum zone_stat_item )0) ? (item) : (item))
+#define __inc_node_page_state(page, item) \
+	__inc_node_page_state(page, ((item) == (enum node_stat_item )0) ? (item) : (item))
+#define __dec_zone_page_state(page, item) \
+	__dec_zone_page_state(page, ((item) == (enum zone_stat_item )0) ? (item) : (item))
+#define __dec_node_page_state(page, item) \
+	__dec_node_page_state(page, ((item) == (enum node_stat_item )0) ? (item) : (item))
+
 static inline void __mod_zone_freepage_state(struct zone *zone, int nr_pages,
 					     int migratetype)
 {
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
