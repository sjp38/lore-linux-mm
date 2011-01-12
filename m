Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB686B0092
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 20:13:28 -0500 (EST)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p0C1DODm021948
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 17:13:24 -0800
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by hpaq6.eem.corp.google.com with ESMTP id p0C1D9Z2013724
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 17:13:23 -0800
Received: by pvc21 with SMTP id 21so14168pvc.17
        for <linux-mm@kvack.org>; Tue, 11 Jan 2011 17:13:22 -0800 (PST)
Date: Tue, 11 Jan 2011 17:13:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/3] oom: suppress nodes that are not allowed from meminfo
 on oom kill
Message-ID: <alpine.DEB.2.00.1101111712190.20611@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The oom killer is extremely verbose for machines with a large number of
cpus and/or nodes.  This verbosity can often be harmful if it causes
other important messages to be scrolled from the kernel log and incurs a
signicant time delay, specifically for kernels with
CONFIG_NODES_SHIFT > 8.

This patch causes only memory information to be displayed for nodes that
are allowed by current's cpuset when dumping the VM state.  Information
for all other nodes is irrelevant to the oom condition; we don't care if
there's an abundance of memory elsewhere if we can't access it.

This only affects the behavior of dumping memory information when an oom
is triggered.  Other dumps, such as for sysrq+m, still display the
unfiltered form when using the existing show_mem() interface.

Additionally, the per-cpu pageset statistics are extremely verbose in oom
killer output, so it is now suppressed.  This removes

	nodes_weight(current->mems_allowed) * (1 + nr_cpus)

lines from the oom killer output.

Callers may use __show_mem(SHOW_MEM_FILTER_NODES) to filter disallowed
nodes.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mm.h |    8 ++++++++
 lib/show_mem.c     |    9 +++++++--
 mm/oom_kill.c      |    2 +-
 mm/page_alloc.c    |   34 +++++++++++++++++++++++++++++++++-
 4 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -742,7 +742,14 @@ extern void pagefault_out_of_memory(void);
 
 #define offset_in_page(p)	((unsigned long)(p) & ~PAGE_MASK)
 
+/*
+ * Flags passed to __show_mem() and __show_free_areas() to suppress output in
+ * various contexts.
+ */
+#define SHOW_MEM_FILTER_NODES	(0x0001u)	/* filter disallowed nodes */
+
 extern void show_free_areas(void);
+extern void __show_free_areas(unsigned int flags);
 
 int shmem_lock(struct file *file, int lock, struct user_struct *user);
 struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags);
@@ -1226,6 +1233,7 @@ extern void calculate_zone_inactive_ratio(struct zone *zone);
 extern void mem_init(void);
 extern void __init mmap_init(void);
 extern void show_mem(void);
+extern void __show_mem(unsigned int flags);
 extern void si_meminfo(struct sysinfo * val);
 extern void si_meminfo_node(struct sysinfo *val, int nid);
 extern int after_bootmem;
diff --git a/lib/show_mem.c b/lib/show_mem.c
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -9,14 +9,14 @@
 #include <linux/nmi.h>
 #include <linux/quicklist.h>
 
-void show_mem(void)
+void __show_mem(unsigned int filter)
 {
 	pg_data_t *pgdat;
 	unsigned long total = 0, reserved = 0, shared = 0,
 		nonshared = 0, highmem = 0;
 
 	printk("Mem-Info:\n");
-	show_free_areas();
+	__show_free_areas(filter);
 
 	for_each_online_pgdat(pgdat) {
 		unsigned long i, flags;
@@ -61,3 +61,8 @@ void show_mem(void)
 		quicklist_total_size());
 #endif
 }
+
+void show_mem(void)
+{
+	__show_mem(0);
+}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -396,7 +396,7 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 	task_unlock(current);
 	dump_stack();
 	mem_cgroup_print_oom_info(mem, p);
-	show_mem();
+	__show_mem(SHOW_MEM_FILTER_NODES);
 	if (sysctl_oom_dump_tasks)
 		dump_tasks(mem, nodemask);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2358,19 +2358,42 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 }
 #endif
 
+/*
+ * Determine whether the zone's node should be displayed or not, depending on
+ * whether SHOW_MEM_FILTER_NODES was passed to __show_free_areas().
+ */
+static bool skip_free_areas_zone(unsigned int flags, const struct zone *zone)
+{
+	bool ret = false;
+
+	if (!(flags & SHOW_MEM_FILTER_NODES))
+		goto out;
+
+	get_mems_allowed();
+	ret = !node_isset(zone->zone_pgdat->node_id,
+				cpuset_current_mems_allowed);
+	put_mems_allowed();
+out:
+	return ret;
+}
+
 #define K(x) ((x) << (PAGE_SHIFT-10))
 
 /*
  * Show free area list (used inside shift_scroll-lock stuff)
  * We also calculate the percentage fragmentation. We do this by counting the
  * memory on each free list with the exception of the first item on the list.
+ * Suppresses nodes that are not allowed by current's cpuset if
+ * SHOW_MEM_FILTER_NODES is passed.
  */
-void show_free_areas(void)
+void __show_free_areas(unsigned int filter)
 {
 	int cpu;
 	struct zone *zone;
 
 	for_each_populated_zone(zone) {
+		if (skip_free_areas_zone(filter, zone))
+			continue;
 		show_node(zone);
 		printk("%s per-cpu:\n", zone->name);
 
@@ -2412,6 +2435,8 @@ void show_free_areas(void)
 	for_each_populated_zone(zone) {
 		int i;
 
+		if (skip_free_areas_zone(filter, zone))
+			continue;
 		show_node(zone);
 		printk("%s"
 			" free:%lukB"
@@ -2479,6 +2504,8 @@ void show_free_areas(void)
 	for_each_populated_zone(zone) {
 		unsigned long nr[MAX_ORDER], flags, order, total = 0;
 
+		if (skip_free_areas_zone(filter, zone))
+			continue;
 		show_node(zone);
 		printk("%s: ", zone->name);
 
@@ -2498,6 +2525,11 @@ void show_free_areas(void)
 	show_swap_cache_info();
 }
 
+void show_free_areas(void)
+{
+	__show_free_areas(0);
+}
+
 static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
 {
 	zoneref->zone = zone;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
