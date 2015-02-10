Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 22D896B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 10:19:46 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id l2so8000044wgh.9
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 07:19:45 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id vu7si29440922wjc.107.2015.02.10.07.19.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 07:19:44 -0800 (PST)
Date: Tue, 10 Feb 2015 10:19:34 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150210151934.GA11212@phnom.home.cmpxchg.org>
References: <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
 <20141229181937.GE32618@dhcp22.suse.cz>
 <201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
 <20141230112158.GA15546@dhcp22.suse.cz>
 <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
 <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.cz, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

On Tue, Feb 10, 2015 at 10:58:46PM +0900, Tetsuo Handa wrote:
> (Michal is offline, asking Johannes instead.)
> 
> Tetsuo Handa wrote:
> > (A) The order-0 __GFP_WAIT allocation fails immediately upon OOM condition
> >     despite we didn't remove the
> > 
> >         /*
> >          * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
> >          * means __GFP_NOFAIL, but that may not be true in other
> >          * implementations.
> >          */
> >         if (order <= PAGE_ALLOC_COSTLY_ORDER)
> >                 return 1;
> > 
> >     check in should_alloc_retry(). Is this what you expected?
> 
> This behavior is caused by commit 9879de7373fcfb46 "mm: page_alloc:
> embed OOM killing naturally into allocation slowpath". Did you apply
> that commit with agreement to let GFP_NOIO / GFP_NOFS allocations fail
> upon memory pressure and permit filesystems to take fs error actions?
> 
> 	/* The OOM killer does not compensate for light reclaim */
> 	if (!(gfp_mask & __GFP_FS))
> 		goto out;

The model behind the refactored code is to continue retrying the
allocation as long as the allocator has the ability to free memory,
i.e. if page reclaim makes progress, or the OOM killer can be used.

That being said, I missed that GFP_NOFS were able to loop endlessly
even without page reclaim making progress or the OOM killer working,
and since it didn't fit the model I dropped it by accident.

Is this a real workload you are having trouble with or an artificial
stresstest?  Because I'd certainly be willing to revert that part of
the patch and make GFP_NOFS looping explicit if it helps you.  But I
do think the new behavior makes more sense, so I'd prefer to keep it
if it's merely a stress test you use to test allocator performance.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8e20f9c2fa5a..f77c58ebbcfa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2382,8 +2382,15 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		if (high_zoneidx < ZONE_NORMAL)
 			goto out;
 		/* The OOM killer does not compensate for light reclaim */
-		if (!(gfp_mask & __GFP_FS))
+		if (!(gfp_mask & __GFP_FS)) {
+			/*
+			 * XXX: Page reclaim didn't yield anything,
+			 * and the OOM killer can't be invoked, but
+			 * keep looping as per should_alloc_retry().
+			 */
+			*did_some_progress = 1;
 			goto out;
+		}
 		/*
 		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
 		 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
