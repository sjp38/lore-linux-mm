Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 56FE56B0044
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:57:25 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id t13so3125763lbd.1
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:57:23 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v10 09/16] memcg: per-memcg kmem shrinking
Date: Sun,  7 Jul 2013 11:56:49 -0400
Message-Id: <1373212616-11713-10-git-send-email-glommer@openvz.org>
In-Reply-To: <1373212616-11713-1-git-send-email-glommer@openvz.org>
References: <1373212616-11713-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, akpm@linux-foundation.org, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>

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

For those cases, the best we can do is to spawn a worker and fail the
current allocation.

[ v2: moved congestion_wait call to vmscan.c ]
[ v12: Don't wait for worker to complete ]
Signed-off-by: Glauber Costa <glommer@openvz.org>
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
 mm/memcontrol.c      | 116 ++++++++++++++++++++++++++++++++++++++++++++++++---
 mm/vmscan.c          |  44 ++++++++++++++++++-
 3 files changed, 155 insertions(+), 7 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d95cde5..efb3e8c 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -276,6 +276,8 @@ extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap);
+extern unsigned long try_to_free_mem_cgroup_kmem(struct mem_cgroup *mem,
+						 gfp_t gfp_mask);
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d853d71..1f13480 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -341,6 +341,8 @@ struct mem_cgroup {
 	atomic_t	numainfo_events;
 	atomic_t	numainfo_updating;
 #endif
+	/* when kmem shrinkers can sleep but can't proceed due to context */
+	struct work_struct kmemcg_shrink_work;
 
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
@@ -352,11 +354,14 @@ static size_t memcg_size(void)
 		nr_node_ids * sizeof(struct mem_cgroup_per_node);
 }
 
+static DEFINE_MUTEX(set_limit_mutex);
+
 /* internal only representation about the status of kmem accounting. */
 enum {
 	KMEM_ACCOUNTED_ACTIVE = 0, /* accounted by this cgroup itself */
 	KMEM_ACCOUNTED_ACTIVATED, /* static key enabled. */
 	KMEM_ACCOUNTED_DEAD, /* dead memcg with pending kmem charges */
+	KMEM_MAY_SHRINK, /* kmem limit < mem limit, shrink kmem only */
 };
 
 /* We account when limit is on, but only after call sites are patched */
@@ -400,6 +405,31 @@ static bool memcg_kmem_test_and_clear_dead(struct mem_cgroup *memcg)
 	return test_and_clear_bit(KMEM_ACCOUNTED_DEAD,
 				  &memcg->kmem_account_flags);
 }
+
+/*
+ * If the kernel limit is smaller than the user limit, we will have situations
+ * in which our allocations fail but freeing user pages will buy us nothing.
+ * In those, we would like to call a specialized memcg reclaimer that only
+ * frees kernel memory and leaves the user memory alone.
+ *
+ * This test exists so we can differentiate between those. Every time one of the
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
+#else
+static void memcg_update_shrink_status(struct mem_cgroup *memcg)
+{
+}
 #endif
 
 /* Stuffs for move charges at task migration. */
@@ -2945,8 +2975,6 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 	memcg_check_events(memcg, page);
 }
 
-static DEFINE_MUTEX(set_limit_mutex);
-
 #ifdef CONFIG_MEMCG_KMEM
 static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 {
@@ -3044,16 +3072,55 @@ static int mem_cgroup_slabinfo_read(struct cgroup *cont, struct cftype *cft,
 }
 #endif
 
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
+		/*
+		 * We will try to shrink kernel memory present in caches.  If
+		 * we can't wait, we will have no option rather than fail the
+		 * current allocation and make room in the background hoping
+		 * the next one will succeed.
+		 *
+		 * If we are in FS context, then although we can wait,
+		 * we cannot call the shrinkers. Most fs shrinkers will not run
+		 * without __GFP_FS since they can deadlock.
+		 */
+		if (!(gfp & __GFP_WAIT) || !(gfp & __GFP_FS)) {
+			/*
+			 * we are already short on memory, every queue
+			 * allocation is likely to fail.
+			 */
+			memcg_stop_kmem_account();
+			schedule_work(&memcg->kmemcg_shrink_work);
+			memcg_resume_kmem_account();
+		} else
+			try_to_free_mem_cgroup_kmem(memcg, gfp);
+	} while (retries--);
+
+	return ret;
+}
+
 static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 {
 	struct res_counter *fail_res;
 	struct mem_cgroup *_memcg;
 	int ret = 0;
 	bool may_oom;
+	bool kmem_first = test_bit(KMEM_MAY_SHRINK, &memcg->kmem_account_flags);
 
-	ret = res_counter_charge(&memcg->kmem, size, &fail_res);
-	if (ret)
-		return ret;
+	if (kmem_first) {
+		ret = memcg_try_charge_kmem(memcg, gfp, size);
+		if (ret)
+			return ret;
+	}
 
 	/*
 	 * Conditions under which we can wait for the oom_killer. Those are
@@ -3086,12 +3153,46 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 			res_counter_charge_nofail(&memcg->memsw, size,
 						  &fail_res);
 		ret = 0;
-	} else if (ret)
+		if (kmem_first)
+			res_counter_charge_nofail(&memcg->kmem, size, &fail_res);
+	} else if (ret && kmem_first)
 		res_counter_uncharge(&memcg->kmem, size);
 
+	if (!ret && !kmem_first) {
+		ret = res_counter_charge(&memcg->kmem, size, &fail_res);
+		if (!ret)
+			return ret;
+
+		res_counter_uncharge(&memcg->res, size);
+		if (do_swap_account)
+			res_counter_uncharge(&memcg->memsw, size);
+	}
+
 	return ret;
 }
 
+/*
+ * There might be situations in which there are plenty of objects to shrink,
+ * but we can't do it because the __GFP_FS flag is not set.  This is the case
+ * with almost all inode allocation. Unfortunately we have no idea which fs
+ * locks we are holding to put ourselves in this situation, so the best we
+ * can do is to spawn a worker, fail the current allocation and hope that
+ * the next one succeeds.
+ *
+ * One way to make it better is to introduce some sort of implicit soft-limit
+ * that would trigger background reclaim for memcg when we are close to the
+ * kmem limit, so that we would never have to be faced with direct reclaim
+ * potentially lacking __GFP_FS.
+ */
+static void kmemcg_shrink_work_fn(struct work_struct *w)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = container_of(w, struct mem_cgroup, kmemcg_shrink_work);
+	try_to_free_mem_cgroup_kmem(memcg, GFP_KERNEL);
+}
+
+
 static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 {
 	res_counter_uncharge(&memcg->res, size);
@@ -5452,6 +5553,8 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 			ret = memcg_update_kmem_limit(cont, val);
 		else
 			return -EINVAL;
+		if (!ret)
+			memcg_update_shrink_status(memcg);
 		break;
 	case RES_SOFT_LIMIT:
 		ret = res_counter_memparse_write_strategy(buffer, &val);
@@ -6083,6 +6186,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	int ret;
 
 	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
+	INIT_WORK(&memcg->kmemcg_shrink_work, kmemcg_shrink_work_fn);
 	mutex_init(&memcg->slab_caches_mutex);
 	memcg->kmemcg_id = -1;
 	ret = memcg_propagate_kmem(memcg);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d2d9823..74653ed 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2714,7 +2714,49 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
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
+	long freed;
+
+	struct shrink_control shrink = {
+		.gfp_mask = gfp_mask,
+		.target_mem_cgroup = memcg,
+	};
+
+	if (!(gfp_mask & __GFP_WAIT))
+		return 0;
+
+	/*
+	 * memcg pressure is always global */
+	nodes_setall(shrink.nodes_to_scan);
+
+	/*
+	 * We haven't scanned any user LRU, so we basically come up with
+	 * crafted values of nr_scanned and LRU page (1 and 0 respectively).
+	 * This should be enough to tell shrink_slab that the freeing
+	 * responsibility is all on himself.
+	 */
+	freed = shrink_slab(&shrink, 1, 0);
+	if (!freed)
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
+	return freed;
+}
+#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG */
 
 static void age_active_anon(struct zone *zone, struct scan_control *sc)
 {
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
