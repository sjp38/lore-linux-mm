Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DF9686B00E7
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 05:46:39 -0400 (EDT)
Message-Id: <0ed59a22cc84037d6e42b258981c75e3a6063899.1311241300.git.mhocko@suse.cz>
In-Reply-To: <cover.1311241300.git.mhocko@suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Thu, 21 Jul 2011 10:28:10 +0200
Subject: [PATCH 4/4] memcg: prevent from reclaiming if there are per-cpu
 cached charges
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

If we fail to charge an allocation for a cgroup we usually have to fall
back into direct reclaim (mem_cgroup_hierarchical_reclaim).
The charging code, however, currently doesn't care about per-cpu charge
caches which might have up to (nr_cpus - 1) * CHARGE_BATCH pre charged
pages (the current cache is already drained, otherwise we wouldn't get
to mem_cgroup_do_charge).
That can be quite a lot on boxes with big amounts of CPUs so we can end
up reclaiming even though there are charges that could be used. This
will typically happen in a multi-threaded applications pined to many CPUs
which allocates memory heavily.

Currently we are draining caches during reclaim
(mem_cgroup_hierarchical_reclaim) but this can be already late as we
could have already reclaimed from other groups in the hierarchy.

The solution for this would be to synchronously drain charges early when
we fail to charge and retry the charge once more.
I think it still makes sense to keep async draining in the reclaim path
as it is used from other code paths as well (e.g. limit resize). It will
not do any work if we drained previously anyway.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9d49a12..59bcb01 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2265,11 +2265,12 @@ static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 				unsigned int nr_pages, bool oom_check)
 {
 	unsigned long csize = nr_pages * PAGE_SIZE;
-	struct mem_cgroup *mem_over_limit;
+	struct mem_cgroup *mem_over_limit, *drained = NULL;
 	struct res_counter *fail_res;
 	unsigned long flags = 0;
 	int ret;
 
+retry:
 	ret = res_counter_charge(&mem->res, csize, &fail_res);
 
 	if (likely(!ret)) {
@@ -2282,8 +2283,14 @@ static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 		res_counter_uncharge(&mem->res, csize);
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
 		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
-	} else
+	} else {
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
+		if (!drained) {
+			drained = mem_over_limit;
+			drain_all_stock_sync(drained);
+			goto retry;
+		}
+	}
 	/*
 	 * nr_pages can be either a huge page (HPAGE_PMD_NR), a batch
 	 * of regular pages (CHARGE_BATCH), or a single regular page (1).
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
