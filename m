Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4B76B0260
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 04:15:58 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id ez4so12516408wjd.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:15:58 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id j136si15275245wmf.102.2017.01.17.01.15.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 01:15:56 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id d140so20528772wmd.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:15:56 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/4] lib/show_mem.c: teach show_mem to work with the given nodemask
Date: Tue, 17 Jan 2017 10:15:43 +0100
Message-Id: <20170117091543.25850-5-mhocko@kernel.org>
In-Reply-To: <20170117091543.25850-1-mhocko@kernel.org>
References: <20170117091543.25850-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

show_mem() allows to filter out node specific data which is irrelevant
to the allocation request via SHOW_MEM_FILTER_NODES. The filtering
is done in skip_free_areas_node which skips all nodes which are not
in the mems_allowed of the current process. This works most of the
time as expected because the nodemask shouldn't be outside of the
allocating task but there are some exceptions. E.g. memory hotplug might
want to request allocations from outside of the allowed nodes (see
new_node_page).

Get rid of this hardcoded behavior and push the allocation mask down the
show_mem path and use it instead of cpuset_current_mems_allowed. NULL
nodemask is interpreted as cpuset_current_mems_allowed.

Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/powerpc/xmon/xmon.c            |  2 +-
 arch/sparc/kernel/setup_32.c        |  2 +-
 drivers/net/ethernet/sgi/ioc3-eth.c |  2 +-
 drivers/tty/sysrq.c                 |  2 +-
 drivers/tty/vt/keyboard.c           |  2 +-
 include/linux/mm.h                  |  5 ++---
 lib/show_mem.c                      |  4 ++--
 mm/nommu.c                          |  6 +++---
 mm/oom_kill.c                       |  2 +-
 mm/page_alloc.c                     | 38 ++++++++++++++++++-------------------
 10 files changed, 32 insertions(+), 33 deletions(-)

diff --git a/arch/powerpc/xmon/xmon.c b/arch/powerpc/xmon/xmon.c
index 760545519a0b..e285a89a65ec 100644
--- a/arch/powerpc/xmon/xmon.c
+++ b/arch/powerpc/xmon/xmon.c
@@ -913,7 +913,7 @@ cmds(struct pt_regs *excp)
 				memzcan();
 				break;
 			case 'i':
-				show_mem(0);
+				show_mem(0, NULL);
 				break;
 			default:
 				termch = cmd;
diff --git a/arch/sparc/kernel/setup_32.c b/arch/sparc/kernel/setup_32.c
index c4e65cb3280f..6f06058c5ae7 100644
--- a/arch/sparc/kernel/setup_32.c
+++ b/arch/sparc/kernel/setup_32.c
@@ -82,7 +82,7 @@ static void prom_sync_me(void)
 			     "nop\n\t" : : "r" (&trapbase));
 
 	prom_printf("PROM SYNC COMMAND...\n");
-	show_free_areas(0);
+	show_free_areas(0, NULL);
 	if (!is_idle_task(current)) {
 		local_irq_enable();
 		sys_sync();
diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index 7a254da85dd7..231e96d8bd14 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -914,7 +914,7 @@ static void ioc3_alloc_rings(struct net_device *dev)
 
 			skb = ioc3_alloc_skb(RX_BUF_ALLOC_SIZE, GFP_ATOMIC);
 			if (!skb) {
-				show_free_areas(0);
+				show_free_areas(0, NULL);
 				continue;
 			}
 
diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 52bbd27e93ae..667fa3931161 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -317,7 +317,7 @@ static struct sysrq_key_op sysrq_ftrace_dump_op = {
 
 static void sysrq_handle_showmem(int key)
 {
-	show_mem(0);
+	show_mem(0, NULL);
 }
 static struct sysrq_key_op sysrq_showmem_op = {
 	.handler	= sysrq_handle_showmem,
diff --git a/drivers/tty/vt/keyboard.c b/drivers/tty/vt/keyboard.c
index 0f8caae4267d..09511a362ade 100644
--- a/drivers/tty/vt/keyboard.c
+++ b/drivers/tty/vt/keyboard.c
@@ -572,7 +572,7 @@ static void fn_scroll_back(struct vc_data *vc)
 
 static void fn_show_mem(struct vc_data *vc)
 {
-	show_mem(0);
+	show_mem(0, NULL);
 }
 
 static void fn_show_state(struct vc_data *vc)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3e35eb04a28a..95488f901c6f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1124,8 +1124,7 @@ extern void pagefault_out_of_memory(void);
  */
 #define SHOW_MEM_FILTER_NODES		(0x0001u)	/* disallowed nodes */
 
-extern void show_free_areas(unsigned int flags);
-extern bool skip_free_areas_node(unsigned int flags, int nid);
+extern void show_free_areas(unsigned int flags, nodemask_t *nodemask);
 
 int shmem_zero_setup(struct vm_area_struct *);
 #ifdef CONFIG_SHMEM
@@ -1904,7 +1903,7 @@ extern void setup_per_zone_wmarks(void);
 extern int __meminit init_per_zone_wmark_min(void);
 extern void mem_init(void);
 extern void __init mmap_init(void);
-extern void show_mem(unsigned int flags);
+extern void show_mem(unsigned int flags, nodemask_t *nodemask);
 extern long si_mem_available(void);
 extern void si_meminfo(struct sysinfo * val);
 extern void si_meminfo_node(struct sysinfo *val, int nid);
diff --git a/lib/show_mem.c b/lib/show_mem.c
index 1feed6a2b12a..0beaa1d899aa 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -9,13 +9,13 @@
 #include <linux/quicklist.h>
 #include <linux/cma.h>
 
-void show_mem(unsigned int filter)
+void show_mem(unsigned int filter, nodemask_t *nodemask)
 {
 	pg_data_t *pgdat;
 	unsigned long total = 0, reserved = 0, highmem = 0;
 
 	printk("Mem-Info:\n");
-	show_free_areas(filter);
+	show_free_areas(filter, nodemask);
 
 	for_each_online_pgdat(pgdat) {
 		unsigned long flags;
diff --git a/mm/nommu.c b/mm/nommu.c
index ca239988fb68..5bd401b7f9a9 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1191,7 +1191,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
 enomem:
 	pr_err("Allocation of length %lu from process %d (%s) failed\n",
 	       len, current->pid, current->comm);
-	show_free_areas(0);
+	show_free_areas(0, NULL);
 	return -ENOMEM;
 }
 
@@ -1412,13 +1412,13 @@ unsigned long do_mmap(struct file *file,
 	kmem_cache_free(vm_region_jar, region);
 	pr_warn("Allocation of vma for %lu byte allocation from process %d failed\n",
 			len, current->pid);
-	show_free_areas(0);
+	show_free_areas(0, NULL);
 	return -ENOMEM;
 
 error_getting_region:
 	pr_warn("Allocation of vm region for %lu byte allocation from process %d failed\n",
 			len, current->pid);
-	show_free_areas(0);
+	show_free_areas(0, NULL);
 	return -ENOMEM;
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ead093c6f2a6..7cf61b928ba8 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -417,7 +417,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 	if (oc->memcg)
 		mem_cgroup_print_oom_info(oc->memcg, p);
 	else
-		show_mem(SHOW_MEM_FILTER_NODES);
+		show_mem(SHOW_MEM_FILTER_NODES, nm);
 	if (sysctl_oom_dump_tasks)
 		dump_tasks(oc->memcg, oc->nodemask);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7f9c0ee18ae0..380bfe340336 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3008,7 +3008,7 @@ static inline bool should_suppress_show_mem(void)
 	return ret;
 }
 
-static void warn_alloc_show_mem(gfp_t gfp_mask)
+static void warn_alloc_show_mem(gfp_t gfp_mask, nodemask_t *nodemask)
 {
 	unsigned int filter = SHOW_MEM_FILTER_NODES;
 	static DEFINE_RATELIMIT_STATE(show_mem_rs, HZ, 1);
@@ -3028,7 +3028,7 @@ static void warn_alloc_show_mem(gfp_t gfp_mask)
 	if (in_interrupt() || !(gfp_mask & __GFP_DIRECT_RECLAIM))
 		filter &= ~SHOW_MEM_FILTER_NODES;
 
-	show_mem(filter);
+	show_mem(filter, nodemask);
 }
 
 void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
@@ -3055,7 +3055,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	cpuset_print_current_mems_allowed();
 
 	dump_stack();
-	warn_alloc_show_mem(gfp_mask);
+	warn_alloc_show_mem(gfp_mask, nm);
 }
 
 static inline struct page *
@@ -4251,20 +4251,20 @@ void si_meminfo_node(struct sysinfo *val, int nid)
  * Determine whether the node should be displayed or not, depending on whether
  * SHOW_MEM_FILTER_NODES was passed to show_free_areas().
  */
-bool skip_free_areas_node(unsigned int flags, int nid)
+static bool show_mem_node_skip(unsigned int flags, int nid, nodemask_t *nodemask)
 {
-	bool ret = false;
-	unsigned int cpuset_mems_cookie;
-
 	if (!(flags & SHOW_MEM_FILTER_NODES))
-		goto out;
+		return false;
 
-	do {
-		cpuset_mems_cookie = read_mems_allowed_begin();
-		ret = !node_isset(nid, cpuset_current_mems_allowed);
-	} while (read_mems_allowed_retry(cpuset_mems_cookie));
-out:
-	return ret;
+	/*
+	 * no node mask - aka implicit memory numa policy. Do not bother with the
+	 * synchronization - read_mems_allowed_begin - because we do not have to be
+	 * precise here.
+	 */
+	if (!nodemask)
+		nodemask = &cpuset_current_mems_allowed;
+
+	return !node_isset(nid, *nodemask);
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
@@ -4305,7 +4305,7 @@ static void show_migration_types(unsigned char type)
  * SHOW_MEM_FILTER_NODES: suppress nodes that are not allowed by current's
  *   cpuset.
  */
-void show_free_areas(unsigned int filter)
+void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 {
 	unsigned long free_pcp = 0;
 	int cpu;
@@ -4313,7 +4313,7 @@ void show_free_areas(unsigned int filter)
 	pg_data_t *pgdat;
 
 	for_each_populated_zone(zone) {
-		if (skip_free_areas_node(filter, zone_to_nid(zone)))
+		if (show_mem_node_skip(filter, zone_to_nid(zone), nodemask))
 			continue;
 
 		for_each_online_cpu(cpu)
@@ -4347,7 +4347,7 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_FREE_CMA_PAGES));
 
 	for_each_online_pgdat(pgdat) {
-		if (skip_free_areas_node(filter, pgdat->node_id))
+		if (show_mem_node_skip(filter, pgdat->node_id, nodemask))
 			continue;
 
 		printk("Node %d"
@@ -4399,7 +4399,7 @@ void show_free_areas(unsigned int filter)
 	for_each_populated_zone(zone) {
 		int i;
 
-		if (skip_free_areas_node(filter, zone_to_nid(zone)))
+		if (show_mem_node_skip(filter, zone_to_nid(zone), nodemask))
 			continue;
 
 		free_pcp = 0;
@@ -4464,7 +4464,7 @@ void show_free_areas(unsigned int filter)
 		unsigned long nr[MAX_ORDER], flags, total = 0;
 		unsigned char types[MAX_ORDER];
 
-		if (skip_free_areas_node(filter, zone_to_nid(zone)))
+		if (show_mem_node_skip(filter, zone_to_nid(zone), nodemask))
 			continue;
 		show_node(zone);
 		printk(KERN_CONT "%s: ", zone->name);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
