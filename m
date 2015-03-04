Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id DFB576B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 09:12:03 -0500 (EST)
Received: by padfa1 with SMTP id fa1so33703401pad.9
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 06:12:03 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ym2si5060371pbc.211.2015.03.04.06.12.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 06:12:02 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150227073949.GJ4251@dastard>
	<201502272142.BFJ09388.OLOMFFFVSQJOtH@I-love.SAKURA.ne.jp>
	<20150227131209.GK4251@dastard>
	<201503042141.FIC48980.OFFtVSQFOOMHJL@I-love.SAKURA.ne.jp>
	<20150304132514.GW4251@dastard>
In-Reply-To: <20150304132514.GW4251@dastard>
Message-Id: <201503042311.CHA93957.tJFFOHMQLSOFVO@I-love.SAKURA.ne.jp>
Date: Wed, 4 Mar 2015 23:11:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: tytso@mit.edu, rientjes@google.com, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, fernando_b1@lab.ntt.co.jp

Dave Chinner wrote:
> > Forever blocking kswapd0 somewhere inside filesystem shrinker functions is
> > equivalent with removing kswapd() function because it also prevents non
> > filesystem shrinker functions from being called by kswapd0, doesn't it?
> 
> Yes, but that's not intentional. Remember, we keep talking about the
> filesystem not being able to guarantee forwards progress if
> allocations block forever? Well...
> 
> > Then, the description will become "We won't have _some_ free memory available
> > if there is no other activity that frees anything up", won't it?
> 
> ... we've ended up blocking kswapd because it's waiting on a journal
> commit to complete, and that journal commit is blocked waiting for
> forwards progress in memory allocation...
> 
> Yes, it's another one of those nasty dependencies I keep pointing
> out that filesystems have, and that can only be solved by
> guaranteeing we can always make forwards allocation progress from
> transaction reserve to transaction commit.

If this is an unexpected deadlock, don't we want below change for
xfs_reclaim_inodes_ag() ?

-	if (skipped && (flags & SYNC_WAIT) && *nr_to_scan > 0) {
+	if (skipped && (flags & SYNC_WAIT) && *nr_to_scan > 0 && !current_is_kswapd()) {
 		trylock = 0;
 		goto restart;
 	}

> It's rare that kswapd actually gets stuck like this - I've only ever
> seen it once, and I've never had anyone running a production system
> report deadlocks like this...

I guess we will unlikely see this again, for so far this is observed with
only Linux 3.19 which lacks commit cc87317726f8 ("mm: page_alloc: revert
inadvertent !__GFP_FS retry behavior change").

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
