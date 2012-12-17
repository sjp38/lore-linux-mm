Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 535556B002B
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 06:03:20 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so2633356dak.14
        for <linux-mm@kvack.org>; Mon, 17 Dec 2012 03:03:19 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V4] memcg, oom: provide more precise dump info while memcg oom happening
Date: Mon, 17 Dec 2012 19:03:07 +0800
Message-Id: <1355742187-4111-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Current when a memcg oom is happening the oom dump messages is still global
state and provides few useful info for users. This patch prints more pointed
memcg page statistics for memcg-oom and take hierarchy into consideration:

Based on Michal's advice, we take hierarchy into consideration :
supppose we trigger an OOM on A's limit
        root_memcg
            |
            A (use_hierachy=1)
           / \
          B   C
          |
          D
then the printed info will be:
Memory cgroup stats for /A:...
Memory cgroup stats for /A/B:...
Memory cgroup stats for /A/C:...
Memory cgroup stats for /A/B/D:...

Following are samples of oom output:
(1)Before change:
[  204.308085] mal-80 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
[  204.308088] mal-80 cpuset=/ mems_allowed=0
[  204.308090] Pid: 2376, comm: mal-80 Not tainted 3.7.0+ #4
[  204.308091] Call Trace:
[  204.308100]  [<ffffffff81692515>] dump_header+0x83/0x1ca
[  204.308107]  [<ffffffff8112effe>] oom_kill_process+0x1be/0x320
                ..... (call trace)
[  204.308146]  [<ffffffff8169c418>] page_fault+0x28/0x30
[  204.308148] Task in /1/2 killed as a result of limit of /1
[  204.308150] memory: usage 102400kB, limit 102400kB, failcnt 181
[  204.308151] memory+swap: usage 102400kB, limit 102400kB, failcnt 0
[  204.308151] Mem-Info:
[  204.308152] Node 0 DMA per-cpu:			<<<<<<<<<<<<<<<<<<<<< print per cpu pageset stat
[  204.308154] CPU    0: hi:    0, btch:   1 usd:   0
               ......
[  204.308157] CPU    3: hi:    0, btch:   1 usd:   0
[  204.308158] Node 0 DMA32 per-cpu:
[  204.308159] CPU    0: hi:  186, btch:  31 usd: 134
               ......
[  204.308162] CPU    3: hi:  186, btch:  31 usd: 141
							<<<<<<<<<<<<<<<<<<<<< print global page state
[  204.308169] active_anon:94139 inactive_anon:41771 isolated_anon:0
[  204.308169]  active_file:24655 inactive_file:60269 isolated_file:0
[  204.308169]  unevictable:0 dirty:11 writeback:0 unstable:0
[  204.308169]  free:729657 slab_reclaimable:6861 slab_unreclaimable:6199
[  204.308169]  mapped:28794 shmem:35794 pagetables:5774 bounce:0
[  204.308169]  free_cma:0
							<<<<<<<<<<<<<<<<<<<<< print per zone page state
[  204.308171] Node 0 DMA free:15836kB min:260kB low:324kB high:388kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15596kB managed:15852kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  204.308174] lowmem_reserve[]: 0 3175 3899 3899
[  204.308176] Node 0 DMA32 free:2887244kB ...
[  204.308174] lowmem_reserve[]: 0 3175 3899 3899
[  204.308176] Node 0 DMA32 free:2887244kB ...
[  204.308185] lowmem_reserve[]: 0 0 0 0
[  204.308187] Node 0 DMA: 1*4kB (U) 1*8kB (U) ...
[  204.308196] Node 0 DMA32: 21*4kB (UEM) 58*8kB (UE) ...
[  204.308213] 120727 total pagecache pages
[  204.308214] 0 pages in swap cache
							<<<<<<<<<<<<<<<<<<<<< print global swap cache stat
[  204.308215] Swap cache stats: add 0, delete 0, find 0/0
[  204.308215] Free swap  = 499708kB
[  204.308216] Total swap = 499708kB
[  204.316300] 1040368 pages RAM
[  204.316304] 58707 pages reserved
[  204.316308] 175021 pages shared
[  204.316312] 174709 pages non-shared
[  204.316315] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[  204.316348] [ 1996]  1000  1996     6007     1324      17        0             0 bash
[  204.316354] [ 2283]  1000  2283     6008     1324      18        0             0 bash
[  204.316356] [ 2367]  1000  2367     8721     7742      22        0             0 mal-30
[  204.316358] [ 2376]  1000  2376    21521    17841      43        0             0 mal-80
[  204.316359] Memory cgroup out of memory: Kill process 2376 (mal-80) score 698 or sacrifice child
[  204.316361] Killed process 2376 (mal-80) total-vm:86084kB, anon-rss:71020kB, file-rss:344kB

We can see that messages dumped by show_free_areas() are longsome and can provide so limited info for memcg that just happen oom.

(2) After change
[  328.035727] mal-80 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
[  328.035730] mal-80 cpuset=/ mems_allowed=0
[  328.035732] Pid: 2439, comm: mal-80 Not tainted 3.7.0+ #5
[  328.035733] Call Trace:
[  328.035743]  [<ffffffff81692625>] dump_header+0x83/0x1d1
		.......(call trace)
[  328.035793] Task in /1/2 killed as a result of limit of /1
[  328.035795] memory: usage 101376kB, limit 101376kB, failcnt 815
[  328.035796] memory+swap: usage 101376kB, limit 101376kB, failcnt 0
[  328.035797] Memory cgroup stats for /1:cache:0KB rss:31052KB mapped_file:0KB swap:0KB inactive_anon:15620KB active_anon:15432KB inactive_file:0KB active_file:0KB unevictable:0KB
[  328.035804] Memory cgroup stats for /1/2:cache:44KB rss:70280KB mapped_file:0KB swap:0KB inactive_anon:16640KB active_anon:53608KB inactive_file:44KB active_file:0KB unevictable:0KB
[  328.035809] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[  328.035841] [ 2239]     0  2239     6005     1322      17        0             0 god
[  328.035843] [ 2361]     0  2361     6004     1321      17        0             0 god
[  328.035845] [ 2437]     0  2437     8721     7741      22        0             0 mal-30
[  328.035846] [ 2439]     0  2439    21521    17575      42        0             0 mal-80
[  328.035847] Memory cgroup out of memory: Kill process 2439 (mal-80) score 665 or sacrifice child
[  328.035849] Killed process 2439 (mal-80) total-vm:86084kB, anon-rss:69960kB, file-rss:340kB


This version provides more pointed info for memcg in "Memory cgroup stats" section.

Change log:
v4 <--- v3
	1. print more info in hierarchy	
v3 <--- v2
        1. fix towards hierarchy
        2. undo rework dump_tasks
v2 <--- v1
        1. some modification towards hierarchy
        2. rework dump_tasks
        3. rebased on Michal's mm tree since-3.6

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 mm/memcontrol.c |   47 +++++++++++++++++++++++++++++++++++++----------
 mm/oom_kill.c   |    6 ++++--
 2 files changed, 41 insertions(+), 12 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bbfac50..e2d17c8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -116,6 +116,14 @@ static const char * const mem_cgroup_events_names[] = {
 	"pgmajfault",
 };
 
+static const char * const mem_cgroup_lru_names[] = {
+	"inactive_anon",
+	"active_anon",
+	"inactive_file",
+	"active_file",
+	"unevictable",
+};
+
 /*
  * Per memcg event counter is incremented at every pagein/pageout. With THP,
  * it will be incremated by the number of pages. This counter is used for
@@ -1389,8 +1397,9 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
 	spin_unlock_irqrestore(&memcg->move_lock, *flags);
 }
 
+#define K(x) ((x) << (PAGE_SHIFT-10))
 /**
- * mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held in read mode.
+ * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
  * @memcg: The memory cgroup that went over limit
  * @p: Task that is going to be killed
  *
@@ -1408,8 +1417,10 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	 */
 	static char memcg_name[PATH_MAX];
 	int ret;
+	struct mem_cgroup *iter;
+	unsigned int i;
 
-	if (!memcg || !p)
+	if (!p)
 		return;
 
 	rcu_read_lock();
@@ -1453,6 +1464,30 @@ done:
 		res_counter_read_u64(&memcg->memsw, RES_USAGE) >> 10,
 		res_counter_read_u64(&memcg->memsw, RES_LIMIT) >> 10,
 		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
+
+	for_each_mem_cgroup_tree(iter, memcg) {
+		pr_info("Memory cgroup stats");
+
+		rcu_read_lock();
+		ret = cgroup_path(iter->css.cgroup, memcg_name, PATH_MAX);
+		if (!ret)
+			pr_cont(" for %s", memcg_name);
+		rcu_read_unlock();
+		pr_cont(":");
+
+		for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
+			if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
+				continue;
+			pr_cont("%s:%ldKB ", mem_cgroup_stat_names[i],
+				K(mem_cgroup_read_stat(iter, i)));
+		}
+
+		for (i = 0; i < NR_LRU_LISTS; i++)
+			pr_cont("%s:%luKB ", mem_cgroup_lru_names[i],
+				K(mem_cgroup_nr_lru_pages(iter, BIT(i))));
+
+		pr_cont("\n");
+	}
 }
 
 /*
@@ -4160,14 +4195,6 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
 }
 #endif /* CONFIG_NUMA */
 
-static const char * const mem_cgroup_lru_names[] = {
-	"inactive_anon",
-	"active_anon",
-	"inactive_file",
-	"active_file",
-	"unevictable",
-};
-
 static inline void mem_cgroup_lru_names_not_uptodate(void)
 {
 	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0399f14..79e451a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -386,8 +386,10 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 	cpuset_print_task_mems_allowed(current);
 	task_unlock(current);
 	dump_stack();
-	mem_cgroup_print_oom_info(memcg, p);
-	show_mem(SHOW_MEM_FILTER_NODES);
+	if (memcg)
+		mem_cgroup_print_oom_info(memcg, p);
+	else
+		show_mem(SHOW_MEM_FILTER_NODES);
 	if (sysctl_oom_dump_tasks)
 		dump_tasks(memcg, nodemask);
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
