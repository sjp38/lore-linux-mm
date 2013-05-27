Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id DC60D6B0036
	for <linux-mm@kvack.org>; Mon, 27 May 2013 13:13:39 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 2/3] memcg, vmscan: Do not attempt soft limit reclaim if it would not scan anything
Date: Mon, 27 May 2013 19:13:10 +0200
Message-Id: <1369674791-13861-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1369674791-13861-1-git-send-email-mhocko@suse.cz>
References: <20130517160247.GA10023@cmpxchg.org>
 <1369674791-13861-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

mem_cgroup_should_soft_reclaim controls whether soft reclaim pass is
done and it always says yes currently. Memcg iterators are clever to
skip nodes that are not soft reclaimable quite efficiently but
mem_cgroup_should_soft_reclaim can be more clever and do not start the
soft reclaim pass at all if it knows that nothing would be scanned
anyway.

In order to do that, simply reuse mem_cgroup_soft_reclaim_eligible for
the target group of the reclaim and allow the pass only if the whole
subtree wouldn't be skipped.

TODO - should mem_cgroup_soft_reclaim_eligible check for NULL root/memcg
so that we do not export root_mem_cgroup?

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h |    2 ++
 mm/memcontrol.c            |    2 +-
 mm/vmscan.c                |    5 ++++-
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 811967a..909bb6b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -51,6 +51,8 @@ typedef enum mem_cgroup_filter_t
 (*mem_cgroup_iter_filter)(struct mem_cgroup *memcg, struct mem_cgroup *root);
 
 #ifdef CONFIG_MEMCG
+extern struct mem_cgroup *root_mem_cgroup;
+
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
  * (gfp_mask & GFP_RECLAIM_MASK). In current implementatin, memcg doesn't
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 60b48bc..592df10 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -66,7 +66,7 @@ struct cgroup_subsys mem_cgroup_subsys __read_mostly;
 EXPORT_SYMBOL(mem_cgroup_subsys);
 
 #define MEM_CGROUP_RECLAIM_RETRIES	5
-static struct mem_cgroup *root_mem_cgroup __read_mostly;
+struct mem_cgroup *root_mem_cgroup __read_mostly;
 
 #ifdef CONFIG_MEMCG_SWAP
 /* Turned on only when memory cgroup is enabled && really_do_swap_account = 1 */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 49878dd..22c1278 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -142,7 +142,10 @@ static bool global_reclaim(struct scan_control *sc)
 
 static bool mem_cgroup_should_soft_reclaim(struct scan_control *sc)
 {
-	return true;
+	struct mem_cgroup *root = sc->target_mem_cgroup;
+	if (!root)
+		root = root_mem_cgroup;
+	return mem_cgroup_soft_reclaim_eligible(root, root) != SKIP_TREE;
 }
 #else
 static bool global_reclaim(struct scan_control *sc)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
