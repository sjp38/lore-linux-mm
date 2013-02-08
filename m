Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id BE4626B000D
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 08:07:40 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 7/7] memcg: per-memcg kmem shrinking
Date: Fri,  8 Feb 2013 17:07:37 +0400
Message-Id: <1360328857-28070-8-git-send-email-glommer@parallels.com>
In-Reply-To: <1360328857-28070-1-git-send-email-glommer@parallels.com>
References: <1360328857-28070-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Dave Shrinnker <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, Glauber Costa <glommer@parallels.com>, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

If the kernel limit is smaller than the user limit, we will have
situations in which our allocations fail but freeing user pages will buy
us nothing.  In those, we would like to call a specialized memcg
reclaimer that only frees kernel memory and leave the user memory alone.
Those are also expected to fail when we account memcg->kmem, instead of
when we account memcg->res. Based on that, this patch implements a
memcg-specific reclaimer, that only shrinks kernel objects, withouth
touching user pages.

There might be situations in which there are plenty of objects to
shrink, but we can't do it because the __GFP_FS flag is not set.
Although they can happen with user pages, they are a lot more common
with fs-metadata: this is the case with almost all inode allocation.

Those allocations are, however, capable of waiting.  So we can just span
a worker, let it finish its job and proceed with the allocation. As slow
as it is, at this point we are already past any hopes anyway.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/swap.h |   2 +
 mm/memcontrol.c      | 102 +++++++++++++++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c          |  37 ++++++++++++++++++-
 3 files changed, 137 insertions(+), 4 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 8c66486..ff74226 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -259,6 +259,8 @@ extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap);
+extern unsigned long try_to_free_mem_cgroup_kmem(struct mem_cgroup *mem,
+						 gfp_t gfp_mask);
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bfb4b5b..7dc9ec1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -294,6 +294,8 @@ struct mem_cgroup {
 	atomic_t	numainfo_events;
 	atomic_t	numainfo_updating;
 #endif
+
+	struct work_struct kmemcg_shrink_work;
 	/*
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
@@ -376,6 +378,9 @@ struct mem_cgroup {
 #endif
 };
 
+
+static DEFINE_MUTEX(set_limit_mutex);
+
 #ifdef CONFIG_MEMCG_DEBUG_ASYNC_DESTROY
 static LIST_HEAD(dangling_memcgs);
 static DEFINE_MUTEX(dangling_memcgs_mutex);
@@ -430,6 +435,7 @@ enum {
 	KMEM_ACCOUNTED_ACTIVE = 0, /* accounted by this cgroup itself */
 	KMEM_ACCOUNTED_ACTIVATED, /* static key enabled. */
 	KMEM_ACCOUNTED_DEAD, /* dead memcg with pending kmem charges */
+	KMEM_MAY_SHRINK, /* kmem limit < mem limit, shrink kmem only */
 };
 
 /* We account when limit is on, but only after call sites are patched */
@@ -468,6 +474,36 @@ static bool memcg_kmem_test_and_clear_dead(struct mem_cgroup *memcg)
 	return test_and_clear_bit(KMEM_ACCOUNTED_DEAD,
 				  &memcg->kmem_account_flags);
 }
+
+/*
+ * If the kernel limit is smaller than the user limit, we will have situations
+ * in which our allocations fail but freeing user pages will buy us nothing.
+ * In those, we would like to call a specialized memcg reclaimer that only
+ * frees kernel memory and leave the user memory alone.
+ *
+ * This test exists so we can differentiate between those. Everytime one of the
+ * limits is updated, we need to run it. The set_limit_mutex must be held, so
+ * they don't change again.
+ */
+static void memcg_update_shrink_status(struct mem_cgroup *memcg)
+{
+	mutex_lock(&set_limit_mutex);
+	if (res_counter_read_u64(&memcg->kmem, RES_LIMIT) <
+		res_counter_read_u64(&memcg->res, RES_LIMIT))
+		set_bit(KMEM_MAY_SHRINK, &memcg->kmem_account_flags);
+	else
+		clear_bit(KMEM_MAY_SHRINK, &memcg->kmem_account_flags);
+	mutex_unlock(&set_limit_mutex);
+}
+
+static bool memcg_kmem_should_shrink(struct mem_cgroup *memcg)
+{
+	return test_bit(KMEM_MAY_SHRINK, &memcg->kmem_account_flags);
+}
+#else
+static void memcg_update_shrink_status(struct mem_cgroup *memcg)
+{
+}
 #endif
 
 /* Stuffs for move charges at task migration. */
@@ -2882,8 +2918,6 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 	memcg_check_events(memcg, page);
 }
 
-static DEFINE_MUTEX(set_limit_mutex);
-
 #ifdef CONFIG_MEMCG_KMEM
 static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 {
@@ -2925,6 +2959,7 @@ static int mem_cgroup_slabinfo_read(struct cgroup *cont, struct cftype *cft,
 }
 #endif
 
+static int memcg_try_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size);
 static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 {
 	struct res_counter *fail_res;
@@ -2932,7 +2967,7 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 	int ret = 0;
 	bool may_oom;
 
-	ret = res_counter_charge(&memcg->kmem, size, &fail_res);
+	ret = memcg_try_charge_kmem(memcg, gfp, size);
 	if (ret)
 		return ret;
 
@@ -2973,6 +3008,25 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 	return ret;
 }
 
+/*
+ * There might be situations in which there are plenty of objects to shrink,
+ * but we can't do it because the __GFP_FS flag is not set.  This is the case
+ * with almost all inode allocation. They do are, however, capable of waiting.
+ * So we can just span a worker, let it finish its job and proceed with the
+ * allocation. As slow as it is, at this point we are already past any hopes
+ * anyway.
+ */
+static void kmemcg_shrink_work_fn(struct work_struct *w)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = container_of(w, struct mem_cgroup, kmemcg_shrink_work);
+
+	if (!try_to_free_mem_cgroup_kmem(memcg, GFP_KERNEL))
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
+}
+
+
 static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 {
 	res_counter_uncharge(&memcg->res, size);
@@ -3049,6 +3103,7 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 	memcg_update_array_size(num + 1);
 
 	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
+	INIT_WORK(&memcg->kmemcg_shrink_work, kmemcg_shrink_work_fn);
 	mutex_init(&memcg->slab_caches_mutex);
 
 	return 0;
@@ -3319,6 +3374,36 @@ static inline void memcg_resume_kmem_account(void)
 	current->memcg_kmem_skip_account--;
 }
 
+static int memcg_try_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
+{
+	int retries = MEM_CGROUP_RECLAIM_RETRIES;
+	struct res_counter *fail_res;
+	int ret;
+
+	do {
+		ret = res_counter_charge(&memcg->kmem, size, &fail_res);
+		if (!ret)
+			return ret;
+
+		if (!memcg_kmem_should_shrink(memcg) || !(gfp & __GFP_WAIT))
+			return ret;
+
+		if (!(gfp & __GFP_FS)) {
+			/*
+			 * we are already short on memory, every queue
+			 * allocation is likely to fail
+			 */
+			memcg_stop_kmem_account();
+			schedule_work(&memcg->kmemcg_shrink_work);
+			memcg_resume_kmem_account();
+		} else if (!try_to_free_mem_cgroup_kmem(memcg, gfp))
+			congestion_wait(BLK_RW_ASYNC, HZ/10);
+
+	} while (retries--);
+
+	return ret;
+}
+
 static struct mem_cgroup *mem_cgroup_from_kmem_page(struct page *page)
 {
 	struct page_cgroup *pc;
@@ -5399,6 +5484,9 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 			ret = memcg_update_kmem_limit(cont, val);
 		else
 			return -EINVAL;
+
+		if (!ret)
+			memcg_update_shrink_status(memcg);
 		break;
 	case RES_SOFT_LIMIT:
 		ret = res_counter_memparse_write_strategy(buffer, &val);
@@ -5411,6 +5499,8 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 		 */
 		if (type == _MEM)
 			ret = res_counter_set_soft_limit(&memcg->res, val);
+		else if (type == _KMEM)
+			ret = res_counter_set_soft_limit(&memcg->kmem, val);
 		else
 			ret = -EINVAL;
 		break;
@@ -6178,6 +6268,12 @@ static struct cftype mem_cgroup_files[] = {
 		.read = mem_cgroup_read,
 	},
 	{
+		.name = "kmem.soft_limit_in_bytes",
+		.private = MEMFILE_PRIVATE(_KMEM, RES_SOFT_LIMIT),
+		.write_string = mem_cgroup_write,
+		.read = mem_cgroup_read,
+	},
+	{
 		.name = "kmem.usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_KMEM, RES_USAGE),
 		.read = mem_cgroup_read,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8af0e2b..e4de27a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2499,7 +2499,42 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	return nr_reclaimed;
 }
-#endif
+
+#ifdef CONFIG_MEMCG_KMEM
+/*
+ * This function is called when we are under kmem-specific pressure.  It will
+ * only trigger in environments with kmem.limit_in_bytes < limit_in_bytes, IOW,
+ * with a lower kmem allowance than the memory allowance.
+ *
+ * In this situation, freeing user pages from the cgroup won't do us any good.
+ * What we really need is to call the memcg-aware shrinkers, in the hope of
+ * freeing pages holding kmem objects. It may also be that we won't be able to
+ * free any pages, but will get rid of old objects opening up space for new
+ * ones.
+ */
+unsigned long try_to_free_mem_cgroup_kmem(struct mem_cgroup *memcg,
+					  gfp_t gfp_mask)
+{
+	struct shrink_control shrink = {
+		.gfp_mask = gfp_mask,
+		.target_mem_cgroup = memcg,
+	};
+
+	if (!(gfp_mask & __GFP_WAIT))
+		return 0;
+
+	nodes_setall(shrink.nodes_to_scan);
+
+	/*
+	 * We haven't scanned any user LRU, so we basically come up with
+	 * crafted values of nr_scanned and LRU page (1 and 0 respectively).
+	 * This should be enough to tell shrink_slab that the freeing
+	 * responsibility is all on himself.
+	 */
+	return shrink_slab(&shrink, 1, 0);
+}
+#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG */
 
 static void age_active_anon(struct zone *zone, struct scan_control *sc)
 {
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
