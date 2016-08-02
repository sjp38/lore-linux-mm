Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD346B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 06:32:57 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id e139so354655446oib.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 03:32:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v63si895100oif.204.2016.08.02.03.32.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 03:32:56 -0700 (PDT)
Subject: Re: [PATCH 08/10] exit, oom: postpone exit_oom_victim to later
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1469734954-31247-9-git-send-email-mhocko@kernel.org>
	<201607301720.GHG43737.JLVtHOOSQOFFMF@I-love.SAKURA.ne.jp>
	<20160731093530.GB22397@dhcp22.suse.cz>
	<201608011946.JAI56255.HJLOtSMFOFOVQF@I-love.SAKURA.ne.jp>
	<20160801113304.GD13544@dhcp22.suse.cz>
In-Reply-To: <20160801113304.GD13544@dhcp22.suse.cz>
Message-Id: <201608021932.IFA41217.FHtFLOOOQVJMFS@I-love.SAKURA.ne.jp>
Date: Tue, 2 Aug 2016 19:32:45 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com

Michal Hocko wrote:
> > > > It is possible that a user creates a process with 10000 threads
> > > > and let that process be OOM-killed. Then, this patch allows 10000 threads
> > > > to start consuming memory reserves after they left exit_mm(). OOM victims
> > > > are not the only threads who need to allocate memory for termination. Non
> > > > OOM victims might need to allocate memory at exit_task_work() in order to
> > > > allow OOM victims to make forward progress.
> > > 
> > > this might be possible but unlike the regular exiting tasks we do
> > > reclaim oom victim's memory in the background. So while they can consume
> > > memory reserves we should also give some (and arguably much more) memory
> > > back. The reserves are there to expedite the exit.
> > 
> > Background reclaim does not occur on CONFIG_MMU=n kernels. But this patch
> > also affects CONFIG_MMU=n kernels. If a process with two threads was
> > OOM-killed and one thread consumed too much memory after it left exit_mm()
> > before the other thread sets MMF_OOM_SKIP on their mm by returning from
> > exit_aio() etc. in __mmput() from mmput() from exit_mm(), this patch
> > introduces a new possibility to OOM livelock. I think it is wild to assume
> > that "CONFIG_MMU=n kernels can OOM livelock even without this patch. Thus,
> > let's apply this patch even though this patch might break the balance of
> > OOM handling in CONFIG_MMU=n kernels."
> 
> As I've said if you have strong doubts about the patch I can drop it for
> now. I do agree that nommu really matters here, though.

OK. Then, for now let's postpone only the oom_killer_disbale() to later
rather than postpone the exit_oom_victim() to later.

> 
> > Also, where is the guarantee that memory reclaimed by the OOM reaper is
> > used for terminating exiting threads?
> 
> As the oom reaper replenishes the memory the oom victim should be able
> to consume that memory in favor of other processes exactly because it
> has access to memory reserves which others are not.

The difficult thing is that TIF_MEMDIE (or signal->oom_mm != NULL) threads
are not always the only threads which need to allocate memory in order to
make forward progress. Some kernel threads might need to allocate memory
in order to allow TIF_MEMDIE (or signal->oom_mm != NULL) threads to make
forward progress, but they don't have acess to memory reserves.

Anyway, this is out of scope if we for now postpone only
the oom_killer_disbale() to later.

> > > > I think that allocations from
> > > > do_exit() are important for terminating cleanly (from the point of view of
> > > > filesystem integrity and kernel object management) and such allocations
> > > > should not be given up simply because ALLOC_NO_WATERMARKS allocations
> > > > failed.
> > > 
> > > We are talking about a fatal condition when OOM killer forcefully kills
> > > a task. Chances are that the userspace leaves so much state behind that
> > > a manual cleanup would be necessary anyway. Depleting the memory
> > > reserves is not nice but I really believe that this particular patch
> > > doesn't make the situation really much worse than before.
> > 
> > I'm not talking about inconsistency in userspace programs. I'm talking
> > about inconsistency of objects managed by kernel (e.g. failing to drop
> > references) caused by allocation failures.
> 
> That would be a bug on its own, no?

Right, but memory allocations after exit_mm() from do_exit() (e.g.
exit_task_work()) might assume (or depend on) the "too small to fail"
memory-allocation rule where small GFP_FS allocations won't fail unless
TIF_MEMDIE is set, but this patch can unexpectedly break that rule if
they assume (or depend on) that rule.

>  
> > > > > There is possible advantages of this because we are reducing chances
> > > > > of further interference of the oom victim with the rest of the system
> > > > > after oom_killer_disable(). Strictly speaking this is possible right
> > > > > now because there are indeed allocations possible past exit_mm() and
> > > > > who knows whether some of them can trigger IO. I haven't seen this in
> > > > > practice though.
> > > > 
> > > > I don't know which I/O oom_killer_disable() must act as a hard barrier.
> > > 
> > > Any allocation that could trigger the IO can corrupt the hibernation
> > > image or access the half suspended device. The whole point of
> > > oom_killer_disable is to prevent anything like that to happen.
> > 
> > That's a puzzling answer. What I/O? If fs writeback done by a GFP_FS
> > allocation issued by userspace processes between after returning from
> > exit_mm() and reaching final schedule() in do_exit() is problematic, why
> > fs writeback issued by a GFP_FS allocation done by kernel threads after
> > returning from oom_killer_disable() is not problematic? I think any I/O
> > which userspace processes can do is also doable by kernel threads.
> > Where is the guarantee that kernel threads which do I/O which
> > oom_killer_disable() acts as a hard barrier do not corrupt the hibernation
> > image or access the half suspended device?
> 
> This has been discussed several times already. I do not have a link
> handy but it should be there in the archives. I am sorry and do not want
> to be rude here but I guess this is only tangential to this particular
> patch series so I would prefer not discussing PM consequences. PM
> suspend is describe to expect no _user_ activity after oom_killer_disable.
> If you are questioning that assumption then please do that in a separate
> thread.
> 

OK. Well, it seems to me that pm_restrict_gfp_mask() is called from
enter_state() in kernel/power/suspend.c which is really late stage of
suspend operation. This suggests that fs writeback done by a GFP_FS
allocation issued by kernel threads after returning from oom_killer_disable()
is not problematic. Though I don't know whether it is safe that we do not
have a synchronization mechanism to wait for non freezable kernel threads
which are between post

  gfp_mask &= gfp_allowed_mask;

line in __alloc_pages_nodemask() and pre

  if (pm_suspended_storage())
      goto out;

line in __alloc_pages_may_oom() after pm_restrict_gfp_mask() is called.
Presumably we are assuming that we are no longer under memory pressure
so that no I/O will be needed for allocations by the moment
pm_restrict_gfp_mask() is called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
