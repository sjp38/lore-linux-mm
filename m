Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 163EE6B0317
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 17:56:52 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o68so48990826pfj.20
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 14:56:52 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id x3si7261036plb.1.2017.04.28.14.56.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 14:56:51 -0700 (PDT)
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: [PATCH 2/2] mm/memcontrol: inc reclaim gen if restarting walk in mem_cgroup_iter()
Date: Fri, 28 Apr 2017 14:55:47 -0700
Message-Id: <1493416547-19212-3-git-send-email-sean.j.christopherson@intel.com>
In-Reply-To: <1493416547-19212-1-git-send-email-sean.j.christopherson@intel.com>
References: <1493416547-19212-1-git-send-email-sean.j.christopherson@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, sean.j.christopherson@intel.com

Increment iter->generation if a reclaimer reaches the end of the tree,
even if it restarts the hierarchy walk instead of returning NULL, i.e.
this is the reclaimer's initial call to mem_cgroup_iter().  If we don't
increment the generation, other threads that are part of the current
reclaim generation will incorrectly continue to walk the tree since
iter->generation won't be updated until one of the reclaimers reaches
the end of the hierarchy a second time.

Move the put_css(&pos->css) call below the iter->generation update
to minimize the window where a thread can see a stale generation but
consume an updated position, as iter->generation and iter->position
are not updated atomically.

Signed-off-by: Sean Christopherson <sean.j.christopherson@intel.com>
---
 mm/memcontrol.c | 31 ++++++++++++++++++++++++++-----
 1 file changed, 26 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6a7ca3c..b858245 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -740,6 +740,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 	struct cgroup_subsys_state *css = NULL;
 	struct mem_cgroup *memcg = NULL;
 	struct mem_cgroup *pos = NULL;
+	bool inc_gen = false;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -791,6 +792,14 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		css = css_next_descendant_pre(css, &root->css);
 		if (!css) {
 			/*
+			 * Increment the generation as the next call to
+			 * css_next_descendant_pre will restart at root.
+			 * Do not update iter->generation directly as we
+			 * should only do so if we update iter->position.
+			 */
+			inc_gen = true;
+
+			/*
 			 * Reclaimers share the hierarchy walk, and a
 			 * new one might jump in right at the end of
 			 * the hierarchy - make sure they see at least
@@ -838,16 +847,28 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				css_put(&pos->css);
 			css = NULL;
 			memcg = NULL;
+			inc_gen = false;
 			goto start;
 		}
 
-		if (pos)
-			css_put(&pos->css);
-
-		if (!memcg)
+		/*
+		 * Update iter->generation asap to minimize the window where
+		 * a different thread compares against a stale generation but
+		 * consumes an updated position.
+		 */
+		if (inc_gen)
 			iter->generation++;
-		else if (!prev)
+
+		/*
+		 * Initialize the reclaimer's generation after the potential
+		 * update to iter->generation; if we restarted the hierarchy
+		 * walk then we are part of the new generation.
+		 */
+		if (!prev)
 			reclaim->generation = iter->generation;
+
+		if (pos)
+			css_put(&pos->css);
 	}
 
 out_unlock:
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
