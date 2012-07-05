Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 344376B0073
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 05:50:35 -0400 (EDT)
From: Jiang Liu <jiang.liu@huawei.com>
Subject: [PATCH 1/4] mm/hotplug: correctly setup fallback zonelists when creating new pgdat
Date: Thu, 5 Jul 2012 17:45:29 +0800
Message-ID: <1341481532-1700-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Bjorn Helgaas <bhelgaas@google.com>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>

When hotadd_new_pgdat() is called to create new pgdat for a new node,
a fallback zonelist should be created for the new node. There's code
to try to achieve that in hotadd_new_pgdat() as below:
	/*
	 * The node we allocated has no zone fallback lists. For avoiding
	 * to access not-initialized zonelist, build here.
	 */
	mutex_lock(&zonelists_mutex);
	build_all_zonelists(pgdat, NULL);
	mutex_unlock(&zonelists_mutex);

But it doesn't work as expected. When hotadd_new_pgdat() is called, the
new node is still in offline state because node_set_online(nid) hasn't
been called yet. And build_all_zonelists() only builds zonelists for
online nodes as:
        for_each_online_node(nid) {
                pg_data_t *pgdat = NODE_DATA(nid);

                build_zonelists(pgdat);
                build_zonelist_cache(pgdat);
        }

Though we hope to create zonelist for the new pgdat, but it doesn't.
So add a new parameter "pgdat" the build_all_zonelists() to build pgdat
for the new pgdat too.

Signed-off-by: Jiang Liu <liuj97@gmail.com>
Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/mmzone.h |    2 +-
 init/main.c            |    2 +-
 kernel/cpu.c           |    2 +-
 mm/memory_hotplug.c    |    4 ++--
 mm/page_alloc.c        |   17 ++++++++++++-----
 5 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2427706..8ddbfb4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -718,7 +718,7 @@ typedef struct pglist_data {
 #include <linux/memory_hotplug.h>
 
 extern struct mutex zonelists_mutex;
-void build_all_zonelists(void *data);
+void build_all_zonelists(pg_data_t *pgdat, struct zone *zone);
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
 bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		int classzone_idx, int alloc_flags);
diff --git a/init/main.c b/init/main.c
index b5cc0a7..622364d 100644
--- a/init/main.c
+++ b/init/main.c
@@ -501,7 +501,7 @@ asmlinkage void __init start_kernel(void)
 	setup_per_cpu_areas();
 	smp_prepare_boot_cpu();	/* arch-specific boot-cpu hooks */
 
-	build_all_zonelists(NULL);
+	build_all_zonelists(NULL, NULL);
 	page_alloc_init();
 
 	printk(KERN_NOTICE "Kernel command line: %s\n", boot_command_line);
diff --git a/kernel/cpu.c b/kernel/cpu.c
index a4eb522..14d3258 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -416,7 +416,7 @@ int __cpuinit cpu_up(unsigned int cpu)
 
 	if (pgdat->node_zonelists->_zonerefs->zone == NULL) {
 		mutex_lock(&zonelists_mutex);
-		build_all_zonelists(NULL);
+		build_all_zonelists(NULL, NULL);
 		mutex_unlock(&zonelists_mutex);
 	}
 #endif
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0d7e3ec..f93c5b5 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -513,7 +513,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	zone->present_pages += onlined_pages;
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 	if (need_zonelists_rebuild)
-		build_all_zonelists(zone);
+		build_all_zonelists(NULL, zone);
 	else
 		zone_pcp_update(zone);
 
@@ -562,7 +562,7 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 	 * to access not-initialized zonelist, build here.
 	 */
 	mutex_lock(&zonelists_mutex);
-	build_all_zonelists(NULL);
+	build_all_zonelists(pgdat, NULL);
 	mutex_unlock(&zonelists_mutex);
 
 	return pgdat;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4403009..ebf319d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3030,7 +3030,7 @@ int numa_zonelist_order_handler(ctl_table *table, int write,
 			user_zonelist_order = oldval;
 		} else if (oldval != user_zonelist_order) {
 			mutex_lock(&zonelists_mutex);
-			build_all_zonelists(NULL);
+			build_all_zonelists(NULL, NULL);
 			mutex_unlock(&zonelists_mutex);
 		}
 	}
@@ -3413,10 +3413,17 @@ static __init_refok int __build_all_zonelists(void *data)
 {
 	int nid;
 	int cpu;
+	pg_data_t *self = data;
 
 #ifdef CONFIG_NUMA
 	memset(node_load, 0, sizeof(node_load));
 #endif
+
+	if (self && !node_online(self->node_id)) {
+		build_zonelists(self);
+		build_zonelist_cache(self);
+	}
+
 	for_each_online_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);
 
@@ -3461,7 +3468,7 @@ static __init_refok int __build_all_zonelists(void *data)
  * Called with zonelists_mutex held always
  * unless system_state == SYSTEM_BOOTING.
  */
-void __ref build_all_zonelists(void *data)
+void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
 {
 	set_zonelist_order();
 
@@ -3473,10 +3480,10 @@ void __ref build_all_zonelists(void *data)
 		/* we have to stop all cpus to guarantee there is no user
 		   of zonelist */
 #ifdef CONFIG_MEMORY_HOTPLUG
-		if (data)
-			setup_zone_pageset((struct zone *)data);
+		if (zone)
+			setup_zone_pageset(zone);
 #endif
-		stop_machine(__build_all_zonelists, NULL, NULL);
+		stop_machine(__build_all_zonelists, pgdat, NULL);
 		/* cpuset refresh routine should be here */
 	}
 	vm_total_pages = nr_free_pagecache_pages();
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
