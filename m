Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 65A026B0032
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 20:21:10 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so124325013pdb.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 17:21:10 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id a8si17994593pbu.153.2015.04.13.17.21.07
        for <linux-mm@kvack.org>;
        Mon, 13 Apr 2015 17:21:09 -0700 (PDT)
Date: Tue, 14 Apr 2015 10:11:18 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 00/12] mm: page_alloc: improve OOM mechanism and policy
Message-ID: <20150414001118.GS15810@dastard>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <20150326195822.GB28129@dastard>
 <20150327150509.GA21119@cmpxchg.org>
 <20150330003240.GB28621@dastard>
 <20150401151920.GB23824@dhcp22.suse.cz>
 <20150407141822.GA3262@cmpxchg.org>
 <20150413124614.GA21790@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150413124614.GA21790@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Mon, Apr 13, 2015 at 02:46:14PM +0200, Michal Hocko wrote:
> [Sorry for a late reply]
> 
> On Tue 07-04-15 10:18:22, Johannes Weiner wrote:
> > On Wed, Apr 01, 2015 at 05:19:20PM +0200, Michal Hocko wrote:
> > My question here would be: are there any NOFS allocations that *don't*
> > want this behavior?  Does it even make sense to require this separate
> > annotation or should we just make it the default?
> > 
> > The argument here was always that NOFS allocations are very limited in
> > their reclaim powers and will trigger OOM prematurely.  However, the
> > way we limit dirty memory these days forces most cache to be clean at
> > all times, and direct reclaim in general hasn't been allowed to issue
> > page writeback for quite some time.  So these days, NOFS reclaim isn't
> > really weaker than regular direct reclaim. 
> 
> What about [di]cache and some others fs specific shrinkers (and heavy
> metadata loads)?

We don't do direct reclaim for fs shrinkers in GFP_NOFS context,
either.

*HOWEVER*

The shrinker reclaim we can not execute is deferred to the next
context that can do the reclaim, which is usually kswapd. So the
reclaim gets done according to the GFP_NOFS memory pressure that is
occurring, it is just done in a different context...

> > The only exception is that
> > it might block writeback, so we'd go OOM if the only reclaimables left
> > were dirty pages against that filesystem.  That should be acceptable.
> 
> OOM killer is hardly acceptable by most users I've heard from. OOM
> killer is the _last_ resort and if the allocation is restricted then
> we shouldn't use the big hammer. The allocator might use __GFP_HIGH to
> get access to memory reserves if it can fail or __GFP_NOFAIL if it
> cannot. With your patches the NOFAIL case would get an access to memory
> reserves as well. So I do not really see a reason to change GFP_NOFS vs.
> OOM killer semantic.

So, really, what we want is something like:

#define __GFP_USE_LOWMEM_RESERVE	__GFP_HIGH

So that it documents the code that is using it effectively and we
can find them easily with cscope/grep?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
