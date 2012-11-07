Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id DB5E86B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 03:41:41 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so648014dad.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 00:41:41 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 1/2] memcg, oom: provide more precise dump info while memcg oom happening
Date: Wed,  7 Nov 2012 16:41:36 +0800
Message-Id: <1352277696-21724-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1352277602-21687-1-git-send-email-handai.szj@taobao.com>
References: <1352277602-21687-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, rientjes@google.com
Cc: linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Current, when a memcg oom is happening the oom dump messages is still global
state and provides few useful info for users. This patch prints more pointed
memcg page statistics for memcg-oom.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c |   71 ++++++++++++++++++++++++++++++++++++++++++++++++-------
 mm/oom_kill.c   |    6 +++-
 2 files changed, 66 insertions(+), 11 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0eab7d5..2df5e72 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -118,6 +118,14 @@ static const char * const mem_cgroup_events_names[] = {
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
@@ -1501,8 +1509,59 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
 	spin_unlock_irqrestore(&memcg->move_lock, *flags);
 }
 
+#define K(x) ((x) << (PAGE_SHIFT-10))
+static void mem_cgroup_print_oom_stat(struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *mi;
+	unsigned int i;
+
+	if (!memcg->use_hierarchy && memcg != root_mem_cgroup) {
+		for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
+			if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
+				continue;
+			printk(KERN_CONT "%s:%ldKB ", mem_cgroup_stat_names[i],
+				K(mem_cgroup_read_stat(memcg, i)));
+		}
+
+		for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
+			printk(KERN_CONT "%s:%lu ", mem_cgroup_events_names[i],
+				mem_cgroup_read_events(memcg, i));
+
+		for (i = 0; i < NR_LRU_LISTS; i++)
+			printk(KERN_CONT "%s:%luKB ", mem_cgroup_lru_names[i],
+				K(mem_cgroup_nr_lru_pages(memcg, BIT(i))));
+	} else {
+
+		for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
+			long long val = 0;
+
+			if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
+				continue;
+			for_each_mem_cgroup_tree(mi, memcg)
+				val += mem_cgroup_read_stat(mi, i);
+			printk(KERN_CONT "%s:%lldKB ", mem_cgroup_stat_names[i], K(val));
+		}
+
+		for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++) {
+			unsigned long long val = 0;
+
+			for_each_mem_cgroup_tree(mi, memcg)
+				val += mem_cgroup_read_events(mi, i);
+			printk(KERN_CONT "%s:%llu ",
+				mem_cgroup_events_names[i], val);
+		}
+
+		for (i = 0; i < NR_LRU_LISTS; i++) {
+			unsigned long long val = 0;
+
+			for_each_mem_cgroup_tree(mi, memcg)
+				val += mem_cgroup_nr_lru_pages(mi, BIT(i));
+			printk(KERN_CONT "%s:%lluKB ", mem_cgroup_lru_names[i], K(val));
+		}
+	}
+	printk(KERN_CONT "\n");
+}
 /**
- * mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held in read mode.
  * @memcg: The memory cgroup that went over limit
  * @p: Task that is going to be killed
  *
@@ -1569,6 +1628,8 @@ done:
 		res_counter_read_u64(&memcg->kmem, RES_USAGE) >> 10,
 		res_counter_read_u64(&memcg->kmem, RES_LIMIT) >> 10,
 		res_counter_read_u64(&memcg->kmem, RES_FAILCNT));
+
+	mem_cgroup_print_oom_stat(memcg);
 }
 
 /*
@@ -5195,14 +5256,6 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
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
index 7e9e911..4b8a6dd 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -421,8 +421,10 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
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
1.7.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
