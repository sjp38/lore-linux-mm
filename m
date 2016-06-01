Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71EDA6B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 03:34:45 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id j12so5253795lbo.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 00:34:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d76si41721586wma.63.2016.06.01.00.34.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 00:34:43 -0700 (PDT)
Date: Wed, 1 Jun 2016 09:34:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm,oom: Allow SysRq-f to always select !TIF_MEMDIE
 thread group.
Message-ID: <20160601073441.GE26601@dhcp22.suse.cz>
References: <1464432784-6058-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1464452714-5126-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160531131159.GL26128@dhcp22.suse.cz>
 <201606010635.HJI86975.JOFOFFMQHLVtSO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606010635.HJI86975.JOFOFFMQHLVtSO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com

On Wed 01-06-16 06:35:30, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sun 29-05-16 01:25:14, Tetsuo Handa wrote:
> > > There has been three problems about SysRq-f (manual invocation of the OOM
> > > killer) case. To make description simple, this patch assumes situation
> > > where the OOM reaper is not called (because the OOM victim's mm is shared
> > > by unkillable threads) or not available (due to kthread_run() failure or
> > > CONFIG_MMU=n).
> > > 
> > > First is that moom_callback() is not called by moom_work under OOM
> > > livelock situation because it does not have a dedicated WQ like vmstat_wq.
> > > This problem is not fixed yet.
> > 
> > Why do you mention it in the changelog when it is not related to the
> > patch then?
> 
> Just we won't forget about it.

OK, then this belongs to a cover letter. Discussing unrelated things in
the patch description might end up being just confusing.
 
> > Btw. you can (ab)use oom_reaper for that purpose. The patch would be
> > quite trivial.
> 
> How do you handle CONFIG_MMU=n case?

void schedule_sysrq_oom(void)
{
	if (IS_ENABLED(CONFIG_MMU) && oom_reaper_th)
		kick_oom_reaper()
	else
		schedule_work(&moom_work);
}

[...]
> > > But SysRq-f case will
> > > select such thread group due to returning OOM_SCAN_OK. This patch makes
> > > sure that oom_badness() is skipped by making oom_scan_process_group() to
> > > return OOM_SCAN_CONTINUE for SysRq-f case.
> > 
> > I am OK with this part. I was suggesting something similar except I
> > wanted to skip over tasks which have fatal_signal_pending and that part
> > got nacked by David AFAIR. Could you make this a separate patch, please?
> 
> I think it is better to change both part with this patch.

They are semantically different (one is sysrq specific while the other
is not) so I would prefer to split them up.
 
> > > Third is that oom_kill_process() chooses a thread group which already
> > > has a TIF_MEMDIE thread when the candidate select_bad_process() chose
> > > has children because oom_badness() does not take TIF_MEMDIE into account.
> > > This patch checks child->signal->oom_victims before calling oom_badness()
> > > if oom_kill_process() was called by SysRq-f case. This resembles making
> > > sure that oom_badness() is skipped by returning OOM_SCAN_CONTINUE.
> > 
> > This makes sense to me as well but why should be limit this to sysrq case?
> > Does it make any sense to select a child which already got killed for
> > normal OOM killer? Anyway I think it would be better to split this into
> > its own patch as well.
> 
> The reason is described in next paragraph.
> Do we prefer immediately killing all children of the allocating task?

I do not think we want to select them _all_. We haven't been doing that
and I do not see a reason we should start now. But it surely doesn't
make any sense to select a task which has already TIF_MEMDIE set.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
