From: linux-kernel@vger.kernel.org
Subject: [patch 11/19] Non-reclaimable page statistics
Date: Wed, 02 Jan 2008 17:41:55 -0500
Message-ID: <20080102224154.700695350@redhat.com>
References: <20080102224144.885671949@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760009AbYABX00@vger.kernel.org>
Content-Disposition: inline; filename=noreclaim-01.2-report-nonreclaimable-memory.patch
Sender: linux-kernel-owner@vger.kernel.org
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com
List-Id: linux-mm.kvack.org

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

Index: linux-2.6.24-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/page_alloc.c	2008-01-02 12:37:58.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/page_alloc.c	2008-01-02 12:38:03.000000000 -0500
@@ -1899,12 +1899,20 @@ void show_free_areas(void)
 	}
 
 	printk("Active_anon:%lu active_file:%lu inactive_anon%lu\n"
-		" inactive_file:%lu dirty:%lu writeback:%lu unstable:%lu\n"
+		" inactive_file:%lu"
+//TODO:  check/adjust line lengths
+#ifdef CONFIG_NORECLAIM
+		" noreclaim:%lu"
+#endif
+		" dirty:%lu writeback:%lu unstable:%lu\n"
 		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_ACTIVE_FILE),
 		global_page_state(NR_INACTIVE_ANON),
 		global_page_state(NR_INACTIVE_FILE),
+#ifdef CONFIG_NORECLAIM
+		global_page_state(NR_NORECLAIM),
+#endif
 		global_page_state(NR_FILE_DIRTY),
 		global_page_state(NR_WRITEBACK),
 		global_page_state(NR_UNSTABLE_NFS),
@@ -1931,6 +1939,9 @@ void show_free_areas(void)
 			" inactive_anon:%lukB"
 			" active_file:%lukB"
 			" inactive_file:%lukB"
+#ifdef CONFIG_NORECLAIM
+			" noreclaim:%lukB"
+#endif
 			" present:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -1944,6 +1955,9 @@ void show_free_areas(void)
 			K(zone_page_state(zone, NR_INACTIVE_ANON)),
 			K(zone_page_state(zone, NR_ACTIVE_FILE)),
 			K(zone_page_state(zone, NR_INACTIVE_FILE)),
+#ifdef CONFIG_NORECLAIM
+			K(zone_page_state(zone, NR_NORECLAIM)),
+#endif
 			K(zone->present_pages),
 			zone->pages_scanned,
 			(zone_is_all_unreclaimable(zone) ? "yes" : "no")
Index: linux-2.6.24-rc6-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmstat.c	2008-01-02 12:37:48.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmstat.c	2008-01-02 12:38:03.000000000 -0500
@@ -690,6 +690,9 @@ static const char * const vmstat_text[] 
 	"nr_active_anon",
 	"nr_inactive_file",
 	"nr_active_file",
+#ifdef CONFIG_NORECLAIM
+	"nr_noreclaim",
+#endif
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
Index: linux-2.6.24-rc6-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/drivers/base/node.c	2008-01-02 12:37:38.000000000 -0500
+++ linux-2.6.24-rc6-mm1/drivers/base/node.c	2008-01-02 12:38:03.000000000 -0500
@@ -52,6 +52,9 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d Inactive(anon): %8lu kB\n"
 		       "Node %d Active(file):   %8lu kB\n"
 		       "Node %d Inactive(file): %8lu kB\n"
+#ifdef CONFIG_NORECLAIM
+		       "Node %d Noreclaim:    %8lu kB\n"
+#endif
 #ifdef CONFIG_HIGHMEM
 		       "Node %d HighTotal:      %8lu kB\n"
 		       "Node %d HighFree:       %8lu kB\n"
@@ -76,6 +79,9 @@ static ssize_t node_read_meminfo(struct 
 		       nid, node_page_state(nid, NR_INACTIVE_ANON),
 		       nid, node_page_state(nid, NR_ACTIVE_FILE),
 		       nid, node_page_state(nid, NR_INACTIVE_FILE),
+#ifdef CONFIG_NORECLAIM
+		       nid, node_page_state(nid, NR_NORECLAIM),
+#endif
 #ifdef CONFIG_HIGHMEM
 		       nid, K(i.totalhigh),
 		       nid, K(i.freehigh),
Index: linux-2.6.24-rc6-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/proc/proc_misc.c	2008-01-02 12:37:38.000000000 -0500
+++ linux-2.6.24-rc6-mm1/fs/proc/proc_misc.c	2008-01-02 12:38:03.000000000 -0500
@@ -162,6 +162,9 @@ static int meminfo_read_proc(char *page,
 		"Inactive(anon): %8lu kB\n"
 		"Active(file):   %8lu kB\n"
 		"Inactive(file): %8lu kB\n"
+#ifdef CONFIG_NORECLAIM
+		"Noreclaim:    %8lu kB\n"
+#endif
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:      %8lu kB\n"
 		"HighFree:       %8lu kB\n"
@@ -194,6 +197,9 @@ static int meminfo_read_proc(char *page,
 		K(global_page_state(NR_INACTIVE_ANON)),
 		K(global_page_state(NR_ACTIVE_FILE)),
 		K(global_page_state(NR_INACTIVE_FILE)),
+#ifdef CONFIG_NORECLAIM
+		K(global_page_state(NR_NORECLAIM)),
+#endif
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
 		K(i.freehigh),

-- 
All Rights Reversed

