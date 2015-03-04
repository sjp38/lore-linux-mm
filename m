Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D06306B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 07:41:13 -0500 (EST)
Received: by pdno5 with SMTP id o5so10661368pdn.12
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 04:41:13 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ld10si5011864pbc.60.2015.03.04.04.41.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 04:41:12 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150224210244.GA13666@dastard>
	<201502252331.IEJ78629.OOOFSLFMHQtFVJ@I-love.SAKURA.ne.jp>
	<20150227073949.GJ4251@dastard>
	<201502272142.BFJ09388.OLOMFFFVSQJOtH@I-love.SAKURA.ne.jp>
	<20150227131209.GK4251@dastard>
In-Reply-To: <20150227131209.GK4251@dastard>
Message-Id: <201503042141.FIC48980.OFFtVSQFOOMHJL@I-love.SAKURA.ne.jp>
Date: Wed, 4 Mar 2015 21:41:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: tytso@mit.edu, rientjes@google.com, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, fernando_b1@lab.ntt.co.jp

Dave Chinner wrote:
> On Fri, Feb 27, 2015 at 09:42:55PM +0900, Tetsuo Handa wrote:
> > If kswapd0 is blocked forever at e.g. mutex_lock() inside shrinker
> > functions, who else can make forward progress?
> 
> You can't get into these filesystem shrinkers when you do GFP_NOIO
> allocations, as the IO path does.
> 
> > Shouldn't we avoid calling functions which could potentially block for
> > unpredictable duration (e.g. unkillable locks and/or completion) from
> > shrinker functions?
> 
> No, because otherwise we can't throttle allocation and reclaim to
> the rate at which IO can clean dirty objects. i.e. we do this for
> the same reason we throttle page cache dirtying to the rate at which
> we can clean dirty pages....

I'm misunderstanding something. The description for kswapd() function
in mm/vmscan.c says "This basically trickles out pages so that we have
_some_ free memory available even if there is no other activity that frees
anything up".

Forever blocking kswapd0 somewhere inside filesystem shrinker functions is
equivalent with removing kswapd() function because it also prevents non
filesystem shrinker functions from being called by kswapd0, doesn't it?
Then, the description will become "We won't have _some_ free memory available
if there is no other activity that frees anything up", won't it?

Does kswapd0 exist only for reducing the delay caused by reclaiming
synchronously? Disabling kswapd0 affects nothing about functionality?
The system can make forward progress even if nobody can call non filesystem
shrinkers, can't it?

If yes, then why do we need to make special handling for
excluding kswapd0 at

	while (unlikely(too_many_isolated(zone, file, sc))) {
		congestion_wait(BLK_RW_ASYNC, HZ/10);

		/* We are about to die and free our memory. Return now. */
		if (fatal_signal_pending(current))
			return SWAP_CLUSTER_MAX;
	}

loop inside shrink_inactive_list() ?

I can't understand the difference between "kswapd0 sleeping forever at
too_many_isolated() loop inside shrink_inactive_list()" and "kswapd0
sleeping forever at mutex_lock() inside xfs_reclaim_inodes_ag()".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
