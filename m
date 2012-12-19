Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 886096B002B
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 08:54:05 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id wz7so1238293pbc.23
        for <linux-mm@kvack.org>; Wed, 19 Dec 2012 05:54:04 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V5] memcg, oom: provide more precise dump info while memcg oom happening
Date: Wed, 19 Dec 2012 21:51:01 +0800
Message-Id: <1355925061-3858-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Current when a memcg oom is happening the oom dump messages is still
global state and provides few useful info for users. This patch prints
more pointed memcg page statistics for memcg-oom and take hierarchy
into consideration:

Based on Michal's advice, we take hierarchy into consideration:
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
[  609.917309] mal-80 invoked oom-killer:gfp_mask=0xd0, order=0, oom_score_adj=0
[  609.917313] mal-80 cpuset=/ mems_allowed=0
[  609.917315] Pid: 2976, comm: mal-80 Not tainted 3.7.0+ #10
[  609.917316] Call Trace:
[  609.917327]  [<ffffffff8167fbfb>] dump_header+0x83/0x1ca
                ..... (call trace)
[  609.917389]  [<ffffffff8168a818>] page_fault+0x28/0x30
					<<<<<<<<<<<<<<<<<<<<< memcg specific information
[  609.917391] Task in /A/B/D killed as a result of limit of /A
[  609.917393] memory: usage 101376kB, limit 101376kB, failcnt 57
[  609.917394] memory+swap: usage 101376kB, limit 101376kB, failcnt 0
[  609.917395] kmem: usage 0kB, limit 9007199254740991kB, failcnt 0
					<<<<<<<<<<<<<<<<<<<<< print per cpu pageset stat
[  609.917396] Mem-Info:
[  609.917397] Node 0 DMA per-cpu:
[  609.917399] CPU    0: hi:    0, btch:   1 usd:   0
               ......
[  609.917402] CPU    3: hi:    0, btch:   1 usd:   0
[  609.917403] Node 0 DMA32 per-cpu:
[  609.917404] CPU    0: hi:  186, btch:  31 usd: 173
               ......
[  609.917407] CPU    3: hi:  186, btch:  31 usd: 130
					<<<<<<<<<<<<<<<<<<<<< print global page state
[  609.917415] active_anon:92963 inactive_anon:40777 isolated_anon:0
[  609.917415]  active_file:33027 inactive_file:51718 isolated_file:0
[  609.917415]  unevictable:0 dirty:3 writeback:0 unstable:0
[  609.917415]  free:729995 slab_reclaimable:6897 slab_unreclaimable:6263
[  609.917415]  mapped:20278 shmem:35971 pagetables:5885 bounce:0
[  609.917415]  free_cma:0
					<<<<<<<<<<<<<<<<<<<<< print per zone page state
[  609.917418] Node 0 DMA free:15836kB ... all_unreclaimable? no
[  609.917423] lowmem_reserve[]: 0 3175 3899 3899
[  609.917426] Node 0 DMA32 free:2888564kB ... all_unrelaimable? no
[  609.917430] lowmem_reserve[]: 0 0 724 724
[  609.917436] lowmem_reserve[]: 0 0 0 0
[  609.917438] Node 0 DMA: 1*4kB (U) ... 3*4096kB (M) = 15836kB
[  609.917447] Node 0 DMA32: 41*4kB (UM) ... 702*4096kB (MR) = 2888316kB
[  609.917466] 120710 total pagecache pages
[  609.917467] 0 pages in swap cache
					<<<<<<<<<<<<<<<<<<<<< print global swap cache stat
[  609.917468] Swap cache stats: add 0, delete 0, find 0/0
[  609.917469] Free swap  = 499708kB
[  609.917470] Total swap = 499708kB
[  609.929057] 1040368 pages RAM
[  609.929059] 58678 pages reserved
[  609.929060] 169065 pages shared
[  609.929061] 173632 pages non-shared
[  609.929062] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[  609.929101] [ 2693]     0  2693     6005     1324      17        0             0 god
[  609.929103] [ 2754]     0  2754     6003     1320      16        0             0 god
[  609.929105] [ 2811]     0  2811     5992     1304      18        0             0 god
[  609.929107] [ 2874]     0  2874     6005     1323      18        0             0 god
[  609.929109] [ 2935]     0  2935     8720     7742      21        0             0 mal-30
[  609.929111] [ 2976]     0  2976    21520    17577      42        0             0 mal-80
[  609.929112] Memory cgroup out of memory: Kill process 2976 (mal-80) score 665 or sacrifice child
[  609.929114] Killed process 2976 (mal-80) total-vm:86080kB, anon-rss:69964kB, file-rss:344kB

We can see that messages dumped by show_free_areas() are longsome and can
provide so limited info for memcg that just happen oom.

(2) After change
[  293.235042] mal-80 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
[  293.235046] mal-80 cpuset=/ mems_allowed=0
[  293.235048] Pid: 2704, comm: mal-80 Not tainted 3.7.0+ #10
[  293.235049] Call Trace:
[  293.235058]  [<ffffffff8167fd0b>] dump_header+0x83/0x1d1
		.......(call trace)
[  293.235108]  [<ffffffff8168a918>] page_fault+0x28/0x30
[  293.235110] Task in /A/B/D killed as a result of limit of /A
					<<<<<<<<<<<<<<<<<<<<< memcg specific information
[  293.235111] memory: usage 102400kB, limit 102400kB, failcnt 140
[  293.235112] memory+swap: usage 102400kB, limit 102400kB, failcnt 0
[  293.235114] kmem: usage 0kB, limit 9007199254740991kB, failcnt 0
[  293.235114] Memory cgroup stats for /A: cache:32KB rss:30984KB mapped_file:0KB swap:0KB inactive_anon:6912KB active_anon:24072KB inactive_file:32KB active_file:0KB unevictable:0KB
[  293.235122] Memory cgroup stats for /A/B: cache:0KB rss:0KB mapped_file:0KB swap:0KB inactive_anon:0KB active_anon:0KB inactive_file:0KB active_file:0KB unevictable:0KB
[  293.235127] Memory cgroup stats for /A/C: cache:0KB rss:0KB mapped_file:0KB swap:0KB inactive_anon:0KB active_anon:0KB inactive_file:0KB active_file:0KB unevictable:0KB
[  293.235132] Memory cgroup stats for /A/B/D: cache:32KB rss:71352KB mapped_file:0KB swap:0KB inactive_anon:6656KB active_anon:64696KB inactive_file:16KB active_file:16KB unevictable:0KB
[  293.235137] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[  293.235153] [ 2260]     0  2260     6006     1325      18        0             0 god
[  293.235155] [ 2383]     0  2383     6003     1319      17        0             0 god
[  293.235156] [ 2503]     0  2503     6004     1321      18        0             0 god
[  293.235158] [ 2622]     0  2622     6004     1321      16        0             0 god
[  293.235159] [ 2695]     0  2695     8720     7741      22        0             0 mal-30
[  293.235160] [ 2704]     0  2704    21520    17839      43        0             0 mal-80
[  293.235161] Memory cgroup out of memory: Kill process 2704 (mal-80) score 669 or sacrifice child
[  293.235163] Killed process 2704 (mal-80) total-vm:86080kB, anon-rss:71016kB, file-rss:340kB

This version provides more pointed info for memcg in "Memory cgroup stats
for XXX" section.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
Change log:
v5 <---V4
	1. rebase on -mm since-3.7
	2. modification of commit log
v4 <--- v3
	1. print more info in hierarchy	
v3 <--- v2
        1. fix towards hierarchy
        2. undo rework dump_tasks
v2 <--- v1
        1. some modification towards hierarchy
        2. rework dump_tasks
        3. rebased on Michal's mm tree since-3.6

 mm/memcontrol.c |   47 +++++++++++++++++++++++++++++++++++++----------
 mm/oom_kill.c   |    6 ++++--
 2 files changed, 41 insertions(+), 12 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1ea8951..b2fffb4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -120,6 +120,14 @@ static const char * const mem_cgroup_events_names[] = {
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
@@ -1590,8 +1598,9 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
 	spin_unlock_irqrestore(&memcg->move_lock, *flags);
 }
 
+#define K(x) ((x) << (PAGE_SHIFT-10))
 /**
- * mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held in read mode.
+ * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
  * @memcg: The memory cgroup that went over limit
  * @p: Task that is going to be killed
  *
@@ -1609,8 +1618,10 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	 */
 	static char memcg_name[PATH_MAX];
 	int ret;
+	struct mem_cgroup *iter;
+	unsigned int i;
 
-	if (!memcg || !p)
+	if (!p)
 		return;
 
 	rcu_read_lock();
@@ -1658,6 +1669,30 @@ done:
 		res_counter_read_u64(&memcg->kmem, RES_USAGE) >> 10,
 		res_counter_read_u64(&memcg->kmem, RES_LIMIT) >> 10,
 		res_counter_read_u64(&memcg->kmem, RES_FAILCNT));
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
+			pr_cont(" %s:%ldKB", mem_cgroup_stat_names[i],
+				K(mem_cgroup_read_stat(iter, i)));
+		}
+
+		for (i = 0; i < NR_LRU_LISTS; i++)
+			pr_cont(" %s:%luKB", mem_cgroup_lru_names[i],
+				K(mem_cgroup_nr_lru_pages(iter, BIT(i))));
+
+		pr_cont("\n");
+	}
 }
 
 /*
@@ -5379,14 +5414,6 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
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
