Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 086A56B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 18:25:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s73so1154725pfs.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 15:25:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s15si46321328pfj.65.2016.05.31.15.25.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 15:25:05 -0700 (PDT)
Subject: Re: [PATCH v2] mm,oom: Allow SysRq-f to always select !TIF_MEMDIE thread group.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464432784-6058-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<1464452714-5126-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160531131159.GL26128@dhcp22.suse.cz>
In-Reply-To: <20160531131159.GL26128@dhcp22.suse.cz>
Message-Id: <201606010635.HJI86975.JOFOFFMQHLVtSO@I-love.SAKURA.ne.jp>
Date: Wed, 1 Jun 2016 06:35:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com

Michal Hocko wrote:
> On Sun 29-05-16 01:25:14, Tetsuo Handa wrote:
> > There has been three problems about SysRq-f (manual invocation of the OOM
> > killer) case. To make description simple, this patch assumes situation
> > where the OOM reaper is not called (because the OOM victim's mm is shared
> > by unkillable threads) or not available (due to kthread_run() failure or
> > CONFIG_MMU=n).
> > 
> > First is that moom_callback() is not called by moom_work under OOM
> > livelock situation because it does not have a dedicated WQ like vmstat_wq.
> > This problem is not fixed yet.
> 
> Why do you mention it in the changelog when it is not related to the
> patch then?

Just we won't forget about it.

> 
> Btw. you can (ab)use oom_reaper for that purpose. The patch would be
> quite trivial.

How do you handle CONFIG_MMU=n case?
Are we going to provide oom_reaper for CONFIG_MMU=n case?

> 
> > Second is that select_bad_process() chooses a thread group which already
> > has a TIF_MEMDIE thread. Since commit f44666b04605d1c7 ("mm,oom: speed up
> > select_bad_process() loop") changed oom_scan_process_group() to use
> > task->signal->oom_victims, non SysRq-f case will no longer select a
> > thread group which already has a TIF_MEMDIE thread.
> 
> I am not sure the reference to the commit is really helpful. The
> behavior you are describing below was there before this commit, the only
> thing that has changed is the scope of the TIF_MEMDIE check.

Indeed. Traversing on all threads can always find a thread group which
already has a TIF_MEMDIE thread when there is already a TIF_MEMDIE thread.

> 
> > But SysRq-f case will
> > select such thread group due to returning OOM_SCAN_OK. This patch makes
> > sure that oom_badness() is skipped by making oom_scan_process_group() to
> > return OOM_SCAN_CONTINUE for SysRq-f case.
> 
> I am OK with this part. I was suggesting something similar except I
> wanted to skip over tasks which have fatal_signal_pending and that part
> got nacked by David AFAIR. Could you make this a separate patch, please?

I think it is better to change both part with this patch.

> 
> > Third is that oom_kill_process() chooses a thread group which already
> > has a TIF_MEMDIE thread when the candidate select_bad_process() chose
> > has children because oom_badness() does not take TIF_MEMDIE into account.
> > This patch checks child->signal->oom_victims before calling oom_badness()
> > if oom_kill_process() was called by SysRq-f case. This resembles making
> > sure that oom_badness() is skipped by returning OOM_SCAN_CONTINUE.
> 
> This makes sense to me as well but why should be limit this to sysrq case?
> Does it make any sense to select a child which already got killed for
> normal OOM killer? Anyway I think it would be better to split this into
> its own patch as well.

The reason is described in next paragraph.
Do we prefer immediately killing all children of the allocating task?
If yes, I think it should be a separate patch on top of this patch because
somebody might complain such behavior as a regression.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
