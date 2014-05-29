Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id C957E6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 12:16:24 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hi2so5380813wib.2
        for <linux-mm@kvack.org>; Thu, 29 May 2014 09:16:24 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id f2si2287448wjx.79.2014.05.29.09.16.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 29 May 2014 09:16:23 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 02/10] mm: memcontrol: rearrange charging fast path
Date: Thu, 29 May 2014 12:15:54 -0400
Message-Id: <1401380162-24121-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1401380162-24121-1-git-send-email-hannes@cmpxchg.org>
References: <1401380162-24121-1-git-send-email-hannes@cmpxchg.org>
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
---
 mm/memcontrol.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c3c10ab98355..46b3e37542ad 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2576,22 +2576,6 @@ static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
 
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
@@ -2613,6 +2597,20 @@ retry:
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
 
@@ -2641,6 +2639,9 @@ retry:
 	if (mem_cgroup_wait_acct_move(mem_over_limit))
 		goto retry;
 
+	if (gfp_mask & __GFP_NOFAIL)
+		goto bypass;
+
 	if (fatal_signal_pending(current))
 		goto bypass;
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
