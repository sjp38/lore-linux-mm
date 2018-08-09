Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 039786B000A
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 07:23:42 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id i9-v6so4298532qtj.3
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 04:23:41 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0092.outbound.protection.outlook.com. [104.47.0.92])
        by mx.google.com with ESMTPS id 57-v6si6820037qtz.128.2018.08.09.04.23.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Aug 2018 04:23:40 -0700 (PDT)
Subject: Re: [PATCH RFC v2 02/10] mm: Make shrink_slab() lockless
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365626605.19074.16202958374930777592.stgit@localhost.localdomain>
 <591d2063-0511-103d-bef6-dd35f55afe32@virtuozzo.com>
 <4ceb948c-7ce7-0db3-17d8-82ef1e6e47cc@virtuozzo.com>
 <20180809071418.GA24884@dhcp22.suse.cz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <964ee4fe-bbd1-0caa-4c5e-a73af99ee7bb@virtuozzo.com>
Date: Thu, 9 Aug 2018 14:23:28 +0300
MIME-Version: 1.0
In-Reply-To: <20180809071418.GA24884@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 09.08.2018 10:14, Michal Hocko wrote:
> On Wed 08-08-18 16:20:54, Kirill Tkhai wrote:
>> [Added two more places needed srcu_dereference(). All ->shrinker_map
>>  dereferences must be under SRCU, and this v2 adds missed in previous]
>>
>> The patch makes shrinker list and shrinker_idr SRCU-safe
>> for readers. This requires synchronize_srcu() on finalize
>> stage unregistering stage, which waits till all parallel
>> shrink_slab() are finished
>>
>> Note, that patch removes rwsem_is_contended() checks from
>> the code, and this does not result in delays during
>> registration, since there is no waiting at all. Unregistration
>> case may be optimized by splitting unregister_shrinker()
>> in tho stages, and this is made in next patches.
>>     
>> Also, keep in mind, that in case of SRCU is not allowed
>> to make unconditional (which is done in previous patch),
>> it is possible to use percpu_rw_semaphore instead of it.
>> percpu_down_read() will be used in shrink_slab_memcg()
>> and in shrink_slab(), and consecutive calls
>>
>>         percpu_down_write(percpu_rwsem);
>>         percpu_up_write(percpu_rwsem);
>>
>> will be used instead of synchronize_srcu().
> 
> An obvious question. Why didn't you go that way? What are pros/cons of
> both approaches?

percpu_rw_semaphore based variant looks something like:

commit d581d4ad7ecf
Author: Kirill Tkhai <ktkhai@virtuozzo.com>
Date:   Thu Aug 9 14:21:12 2018 +0300

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0ff97e860759..fe8693775e33 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -168,6 +168,7 @@ unsigned long vm_total_pages;
 
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
+DEFINE_STATIC_PERCPU_RWSEM(shrinker_percpu_rwsem);
 
 #ifdef CONFIG_MEMCG_KMEM
 
@@ -198,7 +199,10 @@ static int prealloc_memcg_shrinker(struct shrinker *shrinker)
 		goto unlock;
 
 	if (id >= shrinker_nr_max) {
-		if (memcg_expand_shrinker_maps(id)) {
+		percpu_down_write(&shrinker_percpu_rwsem);
+		ret = memcg_expand_shrinker_maps(id);
+		percpu_up_write(&shrinker_percpu_rwsem);
+		if (ret) {
 			idr_remove(&shrinker_idr, id);
 			goto unlock;
 		}
@@ -406,7 +410,7 @@ void free_prealloced_shrinker(struct shrinker *shrinker)
 void register_shrinker_prepared(struct shrinker *shrinker)
 {
 	down_write(&shrinker_rwsem);
-	list_add_tail(&shrinker->list, &shrinker_list);
+	list_add_tail_rcu(&shrinker->list, &shrinker_list);
 #ifdef CONFIG_MEMCG_KMEM
 	idr_replace(&shrinker_idr, shrinker, shrinker->id);
 #endif
@@ -434,8 +438,14 @@ void unregister_shrinker(struct shrinker *shrinker)
 	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
 		unregister_memcg_shrinker(shrinker);
 	down_write(&shrinker_rwsem);
-	list_del(&shrinker->list);
+	list_del_rcu(&shrinker->list);
 	up_write(&shrinker_rwsem);
+
+	synchronize_rcu();
+
+	percpu_down_write(&shrinker_percpu_rwsem);
+	percpu_up_write(&shrinker_percpu_rwsem);
+
 	kfree(shrinker->nr_deferred);
 	shrinker->nr_deferred = NULL;
 }
@@ -574,11 +584,11 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 	if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
 		return 0;
 
-	if (!down_read_trylock(&shrinker_rwsem))
+	if (!percpu_down_read_trylock(&shrinker_percpu_rwsem))
 		return 0;
 
 	map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
-					true);
+					true /* shrinker_percpu_rwsem */);
 	if (unlikely(!map))
 		goto unlock;
 
@@ -590,7 +600,22 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 		};
 		struct shrinker *shrinker;
 
+		/*
+		 * See shutdown sequence in unregister_shrinker().
+		 * RCU allows us to iterate IDR locklessly (this
+		 * is the way to synchronize with IDR changing by
+		 * idr_alloc()).
+		 *
+		 * If we see shrinker pointer undex RCU, this means
+		 * synchronize_rcu() in unregister_shrinker() has not
+		 * finished yet. Then, we unlock RCU, and synchronize_rcu()
+		 * can complete, but unregister_shrinker() can't proceed,
+		 * before we unlock shrinker_percpu_rwsem.
+		 */
+		rcu_read_lock();
 		shrinker = idr_find(&shrinker_idr, i);
+		rcu_read_unlock();
+
 		if (unlikely(!shrinker || shrinker == SHRINKER_REGISTERING)) {
 			if (!shrinker)
 				clear_bit(i, map->map);
@@ -624,13 +649,13 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
 		}
 		freed += ret;
 
-		if (rwsem_is_contended(&shrinker_rwsem)) {
+		if (!rcu_sync_is_idle(&shrinker_percpu_rwsem.rss)) {
 			freed = freed ? : 1;
 			break;
 		}
 	}
 unlock:
-	up_read(&shrinker_rwsem);
+	percpu_up_read(&shrinker_percpu_rwsem);
 	return freed;
 }
 #else /* CONFIG_MEMCG_KMEM */
@@ -672,15 +697,17 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	if (!mem_cgroup_is_root(memcg))
 		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
 
-	if (!down_read_trylock(&shrinker_rwsem))
+	if (!percpu_down_read_trylock(&shrinker_percpu_rwsem))
 		goto out;
 
-	list_for_each_entry(shrinker, &shrinker_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(shrinker, &shrinker_list, list) {
 		struct shrink_control sc = {
 			.gfp_mask = gfp_mask,
 			.nid = nid,
 			.memcg = memcg,
 		};
+		rcu_read_unlock();
 
 		ret = do_shrink_slab(&sc, shrinker, priority);
 		if (ret == SHRINK_EMPTY)
@@ -691,13 +718,16 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		 * prevent the regsitration from being stalled for long periods
 		 * by parallel ongoing shrinking.
 		 */
-		if (rwsem_is_contended(&shrinker_rwsem)) {
+		if (!rcu_sync_is_idle(&shrinker_percpu_rwsem.rss)) {
 			freed = freed ? : 1;
 			break;
 		}
+
+		rcu_read_lock();
 	}
+	rcu_read_unlock();
 
-	up_read(&shrinker_rwsem);
+	percpu_up_read(&shrinker_percpu_rwsem);
 out:
 	cond_resched();
 	return freed;
