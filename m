Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id B5C326B005C
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 06:41:09 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CC7153EE0BC
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 19:41:07 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AF93845DE56
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 19:41:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 37B3345DE4E
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 19:41:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 28E7F1DB8046
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 19:41:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CEEA91DB8042
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 19:41:06 +0900 (JST)
Message-ID: <4FC89BC4.9030604@jp.fujitsu.com>
Date: Fri, 01 Jun 2012 19:39:00 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] rename MEM_CGROUP_STAT_SWAPOUT as MEM_CGROUP_STAT_NR_SWAP
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org

MEM_CGROUP_STAT_SWAPOUT represents the usage of swap rather than
the number of swap-out events. Rename it to be MEM_CGROUP_STAT_NR_SWAP.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0121ef3..76bc54c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -97,7 +97,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
 	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
-	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
+	MEM_CGROUP_STAT_NR_SWAP, /* # of pages, swapped out */
 	MEM_CGROUP_STAT_NSTATS,
 };
 
@@ -722,7 +722,7 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
 					 bool charge)
 {
 	int val = (charge) ? 1 : -1;
-	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
+	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_NR_SWAP], val);
 }
 
 static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
@@ -4042,7 +4042,7 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 	val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
 
 	if (swap)
-		val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_SWAPOUT);
+		val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_NR_SWAP);
 
 	return val << PAGE_SHIFT;
 }
@@ -4303,7 +4303,7 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 	unsigned int i;
 
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
-		if (i == MEM_CGROUP_STAT_SWAPOUT && !do_swap_account)
+		if (i == MEM_CGROUP_STAT_NR_SWAP && !do_swap_account)
 			continue;
 		seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
 			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
@@ -4330,7 +4330,7 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
 		long long val = 0;
 
-		if (i == MEM_CGROUP_STAT_SWAPOUT && !do_swap_account)
+		if (i == MEM_CGROUP_STAT_NR_SWAP && !do_swap_account)
 			continue;
 		for_each_mem_cgroup_tree(mi, memcg)
 			val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
