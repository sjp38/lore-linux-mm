Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71BDC6B0007
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 16:26:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e14so8696973pfi.9
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 13:26:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q13sor2233692pfi.105.2018.04.22.13.26.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 13:26:49 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [RFC PATCH 1/2] memcg: fix memory.low
Date: Sun, 22 Apr 2018 13:26:11 -0700
Message-Id: <20180422202612.127760-2-gthelen@google.com>
In-Reply-To: <20180422202612.127760-1-gthelen@google.com>
References: <20180320223353.5673-1-guro@fb.com>
 <20180422202612.127760-1-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: guro@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Cgroups <cgroups@vger.kernel.org>, kernel-team@fb.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>

When targeting reclaim to a memcg, protect that memcg from reclaim is
memory consumption of any level is below respective memory.low.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 670e99b68aa6..9668f620203a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5341,8 +5341,8 @@ struct cgroup_subsys memory_cgrp_subsys = {
  * @root: the top ancestor of the sub-tree being checked
  * @memcg: the memory cgroup to check
  *
- * Returns %true if memory consumption of @memcg, and that of all
- * ancestors up to (but not including) @root, is below the normal range.
+ * Returns %true if memory consumption of @memcg, or any of its ancestors
+ * up to (but not including) @root, is below the normal range.
  *
  * @root is exclusive; it is never low when looked at directly and isn't
  * checked when traversing the hierarchy.
@@ -5379,12 +5379,12 @@ bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
 	if (memcg == root)
 		return false;
 
+	/* If any level is under, then protect @memcg from reclaim */
 	for (; memcg != root; memcg = parent_mem_cgroup(memcg)) {
-		if (page_counter_read(&memcg->memory) >= memcg->low)
-			return false;
+		if (page_counter_read(&memcg->memory) <= memcg->low)
+			return true; /* protect from reclaim */
 	}
-
-	return true;
+	return false; /* not protected from reclaim */
 }
 
 /**
-- 
2.17.0.484.g0c8726318c-goog
