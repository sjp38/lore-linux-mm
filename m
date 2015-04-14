Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 72FF86B006E
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 03:21:01 -0400 (EDT)
Received: by wiax7 with SMTP id x7so81507218wia.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 00:21:00 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id df3si2122703wib.53.2015.04.14.00.20.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 00:21:00 -0700 (PDT)
Received: by wiun10 with SMTP id n10so10664424wiu.1
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 00:20:59 -0700 (PDT)
Date: Tue, 14 Apr 2015 09:20:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 00/12] mm: page_alloc: improve OOM mechanism and policy
Message-ID: <20150414072058.GA17160@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <20150326195822.GB28129@dastard>
 <20150327150509.GA21119@cmpxchg.org>
 <20150330003240.GB28621@dastard>
 <20150401151920.GB23824@dhcp22.suse.cz>
 <20150407141822.GA3262@cmpxchg.org>
 <20150413124614.GA21790@dhcp22.suse.cz>
 <20150414001118.GS15810@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150414001118.GS15810@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Tue 14-04-15 10:11:18, Dave Chinner wrote:
> On Mon, Apr 13, 2015 at 02:46:14PM +0200, Michal Hocko wrote:
> > [Sorry for a late reply]
> > 
> > On Tue 07-04-15 10:18:22, Johannes Weiner wrote:
> > > On Wed, Apr 01, 2015 at 05:19:20PM +0200, Michal Hocko wrote:
> > > My question here would be: are there any NOFS allocations that *don't*
> > > want this behavior?  Does it even make sense to require this separate
> > > annotation or should we just make it the default?
> > > 
> > > The argument here was always that NOFS allocations are very limited in
> > > their reclaim powers and will trigger OOM prematurely.  However, the
> > > way we limit dirty memory these days forces most cache to be clean at
> > > all times, and direct reclaim in general hasn't been allowed to issue
> > > page writeback for quite some time.  So these days, NOFS reclaim isn't
> > > really weaker than regular direct reclaim. 
> > 
> > What about [di]cache and some others fs specific shrinkers (and heavy
> > metadata loads)?
> 
> We don't do direct reclaim for fs shrinkers in GFP_NOFS context,
> either.

Yeah but we invoke fs shrinkers for the _regular_ direct reclaim (with
__GFP_FS), which was the point I've tried to make here.

> *HOWEVER*
> 
> The shrinker reclaim we can not execute is deferred to the next
> context that can do the reclaim, which is usually kswapd. So the
> reclaim gets done according to the GFP_NOFS memory pressure that is
> occurring, it is just done in a different context...

Right, deferring to kswapd is the reason why I think the direct reclaim
shouldn't invoke OOM killer in this context because that would be
premature - as kswapd still can make some progress. Sorry for not being
more clear.

> > > The only exception is that
> > > it might block writeback, so we'd go OOM if the only reclaimables left
> > > were dirty pages against that filesystem.  That should be acceptable.
> > 
> > OOM killer is hardly acceptable by most users I've heard from. OOM
> > killer is the _last_ resort and if the allocation is restricted then
> > we shouldn't use the big hammer. The allocator might use __GFP_HIGH to
> > get access to memory reserves if it can fail or __GFP_NOFAIL if it
> > cannot. With your patches the NOFAIL case would get an access to memory
> > reserves as well. So I do not really see a reason to change GFP_NOFS vs.
> > OOM killer semantic.
> 
> So, really, what we want is something like:
> 
> #define __GFP_USE_LOWMEM_RESERVE	__GFP_HIGH
> 
> So that it documents the code that is using it effectively and we
> can find them easily with cscope/grep?

I wouldn't be opposed. To be honest I was never fond of __GFP_HIGH. The
naming is counterintuitive. So I would rather go with renaminag it. We do
not have that many users in the tree.
git grep "GFP_HIGH\>" | wc -l
40
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
