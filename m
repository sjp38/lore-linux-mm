Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3D2440901
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:00:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z81so10659206wrc.2
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:32 -0700 (PDT)
Received: from mail-wr0-f196.google.com (mail-wr0-f196.google.com. [209.85.128.196])
        by mx.google.com with ESMTPS id y23si6009727wrb.262.2017.07.14.01.00.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 01:00:30 -0700 (PDT)
Received: by mail-wr0-f196.google.com with SMTP id k67so11057663wrc.1
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:30 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/9] mm, memory_hotplug: drop zone from build_all_zonelists
Date: Fri, 14 Jul 2017 10:00:01 +0200
Message-Id: <20170714080006.7250-5-mhocko@kernel.org>
In-Reply-To: <20170714080006.7250-1-mhocko@kernel.org>
References: <20170714080006.7250-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Wen Congyang <wency@cn.fujitsu.com>

From: Michal Hocko <mhocko@suse.com>

build_all_zonelists gets a zone parameter to initialize zone's
pagesets. There is only a single user which gives a non-NULL
zone parameter and that one doesn't really need the rest of the
build_all_zonelists (see 6dcd73d7011b ("memory-hotplug: allocate zone's
pcp before onlining pages")).

Therefore remove setup_zone_pageset from build_all_zonelists and call it
from its only user directly. This will also remove a pointless zonlists
rebuilding which is always good.

Cc: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mmzone.h |  2 +-
 init/main.c            |  2 +-
 mm/internal.h          |  1 +
 mm/memory_hotplug.c    | 10 +++++-----
 mm/page_alloc.c        | 12 +++---------
 5 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fc14b8b3f6ce..97f0f42e9f2a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -771,7 +771,7 @@ static inline bool is_dev_zone(const struct zone *zone)
 #include <linux/memory_hotplug.h>
 
 extern struct mutex zonelists_mutex;
-void build_all_zonelists(pg_data_t *pgdat, struct zone *zone);
+void build_all_zonelists(pg_data_t *pgdat);
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
 bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 			 int classzone_idx, unsigned int alloc_flags,
diff --git a/init/main.c b/init/main.c
index f866510472d7..e1baf6544d15 100644
--- a/init/main.c
+++ b/init/main.c
@@ -519,7 +519,7 @@ asmlinkage __visible void __init start_kernel(void)
 	boot_cpu_state_init();
 	smp_prepare_boot_cpu();	/* arch-specific boot-cpu hooks */
 
-	build_all_zonelists(NULL, NULL);
+	build_all_zonelists(NULL);
 	page_alloc_init();
 
 	pr_notice("Kernel command line: %s\n", boot_command_line);
diff --git a/mm/internal.h b/mm/internal.h
index 24d88f084705..19d1f35aa6d7 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -522,4 +522,5 @@ static inline bool is_migrate_highatomic_page(struct page *page)
 	return get_pageblock_migratetype(page) == MIGRATE_HIGHATOMIC;
 }
 
+void setup_zone_pageset(struct zone *zone);
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d620d0427b6b..639b8af37c45 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -952,7 +952,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	mutex_lock(&zonelists_mutex);
 	if (!populated_zone(zone)) {
 		need_zonelists_rebuild = 1;
-		build_all_zonelists(NULL, zone);
+		setup_zone_pageset(zone);
 	}
 
 	ret = walk_system_ram_range(pfn, nr_pages, &onlined_pages,
@@ -973,7 +973,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	if (onlined_pages) {
 		node_states_set_node(nid, &arg);
 		if (need_zonelists_rebuild)
-			build_all_zonelists(NULL, NULL);
+			build_all_zonelists(NULL);
 		else
 			zone_pcp_update(zone);
 	}
@@ -1051,7 +1051,7 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 	 * to access not-initialized zonelist, build here.
 	 */
 	mutex_lock(&zonelists_mutex);
-	build_all_zonelists(pgdat, NULL);
+	build_all_zonelists(pgdat);
 	mutex_unlock(&zonelists_mutex);
 
 	/*
@@ -1107,7 +1107,7 @@ int try_online_node(int nid)
 
 	if (pgdat->node_zonelists->_zonerefs->zone == NULL) {
 		mutex_lock(&zonelists_mutex);
-		build_all_zonelists(NULL, NULL);
+		build_all_zonelists(NULL);
 		mutex_unlock(&zonelists_mutex);
 	}
 
@@ -1727,7 +1727,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	if (!populated_zone(zone)) {
 		zone_pcp_reset(zone);
 		mutex_lock(&zonelists_mutex);
-		build_all_zonelists(NULL, NULL);
+		build_all_zonelists(NULL);
 		mutex_unlock(&zonelists_mutex);
 	} else
 		zone_pcp_update(zone);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebc3311555b1..00e117922b3f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5065,7 +5065,6 @@ static void build_zonelists(pg_data_t *pgdat)
 static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch);
 static DEFINE_PER_CPU(struct per_cpu_pageset, boot_pageset);
 static DEFINE_PER_CPU(struct per_cpu_nodestat, boot_nodestats);
-static void setup_zone_pageset(struct zone *zone);
 
 /*
  * Global mutex to protect against size modification of zonelists
@@ -5146,19 +5145,14 @@ build_all_zonelists_init(void)
  * unless system_state == SYSTEM_BOOTING.
  *
  * __ref due to (1) call of __meminit annotated setup_zone_pageset
- * [we're only called with non-NULL zone through __meminit paths] and
- * (2) call of __init annotated helper build_all_zonelists_init
+ * and (2) call of __init annotated helper build_all_zonelists_init
  * [protected by SYSTEM_BOOTING].
  */
-void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
+void __ref build_all_zonelists(pg_data_t *pgdat)
 {
 	if (system_state == SYSTEM_BOOTING) {
 		build_all_zonelists_init();
 	} else {
-#ifdef CONFIG_MEMORY_HOTPLUG
-		if (zone)
-			setup_zone_pageset(zone);
-#endif
 		/* we have to stop all cpus to guarantee there is no user
 		   of zonelist */
 		stop_machine_cpuslocked(__build_all_zonelists, pgdat, NULL);
@@ -5432,7 +5426,7 @@ static void __meminit zone_pageset_init(struct zone *zone, int cpu)
 	pageset_set_high_and_batch(zone, pcp);
 }
 
-static void __meminit setup_zone_pageset(struct zone *zone)
+void __meminit setup_zone_pageset(struct zone *zone)
 {
 	int cpu;
 	zone->pageset = alloc_percpu(struct per_cpu_pageset);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
