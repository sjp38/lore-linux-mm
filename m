Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5663A6B0253
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 07:26:20 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id u190so23518324pfb.3
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 04:26:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id sk6si3793242pab.138.2016.03.23.04.26.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Mar 2016 04:26:19 -0700 (PDT)
Subject: Re: [PATCH 0/9] oom reaper v6
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
	<alpine.DEB.2.10.1603221507150.22638@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1603221507150.22638@chino.kir.corp.google.com>
Message-Id: <201603232011.HDI05246.FFMLtVOHOQJFOS@I-love.SAKURA.ne.jp>
Date: Wed, 23 Mar 2016 20:11:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, hannes@cmpxchg.org, mgorman@suse.de, mhocko@suse.com, oleg@redhat.com, a.p.zijlstra@chello.nl, vdavydov@virtuozzo.com

David Rientjes wrote:
> On Tue, 22 Mar 2016, Michal Hocko wrote:
> 
> > Hi,
> > I am reposting the whole patchset on top of the current Linus tree which should
> > already contain big pile of Andrew's mm patches. This should serve an easier
> > reviewability and I also hope that this core part of the work can go to 4.6.
> > 
> > The previous version was posted here [1] Hugh and David have suggested to
> > drop [2] because the munlock path currently depends on the page lock and
> > it is better if the initial version was conservative and prevent from
> > any potential lockups even though it is not clear whether they are real
> > - nobody has seen oom_reaper stuck on the page lock AFAICK. Me or Hugh
> > will have a look and try to make the munlock path not depend on the page
> > lock as a follow up work.
> > 
> > Apart from that the feedback revealed one bug for a very unusual
> > configuration (sysctl_oom_kill_allocating_task) and that has been fixed
> > by patch 8 and one potential mis interaction with the pm freezer fixed by
> > patch 7.
> > 
> > I think the current code base is already very useful for many situations.
> > The rest of the feedback was mostly about potential enhancements of the
> > current code which I would really prefer to build on top of the current
> > series. I plan to finish my mmap_sem killable for write in the upcoming
> > release cycle and hopefully have it merged in the next merge window.
> > I believe more extensions will follow.
> > 
> > This code has been sitting in the mmotm (thus linux-next) for a while.
> > Are there any fundamental objections to have this part merged in this
> > merge window?
> > 
> 
> Tetsuo, have you been able to run your previous test cases on top of this 
> version and do you have any concerns about it or possible extensions that 
> could be made?
> 

I think [PATCH 3/9] [PATCH 4/9] [PATCH 8/9] will be mostly reverted.
My concerns and possible extensions are explained in

    Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task
    http://lkml.kernel.org/r/201603152015.JAE86937.VFOLtQFOFJOSHM@I-love.SAKURA.ne.jp

. Regarding "[PATCH 4/9] mm, oom_reaper: report success/failure",
debug_show_all_locks() may not be safe

    commit 856848737bd944c1 "lockdep: fix debug_show_all_locks()"
    commit 82a1fcb90287052a "softlockup: automatically detect hung TASK_UNINTERRUPTIBLE tasks"

and showing traces might be more useful.
(A discussion for making printk() completely async is in progress.)

But we don't have time to update this series before merge window for 4.6 closes.
We want to send current patchset as is for now, don't we? So, please go ahead.



My other concerns about OOM handling:

  Change TIF_MEMDIE strategy from per a thread to per a signal_struct.

    [PATCH] mm,oom: Set TIF_MEMDIE on all OOM-killed threads.
    http://lkml.kernel.org/r/1458529634-5951-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp

  Found a bug in too_many_isolated() assumption.

    How to handle infinite too_many_isolated() loop (for OOM detection rework v4) ?
    http://lkml.kernel.org/r/201602092349.ACG81273.OSVtMJQHLOFOFF@I-love.SAKURA.ne.jp

  Waiting for a patch to be merged.

    [PATCH] mm,writeback: Don't use memory reserves for wb_start_writeback
    http://lkml.kernel.org/r/20160318134230.GC30225@dhcp22.suse.cz

  And, kmallocwd, __GFP_KILLABLE, and timeout (or something finite one) for TIF_MEMDIE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
