Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8EB828F6
	for <linux-mm@kvack.org>; Sun, 31 Jul 2016 05:35:35 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so58698086lfe.0
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 02:35:35 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id s70si11150375wme.140.2016.07.31.02.35.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Jul 2016 02:35:33 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id o80so205167355wme.1
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 02:35:33 -0700 (PDT)
Date: Sun, 31 Jul 2016 11:35:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 08/10] exit, oom: postpone exit_oom_victim to later
Message-ID: <20160731093530.GB22397@dhcp22.suse.cz>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
 <1469734954-31247-9-git-send-email-mhocko@kernel.org>
 <201607301720.GHG43737.JLVtHOOSQOFFMF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607301720.GHG43737.JLVtHOOSQOFFMF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com

On Sat 30-07-16 17:20:30, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > exit_oom_victim was called after mmput because it is expected that
> > address space of the victim would get released by that time and there is
> > no reason to hold off the oom killer from selecting another task should
> > that be insufficient to handle the oom situation. In order to catch
> > post exit_mm() allocations we used to check for PF_EXITING but this
> > got removed by 6a618957ad17 ("mm: oom_kill: don't ignore oom score on
> > exiting tasks") because this check was lockup prone.
> > 
> > It seems that we have all needed pieces ready now and can finally
> > fix this properly (at least for CONFIG_MMU cases where we have the
> > oom_reaper).  Since "oom: keep mm of the killed task available" we have
> > a reliable way to ignore oom victims which are no longer interesting
> > because they either were reaped and do not sit on a lot of memory or
> > they are not reapable for some reason and it is safer to ignore them
> > and move on to another victim. That means that we can safely postpone
> > exit_oom_victim to closer to the final schedule.
> 
> I don't like this patch. The advantage of this patch will be that we can
> avoid selecting next OOM victim when only OOM victims need to allocate
> memory after they left exit_mm().

Not really as we do not rely on TIF_MEMDIE nor signal->oom_victims to
block new oom victim selection anymore.

> But the disadvantage of this patch will
> be that we increase the possibility of depleting 100% of memory reserves
> by allowing them to allocate using ALLOC_NO_WATERMARKS after they left
> exit_mm().

I think this is a separate problem. As the current code stands we can
already deplete memory reserves. The large number of threads might be
sitting in an allocation loop before they bail out to handle the
SIGKILL. Exit path shouldn't add too much on top of that. If we want to
be reliable in not consuming all the reserves we would have to employ
some form of throttling and that is out of scope of this patch.

> It is possible that a user creates a process with 10000 threads
> and let that process be OOM-killed. Then, this patch allows 10000 threads
> to start consuming memory reserves after they left exit_mm(). OOM victims
> are not the only threads who need to allocate memory for termination. Non
> OOM victims might need to allocate memory at exit_task_work() in order to
> allow OOM victims to make forward progress.

this might be possible but unlike the regular exiting tasks we do
reclaim oom victim's memory in the background. So while they can consume
memory reserves we should also give some (and arguably much more) memory
back. The reserves are there to expedite the exit.

> I think that allocations from
> do_exit() are important for terminating cleanly (from the point of view of
> filesystem integrity and kernel object management) and such allocations
> should not be given up simply because ALLOC_NO_WATERMARKS allocations
> failed.

We are talking about a fatal condition when OOM killer forcefully kills
a task. Chances are that the userspace leaves so much state behind that
a manual cleanup would be necessary anyway. Depleting the memory
reserves is not nice but I really believe that this particular patch
doesn't make the situation really much worse than before.
 
> > There is possible advantages of this because we are reducing chances
> > of further interference of the oom victim with the rest of the system
> > after oom_killer_disable(). Strictly speaking this is possible right
> > now because there are indeed allocations possible past exit_mm() and
> > who knows whether some of them can trigger IO. I haven't seen this in
> > practice though.
> 
> I don't know which I/O oom_killer_disable() must act as a hard barrier.

Any allocation that could trigger the IO can corrupt the hibernation
image or access the half suspended device. The whole point of
oom_killer_disable is to prevent anything like that to happen.

> But safer way is to get rid of TIF_MEMDIE's triple meanings. The first
> one which prevents the OOM killer from selecting next OOM victim was
> removed by replacing TIF_MEMDIE test in oom_scan_process_thread() with
> tsk_is_oom_victim(). The second one which allows the OOM victims to
> deplete 100% of memory reserves wants some changes in order not to
> block memory allocations by non OOM victims (e.g. GFP_ATOMIC allocations
> by interrupt handlers, GFP_NOIO / GFP_NOFS allocations by subsystems
> which are needed for making forward progress of threads in do_exit())
> by consuming too much of memory reserves. The third one which blocks
> oom_killer_disable() can be removed by replacing TIF_MEMDIE test in
> exit_oom_victim() with PFA_OOM_WAITING test like below patch.

I plan to remove TIF_MEMDIE dependency for this as well but I would like
to finish this pile first. We actually do not need any flag for that. We
just need to detect last exiting thread and tsk_is_oom_victim. I have
some preliminary code for that.

> (If
> oom_killer_disable() were specific to CONFIG_MMU=y kernels, I think
> that not thawing OOM victims will be simpler because the OOM reaper
> can reclaim memory without thawing OOM victims.)

Well I do not think keeping an oom victim inside the fridge is a good
idea. The task might be not sitting on any reclaimable memory but it
still might consume resources which are bound to its life time (open
files and their buffers etc.).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
