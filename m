Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 960E86B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 03:48:40 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c52so74393282qte.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 00:48:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i197si5344295wmg.0.2016.07.13.00.48.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 00:48:39 -0700 (PDT)
Date: Wed, 13 Jul 2016 09:48:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 5/8] mm,oom_reaper: Make OOM reaper use list of mm_struct.
Message-ID: <20160713074837.GA28723@dhcp22.suse.cz>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1468330163-4405-6-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160712145119.GP14586@dhcp22.suse.cz>
 <201607130042.FFE34886.FtJVOLOFMHQOSF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607130042.FFE34886.FtJVOLOFMHQOSF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Wed 13-07-16 00:42:51, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 12-07-16 22:29:20, Tetsuo Handa wrote:
[...]
> > > Since later patch in the series will change oom_scan_process_thread() not
> > > to depend on atomic_read(&task->signal->oom_victims) != 0 &&
> > > find_lock_task_mm(task) != NULL, this patch removes exit_oom_victim()
> > > on remote thread.
> > 
> > I have already suggested doing this in a separate patch. Because
> > dropping exit_oom_victim has other side effectes (namely for
> > oom_killer_disable convergence guarantee).
> 
> You can apply
> http://lkml.kernel.org/r/1467365190-24640-3-git-send-email-mhocko@kernel.org
> at this point.

I would still prefer if exit_oom_victim was done in a separate patch.
Unless you have a strong reason to do it in this patch. I plan to rework
the above to remove exit_oom_victim along with the oom_killer_disable
change.

> > Also I would suggest doing set_bit(MMF_OOM_REAPED) from exit_oom_mm and
> > (in a follow up patch) rename it to MMF_SKIP_OOM_MM.
> > 
> > I haven't spotted any other issues.
> > 
> Oops. Please fold below fix into
> "[PATCH 5/8] mm,oom_reaper: Make OOM reaper use list of mm_struct.".
> 
> >From ae051fb92b285c0dc4ebc4953fadc755b1ae8a31 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 13 Jul 2016 00:24:32 +0900
> Subject: [PATCH] mm,oom_reaper: Close race on exit_oom_mm().
> 
> Previous patch forgot to take a reference on mm, for __mmput() from
> mmput() from exit_mm() can drop mm->mm_count till 0 before the OOM
> reaper calls exit_oom_mm().

I have missed that as well. Please fold this in.

> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 715f77d..4c8b686 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -626,21 +626,24 @@ static int oom_reaper(void *unused)
>  		if (!list_empty(&oom_mm_list)) {
>  			mm = list_first_entry(&oom_mm_list, struct mm_struct,
>  					      oom_mm.list);
> -			victim = mm->oom_mm.victim;
>  			/*
> -			 * Take a reference on current victim thread in case
> -			 * oom_reap_task() raced with mark_oom_victim() by
> -			 * other threads sharing this mm.
> +			 * Take references on mm and victim in case
> +			 * oom_reap_task() raced with mark_oom_victim() or
> +			 * __mmput().
>  			 */
> +			atomic_inc(&mm->mm_count);
> +			victim = mm->oom_mm.victim;
>  			get_task_struct(victim);
>  		}
>  		spin_unlock(&oom_mm_lock);
>  		if (!mm)
>  			continue;
>  		oom_reap_task(victim, mm);
> -		put_task_struct(victim);
>  		/* Drop references taken by mark_oom_victim() */
>  		exit_oom_mm(mm);
> +		/* Drop references taken above. */
> +		put_task_struct(victim);
> +		mmdrop(mm);
>  	}
>  
>  	return 0;
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
