Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 371B26B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 22:31:30 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id q59so61705wes.25
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 19:31:29 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ch2si1612934wib.41.2014.09.24.19.31.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 19:31:28 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: do not iterate uninitialized memcgs
Date: Wed, 24 Sep 2014 22:31:18 -0400
Message-Id: <1411612278-4707-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The cgroup iterators yield css objects that have not yet gone through
css_online(), but they are not complete memcgs at this point and so
the memcg iterators should not return them.  d8ad30559715 ("mm/memcg:
iteration skip memcgs not yet fully initialized") set out to implement
exactly this, but it uses CSS_ONLINE, a cgroup-internal flag that does
not meet the ordering requirements for memcg, and so we still may see
partially initialized memcgs from the iterators.

The cgroup core can not reasonably provide a clear answer on whether
the object around the css has been fully initialized, as that depends
on controller-specific locking and lifetime rules.  Thus, introduce a
memcg-specific flag that is set after the memcg has been initialized
in css_online(), and read before mem_cgroup_iter() callers access the
memcg members.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@vger.kernel.org>	[3.12+]
---
 mm/memcontrol.c | 35 ++++++++++++++++++++++++++++++-----
 1 file changed, 30 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 306b6470784c..71ed15e3a148 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -292,6 +292,9 @@ struct mem_cgroup {
 	/* vmpressure notifications */
 	struct vmpressure vmpressure;
 
+	/* css_online() has been completed */
+	bool initialized;
+
 	/*
 	 * the counter to account for mem+swap usage.
 	 */
@@ -1090,10 +1093,22 @@ skip_node:
 	 * skipping css reference should be safe.
 	 */
 	if (next_css) {
-		if ((next_css == &root->css) ||
-		    ((next_css->flags & CSS_ONLINE) &&
-		     css_tryget_online(next_css)))
-			return mem_cgroup_from_css(next_css);
+		if (next_css == &root->css ||
+		    css_tryget_online(next_css)) {
+			struct mem_cgroup *memcg;
+
+			memcg = mem_cgroup_from_css(next_css);
+			if (memcg->initialized) {
+				/*
+				 * Make sure the caller's accesses to
+				 * the memcg members are issued after
+				 * we see this flag set.
+				 */
+				smp_rmb();
+				return memcg;
+			}
+			css_put(next_css);
+		}
 
 		prev_css = next_css;
 		goto skip_node;
@@ -5413,6 +5428,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup *parent = mem_cgroup_from_css(css->parent);
+	int ret;
 
 	if (css->id > MEM_CGROUP_ID_MAX)
 		return -ENOSPC;
@@ -5449,7 +5465,16 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	}
 	mutex_unlock(&memcg_create_mutex);
 
-	return memcg_init_kmem(memcg, &memory_cgrp_subsys);
+	ret = memcg_init_kmem(memcg, &memory_cgrp_subsys);
+	if (ret)
+		return ret;
+
+	/* Make sure the initialization is visible before the flag */
+	smp_wmb();
+
+	memcg->initialized = true;
+
+	return 0;
 }
 
 /*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
