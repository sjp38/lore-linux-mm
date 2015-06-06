Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id EA453900016
	for <linux-mm@kvack.org>; Sat,  6 Jun 2015 03:36:09 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so63235297pab.3
        for <linux-mm@kvack.org>; Sat, 06 Jun 2015 00:36:09 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id nh4si14106018pdb.70.2015.06.06.00.36.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 06 Jun 2015 00:36:08 -0700 (PDT)
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is configured
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz>
	<alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com>
	<20150605111302.GB26113@dhcp22.suse.cz>
In-Reply-To: <20150605111302.GB26113@dhcp22.suse.cz>
Message-Id: <201506061551.BHH48489.QHFOMtFLSOFOJV@I-love.SAKURA.ne.jp>
Date: Sat, 6 Jun 2015 15:51:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, rientjes@google.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > > Let's move check_panic_on_oom up before the current task is
> > > checked so that the knob value is . Do the same for the memcg in
> > > mem_cgroup_out_of_memory.
> > > 
> > > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > 
> > Nack, this is not the appropriate response to exit path livelocks.  By 
> > doing this, you are going to start unnecessarily panicking machines that 
> > have panic_on_oom set when it would not have triggered before.  If there 
> > is no reclaimable memory and a process that has already been signaled to 
> > die to is in the process of exiting has to allocate memory, it is 
> > perfectly acceptable to give them access to memory reserves so they can 
> > allocate and exit.  Under normal circumstances, that allows the process to 
> > naturally exit.  With your patch, it will cause the machine to panic.
> 
> Isn't that what the administrator of the system wants? The system
> is _clearly_ out of memory at this point. A coincidental exiting task
> doesn't change a lot in that regard. Moreover it increases a risk of
> unnecessarily unresponsive system which is what panic_on_oom tries to
> prevent from. So from my POV this is a clear violation of the user
> policy.

For me, !__GFP_FS allocations not calling out_of_memory() _forever_ is a
violation of the user policy.

If kswapd found nothing more to reclaim and/or kswapd cannot continue
reclaiming due to lock dependency, can't we consider as out of memory
because we already tried to reclaim memory which would have been done by
__GFP_FS allocations?

Why do we do "!__GFP_FS allocations do not call out_of_memory() because
they have very limited reclaim ability"? Both GFP_NOFS and GFP_NOIO
allocations will wake up kswapd due to !__GFP_NO_KSWAPD, doesn't it?

Are objects reclaimed by kswapd and objects reclaimed by __GFP_FS allocations
differ? If yes, we could introduce a proxy kernel thread which does __GFP_FS
allocations on behalf of !__GFP_FS allocators, and notify !__GFP_FS allocators
of completion. If no, why not to call out_of_memory() when kswapd found nothing
more to reclaim and/or kswapd cannot continue reclaiming due to lock dependency?

At least, I expect some warning like check_hung_task() in kernel/hung_task.c
is emitted when memory allocation livelock/deadlock is suspected. That will
help detecting unresponsive systems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
