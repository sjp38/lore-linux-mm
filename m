Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 570E96B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 05:37:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p129so8313304wmp.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 02:37:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q190si19000843wmd.73.2016.07.19.02.37.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 02:37:42 -0700 (PDT)
Date: Tue, 19 Jul 2016 11:37:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, oom: fix for hiding mm which is shared with
 kthreador global init
Message-ID: <20160719093739.GE9486@dhcp22.suse.cz>
References: <1468647004-5721-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160718071825.GB22671@dhcp22.suse.cz>
 <201607190630.DIH34854.HFOOQFLOJMVFSt@I-love.SAKURA.ne.jp>
 <20160719064048.GA9486@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160719064048.GA9486@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, vdavydov@virtuozzo.com, rientjes@google.com

On Tue 19-07-16 08:40:48, Michal Hocko wrote:
> On Tue 19-07-16 06:30:42, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > I really do not think that this unlikely case really has to be handled
> > > now. We are very likely going to move to a different model of oom victim
> > > detection soon. So let's do not add new hacks. exit_oom_victim from
> > > oom_kill_process just looks like sand in eyes.
> > 
> > Then, please revert "mm, oom: hide mm which is shared with kthread or global init"
> > ( http://lkml.kernel.org/r/1466426628-15074-11-git-send-email-mhocko@kernel.org ).
> > I don't like that patch because it is doing pointless find_lock_task_mm() test
> > and is telling a lie because it does not guarantee that we won't hit OOM livelock.
> 
> The above patch doesn't make the situation worse wrt livelock. I
> consider it an improvement. It adds find_lock_task_mm into
> oom_scan_process_thread but that can hardly be worse than just the
> task->signal->oom_victims check because we can catch MMF_OOM_REAPED. If
> we are mm loss, which is a less likely case, then we behave the same as
> with the previous implementation.
> 
> So I do not really see a reason to revert that patch for now.

And that being said. If you strongly disagree with the wording then what
about the following:
"
    In order to help a forward progress for the OOM killer, make sure that
    this really rare cases will not get into the way and hide the mm from the
    oom killer by setting MMF_OOM_REAPED flag for it.  oom_scan_process_thread
    will ignore any TIF_MEMDIE task if it has MMF_OOM_REAPED flag set to catch
    these oom victims.
    
    After this patch we should guarantee a forward progress for the OOM killer
    even when the selected victim is sharing memory with a kernel thread or
    global init as long as the victims mm is still alive.
"
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
