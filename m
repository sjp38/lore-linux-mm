Date: Thu, 25 Jan 2007 21:42:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070126054229.10564.27252.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
References: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 7/8] Drop get_zone_counts()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Nikita Danilov <nikita@clusterfs.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Get rid of get_zone_counts

Values are available via ZVC sums.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-rc6/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.20-rc6.orig/fs/proc/proc_misc.c	2007-01-25 10:52:06.000000000 -0800
+++ linux-2.6.20-rc6/fs/proc/proc_misc.c	2007-01-25 10:52:51.000000000 -0800
@@ -121,16 +121,11 @@ static int meminfo_read_proc(char *page,
 {
 	struct sysinfo i;
 	int len;
-	unsigned long inactive;
-	unsigned long active;
-	unsigned long free;
 	unsigned long committed;
 	unsigned long allowed;
 	struct vmalloc_info vmi;
 	long cached;
 
-	get_zone_counts(&active, &inactive, &free);
-
 /*
  * display in kilobytes.
  */
@@ -187,8 +182,8 @@ static int meminfo_read_proc(char *page,
 		K(i.bufferram),
 		K(cached),
 		K(total_swapcache_pages),
-		K(active),
-		K(inactive),
+		K(global_page_state(NR_ACTIVE)),
+		K(global_page_state(NR_INACTIVE)),
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
 		K(i.freehigh),
Index: linux-2.6.20-rc6/mm/page_alloc.c
===================================================================
--- linux-2.6.20-rc6.orig/mm/page_alloc.c	2007-01-25 10:52:50.000000000 -0800
+++ linux-2.6.20-rc6/mm/page_alloc.c	2007-01-25 10:52:51.000000000 -0800
@@ -1524,9 +1524,6 @@ void si_meminfo_node(struct sysinfo *val
 void show_free_areas(void)
 {
 	int cpu;
-	unsigned long active;
-	unsigned long inactive;
-	unsigned long free;
 	struct zone *zone;
 
 	for_each_zone(zone) {
@@ -1550,12 +1547,10 @@ void show_free_areas(void)
 		}
 	}
 
-	get_zone_counts(&active, &inactive, &free);
-
 	printk("Active:%lu inactive:%lu dirty:%lu writeback:%lu "
 		"unstable:%lu free:%lu slab:%lu mapped:%lu pagetables:%lu\n",
-		active,
-		inactive,
+		global_page_state(NR_ACTIVE),
+		global_page_state(NR_INACTIVE),
 		global_page_state(NR_FILE_DIRTY),
 		global_page_state(NR_WRITEBACK),
 		global_page_state(NR_UNSTABLE_NFS),
Index: linux-2.6.20-rc6/mm/vmstat.c
===================================================================
--- linux-2.6.20-rc6.orig/mm/vmstat.c	2007-01-25 10:52:51.000000000 -0800
+++ linux-2.6.20-rc6/mm/vmstat.c	2007-01-25 10:52:51.000000000 -0800
@@ -13,14 +13,6 @@
 #include <linux/module.h>
 #include <linux/cpu.h>
 
-void get_zone_counts(unsigned long *active,
-		unsigned long *inactive, unsigned long *free)
-{
-	*active = global_page_state(NR_ACTIVE);
-	*inactive = global_page_state(NR_INACTIVE);
-	*free = global_page_state(NR_FREE_PAGES);
-}
-
 #ifdef CONFIG_VM_EVENT_COUNTERS
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
 EXPORT_PER_CPU_SYMBOL(vm_event_states);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
