Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6CB1E6B0036
	for <linux-mm@kvack.org>; Mon, 26 May 2014 22:38:08 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so8334532pad.2
        for <linux-mm@kvack.org>; Mon, 26 May 2014 19:38:08 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:7])
        by mx.google.com with ESMTP id ot9si17034945pac.53.2014.05.26.19.38.06
        for <linux-mm@kvack.org>;
        Mon, 26 May 2014 19:38:07 -0700 (PDT)
Date: Tue, 27 May 2014 12:37:51 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/3] Shrinkers and proportional reclaim
Message-ID: <20140527023751.GB8554@dastard>
References: <1400749779-24879-1-git-send-email-mgorman@suse.de>
 <alpine.LSU.2.11.1405261441320.7154@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1405261441320.7154@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Mon, May 26, 2014 at 02:44:29PM -0700, Hugh Dickins wrote:
> On Thu, 22 May 2014, Mel Gorman wrote:
> 
> > This series is aimed at regressions noticed during reclaim activity. The
> > first two patches are shrinker patches that were posted ages ago but never
> > merged for reasons that are unclear to me. I'm posting them again to see if
> > there was a reason they were dropped or if they just got lost. Dave?  Time?
> > The last patch adjusts proportional reclaim. Yuanhan Liu, can you retest
> > the vm scalability test cases on a larger machine? Hugh, does this work
> > for you on the memcg test cases?
> 
> Yes it does, thank you.
> 
> Though the situation is muddy, since on our current internal tree, I'm
> surprised to find that the memcg test case no longer fails reliably
> without our workaround and without your fix.
> 
> "Something must have changed"; but it would take a long time to work
> out what.  If I travel back in time with git, to where we first applied
> the "vindictive" patch, then yes that test case convincingly fails
> without either (my or your) patch, and passes with either patch.
> 
> And you have something that satisfies Yuanhan too, that's great.
> 
> I'm also pleased to see Dave and Tim reduce the contention in
> grab_super_passive(): that's a familiar symbol from livelock dumps.
> 
> You might want to add this little 4/3, that we've had in for a
> while; but with grab_super_passive() out of super_cache_count(),
> it will have much less importance.
> 
> 
> [PATCH 4/3] fs/superblock: Avoid counting without __GFP_FS
> 
> Don't waste time counting objects in super_cache_count() if no __GFP_FS:
> super_cache_scan() would only back out with SHRINK_STOP in that case.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

While you might think that's a good thing, it's not.  The act of
shrinking is kept separate from the accounting of how much shrinking
needs to take place.  The amount of work the shrinker can't do due
to the reclaim context is deferred until the shrinker is called in a
context where it can do work (eg. kswapd)

Hence not accounting for work that can't be done immediately will
adversely impact the balance of the system under memory intensive
filesystem workloads. In these worklaods, almost all allocations are
done in the GFP_NOFS or GFP_NOIO contexts so not deferring the work
will will effectively stop superblock cache reclaim entirely....

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
