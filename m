Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88EE26B0267
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:49:38 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so2441019wms.7
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 22:49:38 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id qa4si29681755wjc.238.2016.11.22.22.49.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 22:49:37 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id jb2so310933wjb.3
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 22:49:37 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL automatically
Date: Wed, 23 Nov 2016 07:49:25 +0100
Message-Id: <20161123064925.9716-3-mhocko@kernel.org>
In-Reply-To: <20161123064925.9716-1-mhocko@kernel.org>
References: <20161123064925.9716-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__alloc_pages_may_oom makes sure to skip the OOM killer depending on
the allocation request. This includes lowmem requests, costly high
order requests and others. For a long time __GFP_NOFAIL acted as an
override for all those rules. This is not documented and it can be quite
surprising as well. E.g. GFP_NOFS requests are not invoking the OOM
killer but GFP_NOFS|__GFP_NOFAIL does so if we try to convert some of
the existing open coded loops around allocator to nofail request (and we
have done that in the past) then such a change would have a non trivial
side effect which is not obvious. Note that the primary motivation for
skipping the OOM killer is to prevent from pre-mature invocation.

The exception has been added by 82553a937f12 ("oom: invoke oom killer
for __GFP_NOFAIL"). The changelog points out that the oom killer has to
be invoked otherwise the request would be looping for ever. But this
argument is rather weak because the OOM killer doesn't really guarantee
any forward progress for those exceptional cases - e.g. it will hardly
help to form costly order - I believe we certainly do not want to kill
all processes and eventually panic the system just because there is a
nasty driver asking for order-9 page with GFP_NOFAIL not realizing all
the consequences - it is much better this request would loop for ever
than the massive system disruption, lowmem is also highly unlikely to be
freed during OOM killer and GFP_NOFS request could trigger while there
is still a lot of memory pinned by filesystems.

This patch simply removes the __GFP_NOFAIL special case in order to have
a more clear semantic without surprising side effects. Instead we do
allow nofail requests to access memory reserves to move forward in both
cases when the OOM killer is invoked and when it should be supressed.
__alloc_pages_nowmark helper has been introduced for that purpose.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c   |  2 +-
 mm/page_alloc.c | 95 +++++++++++++++++++++++++++++++++++----------------------
 2 files changed, 59 insertions(+), 38 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ec9f11d4f094..12a6fce85f61 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1013,7 +1013,7 @@ bool out_of_memory(struct oom_control *oc)
 	 * make sure exclude 0 mask - all other users should have at least
 	 * ___GFP_DIRECT_RECLAIM to get here.
 	 */
-	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
+	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
 		return true;
 
 	/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 76c0b6bb0baf..7102641147c4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3044,6 +3044,25 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 }
 
 static inline struct page *
+__alloc_pages_nowmark(gfp_t gfp_mask, unsigned int order,
+						const struct alloc_context *ac)
+{
+	struct page *page;
+
+	page = get_page_from_freelist(gfp_mask, order,
+			ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
+	/*
+	 * fallback to ignore cpuset restriction if our nodes
+	 * are depleted
+	 */
+	if (!page)
+		page = get_page_from_freelist(gfp_mask, order,
+				ALLOC_NO_WATERMARKS, ac);
+
+	return page;
+}
+
+static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	const struct alloc_context *ac, unsigned long *did_some_progress)
 {
@@ -3078,47 +3097,41 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	if (page)
 		goto out;
 
-	if (!(gfp_mask & __GFP_NOFAIL)) {
-		/* Coredumps can quickly deplete all memory reserves */
-		if (current->flags & PF_DUMPCORE)
-			goto out;
-		/* The OOM killer will not help higher order allocs */
-		if (order > PAGE_ALLOC_COSTLY_ORDER)
-			goto out;
-		/* The OOM killer does not needlessly kill tasks for lowmem */
-		if (ac->high_zoneidx < ZONE_NORMAL)
-			goto out;
-		if (pm_suspended_storage())
-			goto out;
-		/*
-		 * XXX: GFP_NOFS allocations should rather fail than rely on
-		 * other request to make a forward progress.
-		 * We are in an unfortunate situation where out_of_memory cannot
-		 * do much for this context but let's try it to at least get
-		 * access to memory reserved if the current task is killed (see
-		 * out_of_memory). Once filesystems are ready to handle allocation
-		 * failures more gracefully we should just bail out here.
-		 */
+	/* Coredumps can quickly deplete all memory reserves */
+	if (current->flags & PF_DUMPCORE)
+		goto out;
+	/* The OOM killer will not help higher order allocs */
+	if (order > PAGE_ALLOC_COSTLY_ORDER)
+		goto out;
+	/* The OOM killer does not needlessly kill tasks for lowmem */
+	if (ac->high_zoneidx < ZONE_NORMAL)
+		goto out;
+	if (pm_suspended_storage())
+		goto out;
+	/*
+	 * XXX: GFP_NOFS allocations should rather fail than rely on
+	 * other request to make a forward progress.
+	 * We are in an unfortunate situation where out_of_memory cannot
+	 * do much for this context but let's try it to at least get
+	 * access to memory reserved if the current task is killed (see
+	 * out_of_memory). Once filesystems are ready to handle allocation
+	 * failures more gracefully we should just bail out here.
+	 */
+
+	/* The OOM killer may not free memory on a specific node */
+	if (gfp_mask & __GFP_THISNODE)
+		goto out;
 
-		/* The OOM killer may not free memory on a specific node */
-		if (gfp_mask & __GFP_THISNODE)
-			goto out;
-	}
 	/* Exhausted what can be done so it's blamo time */
-	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
+	if (out_of_memory(&oc)) {
 		*did_some_progress = 1;
 
-		if (gfp_mask & __GFP_NOFAIL) {
-			page = get_page_from_freelist(gfp_mask, order,
-					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
-			/*
-			 * fallback to ignore cpuset restriction if our nodes
-			 * are depleted
-			 */
-			if (!page)
-				page = get_page_from_freelist(gfp_mask, order,
-					ALLOC_NO_WATERMARKS, ac);
-		}
+		/*
+		 * Help non-failing allocations by giving them access to memory
+		 * reserves
+		 */
+		if (gfp_mask & __GFP_NOFAIL)
+			page = __alloc_pages_nowmark(gfp_mask, order, ac);
 	}
 out:
 	mutex_unlock(&oom_lock);
@@ -3725,6 +3738,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 */
 		WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
 
+		/*
+		 * Help non-failing allocations by giving them access to memory
+		 * reserves
+		 */
+		page = __alloc_pages_nowmark(gfp_mask, order, ac);
+		if (page)
+			goto got_pg;
+
 		cond_resched();
 		goto retry;
 	}
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
