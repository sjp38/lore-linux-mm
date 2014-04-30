Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 804016B0037
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 16:25:57 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so1764309eek.1
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:25:56 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id y41si32005586eel.230.2014.04.30.13.25.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 13:25:56 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/9] mm: memcontrol: rearrange charging fast path
Date: Wed, 30 Apr 2014 16:25:36 -0400
Message-Id: <1398889543-23671-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The charging path currently starts out with OOM condition checks when
OOM is the rarest possible case.

Rearrange this code to run OOM/task dying checks only after trying the
percpu charge and the res_counter charge and bail out before entering
reclaim.  Attempting a charge does not hurt an (oom-)killed task as
much as every charge attempt having to check OOM conditions.  Also,
only check __GFP_NOFAIL when the charge would actually fail.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 75dfeb8fa98b..6ce59146fec7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2598,21 +2598,6 @@ static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
 
 	if (mem_cgroup_is_root(memcg))
 		goto done;
-	/*
-	 * Unlike in global OOM situations, memcg is not in a physical
-	 * memory shortage.  Allow dying and OOM-killed tasks to
-	 * bypass the last charges so that they can exit quickly and
-	 * free their memory.
-	 */
-	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
-		     fatal_signal_pending(current)))
-		goto bypass;
-
-	if (unlikely(task_in_memcg_oom(current)))
-		goto nomem;
-
-	if (gfp_mask & __GFP_NOFAIL)
-		oom = false;
 retry:
 	if (consume_stock(memcg, nr_pages))
 		goto done;
@@ -2634,6 +2619,19 @@ retry:
 		goto retry;
 	}
 
+	/*
+	 * Unlike in global OOM situations, memcg is not in a physical
+	 * memory shortage.  Allow dying and OOM-killed tasks to
+	 * bypass the last charges so that they can exit quickly and
+	 * free their memory.
+	 */
+	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
+		     fatal_signal_pending(current)))
+		goto bypass;
+
+	if (unlikely(task_in_memcg_oom(current)))
+		goto nomem;
+
 	if (!(gfp_mask & __GFP_WAIT))
 		goto nomem;
 
@@ -2662,6 +2660,9 @@ retry:
 	if (mem_cgroup_wait_acct_move(mem_over_limit))
 		goto retry;
 
+	if (gfp_mask & __GFP_NOFAIL)
+		goto bypass;
+
 	if (fatal_signal_pending(current))
 		goto bypass;
 
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
