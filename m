Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB486B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 08:17:50 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id i64so39367088ith.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 05:17:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l2si16755230otb.180.2016.07.19.05.17.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 05:17:49 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: fix for hiding mm which is shared with kthread or global init
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607190630.DIH34854.HFOOQFLOJMVFSt@I-love.SAKURA.ne.jp>
	<20160719064048.GA9486@dhcp22.suse.cz>
	<20160719093739.GE9486@dhcp22.suse.cz>
	<201607191936.BEJ82340.OHFOtOFFSQMJVL@I-love.SAKURA.ne.jp>
	<20160719105440.GF9486@dhcp22.suse.cz>
In-Reply-To: <20160719105440.GF9486@dhcp22.suse.cz>
Message-Id: <201607192043.CEI28519.VtQOMFFSFLOJOH@I-love.SAKURA.ne.jp>
Date: Tue, 19 Jul 2016 20:43:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, vdavydov@virtuozzo.com, rientjes@google.com

Michal Hocko wrote:
> On Tue 19-07-16 19:36:40, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 19-07-16 08:40:48, Michal Hocko wrote:
> > > > On Tue 19-07-16 06:30:42, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > > > > > I really do not think that this unlikely case really has to be handled
> > > > > > now. We are very likely going to move to a different model of oom victim
> > > > > > detection soon. So let's do not add new hacks. exit_oom_victim from
> > > > > > oom_kill_process just looks like sand in eyes.
> > > > > 
> > > > > Then, please revert "mm, oom: hide mm which is shared with kthread or global init"
> > > > > ( http://lkml.kernel.org/r/1466426628-15074-11-git-send-email-mhocko@kernel.org ).
> > > > > I don't like that patch because it is doing pointless find_lock_task_mm() test
> > > > > and is telling a lie because it does not guarantee that we won't hit OOM livelock.
> > > > 
> > > > The above patch doesn't make the situation worse wrt livelock. I
> > > > consider it an improvement. It adds find_lock_task_mm into
> > > > oom_scan_process_thread but that can hardly be worse than just the
> > > > task->signal->oom_victims check because we can catch MMF_OOM_REAPED. If
> > > > we are mm loss, which is a less likely case, then we behave the same as
> > > > with the previous implementation.
> > > > 
> > > > So I do not really see a reason to revert that patch for now.
> > > 
> > > And that being said. If you strongly disagree with the wording then what
> > > about the following:
> > > "
> > >     In order to help a forward progress for the OOM killer, make sure that
> > >     this really rare cases will not get into the way and hide the mm from the
> > >     oom killer by setting MMF_OOM_REAPED flag for it.  oom_scan_process_thread
> > >     will ignore any TIF_MEMDIE task if it has MMF_OOM_REAPED flag set to catch
> > >     these oom victims.
> > >     
> > >     After this patch we should guarantee a forward progress for the OOM killer
> > >     even when the selected victim is sharing memory with a kernel thread or
> > >     global init as long as the victims mm is still alive.
> > > "
> > 
> > No, I don't like "as long as the victims mm is still alive" exception.
> 
> Why? Because of the wording or in principle?

Making a _guarantee without exceptions now_ can allow other OOM livelock handlings
(e.g. http://lkml.kernel.org/r/20160719074935.GC9486@dhcp22.suse.cz ) to rely on
the OOM reaper. We can improve OOM reaper after we made a guarantee without
exceptions now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
