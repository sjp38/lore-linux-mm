Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5636B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:56:05 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id rd3so5449912pab.20
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 08:56:05 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id kw1si8205830pab.195.2014.10.20.08.56.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 08:56:04 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] memcg: simplify unreclaimable groups handling in soft limit reclaim
Date: Mon, 20 Oct 2014 19:55:54 +0400
Message-ID: <1413820554-15611-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If we fail to reclaim anything from a cgroup during a soft reclaim pass
we want to get the next largest cgroup exceeding its soft limit. To
achieve this, we should obviously remove the current group from the tree
and then pick the largest group. Currently we have a weird loop instead.
Let's simplify it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |   26 ++++----------------------
 1 file changed, 4 insertions(+), 22 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e957f0c80c6e..53393e27ff03 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3507,34 +3507,16 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 		nr_reclaimed += reclaimed;
 		*total_scanned += nr_scanned;
 		spin_lock_irq(&mctz->lock);
+		__mem_cgroup_remove_exceeded(mz, mctz);
 
 		/*
 		 * If we failed to reclaim anything from this memory cgroup
 		 * it is time to move on to the next cgroup
 		 */
 		next_mz = NULL;
-		if (!reclaimed) {
-			do {
-				/*
-				 * Loop until we find yet another one.
-				 *
-				 * By the time we get the soft_limit lock
-				 * again, someone might have aded the
-				 * group back on the RB tree. Iterate to
-				 * make sure we get a different mem.
-				 * mem_cgroup_largest_soft_limit_node returns
-				 * NULL if no other cgroup is present on
-				 * the tree
-				 */
-				next_mz =
-				__mem_cgroup_largest_soft_limit_node(mctz);
-				if (next_mz == mz)
-					css_put(&next_mz->memcg->css);
-				else /* next_mz == NULL or other memcg */
-					break;
-			} while (1);
-		}
-		__mem_cgroup_remove_exceeded(mz, mctz);
+		if (!reclaimed)
+			next_mz = __mem_cgroup_largest_soft_limit_node(mctz);
+
 		excess = soft_limit_excess(mz->memcg);
 		/*
 		 * One school of thought says that we should not add
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
