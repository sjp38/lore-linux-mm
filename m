Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id D62A16B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 12:34:59 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id z135so117091094iof.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 09:34:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h65si22704407ioi.100.2016.02.19.09.34.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 09:34:59 -0800 (PST)
Subject: Re: [PATCH] mm,oom: kill duplicated oom_unkillable_task() checks.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1455892411-7611-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160219151043.GI12690@dhcp22.suse.cz>
	<201602200101.IBE90199.OSOFMFOLVtJQHF@I-love.SAKURA.ne.jp>
	<20160219171533.GA23376@dhcp22.suse.cz>
In-Reply-To: <20160219171533.GA23376@dhcp22.suse.cz>
Message-Id: <201602200234.DGG56738.LQFMFJFtOOVSOH@I-love.SAKURA.ne.jp>
Date: Sat, 20 Feb 2016 02:34:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

Michal Hocko wrote:
> On Sat 20-02-16 01:01:36, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 19-02-16 23:33:31, Tetsuo Handa wrote:
> > > > Currently, oom_unkillable_task() is called for twice for each thread,
> > > > once at oom_scan_process_thread() and again at oom_badness().
> > > > 
> > > > The reason oom_scan_process_thread() needs to call oom_unkillable_task()
> > > > is to skip TIF_MEMDIE test and oom_task_origin() test if that thread is
> > > > not OOM-killable.
> > > > 
> > > > But there is a problem with this ordering, for oom_task_origin() == true
> > > > will unconditionally select that thread regardless of oom_score_adj.
> > > > When we merge the OOM reaper, the OOM reaper will mark already reaped
> > > > process as OOM-unkillable by updating oom_score_adj. In order to avoid
> > > > falling into infinite loop, oom_score_adj needs to be checked before
> > > > doing oom_task_origin() test.
> > > 
> > > What would be the infinite loop?
> > 
> > Sequence until we merge the OOM reaper:
> > 
> >  (1) select_bad_process() returns p due to oom_task_origin(p) == true.
> >  (2) oom_kill_process() sends SIGKILL to p and sets TIF_MEMDIE on p.
> >  (3) p gets stuck at down_read(&mm->mmap_sem) in exit_mm().
> >  (4) The OOM killer will ignore TIF_MEMDIE on p after some timeout expires.
> >  (5) select_bad_process() returns p again due to oom_task_origin(p) == true &&
> >      p->mm != NULL.
> 
> And one more thing. The task will stop being oom_task_origin right
> after it detects signal pending and retuns from try_to_unuse resp.
> unmerge_and_remove_all_rmap_items.

That's good. Then, we don't need to worry about oom_task_origin() case.
So, the purpose of this "[PATCH] mm,oom: kill duplicated oom_unkillable_task()
checks." became only to save oom_unkillable_task() call.

I'm trying to update select_bad_process() to use for_each_process() rather than
for_each_process_thread(). If we can do it, I think we can use is_oom_victim()
and respond to your concern

  | This will make the scanning much more time consuming (you will check
  | all the threads in the same thread group for each scanned thread!). I
  | do not think this is acceptable and it is not really needed for the
  | !is_sysrq_oom because we are scanning all the threads anyway.

while excluding TIF_MEMDIE processes from candidates.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
