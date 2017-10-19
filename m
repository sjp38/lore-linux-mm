Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 249E56B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 15:30:52 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 11so1660019wrb.10
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 12:30:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i191si1674918wmd.139.2017.10.19.12.30.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 12:30:50 -0700 (PDT)
Date: Thu, 19 Oct 2017 21:30:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND v12 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171019193048.itwkfhycnebgbxsn@dhcp22.suse.cz>
References: <20171019185218.12663-1-guro@fb.com>
 <20171019185218.12663-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019185218.12663-4-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 19-10-17 19:52:15, Roman Gushchin wrote:
> Traditionally, the OOM killer is operating on a process level.
> Under oom conditions, it finds a process with the highest oom score
> and kills it.
> 
> This behavior doesn't suit well the system with many running
> containers:
> 
> 1) There is no fairness between containers. A small container with
> few large processes will be chosen over a large one with huge
> number of small processes.
> 
> 2) Containers often do not expect that some random process inside
> will be killed. In many cases much safer behavior is to kill
> all tasks in the container. Traditionally, this was implemented
> in userspace, but doing it in the kernel has some advantages,
> especially in a case of a system-wide OOM.
> 
> To address these issues, the cgroup-aware OOM killer is introduced.
> 
> This patch introduces the core functionality: an ability to select
> a memory cgroup as an OOM victim. Under OOM conditions the OOM killer
> looks for the biggest leaf memory cgroup and kills the biggest
> task belonging to it.
> 
> The following patches will extend this functionality to consider
> non-leaf memory cgroups as OOM victims, and also provide an ability
> to kill all tasks belonging to the victim cgroup.
> 
> The root cgroup is treated as a leaf memory cgroup, so it's score
> is compared with other leaf memory cgroups.
> Due to memcg statistics implementation a special approximation
> is used for estimating oom_score of root memory cgroup: we sum
> oom_score of the belonging processes (or, to be more precise,
> tasks owning their mm structures).
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Just to make it clear. My ack is conditional on the opt-in which is
implemented later in the series. Strictly speaking system would
behave differently during the bisection and that might lead to a
confusion. I guess it would be better to simply disable this feature
until we have means to enable it. But I do not really care strongly
here.

There is another thing that I am more concerned about. Usually you
should drop ack when making further changes or at least call them out
so that the reviewer is aware of them.  In this particular case I am
worried about the fallback code we have discussed previously

[...]
> @@ -1080,27 +1102,39 @@ bool out_of_memory(struct oom_control *oc)
>  	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
>  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
>  		get_task_struct(current);
> -		oc->chosen = current;
> +		oc->chosen_task = current;
>  		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
>  		return true;
>  	}
>  
> +	if (mem_cgroup_select_oom_victim(oc)) {
> +		if (oom_kill_memcg_victim(oc))
> +		    delay = true;
> +
> +		goto out;
> +	}
> +
[...]
> +out:
> +	/*
> +	 * Give the killed process a good chance to exit before trying
> +	 * to allocate memory again.
> +	 */
> +	if (delay)
> +		schedule_timeout_killable(1);
> +
> +	return !!oc->chosen_task;
>  }

this basically means that if you manage to select a memcg victim but
then you won't be able to select any task in that memcg then you would
return false from out_of_memory and that has other consequences. Namely
__alloc_pages_may_oom will not set did_some_progress and so the
allocation path will fail. While this scenario is not very likely we
should behave better. Your previous implementation (which I've acked)
did fall back to the standard oom killer path which is the safest
option. Maybe we can do better but let's try robust and be clever later.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
