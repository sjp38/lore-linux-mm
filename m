Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6706B003B
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 15:55:05 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id cc10so4700109wib.6
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:55:04 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id z17si9851927wiv.4.2014.06.16.12.55.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 12:55:04 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 02/12] mm: memcontrol: rearrange charging fast path
Date: Mon, 16 Jun 2014 15:54:22 -0400
Message-Id: <1402948472-8175-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The charging path currently starts out with OOM condition checks when
OOM is the rarest possible case.

Rearrange this code to run OOM/task dying checks only after trying the
percpu charge and the res_counter charge and bail out before entering
reclaim.  Attempting a charge does not hurt an (oom-)killed task as
much as every charge attempt having to check OOM conditions.  Also,
only check __GFP_NOFAIL when the charge would actually fail.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 94531df14d37..e946f7439b16 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2575,22 +2575,6 @@ static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
 
 	if (mem_cgroup_is_root(memcg))
 		goto done;
-	/*
-	 * Unlike in global OOM situations, memcg is not in a physical
-	 * memory shortage.  Allow dying and OOM-killed tasks to
-	 * bypass the last charges so that they can exit quickly and
-	 * free their memory.
-	 */
-	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
-		     fatal_signal_pending(current) ||
-		     current->flags & PF_EXITING))
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
@@ -2612,6 +2596,20 @@ retry:
 		goto retry;
 	}
 
+	/*
+	 * Unlike in global OOM situations, memcg is not in a physical
+	 * memory shortage.  Allow dying and OOM-killed tasks to
+	 * bypass the last charges so that they can exit quickly and
+	 * free their memory.
+	 */
+	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
+		     fatal_signal_pending(current) ||
+		     current->flags & PF_EXITING))
+		goto bypass;
+
+	if (unlikely(task_in_memcg_oom(current)))
+		goto nomem;
+
 	if (!(gfp_mask & __GFP_WAIT))
 		goto nomem;
 
@@ -2640,6 +2638,9 @@ retry:
 	if (mem_cgroup_wait_acct_move(mem_over_limit))
 		goto retry;
 
+	if (gfp_mask & __GFP_NOFAIL)
+		goto bypass;
+
 	if (fatal_signal_pending(current))
 		goto bypass;
 
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
