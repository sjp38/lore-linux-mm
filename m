Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 78CD66B0032
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 20:44:52 -0400 (EDT)
Received: by mail-qc0-f178.google.com with SMTP id l11so2553612qcy.37
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 17:44:51 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/3] memcg: fix subtle memory barrier bug in mem_cgroup_iter()
Date: Mon,  3 Jun 2013 17:44:37 -0700
Message-Id: <1370306679-13129-2-git-send-email-tj@kernel.org>
In-Reply-To: <1370306679-13129-1-git-send-email-tj@kernel.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org, bsingharora@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com, Tejun Heo <tj@kernel.org>

mem_cgroup_iter() plays a rather delicate game to allow sharing
reclaim iteration across multiple reclaimers.  It uses
reclaim_iter->last_visited and ->dead_count to remember the last
visited cgroup and verify whether the cgroup is still safe to access.

For the mechanism to work properly, updates to ->last_visited must be
visible before ->dead_count; otherwise, a stale ->last_visited may be
considered to be associated with more recent ->dead_count and thus
escape the dead condition detection which may lead to use-after-free.

The function has smp_rmb() where the dead condition is checked and
smp_wmb() where the two variables are updated but the smp_rmb() isn't
between dereferences of the two variables making the whole thing
pointless.  It's right after atomic_read(&root->dead_count) whose only
requirement is to belong to the same RCU critical section.

This patch moves the smp_rmb() between ->last_visited and
->last_dead_count dereferences and adds comment explaining how the
barriers are paired and for what.

Let's please not add memory barriers without explicitly explaining the
pairing and what they are achieving.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 mm/memcontrol.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cb1c9de..cb2f91c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1218,9 +1218,18 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 			 * is alive.
 			 */
 			dead_count = atomic_read(&root->dead_count);
-			smp_rmb();
+
 			last_visited = iter->last_visited;
 			if (last_visited) {
+				/*
+				 * Paired with smp_wmb() below in this
+				 * function.  The pair guarantee that
+				 * last_visited is more current than
+				 * last_dead_count, which may lead to
+				 * spurious iteration resets but guarantees
+				 * reliable detection of dead condition.
+				 */
+				smp_rmb();
 				if ((dead_count != iter->last_dead_count) ||
 					!css_tryget(&last_visited->css)) {
 					last_visited = NULL;
@@ -1235,6 +1244,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				css_put(&last_visited->css);
 
 			iter->last_visited = memcg;
+			/* paired with smp_rmb() above in this function */
 			smp_wmb();
 			iter->last_dead_count = dead_count;
 
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
