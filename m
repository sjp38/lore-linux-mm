Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id D20A56B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 11:17:40 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id g62so75536081wme.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 08:17:40 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id mc5si18842101wjb.99.2016.02.19.08.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 08:17:39 -0800 (PST)
Received: by mail-wm0-f44.google.com with SMTP id a4so77879647wme.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 08:17:39 -0800 (PST)
Date: Fri, 19 Feb 2016 17:17:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: kill duplicated oom_unkillable_task() checks.
Message-ID: <20160219161738.GK12690@dhcp22.suse.cz>
References: <1455892411-7611-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160219151043.GI12690@dhcp22.suse.cz>
 <201602200101.IBE90199.OSOFMFOLVtJQHF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602200101.IBE90199.OSOFMFOLVtJQHF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

On Sat 20-02-16 01:01:36, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 19-02-16 23:33:31, Tetsuo Handa wrote:
> > > Currently, oom_unkillable_task() is called for twice for each thread,
> > > once at oom_scan_process_thread() and again at oom_badness().
> > > 
> > > The reason oom_scan_process_thread() needs to call oom_unkillable_task()
> > > is to skip TIF_MEMDIE test and oom_task_origin() test if that thread is
> > > not OOM-killable.
> > > 
> > > But there is a problem with this ordering, for oom_task_origin() == true
> > > will unconditionally select that thread regardless of oom_score_adj.
> > > When we merge the OOM reaper, the OOM reaper will mark already reaped
> > > process as OOM-unkillable by updating oom_score_adj. In order to avoid
> > > falling into infinite loop, oom_score_adj needs to be checked before
> > > doing oom_task_origin() test.
> > 
> > What would be the infinite loop?
> 
> Sequence until we merge the OOM reaper:
> 
>  (1) select_bad_process() returns p due to oom_task_origin(p) == true.
>  (2) oom_kill_process() sends SIGKILL to p and sets TIF_MEMDIE on p.
>  (3) p gets stuck at down_read(&mm->mmap_sem) in exit_mm().

How would this happen? oom_task_origin is swapoff resp run_store (which
triggers KSM). While theoretically both can be done from multithreaded
process, does this happen in reality? I seriously doubt so. Doing many
changes in an already complex code for non-realistic cases sounds like a
bad idea to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
