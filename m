Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 546DB6B0037
	for <linux-mm@kvack.org>; Mon, 27 May 2013 13:13:41 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 3/3] memcg: Track all children over limit in the root
Date: Mon, 27 May 2013 19:13:11 +0200
Message-Id: <1369674791-13861-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1369674791-13861-1-git-send-email-mhocko@suse.cz>
References: <20130517160247.GA10023@cmpxchg.org>
 <1369674791-13861-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Children in soft limit excess are currently tracked up the hierarchy
in memcg->children_in_excess. Nevertheless there still might exist
tons of groups that are not in hierarchy relation to the root cgroup
(e.g. all first level groups if root_mem_cgroup->use_hierarchy ==
false).

As the whole tree walk has to be done when the iteration starts at
root_mem_cgroup the iterator should be able to skip the walk if there
is no child above the limit without iterating them. This can be done
easily if the root tracks all children rather than only hierarchical
children. This is done by this patch which updates root_mem_cgroup
children_in_excess if root_mem_cgroup->use_hierarchy == false so the
root knows about all children in excess.

Please note that this is not an issue for inner memcgs which have
use_hierarchy == false because then only the single group is visited so
no special optimization is necessary.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 592df10..7fb063f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -932,9 +932,15 @@ static void mem_cgroup_update_soft_limit(struct mem_cgroup *memcg)
 	/*
 	 * Necessary to update all ancestors when hierarchy is used
 	 * because their event counter is not touched.
+	 * We track children even outside the hierarchy for the root
+	 * cgroup because tree walk starting at root should visit
+	 * all cgroups and we want to prevent from pointless tree
+	 * walk if no children is below the limit.
 	 */
 	while (delta && (parent = parent_mem_cgroup(parent)))
 		atomic_add(delta, &parent->children_in_excess);
+	if (memcg != root_mem_cgroup && !root_mem_cgroup->use_hierarchy)
+		atomic_add(delta, &root_mem_cgroup->children_in_excess);
 	spin_unlock(&memcg->soft_lock);
 }
 
@@ -6200,6 +6206,9 @@ static void mem_cgroup_css_offline(struct cgroup *cont)
 	if (memcg->soft_contributed) {
 		while ((memcg = parent_mem_cgroup(memcg)))
 			atomic_dec(&memcg->children_in_excess);
+
+		if (memcg != root_mem_cgroup && !root_mem_cgroup->use_hierarchy)
+			atomic_dec(&root_mem_cgroup->children_in_excess);
 	}
 	mem_cgroup_destroy_all_caches(memcg);
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
