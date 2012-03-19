Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id DFFB56B00F5
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 04:05:31 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 25ACB3EE0CB
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 17:05:30 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D7F545DD74
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 17:05:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E16AE45DE58
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 17:05:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CF5AD1DB802C
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 17:05:29 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5010B1DB803C
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 17:05:29 +0900 (JST)
Message-ID: <4F66E85E.6030000@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 17:03:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 3/3] memcg: atomic update of memcg pointer and other
 bits.
References: <4F66E6A5.10804@jp.fujitsu.com>
In-Reply-To: <4F66E6A5.10804@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, suleiman@google.com, n-horiguchi@ah.jp.nec.com, khlebnikov@openvz.org, Tejun Heo <tj@kernel.org>

Because a pointer to memcg and flags are in the same word,
it can be updated at the same time. Then, we can remove
memory barrier which was used for fixing races.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |    4 ++--
 mm/memcontrol.c             |   22 ++++------------------
 2 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index bca5447..e05f157 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -97,9 +97,9 @@ static inline struct mem_cgroup* pc_to_mem_cgroup(struct page_cgroup *pc)
 }
 
 static inline void
-pc_set_mem_cgroup(struct page_cgroup *pc, struct mem_cgroup *memcg)
+pc_set_mem_cgroup(struct page_cgroup *pc,
+		struct mem_cgroup *memcg, unsigned long bits)
 {
-	unsigned long bits = pc->flags & PCG_FLAGS_MASK;
 	pc->flags = (unsigned long)memcg | bits;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 124fec9..603a476 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1060,7 +1060,7 @@ struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
 	 * of pc's mem_cgroup safe.
 	 */
 	if (!PageCgroupUsed(pc) && memcg != root_mem_cgroup) {
-		pc_set_mem_cgroup(pc, root_mem_cgroup);
+		pc_set_mem_cgroup(pc, root_mem_cgroup, 0);
 		memcg = root_mem_cgroup;
 	}
 
@@ -1237,8 +1237,6 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	pc = lookup_page_cgroup(page);
 	if (!PageCgroupUsed(pc))
 		return NULL;
-	/* Ensure pc's mem_cgroup is visible after reading PCG_USED. */
-	smp_rmb();
 	mz = page_cgroup_zoneinfo(pc_to_mem_cgroup(pc), page);
 	return &mz->reclaim_stat;
 }
@@ -2491,16 +2489,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 		}
 	}
 
-	pc_set_mem_cgroup(pc, memcg);
-	/*
-	 * We access a page_cgroup asynchronously without lock_page_cgroup().
-	 * Especially when a page_cgroup is taken from a page, pc's mem_cgroup
-	 * is accessed after testing USED bit. To make pc's mem_cgroup visible
-	 * before USED bit, we need memory barrier here.
-	 * See mem_cgroup_add_lru_list(), etc.
- 	 */
-	smp_wmb();
-	SetPageCgroupUsed(pc);
+	pc_set_mem_cgroup(pc, memcg, BIT(PCG_USED) | BIT(PCG_LOCK));
 
 	if (lrucare) {
 		if (was_on_lru) {
@@ -2529,7 +2518,6 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
-#define PCGF_NOCOPY_AT_SPLIT ((1 << PCG_LOCK) | (1 << PCG_MIGRATION))
 /*
  * Because tail pages are not marked as "used", set it. We're under
  * zone->lru_lock, 'splitting on pmd' and compound_lock.
@@ -2547,9 +2535,7 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 		return;
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		pc = head_pc + i;
-		pc_set_mem_cgroup(pc, memcg);
-		smp_wmb();/* see __commit_charge() */
-		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
+		pc_set_mem_cgroup(pc, memcg, BIT(PCG_USED));
 	}
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
@@ -2616,7 +2602,7 @@ static int mem_cgroup_move_account(struct page *page,
 		__mem_cgroup_cancel_charge(from, nr_pages);
 
 	/* caller should have done css_get */
-	pc_set_mem_cgroup(pc, to);
+	pc_set_mem_cgroup(pc, to, BIT(PCG_USED) | BIT(PCG_LOCK));
 	mem_cgroup_charge_statistics(to, anon, nr_pages);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
