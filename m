Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 217276B003B
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 15:55:04 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id a1so6018374wgh.0
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:55:03 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id w12si2529087wie.37.2014.06.16.12.55.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 12:55:02 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 01/12] mm: memcontrol: fold mem_cgroup_do_charge()
Date: Mon, 16 Jun 2014 15:54:21 -0400
Message-Id: <1402948472-8175-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This function was split out because mem_cgroup_try_charge() got too
big.  But having essentially one sequence of operations arbitrarily
split in half is not good for reworking the code.  Fold it back in.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 166 ++++++++++++++++++++++----------------------------------
 1 file changed, 64 insertions(+), 102 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a2c7bcb0e6eb..94531df14d37 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2551,80 +2551,6 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
 	return NOTIFY_OK;
 }
 
-
-/* See mem_cgroup_try_charge() for details */
-enum {
-	CHARGE_OK,		/* success */
-	CHARGE_RETRY,		/* need to retry but retry is not bad */
-	CHARGE_NOMEM,		/* we can't do more. return -ENOMEM */
-	CHARGE_WOULDBLOCK,	/* GFP_WAIT wasn't set and no enough res. */
-};
-
-static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
-				unsigned int nr_pages, unsigned int min_pages,
-				bool invoke_oom)
-{
-	unsigned long csize = nr_pages * PAGE_SIZE;
-	struct mem_cgroup *mem_over_limit;
-	struct res_counter *fail_res;
-	unsigned long flags = 0;
-	int ret;
-
-	ret = res_counter_charge(&memcg->res, csize, &fail_res);
-
-	if (likely(!ret)) {
-		if (!do_swap_account)
-			return CHARGE_OK;
-		ret = res_counter_charge(&memcg->memsw, csize, &fail_res);
-		if (likely(!ret))
-			return CHARGE_OK;
-
-		res_counter_uncharge(&memcg->res, csize);
-		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
-		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
-	} else
-		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
-	/*
-	 * Never reclaim on behalf of optional batching, retry with a
-	 * single page instead.
-	 */
-	if (nr_pages > min_pages)
-		return CHARGE_RETRY;
-
-	if (!(gfp_mask & __GFP_WAIT))
-		return CHARGE_WOULDBLOCK;
-
-	if (gfp_mask & __GFP_NORETRY)
-		return CHARGE_NOMEM;
-
-	ret = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
-	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
-		return CHARGE_RETRY;
-	/*
-	 * Even though the limit is exceeded at this point, reclaim
-	 * may have been able to free some pages.  Retry the charge
-	 * before killing the task.
-	 *
-	 * Only for regular pages, though: huge pages are rather
-	 * unlikely to succeed so close to the limit, and we fall back
-	 * to regular pages anyway in case of failure.
-	 */
-	if (nr_pages <= (1 << PAGE_ALLOC_COSTLY_ORDER) && ret)
-		return CHARGE_RETRY;
-
-	/*
-	 * At task move, charge accounts can be doubly counted. So, it's
-	 * better to wait until the end of task_move if something is going on.
-	 */
-	if (mem_cgroup_wait_acct_move(mem_over_limit))
-		return CHARGE_RETRY;
-
-	if (invoke_oom)
-		mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(csize));
-
-	return CHARGE_NOMEM;
-}
-
 /**
  * mem_cgroup_try_charge - try charging a memcg
  * @memcg: memcg to charge
@@ -2641,7 +2567,11 @@ static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
 {
 	unsigned int batch = max(CHARGE_BATCH, nr_pages);
 	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	int ret;
+	struct mem_cgroup *mem_over_limit;
+	struct res_counter *fail_res;
+	unsigned long nr_reclaimed;
+	unsigned long flags = 0;
+	unsigned long long size;
 
 	if (mem_cgroup_is_root(memcg))
 		goto done;
@@ -2661,44 +2591,76 @@ static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
 
 	if (gfp_mask & __GFP_NOFAIL)
 		oom = false;
-again:
+retry:
 	if (consume_stock(memcg, nr_pages))
 		goto done;
 
-	do {
-		bool invoke_oom = oom && !nr_oom_retries;
+	size = batch * PAGE_SIZE;
+	if (!res_counter_charge(&memcg->res, size, &fail_res)) {
+		if (!do_swap_account)
+			goto done_restock;
+		if (!res_counter_charge(&memcg->memsw, size, &fail_res))
+			goto done_restock;
+		res_counter_uncharge(&memcg->res, size);
+		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
+		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
+	} else
+		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
 
-		/* If killed, bypass charge */
-		if (fatal_signal_pending(current))
-			goto bypass;
+	if (batch > nr_pages) {
+		batch = nr_pages;
+		goto retry;
+	}
 
-		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch,
-					   nr_pages, invoke_oom);
-		switch (ret) {
-		case CHARGE_OK:
-			break;
-		case CHARGE_RETRY: /* not in OOM situation but retry */
-			batch = nr_pages;
-			goto again;
-		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
-			goto nomem;
-		case CHARGE_NOMEM: /* OOM routine works */
-			if (!oom || invoke_oom)
-				goto nomem;
-			nr_oom_retries--;
-			break;
-		}
-	} while (ret != CHARGE_OK);
+	if (!(gfp_mask & __GFP_WAIT))
+		goto nomem;
 
-	if (batch > nr_pages)
-		refill_stock(memcg, batch - nr_pages);
-done:
-	return 0;
+	if (gfp_mask & __GFP_NORETRY)
+		goto nomem;
+
+	nr_reclaimed = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
+
+	if (mem_cgroup_margin(mem_over_limit) >= batch)
+		goto retry;
+	/*
+	 * Even though the limit is exceeded at this point, reclaim
+	 * may have been able to free some pages.  Retry the charge
+	 * before killing the task.
+	 *
+	 * Only for regular pages, though: huge pages are rather
+	 * unlikely to succeed so close to the limit, and we fall back
+	 * to regular pages anyway in case of failure.
+	 */
+	if (nr_reclaimed && batch <= (1 << PAGE_ALLOC_COSTLY_ORDER))
+		goto retry;
+	/*
+	 * At task move, charge accounts can be doubly counted. So, it's
+	 * better to wait until the end of task_move if something is going on.
+	 */
+	if (mem_cgroup_wait_acct_move(mem_over_limit))
+		goto retry;
+
+	if (fatal_signal_pending(current))
+		goto bypass;
+
+	if (!oom)
+		goto nomem;
+
+	if (nr_oom_retries--)
+		goto retry;
+
+	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(batch));
 nomem:
 	if (!(gfp_mask & __GFP_NOFAIL))
 		return -ENOMEM;
 bypass:
 	return -EINTR;
+
+done_restock:
+	if (batch > nr_pages)
+		refill_stock(memcg, batch - nr_pages);
+done:
+	return 0;
 }
 
 /**
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
