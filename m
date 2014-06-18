Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5796B004D
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:41:11 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id y10so1405313wgg.5
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:41:11 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id qg4si4150602wic.57.2014.06.18.13.41.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 13:41:09 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 09/13] mm: memcontrol: use root_mem_cgroup res_counter
Date: Wed, 18 Jun 2014 16:40:41 -0400
Message-Id: <1403124045-24361-10-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Due to an old optimization to keep expensive res_counter changes at a
minimum, the root_mem_cgroup res_counter is never charged; there is no
limit at that level anyway, and any statistics can be generated on
demand by summing up the counters of all other cgroups.

However, with per-cpu charge caches, res_counter operations do not
even show up in profiles anymore, so this optimization is no longer
necessary.

Remove it to simplify the code.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c | 152 ++++++++++++++++----------------------------------------
 1 file changed, 44 insertions(+), 108 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b6b5f7f98618..d2b8429002c0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2570,9 +2570,8 @@ static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
 	unsigned long nr_reclaimed;
 	unsigned long flags = 0;
 	unsigned long long size;
+	int ret = 0;
 
-	if (mem_cgroup_is_root(memcg))
-		goto done;
 retry:
 	if (consume_stock(memcg, nr_pages))
 		goto done;
@@ -2650,13 +2649,15 @@ nomem:
 	if (!(gfp_mask & __GFP_NOFAIL))
 		return -ENOMEM;
 bypass:
-	return -EINTR;
+	memcg = root_mem_cgroup;
+	ret = -EINTR;
+	goto retry;
 
 done_restock:
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
 done:
-	return 0;
+	return ret;
 }
 
 /**
@@ -2695,13 +2696,11 @@ static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
 static void __mem_cgroup_cancel_charge(struct mem_cgroup *memcg,
 				       unsigned int nr_pages)
 {
-	if (!mem_cgroup_is_root(memcg)) {
-		unsigned long bytes = nr_pages * PAGE_SIZE;
+	unsigned long bytes = nr_pages * PAGE_SIZE;
 
-		res_counter_uncharge(&memcg->res, bytes);
-		if (do_swap_account)
-			res_counter_uncharge(&memcg->memsw, bytes);
-	}
+	res_counter_uncharge(&memcg->res, bytes);
+	if (do_swap_account)
+		res_counter_uncharge(&memcg->memsw, bytes);
 }
 
 /*
@@ -2713,9 +2712,6 @@ static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
 {
 	unsigned long bytes = nr_pages * PAGE_SIZE;
 
-	if (mem_cgroup_is_root(memcg))
-		return;
-
 	res_counter_uncharge_until(&memcg->res, memcg->res.parent, bytes);
 	if (do_swap_account)
 		res_counter_uncharge_until(&memcg->memsw,
@@ -3943,7 +3939,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
 	 * replacement page, so leave it alone when phasing out the
 	 * page that is unused after the migration.
 	 */
-	if (!end_migration && !mem_cgroup_is_root(memcg))
+	if (!end_migration)
 		mem_cgroup_do_uncharge(memcg, nr_pages, ctype);
 
 	return memcg;
@@ -4076,8 +4072,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
 		 * We uncharge this because swap is freed.  This memcg can
 		 * be obsolete one. We avoid calling css_tryget_online().
 		 */
-		if (!mem_cgroup_is_root(memcg))
-			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 		mem_cgroup_swap_statistics(memcg, false);
 		css_put(&memcg->css);
 	}
@@ -4767,78 +4762,24 @@ out:
 	return retval;
 }
 
-
-static unsigned long mem_cgroup_recursive_stat(struct mem_cgroup *memcg,
-					       enum mem_cgroup_stat_index idx)
-{
-	struct mem_cgroup *iter;
-	long val = 0;
-
-	/* Per-cpu values can be negative, use a signed accumulator */
-	for_each_mem_cgroup_tree(iter, memcg)
-		val += mem_cgroup_read_stat(iter, idx);
-
-	if (val < 0) /* race ? */
-		val = 0;
-	return val;
-}
-
-static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
-{
-	u64 val;
-
-	if (!mem_cgroup_is_root(memcg)) {
-		if (!swap)
-			return res_counter_read_u64(&memcg->res, RES_USAGE);
-		else
-			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
-	}
-
-	/*
-	 * Transparent hugepages are still accounted for in MEM_CGROUP_STAT_RSS
-	 * as well as in MEM_CGROUP_STAT_RSS_HUGE.
-	 */
-	val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
-	val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
-
-	if (swap)
-		val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_SWAP);
-
-	return val << PAGE_SHIFT;
-}
-
 static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
-				   struct cftype *cft)
+			       struct cftype *cft)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
-	u64 val;
-	int name;
-	enum res_type type;
-
-	type = MEMFILE_TYPE(cft->private);
-	name = MEMFILE_ATTR(cft->private);
+	enum res_type type = MEMFILE_TYPE(cft->private);
+	int name = MEMFILE_ATTR(cft->private);
 
 	switch (type) {
 	case _MEM:
-		if (name == RES_USAGE)
-			val = mem_cgroup_usage(memcg, false);
-		else
-			val = res_counter_read_u64(&memcg->res, name);
-		break;
+		return res_counter_read_u64(&memcg->res, name);
 	case _MEMSWAP:
-		if (name == RES_USAGE)
-			val = mem_cgroup_usage(memcg, true);
-		else
-			val = res_counter_read_u64(&memcg->memsw, name);
-		break;
+		return res_counter_read_u64(&memcg->memsw, name);
 	case _KMEM:
-		val = res_counter_read_u64(&memcg->kmem, name);
+		return res_counter_read_u64(&memcg->kmem, name);
 		break;
 	default:
 		BUG();
 	}
-
-	return val;
 }
 
 #ifdef CONFIG_MEMCG_KMEM
@@ -5300,7 +5241,10 @@ static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 	if (!t)
 		goto unlock;
 
-	usage = mem_cgroup_usage(memcg, swap);
+	if (!swap)
+		usage = res_counter_read_u64(&memcg->res, RES_USAGE);
+	else
+		usage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 
 	/*
 	 * current_threshold points to threshold just below or equal to usage.
@@ -5392,15 +5336,15 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
 
 	mutex_lock(&memcg->thresholds_lock);
 
-	if (type == _MEM)
+	if (type == _MEM) {
 		thresholds = &memcg->thresholds;
-	else if (type == _MEMSWAP)
+		usage = res_counter_read_u64(&memcg->res, RES_USAGE);
+	} else if (type == _MEMSWAP) {
 		thresholds = &memcg->memsw_thresholds;
-	else
+		usage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
+	} else
 		BUG();
 
-	usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
-
 	/* Check if a threshold crossed before adding a new one */
 	if (thresholds->primary)
 		__mem_cgroup_threshold(memcg, type == _MEMSWAP);
@@ -5480,18 +5424,19 @@ static void __mem_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
 	int i, j, size;
 
 	mutex_lock(&memcg->thresholds_lock);
-	if (type == _MEM)
+
+	if (type == _MEM) {
 		thresholds = &memcg->thresholds;
-	else if (type == _MEMSWAP)
+		usage = res_counter_read_u64(&memcg->res, RES_USAGE);
+	} else if (type == _MEMSWAP) {
 		thresholds = &memcg->memsw_thresholds;
-	else
+		usage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
+	} else
 		BUG();
 
 	if (!thresholds->primary)
 		goto unlock;
 
-	usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
-
 	/* Check if a threshold crossed before removing */
 	__mem_cgroup_threshold(memcg, type == _MEMSWAP);
 
@@ -6246,9 +6191,9 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		 * core guarantees its existence.
 		 */
 	} else {
-		res_counter_init(&memcg->res, NULL);
-		res_counter_init(&memcg->memsw, NULL);
-		res_counter_init(&memcg->kmem, NULL);
+		res_counter_init(&memcg->res, &root_mem_cgroup->res);
+		res_counter_init(&memcg->memsw, &root_mem_cgroup->memsw);
+		res_counter_init(&memcg->kmem, &root_mem_cgroup->kmem);
 		/*
 		 * Deeper hierachy with use_hierarchy == false doesn't make
 		 * much sense so let cgroup subsystem know about this
@@ -6361,13 +6306,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 /* Handlers for move charge at task migration. */
 static int mem_cgroup_do_precharge(unsigned long count)
 {
-	int ret = 0;
-
-	if (mem_cgroup_is_root(mc.to)) {
-		mc.precharge += count;
-		/* we don't need css_get for root */
-		return ret;
-	}
+	int ret;
 
 	/* Try a single bulk charge without reclaim first */
 	ret = mem_cgroup_try_charge(mc.to, GFP_KERNEL & ~__GFP_WAIT, count);
@@ -6674,21 +6613,18 @@ static void __mem_cgroup_clear_mc(void)
 	/* we must fixup refcnts and charges */
 	if (mc.moved_swap) {
 		/* uncharge swap account from the old cgroup */
-		if (!mem_cgroup_is_root(mc.from))
-			res_counter_uncharge(&mc.from->memsw,
-						PAGE_SIZE * mc.moved_swap);
+		res_counter_uncharge(&mc.from->memsw,
+				     PAGE_SIZE * mc.moved_swap);
 
 		for (i = 0; i < mc.moved_swap; i++)
 			css_put(&mc.from->css);
 
-		if (!mem_cgroup_is_root(mc.to)) {
-			/*
-			 * we charged both to->res and to->memsw, so we should
-			 * uncharge to->res.
-			 */
-			res_counter_uncharge(&mc.to->res,
-						PAGE_SIZE * mc.moved_swap);
-		}
+		/*
+		 * we charged both to->res and to->memsw, so we should
+		 * uncharge to->res.
+		 */
+		res_counter_uncharge(&mc.to->res,
+				     PAGE_SIZE * mc.moved_swap);
 		/* we've already done css_get(mc.to) */
 		mc.moved_swap = 0;
 	}
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
