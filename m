Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5105F2808A9
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 10:26:15 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v190so4209707wme.0
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 07:26:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l35si13278004wre.212.2017.03.10.07.26.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 07:26:13 -0800 (PST)
Date: Fri, 10 Mar 2017 16:26:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7] mm: Add memory allocation watchdog kernel thread.
Message-ID: <20170310152611.GM3753@dhcp22.suse.cz>
References: <1488244908-57586-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201703091946.GDC21885.OQFFOtJHSOFVML@I-love.SAKURA.ne.jp>
 <20170309143751.05bddcbad82672384947de5f@linux-foundation.org>
 <20170310104047.GF3753@dhcp22.suse.cz>
 <201703102019.JHJ58283.MQHtVFOOFOLFJS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201703102019.JHJ58283.MQHtVFOOFOLFJS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, mgorman@techsingularity.net, david@fromorbit.com, apolyakov@beget.ru

On Fri 10-03-17 20:19:58, Tetsuo Handa wrote:
[...]
> Or, did you mean "some additional examples of how this new code was used
> to understand and improve real-world kernel problems" as how this patch
> helped in [2] [3] ?
> 
> Regarding [3] (now continued as
> http://lkml.kernel.org/r/201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp ),
> I used this patch for confirming the following things.
> 
>   (1) kswapd cannot make progress waiting for lock.
> 
> ----------
> [  518.900038] MemAlloc: kswapd0(69) flags=0xa40840 switches=23883 uninterruptible
> [  518.902095] kswapd0         D10776    69      2 0x00000000
> [  518.903784] Call Trace:
[...]
> 
> [ 1095.632984] MemAlloc: kswapd0(69) flags=0xa40840 switches=23883 uninterruptible
> [ 1095.632985] kswapd0         D10776    69      2 0x00000000
> [ 1095.632988] Call Trace:
[...]
> ----------
> 
>   (2) All WQ_MEM_RECLAIM threads shown by show_workqueue_state()
>       cannot make progress waiting for memory allocation.
> 
> ----------
> [ 1095.633625] MemAlloc: xfs-data/sda1(451) flags=0x4228060 switches=45509 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652073
> [ 1095.633626] xfs-data/sda1   R  running task    12696   451      2 0x00000000
> [ 1095.633663] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
> [ 1095.633665] Call Trace:
[...]

We can get all this from the sysrq+t output, right? Well except for the
gfp mask, oder and delay which is something that would give us a hint
that something is going on with the allocation because all those tasks
are in the page allocation obviously from the Call trace.
> ----------
> 
>   (3) order-0 GFP_NOIO allocation request cannot make progress
>       waiting for memory allocation.

which is completely irrelevant to the issue...
 
>   (4) Number of stalling threads does not decrease over time while
>       number of out_of_memory() calls increases over time.

You would see the same from the allocation stall warning. Even when it
is not really ideal (we are getting there though) you would see that
some allocation simply do not make a forward progress.

> ----------
> [  518.090012] MemAlloc-Info: stalling=184 dying=1 exiting=0 victim=1 oom_count=8441307
> [  553.070829] MemAlloc-Info: stalling=184 dying=1 exiting=0 victim=1 oom_count=10318507
> [  616.394649] MemAlloc-Info: stalling=186 dying=1 exiting=0 victim=1 oom_count=13908219
> [  642.266252] MemAlloc-Info: stalling=186 dying=1 exiting=0 victim=1 oom_count=15180673
> [  702.412189] MemAlloc-Info: stalling=187 dying=1 exiting=0 victim=1 oom_count=18732529
> [  736.787879] MemAlloc-Info: stalling=187 dying=1 exiting=0 victim=1 oom_count=20565244
> [  800.715759] MemAlloc-Info: stalling=188 dying=1 exiting=0 victim=1 oom_count=24411576
> [  837.571405] MemAlloc-Info: stalling=188 dying=1 exiting=0 victim=1 oom_count=26463562
> [  899.021495] MemAlloc-Info: stalling=189 dying=1 exiting=0 victim=1 oom_count=30144879
> [  936.282709] MemAlloc-Info: stalling=189 dying=1 exiting=0 victim=1 oom_count=32129234
> [  997.328119] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=35657983
> [ 1033.977265] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=37659912
> [ 1095.630961] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=40639677
> [ 1095.821248] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=40646791

yeah, this is more than you can find out right now but I am not really
sure how much more this will tell you from what we already know above.
Do not take me wrong this is all nice and dandy but existing debugging
tools would give us a good clue what is going on even without that.
 
[...]

> Regarding "infinite too_many_isolated() loop" case
> ( http://lkml.kernel.org/r/201702212335.DJB30777.JOFMHSFtVLQOOF@I-love.SAKURA.ne.jp ),
> I used this patch for confirming the following things.
> 
>   (1) kswapd cannot make progress waiting for lock.
[...]
> 
>   (2) Both GFP_IO and GFP_KERNEL allocations are stuck at
>       too_many_isolated() loop.
[...]
> ----------
> 
>   (3) Number of stalling threads does not decrease over time and
>       number of out_of_memory() calls does not increase over time.
> 
> ----------
> [ 1209.781787] MemAlloc-Info: stalling=32 dying=1 exiting=0 victim=1 oom_count=45896
> [ 1212.195351] MemAlloc-Info: stalling=32 dying=1 exiting=0 victim=1 oom_count=45896
> [ 1242.551629] MemAlloc-Info: stalling=36 dying=1 exiting=0 victim=1 oom_count=45896
> [ 1245.149165] MemAlloc-Info: stalling=36 dying=1 exiting=0 victim=1 oom_count=45896
> [ 1275.319189] MemAlloc-Info: stalling=40 dying=1 exiting=0 victim=1 oom_count=45896
> [ 1278.241813] MemAlloc-Info: stalling=40 dying=1 exiting=0 victim=1 oom_count=45896
> ----------

OK, this is a better example but I would argue that multiple snapshots
when CPUs are basically idle while all memory allocations are sitting on
the congestion wait would signal this pretty clearly as well and we can
see this from the sysrq+t as well.

So, we have means to debug these issues. Some of them are rather coarse
and your watchdog can collect much more and maybe give us a clue much
quicker but we still have to judge whether all this is really needed
because it doesn't come for free. Have you considered this aspect?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
