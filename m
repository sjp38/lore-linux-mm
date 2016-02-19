Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7BD8B6B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 11:01:54 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id gc3so110207628obb.3
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 08:01:54 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a126si17507115oif.21.2016.02.19.08.01.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 08:01:53 -0800 (PST)
Subject: Re: [PATCH] mm,oom: kill duplicated oom_unkillable_task() checks.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1455892411-7611-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160219151043.GI12690@dhcp22.suse.cz>
In-Reply-To: <20160219151043.GI12690@dhcp22.suse.cz>
Message-Id: <201602200101.IBE90199.OSOFMFOLVtJQHF@I-love.SAKURA.ne.jp>
Date: Sat, 20 Feb 2016 01:01:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

Michal Hocko wrote:
> On Fri 19-02-16 23:33:31, Tetsuo Handa wrote:
> > Currently, oom_unkillable_task() is called for twice for each thread,
> > once at oom_scan_process_thread() and again at oom_badness().
> > 
> > The reason oom_scan_process_thread() needs to call oom_unkillable_task()
> > is to skip TIF_MEMDIE test and oom_task_origin() test if that thread is
> > not OOM-killable.
> > 
> > But there is a problem with this ordering, for oom_task_origin() == true
> > will unconditionally select that thread regardless of oom_score_adj.
> > When we merge the OOM reaper, the OOM reaper will mark already reaped
> > process as OOM-unkillable by updating oom_score_adj. In order to avoid
> > falling into infinite loop, oom_score_adj needs to be checked before
> > doing oom_task_origin() test.
> 
> What would be the infinite loop?

Sequence until we merge the OOM reaper:

 (1) select_bad_process() returns p due to oom_task_origin(p) == true.
 (2) oom_kill_process() sends SIGKILL to p and sets TIF_MEMDIE on p.
 (3) p gets stuck at down_read(&mm->mmap_sem) in exit_mm().
 (4) The OOM killer will ignore TIF_MEMDIE on p after some timeout expires.
 (5) select_bad_process() returns p again due to oom_task_origin(p) == true &&
     p->mm != NULL.
 (6) oom_kill_process() will do only

	task_lock(p);
	if (p->mm && task_will_free_mem(p)) {
		mark_oom_victim(p);
		task_unlock(p);
		put_task_struct(p);
		return;
	}
	task_unlock(p);

     which would fail to continue because p already got stuck.

Sequence after we merge the OOM reaper:

 (1) select_bad_process() returns p due to oom_task_origin(p) == true.
 (2) oom_kill_process() sends SIGKILL to p and sets TIF_MEMDIE on p.
 (3) p gets stuck at down_read(&mm->mmap_sem) in exit_mm().
 (4) The OOM reaper will reap p's memory and set
     p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN and clear TIF_MEMDIE on p.
 (5) select_bad_process() returns p again due to oom_task_origin(p) == true &&
     p->mm != NULL.
 (6) oom_kill_process() will do only

	task_lock(p);
	if (p->mm && task_will_free_mem(p)) {
		mark_oom_victim(p);
		task_unlock(p);
		put_task_struct(p);
		return;
	}
	task_unlock(p);

     which would fail to continue because p already got stuck.

The difference is "TIF_MEMDIE is cleared by the OOM reaper" and
"TIF_MEMDIE is ignored by some timeout". This trap can be avoided
by not returning p due to p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN.

Well, if the OOM reaper cannot reap p's memory, skipping TIF_MEMDIE by
some timeout will again select p. Maybe we need to add a flag for
avoid selecting the same task again (e.g. PFA_OOM_NO_RECURSION in
http://lkml.kernel.org/r/201601181335.JJD69226.JHVQSMFOFOFtOL@I-love.SAKURA.ne.jp ).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
