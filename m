Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C29CA6B0279
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 10:12:59 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id n18so7636209wra.11
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 07:12:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e68si3159416wmc.117.2017.06.16.07.12.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 07:12:58 -0700 (PDT)
Date: Fri, 16 Jun 2017 16:12:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is
 freed
Message-ID: <20170616141255.GN30580@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com>
 <20170615103909.GG1486@dhcp22.suse.cz>
 <alpine.DEB.2.10.1706151420300.95906@chino.kir.corp.google.com>
 <20170615214133.GB20321@dhcp22.suse.cz>
 <201706162122.ACE95321.tOFLOOVFFHMSJQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706162122.ACE95321.tOFLOOVFFHMSJQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-06-17 21:22:20, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > OK, could you play with the patch/idea suggested in
> > http://lkml.kernel.org/r/20170615122031.GL1486@dhcp22.suse.cz?
> 
> I think we don't need to worry about mmap_sem dependency inside __mmput().
> Since the OOM killer checks for !MMF_OOM_SKIP mm rather than TIF_MEMDIE thread,
> we can keep the OOM killer disabled until we set MMF_OOM_SKIP to the victim's mm.
> That is, elevating mm_users throughout the reaping procedure does not cause
> premature victim selection, even after TIF_MEMDIE is cleared from the victim's
> thread. Then, we don't need to use down_write()/up_write() for non OOM victim's mm
> (nearly 100% of exit_mmap() calls), and can force partial reaping of OOM victim's mm
> (nearly 0% of exit_mmap() calls) before __mmput() starts doing exit_aio() etc.
> Patch is shown below. Only compile tested.

Yes, that would be another approach.
 
>  include/linux/sched/coredump.h |  1 +
>  mm/oom_kill.c                  | 80 ++++++++++++++++++++----------------------
>  2 files changed, 40 insertions(+), 41 deletions(-)
> 
> diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
> index 98ae0d0..6b6237b 100644
> --- a/include/linux/sched/coredump.h
> +++ b/include/linux/sched/coredump.h
> @@ -62,6 +62,7 @@ static inline int get_dumpable(struct mm_struct *mm)
>   * on NFS restore
>   */
>  //#define MMF_EXE_FILE_CHANGED	18	/* see prctl_set_mm_exe_file() */
> +#define MMF_OOM_REAPING		18	/* mm is supposed to be reaped */

A new flag is not really needed. We can increase it for _each_ reapable
oom victim.

> @@ -658,6 +643,13 @@ static void mark_oom_victim(struct task_struct *tsk)
>  	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
>  		mmgrab(tsk->signal->oom_mm);
>  
> +#ifdef CONFIG_MMU
> +	if (!test_bit(MMF_OOM_REAPING, &mm->flags)) {
> +		set_bit(MMF_OOM_REAPING, &mm->flags);
> +		mmget(mm);
> +	}
> +#endif

This would really need a big fat warning explaining why we do not need
mmget_not_zero. We rely on exit_mm doing both mmput and tsk->mm = NULL
under the task_lock and mark_oom_victim is called under this lock as
well and task_will_free_mem resp. find_lock_task_mm makes sure we do not
even consider tasks wihout mm.

I agree that a solution which is fully contained inside the oom proper
would be preferable to touching __mmput path.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
