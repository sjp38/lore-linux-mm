Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id EC04A6B0071
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 07:07:00 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3537203pbb.14
        for <linux-mm@kvack.org>; Thu, 28 Jun 2012 04:07:00 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 7/7] memcg: print more detailed info while memcg oom happening
Date: Thu, 28 Jun 2012 19:06:49 +0800
Message-Id: <1340881609-5935-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1340880885-5427-1-git-send-email-handai.szj@taobao.com>
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

While memcg oom happening, the dump info is limited, so add this
to provide memcg page stat.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 mm/memcontrol.c |   42 ++++++++++++++++++++++++++++++++++--------
 1 files changed, 34 insertions(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8493119..3ed41e9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -101,6 +101,14 @@ static const char * const mem_cgroup_events_names[] = {
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
@@ -1358,6 +1366,30 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
 	spin_unlock_irqrestore(&memcg->move_lock, *flags);
 }
 
+#define K(x) ((x) << (PAGE_SHIFT-10))
+static void mem_cgroup_print_oom_stat(struct mem_cgroup *memcg)
+{
+	int i;
+
+	printk(KERN_INFO "Memory cgroup stat:\n");
+	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
+		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
+			continue;
+		printk(KERN_CONT "%s:%ldKB ", mem_cgroup_stat_names[i],
+			   K(mem_cgroup_read_stat(memcg, i)));
+	}
+
+	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
+		printk(KERN_CONT "%s:%lu ", mem_cgroup_events_names[i],
+			   mem_cgroup_read_events(memcg, i));
+
+	for (i = 0; i < NR_LRU_LISTS; i++)
+		printk(KERN_CONT "%s:%luKB ", mem_cgroup_lru_names[i],
+			   K(mem_cgroup_nr_lru_pages(memcg, BIT(i))));
+	printk(KERN_CONT "\n");
+
+}
+
 /**
  * mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held in read mode.
  * @memcg: The memory cgroup that went over limit
@@ -1422,6 +1454,8 @@ done:
 		res_counter_read_u64(&memcg->memsw, RES_USAGE) >> 10,
 		res_counter_read_u64(&memcg->memsw, RES_LIMIT) >> 10,
 		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
+
+	mem_cgroup_print_oom_stat(memcg);
 }
 
 /*
@@ -4043,14 +4077,6 @@ static int mem_control_numa_stat_show(struct cgroup *cont, struct cftype *cft,
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
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
