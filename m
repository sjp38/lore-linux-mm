Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1C656B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 12:14:52 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 44so3516347wry.5
        for <linux-mm@kvack.org>; Wed, 17 May 2017 09:14:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a38si2511350eda.182.2017.05.17.09.14.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 09:14:51 -0700 (PDT)
Date: Wed, 17 May 2017 18:14:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: fix oom invocation issues
Message-ID: <20170517161446.GB20660@dhcp22.suse.cz>
References: <1495034780-9520-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495034780-9520-1-git-send-email-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-05-17 16:26:20, Roman Gushchin wrote:
[...]
> [   25.781882] Out of memory: Kill process 492 (allocate) score 899 or sacrifice child
> [   25.783874] Killed process 492 (allocate) total-vm:2052368kB, anon-rss:1894576kB, file-rss:4kB, shmem-rss:0kB

Are there any oom_reaper messages? Could you provide the full kernel log
please?

> <cut>
> [   25.817589] allocate invoked oom-killer: gfp_mask=0x0(), nodemask=(null),  order=0, oom_score_adj=0
> [   25.818821] allocate cpuset=/ mems_allowed=0
> [   25.819259] CPU: 1 PID: 492 Comm: allocate Not tainted 4.12.0-rc1-mm1+ #181
> [   25.819847] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
> [   25.820549] Call Trace:
> [   25.820733]  dump_stack+0x63/0x82
> [   25.820961]  dump_header+0x97/0x21a
> [   25.820961]  ? security_capable_noaudit+0x45/0x60
> [   25.820961]  oom_kill_process+0x219/0x3e0
> [   25.820961]  out_of_memory+0x11d/0x480

This is interesting. OOM usually happens from the page allocator path.
Hitting it from here means that somebody has returned VM_FAULT_OOM. Who
was that and is there any preceeding OOM before?

> [   25.820961]  pagefault_out_of_memory+0x68/0x80
> [   25.820961]  mm_fault_error+0x8f/0x190
> [   25.820961]  ? handle_mm_fault+0xf3/0x210
> [   25.820961]  __do_page_fault+0x4b2/0x4e0
> [   25.820961]  trace_do_page_fault+0x37/0xe0
> [   25.820961]  do_async_page_fault+0x19/0x70
> [   25.820961]  async_page_fault+0x28/0x30
> <cut>
> [   25.863078] Out of memory: Kill process 233 (firewalld) score 10 or sacrifice child
> [   25.863634] Killed process 233 (firewalld) total-vm:246076kB, anon-rss:20956kB, file-rss:0kB, shmem-rss:0kB
> 
> After some investigations I've found some issues:
> 
> 1) Prior to commit 1af8bb432695 ("mm, oom: fortify task_will_free_mem()"),
>    if a process with a pending SIGKILL was calling out_of_memory(),
>    it was always immediately selected as a victim.

Yes but this had its own issues. Mainly picking the same victim again
without making a further progress.

>    But now, after some changes, it's not always a case.
>    If a process has been reaped at the moment, MMF_SKIP_FLAG is set,
>    task_will_free_mem() will return false, and a new
>    victim selection logic will be started.

right. The point is that it doesn't make any sense to consider such a
task because it either cannot be reaped or it has been reaped and there
is not much left to consider. It would be interesting to see what
happened in your case.

>    This actually happens if a userspace pagefault causing an OOM.
>    pagefault_out_of_memory() is called in a context of a faulting
>    process after it has been selected as OOM victim (assuming, it
>    has), and killed. With some probability (there is a race with
>    oom_reaper thread) this process will be passed to the oom reaper
>    again, or an innocent victim will be selected and killed.
> 
> 2) We clear up the task->oom_reaper_list before setting
>    the MMF_OOM_SKIP flag, so there is a race.

I am not sure what you mean here. Why would a race matter?

> 
> 3) We skip the MMF_OOM_SKIP flag check in case of
>    an sysrq-triggered OOM.

yes because we we always want to pick a new victim when sysrq is
invoked.

> To address these issues, the following is proposed:
> 1) If task is already an oom victim, skip out_of_memory() call
>    from the pagefault_out_of_memory().

Hmm, this alone doesn't look all that bad. It would be better to simply
let the task die than go over the oom handling. But I am still not sure
what is going on in your case so I do not see how could this help.
 
> 2) Set the MMF_OOM_SKIP bit in wake_oom_reaper() before adding a
>    process to the oom_reaper list. If it's already set, do nothing.
>    Do not rely on tsk->oom_reaper_list value.

This is wrong. The sole purpose of MMF_OOM_SKIP is to let the oom
selection logic know that this task is not interesting anymore. Setting
it in wake_oom_reaper means it would be set _before_ the oom_reaper had
any chance to free any memory from the task. So we would

> 3) Check the MMF_OOM_SKIP even if OOM is triggered by a sysrq.

The code is a bit messy here but we do check MMF_OOM_SKIP in that case.
We just do it in oom_badness(). So this is not needed, strictly
speaking.

That being said I would like to here more about the cause of the OOM and
the full dmesg would be interesting. The proposed setting of
MMF_OOM_SKIP before the task is reaped is a nogo, though. 1) would be
acceptable I think but I would have to think about it some more.

> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: kernel-team@fb.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/oom_kill.c | 33 +++++++++++++--------------------
>  1 file changed, 13 insertions(+), 20 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 04c9143..c630c76 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -302,10 +302,11 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
>  	 * the task has MMF_OOM_SKIP because chances that it would release
>  	 * any memory is quite low.
>  	 */
> -	if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
> +	if (tsk_is_oom_victim(task)) {
>  		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
>  			goto next;
> -		goto abort;
> +		if (!is_sysrq_oom(oc))
> +			goto abort;
>  	}
>  
>  	/*
> @@ -559,22 +560,11 @@ static void oom_reap_task(struct task_struct *tsk)
>  	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
>  		schedule_timeout_idle(HZ/10);
>  
> -	if (attempts <= MAX_OOM_REAP_RETRIES)
> -		goto done;
> -
> -
> -	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
> -		task_pid_nr(tsk), tsk->comm);
> -	debug_show_all_locks();
> -
> -done:
> -	tsk->oom_reaper_list = NULL;
> -
> -	/*
> -	 * Hide this mm from OOM killer because it has been either reaped or
> -	 * somebody can't call up_write(mmap_sem).
> -	 */
> -	set_bit(MMF_OOM_SKIP, &mm->flags);
> +	if (attempts > MAX_OOM_REAP_RETRIES) {
> +		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
> +			task_pid_nr(tsk), tsk->comm);
> +		debug_show_all_locks();
> +	}
>  
>  	/* Drop a reference taken by wake_oom_reaper */
>  	put_task_struct(tsk);
> @@ -590,6 +580,7 @@ static int oom_reaper(void *unused)
>  		if (oom_reaper_list != NULL) {
>  			tsk = oom_reaper_list;
>  			oom_reaper_list = tsk->oom_reaper_list;
> +			tsk->oom_reaper_list = NULL;
>  		}
>  		spin_unlock(&oom_reaper_lock);
>  
> @@ -605,8 +596,7 @@ static void wake_oom_reaper(struct task_struct *tsk)
>  	if (!oom_reaper_th)
>  		return;
>  
> -	/* tsk is already queued? */
> -	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
> +	if (test_and_set_bit(MMF_OOM_SKIP, &tsk->signal->oom_mm->flags))
>  		return;
>  
>  	get_task_struct(tsk);
> @@ -1068,6 +1058,9 @@ void pagefault_out_of_memory(void)
>  	if (mem_cgroup_oom_synchronize(true))
>  		return;
>  
> +	if (tsk_is_oom_victim(current))
> +		return;
> +
>  	if (!mutex_trylock(&oom_lock))
>  		return;
>  	out_of_memory(&oc);
> -- 
> 2.7.4
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
