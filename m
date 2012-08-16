Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id EC1666B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 07:04:47 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2] memcg: execute partial memcg freeing in mem_cgroup_destroy
Date: Thu, 16 Aug 2012 15:01:43 +0400
Message-Id: <1345114903-20627-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>

A lot of the initialization we do in mem_cgroup_create() is done with
softirqs enabled. This include grabbing a css id, which holds
&ss->id_lock->rlock, and the per-zone trees, which holds
rtpz->lock->rlock. All of those signal to the lockdep mechanism that
those locks can be used in SOFTIRQ-ON-W context. This means that the
freeing of memcg structure must happen in a compatible context,
otherwise we'll get a deadlock.

The reference counting mechanism we use allows the memcg structure to be
freed later and outlive the actual memcg destruction from the
filesystem. However, we have little, if any, means to guarantee in which
context the last memcg_put will happen. The best we can do is test it
and try to make sure no invalid context releases are happening. But as
we add more code to memcg, the possible interactions grow in number and
expose more ways to get context conflicts.

Greg Thelen reported a bug with that patchset applied that would trigger
if a task would hold a reference to a memcg through its kmem counter.
This would mean that killing that task would eventually get us to
__mem_cgroup_free() after dropping the last kernel page reference, in an
invalid IN-SOFTIRQ-W.

Besides that, he raised the quite valid concern that keeping the full
memcg around for an unbounded period of time can eventually exhaust the
css_id space, and pin a lot of not needed memory. For instance, a
O(nr_cpus) percpu data for the stats is kept around, and we don't expect
to use it after the memcg is gone.

Both those problems can be avoided by freeing as much as we can in
mem_cgroup_destroy(), and leaving only the memcg structure and the
static branches to be removed later. That freeing run on a predictable
context, getting rid of the softirq problem, and also reduces pressure
both on the css_id space and total dangling memory.

I consider this safe because all the page_cgroup references to user
pages are reparented to the imediate parent, so late uncharges won't
trigger the common uncharge paths with a destroyed memcg.

Although we don't migrate kernel pages to parent, we also don't call the
common uncharge paths for those pages, rather uncharging the
res_counters directly. So we are safe on this side of the wall as well.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Reported-by: Greg Thelen <gthelen@google.com>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9a82965..78cb394 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5169,18 +5169,9 @@ static void free_work(struct work_struct *work)
 		vfree(memcg);
 }
 
-static void free_rcu(struct rcu_head *rcu_head)
-{
-	struct mem_cgroup *memcg;
-
-	memcg = container_of(rcu_head, struct mem_cgroup, rcu_freeing);
-	INIT_WORK(&memcg->work_freeing, free_work);
-	schedule_work(&memcg->work_freeing);
-}
-
 /*
- * At destroying mem_cgroup, references from swap_cgroup can remain.
- * (scanning all at force_empty is too costly...)
+ * At destroying mem_cgroup, references from swap_cgroup and other places can
+ * remain.  (scanning all at force_empty is too costly...)
  *
  * Instead of clearing all references at force_empty, we remember
  * the number of reference from swap_cgroup and free mem_cgroup when
@@ -5188,6 +5179,14 @@ static void free_rcu(struct rcu_head *rcu_head)
  *
  * Removal of cgroup itself succeeds regardless of refs from swap.
  */
+static void free_rcu(struct rcu_head *rcu_head)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = container_of(rcu_head, struct mem_cgroup, rcu_freeing);
+	INIT_WORK(&memcg->work_freeing, free_work);
+	schedule_work(&memcg->work_freeing);
+}
 
 static void __mem_cgroup_free(struct mem_cgroup *memcg)
 {
@@ -5200,7 +5199,6 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 		free_mem_cgroup_per_zone_info(memcg, node);
 
 	free_percpu(memcg->stat);
-	call_rcu(&memcg->rcu_freeing, free_rcu);
 }
 
 static void mem_cgroup_get(struct mem_cgroup *memcg)
@@ -5212,7 +5210,7 @@ static void __mem_cgroup_put(struct mem_cgroup *memcg, int count)
 {
 	if (atomic_sub_and_test(count, &memcg->refcnt)) {
 		struct mem_cgroup *parent = parent_mem_cgroup(memcg);
-		__mem_cgroup_free(memcg);
+		call_rcu(&memcg->rcu_freeing, free_rcu);
 		if (parent)
 			mem_cgroup_put(parent);
 	}
@@ -5377,6 +5375,7 @@ static void mem_cgroup_destroy(struct cgroup *cont)
 
 	kmem_cgroup_destroy(memcg);
 
+	__mem_cgroup_free(memcg);
 	mem_cgroup_put(memcg);
 }
 
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
