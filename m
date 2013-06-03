Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 2A7DB6B0080
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 06:19:15 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [patch -v4 6/8] memcg, vmscan: Do not attempt soft limit reclaim if it would not scan anything
Date: Mon,  3 Jun 2013 12:18:53 +0200
Message-Id: <1370254735-13012-7-git-send-email-mhocko@suse.cz>
In-Reply-To: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
References: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>

mem_cgroup_should_soft_reclaim controls whether soft reclaim pass is
done and it always says yes currently. Memcg iterators are clever to
skip nodes that are not soft reclaimable quite efficiently but
mem_cgroup_should_soft_reclaim can be more clever and do not start the
soft reclaim pass at all if it knows that nothing would be scanned
anyway.

In order to do that, simply reuse mem_cgroup_soft_reclaim_eligible for
the target group of the reclaim and allow the pass only if the whole
subtree wouldn't be skipped.

Changes since v1
- do not export mem_cgroup_root and teach mem_cgroup_soft_reclaim_eligible
  to handle NULL memcg as mem_cgroup_root

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |    6 +++++-
 mm/vmscan.c     |    4 +++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 90495d5..8ff9366 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1941,7 +1941,11 @@ enum mem_cgroup_filter_t
 mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
 		struct mem_cgroup *root)
 {
-	struct mem_cgroup *parent = memcg;
+	struct mem_cgroup *parent;
+
+	if (!memcg)
+		memcg = root_mem_cgroup;
+	parent = memcg;
 
 	if (res_counter_soft_limit_excess(&memcg->res))
 		return VISIT;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 10bcbc2..dc78f07 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -142,7 +142,9 @@ static bool global_reclaim(struct scan_control *sc)
 
 static bool mem_cgroup_should_soft_reclaim(struct scan_control *sc)
 {
-	return !mem_cgroup_disabled();
+	struct mem_cgroup *root = sc->target_mem_cgroup;
+	return !mem_cgroup_disabled() &&
+		mem_cgroup_soft_reclaim_eligible(root, root) != SKIP_TREE;
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
