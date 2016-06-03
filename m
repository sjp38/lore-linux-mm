From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [RFC PATCH 10/10] mm, oom: hide mm which is shared with kthread or global init
Date: Sat, 4 Jun 2016 00:16:32 +0900
Message-ID: <201606040016.BFG17115.OFMLSJFOtHQOFV@I-love.SAKURA.ne.jp>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
	<1464945404-30157-11-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464945404-30157-11-git-send-email-mhocko@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com
List-Id: linux-mm.kvack.org

Michal Hocko wrote:
> The only case where the oom_reaper is not triggered for the oom victim
> is when it shares the memory with a kernel thread (aka use_mm) or with
> the global init. After "mm, oom: skip vforked tasks from being selected"
> the victim cannot be a vforked task of the global init so we are left
> with clone(CLONE_VM) (without CLONE_THREAD or CLONE_SIGHAND).

According to clone(2) manpage

  Since Linux 2.5.35, flags must also include CLONE_SIGHAND if
  CLONE_THREAD is specified (and note that, since Linux
  2.6.0-test6, CLONE_SIGHAND also requires CLONE_VM to be
  included).

clone(CLONE_VM | CLONE_SIGHAND) and clone(CLONE_VM | CLONE_SIGHAND | CLONE_THREAD)
are allowed but clone(CLONE_VM | CLONE_THREAD) is not allowed. Therefore,
I think "clone(CLONE_VM) (without CLONE_THREAD or CLONE_SIGHAND)" should be
written like "clone(CLONE_VM without CLONE_SIGHAND)".

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 9a5cc12a479a..3a3b136ee9db 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -283,10 +283,19 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  
>  	/*
>  	 * This task already has access to memory reserves and is being killed.
> -	 * Don't allow any other task to have access to the reserves.
> +	 * Don't allow any other task to have access to the reserves unless
> +	 * this is a current task which is clearly in the allocation path and
> +	 * the access to memory reserves didn't help so we should rather try
> +	 * to kill somebody else or panic on no oom victim than loop with no way
> +	 * forward. Go with OOM_SCAN_OK rather than OOM_SCAN_CONTINUE to double
> +	 * check MMF_OOM_REAPED in oom_badness() to make sure we've done
> +	 * everything to reclaim memory.
>  	 */
> -	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
> -		return OOM_SCAN_ABORT;
> +	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
> +		if (task != current)
> +			return OOM_SCAN_ABORT;
> +		return OOM_SCAN_OK;
> +	}

I don't think above change is needed. Instead, making sure that TIF_MEMDIE is
cleared (or ignored) some time later is needed.

If an allocating task leaves out_of_memory() with a TIF_MEMDIE thread, it is
guaranteed (provided that CONFIG_MMU=y && oom_reaper_th != NULL) that the OOM
reaper is woken up and clear TIF_MEMDIE and sets MMF_OOM_REAPED regardless of
reaping result.

Leaving current thread from out_of_memory() without clearing TIF_MEMDIE might
cause OOM lockup, for there is no guarantee that current thread will not wait
for locks in unkillable state after current memory allocation request completes
(e.g. getname() followed by mutex_lock() shown at
http://lkml.kernel.org/r/201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp ).

> @@ -922,8 +936,17 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	}
>  	rcu_read_unlock();
>  
> -	if (can_oom_reap)
> +	if (can_oom_reap) {
>  		wake_oom_reaper(victim);
> +	} else if (victim != current) {
> +		/*
> +		 * If we want to guarantee a forward progress we cannot keep
> +		 * the oom victim TIF_MEMDIE here. Sleep for a while and then
> +		 * drop the flag to make sure another victim can be selected.
> +		 */
> +		schedule_timeout_killable(HZ);

Sending SIGKILL to victim makes this sleep a no-op if
same_thread_group(victim, current) == true.

> +		exit_oom_victim(victim);
> +	}
>  
>  	mmdrop(mm);
>  	put_task_struct(victim);
> -- 
> 2.8.1
