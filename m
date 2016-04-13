Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 24E09828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 07:05:12 -0400 (EDT)
Received: by mail-oi0-f47.google.com with SMTP id w85so58848504oiw.0
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 04:05:12 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k23si11897676otd.56.2016.04.13.04.05.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Apr 2016 04:05:10 -0700 (PDT)
Subject: Re: [PATCH] oom: consider multi-threaded tasks in task_will_free_mem
References: <1460452756-15491-1-git-send-email-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <570E27D6.9060908@I-love.SAKURA.ne.jp>
Date: Wed, 13 Apr 2016 20:04:54 +0900
MIME-Version: 1.0
In-Reply-To: <1460452756-15491-1-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 2016/04/12 18:19, Michal Hocko wrote:
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

I don't know what

    fatal_signal_pending() can be true because of SIGNAL_GROUP_COREDUMP so
    out_of_memory() and mem_cgroup_out_of_memory() shouldn't blindly trust it.

in commit d003f371b270 is saying (how SIGNAL_GROUP_COREDUMP can make
fatal_signal_pending() true when fatal_signal_pending() is defined as

  static inline int __fatal_signal_pending(struct task_struct *p)
  {
  	return unlikely(sigismember(&p->pending.signal, SIGKILL));
  }

  static inline int fatal_signal_pending(struct task_struct *p)
  {
  	return signal_pending(p) && __fatal_signal_pending(p);
  }

which does not check SIGNAL_GROUP_COREDUMP). But I think that playing
with racy conditions as of setting TIF_MEMDIE is a bad direction.

The most disruptive action is not to select an OOM victim when we need to
select an OOM victim (which is known as the OOM livelock). Do you agree?

The least disruptive action is not to select an OOM victim when we don't
need to select an OOM victim (which is known as disabling the OOM killer).
Do you agree?

If you can agree on both, we can have a chance to make less disruptive
using bound waiting.

Since commit 6a618957ad17 ("mm: oom_kill: don't ignore oom score on exiting
tasks") was merged before your OOM detection rework is merged,

    We've tried direct reclaim at least 15 times by the time we decide
    the system is OOM

in that commit now became a puzzling explanation. But the reason I proposed
that change is that we will hit the OOM livelock if we wait unconditionally
( http://lkml.kernel.org/r/20160217143917.GP29196@dhcp22.suse.cz ).
If we accept bound waiting, we did not need to merge that change.

Also, we don't need to delete the shortcuts if we accept bound waiting
if you think deleting the shortcuts makes more disruptive.

I believe that the preferred way (from the point of view of trying to avoid
disruptive action if possible) is to wait for a bounded amount when checking
for TIF_MEMDIE threads to release their mm, rather than play with racy
situations as of setting TIF_MEMDIE.

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

The whole thread group is going down does not mean we make sure that
we will send SIGKILL to other thread groups sharing the same memory which
is possibly holding mmap_sem for write, does it?

> +
> +	return true;
>  }
>  
>  /* sysctls */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
