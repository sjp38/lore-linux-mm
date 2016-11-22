Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DACA6B025E
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 01:29:41 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g23so3085153wme.4
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 22:29:41 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id m9si23932123wjr.174.2016.11.21.22.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 22:29:40 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id m203so1266171wma.3
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 22:29:40 -0800 (PST)
Date: Tue, 22 Nov 2016 07:29:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Don't fail costly __GFP_NOFAIL
 allocations.
Message-ID: <20161122062936.GA4829@dhcp22.suse.cz>
References: <1479387004-5998-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20161121060313.GB29816@dhcp22.suse.cz>
 <201611212016.GGG52176.LSOVtOHJFMQFFO@I-love.SAKURA.ne.jp>
 <20161121125431.GA18112@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161121125431.GA18112@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, stable@vger.kernel.org

On Mon 21-11-16 13:54:31, Michal Hocko wrote:
> On Mon 21-11-16 20:16:40, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Thu 17-11-16 21:50:04, Tetsuo Handa wrote:
> > > > Filesystem code might request costly __GFP_NOFAIL !__GFP_REPEAT GFP_NOFS
> > > > allocations. But commit 0a0337e0d1d13446 ("mm, oom: rework oom detection")
> > > > overlooked that __GFP_NOFAIL allocation requests need to invoke the OOM
> > > > killer and retry even if order > PAGE_ALLOC_COSTLY_ORDER && !__GFP_REPEAT.
> > > > The caller will crash if such allocation request failed.
> > >
> > > Could you point to such an allocation request please? Costly GFP_NOFAIL
> > > requests are a really high requirement and I am even not sure we should
> > > support them. buffered_rmqueue already warns about order > 1 NOFAIL
> > > allocations.
> > 
> > That question is pointless. You are simply lucky that you see only order 0 or
> > order 1. There are many __GFP_NOFAIL allocations where order is determined at
> > runtime. There is no guarantee that order 2 and above never happens.
> 
> You are pushing to the extreme again! Your changelog stated this might
> be an existing and the real life problem and that is the reason I've
> asked. Especially because you have marked the patch for stable. As I've
> said in my previous response. Your patch looks correct, I am just not
> entirely happy to clutter the code path even more for GFP_NOFAIL for
> something we maybe even do not support. All the checks we have there are
> head spinning already.
> 
> So we have two options, either we have real users of GFP_NOFAIL for
> costly orders and handle that properly with all that information in the
> changelog or simply rely on the warning and fix callers who do that
> accidentally. But please stop this, theoretically something might do
> $THIS_RANDOM_GFP_FLAGS + order combination and we absolutely must handle
> that in the allocator.

So if we really want to pretend to support GFP_NOFAIL + costly order,
and I still do not see any real user in the kernel but I can imagine
that some of the opencoded endless loops around allocator might
eventually become GFP_NOFAIL so there is some merit to be prepared for
that. So this is something I've ended up with (no compilation testing
yet because my gcc decided to not cooperate and fail with
kernel/bounds.c:1:0: error: code model kernel does not support PIC mode)

Anyway the intention should be pretty clear from the diff
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f62860e6dfb9..8170ee8765b7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3627,26 +3626,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto got_pg;
 
 	/* Caller is not willing to reclaim, we can't balance anything */
-	if (!can_direct_reclaim) {
-		/*
-		 * All existing users of the __GFP_NOFAIL are blockable, so warn
-		 * of any new users that actually allow this type of allocation
-		 * to fail.
-		 */
-		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
-		goto fail;
-	}
+	if (!can_direct_reclaim)
+		goto nopage;
 
 	/* Avoid recursion of direct reclaim */
-	if (current->flags & PF_MEMALLOC) {
-		/*
-		 * __GFP_NOFAIL request from this context is rather bizarre
-		 * because we cannot reclaim anything and only can loop waiting
-		 * for somebody to do a work for us.
-		 */
-		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
+	if (current->flags & PF_MEMALLOC)
 		goto nopage;
-	}
 
 	/* Avoid allocations with no watermarks from looping endlessly */
 	if (test_thread_flag(TIF_MEMDIE))
@@ -3717,6 +3702,28 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * we always retry
 	 */
 	if (gfp_mask & __GFP_NOFAIL) {
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
 		cond_resched();
 		goto retry;
 	}

I would even go one step further and do the following because, honestly,
I never liked GFP_NOFAIL having OOM side effects.

@@ -3078,32 +3078,31 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
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
 	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
 		*did_some_progress = 1;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
