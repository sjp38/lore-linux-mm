Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 05212828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 08:41:49 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id f206so136467730wmf.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 05:41:48 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id gg9si1305152wjb.115.2016.01.08.05.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 05:41:47 -0800 (PST)
Received: by mail-wm0-f44.google.com with SMTP id u188so137398555wmu.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 05:41:47 -0800 (PST)
Date: Fri, 8 Jan 2016 14:41:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
Message-ID: <20160108134145.GD14657@dhcp22.suse.cz>
References: <201512292258.ABF87505.OFOSJLHMFVOQFt@I-love.SAKURA.ne.jp>
 <20160107162815.GA31729@cmpxchg.org>
 <20160108123735.GB14657@dhcp22.suse.cz>
 <201601082214.GAE43765.HQVFSMOJOOFLFt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601082214.GAE43765.HQVFSMOJOOFLFt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 08-01-16 22:14:54, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 07-01-16 11:28:15, Johannes Weiner wrote:
> > > On Tue, Dec 29, 2015 at 10:58:22PM +0900, Tetsuo Handa wrote:
> > > > >From 8bb9e36891a803e82c589ef78077838026ce0f7d Mon Sep 17 00:00:00 2001
> > > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > > Date: Tue, 29 Dec 2015 22:20:58 +0900
> > > > Subject: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
> > > > 
> > > > The OOM reaper kernel thread can reclaim OOM victim's memory before the victim
> > > > terminates. But since oom_kill_process() tries to kill children of the memory
> > > > hog process first, the OOM reaper can not reclaim enough memory for terminating
> > > > the victim if the victim is consuming little memory. The result is OOM livelock
> > > > as usual, for timeout based next OOM victim selection is not implemented.
> > > 
> > > What we should be doing is have the OOM reaper clear TIF_MEMDIE after
> > > it's done. There is no reason to wait for and prioritize the exit of a
> > > task that doesn't even have memory anymore. Once a task's memory has
> > > been reaped, subsequent OOM invocations should evaluate anew the most
> > > desirable OOM victim.
> > 
> > This is an interesting idea. It definitely sounds better than timeout
> > based solutions. I will cook up a patch for this. The API between oom
> > killer and the reaper has to change slightly but that shouldn't be a big
> > deal.
> 
> That is part of what I suggested at
> http://lkml.kernel.org/r/201512052133.IAE00551.LSOQFtMFFVOHOJ@I-love.SAKURA.ne.jp .
> | What about marking current OOM victim unkillable by updating
> | victim->signal->oom_score_adj to OOM_SCORE_ADJ_MIN and clearing victim's
> | TIF_MEMDIE flag when the victim is still alive for a second after
> | oom_reap_vmas() completed?

Sorry, I must have missed this part. I have added your Suggested-by to the
patch description.

> Can we update victim's oom_score_adj as well? Otherwise, the OOM killer
> might choose the same victim if victim's oom_score_adj was set to 1000.

Yes I've done that in the patch I am testing ATM.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
