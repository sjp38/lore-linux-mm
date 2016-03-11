Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A8F036B007E
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 11:49:50 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id td3so76163786pab.2
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 08:49:50 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ua9si226101pab.25.2016.03.11.08.49.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Mar 2016 08:49:49 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<201603111945.FHI64215.JVOFLHQFOMOSFt@I-love.SAKURA.ne.jp>
	<20160311130847.GP27701@dhcp22.suse.cz>
	<201603112232.AEJ78150.LOHQJtMFSVOFOF@I-love.SAKURA.ne.jp>
	<20160311152851.GU27701@dhcp22.suse.cz>
In-Reply-To: <20160311152851.GU27701@dhcp22.suse.cz>
Message-Id: <201603120149.JEI86913.JVtSOOFHMFFQOL@I-love.SAKURA.ne.jp>
Date: Sat, 12 Mar 2016 01:49:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 11-03-16 22:32:02, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 11-03-16 19:45:29, Tetsuo Handa wrote:
> > > > (Posting as a reply to this thread.)
> > > 
> > > I really do not see how this is related to this thread.
> > 
> > All allocating tasks are looping at
> > 
> >                         /*
> >                          * If we didn't make any progress and have a lot of
> >                          * dirty + writeback pages then we should wait for
> >                          * an IO to complete to slow down the reclaim and
> >                          * prevent from pre mature OOM
> >                          */
> >                         if (!did_some_progress && 2*(writeback + dirty) > reclaimable) {
> >                                 congestion_wait(BLK_RW_ASYNC, HZ/10);
> >                                 return true;
> >                         }
> > 
> > in should_reclaim_retry().
> > 
> > should_reclaim_retry() was added by OOM detection rework, wan't it?
> 
> What happens without this patch applied. In other words, it all smells
> like the IO got stuck somewhere and the direct reclaim cannot perform it
> so we have to wait for the flushers to make a progress for us. Are those
> stuck? Is the IO making any progress at all or it is just too slow and
> it would finish actually.  Wouldn't we just wait somewhere else in the
> direct reclaim path instead.

As of next-20160311, CPU usage becomes 0% when this problem occurs.

If I remove

  mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations-checkpatch-fixes
  mm: use watermark checks for __GFP_REPEAT high order allocations
  mm: throttle on IO only when there are too many dirty and writeback pages
  mm-oom-rework-oom-detection-checkpatch-fixes
  mm, oom: rework oom detection

then CPU usage becomes 60% and most of allocating tasks
are looping at

        /*
         * Acquire the oom lock.  If that fails, somebody else is
         * making progress for us.
         */
        if (!mutex_trylock(&oom_lock)) {
                *did_some_progress = 1;
                schedule_timeout_uninterruptible(1);
                return NULL;
        }

in __alloc_pages_may_oom() (i.e. OOM-livelock due to the OOM reaper disabled).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
