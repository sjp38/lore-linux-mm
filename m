Message-Id: <20080304225227.524690568@redhat.com>
References: <20080304225157.573336066@redhat.com>
Date: Tue, 04 Mar 2008 17:52:09 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 12/20] Non-reclaimable page statistics
Content-Disposition: inline; filename=noreclaim-01.2-report-nonreclaimable-memory.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split LRU series

V1 -> V2:
	no changes

Report non-reclaimable pages per zone and system wide.

Note:  may want to track/report some specific reasons for 
nonreclaimability for deciding when to splice the noreclaim
lists back to the normal lru.  That will be tricky,
especially in shrink_active_list(), where we'd need someplace
to save the per page reason for non-reclaimability until the
pages are dumped back onto the noreclaim list from the pagevec.

Note:  my tests indicate that NR_NORECLAIM and probably the
other LRU stats aren't being maintained properly--especially
with large amounts of mlocked memory and the mlock patch in
this series installed.  Can't be sure of this, as I don't 
know why the pages are on the noreclaim list. Needs further
investigation.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.25-rc3-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/page_alloc.c	2008-03-04 16:07:35.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/page_alloc.c	2008-03-04 16:13:13.000000000 -0500
@@ -1914,12 +1914,20 @@ void show_free_areas(void)
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
@@ -1946,6 +1954,9 @@ void show_free_areas(void)
 			" inactive_anon:%lukB"
 			" active_file:%lukB"
 			" inactive_file:%lukB"
+#ifdef CONFIG_NORECLAIM_LRU
+			" noreclaim:%lukB"
+#endif
 			" present:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -1959,6 +1970,9 @@ void show_free_areas(void)
 			K(zone_page_state(zone, NR_INACTIVE_ANON)),
 			K(zone_page_state(zone, NR_ACTIVE_FILE)),
 			K(zone_page_state(zone, NR_INACTIVE_FILE)),
+#ifdef CONFIG_NORECLAIM_LRU
+			K(zone_page_state(zone, NR_NORECLAIM)),
+#endif
 			K(zone->present_pages),
 			zone->pages_scanned,
 			(zone_is_all_unreclaimable(zone) ? "yes" : "no")
Index: linux-2.6.25-rc3-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/vmstat.c	2008-03-04 15:39:31.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/vmstat.c	2008-03-04 16:13:13.000000000 -0500
@@ -690,6 +690,9 @@ static const char * const vmstat_text[] 
 	"nr_active_anon",
 	"nr_inactive_file",
 	"nr_active_file",
+#ifdef CONFIG_NORECLAIM_LRU
+	"nr_noreclaim",
+#endif
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
Index: linux-2.6.25-rc3-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/drivers/base/node.c	2008-03-04 15:30:20.000000000 -0500
+++ linux-2.6.25-rc3-mm1/drivers/base/node.c	2008-03-04 16:13:13.000000000 -0500
@@ -52,6 +52,9 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d Inactive(anon): %8lu kB\n"
 		       "Node %d Active(file):   %8lu kB\n"
 		       "Node %d Inactive(file): %8lu kB\n"
+#ifdef CONFIG_NORECLAIM_LRU
+		       "Node %d Noreclaim:    %8lu kB\n"
+#endif
 #ifdef CONFIG_HIGHMEM
 		       "Node %d HighTotal:      %8lu kB\n"
 		       "Node %d HighFree:       %8lu kB\n"
@@ -76,6 +79,9 @@ static ssize_t node_read_meminfo(struct 
 		       nid, node_page_state(nid, NR_INACTIVE_ANON),
 		       nid, node_page_state(nid, NR_ACTIVE_FILE),
 		       nid, node_page_state(nid, NR_INACTIVE_FILE),
+#ifdef CONFIG_NORECLAIM_LRU
+		       nid, node_page_state(nid, NR_NORECLAIM),
+#endif
 #ifdef CONFIG_HIGHMEM
 		       nid, K(i.totalhigh),
 		       nid, K(i.freehigh),
Index: linux-2.6.25-rc3-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/fs/proc/proc_misc.c	2008-03-04 15:30:20.000000000 -0500
+++ linux-2.6.25-rc3-mm1/fs/proc/proc_misc.c	2008-03-04 16:13:13.000000000 -0500
@@ -173,6 +173,9 @@ static int meminfo_read_proc(char *page,
 		"Inactive(anon): %8lu kB\n"
 		"Active(file):   %8lu kB\n"
 		"Inactive(file): %8lu kB\n"
+#ifdef CONFIG_NORECLAIM_LRU
+		"Noreclaim:    %8lu kB\n"
+#endif
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:      %8lu kB\n"
 		"HighFree:       %8lu kB\n"
@@ -207,6 +210,9 @@ static int meminfo_read_proc(char *page,
 		K(inactive_anon),
 		K(active_file),
 		K(inactive_file),
+#ifdef CONFIG_NORECLAIM_LRU
+		K(global_page_state(NR_NORECLAIM)),
+#endif
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
 		K(i.freehigh),

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
