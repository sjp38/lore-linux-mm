Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 142D66B006C
	for <linux-mm@kvack.org>; Sun, 28 Dec 2014 11:19:32 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id fp1so15666310pdb.19
        for <linux-mm@kvack.org>; Sun, 28 Dec 2014 08:19:31 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id w3si21616893pdl.196.2014.12.28.08.19.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Dec 2014 08:19:28 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [RFC PATCH 1/2] memcg: account swap instead of memory+swap
Date: Sun, 28 Dec 2014 19:19:12 +0300
Message-ID: <dd99dc0de2ce6fd9aa18b25851819b71a58dca7d.1419782051.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

The design of swap limits for memory cgroups looks broken. Instead of a
separate swap limit, there is the memory.memsw.limit_in_bytes knob,
which limits total memory+swap consumption. As a result, under global
memory pressure, a cgroup can eat up to memsw.limit of *swap*, so it's
just impossible to set the swap limit to be less than the memory limit
with such a design. In particular, this means that we have to leave swap
unlimited if we want to partition system memory dynamically using soft
limits.

This patch therefore attempts to move from memory+swap to pure swap
accounting so that we will be able to separate memory and swap resources
in the sane cgroup hierarchy, which is the business of the following
patch.

The old interface acts on memory and swap limits as follows:

 - Apart from changing the memory limit, increasing/decreasing the value
   of memory.limit_in_bytes results in decreasing/increasing the swap
   limit by the same amount.

 - Increasing/decreasing the value of memory.memsw.limit_in_bytes
   results in increasing/decreasing of the swap limit by the same
   amount.

Known issues:

 - No attempt to unuse swap entries is made on diminishing the swap
   limit. As a result, increasing the value of memory.limit_in_bytes may
   fail, which is not possible with the old accounting design. Also,
   decreasing the value of memory.memsw.limit_in_bytes may fail even if
   memory.memsw.usage_in_bytes is less than the new limit.

 - With this patch mem_cgroup_do_precharge(), which is called to
   precharge the destination cgroup before migrating a task, charges
   both memory and swap for each page table entry. Hence, migration of a
   task to a cgroup with memory.move_charge_at_immigrate set may fail
   where it would work with the old accounting design. Will anyone care
   provided moving charges is disabled by default and going to be
   deprecated in the sane hierarchy? Anyway, this issue shouldn't be
   hard to fix.

 - On global reclaim anonymous lru lists of cgroups with no swap quota
   left are still scanned although it isn't possible to reclaim anything
   from them. This should be easy to fix though - we only have to make
   get_scan_count() set scan_balance to SCAN_FILE for such cgroups (make
   mem_cgroup_swappiness() return 0 if the swap limit is reached?)

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/swap.h |    5 +-
 mm/memcontrol.c      |  379 ++++++++++++++++++++++++++------------------------
 mm/page_counter.c    |    8 ++
 mm/shmem.c           |    4 +
 mm/swap_state.c      |    5 +
 mm/vmscan.c          |    1 -
 6 files changed, 218 insertions(+), 184 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 34e8b60ab973..c944d771809c 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -359,11 +359,12 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
 }
 #endif
 #ifdef CONFIG_MEMCG_SWAP
-extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
+extern int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry);
 extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
 #else
-static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
+static inline int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry)
 {
+	return 0;
 }
 static inline void mem_cgroup_uncharge_swap(swp_entry_t entry)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ef91e856c7e4..6b5eaa399b23 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -281,7 +281,7 @@ struct mem_cgroup {
 
 	/* Accounted resources */
 	struct page_counter memory;
-	struct page_counter memsw;
+	struct page_counter swap;
 	struct page_counter kmem;
 
 	unsigned long soft_limit;
@@ -445,6 +445,9 @@ enum res_type {
  */
 static DEFINE_MUTEX(memcg_create_mutex);
 
+/* Protects cgroup limits. */
+static DEFINE_MUTEX(memcg_limit_mutex);
+
 struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
 {
 	return s ? container_of(s, struct mem_cgroup, css) : NULL;
@@ -1389,13 +1392,6 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 	if (count < limit)
 		margin = limit - count;
 
-	if (do_swap_account) {
-		count = page_counter_read(&memcg->memsw);
-		limit = ACCESS_ONCE(memcg->memsw.limit);
-		if (count <= limit)
-			margin = min(margin, limit - count);
-	}
-
 	return margin;
 }
 
@@ -1486,9 +1482,9 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	pr_info("memory: usage %llukB, limit %llukB, failcnt %lu\n",
 		K((u64)page_counter_read(&memcg->memory)),
 		K((u64)memcg->memory.limit), memcg->memory.failcnt);
-	pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %lu\n",
-		K((u64)page_counter_read(&memcg->memsw)),
-		K((u64)memcg->memsw.limit), memcg->memsw.failcnt);
+	pr_info("swap: usage %llukB, limit %llukB, failcnt %lu\n",
+		K((u64)page_counter_read(&memcg->swap)),
+		K((u64)memcg->swap.limit), memcg->swap.failcnt);
 	pr_info("kmem: usage %llukB, limit %llukB, failcnt %lu\n",
 		K((u64)page_counter_read(&memcg->kmem)),
 		K((u64)memcg->kmem.limit), memcg->kmem.failcnt);
@@ -1537,10 +1533,12 @@ static unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
 
 	limit = memcg->memory.limit;
 	if (mem_cgroup_swappiness(memcg)) {
-		unsigned long memsw_limit;
+		unsigned long swap_limit;
 
-		memsw_limit = memcg->memsw.limit;
-		limit = min(limit + total_swap_pages, memsw_limit);
+		swap_limit = ACCESS_ONCE(memcg->swap.limit);
+		if (swap_limit > total_swap_pages)
+			swap_limit = total_swap_pages;
+		limit += swap_limit;
 	}
 	return limit;
 }
@@ -2115,8 +2113,6 @@ static void drain_stock(struct memcg_stock_pcp *stock)
 
 	if (stock->nr_pages) {
 		page_counter_uncharge(&old->memory, stock->nr_pages);
-		if (do_swap_account)
-			page_counter_uncharge(&old->memsw, stock->nr_pages);
 		css_put_many(&old->css, stock->nr_pages);
 		stock->nr_pages = 0;
 	}
@@ -2250,7 +2246,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	struct mem_cgroup *mem_over_limit;
 	struct page_counter *counter;
 	unsigned long nr_reclaimed;
-	bool may_swap = true;
 	bool drained = false;
 	int ret = 0;
 
@@ -2260,17 +2255,9 @@ retry:
 	if (consume_stock(memcg, nr_pages))
 		goto done;
 
-	if (!do_swap_account ||
-	    !page_counter_try_charge(&memcg->memsw, batch, &counter)) {
-		if (!page_counter_try_charge(&memcg->memory, batch, &counter))
-			goto done_restock;
-		if (do_swap_account)
-			page_counter_uncharge(&memcg->memsw, batch);
-		mem_over_limit = mem_cgroup_from_counter(counter, memory);
-	} else {
-		mem_over_limit = mem_cgroup_from_counter(counter, memsw);
-		may_swap = false;
-	}
+	if (!page_counter_try_charge(&memcg->memory, batch, &counter))
+		goto done_restock;
+	mem_over_limit = mem_cgroup_from_counter(counter, memory);
 
 	if (batch > nr_pages) {
 		batch = nr_pages;
@@ -2295,7 +2282,7 @@ retry:
 		goto nomem;
 
 	nr_reclaimed = try_to_free_mem_cgroup_pages(mem_over_limit, nr_pages,
-						    gfp_mask, may_swap);
+						    gfp_mask, true);
 
 	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
 		goto retry;
@@ -2356,9 +2343,29 @@ static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
 		return;
 
 	page_counter_uncharge(&memcg->memory, nr_pages);
-	if (do_swap_account)
-		page_counter_uncharge(&memcg->memsw, nr_pages);
+	css_put_many(&memcg->css, nr_pages);
+}
+
+static int try_charge_swap(struct mem_cgroup *memcg, unsigned int nr_pages)
+{
+	struct page_counter *counter;
+
+	if (mem_cgroup_is_root(memcg))
+		return 0;
+
+	if (page_counter_try_charge(&memcg->swap, nr_pages, &counter))
+		return -ENOMEM;
 
+	css_get_many(&memcg->css, nr_pages);
+	return 0;
+}
+
+static void cancel_charge_swap(struct mem_cgroup *memcg, unsigned int nr_pages)
+{
+	if (mem_cgroup_is_root(memcg))
+		return;
+
+	page_counter_uncharge(&memcg->swap, nr_pages);
 	css_put_many(&memcg->css, nr_pages);
 }
 
@@ -2523,8 +2530,6 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
 		 * directed to the root cgroup in memcontrol.h
 		 */
 		page_counter_charge(&memcg->memory, nr_pages);
-		if (do_swap_account)
-			page_counter_charge(&memcg->memsw, nr_pages);
 		css_get_many(&memcg->css, nr_pages);
 		ret = 0;
 	} else if (ret)
@@ -2537,11 +2542,7 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg,
 				unsigned long nr_pages)
 {
 	page_counter_uncharge(&memcg->memory, nr_pages);
-	if (do_swap_account)
-		page_counter_uncharge(&memcg->memsw, nr_pages);
-
 	page_counter_uncharge(&memcg->kmem, nr_pages);
-
 	css_put_many(&memcg->css, nr_pages);
 }
 
@@ -3029,8 +3030,7 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
  *
  * Returns 0 on success, -EINVAL on failure.
  *
- * The caller must have charged to @to, IOW, called page_counter_charge() about
- * both res and memsw, and called css_get().
+ * The caller must have called try_charge_swap() on @to.
  */
 static int mem_cgroup_move_swap_account(swp_entry_t entry,
 				struct mem_cgroup *from, struct mem_cgroup *to)
@@ -3043,18 +3043,6 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
 	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
 		mem_cgroup_swap_statistics(from, false);
 		mem_cgroup_swap_statistics(to, true);
-		/*
-		 * This function is only called from task migration context now.
-		 * It postpones page_counter and refcount handling till the end
-		 * of task migration(mem_cgroup_clear_mc()) for performance
-		 * improvement. But we cannot postpone css_get(to)  because if
-		 * the process that has been moved to @to does swap-in, the
-		 * refcount of @to might be decreased to 0.
-		 *
-		 * We are in attach() phase, so the cgroup is guaranteed to be
-		 * alive, so we can just call css_get().
-		 */
-		css_get(&to->css);
 		return 0;
 	}
 	return -EINVAL;
@@ -3067,10 +3055,7 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 }
 #endif
 
-static DEFINE_MUTEX(memcg_limit_mutex);
-
-static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
-				   unsigned long limit)
+static int resize_memory_limit(struct mem_cgroup *memcg, unsigned long limit)
 {
 	unsigned long curusage;
 	unsigned long oldusage;
@@ -3078,6 +3063,9 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 	int retry_count;
 	int ret;
 
+	if (limit > memcg->memory.limit)
+		enlarge = true;
+
 	/*
 	 * For keeping hierarchical_reclaim simple, how long we should retry
 	 * is depends on callers. We set our retry-count to be function
@@ -3089,25 +3077,14 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 	oldusage = page_counter_read(&memcg->memory);
 
 	do {
+		ret = page_counter_limit(&memcg->memory, limit);
+		if (!ret)
+			break;
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			break;
 		}
 
-		mutex_lock(&memcg_limit_mutex);
-		if (limit > memcg->memsw.limit) {
-			mutex_unlock(&memcg_limit_mutex);
-			ret = -EINVAL;
-			break;
-		}
-		if (limit > memcg->memory.limit)
-			enlarge = true;
-		ret = page_counter_limit(&memcg->memory, limit);
-		mutex_unlock(&memcg_limit_mutex);
-
-		if (!ret)
-			break;
-
 		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, true);
 
 		curusage = page_counter_read(&memcg->memory);
@@ -3124,55 +3101,65 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 	return ret;
 }
 
-static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
-					 unsigned long limit)
+static int resize_swap_limit(struct mem_cgroup *memcg, unsigned long limit)
 {
-	unsigned long curusage;
-	unsigned long oldusage;
 	bool enlarge = false;
-	int retry_count;
 	int ret;
 
-	/* see mem_cgroup_resize_res_limit */
-	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
-		      mem_cgroup_count_children(memcg);
+	if (limit > memcg->swap.limit)
+		enlarge = true;
 
-	oldusage = page_counter_read(&memcg->memsw);
+	ret = page_counter_limit(&memcg->swap, limit);
 
-	do {
-		if (signal_pending(current)) {
-			ret = -EINTR;
-			break;
-		}
+	if (!ret && enlarge)
+		memcg_oom_recover(memcg);
 
-		mutex_lock(&memcg_limit_mutex);
-		if (limit < memcg->memory.limit) {
-			mutex_unlock(&memcg_limit_mutex);
-			ret = -EINVAL;
-			break;
-		}
-		if (limit > memcg->memsw.limit)
-			enlarge = true;
-		ret = page_counter_limit(&memcg->memsw, limit);
-		mutex_unlock(&memcg_limit_mutex);
+	return ret;
+}
 
+static int do_resize_legacy_limits(struct mem_cgroup *memcg,
+				   unsigned long mem_limit,
+				   unsigned long memsw_limit)
+{
+	unsigned long swap_limit;
+	int ret;
+
+	if (mem_limit > memsw_limit)
+		return -EINVAL;
+
+	swap_limit = memsw_limit == PAGE_COUNTER_MAX ?
+			PAGE_COUNTER_MAX : memsw_limit - mem_limit;
+
+	if (mem_limit < memcg->memory.limit) {
+		BUG_ON(swap_limit < memcg->swap.limit);
+		ret = resize_memory_limit(memcg, mem_limit);
 		if (!ret)
-			break;
+			BUG_ON(resize_swap_limit(memcg, swap_limit));
+	} else {
+		ret = resize_swap_limit(memcg, swap_limit);
+		if (!ret)
+			BUG_ON(resize_memory_limit(memcg, mem_limit));
+	}
+	return ret;
+}
 
-		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, false);
+static int resize_legacy_memory_limit(struct mem_cgroup *memcg,
+				      unsigned long mem_limit)
+{
+	unsigned long memsw_limit;
 
-		curusage = page_counter_read(&memcg->memsw);
-		/* Usage is reduced ? */
-		if (curusage >= oldusage)
-			retry_count--;
-		else
-			oldusage = curusage;
-	} while (retry_count);
+	memsw_limit = min((u64)PAGE_COUNTER_MAX,
+			  (u64)memcg->memory.limit + memcg->swap.limit);
+	return do_resize_legacy_limits(memcg, mem_limit, memsw_limit);
+}
 
-	if (!ret && enlarge)
-		memcg_oom_recover(memcg);
+static int resize_legacy_memsw_limit(struct mem_cgroup *memcg,
+				     unsigned long memsw_limit)
+{
+	unsigned long mem_limit;
 
-	return ret;
+	mem_limit = memcg->memory.limit;
+	return do_resize_legacy_limits(memcg, mem_limit, memsw_limit);
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
@@ -3372,21 +3359,36 @@ static unsigned long tree_stat(struct mem_cgroup *memcg,
 	return val;
 }
 
+static unsigned long read_memory_usage(struct mem_cgroup *memcg)
+{
+	unsigned long val;
+
+	if (mem_cgroup_is_root(memcg))
+		val = tree_stat(memcg, MEM_CGROUP_STAT_CACHE) +
+		      tree_stat(memcg, MEM_CGROUP_STAT_RSS);
+	else
+		val = page_counter_read(&memcg->memory);
+	return val;
+}
+
+static unsigned long read_swap_usage(struct mem_cgroup *memcg)
+{
+	unsigned long val;
+
+	if (mem_cgroup_is_root(memcg))
+		val = tree_stat(memcg, MEM_CGROUP_STAT_SWAP);
+	else
+		val = page_counter_read(&memcg->swap);
+	return val;
+}
+
 static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 {
 	u64 val;
 
-	if (mem_cgroup_is_root(memcg)) {
-		val = tree_stat(memcg, MEM_CGROUP_STAT_CACHE);
-		val += tree_stat(memcg, MEM_CGROUP_STAT_RSS);
-		if (swap)
-			val += tree_stat(memcg, MEM_CGROUP_STAT_SWAP);
-	} else {
-		if (!swap)
-			val = page_counter_read(&memcg->memory);
-		else
-			val = page_counter_read(&memcg->memsw);
-	}
+	val = read_memory_usage(memcg);
+	if (swap)
+		val += read_swap_usage(memcg);
 	return val << PAGE_SHIFT;
 }
 
@@ -3403,13 +3405,15 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct page_counter *counter;
+	int type;
 
-	switch (MEMFILE_TYPE(cft->private)) {
+	type = MEMFILE_TYPE(cft->private);
+	switch (type) {
 	case _MEM:
 		counter = &memcg->memory;
 		break;
 	case _MEMSWAP:
-		counter = &memcg->memsw;
+		counter = &memcg->swap;
 		break;
 	case _KMEM:
 		counter = &memcg->kmem;
@@ -3420,14 +3424,21 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 
 	switch (MEMFILE_ATTR(cft->private)) {
 	case RES_USAGE:
-		if (counter == &memcg->memory)
+		if (type == _MEM)
 			return mem_cgroup_usage(memcg, false);
-		if (counter == &memcg->memsw)
+		if (type == _MEMSWAP)
 			return mem_cgroup_usage(memcg, true);
 		return (u64)page_counter_read(counter) * PAGE_SIZE;
 	case RES_LIMIT:
+		if (type == _MEMSWAP)
+			return min((u64)PAGE_COUNTER_MAX,
+				   (u64)memcg->memory.limit +
+					memcg->swap.limit) * PAGE_SIZE;
 		return (u64)counter->limit * PAGE_SIZE;
 	case RES_MAX_USAGE:
+		if (type == _MEMSWAP)
+			return ((u64)memcg->memory.watermark +
+					memcg->swap.watermark) * PAGE_SIZE;
 		return (u64)counter->watermark * PAGE_SIZE;
 	case RES_FAILCNT:
 		return counter->failcnt;
@@ -3493,17 +3504,14 @@ out:
 	return err;
 }
 
-static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
-				   unsigned long limit)
+static int resize_kmem_limit(struct mem_cgroup *memcg, unsigned long limit)
 {
 	int ret;
 
-	mutex_lock(&memcg_limit_mutex);
 	if (!memcg_kmem_is_active(memcg))
 		ret = memcg_activate_kmem(memcg, limit);
 	else
 		ret = page_counter_limit(&memcg->kmem, limit);
-	mutex_unlock(&memcg_limit_mutex);
 	return ret;
 }
 
@@ -3515,7 +3523,9 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 	if (!parent)
 		return 0;
 
-	mutex_lock(&memcg_limit_mutex);
+	ret = mutex_lock_interruptible(&memcg_limit_mutex);
+	if (ret)
+		return ret;
 	/*
 	 * If the parent cgroup is not kmem-active now, it cannot be activated
 	 * after this point, because it has at least one child already.
@@ -3526,8 +3536,7 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 	return ret;
 }
 #else
-static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
-				   unsigned long limit)
+static int resize_kmem_limit(struct mem_cgroup *memcg, unsigned long limit)
 {
 	return -EINVAL;
 }
@@ -3555,17 +3564,21 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
 			ret = -EINVAL;
 			break;
 		}
+		ret = mutex_lock_interruptible(&memcg_limit_mutex);
+		if (ret)
+			break;
 		switch (MEMFILE_TYPE(of_cft(of)->private)) {
 		case _MEM:
-			ret = mem_cgroup_resize_limit(memcg, nr_pages);
+			ret = resize_legacy_memory_limit(memcg, nr_pages);
 			break;
 		case _MEMSWAP:
-			ret = mem_cgroup_resize_memsw_limit(memcg, nr_pages);
+			ret = resize_legacy_memsw_limit(memcg, nr_pages);
 			break;
 		case _KMEM:
-			ret = memcg_update_kmem_limit(memcg, nr_pages);
+			ret = resize_kmem_limit(memcg, nr_pages);
 			break;
 		}
+		mutex_unlock(&memcg_limit_mutex);
 		break;
 	case RES_SOFT_LIMIT:
 		memcg->soft_limit = nr_pages;
@@ -3580,13 +3593,15 @@ static ssize_t mem_cgroup_reset(struct kernfs_open_file *of, char *buf,
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
 	struct page_counter *counter;
+	int type;
 
-	switch (MEMFILE_TYPE(of_cft(of)->private)) {
+	type = MEMFILE_TYPE(of_cft(of)->private);
+	switch (type) {
 	case _MEM:
 		counter = &memcg->memory;
 		break;
 	case _MEMSWAP:
-		counter = &memcg->memsw;
+		counter = &memcg->swap;
 		break;
 	case _KMEM:
 		counter = &memcg->kmem;
@@ -3597,6 +3612,8 @@ static ssize_t mem_cgroup_reset(struct kernfs_open_file *of, char *buf,
 
 	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_MAX_USAGE:
+		if (type == _MEMSWAP)
+			page_counter_reset_watermark(&memcg->memory);
 		page_counter_reset_watermark(counter);
 		break;
 	case RES_FAILCNT:
@@ -3720,7 +3737,7 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 	memory = memsw = PAGE_COUNTER_MAX;
 	for (mi = memcg; mi; mi = parent_mem_cgroup(mi)) {
 		memory = min(memory, mi->memory.limit);
-		memsw = min(memsw, mi->memsw.limit);
+		memsw = min((u64)memsw, (u64)mi->memory.limit + mi->swap.limit);
 	}
 	seq_printf(m, "hierarchical_memory_limit %llu\n",
 		   (u64)memory * PAGE_SIZE);
@@ -4679,7 +4696,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	if (parent_css == NULL) {
 		root_mem_cgroup = memcg;
 		page_counter_init(&memcg->memory, NULL);
-		page_counter_init(&memcg->memsw, NULL);
+		page_counter_init(&memcg->swap, NULL);
 		page_counter_init(&memcg->kmem, NULL);
 	}
 
@@ -4724,7 +4741,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 
 	if (parent->use_hierarchy) {
 		page_counter_init(&memcg->memory, &parent->memory);
-		page_counter_init(&memcg->memsw, &parent->memsw);
+		page_counter_init(&memcg->swap, &parent->swap);
 		page_counter_init(&memcg->kmem, &parent->kmem);
 
 		/*
@@ -4733,7 +4750,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		 */
 	} else {
 		page_counter_init(&memcg->memory, NULL);
-		page_counter_init(&memcg->memsw, NULL);
+		page_counter_init(&memcg->swap, NULL);
 		page_counter_init(&memcg->kmem, NULL);
 		/*
 		 * Deeper hierachy with use_hierarchy == false doesn't make
@@ -4804,9 +4821,12 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
-	mem_cgroup_resize_limit(memcg, PAGE_COUNTER_MAX);
-	mem_cgroup_resize_memsw_limit(memcg, PAGE_COUNTER_MAX);
-	memcg_update_kmem_limit(memcg, PAGE_COUNTER_MAX);
+	mutex_lock(&memcg_limit_mutex);
+	resize_memory_limit(memcg, PAGE_COUNTER_MAX);
+	resize_swap_limit(memcg, PAGE_COUNTER_MAX);
+	resize_kmem_limit(memcg, PAGE_COUNTER_MAX);
+	mutex_unlock(&memcg_limit_mutex);
+
 	memcg->soft_limit = 0;
 }
 
@@ -4816,6 +4836,9 @@ static int mem_cgroup_do_precharge(unsigned long count)
 {
 	int ret;
 
+	if (do_swap_account && try_charge_swap(mc.to, count))
+		return -ENOMEM;
+
 	/* Try a single bulk charge without reclaim first */
 	ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_WAIT, count);
 	if (!ret) {
@@ -4824,11 +4847,11 @@ static int mem_cgroup_do_precharge(unsigned long count)
 	}
 	if (ret == -EINTR) {
 		cancel_charge(root_mem_cgroup, count);
-		return ret;
+		goto uncharge_swap;
 	}
 
 	/* Try charges one by one with reclaim */
-	while (count--) {
+	while (count) {
 		ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_NORETRY, 1);
 		/*
 		 * In case of failure, any residual charges against
@@ -4839,11 +4862,17 @@ static int mem_cgroup_do_precharge(unsigned long count)
 		if (ret == -EINTR)
 			cancel_charge(root_mem_cgroup, 1);
 		if (ret)
-			return ret;
+			goto uncharge_swap;
 		mc.precharge++;
+		count--;
 		cond_resched();
 	}
 	return 0;
+
+uncharge_swap:
+	if (do_swap_account)
+		cancel_charge_swap(mc.to, count);
+	return ret;
 }
 
 /**
@@ -5102,6 +5131,8 @@ static void __mem_cgroup_clear_mc(void)
 	/* we must uncharge all the leftover precharges from mc.to */
 	if (mc.precharge) {
 		cancel_charge(mc.to, mc.precharge);
+		if (do_swap_account)
+			cancel_charge_swap(mc.to, mc.precharge);
 		mc.precharge = 0;
 	}
 	/*
@@ -5110,24 +5141,21 @@ static void __mem_cgroup_clear_mc(void)
 	 */
 	if (mc.moved_charge) {
 		cancel_charge(mc.from, mc.moved_charge);
+
+		/* we charged both to->memory and to->swap, so we should
+		 * uncharge to->swap */
+		if (do_swap_account)
+			cancel_charge_swap(mc.to, mc.moved_charge);
+
 		mc.moved_charge = 0;
 	}
-	/* we must fixup refcnts and charges */
 	if (mc.moved_swap) {
-		/* uncharge swap account from the old cgroup */
-		if (!mem_cgroup_is_root(mc.from))
-			page_counter_uncharge(&mc.from->memsw, mc.moved_swap);
-
-		/*
-		 * we charged both to->memory and to->memsw, so we
-		 * should uncharge to->memory.
-		 */
-		if (!mem_cgroup_is_root(mc.to))
-			page_counter_uncharge(&mc.to->memory, mc.moved_swap);
+		cancel_charge_swap(mc.from, mc.moved_swap);
 
-		css_put_many(&mc.from->css, mc.moved_swap);
+		/* we charged both to->memory and to->swap, so we should
+		 * uncharge to->memory */
+		cancel_charge(mc.to, mc.moved_swap);
 
-		/* we've already done css_get(mc.to) */
 		mc.moved_swap = 0;
 	}
 	memcg_oom_recover(from);
@@ -5442,50 +5470,43 @@ static void __init enable_swap_cgroup(void)
 
 #ifdef CONFIG_MEMCG_SWAP
 /**
- * mem_cgroup_swapout - transfer a memsw charge to swap
- * @page: page whose memsw charge to transfer
- * @entry: swap entry to move the charge to
+ * mem_cgroup_charge_swap - charge a swap entry
+ * @page: page being added to swap
+ * @entry: swap entry to charge
  *
- * Transfer the memsw charge of @page to @entry.
+ * Try to charge @entry to the memcg that @page belongs to.
+ *
+ * Returns 0 on success, -errno on failure.
  */
-void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
+int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry)
 {
 	struct mem_cgroup *memcg;
 	unsigned short oldid;
 
-	VM_BUG_ON_PAGE(PageLRU(page), page);
-	VM_BUG_ON_PAGE(page_count(page), page);
-
 	if (!do_swap_account)
-		return;
+		return 0;
 
 	memcg = page->mem_cgroup;
 
 	/* Readahead page, never charged */
 	if (!memcg)
-		return;
+		return 0;
+
+	if (try_charge_swap(memcg, 1))
+		return -ENOMEM;
 
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
 	VM_BUG_ON_PAGE(oldid, page);
 	mem_cgroup_swap_statistics(memcg, true);
 
-	page->mem_cgroup = NULL;
-
-	if (!mem_cgroup_is_root(memcg))
-		page_counter_uncharge(&memcg->memory, 1);
-
-	/* XXX: caller holds IRQ-safe mapping->tree_lock */
-	VM_BUG_ON(!irqs_disabled());
-
-	mem_cgroup_charge_statistics(memcg, page, -1);
-	memcg_check_events(memcg, page);
+	return 0;
 }
 
 /**
  * mem_cgroup_uncharge_swap - uncharge a swap entry
  * @entry: swap entry to uncharge
  *
- * Drop the memsw charge associated with @entry.
+ * Drop the swap charge associated with @entry.
  */
 void mem_cgroup_uncharge_swap(swp_entry_t entry)
 {
@@ -5499,10 +5520,8 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
 	rcu_read_lock();
 	memcg = mem_cgroup_lookup(id);
 	if (memcg) {
-		if (!mem_cgroup_is_root(memcg))
-			page_counter_uncharge(&memcg->memsw, 1);
 		mem_cgroup_swap_statistics(memcg, false);
-		css_put(&memcg->css);
+		cancel_charge_swap(memcg, 1);
 	}
 	rcu_read_unlock();
 }
@@ -5665,8 +5684,6 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 
 	if (!mem_cgroup_is_root(memcg)) {
 		page_counter_uncharge(&memcg->memory, nr_pages);
-		if (do_swap_account)
-			page_counter_uncharge(&memcg->memsw, nr_pages);
 		memcg_oom_recover(memcg);
 	}
 
diff --git a/mm/page_counter.c b/mm/page_counter.c
index a009574fbba9..9bc9db87dde6 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -133,6 +133,14 @@ void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages)
  */
 int page_counter_limit(struct page_counter *counter, unsigned long limit)
 {
+	/*
+	 * Never fail enlarging the limit.
+	 */
+	if (limit >= counter->limit) {
+		counter->limit = limit;
+		return 0;
+	}
+
 	for (;;) {
 		unsigned long old;
 		long count;
diff --git a/mm/shmem.c b/mm/shmem.c
index 185836ba53ef..2cf2c71fe2b6 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -812,6 +812,9 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	if (!swap.val)
 		goto redirty;
 
+	if (mem_cgroup_charge_swap(page, swap))
+		goto free_swap;
+
 	/*
 	 * Add inode to shmem_unuse()'s list of swapped-out inodes,
 	 * if it's not already there.  Do it now before the page is
@@ -840,6 +843,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	}
 
 	mutex_unlock(&shmem_swaplist_mutex);
+free_swap:
 	swapcache_free(swap);
 redirty:
 	set_page_dirty(page);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 9711342987a0..8debfc621de6 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -176,6 +176,11 @@ int add_to_swap(struct page *page, struct list_head *list)
 	if (!entry.val)
 		return 0;
 
+	if (mem_cgroup_charge_swap(page, entry)) {
+		swapcache_free(entry);
+		return 0;
+	}
+
 	if (unlikely(PageTransHuge(page)))
 		if (unlikely(split_huge_page_to_list(page, list))) {
 			swapcache_free(entry);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8772b2b9ef..e9b1a5b78990 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -577,7 +577,6 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 
 	if (PageSwapCache(page)) {
 		swp_entry_t swap = { .val = page_private(page) };
-		mem_cgroup_swapout(page, swap);
 		__delete_from_swap_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
 		swapcache_free(swap);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
