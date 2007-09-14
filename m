From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:54:44 -0400
Message-Id: <20070914205444.6536.78981.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 7/14] Reclaim Scalability: Non-reclaimable page statistics
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

PATCH/RFC 07/14 Reclaim Scalability: Non-reclaimable page statistics

Against:  2.6.23-rc4-mm1

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

 drivers/base/node.c |    6 ++++++
 fs/proc/proc_misc.c |    6 ++++++
 mm/page_alloc.c     |   16 +++++++++++++++-
 mm/vmstat.c         |    3 +++
 4 files changed, 30 insertions(+), 1 deletion(-)

Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-09-14 10:22:05.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-09-14 10:23:49.000000000 -0400
@@ -1913,10 +1913,18 @@ void show_free_areas(void)
 		}
 	}
 
-	printk("Active:%lu inactive:%lu dirty:%lu writeback:%lu unstable:%lu\n"
+//TODO:  check/adjust line lengths
+	printk("Active:%lu inactive:%lu"
+#ifdef CONFIG_NORECLAIM
+		" noreclaim:%lu"
+#endif
+		" dirty:%lu writeback:%lu unstable:%lu\n"
 		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n",
 		global_page_state(NR_ACTIVE),
 		global_page_state(NR_INACTIVE),
+#ifdef CONFIG_NORECLAIM
+		global_page_state(NR_NORECLAIM),
+#endif
 		global_page_state(NR_FILE_DIRTY),
 		global_page_state(NR_WRITEBACK),
 		global_page_state(NR_UNSTABLE_NFS),
@@ -1941,6 +1949,9 @@ void show_free_areas(void)
 			" high:%lukB"
 			" active:%lukB"
 			" inactive:%lukB"
+#ifdef CONFIG_NORECLAIM
+			" noreclaim:%lukB"
+#endif
 			" present:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -1952,6 +1963,9 @@ void show_free_areas(void)
 			K(zone->pages_high),
 			K(zone_page_state(zone, NR_ACTIVE)),
 			K(zone_page_state(zone, NR_INACTIVE)),
+#ifdef CONFIG_NORECLAIM
+			K(zone_page_state(zone, NR_NORECLAIM)),
+#endif
 			K(zone->present_pages),
 			zone->pages_scanned,
 			(zone->all_unreclaimable ? "yes" : "no")
Index: Linux/mm/vmstat.c
===================================================================
--- Linux.orig/mm/vmstat.c	2007-09-14 10:22:05.000000000 -0400
+++ Linux/mm/vmstat.c	2007-09-14 10:23:49.000000000 -0400
@@ -686,6 +686,9 @@ static const char * const vmstat_text[] 
 	"nr_free_pages",
 	"nr_inactive",
 	"nr_active",
+#ifdef CONFIG_NORECLAIM
+	"nr_noreclaim",
+#endif
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
Index: Linux/drivers/base/node.c
===================================================================
--- Linux.orig/drivers/base/node.c	2007-09-14 10:22:05.000000000 -0400
+++ Linux/drivers/base/node.c	2007-09-14 10:23:49.000000000 -0400
@@ -49,6 +49,9 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d MemUsed:      %8lu kB\n"
 		       "Node %d Active:       %8lu kB\n"
 		       "Node %d Inactive:     %8lu kB\n"
+#ifdef CONFIG_NORECLAIM
+		       "Node %d Noreclaim:    %8lu kB\n"
+#endif
 #ifdef CONFIG_HIGHMEM
 		       "Node %d HighTotal:    %8lu kB\n"
 		       "Node %d HighFree:     %8lu kB\n"
@@ -71,6 +74,9 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(i.totalram - i.freeram),
 		       nid, node_page_state(nid, NR_ACTIVE),
 		       nid, node_page_state(nid, NR_INACTIVE),
+#ifdef CONFIG_NORECLAIM
+		       nid, node_page_state(nid, NR_NORECLAIM),
+#endif
 #ifdef CONFIG_HIGHMEM
 		       nid, K(i.totalhigh),
 		       nid, K(i.freehigh),
Index: Linux/fs/proc/proc_misc.c
===================================================================
--- Linux.orig/fs/proc/proc_misc.c	2007-09-14 10:22:05.000000000 -0400
+++ Linux/fs/proc/proc_misc.c	2007-09-14 10:23:49.000000000 -0400
@@ -157,6 +157,9 @@ static int meminfo_read_proc(char *page,
 		"SwapCached:   %8lu kB\n"
 		"Active:       %8lu kB\n"
 		"Inactive:     %8lu kB\n"
+#ifdef CONFIG_NORECLAIM
+		"Noreclaim:    %8lu kB\n"
+#endif
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:    %8lu kB\n"
 		"HighFree:     %8lu kB\n"
@@ -187,6 +190,9 @@ static int meminfo_read_proc(char *page,
 		K(total_swapcache_pages),
 		K(global_page_state(NR_ACTIVE)),
 		K(global_page_state(NR_INACTIVE)),
+#ifdef CONFIG_NORECLAIM
+		K(global_page_state(NR_NORECLAIM)),
+#endif
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
 		K(i.freehigh),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
