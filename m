Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 177E16B003C
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 17:13:26 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id d49so9223665eek.41
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 14:13:26 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id w48si31952621eel.266.2014.04.16.14.13.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 14:13:25 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: remove hierarchy restrictions for swappiness and oom_control
Date: Wed, 16 Apr 2014 17:13:18 -0400
Message-Id: <1397682798-22906-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Per-memcg swappiness and oom killing can currently not be tweaked on a
memcg that is part of a hierarchy, but not the root of that hierarchy.
Users have complained that they can't configure this when they turned
on hierarchy mode.  In fact, with hierarchy mode becoming the default,
this restriction disables the tunables entirely.

But there is no good reason for this restriction.  The settings for
swappiness and OOM killing are taken from whatever memcg whose limit
triggered reclaim and OOM invocation, regardless of its position in
the hierarchy tree.

Allow setting swappiness on any group.  The knob on the root memcg
already reads the global VM swappiness, make it writable as well.

Allow disabling the OOM killer on any non-root memcg.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 29 +++++++----------------------
 1 file changed, 7 insertions(+), 22 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e2a0d3986c74..edcc9513b419 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5548,22 +5548,14 @@ static int mem_cgroup_swappiness_write(struct cgroup_subsys_state *css,
 				       struct cftype *cft, u64 val)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
-	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(&memcg->css));
 
-	if (val > 100 || !parent)
+	if (val > 100)
 		return -EINVAL;
 
-	mutex_lock(&memcg_create_mutex);
-
-	/* If under hierarchy, only empty-root can set this value */
-	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
-		mutex_unlock(&memcg_create_mutex);
-		return -EINVAL;
-	}
-
-	memcg->swappiness = val;
-
-	mutex_unlock(&memcg_create_mutex);
+	if (css_parent(css))
+		memcg->swappiness = val;
+	else
+		vm_swappiness = val;
 
 	return 0;
 }
@@ -5895,22 +5887,15 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
 	struct cftype *cft, u64 val)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
-	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(&memcg->css));
 
 	/* cannot set to root cgroup and only 0 and 1 are allowed */
-	if (!parent || !((val == 0) || (val == 1)))
+	if (!css_parent(css) || !((val == 0) || (val == 1)))
 		return -EINVAL;
 
-	mutex_lock(&memcg_create_mutex);
-	/* oom-kill-disable is a flag for subhierarchy. */
-	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
-		mutex_unlock(&memcg_create_mutex);
-		return -EINVAL;
-	}
 	memcg->oom_kill_disable = val;
 	if (!val)
 		memcg_oom_recover(memcg);
-	mutex_unlock(&memcg_create_mutex);
+
 	return 0;
 }
 
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
