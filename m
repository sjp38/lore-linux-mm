Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 44C00828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 08:15:06 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id q63so10077274pfb.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 05:15:06 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id bc9si16687023pad.140.2016.01.08.05.15.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jan 2016 05:15:05 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201512292258.ABF87505.OFOSJLHMFVOQFt@I-love.SAKURA.ne.jp>
	<20160107162815.GA31729@cmpxchg.org>
	<20160108123735.GB14657@dhcp22.suse.cz>
In-Reply-To: <20160108123735.GB14657@dhcp22.suse.cz>
Message-Id: <201601082214.GAE43765.HQVFSMOJOOFLFt@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jan 2016 22:14:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 07-01-16 11:28:15, Johannes Weiner wrote:
> > On Tue, Dec 29, 2015 at 10:58:22PM +0900, Tetsuo Handa wrote:
> > > >From 8bb9e36891a803e82c589ef78077838026ce0f7d Mon Sep 17 00:00:00 2001
> > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Date: Tue, 29 Dec 2015 22:20:58 +0900
> > > Subject: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
> > > 
> > > The OOM reaper kernel thread can reclaim OOM victim's memory before the victim
> > > terminates. But since oom_kill_process() tries to kill children of the memory
> > > hog process first, the OOM reaper can not reclaim enough memory for terminating
> > > the victim if the victim is consuming little memory. The result is OOM livelock
> > > as usual, for timeout based next OOM victim selection is not implemented.
> > 
> > What we should be doing is have the OOM reaper clear TIF_MEMDIE after
> > it's done. There is no reason to wait for and prioritize the exit of a
> > task that doesn't even have memory anymore. Once a task's memory has
> > been reaped, subsequent OOM invocations should evaluate anew the most
> > desirable OOM victim.
> 
> This is an interesting idea. It definitely sounds better than timeout
> based solutions. I will cook up a patch for this. The API between oom
> killer and the reaper has to change slightly but that shouldn't be a big
> deal.

That is part of what I suggested at
http://lkml.kernel.org/r/201512052133.IAE00551.LSOQFtMFFVOHOJ@I-love.SAKURA.ne.jp .
| What about marking current OOM victim unkillable by updating
| victim->signal->oom_score_adj to OOM_SCORE_ADJ_MIN and clearing victim's
| TIF_MEMDIE flag when the victim is still alive for a second after
| oom_reap_vmas() completed?

Can we update victim's oom_score_adj as well? Otherwise, the OOM killer
might choose the same victim if victim's oom_score_adj was set to 1000.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
