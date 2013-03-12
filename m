Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 497376B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 06:09:55 -0400 (EDT)
Received: by mail-da0-f51.google.com with SMTP id z17so1200989dal.24
        for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:09:54 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 2/6] memcg: Don't account root memcg CACHE/RSS stats
Date: Tue, 12 Mar 2013 18:09:37 +0800
Message-Id: <1363082977-3753-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1363082773-3598-1-git-send-email-handai.szj@taobao.com>
References: <1363082773-3598-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, glommer@parallels.com, akpm@linux-foundation.org, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

If memcg is enabled and no non-root memcg exists, all allocated pages
belong to root_mem_cgroup and go through root memcg statistics routines
which brings some overheads.

So for the sake of performance, we can give up accounting stats of root
memcg for MEM_CGROUP_STAT_CACHE/RSS and instead we pay special attention
to memcg_stat_show() while showing root memcg numbers:
as we don't account root memcg stats anymore, the root_mem_cgroup->stat
numbers are actually 0. So we fake these numbers by using stats of global
state and all other memcg. That is for root memcg:

	nr(MEM_CGROUP_STAT_CACHE) = global_page_state(NR_FILE_PAGES) -
                              sum_of_all_memcg(MEM_CGROUP_STAT_CACHE);

Rss pages accounting are in the similar way.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 mm/memcontrol.c |   50 ++++++++++++++++++++++++++++++++++----------------
 1 file changed, 34 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 735cd41..e89204f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -958,26 +958,27 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 {
 	preempt_disable();
 
-	/*
-	 * Here, RSS means 'mapped anon' and anon's SwapCache. Shmem/tmpfs is
-	 * counted as CACHE even if it's on ANON LRU.
-	 */
-	if (anon)
-		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS],
-				nr_pages);
-	else
-		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
-				nr_pages);
-
 	/* pagein of a big page is an event. So, ignore page size */
 	if (nr_pages > 0)
 		__this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGIN]);
-	else {
+	else
 		__this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT]);
-		nr_pages = -nr_pages; /* for event */
-	}
 
-	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
+	__this_cpu_add(memcg->stat->nr_page_events,
+					nr_pages < 0 ? -nr_pages : nr_pages);
+
+	if (!mem_cgroup_is_root(memcg)) {
+		/*
+		 * Here, RSS means 'mapped anon' and anon's SwapCache. Shmem/tmpfs is
+		 * counted as CACHE even if it's on ANON LRU.
+		 */
+		if (anon)
+			__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS],
+					nr_pages);
+		else
+			__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
+					nr_pages);
+	}
 
 	preempt_enable();
 }
@@ -5445,12 +5446,24 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	struct mem_cgroup *mi;
 	unsigned int i;
+	enum zone_stat_item global_stat[] = {NR_FILE_PAGES, NR_ANON_PAGES};
+	long root_stat[MEM_CGROUP_STAT_NSTATS] = {0};
 
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
+		long val = 0;
+
 		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
 			continue;
+
+		if (mem_cgroup_is_root(memcg) && (i == MEM_CGROUP_STAT_CACHE
+					|| i == MEM_CGROUP_STAT_RSS)) {
+			val = global_page_state(global_stat[i]) -
+				mem_cgroup_recursive_stat(memcg, i);
+			root_stat[i] = val = val < 0 ? 0 : val;
+		} else
+			val = mem_cgroup_read_stat(memcg, i);
 		seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
-			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
+					val * PAGE_SIZE);
 	}
 
 	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
@@ -5478,6 +5491,11 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 			continue;
 		for_each_mem_cgroup_tree(mi, memcg)
 			val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
+
+		/* Adding local stats of root memcg */
+		if (mem_cgroup_is_root(memcg))
+			val += root_stat[i] * PAGE_SIZE;
+
 		seq_printf(m, "total_%s %lld\n", mem_cgroup_stat_names[i], val);
 	}
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
