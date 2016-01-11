Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id AAD06828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 12:46:56 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id 65so47946833pff.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 09:46:56 -0800 (PST)
Received: from mail-pa0-f67.google.com (mail-pa0-f67.google.com. [209.85.220.67])
        by mx.google.com with ESMTPS id hp4si21582605pad.113.2016.01.11.09.46.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 09:46:55 -0800 (PST)
Received: by mail-pa0-f67.google.com with SMTP id yy13so24805998pab.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 09:46:55 -0800 (PST)
Date: Mon, 11 Jan 2016 18:46:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/2] oom: clear TIF_MEMDIE after oom_reaper managed to
 unmap the address space
Message-ID: <20160111174651.GL27317@dhcp22.suse.cz>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
 <1452516120-5535-1-git-send-email-mhocko@kernel.org>
 <20160111165214.GA32132@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160111165214.GA32132@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 11-01-16 11:52:14, Johannes Weiner wrote:
> This patch looks already good to me. I just have one question:

Thank you for the review!

> On Mon, Jan 11, 2016 at 01:42:00PM +0100, Michal Hocko wrote:
> > @@ -463,60 +479,66 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
> >  	}
> >  	tlb_finish_mmu(&tlb, 0, -1);
> >  	up_read(&mm->mmap_sem);
> > +
> > +	/*
> > +	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
> > +	 * reasonably reclaimable memory anymore. OOM killer can continue
> > +	 * by selecting other victim if unmapping hasn't led to any
> > +	 * improvements. This also means that selecting this task doesn't
> > +	 * make any sense.
> > +	 */
> > +	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
> > +	exit_oom_victim(tsk);
> 
> When the OOM killer scans tasks and encounters a PF_EXITING one, it
> force-selects that one regardless of the score.

True. For some reason I thought that oom_unkillable_task would skip
OOM_SCORE_ADJ_MIN task as they should be hidden from the OOM killer
by definition. Instead we are handling them in oom_badness. Maybe we
should move that check as it would better reflect the semantic.
dump_tasks wouldn't list the task anymore but should it in the first
place? The task is clearly unkillable so why it should add the noise to
the logs.

> Is there a possibility
> that the task might hang after it has set PF_EXITING? In that case the
> OOM killer should be able to move on to the next task.

I guess we can because we are taking some locks after exit_signals but I
haven't checked very closely.

> Frankly, I don't even know why we check for exiting tasks in the OOM
> killer. We've tried direct reclaim at least 15 times by the time we
> decide the system is OOM, there was plenty of time to exit and free
> memory; and a task might exit voluntarily right after we issue a kill.
> This is testing pure noise.

I guess the idea was to prevent from killing another task if some task
is exiting and so it should release its memory shortly. But as you
say this is racy and the oom scanner doesn't know how long has the
target task been in this state without any change. So maybe this is
indeed no longer needed and task_will_free_mem check in out_of_memory is
sufficient.
David?

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index b8a4210..7dfb351 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -305,9 +305,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	if (oom_task_origin(task))
>  		return OOM_SCAN_SELECT;
>  
> -	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
> -		return OOM_SCAN_ABORT;
> -
>  	return OOM_SCAN_OK;
>  }
>  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
