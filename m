Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 28C126B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 07:59:19 -0400 (EDT)
Received: by wgme6 with SMTP id e6so112078568wgm.2
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 04:59:18 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga2si10867457wjb.135.2015.06.01.04.59.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 04:59:17 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] oom: always panic on OOM when panic_on_oom is configured
Date: Mon,  1 Jun 2015 13:59:08 +0200
Message-Id: <1433159948-9912-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

panic_on_oom allows administrator to set OOM policy to panic the system
when it is out of memory to reduce failover time e.g. when resolving
the OOM condition would take much more time than rebooting the system.

out_of_memory tries to be clever and prevent from premature panics
by checking the current task and prevent from panic when the task
has fatal signal pending and so it should die shortly and release some
memory. This is fair enough but Tetsuo Handa has noted that this might
lead to a silent deadlock when current cannot exit because of
dependencies invisible to the OOM killer.

panic_on_oom is disabled by default and if somebody enables it then any
risk of potential deadlock is certainly unwelcome. The risk is really
low because there are usually more sources of allocation requests and
one of them would eventually trigger the panic but it is better to
reduce the risk as much as possible.

Let's move check_panic_on_oom up before the current task is
checked so that the knob value is . Do the same for the memcg in
mem_cgroup_out_of_memory.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |  3 ++-
 mm/oom_kill.c   | 18 +++++++++---------
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 86648a718d21..d3c906da6a09 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1532,6 +1532,8 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 	mutex_lock(&oom_lock);
 
+	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL, memcg);
+
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
@@ -1542,7 +1544,6 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		goto unlock;
 	}
 
-	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL, memcg);
 	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dff991e0681e..f8c83b791dd5 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -667,6 +667,15 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		goto out;
 
 	/*
+	 * Check if there were limitations on the allocation (only relevant for
+	 * NUMA) that may require different handling.
+	 */
+	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
+						&totalpages);
+	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
+	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
+
+	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
@@ -680,15 +689,6 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		goto out;
 	}
 
-	/*
-	 * Check if there were limitations on the allocation (only relevant for
-	 * NUMA) that may require different handling.
-	 */
-	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
-						&totalpages);
-	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
-	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
-
 	if (sysctl_oom_kill_allocating_task && current->mm &&
 	    !oom_unkillable_task(current, NULL, nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
