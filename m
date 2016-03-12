Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id EF5D66B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 23:08:25 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fe3so98258218pab.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 20:08:25 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q64si18574753pfi.190.2016.03.11.20.08.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Mar 2016 20:08:24 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201603112232.AEJ78150.LOHQJtMFSVOFOF@I-love.SAKURA.ne.jp>
	<20160311152851.GU27701@dhcp22.suse.cz>
	<201603120149.JEI86913.JVtSOOFHMFFQOL@I-love.SAKURA.ne.jp>
	<20160311170022.GX27701@dhcp22.suse.cz>
	<201603120220.GFJ00000.QOLVOtJOMFFSHF@I-love.SAKURA.ne.jp>
In-Reply-To: <201603120220.GFJ00000.QOLVOtJOMFFSHF@I-love.SAKURA.ne.jp>
Message-Id: <201603121308.FEH04174.OFHLOFMSJOtQVF@I-love.SAKURA.ne.jp>
Date: Sat, 12 Mar 2016 13:08:04 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> OK, that would suggest that the oom rework patches are not really
> related. They just moved from the livelock to a sleep which is good in
> general IMHO. We even know that it is most probably the IO that is the
> problem because we know that more than half of the reclaimable memory is
> either dirty or under writeback. That is where you should be looking.
> Why the IO is not making progress or such a slow progress.
> 

A footnote. Regarding this reproducer, the problem was "anybody can declare
OOM and call out_of_memory(). But out_of_memory() does nothing because there
is a thread which has TIF_MEMDIE." before the OOM detection rework patches,
and the problem is "nobody can declare OOM and call out_of_memory(). Although
out_of_memory() will do nothing because there is a thread which has
TIF_MEMDIE." after the OOM detection rework patches.

Dave Chinner wrote at http://lkml.kernel.org/r/20160211225929.GU14668@dastard :
> > Although there are memory allocating tasks passing gfp flags with
> > __GFP_KSWAPD_RECLAIM, kswapd is unable to make forward progress because
> > it is blocked at down() called from memory reclaim path. And since it is
> > legal to block kswapd from memory reclaim path (am I correct?), I think
> > we must not assume that current_is_kswapd() check will break the infinite
> > loop condition.
> 
> Right, the threads that are blocked in writeback waiting on memory
> reclaim will be using GFP_NOFS to prevent recursion deadlocks, but
> that does not avoid the problem that kswapd can then get stuck
> on those locks, too. Hence there is no guarantee that kswapd can
> make reclaim progress if it does dirty page writeback...

Unless we address the issue Dave commented, the OOM detection rework patches
add a new location of livelock (which is demonstrated by this reproducer) in
the memory allocator. It is an unfortunate change that we add a new location
of livelock when we are trying to solve thrashing problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
