From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 29 May 2008 15:50:43 -0400
Message-Id: <20080529195043.27159.89057.sendpatchset@lts-notebook>
In-Reply-To: <20080529195030.27159.66161.sendpatchset@lts-notebook>
References: <20080529195030.27159.66161.sendpatchset@lts-notebook>
Subject: [PATCH 14/25] Noreclaim LRU Page Statistics
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

Report non-reclaimable pages per zone and system wide.

Kosaki Motohiro added support for memory controller noreclaim
statistics.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

 drivers/base/node.c |    6 ++++++
 fs/proc/proc_misc.c |    6 ++++++
 mm/memcontrol.c     |    6 ++++++
 mm/page_alloc.c     |   16 +++++++++++++++-
 mm/vmstat.c         |    3 +++
 5 files changed, 36 insertions(+), 1 deletion(-)

Index: linux-2.6.26-rc2-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/page_alloc.c	2008-05-28 10:39:23.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/page_alloc.c	2008-05-28 10:42:52.000000000 -0400
@@ -1918,12 +1918,20 @@ void show_free_areas(void)
 	}
 
 	printk("Active_anon:%lu active_file:%lu inactive_anon%lu\n"
-		" inactive_file:%lu dirty:%lu writeback:%lu unstable:%lu\n"
+		" inactive_file:%lu"
+//TODO:  check/adjust line lengths
+#ifdef CONFIG_NORECLAIM_LRU
+		" noreclaim:%lu"
+#endif
+		" dirty:%lu writeback:%lu unstable:%lu\n"
 		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_ACTIVE_FILE),
 		global_page_state(NR_INACTIVE_ANON),
 		global_page_state(NR_INACTIVE_FILE),
+#ifdef CONFIG_NORECLAIM_LRU
+		global_page_state(NR_NORECLAIM),
+#endif
 		global_page_state(NR_FILE_DIRTY),
 		global_page_state(NR_WRITEBACK),
 		global_page_state(NR_UNSTABLE_NFS),
@@ -1950,6 +1958,9 @@ void show_free_areas(void)
 			" inactive_anon:%lukB"
 			" active_file:%lukB"
 			" inactive_file:%lukB"
+#ifdef CONFIG_NORECLAIM_LRU
+			" noreclaim:%lukB"
+#endif
 			" present:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -1963,6 +1974,9 @@ void show_free_areas(void)
 			K(zone_page_state(zone, NR_INACTIVE_ANON)),
 			K(zone_page_state(zone, NR_ACTIVE_FILE)),
 			K(zone_page_state(zone, NR_INACTIVE_FILE)),
+#ifdef CONFIG_NORECLAIM_LRU
+			K(zone_page_state(zone, NR_NORECLAIM)),
+#endif
 			K(zone->present_pages),
 			zone->pages_scanned,
 			(zone_is_all_unreclaimable(zone) ? "yes" : "no")
Index: linux-2.6.26-rc2-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/vmstat.c	2008-05-28 10:37:46.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/vmstat.c	2008-05-28 10:42:52.000000000 -0400
@@ -699,6 +699,9 @@ static const char * const vmstat_text[] 
 	"nr_active_anon",
 	"nr_inactive_file",
 	"nr_active_file",
+#ifdef CONFIG_NORECLAIM_LRU
+	"nr_noreclaim",
+#endif
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
Index: linux-2.6.26-rc2-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/drivers/base/node.c	2008-05-28 10:37:46.000000000 -0400
+++ linux-2.6.26-rc2-mm1/drivers/base/node.c	2008-05-28 10:42:52.000000000 -0400
@@ -67,6 +67,9 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d Inactive(anon): %8lu kB\n"
 		       "Node %d Active(file):   %8lu kB\n"
 		       "Node %d Inactive(file): %8lu kB\n"
+#ifdef CONFIG_NORECLAIM_LRU
+		       "Node %d Noreclaim:      %8lu kB\n"
+#endif
 #ifdef CONFIG_HIGHMEM
 		       "Node %d HighTotal:      %8lu kB\n"
 		       "Node %d HighFree:       %8lu kB\n"
@@ -96,6 +99,9 @@ static ssize_t node_read_meminfo(struct 
 		       nid, node_page_state(nid, NR_INACTIVE_ANON),
 		       nid, node_page_state(nid, NR_ACTIVE_FILE),
 		       nid, node_page_state(nid, NR_INACTIVE_FILE),
+#ifdef CONFIG_NORECLAIM_LRU
+		       nid, node_page_state(nid, NR_NORECLAIM),
+#endif
 #ifdef CONFIG_HIGHMEM
 		       nid, K(i.totalhigh),
 		       nid, K(i.freehigh),
Index: linux-2.6.26-rc2-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/fs/proc/proc_misc.c	2008-05-28 10:37:46.000000000 -0400
+++ linux-2.6.26-rc2-mm1/fs/proc/proc_misc.c	2008-05-28 10:42:52.000000000 -0400
@@ -174,6 +174,9 @@ static int meminfo_read_proc(char *page,
 		"Inactive(anon): %8lu kB\n"
 		"Active(file):   %8lu kB\n"
 		"Inactive(file): %8lu kB\n"
+#ifdef CONFIG_NORECLAIM_LRU
+		"Noreclaim:      %8lu kB\n"
+#endif
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:      %8lu kB\n"
 		"HighFree:       %8lu kB\n"
@@ -209,6 +212,9 @@ static int meminfo_read_proc(char *page,
 		K(inactive_anon),
 		K(active_file),
 		K(inactive_file),
+#ifdef CONFIG_NORECLAIM_LRU
+		K(global_page_state(NR_NORECLAIM)),
+#endif
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
 		K(i.freehigh),
Index: linux-2.6.26-rc2-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/memcontrol.c	2008-05-28 10:43:06.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/memcontrol.c	2008-05-28 10:43:23.000000000 -0400
@@ -905,6 +905,7 @@ static int mem_control_stat_show(struct 
 	{
 		unsigned long active_anon, inactive_anon;
 		unsigned long active_file, inactive_file;
+		unsigned long noreclaim;
 
 		inactive_anon = mem_cgroup_get_all_zonestat(mem_cont,
 						LRU_INACTIVE_ANON);
@@ -914,10 +915,15 @@ static int mem_control_stat_show(struct 
 						LRU_INACTIVE_FILE);
 		active_file = mem_cgroup_get_all_zonestat(mem_cont,
 						LRU_ACTIVE_FILE);
+		noreclaim = mem_cgroup_get_all_zonestat(mem_cont,
+							LRU_NORECLAIM);
+
 		cb->fill(cb, "active_anon", (active_anon) * PAGE_SIZE);
 		cb->fill(cb, "inactive_anon", (inactive_anon) * PAGE_SIZE);
 		cb->fill(cb, "active_file", (active_file) * PAGE_SIZE);
 		cb->fill(cb, "inactive_file", (inactive_file) * PAGE_SIZE);
+		cb->fill(cb, "noreclaim", noreclaim * PAGE_SIZE);
+
 	}
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
