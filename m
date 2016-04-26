Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7526B0274
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 09:57:56 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so12749017lfq.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 06:57:56 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id w10si3460108wmw.27.2016.04.26.06.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 06:57:54 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w143so4676230wmw.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 06:57:54 -0700 (PDT)
Date: Tue, 26 Apr 2016 15:57:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom: consider multi-threaded tasks in task_will_free_mem
Message-ID: <20160426135752.GC20813@dhcp22.suse.cz>
References: <1460452756-15491-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460452756-15491-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 12-04-16 11:19:16, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> task_will_free_mem is a misnomer for a more complex PF_EXITING test
> for early break out from the oom killer because it is believed that
> such a task would release its memory shortly and so we do not have
> to select an oom victim and perform a disruptive action.
> 
> Currently we make sure that the given task is not participating in the
> core dumping because it might get blocked for a long time - see
> d003f371b270 ("oom: don't assume that a coredumping thread will exit
> soon").
> 
> The check can still do better though. We shouldn't consider the task
> unless the whole thread group is going down. This is rather unlikely
> but not impossible. A single exiting thread would surely leave all the
> address space behind. If we are really unlucky it might get stuck on the
> exit path and keep its TIF_MEMDIE and so block the oom killer.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> I hope I got it right but I would really appreciate if Oleg found some
> time and double checked after me. The fix is more cosmetic than anything
> else but I guess it is worth it.

ping...

> 
> Thanks!
> 
>  include/linux/oom.h | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 628a43242a34..b09c7dc523ff 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -102,13 +102,24 @@ extern struct task_struct *find_lock_task_mm(struct task_struct *p);
>  
>  static inline bool task_will_free_mem(struct task_struct *task)
>  {
> +	struct signal_struct *sig = task->signal;
> +
>  	/*
>  	 * A coredumping process may sleep for an extended period in exit_mm(),
>  	 * so the oom killer cannot assume that the process will promptly exit
>  	 * and release memory.
>  	 */
> -	return (task->flags & PF_EXITING) &&
> -		!(task->signal->flags & SIGNAL_GROUP_COREDUMP);
> +	if (sig->flags & SIGNAL_GROUP_COREDUMP)
> +		return false;
> +
> +	if (!(task->flags & PF_EXITING))
> +		return false;
> +
> +	/* Make sure that the whole thread group is going down */
> +	if (!thread_group_empty(task) && !(sig->flags & SIGNAL_GROUP_EXIT))
> +		return false;
> +
> +	return true;
>  }
>  
>  /* sysctls */
> -- 
> 2.8.0.rc3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
