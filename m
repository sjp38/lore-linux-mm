Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 984FE6B01F0
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 12:04:03 -0400 (EDT)
Received: by pzk33 with SMTP id 33so2143887pzk.14
        for <linux-mm@kvack.org>; Sun, 29 Aug 2010 09:04:02 -0700 (PDT)
Date: Mon, 30 Aug 2010 01:03:54 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/3] writeback: Record if the congestion was unnecessary
Message-ID: <20100829160354.GA4537@barrios-desktop>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
 <1282835656-5638-3-git-send-email-mel@csn.ul.ie>
 <20100826182904.GC6805@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100826182904.GC6805@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi, Hannes. 

On Thu, Aug 26, 2010 at 08:29:04PM +0200, Johannes Weiner wrote:
> On Thu, Aug 26, 2010 at 04:14:15PM +0100, Mel Gorman wrote:
> > If congestion_wait() is called when there is no congestion, the caller
> > will wait for the full timeout. This can cause unreasonable and
> > unnecessary stalls. There are a number of potential modifications that
> > could be made to wake sleepers but this patch measures how serious the
> > problem is. It keeps count of how many congested BDIs there are. If
> > congestion_wait() is called with no BDIs congested, the tracepoint will
> > record that the wait was unnecessary.
> 
> I am not convinced that unnecessary is the right word.  On a workload
> without any IO (i.e. no congestion_wait() necessary, ever), I noticed
> the VM regressing both in time and in reclaiming the right pages when
> simply removing congestion_wait() from the direct reclaim paths (the
> one in __alloc_pages_slowpath and the other one in
> do_try_to_free_pages).

Not exactly same your experiment but I had a simillar experince. 
I had a experiement about swapout. System has lots of anon pages but
almost no file pages and it already started to swap out. It means
system have no memory. In this case, I forked new process which mmap
some MB pages and touch the pages. It means VM should swapout some MB page 
for the process. And I measured the time until completing touching the pages. 

Sometime it's fast, sometime it's slow. time gap is almost two. 
Interesting thing is when it is fast, many of pages are reclaimed by kswapd. 
Ah.. I used swap to ramdisk and reserve the swap pages by touching before 
starting the experiment. So I would say it's not a _flushd_ effect.

> 
> So just being stupid and waiting for the timeout in direct reclaim
> while kswapd can make progress seemed to do a better job for that
> load.
> 
> I can not exactly pinpoint the reason for that behaviour, it would be
> nice if somebody had an idea.

I just thought the cause is direct reclaim just reclaims by 32 pages 
but kswapd could reclaim many pages by batch. But i didn't look at it any more
due to busy. Does it make sense?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
