Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 229696B0038
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 10:18:36 -0400 (EDT)
Received: by wgin8 with SMTP id n8so57733926wgi.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 07:18:35 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k7si13124282wib.9.2015.04.07.07.18.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 07:18:34 -0700 (PDT)
Date: Tue, 7 Apr 2015 10:18:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 00/12] mm: page_alloc: improve OOM mechanism and policy
Message-ID: <20150407141822.GA3262@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <20150326195822.GB28129@dastard>
 <20150327150509.GA21119@cmpxchg.org>
 <20150330003240.GB28621@dastard>
 <20150401151920.GB23824@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150401151920.GB23824@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Wed, Apr 01, 2015 at 05:19:20PM +0200, Michal Hocko wrote:
> On Mon 30-03-15 11:32:40, Dave Chinner wrote:
> > On Fri, Mar 27, 2015 at 11:05:09AM -0400, Johannes Weiner wrote:
> [...]
> > > GFP_NOFS sites are currently one of the sites that can deadlock inside
> > > the allocator, even though many of them seem to have fallback code.
> > > My reasoning here is that if you *have* an exit strategy for failing
> > > allocations that is smarter than hanging, we should probably use that.
> > 
> > We already do that for allocations where we can handle failure in
> > GFP_NOFS conditions. It is, however, somewhat useless if we can't
> > tell the allocator to try really hard if we've already had a failure
> > and we are already in memory reclaim conditions (e.g. a shrinker
> > trying to clean dirty objects so they can be reclaimed).
> > 
> > From that perspective, I think that this patch set aims force us
> > away from handling fallbacks ourselves because a) it makes GFP_NOFS
> > more likely to fail, and b) provides no mechanism to "try harder"
> > when we really need the allocation to succeed.
> 
> You can ask for this "try harder" by __GFP_HIGH flag. Would that help
> in your fallback case?

I would think __GFP_REPEAT would be more suitable here.  From the doc:

 * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
 * _might_ fail.  This depends upon the particular VM implementation.

so we can make the semantics of GFP_NOFS | __GFP_REPEAT such that they
are allowed to use the OOM killer and dip into the OOM reserves.

My question here would be: are there any NOFS allocations that *don't*
want this behavior?  Does it even make sense to require this separate
annotation or should we just make it the default?

The argument here was always that NOFS allocations are very limited in
their reclaim powers and will trigger OOM prematurely.  However, the
way we limit dirty memory these days forces most cache to be clean at
all times, and direct reclaim in general hasn't been allowed to issue
page writeback for quite some time.  So these days, NOFS reclaim isn't
really weaker than regular direct reclaim.  The only exception is that
it might block writeback, so we'd go OOM if the only reclaimables left
were dirty pages against that filesystem.  That should be acceptable.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 47981c5e54c3..fe3cb2b0b85b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2367,16 +2367,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		/* The OOM killer does not needlessly kill tasks for lowmem */
 		if (ac->high_zoneidx < ZONE_NORMAL)
 			goto out;
-		/* The OOM killer does not compensate for IO-less reclaim */
-		if (!(gfp_mask & __GFP_FS)) {
-			/*
-			 * XXX: Page reclaim didn't yield anything,
-			 * and the OOM killer can't be invoked, but
-			 * keep looping as per tradition.
-			 */
-			*did_some_progress = 1;
-			goto out;
-		}
 		if (pm_suspended_storage())
 			goto out;
 		/* The OOM killer may not free memory on a specific node */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
