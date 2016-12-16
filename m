Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 74F166B026F
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:58:24 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a20so9166419wme.5
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:58:24 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id t126si3867665wmg.88.2016.12.16.07.58.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 07:58:23 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id he10so15230225wjc.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:58:23 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm: consolidate GFP_NOFAIL checks in the allocator slowpath
Date: Fri, 16 Dec 2016 16:58:07 +0100
Message-Id: <20161216155808.12809-2-mhocko@kernel.org>
In-Reply-To: <20161216155808.12809-1-mhocko@kernel.org>
References: <20161216073941.GA26976@dhcp22.suse.cz>
 <20161216155808.12809-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nils Holland <nholland@tisys.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo Handa has pointed out that 0a0337e0d1d1 ("mm, oom: rework oom
detection") has subtly changed semantic for costly high order requests
with __GFP_NOFAIL and withtout __GFP_REPEAT and those can fail right now.
My code inspection didn't reveal any such users in the tree but it is
true that this might lead to unexpected allocation failures and
subsequent OOPs.

__alloc_pages_slowpath wrt. GFP_NOFAIL is hard to follow currently.
There are few special cases but we are lacking a catch all place to be
sure we will not miss any case where the non failing allocation might
fail. This patch reorganizes the code a bit and puts all those special
cases under nopage label which is the generic go-to-fail path. Non
failing allocations are retried or those that cannot retry like
non-sleeping allocation go to the failure point directly. This should
make the code flow much easier to follow and make it less error prone
for future changes.

While we are there we have to move the stall check up to catch
potentially looping non-failing allocations.

Changes since v1
- do not skip direct reclaim for TIF_MEMDIE && GFP_NOFAIL as per Hillf
- do not skip __alloc_pages_may_oom for TIF_MEMDIE && GFP_NOFAIL as
  per Tetsuo

Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---
 mm/page_alloc.c | 75 +++++++++++++++++++++++++++++++++------------------------
 1 file changed, 44 insertions(+), 31 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3f2c9e535f7f..095e2fa286de 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3640,35 +3640,21 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto got_pg;
 
 	/* Caller is not willing to reclaim, we can't balance anything */
-	if (!can_direct_reclaim) {
-		/*
-		 * All existing users of the __GFP_NOFAIL are blockable, so warn
-		 * of any new users that actually allow this type of allocation
-		 * to fail.
-		 */
-		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
+	if (!can_direct_reclaim)
 		goto nopage;
-	}
 
-	/* Avoid recursion of direct reclaim */
-	if (current->flags & PF_MEMALLOC) {
-		/*
-		 * __GFP_NOFAIL request from this context is rather bizarre
-		 * because we cannot reclaim anything and only can loop waiting
-		 * for somebody to do a work for us.
-		 */
-		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
-			cond_resched();
-			goto retry;
-		}
-		goto nopage;
+	/* Make sure we know about allocations which stall for too long */
+	if (time_after(jiffies, alloc_start + stall_timeout)) {
+		warn_alloc(gfp_mask,
+			"page alloction stalls for %ums, order:%u",
+			jiffies_to_msecs(jiffies-alloc_start), order);
+		stall_timeout += 10 * HZ;
 	}
 
-	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
+	/* Avoid recursion of direct reclaim */
+	if (current->flags & PF_MEMALLOC)
 		goto nopage;
 
-
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
 							&did_some_progress);
@@ -3692,14 +3678,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
 		goto nopage;
 
-	/* Make sure we know about allocations which stall for too long */
-	if (time_after(jiffies, alloc_start + stall_timeout)) {
-		warn_alloc(gfp_mask,
-			"page allocation stalls for %ums, order:%u",
-			jiffies_to_msecs(jiffies-alloc_start), order);
-		stall_timeout += 10 * HZ;
-	}
-
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
 				 did_some_progress > 0, &no_progress_loops))
 		goto retry;
@@ -3721,6 +3699,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (page)
 		goto got_pg;
 
+	/* Avoid allocations with no watermarks from looping endlessly */
+	if (test_thread_flag(TIF_MEMDIE))
+		goto nopage;
+
 	/* Retry as long as the OOM killer is making progress */
 	if (did_some_progress) {
 		no_progress_loops = 0;
@@ -3728,6 +3710,37 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	}
 
 nopage:
+	/*
+	 * Make sure that __GFP_NOFAIL request doesn't leak out and make sure
+	 * we always retry
+	 */
+	if (gfp_mask & __GFP_NOFAIL) {
+		/*
+		 * All existing users of the __GFP_NOFAIL are blockable, so warn
+		 * of any new users that actually require GFP_NOWAIT
+		 */
+		if (WARN_ON_ONCE(!can_direct_reclaim))
+			goto fail;
+
+		/*
+		 * PF_MEMALLOC request from this context is rather bizarre
+		 * because we cannot reclaim anything and only can loop waiting
+		 * for somebody to do a work for us
+		 */
+		WARN_ON_ONCE(current->flags & PF_MEMALLOC);
+
+		/*
+		 * non failing costly orders are a hard requirement which we
+		 * are not prepared for much so let's warn about these users
+		 * so that we can identify them and convert them to something
+		 * else.
+		 */
+		WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
+
+		cond_resched();
+		goto retry;
+	}
+fail:
 	warn_alloc(gfp_mask,
 			"page allocation failure: order:%u", order);
 got_pg:
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
