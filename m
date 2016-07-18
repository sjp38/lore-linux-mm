Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD14E6B025F
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 03:18:28 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l89so108234074lfi.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 00:18:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si13213452wmv.71.2016.07.18.00.18.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 00:18:27 -0700 (PDT)
Date: Mon, 18 Jul 2016 09:18:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, oom: fix for hiding mm which is shared with kthread
 or global init
Message-ID: <20160718071825.GB22671@dhcp22.suse.cz>
References: <1468647004-5721-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468647004-5721-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, David Rientjes <rientjes@google.com>

On Sat 16-07-16 14:30:04, Tetsuo Handa wrote:
> Patch "mm, oom: hide mm which is shared with kthread or global init" tried
> to guarantee a forward progress for the OOM killer even when the selected
> victim is sharing memory with a kernel thread or global init, but a race
> scenario still remains because it did not add a call to exit_oom_victim()
> in oom_kill_process() in order to avoid a problem which is already worked
> around by commit 74070542099c66d8 ("oom, suspend: fix oom_reaper vs.
> oom_killer_disable race").
> 
> The race scenario is that a !can_oom_reap TIF_MEMDIE thread becomes
> the only user of that mm (i.e. mm->mm_users drops to 1) and is later
> blocked for unbounded period at __mmput() from mmput() from
> exit_mm() from do_exit() by hitting e.g.
> 
>   (1) First round of OOM killer invocation starts.
>   (2) select_bad_process() chooses P1 as an OOM victim because
>       oom_scan_process_thread() does not find existing victims.
>   (3) oom_kill_process() sets TIF_MEMDIE on P1, but does not put P1 under
>       the OOM reaper's supervision due to (p->flags & PF_KTHREAD) being
>       true, and instead sets MMF_OOM_REAPED on the P1's mm.
>   (4) First round of OOM killer invocation finishes.
>   (5) P1 is unable to arrive at do_exit() due to being blocked at
>       unkillable event waiting for somebody else's memory allocation.
>   (6) Second round of OOM killer invocation starts.
>   (7) select_bad_process() chooses P2 as an OOM victim because
>       oom_scan_process_thread() finds P1's mm with MMF_OOM_REAPED set.
>   (8) oom_kill_process() sets TIF_MEMDIE on P2 via mark_oom_victim(),
>       and puts P2 under the OOM reaper's supervision due to
>       (p->flags & PF_KTHREAD) being false.
>   (9) Second round of OOM killer invocation finishes.
>   (10) The OOM reaper reaps P2's mm, and sets MMF_OOM_REAPED to
>        P2's mm, and clears TIF_MEMDIE from P2.
>   (11) Regarding P1's mm, (p->flags & PF_KTHREAD) becomes false because
>        somebody else's memory allocation succeeds and unuse_mm(P1->mm)
>        is called. At this point P1 becomes the only user of P1->mm.
>   (12) P1 arrives at do_exit() due to no longer being blocked at
>        unkillable event waiting for somebody else's memory allocation.
>   (13) P1 reaches P1->mm = NULL line in exit_mm() from do_exit().
>   (14) P1 is blocked at __mmput().
>   (15) Third round of OOM killer invocation starts.
>   (16) select_bad_process() does not choose new OOM victim because
>        oom_scan_process_thread() fails to find P1's mm while
>        P1->signal->oom_victims > 0.
>   (17) Third round of OOM killer invocation finishes.
>   (18) OOM livelock happens because nobody will clear TIF_MEMDIE from
>        P1 (and decrement P1->signal->oom_victims) while P1 is blocked
>        at __mmput().
> 
> sequence, but the patch "mm, oom: hide mm which is shared with kthread
> or global init" is failing to return OOM_SCAN_CONTINUE when we hit
> atomic_read(&task->signal->oom_victims) != 0 &&
> find_lock_task_mm(task) == NULL in oom_scan_process_thread().
> 
> Long term we are planning to change oom_scan_process_thread() not to
> depend on atomic_read(&task->signal->oom_victims) != 0 &&
> find_lock_task_mm(task) != NULL, and remove exit_oom_victim() from
> oom_kill_process() and oom_reap_task() along with signal->oom_victims
> and commit 74070542099c66d8. But since we did not complete such changes
> in time for 4.8 merge window, let's rely on commit 74070542099c66d8
> for now in order to guarantee a forward progress for the OOM killer.

I really do not think that this unlikely case really has to be handled
now. We are very likely going to move to a different model of oom victim
detection soon. So let's do not add new hacks. exit_oom_victim from
oom_kill_process just looks like sand in eyes.
 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 7d0a275..041373e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -922,6 +922,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  			 */
>  			can_oom_reap = false;
>  			set_bit(MMF_OOM_REAPED, &mm->flags);
> +			exit_oom_victim(victim);
>  			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
>  					task_pid_nr(victim), victim->comm,
>  					task_pid_nr(p), p->comm);
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
