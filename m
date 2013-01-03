Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id E376F6B006C
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 12:54:43 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v3 1/7] memcg: synchronize per-zone iterator access by a spinlock
Date: Thu,  3 Jan 2013 18:54:15 +0100
Message-Id: <1357235661-29564-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
References: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

per-zone per-priority iterator is aimed at coordinating concurrent
reclaimers on the same hierarchy (or the global reclaim when all
groups are reclaimed) so that all groups get reclaimed evenly as
much as possible. iter->position holds the last css->id visited
and iter->generation signals the completed tree walk (when it is
incremented).
Concurrent reclaimers are supposed to provide a reclaim cookie which
holds the reclaim priority and the last generation they saw. If cookie's
generation doesn't match the iterator's view then other concurrent
reclaimer already did the job and the tree walk is done for that
priority.

This scheme works nicely in most cases but it is not raceless. Two
racing reclaimers can see the same iter->position and so bang on the
same group. iter->generation increment is not serialized as well so a
reclaimer can see an updated iter->position with and old generation so
the iteration might be restarted from the root of the hierarchy.

The simplest way to fix this issue is to synchronise access to the
iterator by a lock. This implementation uses per-zone per-priority
spinlock which linearizes only directly racing reclaimers which use
reclaim cookies so the effect of the new locking should be really
minimal.

I have to note that I haven't seen this as a real issue so far. The
primary motivation for the change is different. The following patch
will change the way how the iterator is implemented and css->id
iteration will be replaced cgroup generic iteration which requires
storing mem_cgroup pointer into iterator and that requires reference
counting and so concurrent access will be a problem.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1ea8951..e71cfde 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -148,6 +148,8 @@ struct mem_cgroup_reclaim_iter {
 	int position;
 	/* scan generation, increased every round-trip */
 	unsigned int generation;
+	/* lock to protect the position and generation */
+	spinlock_t iter_lock;
 };
 
 /*
@@ -1161,8 +1163,11 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 
 			mz = mem_cgroup_zoneinfo(root, nid, zid);
 			iter = &mz->reclaim_iter[reclaim->priority];
-			if (prev && reclaim->generation != iter->generation)
+			spin_lock(&iter->iter_lock);
+			if (prev && reclaim->generation != iter->generation) {
+				spin_unlock(&iter->iter_lock);
 				return NULL;
+			}
 			id = iter->position;
 		}
 
@@ -1181,6 +1186,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				iter->generation++;
 			else if (!prev && memcg)
 				reclaim->generation = iter->generation;
+			spin_unlock(&iter->iter_lock);
 		}
 
 		if (prev && !css)
@@ -6051,8 +6057,12 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 		return 1;
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
+		int prio;
+
 		mz = &pn->zoneinfo[zone];
 		lruvec_init(&mz->lruvec);
+		for (prio = 0; prio < DEF_PRIORITY + 1; prio++)
+			spin_lock_init(&mz->reclaim_iter[prio].iter_lock);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->memcg = memcg;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
