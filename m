Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 75D486B025E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 09:21:57 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a2so53027031lfe.0
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 06:21:57 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id uk8si205106wjb.66.2016.06.23.06.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 06:21:55 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [RFC, DEBUGGING v2 2/2] mm: add type checking for page state functions
Date: Thu, 23 Jun 2016 15:18:39 +0200
Message-Id: <20160623131839.3579472-2-arnd@arndb.de>
In-Reply-To: <20160623131839.3579472-1-arnd@arndb.de>
References: <3817461.6pThRKgN9N@wuerfel>
 <20160623131839.3579472-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>

We had a couple of bugs where we pass the incorrect 'enum' into
one of the statistics functions, and unfortunately gcc can only
warn about comparing distinct enum types rather than warning
about passing an enum of the wrong type into a function.

This wraps all the stats calls inside of macros that add the
type checking using a comparison.

This second version is better compile-tested, but it's also really ugly.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/vmstat.h | 158 ++++++++++++++++++++++++++++++++++---------------
 mm/vmstat.c            | 136 +++++++++++++++++++++---------------------
 2 files changed, 178 insertions(+), 116 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index c799073fe1c4..390b7ae3efb2 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -110,21 +110,25 @@ static inline void vm_events_fold_cpu(int cpu)
 extern atomic_long_t vm_zone_stat[NR_VM_ZONE_STAT_ITEMS];
 extern atomic_long_t vm_node_stat[NR_VM_NODE_STAT_ITEMS];
 
-static inline void zone_page_state_add(long x, struct zone *zone,
+static inline void zone_page_state_add_check(long x, struct zone *zone,
 				 enum zone_stat_item item)
 {
 	atomic_long_add(x, &zone->vm_stat[item]);
 	atomic_long_add(x, &vm_zone_stat[item]);
 }
+#define zone_page_state_add(x, zone, item) \
+	zone_page_state_add_check(x, zone, ((item) == (enum zone_stat_item )0) ? (item) : (item))
 
-static inline void node_page_state_add(long x, struct pglist_data *pgdat,
+static inline void node_page_state_add_check(long x, struct pglist_data *pgdat,
 				 enum node_stat_item item)
 {
 	atomic_long_add(x, &pgdat->vm_stat[item]);
 	atomic_long_add(x, &vm_node_stat[item]);
 }
+#define node_page_state_add(x, node, item) \
+	node_page_state_add_check(x, node, ((item) == (enum node_stat_item )0) ? (item) : (item))
 
-static inline unsigned long global_page_state(enum zone_stat_item item)
+static inline unsigned long global_page_state_check(enum zone_stat_item item)
 {
 	long x = atomic_long_read(&vm_zone_stat[item]);
 #ifdef CONFIG_SMP
@@ -133,8 +137,10 @@ static inline unsigned long global_page_state(enum zone_stat_item item)
 #endif
 	return x;
 }
+#define global_page_state(item) \
+	global_page_state_check(((item) == (enum zone_stat_item )0) ? (item) : (item))
 
-static inline unsigned long global_node_page_state(enum node_stat_item item)
+static inline unsigned long global_node_page_state_check(enum node_stat_item item)
 {
 	long x = atomic_long_read(&vm_node_stat[item]);
 #ifdef CONFIG_SMP
@@ -143,8 +149,10 @@ static inline unsigned long global_node_page_state(enum node_stat_item item)
 #endif
 	return x;
 }
+#define global_node_page_state(item) \
+	global_node_page_state_check(((item) == (enum node_stat_item )0) ? (item) : (item))
 
-static inline unsigned long zone_page_state(struct zone *zone,
+static inline unsigned long zone_page_state_check(struct zone *zone,
 					enum zone_stat_item item)
 {
 	long x = atomic_long_read(&zone->vm_stat[item]);
@@ -154,6 +162,8 @@ static inline unsigned long zone_page_state(struct zone *zone,
 #endif
 	return x;
 }
+#define zone_page_state(zone, item) \
+	zone_page_state_check(zone, ((item) == (enum zone_stat_item )0) ? (item) : (item))
 
 /*
  * More accurate version that also considers the currently pending
@@ -161,7 +171,7 @@ static inline unsigned long zone_page_state(struct zone *zone,
  * deltas. There is no synchronization so the result cannot be
  * exactly accurate either.
  */
-static inline unsigned long zone_page_state_snapshot(struct zone *zone,
+static inline unsigned long zone_page_state_snapshot_check(struct zone *zone,
 					enum zone_stat_item item)
 {
 	long x = atomic_long_read(&zone->vm_stat[item]);
@@ -176,8 +186,10 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
 #endif
 	return x;
 }
+#define zone_page_state_snapshot(zone, item) \
+	zone_page_state_snapshot_check(zone, ((item) == (enum zone_stat_item )0) ? (item) : (item))
 
-static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
+static inline unsigned long node_page_state_snapshot_check(pg_data_t *pgdat,
 					enum zone_stat_item item)
 {
 	long x = atomic_long_read(&pgdat->vm_stat[item]);
@@ -192,13 +204,18 @@ static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
 #endif
 	return x;
 }
-
+#define node_page_state_snapshot(zone, item) \
+	node_page_state_snapshot_check(zone, ((item) == (enum node_stat_item )0) ? (item) : (item))
 
 #ifdef CONFIG_NUMA
-extern unsigned long sum_zone_node_page_state(int node,
+extern unsigned long sum_zone_node_page_state_check(int node,
 						enum zone_stat_item item);
-extern unsigned long node_page_state(struct pglist_data *pgdat,
+#define sum_zone_node_page_state(node, item) \
+	sum_zone_node_page_state_check(node, ((item) == (enum node_stat_item )0) ? (item) : (item))
+extern unsigned long node_page_state_check(struct pglist_data *pgdat,
 						enum node_stat_item item);
+#define node_page_state(pgdat, item) \
+	node_page_state_check(pgdat, ((item) == (enum node_stat_item )0) ? (item) : (item))
 #else
 #define sum_zone_node_page_state(node, item) global_node_page_state(item)
 #define node_page_state(node, item) global_node_page_state(item)
@@ -210,28 +227,52 @@ extern unsigned long node_page_state(struct pglist_data *pgdat,
 #define sub_node_page_state(__p, __i, __d) mod_node_page_state(__p, __i, -(__d))
 
 #ifdef CONFIG_SMP
-void __mod_zone_page_state(struct zone *, enum zone_stat_item item, long);
-void __inc_zone_page_state(struct page *, enum zone_stat_item);
-void __dec_zone_page_state(struct page *, enum zone_stat_item);
-
-void __mod_node_page_state(struct pglist_data *, enum node_stat_item item, long);
-void __inc_node_page_state(struct page *, enum node_stat_item);
-void __dec_node_page_state(struct page *, enum node_stat_item);
-
-void mod_zone_page_state(struct zone *, enum zone_stat_item, long);
-void inc_zone_page_state(struct page *, enum zone_stat_item);
-void dec_zone_page_state(struct page *, enum zone_stat_item);
-
-void mod_node_page_state(struct pglist_data *, enum node_stat_item, long);
-void inc_node_page_state(struct page *, enum node_stat_item);
-void dec_node_page_state(struct page *, enum node_stat_item);
-
-extern void inc_node_state(struct pglist_data *, enum node_stat_item);
-extern void __inc_zone_state(struct zone *, enum zone_stat_item);
-extern void __inc_node_state(struct pglist_data *, enum node_stat_item);
-extern void dec_zone_state(struct zone *, enum zone_stat_item);
-extern void __dec_zone_state(struct zone *, enum zone_stat_item);
-extern void __dec_node_state(struct pglist_data *, enum node_stat_item);
+void __mod_zone_page_state_check(struct zone *, enum zone_stat_item item, long);
+void __inc_zone_page_state_check(struct page *, enum zone_stat_item);
+void __dec_zone_page_state_check(struct page *, enum zone_stat_item);
+
+void __mod_node_page_state_check(struct pglist_data *, enum node_stat_item item, long);
+void __inc_node_page_state_check(struct page *, enum node_stat_item);
+void __dec_node_page_state_check(struct page *, enum node_stat_item);
+
+void mod_zone_page_state_check(struct zone *, enum zone_stat_item, long);
+void inc_zone_page_state_check(struct page *, enum zone_stat_item);
+void dec_zone_page_state_check(struct page *, enum zone_stat_item);
+
+#define mod_zone_page_state(zone, item, delta) \
+	mod_zone_page_state_check(zone, ((item) == (enum zone_stat_item )0) ? (item) : (item), delta)
+#define inc_zone_page_state(page, item) \
+	inc_zone_page_state_check(page, ((item) == (enum zone_stat_item )0) ? (item) : (item))
+#define dec_zone_page_state(page, item) \
+	dec_zone_page_state_check(page, ((item) == (enum zone_stat_item )0) ? (item) : (item))
+
+void mod_node_page_state_check(struct pglist_data *, enum node_stat_item, long);
+void inc_node_page_state_check(struct page *, enum node_stat_item);
+void dec_node_page_state_check(struct page *, enum node_stat_item);
+
+#define mod_node_page_state(pgdat, item, delta) \
+	mod_node_page_state_check(pgdat, ((item) == (enum node_stat_item )0) ? (item) : (item), delta)
+#define inc_node_page_state(page, item) \
+	inc_node_page_state_check(page, ((item) == (enum node_stat_item )0) ? (item) : (item))
+#define dec_node_page_state(page, item) \
+	dec_node_page_state_check(page, ((item) == (enum node_stat_item )0) ? (item) : (item))
+
+extern void inc_node_state_check(struct pglist_data *, enum node_stat_item);
+extern void __inc_zone_state_check(struct zone *, enum zone_stat_item);
+extern void __inc_node_state_check(struct pglist_data *, enum node_stat_item);
+extern void dec_zone_state_check(struct zone *, enum zone_stat_item);
+extern void __dec_zone_state_check(struct zone *, enum zone_stat_item);
+extern void __dec_node_state_check(struct pglist_data *, enum node_stat_item);
+
+#define inc_node_state(pgdat, item) \
+	inc_node_state_check(pgdat, ((item) == (enum node_stat_item )0) ? (item) : (item))
+#define dec_node_state(pgdat, item) \
+	dec_node_state_check(pgdat, ((item) == (enum node_stat_item )0) ? (item) : (item))
+
+#define inc_zone_state(zone, item) \
+	inc_zone_state_check(zone, ((item) == (enum zone_stat_item )0) ? (item) : (item))
+#define dec_zone_state(zone, item) \
+	dec_zone_state_check(zone, ((item) == (enum zone_stat_item )0) ? (item) : (item))
 
 void quiet_vmstat(void);
 void cpu_vm_stats_fold(int cpu);
@@ -253,65 +294,65 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
  * We do not maintain differentials in a single processor configuration.
  * The functions directly modify the zone and global counters.
  */
-static inline void __mod_zone_page_state(struct zone *zone,
+static inline void __mod_zone_page_state_check(struct zone *zone,
 			enum zone_stat_item item, long delta)
 {
-	zone_page_state_add(delta, zone, item);
+	zone_page_state_add_check(delta, zone, item);
 }
 
-static inline void __mod_node_page_state(struct pglist_data *pgdat,
+static inline void __mod_node_page_state_check(struct pglist_data *pgdat,
 			enum node_stat_item item, int delta)
 {
-	node_page_state_add(delta, pgdat, item);
+	node_page_state_add_check(delta, pgdat, item);
 }
 
-static inline void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
+static inline void __inc_zone_state_check(struct zone *zone, enum zone_stat_item item)
 {
 	atomic_long_inc(&zone->vm_stat[item]);
 	atomic_long_inc(&vm_zone_stat[item]);
 }
 
-static inline void __inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+static inline void __inc_node_state_check(struct pglist_data *pgdat, enum node_stat_item item)
 {
 	atomic_long_inc(&pgdat->vm_stat[item]);
 	atomic_long_inc(&vm_node_stat[item]);
 }
 
-static inline void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
+static inline void __dec_zone_state_check(struct zone *zone, enum zone_stat_item item)
 {
 	atomic_long_dec(&zone->vm_stat[item]);
 	atomic_long_dec(&vm_zone_stat[item]);
 }
 
-static inline void __dec_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+static inline void __dec_node_state_check(struct pglist_data *pgdat, enum node_stat_item item)
 {
 	atomic_long_dec(&pgdat->vm_stat[item]);
 	atomic_long_dec(&vm_node_stat[item]);
 }
 
-static inline void __inc_zone_page_state(struct page *page,
+static inline void __inc_zone_page_state_check(struct page *page,
 			enum zone_stat_item item)
 {
-	__inc_zone_state(page_zone(page), item);
+	__inc_zone_state_check(page_zone(page), item);
 }
 
-static inline void __inc_node_page_state(struct page *page,
+static inline void __inc_node_page_state_check(struct page *page,
 			enum node_stat_item item)
 {
-	__inc_node_state(page_pgdat(page), item);
+	__inc_node_state_check(page_pgdat(page), item);
 }
 
 
-static inline void __dec_zone_page_state(struct page *page,
+static inline void __dec_zone_page_state_check(struct page *page,
 			enum zone_stat_item item)
 {
-	__dec_zone_state(page_zone(page), item);
+	__dec_zone_state_check(page_zone(page), item);
 }
 
-static inline void __dec_node_page_state(struct page *page,
+static inline void __dec_node_page_state_check(struct page *page,
 			enum node_stat_item item)
 {
-	__dec_node_state(page_pgdat(page), item);
+	__dec_node_state_check(page_pgdat(page), item);
 }
 
 
@@ -341,6 +382,27 @@ static inline void drain_zonestat(struct zone *zone,
 			struct per_cpu_pageset *pset) { }
 #endif		/* CONFIG_SMP */
 
+#define __mod_zone_page_state(zone, item, delta) \
+	__mod_zone_page_state_check(zone, ((item) == (enum zone_stat_item )0) ? (item) : (item), delta)
+#define __mod_node_page_state(pgdat, item, delta) \
+	__mod_node_page_state_check(pgdat, ((item) == (enum node_stat_item )0) ? (item) : (item), delta)
+#define __inc_zone_state(zone, item) \
+	__inc_zone_state_check(zone, ((item) == (enum zone_stat_item )0) ? (item) : (item))
+#define __inc_node_state(pgdat, item) \
+	__inc_node_state_check(pgdat, ((item) == (enum node_stat_item )0) ? (item) : (item))
+#define __dec_zone_state(zone, item) \
+	__dec_zone_state_check(zone, ((item) == (enum zone_stat_item )0) ? (item) : (item))
+#define __dec_node_state(pgdat, item) \
+	__dec_node_state_check(pgdat, ((item) == (enum node_stat_item )0) ? (item) : (item))
+#define __inc_zone_page_state(page, item) \
+	__inc_zone_page_state_check(page, ((item) == (enum zone_stat_item )0) ? (item) : (item))
+#define __inc_node_page_state(page, item) \
+	__inc_node_page_state_check(page, ((item) == (enum node_stat_item )0) ? (item) : (item))
+#define __dec_zone_page_state(page, item) \
+	__dec_zone_page_state_check(page, ((item) == (enum zone_stat_item )0) ? (item) : (item))
+#define __dec_node_page_state(page, item) \
+	__dec_node_page_state_check(page, ((item) == (enum node_stat_item )0) ? (item) : (item))
+
 static inline void __mod_zone_freepage_state(struct zone *zone, int nr_pages,
 					     int migratetype)
 {
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 78c682ade326..c309a701d953 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -224,7 +224,7 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
  * or when we know that preemption is disabled and that
  * particular counter cannot be updated from interrupt context.
  */
-void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
+void __mod_zone_page_state_check(struct zone *zone, enum zone_stat_item item,
 			   long delta)
 {
 	struct per_cpu_pageset __percpu *pcp = zone->pageset;
@@ -242,9 +242,9 @@ void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 	}
 	__this_cpu_write(*p, x);
 }
-EXPORT_SYMBOL(__mod_zone_page_state);
+EXPORT_SYMBOL(__mod_zone_page_state_check);
 
-void __mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
+void __mod_node_page_state_check(struct pglist_data *pgdat, enum node_stat_item item,
 				long delta)
 {
 	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
@@ -262,7 +262,7 @@ void __mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
 	}
 	__this_cpu_write(*p, x);
 }
-EXPORT_SYMBOL(__mod_node_page_state);
+EXPORT_SYMBOL(__mod_node_page_state_check);
 
 /*
  * Optimized increment and decrement functions.
@@ -287,7 +287,7 @@ EXPORT_SYMBOL(__mod_node_page_state);
  * in between and therefore the atomicity vs. interrupt cannot be exploited
  * in a useful way here.
  */
-void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
+void __inc_zone_state_check(struct zone *zone, enum zone_stat_item item)
 {
 	struct per_cpu_pageset __percpu *pcp = zone->pageset;
 	s8 __percpu *p = pcp->vm_stat_diff + item;
@@ -303,7 +303,7 @@ void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 	}
 }
 
-void __inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+void __inc_node_state_check(struct pglist_data *pgdat, enum node_stat_item item)
 {
 	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
 	s8 __percpu *p = pcp->vm_node_stat_diff + item;
@@ -314,24 +314,24 @@ void __inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
 	if (unlikely(v > t)) {
 		s8 overstep = t >> 1;
 
-		node_page_state_add(v + overstep, pgdat, item);
+		node_page_state_add_check(v + overstep, pgdat, item);
 		__this_cpu_write(*p, -overstep);
 	}
 }
 
-void __inc_zone_page_state(struct page *page, enum zone_stat_item item)
+void __inc_zone_page_state_check(struct page *page, enum zone_stat_item item)
 {
-	__inc_zone_state(page_zone(page), item);
+	__inc_zone_state_check(page_zone(page), item);
 }
-EXPORT_SYMBOL(__inc_zone_page_state);
+EXPORT_SYMBOL(__inc_zone_page_state_check);
 
-void __inc_node_page_state(struct page *page, enum node_stat_item item)
+void __inc_node_page_state_check(struct page *page, enum node_stat_item item)
 {
-	__inc_node_state(page_pgdat(page), item);
+	__inc_node_state_check(page_pgdat(page), item);
 }
-EXPORT_SYMBOL(__inc_node_page_state);
+EXPORT_SYMBOL(__inc_node_page_state_check);
 
-void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
+void __dec_zone_state_check(struct zone *zone, enum zone_stat_item item)
 {
 	struct per_cpu_pageset __percpu *pcp = zone->pageset;
 	s8 __percpu *p = pcp->vm_stat_diff + item;
@@ -342,12 +342,12 @@ void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 	if (unlikely(v < - t)) {
 		s8 overstep = t >> 1;
 
-		zone_page_state_add(v - overstep, zone, item);
+		zone_page_state_add_check(v - overstep, zone, item);
 		__this_cpu_write(*p, overstep);
 	}
 }
 
-void __dec_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+void __dec_node_state_check(struct pglist_data *pgdat, enum node_stat_item item)
 {
 	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
 	s8 __percpu *p = pcp->vm_node_stat_diff + item;
@@ -358,22 +358,22 @@ void __dec_node_state(struct pglist_data *pgdat, enum node_stat_item item)
 	if (unlikely(v < - t)) {
 		s8 overstep = t >> 1;
 
-		node_page_state_add(v - overstep, pgdat, item);
+		node_page_state_add_check(v - overstep, pgdat, item);
 		__this_cpu_write(*p, overstep);
 	}
 }
 
-void __dec_zone_page_state(struct page *page, enum zone_stat_item item)
+void __dec_zone_page_state_check(struct page *page, enum zone_stat_item item)
 {
-	__dec_zone_state(page_zone(page), item);
+	__dec_zone_state_check(page_zone(page), item);
 }
-EXPORT_SYMBOL(__dec_zone_page_state);
+EXPORT_SYMBOL(__dec_zone_page_state_check);
 
-void __dec_node_page_state(struct page *page, enum node_stat_item item)
+void __dec_node_page_state_check(struct page *page, enum node_stat_item item)
 {
-	__dec_node_state(page_pgdat(page), item);
+	__dec_node_state_check(page_pgdat(page), item);
 }
-EXPORT_SYMBOL(__dec_node_page_state);
+EXPORT_SYMBOL(__dec_node_page_state_check);
 
 #ifdef CONFIG_HAVE_CMPXCHG_LOCAL
 /*
@@ -426,26 +426,26 @@ static inline void mod_zone_state(struct zone *zone,
 		zone_page_state_add(z, zone, item);
 }
 
-void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
+void mod_zone_page_state_check(struct zone *zone, enum zone_stat_item item,
 			 long delta)
 {
-	mod_zone_state(zone, item, delta, 0);
+	mod_zone_state_check(zone, item, delta, 0);
 }
-EXPORT_SYMBOL(mod_zone_page_state);
+EXPORT_SYMBOL(mod_zone_page_state_check);
 
-void inc_zone_page_state(struct page *page, enum zone_stat_item item)
+void inc_zone_page_state_check(struct page *page, enum zone_stat_item item)
 {
-	mod_zone_state(page_zone(page), item, 1, 1);
+	mod_zone_state_check(page_zone(page), item, 1, 1);
 }
-EXPORT_SYMBOL(inc_zone_page_state);
+EXPORT_SYMBOL(inc_zone_page_state_check);
 
-void dec_zone_page_state(struct page *page, enum zone_stat_item item)
+void dec_zone_page_state_check(struct page *page, enum zone_stat_item item)
 {
-	mod_zone_state(page_zone(page), item, -1, -1);
+	mod_zone_state_check(page_zone(page), item, -1, -1);
 }
-EXPORT_SYMBOL(dec_zone_page_state);
+EXPORT_SYMBOL(dec_zone_page_state_check);
 
-static inline void mod_node_state(struct pglist_data *pgdat,
+static inline void mod_node_state_check(struct pglist_data *pgdat,
        enum node_stat_item item, int delta, int overstep_mode)
 {
 	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
@@ -480,111 +480,111 @@ static inline void mod_node_state(struct pglist_data *pgdat,
 	} while (this_cpu_cmpxchg(*p, o, n) != o);
 
 	if (z)
-		node_page_state_add(z, pgdat, item);
+		node_page_state_add_check(z, pgdat, item);
 }
 
-void mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
+void mod_node_page_state_check(struct pglist_data *pgdat, enum node_stat_item item,
 					long delta)
 {
-	mod_node_state(pgdat, item, delta, 0);
+	mod_node_state_check(pgdat, item, delta, 0);
 }
-EXPORT_SYMBOL(mod_node_page_state);
+EXPORT_SYMBOL(mod_node_page_state_check);
 
-void inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+void inc_node_state_check(struct pglist_data *pgdat, enum node_stat_item item)
 {
-	mod_node_state(pgdat, item, 1, 1);
+	mod_node_state_check(pgdat, item, 1, 1);
 }
 
-void inc_node_page_state(struct page *page, enum node_stat_item item)
+void inc_node_page_state_check(struct page *page, enum node_stat_item item)
 {
-	mod_node_state(page_pgdat(page), item, 1, 1);
+	mod_node_state_check(page_pgdat(page), item, 1, 1);
 }
-EXPORT_SYMBOL(inc_node_page_state);
+EXPORT_SYMBOL(inc_node_page_state_check);
 
-void dec_node_page_state(struct page *page, enum node_stat_item item)
+void dec_node_page_state_check(struct page *page, enum node_stat_item item)
 {
-	mod_node_state(page_pgdat(page), item, -1, -1);
+	mod_node_state_check(page_pgdat(page), item, -1, -1);
 }
-EXPORT_SYMBOL(dec_node_page_state);
+EXPORT_SYMBOL(dec_node_page_state_check);
 #else
 /*
  * Use interrupt disable to serialize counter updates
  */
-void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
+void mod_zone_page_state_check(struct zone *zone, enum zone_stat_item item,
 			 long delta)
 {
 	unsigned long flags;
 
 	local_irq_save(flags);
-	__mod_zone_page_state(zone, item, delta);
+	__mod_zone_page_state_check(zone, item, delta);
 	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(mod_zone_page_state);
+EXPORT_SYMBOL(mod_zone_page_state_check);
 
-void inc_zone_page_state(struct page *page, enum zone_stat_item item)
+void inc_zone_page_state_check(struct page *page, enum zone_stat_item item)
 {
 	unsigned long flags;
 	struct zone *zone;
 
 	zone = page_zone(page);
 	local_irq_save(flags);
-	__inc_zone_state(zone, item);
+	__inc_zone_state_check(zone, item);
 	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(inc_zone_page_state);
+EXPORT_SYMBOL(inc_zone_page_state_check);
 
-void dec_zone_page_state(struct page *page, enum zone_stat_item item)
+void dec_zone_page_state_check(struct page *page, enum zone_stat_item item)
 {
 	unsigned long flags;
 
 	local_irq_save(flags);
-	__dec_zone_page_state(page, item);
+	__dec_zone_page_state_check(page, item);
 	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(dec_zone_page_state);
+EXPORT_SYMBOL(dec_zone_page_state_check);
 
-void inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
+void inc_node_state_check(struct pglist_data *pgdat, enum node_stat_item item)
 {
 	unsigned long flags;
 
 	local_irq_save(flags);
-	__inc_node_state(pgdat, item);
+	__inc_node_state_check(pgdat, item);
 	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(inc_node_state);
+EXPORT_SYMBOL(inc_node_state_check);
 
-void mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
+void mod_node_page_state_check(struct pglist_data *pgdat, enum node_stat_item item,
 					long delta)
 {
 	unsigned long flags;
 
 	local_irq_save(flags);
-	__mod_node_page_state(pgdat, item, delta);
+	__mod_node_page_state_check(pgdat, item, delta);
 	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(mod_node_page_state);
+EXPORT_SYMBOL(mod_node_page_state_check);
 
-void inc_node_page_state(struct page *page, enum node_stat_item item)
+void inc_node_page_state_check(struct page *page, enum node_stat_item item)
 {
 	unsigned long flags;
 	struct pglist_data *pgdat;
 
 	pgdat = page_pgdat(page);
 	local_irq_save(flags);
-	__inc_node_state(pgdat, item);
+	__inc_node_state_check(pgdat, item);
 	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(inc_node_page_state);
+EXPORT_SYMBOL(inc_node_page_state_check);
 
-void dec_node_page_state(struct page *page, enum node_stat_item item)
+void dec_node_page_state_check(struct page *page, enum node_stat_item item)
 {
 	unsigned long flags;
 
 	local_irq_save(flags);
-	__dec_node_page_state(page, item);
+	__dec_node_page_state_check(page, item);
 	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(dec_node_page_state);
+EXPORT_SYMBOL(dec_node_page_state_check);
 #endif
 
 /*
@@ -775,7 +775,7 @@ void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
  * is called frequently in a NUMA machine, so try to be as
  * frugal as possible.
  */
-unsigned long sum_zone_node_page_state(int node,
+unsigned long sum_zone_node_page_state_check(int node,
 				 enum zone_stat_item item)
 {
 	struct zone *zones = NODE_DATA(node)->node_zones;
@@ -791,7 +791,7 @@ unsigned long sum_zone_node_page_state(int node,
 /*
  * Determine the per node value of a stat item.
  */
-unsigned long node_page_state(struct pglist_data *pgdat,
+unsigned long node_page_state_check(struct pglist_data *pgdat,
 				enum node_stat_item item)
 {
 	long x = atomic_long_read(&pgdat->vm_stat[item]);
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
