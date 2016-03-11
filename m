Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 04D376B007E
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 12:21:02 -0500 (EST)
Received: by mail-oi0-f48.google.com with SMTP id m82so90687351oif.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 09:21:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id my3si508597obb.87.2016.03.11.09.21.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Mar 2016 09:21:00 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160311130847.GP27701@dhcp22.suse.cz>
	<201603112232.AEJ78150.LOHQJtMFSVOFOF@I-love.SAKURA.ne.jp>
	<20160311152851.GU27701@dhcp22.suse.cz>
	<201603120149.JEI86913.JVtSOOFHMFFQOL@I-love.SAKURA.ne.jp>
	<20160311170022.GX27701@dhcp22.suse.cz>
In-Reply-To: <20160311170022.GX27701@dhcp22.suse.cz>
Message-Id: <201603120220.GFJ00000.QOLVOtJOMFFSHF@I-love.SAKURA.ne.jp>
Date: Sat, 12 Mar 2016 02:20:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sat 12-03-16 01:49:26, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > What happens without this patch applied. In other words, it all smells
> > > like the IO got stuck somewhere and the direct reclaim cannot perform it
> > > so we have to wait for the flushers to make a progress for us. Are those
> > > stuck? Is the IO making any progress at all or it is just too slow and
> > > it would finish actually.  Wouldn't we just wait somewhere else in the
> > > direct reclaim path instead.
> > 
> > As of next-20160311, CPU usage becomes 0% when this problem occurs.
> > 
> > If I remove
> > 
> >   mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations-checkpatch-fixes
> >   mm: use watermark checks for __GFP_REPEAT high order allocations
> >   mm: throttle on IO only when there are too many dirty and writeback pages
> >   mm-oom-rework-oom-detection-checkpatch-fixes
> >   mm, oom: rework oom detection
> > 
> > then CPU usage becomes 60% and most of allocating tasks
> > are looping at
> > 
> >         /*
> >          * Acquire the oom lock.  If that fails, somebody else is
> >          * making progress for us.
> >          */
> >         if (!mutex_trylock(&oom_lock)) {
> >                 *did_some_progress = 1;
> >                 schedule_timeout_uninterruptible(1);
> >                 return NULL;
> >         }
> > 
> > in __alloc_pages_may_oom() (i.e. OOM-livelock due to the OOM reaper disabled).
> 
> OK, that would suggest that the oom rework patches are not really
> related. They just moved from the livelock to a sleep which is good in
> general IMHO. We even know that it is most probably the IO that is the
> problem because we know that more than half of the reclaimable memory is
> either dirty or under writeback. That is where you should be looking.
> Why the IO is not making progress or such a slow progress.
> 

Excuse me, but I can't understand why you think the oom rework patches are not
related. This problem occurs immediately after the OOM killer is invoked, which
means that there is little reclaimable memory.

  Node 0 DMA32 free:3648kB min:3780kB low:4752kB high:5724kB active_anon:783216kB inactive_anon:6376kB active_file:33388kB inactive_file:40292kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:1032064kB mana\
ged:980816kB mlocked:0kB dirty:40232kB writeback:120kB mapped:34720kB shmem:6628kB slab_reclaimable:10528kB slab_unreclaimable:39068kB kernel_stack:20512kB pagetables:8000kB unstable:0kB bounce:0kB free_pcp:1648kB local_pcp:116kB free_c\
ma:0kB writeback_tmp:0kB pages_scanned:964952 all_unreclaimable? yes
  Node 0 DMA32: 860*4kB (UME) 16*8kB (UME) 1*16kB (M) 0*32kB 1*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3648kB

The OOM killer is invoked (but nothing happens due to TIF_MEMDIE) if I remove
the oom rework patches, which means that there is little reclaimable memory.

My understanding is that memory allocation requests needed for doing I/O cannot
be satisfied because free: is below min: . And since kswapd got stuck, nobody can
perform operations needed for making 2*(writeback + dirty) > reclaimable false.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
