Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C77F26B0007
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 09:21:08 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id e3-v6so2157940qkj.17
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 06:21:08 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10090.outbound.protection.outlook.com. [40.107.1.90])
        by mx.google.com with ESMTPS id n3-v6si3108682qvi.279.2018.08.08.06.21.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Aug 2018 06:21:07 -0700 (PDT)
Subject: [PATCH RFC v2 02/10] mm: Make shrink_slab() lockless
From: Kirill Tkhai <ktkhai@virtuozzo.com>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365626605.19074.16202958374930777592.stgit@localhost.localdomain>
 <591d2063-0511-103d-bef6-dd35f55afe32@virtuozzo.com>
Message-ID: <4ceb948c-7ce7-0db3-17d8-82ef1e6e47cc@virtuozzo.com>
Date: Wed, 8 Aug 2018 16:20:54 +0300
MIME-Version: 1.0
In-Reply-To: <591d2063-0511-103d-bef6-dd35f55afe32@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

[Added two more places needed srcu_dereference(). All ->shrinker_map
 dereferences must be under SRCU, and this v2 adds missed in previous]

The patch makes shrinker list and shrinker_idr SRCU-safe
for readers. This requires synchronize_srcu() on finalize
stage unregistering stage, which waits till all parallel
shrink_slab() are finished

Note, that patch removes rwsem_is_contended() checks from
the code, and this does not result in delays during
registration, since there is no waiting at all. Unregistration
case may be optimized by splitting unregister_shrinker()
in tho stages, and this is made in next patches.
    
Also, keep in mind, that in case of SRCU is not allowed
to make unconditional (which is done in previous patch),
it is possible to use percpu_rw_semaphore instead of it.
percpu_down_read() will be used in shrink_slab_memcg()
and in shrink_slab(), and consecutive calls

        percpu_down_write(percpu_rwsem);
        percpu_up_write(percpu_rwsem);

will be used instead of synchronize_srcu().

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 9443cafd1969..94b44662f430 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -82,6 +82,8 @@ struct shrinker {
 #define SHRINKER_NUMA_AWARE	(1 << 0)
 #define SHRINKER_MEMCG_AWARE	(1 << 1)
 
+extern struct srcu_struct shrinker_srcu;
+
 extern int prealloc_shrinker(struct shrinker *shrinker);
 extern void register_shrinker_prepared(struct shrinker *shrinker);
 extern int register_shrinker(struct shrinker *shrinker);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4e3c1315b1de..ed40eb4b8300 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -332,8 +332,9 @@ static int memcg_expand_one_shrinker_map(struct mem_cgroup *memcg,
 	lockdep_assert_held(&memcg_shrinker_map_mutex);
 
 	for_each_node(nid) {
-		old = rcu_dereference_protected(
-			mem_cgroup_nodeinfo(memcg, nid)->shrinker_map, true);
+		old = srcu_dereference_check(
+			mem_cgroup_nodeinfo(memcg, nid)->shrinker_map,
+			&shrinker_srcu, true);
 		/* Not yet online memcg */
 		if (!old)
 			return 0;
@@ -347,7 +348,7 @@ static int memcg_expand_one_shrinker_map(struct mem_cgroup *memcg,
 		memset((void *)new->map + old_size, 0, size - old_size);
 
 		rcu_assign_pointer(memcg->nodeinfo[nid]->shrinker_map, new);
-		call_rcu(&old->rcu, memcg_free_shrinker_map_rcu);
+		call_srcu(&shrinker_srcu, &old->rcu, memcg_free_shrinker_map_rcu);
 	}
 
 	return 0;
@@ -364,7 +365,8 @@ static void memcg_free_shrinker_maps(struct mem_cgroup *memcg)
 
 	for_each_node(nid) {
 		pn = mem_cgroup_nodeinfo(memcg, nid);
-		map = rcu_dereference_protected(pn->shrinker_map, true);
+		map = srcu_dereference_check(pn->shrinker_map,
+				&shrinker_srcu, true);
 		if (map)
 			kvfree(map);
 		rcu_assign_pointer(pn->shrinker_map, NULL);
@@ -427,13 +429,15 @@ void memcg_set_shrinker_bit(struct mem_cgroup *memcg, int nid, int shrinker_id)
 {
 	if (shrinker_id >= 0 && memcg && !mem_cgroup_is_root(memcg)) {
 		struct memcg_shrinker_map *map;
+		int srcu_id;
 
-		rcu_read_lock();
-		map = rcu_dereference(memcg->nodeinfo[nid]->shrinker_map);
+		srcu_id = srcu_read_lock(&shrinker_srcu);
+		map = srcu_dereference(memcg->nodeinfo[nid]->shrinker_map,
+				       &shrinker_srcu);
 		/* Pairs with smp mb in shrink_slab() */
 		smp_mb__before_atomic();
 		set_bit(shrinker_id, map->map);
-		rcu_read_unlock();
+		srcu_read_unlock(&shrinker_srcu, srcu_id);
 	}
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index da135e1acd94..acb087f3ac35 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -168,6 +168,7 @@ unsigned long vm_total_pages;
 
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
+DEFINE_SRCU(shrinker_srcu);
 
 #ifdef CONFIG_MEMCG_KMEM
 
@@ -192,7 +193,6 @@ static int prealloc_memcg_shrinker(struct shrinker *shrinker)
 	int id, ret = -ENOMEM;
 
 	down_write(&shrinker_rwsem);
-	/* This may call shrinker, so it must use down_read_trylock() */
 	id = idr_alloc(&shrinker_idr, SHRINKER_REGISTERING, 0, 0, GFP_KERNEL);
 	if (id < 0)
 		goto unlock;
@@ -406,7 +406,7 @@ void free_prealloced_shrinker(struct shrinker *shrinker)
 void register_shrinker_prepared(struct shrinker *shrinker)
 {
 	down_write(&shrinker_rwsem);
-	list_add_tail(&shrinker->list, &shrinker_list);
+	list_add_tail_rcu(&shrinker->list, &shrinker_list);
 	idr_replace(&shrinker_idr, shrinker, shrinker->id);
 	up_write(&shrinker_rwsem);
 }
@@ -432,8 +432,11 @@ void unregister_shrinker(struct shrinker *shrinker)
 	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
 		unregister_memcg_shrinker(shrinker);
 	down_write(&shrinker_rwsem);
-	list_del(&shrinker->list);
+	list_del_rcu(&shrinker->list);
 	up_write(&shrinker_rwsem);
+
+	synchronize_srcu(&shrinker_srcu);
+
 	kfree(shrinker->nr_deferred);
 	shrinker->nr_deferred = NULL;
 }
@@ -567,16 +570,14 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 {
 	struct memcg_shrinker_map *map;
 	unsigned long freed = 0;
-	int ret, i;
+	int ret, i, srcu_id;
 
 	if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
 		return 0;
 
-	if (!down_read_trylock(&shrinker_rwsem))
-		return 0;
-
-	map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
-					true);
+	srcu_id = srcu_read_lock(&shrinker_srcu);
+	map = srcu_dereference(memcg->nodeinfo[nid]->shrinker_map,
+			       &shrinker_srcu);
 	if (unlikely(!map))
 		goto unlock;
 
@@ -621,14 +622,9 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 				memcg_set_shrinker_bit(memcg, nid, i);
 		}
 		freed += ret;
-
-		if (rwsem_is_contended(&shrinker_rwsem)) {
-			freed = freed ? : 1;
-			break;
-		}
 	}
 unlock:
-	up_read(&shrinker_rwsem);
+	srcu_read_unlock(&shrinker_srcu, srcu_id);
 	return freed;
 }
 #else /* CONFIG_MEMCG_KMEM */
@@ -665,15 +661,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
-	int ret;
+	int srcu_id, ret;
 
 	if (!mem_cgroup_is_root(memcg))
 		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
 
-	if (!down_read_trylock(&shrinker_rwsem))
-		goto out;
-
-	list_for_each_entry(shrinker, &shrinker_list, list) {
+	srcu_id = srcu_read_lock(&shrinker_srcu);
+	list_for_each_entry_rcu(shrinker, &shrinker_list, list) {
 		struct shrink_control sc = {
 			.gfp_mask = gfp_mask,
 			.nid = nid,
@@ -684,19 +678,9 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		if (ret == SHRINK_EMPTY)
 			ret = 0;
 		freed += ret;
-		/*
-		 * Bail out if someone want to register a new shrinker to
-		 * prevent the regsitration from being stalled for long periods
-		 * by parallel ongoing shrinking.
-		 */
-		if (rwsem_is_contended(&shrinker_rwsem)) {
-			freed = freed ? : 1;
-			break;
-		}
 	}
+	srcu_read_unlock(&shrinker_srcu, srcu_id);
 
-	up_read(&shrinker_rwsem);
-out:
 	cond_resched();
 	return freed;
 }
