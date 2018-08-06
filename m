Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id B4EA06B000C
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 12:15:34 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id l1-v6so1874461ywm.11
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 09:15:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p65-v6sor2671071ywp.455.2018.08.06.09.15.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 09:15:33 -0700 (PDT)
Date: Mon, 6 Aug 2018 09:15:29 -0700
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v2] mm: memcg: update memcg OOM messages on cgroup2
Message-ID: <20180806161529.GA410235@devbig004.ftw2.facebook.com>
References: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

mem_cgroup_print_oom_info() currently prints the same info for cgroup1
and cgroup2 OOMs.  It doesn't make much sense on cgroup2, which
doesn't use memsw or separate kmem accounting - the information
reported is both superflous and insufficient.  This patch updates the
memcg OOM messages on cgroup2 so that

* It prints memory and swap usages and limits used on cgroup2.

* It shows the same information as memory.stat.

I took out the recursive printing for cgroup2 because the amount of
output could be a lot and the benefits aren't clear.  An example dump
follows.

[   40.854197] stress invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=0, oo0
[   40.855239] stress cpuset=/ mems_allowed=0
[   40.855665] CPU: 6 PID: 1990 Comm: stress Not tainted 4.18.0-rc7-work+ #281
[   40.856260] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-2.el7 04/01/2014
[   40.857000] Call Trace:
[   40.857222]  dump_stack+0x5e/0x8b
[   40.857517]  dump_header+0x74/0x2fc
[   40.859106]  oom_kill_process+0x225/0x490
[   40.859449]  out_of_memory+0x111/0x530
[   40.859780]  mem_cgroup_out_of_memory+0x4b/0x80
[   40.860161]  mem_cgroup_oom_synchronize+0x3ff/0x450
[   40.861334]  pagefault_out_of_memory+0x2f/0x74
[   40.861718]  __do_page_fault+0x3de/0x460
[   40.862347]  page_fault+0x1e/0x30
[   40.862636] RIP: 0033:0x5566cd5aadd0
[   40.862940] Code: 0f 84 3c 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94 c0 89 04 24 41 83 fd 02 0f 8f f6
[   40.864558] RSP: 002b:00007ffd979ced40 EFLAGS: 00010206
[   40.865005] RAX: 0000000001f4f000 RBX: 00007f3a397d8010 RCX: 00007f3a397d8010
[   40.865615] RDX: 0000000000000000 RSI: 0000000004001000 RDI: 0000000000000000
[   40.866220] RBP: 00005566cd5abbb4 R08: 00000000ffffffff R09: 0000000000000000
[   40.866845] R10: 0000000000000022 R11: 0000000000000246 R12: ffffffffffffffff
[   40.867452] R13: 0000000000000002 R14: 0000000000001000 R15: 0000000004000000
[   40.868091] Task in /test-cgroup killed as a result of limit of /test-cgroup
[   40.868726] memory 33554432 (max 33554432)
[   40.869096] swap 0
[   40.869280] anon 32845824
[   40.869519] file 0
[   40.869730] kernel_stack 0
[   40.869966] slab 163840
[   40.870191] sock 0
[   40.870374] shmem 0
[   40.870566] file_mapped 0
[   40.870801] file_dirty 0
[   40.871039] file_writeback 0
[   40.871292] inactive_anon 0
[   40.871542] active_anon 32944128
[   40.871821] inactive_file 0
[   40.872077] active_file 0
[   40.872309] unevictable 0
[   40.872543] slab_reclaimable 0
[   40.872806] slab_unreclaimable 163840
[   40.873136] pgfault 8085
[   40.873358] pgmajfault 0
[   40.873589] pgrefill 0
[   40.873800] pgscan 0
[   40.873991] pgsteal 0
[   40.874202] pgactivate 0
[   40.874424] pgdeactivate 0
[   40.874663] pglazyfree 0
[   40.874881] pglazyfreed 0
[   40.875121] workingset_refault 0
[   40.875401] workingset_activate 0
[   40.875689] workingset_nodereclaim 0
[   40.875996] [ pid ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
[   40.876789] [ 1969]     0  1969     5121      970    86016        0             0 bash
[   40.877546] [ 1989]     0  1989     1998      260    61440        0             0 stress
[   40.878256] [ 1990]     0  1990    18383     8055   126976        0             0 stress
[   40.878955] Memory cgroup out of memory: Kill process 1990 (stress) score 987 or sacrifice child
[   40.879803] Killed process 1990 (stress) total-vm:73532kB, anon-rss:32008kB, file-rss:212kB, shmemB

v2: Updated commit message to include an example dump as suggested by
    Roman.

Signed-off-by: Tejun Heo <tj@kernel.org>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |  165 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 96 insertions(+), 69 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8c0280b3143e..86133e50a0b2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -177,6 +177,7 @@ struct mem_cgroup_event {
 
 static void mem_cgroup_threshold(struct mem_cgroup *memcg);
 static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
+static void __memory_stat_show(struct seq_file *m, struct mem_cgroup *memcg);
 
 /* Stuffs for move charges at task migration. */
 /*
@@ -1146,33 +1147,49 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 
 	rcu_read_unlock();
 
-	pr_info("memory: usage %llukB, limit %llukB, failcnt %lu\n",
-		K((u64)page_counter_read(&memcg->memory)),
-		K((u64)memcg->memory.max), memcg->memory.failcnt);
-	pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %lu\n",
-		K((u64)page_counter_read(&memcg->memsw)),
-		K((u64)memcg->memsw.max), memcg->memsw.failcnt);
-	pr_info("kmem: usage %llukB, limit %llukB, failcnt %lu\n",
-		K((u64)page_counter_read(&memcg->kmem)),
-		K((u64)memcg->kmem.max), memcg->kmem.failcnt);
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
+		pr_info("memory: usage %llukB, limit %llukB, failcnt %lu\n",
+			K((u64)page_counter_read(&memcg->memory)),
+			K((u64)memcg->memory.max), memcg->memory.failcnt);
+		pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %lu\n",
+			K((u64)page_counter_read(&memcg->memsw)),
+			K((u64)memcg->memsw.max), memcg->memsw.failcnt);
+		pr_info("kmem: usage %llukB, limit %llukB, failcnt %lu\n",
+			K((u64)page_counter_read(&memcg->kmem)),
+			K((u64)memcg->kmem.max), memcg->kmem.failcnt);
 
-	for_each_mem_cgroup_tree(iter, memcg) {
-		pr_info("Memory cgroup stats for ");
-		pr_cont_cgroup_path(iter->css.cgroup);
-		pr_cont(":");
+		for_each_mem_cgroup_tree(iter, memcg) {
+			pr_info("Memory cgroup stats for ");
+			pr_cont_cgroup_path(iter->css.cgroup);
+			pr_cont(":");
+
+			for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
+				if (memcg1_stats[i] == MEMCG_SWAP && !do_swap_account)
+					continue;
+				pr_cont(" %s:%luKB", memcg1_stat_names[i],
+					K(memcg_page_state(iter, memcg1_stats[i])));
+			}
 
-		for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
-			if (memcg1_stats[i] == MEMCG_SWAP && !do_swap_account)
-				continue;
-			pr_cont(" %s:%luKB", memcg1_stat_names[i],
-				K(memcg_page_state(iter, memcg1_stats[i])));
+			for (i = 0; i < NR_LRU_LISTS; i++)
+				pr_cont(" %s:%luKB", mem_cgroup_lru_names[i],
+					K(mem_cgroup_nr_lru_pages(iter, BIT(i))));
+
+			pr_cont("\n");
 		}
+	} else {
+		pr_info("memory %llu (max %llu)\n",
+			(u64)page_counter_read(&memcg->memory) * PAGE_SIZE,
+			(u64)memcg->memory.max * PAGE_SIZE);
 
-		for (i = 0; i < NR_LRU_LISTS; i++)
-			pr_cont(" %s:%luKB", mem_cgroup_lru_names[i],
-				K(mem_cgroup_nr_lru_pages(iter, BIT(i))));
+		if (memcg->swap.max == PAGE_COUNTER_MAX)
+			pr_info("swap %llu\n",
+				(u64)page_counter_read(&memcg->swap) * PAGE_SIZE);
+		else
+			pr_info("swap %llu (max %llu)\n",
+				(u64)page_counter_read(&memcg->swap) * PAGE_SIZE,
+				(u64)memcg->swap.max * PAGE_SIZE);
 
-		pr_cont("\n");
+		__memory_stat_show(NULL, memcg);
 	}
 }
 
@@ -5246,9 +5263,15 @@ static int memory_events_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static int memory_stat_show(struct seq_file *m, void *v)
+#define seq_pr_info(m, fmt, ...) do {					\
+	if ((m))							\
+		seq_printf(m, fmt, ##__VA_ARGS__);			\
+	else								\
+		printk(KERN_INFO fmt, ##__VA_ARGS__);			\
+} while (0)
+
+static void __memory_stat_show(struct seq_file *m, struct mem_cgroup *memcg)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
 	unsigned long stat[MEMCG_NR_STAT];
 	unsigned long events[NR_VM_EVENT_ITEMS];
 	int i;
@@ -5267,26 +5290,26 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	tree_stat(memcg, stat);
 	tree_events(memcg, events);
 
-	seq_printf(m, "anon %llu\n",
-		   (u64)stat[MEMCG_RSS] * PAGE_SIZE);
-	seq_printf(m, "file %llu\n",
-		   (u64)stat[MEMCG_CACHE] * PAGE_SIZE);
-	seq_printf(m, "kernel_stack %llu\n",
-		   (u64)stat[MEMCG_KERNEL_STACK_KB] * 1024);
-	seq_printf(m, "slab %llu\n",
-		   (u64)(stat[NR_SLAB_RECLAIMABLE] +
-			 stat[NR_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
-	seq_printf(m, "sock %llu\n",
-		   (u64)stat[MEMCG_SOCK] * PAGE_SIZE);
-
-	seq_printf(m, "shmem %llu\n",
-		   (u64)stat[NR_SHMEM] * PAGE_SIZE);
-	seq_printf(m, "file_mapped %llu\n",
-		   (u64)stat[NR_FILE_MAPPED] * PAGE_SIZE);
-	seq_printf(m, "file_dirty %llu\n",
-		   (u64)stat[NR_FILE_DIRTY] * PAGE_SIZE);
-	seq_printf(m, "file_writeback %llu\n",
-		   (u64)stat[NR_WRITEBACK] * PAGE_SIZE);
+	seq_pr_info(m, "anon %llu\n",
+		    (u64)stat[MEMCG_RSS] * PAGE_SIZE);
+	seq_pr_info(m, "file %llu\n",
+		    (u64)stat[MEMCG_CACHE] * PAGE_SIZE);
+	seq_pr_info(m, "kernel_stack %llu\n",
+		    (u64)stat[MEMCG_KERNEL_STACK_KB] * 1024);
+	seq_pr_info(m, "slab %llu\n",
+		    (u64)(stat[NR_SLAB_RECLAIMABLE] +
+			  stat[NR_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
+	seq_pr_info(m, "sock %llu\n",
+		    (u64)stat[MEMCG_SOCK] * PAGE_SIZE);
+
+	seq_pr_info(m, "shmem %llu\n",
+		    (u64)stat[NR_SHMEM] * PAGE_SIZE);
+	seq_pr_info(m, "file_mapped %llu\n",
+		    (u64)stat[NR_FILE_MAPPED] * PAGE_SIZE);
+	seq_pr_info(m, "file_dirty %llu\n",
+		    (u64)stat[NR_FILE_DIRTY] * PAGE_SIZE);
+	seq_pr_info(m, "file_writeback %llu\n",
+		    (u64)stat[NR_WRITEBACK] * PAGE_SIZE);
 
 	for (i = 0; i < NR_LRU_LISTS; i++) {
 		struct mem_cgroup *mi;
@@ -5294,37 +5317,41 @@ static int memory_stat_show(struct seq_file *m, void *v)
 
 		for_each_mem_cgroup_tree(mi, memcg)
 			val += mem_cgroup_nr_lru_pages(mi, BIT(i));
-		seq_printf(m, "%s %llu\n",
-			   mem_cgroup_lru_names[i], (u64)val * PAGE_SIZE);
+		seq_pr_info(m, "%s %llu\n",
+			    mem_cgroup_lru_names[i], (u64)val * PAGE_SIZE);
 	}
 
-	seq_printf(m, "slab_reclaimable %llu\n",
-		   (u64)stat[NR_SLAB_RECLAIMABLE] * PAGE_SIZE);
-	seq_printf(m, "slab_unreclaimable %llu\n",
-		   (u64)stat[NR_SLAB_UNRECLAIMABLE] * PAGE_SIZE);
+	seq_pr_info(m, "slab_reclaimable %llu\n",
+		    (u64)stat[NR_SLAB_RECLAIMABLE] * PAGE_SIZE);
+	seq_pr_info(m, "slab_unreclaimable %llu\n",
+		    (u64)stat[NR_SLAB_UNRECLAIMABLE] * PAGE_SIZE);
 
 	/* Accumulated memory events */
 
-	seq_printf(m, "pgfault %lu\n", events[PGFAULT]);
-	seq_printf(m, "pgmajfault %lu\n", events[PGMAJFAULT]);
-
-	seq_printf(m, "pgrefill %lu\n", events[PGREFILL]);
-	seq_printf(m, "pgscan %lu\n", events[PGSCAN_KSWAPD] +
-		   events[PGSCAN_DIRECT]);
-	seq_printf(m, "pgsteal %lu\n", events[PGSTEAL_KSWAPD] +
-		   events[PGSTEAL_DIRECT]);
-	seq_printf(m, "pgactivate %lu\n", events[PGACTIVATE]);
-	seq_printf(m, "pgdeactivate %lu\n", events[PGDEACTIVATE]);
-	seq_printf(m, "pglazyfree %lu\n", events[PGLAZYFREE]);
-	seq_printf(m, "pglazyfreed %lu\n", events[PGLAZYFREED]);
-
-	seq_printf(m, "workingset_refault %lu\n",
-		   stat[WORKINGSET_REFAULT]);
-	seq_printf(m, "workingset_activate %lu\n",
-		   stat[WORKINGSET_ACTIVATE]);
-	seq_printf(m, "workingset_nodereclaim %lu\n",
-		   stat[WORKINGSET_NODERECLAIM]);
+	seq_pr_info(m, "pgfault %lu\n", events[PGFAULT]);
+	seq_pr_info(m, "pgmajfault %lu\n", events[PGMAJFAULT]);
+
+	seq_pr_info(m, "pgrefill %lu\n", events[PGREFILL]);
+	seq_pr_info(m, "pgscan %lu\n", events[PGSCAN_KSWAPD] +
+		    events[PGSCAN_DIRECT]);
+	seq_pr_info(m, "pgsteal %lu\n", events[PGSTEAL_KSWAPD] +
+		    events[PGSTEAL_DIRECT]);
+	seq_pr_info(m, "pgactivate %lu\n", events[PGACTIVATE]);
+	seq_pr_info(m, "pgdeactivate %lu\n", events[PGDEACTIVATE]);
+	seq_pr_info(m, "pglazyfree %lu\n", events[PGLAZYFREE]);
+	seq_pr_info(m, "pglazyfreed %lu\n", events[PGLAZYFREED]);
 
+	seq_pr_info(m, "workingset_refault %lu\n",
+		    stat[WORKINGSET_REFAULT]);
+	seq_pr_info(m, "workingset_activate %lu\n",
+		    stat[WORKINGSET_ACTIVATE]);
+	seq_pr_info(m, "workingset_nodereclaim %lu\n",
+		    stat[WORKINGSET_NODERECLAIM]);
+}
+
+static int memory_stat_show(struct seq_file *m, void *v)
+{
+	__memory_stat_show(m, mem_cgroup_from_css(seq_css(m)));
 	return 0;
 }
 
