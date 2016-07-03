Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD716B0005
	for <linux-mm@kvack.org>; Sat,  2 Jul 2016 22:45:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so320797496pfa.1
        for <linux-mm@kvack.org>; Sat, 02 Jul 2016 19:45:45 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x78si1391828pfa.126.2016.07.02.19.45.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 02 Jul 2016 19:45:44 -0700 (PDT)
Subject: Re: [RFC PATCH 1/6] oom: keep mm of the killed task available
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
	<1467365190-24640-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1467365190-24640-2-git-send-email-mhocko@kernel.org>
Message-Id: <201607031145.HIF90125.LMHQVFJOtOSOFF@I-love.SAKURA.ne.jp>
Date: Sun, 3 Jul 2016 11:45:34 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mhocko@suse.com

Michal Hocko wrote:
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 7d0a275df822..4ea4a649822d 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -286,16 +286,17 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	 * Don't allow any other task to have access to the reserves unless
>  	 * the task has MMF_OOM_REAPED because chances that it would release
>  	 * any memory is quite low.
> +	 * MMF_OOM_NOT_REAPABLE means that the oom_reaper backed off last time
> +	 * so let it try again.
>  	 */
>  	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
> -		struct task_struct *p = find_lock_task_mm(task);
> +		struct mm_struct *mm = task->signal->oom_mm;
>  		enum oom_scan_t ret = OOM_SCAN_ABORT;
>  
> -		if (p) {
> -			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
> -				ret = OOM_SCAN_CONTINUE;
> -			task_unlock(p);
> -		}
> +		if (test_bit(MMF_OOM_REAPED, &mm->flags))
> +			ret = OOM_SCAN_CONTINUE;
> +		else if (test_bit(MMF_OOM_NOT_REAPABLE, &mm->flags))
> +			ret = OOM_SCAN_SELECT;

I don't think this is useful.

MMF_OOM_NOT_REAPABLE is set when mm->mmap_sem could not be held for read
by the OOM reaper thread. That occurs when someone is blocked at unkillable
wait with that mm->mmap_sem held for write. Unless the reason that someone
is blocked is lack of CPU time, the reason is likely that that someone is
blocked due to waiting for somebody else's memory allocation. Then, it
won't succeed that retrying OOM reaping MMF_OOM_NOT_REAPABLE mm as soon as
oom_scan_process_thread() finds it. At least, retrying OOM reaping
MMF_OOM_NOT_REAPABLE mm should be attempted after that someone is no longer
blocked due to waiting for somebody else's memory allocation (e.g. retry
only when oom_scan_process_thread() is sure that the OOM reaper thread can
hold mm->mmap_sem for read).

But I don't think with need to dance with task->signal->oom_mm.
See my series which removes task->signal->oom_victims and OOM_SCAN_ABORT case.

>  
>  		return ret;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
