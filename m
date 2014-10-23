Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 62B4F6B0099
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:42:13 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id gi9so962992lab.7
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:42:12 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b2si2877074lbm.104.2014.10.23.07.42.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 07:42:11 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: fold mem_cgroup_start_move()/mem_cgroup_end_move()
Date: Thu, 23 Oct 2014 10:42:07 -0400
Message-Id: <1414075327-15039-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Having these functions and their documentation split out and somewhere
makes it harder, not easier, to follow what's going on.

Inline them directly where charge moving is prepared and finished, and
put an explanation right next to it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 40 ++++++++++++----------------------------
 1 file changed, 12 insertions(+), 28 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3cd4f1e0bfb3..5b5c784dc39d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1447,32 +1447,6 @@ int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 }
 
 /*
- * memcg->moving_account is used for checking possibility that some thread is
- * calling move_account(). When a thread on CPU-A starts moving pages under
- * a memcg, other threads should check memcg->moving_account under
- * rcu_read_lock(), like this:
- *
- *         CPU-A                                    CPU-B
- *                                              rcu_read_lock()
- *         memcg->moving_account+1              if (memcg->mocing_account)
- *                                                   take heavy locks.
- *         synchronize_rcu()                    update something.
- *                                              rcu_read_unlock()
- *         start move here.
- */
-
-static void mem_cgroup_start_move(struct mem_cgroup *memcg)
-{
-	atomic_inc(&memcg->moving_account);
-	synchronize_rcu();
-}
-
-static void mem_cgroup_end_move(struct mem_cgroup *memcg)
-{
-	atomic_dec(&memcg->moving_account);
-}
-
-/*
  * A routine for checking "mem" is under move_account() or not.
  *
  * Checking a cgroup is mc.from or mc.to or under hierarchy of
@@ -5431,7 +5405,8 @@ static void mem_cgroup_clear_mc(void)
 	mc.from = NULL;
 	mc.to = NULL;
 	spin_unlock(&mc.lock);
-	mem_cgroup_end_move(from);
+
+	atomic_dec(&memcg->moving_account);
 }
 
 static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
@@ -5464,7 +5439,16 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 			VM_BUG_ON(mc.precharge);
 			VM_BUG_ON(mc.moved_charge);
 			VM_BUG_ON(mc.moved_swap);
-			mem_cgroup_start_move(from);
+
+			/*
+			 * Signal mem_cgroup_begin_page_stat() to take
+			 * the memcg's move_lock while we're moving
+			 * its pages to another memcg.  Then wait for
+			 * already started RCU-only updates to finish.
+			 */
+			atomic_inc(&memcg->moving_account);
+			synchronize_rcu();
+
 			spin_lock(&mc.lock);
 			mc.from = from;
 			mc.to = memcg;
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
