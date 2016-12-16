Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 20CD16B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:50:20 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so7054719wms.7
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 03:50:20 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id h70si2965463wme.114.2016.12.16.03.50.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 03:50:19 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id g23so4928445wme.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 03:50:18 -0800 (PST)
Date: Fri, 16 Dec 2016 12:50:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: consolidate GFP_NOFAIL checks in the allocator
 slowpath
Message-ID: <20161216115017.GH13940@dhcp22.suse.cz>
References: <20161214150706.27412-1-mhocko@kernel.org>
 <04b001d256a8$7bc813d0$73583b70$@alibaba-inc.com>
 <20161215102838.GA8602@dhcp22.suse.cz>
 <201612162039.EEI17197.HSFFMFOJOVQOLt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612162039.EEI17197.HSFFMFOJOVQOLt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hillf.zj@alibaba-inc.com, akpm@linux-foundation.org, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-12-16 20:39:12, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 15-12-16 15:54:37, Hillf Danton wrote:
> > > On Wednesday, December 14, 2016 11:07 PM Michal Hocko wrote: 
> > [...]
> > > >  	/* Avoid allocations with no watermarks from looping endlessly */
> > > > -	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> > > > +	if (test_thread_flag(TIF_MEMDIE))
> > > >  		goto nopage;
> > > > 
> > > Nit: currently we allow TIF_MEMDIE & __GFP_NOFAIL request to
> > > try direct reclaim. Are you intentionally reclaiming that chance?
> > 
> > That is definitely not a nit! Thanks for catching that. We definitely
> > shouldn't bypass the direct reclaim because that would mean we rely on
> > somebody else makes progress for us.
> > 
> > Updated patch below:
> > --- 
> > From cebd2d933f245a59504fdce31312b67186311e50 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Tue, 22 Nov 2016 07:52:58 +0100
> > Subject: [PATCH] mm: consolidate GFP_NOFAIL checks in the allocator slowpath
> > 
> > Tetsuo Handa has pointed out that 0a0337e0d1d1 ("mm, oom: rework oom
> > detection") has subtly changed semantic for costly high order requests
> > with __GFP_NOFAIL and withtout __GFP_REPEAT and those can fail right now.
> > My code inspection didn't reveal any such users in the tree but it is
> > true that this might lead to unexpected allocation failures and
> > subsequent OOPs.
> > 
> > __alloc_pages_slowpath wrt. GFP_NOFAIL is hard to follow currently.
> > There are few special cases but we are lacking a catch all place to be
> > sure we will not miss any case where the non failing allocation might
> > fail. This patch reorganizes the code a bit and puts all those special
> > cases under nopage label which is the generic go-to-fail path. Non
> > failing allocations are retried or those that cannot retry like
> > non-sleeping allocation go to the failure point directly. This should
> > make the code flow much easier to follow and make it less error prone
> > for future changes.
> > 
> > While we are there we have to move the stall check up to catch
> > potentially looping non-failing allocations.
> 
> Currently we allow TIF_MEMDIE && __GFP_NOFAIL threads to call
> __alloc_pages_may_oom() after !__alloc_pages_direct_reclaim() &&
> !__alloc_pages_direct_compact() && !should_reclaim_retry() &&
> !should_compact_retry().
> 
> But this patch changes TIF_MEMDIE && __GFP_NOFAIL threads not to call
> __alloc_pages_may_oom(). If this is intentional, please describe it
> (i.e. this patch adds a location which currently does not cause OOM
> livelock) in change log.

No, it's not intentional. And you have a point, we shouldn't bypass
__alloc_pages_may_oom. Does the following on top look any better?
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3f44a5115b4c..095e2fa286de 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3667,10 +3667,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (page)
 		goto got_pg;
 
-	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE))
-		goto nopage;
-
 	/* Do not loop if specifically requested */
 	if (gfp_mask & __GFP_NORETRY)
 		goto nopage;
@@ -3703,6 +3699,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (page)
 		goto got_pg;
 
+	/* Avoid allocations with no watermarks from looping endlessly */
+	if (test_thread_flag(TIF_MEMDIE))
+		goto nopage;
+
 	/* Retry as long as the OOM killer is making progress */
 	if (did_some_progress) {
 		no_progress_loops = 0;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
