Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 59C2D440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:00:35 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r123so8065213wmb.1
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:35 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id e21si1605401wmc.198.2017.07.14.01.00.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 01:00:34 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id y5so9362112wmh.3
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:34 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 8/9] mm, memory_hotplug: get rid of zonelists_mutex
Date: Fri, 14 Jul 2017 10:00:05 +0200
Message-Id: <20170714080006.7250-9-mhocko@kernel.org>
In-Reply-To: <20170714080006.7250-1-mhocko@kernel.org>
References: <20170714080006.7250-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

zonelists_mutex has been introduced by 4eaf3f64397c ("mem-hotplug: fix
potential race while building zonelist for new populated zone") to
protect zonelist building from races. This is no longer needed though
because both memory online and offline are fully serialized. New users
have grown since then.

Notably setup_per_zone_wmarks wants to prevent from races between memory
hotplug, khugepaged setup and manual min_free_kbytes update via sysctl
(see cfd3da1e49bb ("mm: Serialize access to min_free_kbytes"). Let's
add a private lock for that purpose. This will not prevent from seeing
halfway through memory hotplug operation but that shouldn't be a big
deal becuse memory hotplug will update watermarks explicitly so we will
eventually get a full picture. The lock just makes sure we won't race
when updating watermarks leading to weird results.

Also __build_all_zonelists manipulates global data so add a private lock
for it as well. This doesn't seem to be necessary today but it is more
robust to have a lock there.

While we are at it make sure we document that memory online/offline
depends on a full serialization either via mem_hotplug_begin() or
device_lock.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mmzone.h |  1 -
 mm/memory_hotplug.c    | 12 ++----------
 mm/page_alloc.c        | 18 +++++++++---------
 3 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 97f0f42e9f2a..3b638f989b7b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -770,7 +770,6 @@ static inline bool is_dev_zone(const struct zone *zone)
 
 #include <linux/memory_hotplug.h>
 
-extern struct mutex zonelists_mutex;
 void build_all_zonelists(pg_data_t *pgdat);
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
 bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0d2f6a11075c..c1b0077eb9d1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -917,7 +917,7 @@ static struct zone * __meminit move_pfn_range(int online_type, int nid,
 	return zone;
 }
 
-/* Must be protected by mem_hotplug_begin() */
+/* Must be protected by mem_hotplug_begin() or a device_lock */
 int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
 {
 	unsigned long flags;
@@ -949,7 +949,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	 * This means the page allocator ignores this zone.
 	 * So, zonelist must be updated after online.
 	 */
-	mutex_lock(&zonelists_mutex);
 	if (!populated_zone(zone)) {
 		need_zonelists_rebuild = 1;
 		setup_zone_pageset(zone);
@@ -960,7 +959,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	if (ret) {
 		if (need_zonelists_rebuild)
 			zone_pcp_reset(zone);
-		mutex_unlock(&zonelists_mutex);
 		goto failed_addition;
 	}
 
@@ -978,8 +976,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 			zone_pcp_update(zone);
 	}
 
-	mutex_unlock(&zonelists_mutex);
-
 	init_per_zone_wmark_min();
 
 	if (onlined_pages) {
@@ -1050,9 +1046,7 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 	 * The node we allocated has no zone fallback lists. For avoiding
 	 * to access not-initialized zonelist, build here.
 	 */
-	mutex_lock(&zonelists_mutex);
 	build_all_zonelists(pgdat);
-	mutex_unlock(&zonelists_mutex);
 
 	/*
 	 * zone->managed_pages is set to an approximate value in
@@ -1719,9 +1713,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 	if (!populated_zone(zone)) {
 		zone_pcp_reset(zone);
-		mutex_lock(&zonelists_mutex);
 		build_all_zonelists(NULL);
-		mutex_unlock(&zonelists_mutex);
 	} else
 		zone_pcp_update(zone);
 
@@ -1747,7 +1739,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	return ret;
 }
 
-/* Must be protected by mem_hotplug_begin() */
+/* Must be protected by mem_hotplug_begin() or a device_lock */
 int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 {
 	return __offline_pages(start_pfn, start_pfn + nr_pages, 120 * HZ);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 217889ecd13f..dd4c96edcec3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5060,17 +5060,14 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch);
 static DEFINE_PER_CPU(struct per_cpu_pageset, boot_pageset);
 static DEFINE_PER_CPU(struct per_cpu_nodestat, boot_nodestats);
 
-/*
- * Global mutex to protect against size modification of zonelists
- * as well as to serialize pageset setup for the new populated zone.
- */
-DEFINE_MUTEX(zonelists_mutex);
-
 static void __build_all_zonelists(void *data)
 {
 	int nid;
 	int cpu;
 	pg_data_t *self = data;
+	static DEFINE_SPINLOCK(lock);
+
+	spin_lock(&lock);
 
 #ifdef CONFIG_NUMA
 	memset(node_load, 0, sizeof(node_load));
@@ -5102,6 +5099,8 @@ static void __build_all_zonelists(void *data)
 			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
 #endif
 	}
+
+	spin_unlock(&lock);
 }
 
 static noinline void __init
@@ -5132,7 +5131,6 @@ build_all_zonelists_init(void)
 }
 
 /*
- * Called with zonelists_mutex held always
  * unless system_state == SYSTEM_BOOTING.
  *
  * __ref due to (1) call of __meminit annotated setup_zone_pageset
@@ -6874,9 +6872,11 @@ static void __setup_per_zone_wmarks(void)
  */
 void setup_per_zone_wmarks(void)
 {
-	mutex_lock(&zonelists_mutex);
+	static DEFINE_SPINLOCK(lock);
+
+	spin_lock(&lock);
 	__setup_per_zone_wmarks();
-	mutex_unlock(&zonelists_mutex);
+	spin_unlock(&lock);
 }
 
 /*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
