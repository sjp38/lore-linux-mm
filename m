Subject: RFC "Noreclaim Infrastructure patch 2/3 - noreclaim statistics..."
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070629141254.GA23310@v2.random>
References: <8e38f7656968417dfee0.1181332979@v2.random>
	 <466C36AE.3000101@redhat.com> <20070610181700.GC7443@v2.random>
	 <46814829.8090808@redhat.com>
	 <20070626105541.cd82c940.akpm@linux-foundation.org>
	 <468439E8.4040606@redhat.com> <1183124309.5037.31.camel@localhost>
	 <20070629141254.GA23310@v2.random>
Content-Type: text/plain
Date: Fri, 29 Jun 2007 18:44:21 -0400
Message-Id: <1183157061.7012.32.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Dokos <nicholas.dokos@hp.com>
List-ID: <linux-mm.kvack.org>

Patch against 2.6.21-rc5

n/m in the noreclaim series

Report non-reclaimable pages per zone and system wide.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 drivers/base/node.c |    6 ++++++
 fs/proc/proc_misc.c |    6 ++++++
 mm/page_alloc.c     |   16 +++++++++++++++-
 mm/vmstat.c         |    3 +++
 4 files changed, 30 insertions(+), 1 deletion(-)

Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-03-26 13:17:49.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-03-26 13:44:51.000000000 -0400
@@ -1574,10 +1574,18 @@ void show_free_areas(void)
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
@@ -1602,6 +1610,9 @@ void show_free_areas(void)
 			" high:%lukB"
 			" active:%lukB"
 			" inactive:%lukB"
+#ifdef CONFIG_NORECLAIM
+			" noreclaim:%lukB"
+#endif
 			" present:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -1613,6 +1624,9 @@ void show_free_areas(void)
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
--- Linux.orig/mm/vmstat.c	2007-03-26 12:39:02.000000000 -0400
+++ Linux/mm/vmstat.c	2007-03-26 13:35:43.000000000 -0400
@@ -434,6 +434,9 @@ static const char * const vmstat_text[] 
 	"nr_free_pages",
 	"nr_active",
 	"nr_inactive",
+#ifdef CONFIG_NORECLAIM
+	"nr_noreclaim",
+#endif
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
Index: Linux/drivers/base/node.c
===================================================================
--- Linux.orig/drivers/base/node.c	2007-03-26 12:38:59.000000000 -0400
+++ Linux/drivers/base/node.c	2007-03-26 13:37:35.000000000 -0400
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
--- Linux.orig/fs/proc/proc_misc.c	2007-03-26 12:39:01.000000000 -0400
+++ Linux/fs/proc/proc_misc.c	2007-03-26 13:39:05.000000000 -0400
@@ -154,6 +154,9 @@ static int meminfo_read_proc(char *page,
 		"SwapCached:   %8lu kB\n"
 		"Active:       %8lu kB\n"
 		"Inactive:     %8lu kB\n"
+#ifdef CONFIG_NORECLAIM
+		"Noreclaim:    %8lu kB\n"
+#endif
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:    %8lu kB\n"
 		"HighFree:     %8lu kB\n"
@@ -184,6 +187,9 @@ static int meminfo_read_proc(char *page,
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
