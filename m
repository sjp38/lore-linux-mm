Date: Thu, 25 Jan 2007 21:42:24 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070126054224.10564.64164.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
References: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 6/8] Drop __get_zone_counts()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Nikita Danilov <nikita@clusterfs.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Get rid of __get_zone_counts

Values are readily available via ZVC per node and global sums.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-rc6/drivers/base/node.c
===================================================================
--- linux-2.6.20-rc6.orig/drivers/base/node.c	2007-01-25 20:29:22.000000000 -0800
+++ linux-2.6.20-rc6/drivers/base/node.c	2007-01-25 20:30:17.000000000 -0800
@@ -40,13 +40,8 @@ static ssize_t node_read_meminfo(struct 
 	int n;
 	int nid = dev->id;
 	struct sysinfo i;
-	unsigned long inactive;
-	unsigned long active;
-	unsigned long free;
 
 	si_meminfo_node(&i, nid);
-	__get_zone_counts(&active, &inactive, &free, NODE_DATA(nid));
-
 
 	n = sprintf(buf, "\n"
 		       "Node %d MemTotal:     %8lu kB\n"
@@ -74,8 +69,8 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
 		       nid, K(i.totalram - i.freeram),
-		       nid, K(active),
-		       nid, K(inactive),
+		       nid, node_page_state(nid, NR_ACTIVE),
+		       nid, node_page_state(nid, NR_INACTIVE),
 #ifdef CONFIG_HIGHMEM
 		       nid, K(i.totalhigh),
 		       nid, K(i.freehigh),
Index: linux-2.6.20-rc6/include/linux/mmzone.h
===================================================================
--- linux-2.6.20-rc6.orig/include/linux/mmzone.h	2007-01-25 20:29:55.000000000 -0800
+++ linux-2.6.20-rc6/include/linux/mmzone.h	2007-01-25 20:29:58.000000000 -0800
@@ -444,8 +444,6 @@ typedef struct pglist_data {
 
 #include <linux/memory_hotplug.h>
 
-void __get_zone_counts(unsigned long *active, unsigned long *inactive,
-			unsigned long *free, struct pglist_data *pgdat);
 void get_zone_counts(unsigned long *active, unsigned long *inactive,
 			unsigned long *free);
 void build_all_zonelists(void);
Index: linux-2.6.20-rc6/mm/readahead.c
===================================================================
--- linux-2.6.20-rc6.orig/mm/readahead.c	2007-01-25 20:29:14.000000000 -0800
+++ linux-2.6.20-rc6/mm/readahead.c	2007-01-25 20:29:58.000000000 -0800
@@ -575,10 +575,6 @@ void handle_ra_miss(struct address_space
  */
 unsigned long max_sane_readahead(unsigned long nr)
 {
-	unsigned long active;
-	unsigned long inactive;
-	unsigned long free;
-
-	__get_zone_counts(&active, &inactive, &free, NODE_DATA(numa_node_id()));
-	return min(nr, (inactive + free) / 2);
+	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE)
+		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
 }
Index: linux-2.6.20-rc6/mm/vmstat.c
===================================================================
--- linux-2.6.20-rc6.orig/mm/vmstat.c	2007-01-25 20:29:55.000000000 -0800
+++ linux-2.6.20-rc6/mm/vmstat.c	2007-01-25 20:29:58.000000000 -0800
@@ -13,14 +13,6 @@
 #include <linux/module.h>
 #include <linux/cpu.h>
 
-void __get_zone_counts(unsigned long *active, unsigned long *inactive,
-			unsigned long *free, struct pglist_data *pgdat)
-{
-	*active = node_page_state(pgdat->node_id, NR_ACTIVE);
-	*inactive = node_page_state(pgdat->node_id, NR_INACTIVE);
-	*free = node_page_state(pgdat->node_id, NR_FREE_PAGES);
-}
-
 void get_zone_counts(unsigned long *active,
 		unsigned long *inactive, unsigned long *free)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
