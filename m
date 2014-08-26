Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC816B0038
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 03:29:30 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so22824307pab.15
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 00:29:30 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id kg8si2786399pab.152.2014.08.26.00.29.28
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 00:29:29 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC] mm: show deferred_compaction state in page alloc fail
Date: Tue, 26 Aug 2014 16:30:19 +0900
Message-Id: <1409038219-21483-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>

Recently, I saw several reports that high order allocation failed
although there were many freeable pages but it's hard to reproduce
so asking them to reproduce the problem several time is really painful.

A culprit I doubt is compaction deferring logic which prevent
compaction for a while so high order allocation could be fail.

It would be more clear if we can see the stat which can show
current zone's compaction deferred state when allocatil fail.

It's a RFC and never test it. I just get an idea with
handling another strange high order allocation fail.
Any comments are welcome.

Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/arm/mm/init.c                  |  4 ++--
 arch/ia64/mm/init.c                 |  4 ++--
 arch/metag/mm/init.c                |  2 +-
 arch/parisc/mm/init.c               |  4 ++--
 arch/powerpc/xmon/xmon.c            |  2 +-
 arch/sparc/kernel/setup_32.c        |  2 +-
 arch/sparc/mm/init_32.c             |  4 ++--
 arch/tile/mm/pgtable.c              |  2 +-
 arch/unicore32/mm/init.c            |  4 ++--
 drivers/net/ethernet/sgi/ioc3-eth.c |  2 +-
 drivers/tty/serial/68328serial.c    |  2 +-
 drivers/tty/sysrq.c                 |  2 +-
 drivers/tty/vt/keyboard.c           |  2 +-
 include/linux/compaction.h          | 25 ++++++++++++++++++++++---
 include/linux/mm.h                  |  4 ++--
 lib/show_mem.c                      |  4 ++--
 mm/nommu.c                          |  6 +++---
 mm/oom_kill.c                       |  2 +-
 mm/page_alloc.c                     | 10 ++++++----
 mm/vmscan.c                         |  2 +-
 20 files changed, 55 insertions(+), 34 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 659c75d808dc..2b5544072f2a 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -90,14 +90,14 @@ __tagtable(ATAG_INITRD2, parse_tag_initrd2);
  * initialization functions, as well as show_mem() for the skipping
  * of holes in the memory map.  It is populated by arm_add_memory().
  */
-void show_mem(unsigned int filter)
+void show_mem(unsigned int filter, int order)
 {
 	int free = 0, total = 0, reserved = 0;
 	int shared = 0, cached = 0, slab = 0;
 	struct memblock_region *reg;
 
 	printk("Mem-info:\n");
-	show_free_areas(filter);
+	show_free_areas(filter, order);
 
 	for_each_memblock (memory, reg) {
 		unsigned int pfn1, pfn2;
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 6b3345758d3e..c1e73e826032 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -723,14 +723,14 @@ __initcall(per_linux32_init);
  * Shows a simple page count of reserved and used pages in the system.
  * For discontig machines, it does this on a per-pgdat basis.
  */
-void show_mem(unsigned int filter)
+void show_mem(unsigned int filte, int order)
 {
 	int total_reserved = 0;
 	unsigned long total_present = 0;
 	pg_data_t *pgdat;
 
 	printk(KERN_INFO "Mem-info:\n");
-	show_free_areas(filter);
+	show_free_areas(filter, order);
 	printk(KERN_INFO "Node memory in pages:\n");
 	for_each_online_pgdat(pgdat) {
 		unsigned long present;
diff --git a/arch/metag/mm/init.c b/arch/metag/mm/init.c
index 11fa51c89617..7cab8983a1f5 100644
--- a/arch/metag/mm/init.c
+++ b/arch/metag/mm/init.c
@@ -390,7 +390,7 @@ void __init mem_init(void)
 
 	free_all_bootmem();
 	mem_init_print_info(NULL);
-	show_mem(0);
+	show_mem(0, 0);
 }
 
 void free_initmem(void)
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 0bef864264c0..2ed6f37aeb20 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -643,13 +643,13 @@ void __init mem_init(void)
 unsigned long *empty_zero_page __read_mostly;
 EXPORT_SYMBOL(empty_zero_page);
 
-void show_mem(unsigned int filter)
+void show_mem(unsigned int filter, int order)
 {
 	int total = 0,reserved = 0;
 	pg_data_t *pgdat;
 
 	printk(KERN_INFO "Mem-info:\n");
-	show_free_areas(filter);
+	show_free_areas(filter, order);
 
 	for_each_online_pgdat(pgdat) {
 		unsigned long flags;
diff --git a/arch/powerpc/xmon/xmon.c b/arch/powerpc/xmon/xmon.c
index b988b5addf86..411dc0c8ab1f 100644
--- a/arch/powerpc/xmon/xmon.c
+++ b/arch/powerpc/xmon/xmon.c
@@ -843,7 +843,7 @@ cmds(struct pt_regs *excp)
 				memzcan();
 				break;
 			case 'i':
-				show_mem(0);
+				show_mem(0, 0);
 				break;
 			default:
 				termch = cmd;
diff --git a/arch/sparc/kernel/setup_32.c b/arch/sparc/kernel/setup_32.c
index baef495c06bd..7fbcd331179f 100644
--- a/arch/sparc/kernel/setup_32.c
+++ b/arch/sparc/kernel/setup_32.c
@@ -84,7 +84,7 @@ static void prom_sync_me(void)
 			     "nop\n\t" : : "r" (&trapbase));
 
 	prom_printf("PROM SYNC COMMAND...\n");
-	show_free_areas(0);
+	show_free_areas(0, 0);
 	if (!is_idle_task(current)) {
 		local_irq_enable();
 		sys_sync();
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index eb8287155279..8fe4b5857ccd 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -55,10 +55,10 @@ extern unsigned int sparc_ramdisk_size;
 
 unsigned long highstart_pfn, highend_pfn;
 
-void show_mem(unsigned int filter)
+void show_mem(unsigned int filter, int order)
 {
 	printk("Mem-info:\n");
-	show_free_areas(filter);
+	show_free_areas(filter, order);
 	printk("Free swap:       %6ldkB\n",
 	       get_nr_swap_pages() << (PAGE_SHIFT-10));
 	printk("%ld pages of RAM\n", totalram_pages);
diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 5e86eac4bfae..004b6816aee4 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -40,7 +40,7 @@
  * The normal show_free_areas() is too verbose on Tile, with dozens
  * of processors and often four NUMA zones each with high and lowmem.
  */
-void show_mem(unsigned int filter)
+void show_mem(unsigned int filter, int order)
 {
 	struct zone *zone;
 
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index be2bde9b07cf..12d7f5d8a364 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -57,14 +57,14 @@ early_param("initrd", early_initrd);
  */
 struct meminfo meminfo;
 
-void show_mem(unsigned int filter)
+void show_mem(unsigned int filter, int order)
 {
 	int free = 0, total = 0, reserved = 0;
 	int shared = 0, cached = 0, slab = 0, i;
 	struct meminfo *mi = &meminfo;
 
 	printk(KERN_DEFAULT "Mem-info:\n");
-	show_free_areas(filter);
+	show_free_areas(filter, order);
 
 	for_each_bank(i, mi) {
 		struct membank *bank = &mi->bank[i];
diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index 7a254da85dd7..37268392af63 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -914,7 +914,7 @@ static void ioc3_alloc_rings(struct net_device *dev)
 
 			skb = ioc3_alloc_skb(RX_BUF_ALLOC_SIZE, GFP_ATOMIC);
 			if (!skb) {
-				show_free_areas(0);
+				show_free_areas(0, 0);
 				continue;
 			}
 
diff --git a/drivers/tty/serial/68328serial.c b/drivers/tty/serial/68328serial.c
index 5dc9c4bfa66e..5b0210f736ae 100644
--- a/drivers/tty/serial/68328serial.c
+++ b/drivers/tty/serial/68328serial.c
@@ -280,7 +280,7 @@ static void receive_chars(struct m68k_serial *info, unsigned short rx)
 #ifdef CONFIG_MAGIC_SYSRQ
 			} else if (ch == 0x10) { /* ^P */
 				show_state();
-				show_free_areas(0);
+				show_free_areas(0, 0);
 				show_buffers();
 /*				show_net_buffers(); */
 				return;
diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 42bad18c66c9..9212b69a0854 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -313,7 +313,7 @@ static struct sysrq_key_op sysrq_ftrace_dump_op = {
 
 static void sysrq_handle_showmem(int key)
 {
-	show_mem(0);
+	show_mem(0, 0);
 }
 static struct sysrq_key_op sysrq_showmem_op = {
 	.handler	= sysrq_handle_showmem,
diff --git a/drivers/tty/vt/keyboard.c b/drivers/tty/vt/keyboard.c
index d6ecfc9e734f..b16ce44c34c5 100644
--- a/drivers/tty/vt/keyboard.c
+++ b/drivers/tty/vt/keyboard.c
@@ -585,7 +585,7 @@ static void fn_scroll_back(struct vc_data *vc)
 
 static void fn_show_mem(struct vc_data *vc)
 {
-	show_mem(0);
+	show_mem(0, 0);
 }
 
 static void fn_show_state(struct vc_data *vc)
diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 01e3132820da..3a63b8931b18 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -47,8 +47,11 @@ static inline void defer_compaction(struct zone *zone, int order)
 		zone->compact_defer_shift = COMPACT_MAX_DEFER_SHIFT;
 }
 
-/* Returns true if compaction should be skipped this time */
-static inline bool compaction_deferred(struct zone *zone, int order)
+/*
+ * Returns true if compaction should be skipped this time, otherwise,
+ * it updates count for deferring internal logic.
+ */
+static inline bool compaction_deferred_and_update(struct zone *zone, int order)
 {
 	unsigned long defer_limit = 1UL << zone->compact_defer_shift;
 
@@ -62,6 +65,17 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return zone->compact_considered < defer_limit;
 }
 
+/* Check if compaction skipped due to deferred logic */
+static inline bool compaction_deferred(struct zone *zone, int order)
+{
+	unsigned long defer_limit = 1UL << zone->compact_defer_shift;
+
+	if (order < zone->compact_order_failed)
+		return false;
+
+	return zone->compact_considered < defer_limit;
+}
+
 /*
  * Update defer tracking counters after successful compaction of given order,
  * which means an allocation either succeeded (alloc_success == true) or is
@@ -113,11 +127,16 @@ static inline void defer_compaction(struct zone *zone, int order)
 {
 }
 
-static inline bool compaction_deferred(struct zone *zone, int order)
+static inline bool compaction_deferred_and_update(struct zone *zone, int order)
 {
 	return true;
 }
 
+static inline bool compaction_deferred(struct zone *zone, int order)
+{
+	return false
+}
+
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8981cc882ed2..e5c01f7a1b2a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1061,7 +1061,7 @@ extern void pagefault_out_of_memory(void);
  */
 #define SHOW_MEM_FILTER_NODES		(0x0001u)	/* disallowed nodes */
 
-extern void show_free_areas(unsigned int flags);
+extern void show_free_areas(unsigned int flags, int order);
 extern bool skip_free_areas_node(unsigned int flags, int nid);
 
 int shmem_zero_setup(struct vm_area_struct *);
@@ -1702,7 +1702,7 @@ extern void setup_per_zone_wmarks(void);
 extern int __meminit init_per_zone_wmark_min(void);
 extern void mem_init(void);
 extern void __init mmap_init(void);
-extern void show_mem(unsigned int flags);
+extern void show_mem(unsigned int flags, int order);
 extern void si_meminfo(struct sysinfo * val);
 extern void si_meminfo_node(struct sysinfo *val, int nid);
 
diff --git a/lib/show_mem.c b/lib/show_mem.c
index 09225796991a..281d07d555a7 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -9,13 +9,13 @@
 #include <linux/nmi.h>
 #include <linux/quicklist.h>
 
-void show_mem(unsigned int filter)
+void show_mem(unsigned int filter, int order)
 {
 	pg_data_t *pgdat;
 	unsigned long total = 0, reserved = 0, highmem = 0;
 
 	printk("Mem-Info:\n");
-	show_free_areas(filter);
+	show_free_areas(filter, order);
 
 	for_each_online_pgdat(pgdat) {
 		unsigned long flags;
diff --git a/mm/nommu.c b/mm/nommu.c
index 026ac6375aaa..5aef67daaaa6 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1251,7 +1251,7 @@ error_free:
 enomem:
 	pr_err("Allocation of length %lu from process %d (%s) failed\n",
 	       len, current->pid, current->comm);
-	show_free_areas(0);
+	show_free_areas(0, 0);
 	return -ENOMEM;
 }
 
@@ -1480,14 +1480,14 @@ error_getting_vma:
 	printk(KERN_WARNING "Allocation of vma for %lu byte allocation"
 	       " from process %d failed\n",
 	       len, current->pid);
-	show_free_areas(0);
+	show_free_areas(0, 0);
 	return -ENOMEM;
 
 error_getting_region:
 	printk(KERN_WARNING "Allocation of vm region for %lu byte allocation"
 	       " from process %d failed\n",
 	       len, current->pid);
-	show_free_areas(0);
+	show_free_areas(0, 0);
 	return -ENOMEM;
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1e11df8fa7ec..480bace374d4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -399,7 +399,7 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 	if (memcg)
 		mem_cgroup_print_oom_info(memcg, p);
 	else
-		show_mem(SHOW_MEM_FILTER_NODES);
+		show_mem(SHOW_MEM_FILTER_NODES, order);
 	if (sysctl_oom_dump_tasks)
 		dump_tasks(memcg, nodemask);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d0e3d2fee585..90b40c68c8a0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2193,7 +2193,7 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 
 	dump_stack();
 	if (!should_suppress_show_mem())
-		show_mem(filter);
+		show_mem(filter, order);
 }
 
 static inline int
@@ -2302,7 +2302,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	if (!order)
 		return NULL;
 
-	if (compaction_deferred(preferred_zone, order)) {
+	if (compaction_deferred_and_update(preferred_zone, order)) {
 		*deferred_compaction = true;
 		return NULL;
 	}
@@ -3148,7 +3148,7 @@ static void show_migration_types(unsigned char type)
  * Suppresses nodes that are not allowed by current's cpuset if
  * SHOW_MEM_FILTER_NODES is passed.
  */
-void show_free_areas(unsigned int filter)
+void show_free_areas(unsigned int filter, int order)
 {
 	int cpu;
 	struct zone *zone;
@@ -3231,6 +3231,7 @@ void show_free_areas(unsigned int filter)
 			" writeback_tmp:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
+			" deferred_compaction? %s"
 			"\n",
 			zone->name,
 			K(zone_page_state(zone, NR_FREE_PAGES)),
@@ -3261,7 +3262,8 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
 			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
 			K(zone_page_state(zone, NR_PAGES_SCANNED)),
-			(!zone_reclaimable(zone) ? "yes" : "no")
+			(!zone_reclaimable(zone) ? "yes" : "no"),
+			(compaction_deferred(zone, order) ? "yes" : "no")
 			);
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2836b5373b2e..dd0708d0343c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2336,7 +2336,7 @@ static inline bool compaction_ready(struct zone *zone, int order)
 	 * If compaction is deferred, reclaim up to a point where
 	 * compaction will have a chance of success when re-enabled
 	 */
-	if (compaction_deferred(zone, order))
+	if (compaction_deferred_and_update(zone, order))
 		return watermark_ok;
 
 	/* If compaction is not ready to start, keep reclaiming */
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
