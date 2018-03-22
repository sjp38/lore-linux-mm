Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 65B126B0003
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 07:40:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m79so3770824wma.7
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 04:40:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 67si1553703wmj.245.2018.03.22.04.40.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Mar 2018 04:40:05 -0700 (PDT)
Date: Thu, 22 Mar 2018 12:40:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Disable preemption inside the OOM killer.
Message-ID: <20180322114002.GC23100@dhcp22.suse.cz>
References: <1521716652-4868-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1521716652-4868-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu 22-03-18 20:04:12, Tetsuo Handa wrote:
> cond_resched() from printk() or CONFIG_PREEMPT=y can allow other
> contending allocating paths to disturb the owner of oom_lock.
> They can break
> 
>   /*
>    * Acquire the oom lock.  If that fails, somebody else is
>    * making progress for us.
>    */
> 
> assumption in __alloc_pages_may_oom().
> 
> If we use mutex_lock_killable() instead of mutex_trylock(), we can
> guarantee that noone forever continues wasting CPU resource and disturbs
> the owner of oom_lock.

Wrong! _Any_ non allocating task could still preempt the lock holder.

> But when I proposed such change at [1], Michal
> responded that it is worse because it significantly delays the OOM reaper
>  from reclaiming memory. [2] is an alternative which will not delay the
> OOM reaper, but [2] was already rejected.
> 
> Therefore, I proposed further steps at [3] and [4]. But Michal still does
> not like it because it does not address preemption problem. I don't
> consider preemption as a problem because [1] will eventually stop
> disturbing the owner of oom_lock by stop wasting CPU resource.
> 
> It will be nice if we can make the OOM context not preemptible. But it is
> not easy because printk() can be very slow which might not fit for
> disabling the preemption. Since the printk() is responsible for printing
> dying messages, we need to be careful not to deprive printk() of CPU
> resources. From that aspect, [3] is safer direction than making the OOM
> context not preemptible. Of course, if we could get rid of direct reclaim,
> we won't need [3] from the beginning, for [3] is the last defense against
> forever disturbing the owner of oom_lock by wasting CPU resource for
> direct reclaim without any progress.

Can you pretty please try to come up with a reasonable changelog that
doesn't refer to 4 different links and state the problem and the way how
the patch addresses it? Whoever is interested in the history of the
change can look into mailing list archives.

> Nonetheless, this patch disables preemption inside the OOM killer as much
> as possible, for this is the direction Michal wants to go.

And we are doing some pretty heavy lifting in the oom path so disabling
the whole preemption is a no-go. You are likely to introduce soft
lockups on large machines.

Look, this has been explained to you already but you keep ignoring that.
We are not going to add a code that risks negative side effects just
because of an artificial workload of yours. It would be great to handle
it as well but that is way far from straightforward. Large machines with
zilions of tasks are real, on the other hand. So please try to think out
of your bubble finally!

Nacked-by: Michal Hocko <mhocko@suse.com>

> 
> [1] http://lkml.kernel.org/r/201802202232.IEC26597.FOQtMFOFJHOSVL@I-love.SAKURA.ne.jp
> [2] http://lkml.kernel.org/r/1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> [3] http://lkml.kernel.org/r/201802241700.JJB51016.FQOLFJHFOOSVMt@I-love.SAKURA.ne.jp
> [4] http://lkml.kernel.org/r/201803022010.BJE26043.LtSOOVFQOMJFHF@I-love.SAKURA.ne.jp
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tejun Heo <tj@kernel.org>
> ---
>  mm/oom_kill.c | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index dcdb642..614d1a2 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1068,7 +1068,7 @@ int unregister_oom_notifier(struct notifier_block *nb)
>   * OR try to be smart about which process to kill. Note that we
>   * don't have to be perfect here, we just have to be good.
>   */
> -bool out_of_memory(struct oom_control *oc)
> +static bool __out_of_memory(struct oom_control *oc)
>  {
>  	unsigned long freed = 0;
>  	enum oom_constraint constraint = CONSTRAINT_NONE;
> @@ -1077,7 +1077,9 @@ bool out_of_memory(struct oom_control *oc)
>  		return false;
>  
>  	if (!is_memcg_oom(oc)) {
> +		preempt_enable();
>  		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
> +		preempt_disable();
>  		if (freed > 0)
>  			/* Got some memory back in the last second. */
>  			return true;
> @@ -1138,6 +1140,16 @@ bool out_of_memory(struct oom_control *oc)
>  	return !!oc->chosen_task;
>  }
>  
> +bool out_of_memory(struct oom_control *oc)
> +{
> +	bool ret;
> +
> +	preempt_disable();
> +	ret = __out_of_memory(oc);
> +	preempt_enable();
> +	return ret;
> +}
> +
>  /*
>   * The pagefault handler calls here because it is out of memory, so kill a
>   * memory-hogging task. If oom_lock is held by somebody else, a parallel oom
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
