Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A02506B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 07:31:32 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p85so92428928lfg.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 04:31:32 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id ax6si2125814wjc.277.2016.08.02.04.31.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 04:31:31 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id i5so285436737wmg.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 04:31:31 -0700 (PDT)
Date: Tue, 2 Aug 2016 13:31:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 08/10] exit, oom: postpone exit_oom_victim to later
Message-ID: <20160802113129.GE12403@dhcp22.suse.cz>
References: <1469734954-31247-9-git-send-email-mhocko@kernel.org>
 <201607301720.GHG43737.JLVtHOOSQOFFMF@I-love.SAKURA.ne.jp>
 <20160731093530.GB22397@dhcp22.suse.cz>
 <201608011946.JAI56255.HJLOtSMFOFOVQF@I-love.SAKURA.ne.jp>
 <20160801113304.GD13544@dhcp22.suse.cz>
 <201608021932.IFA41217.FHtFLOOOQVJMFS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201608021932.IFA41217.FHtFLOOOQVJMFS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com

On Tue 02-08-16 19:32:45, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > > It is possible that a user creates a process with 10000 threads
> > > > > and let that process be OOM-killed. Then, this patch allows 10000 threads
> > > > > to start consuming memory reserves after they left exit_mm(). OOM victims
> > > > > are not the only threads who need to allocate memory for termination. Non
> > > > > OOM victims might need to allocate memory at exit_task_work() in order to
> > > > > allow OOM victims to make forward progress.
> > > > 
> > > > this might be possible but unlike the regular exiting tasks we do
> > > > reclaim oom victim's memory in the background. So while they can consume
> > > > memory reserves we should also give some (and arguably much more) memory
> > > > back. The reserves are there to expedite the exit.
> > > 
> > > Background reclaim does not occur on CONFIG_MMU=n kernels. But this patch
> > > also affects CONFIG_MMU=n kernels. If a process with two threads was
> > > OOM-killed and one thread consumed too much memory after it left exit_mm()
> > > before the other thread sets MMF_OOM_SKIP on their mm by returning from
> > > exit_aio() etc. in __mmput() from mmput() from exit_mm(), this patch
> > > introduces a new possibility to OOM livelock. I think it is wild to assume
> > > that "CONFIG_MMU=n kernels can OOM livelock even without this patch. Thus,
> > > let's apply this patch even though this patch might break the balance of
> > > OOM handling in CONFIG_MMU=n kernels."
> > 
> > As I've said if you have strong doubts about the patch I can drop it for
> > now. I do agree that nommu really matters here, though.
> 
> OK. Then, for now let's postpone only the oom_killer_disbale() to later
> rather than postpone the exit_oom_victim() to later.

that would require other changes (basically make oom_killer_disbale
independent on TIF_MEMDIE) which I think doesn't belong to this pile. So
I would rather sacrifice this patch instead and it will not be part of
the v2.
 
[...]
> > > > > I think that allocations from
> > > > > do_exit() are important for terminating cleanly (from the point of view of
> > > > > filesystem integrity and kernel object management) and such allocations
> > > > > should not be given up simply because ALLOC_NO_WATERMARKS allocations
> > > > > failed.
> > > > 
> > > > We are talking about a fatal condition when OOM killer forcefully kills
> > > > a task. Chances are that the userspace leaves so much state behind that
> > > > a manual cleanup would be necessary anyway. Depleting the memory
> > > > reserves is not nice but I really believe that this particular patch
> > > > doesn't make the situation really much worse than before.
> > > 
> > > I'm not talking about inconsistency in userspace programs. I'm talking
> > > about inconsistency of objects managed by kernel (e.g. failing to drop
> > > references) caused by allocation failures.
> > 
> > That would be a bug on its own, no?
> 
> Right, but memory allocations after exit_mm() from do_exit() (e.g.
> exit_task_work()) might assume (or depend on) the "too small to fail"
> memory-allocation rule where small GFP_FS allocations won't fail unless
> TIF_MEMDIE is set, but this patch can unexpectedly break that rule if
> they assume (or depend on) that rule.

Silent dependency on nofail semantic withtou GFP_NOFAIL is still a bug.
Full stop. I really fail to see why you are still arguing about that.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
