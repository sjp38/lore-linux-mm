Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C2AA76B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 13:43:51 -0400 (EDT)
Received: by pacgz10 with SMTP id gz10so61764229pac.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 10:43:51 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id of16si5166593pdb.108.2015.07.08.10.43.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 10:43:50 -0700 (PDT)
Date: Wed, 8 Jul 2015 20:43:31 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 8/8] memcg: get rid of mem_cgroup_from_task
Message-ID: <20150708174331.GH2436@esperanza>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-9-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1436358472-29137-9-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Wed, Jul 08, 2015 at 02:27:52PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.cz>
> 
> mem_cgroup_from_task has always been a tricky API. It was added
> by 78fb74669e80 ("Memory controller: accounting setup") for
> mm_struct::mem_cgroup initialization. Later on it gained new callers
> mostly due to mm_struct::mem_cgroup -> mem_cgroup::owner transition and
> most users had to do mem_cgroup_from_task(mm->owner) to get the
> resulting memcg. Now that mm_struct::owner is gone this is not
> necessary, yet the API is still confusing.
> 
> One tricky part has always been that the API sounds generic but it is
> not really. mem_cgroup_from_task(current) doesn't necessarily mean the
> same thing as current->mm->memcg (resp.
> mem_cgroup_from_task(current->mm->owner) previously) because mm might be
> associated with a different cgroup than the process.
> 
> Another tricky part is that p->mm->memcg is unsafe if p!=current
> as pointed by Oleg because nobody is holding a reference on that
> mm. This is not a problem right now because we have only 2 callers in
> the tree. sock_update_memcg operates on current and task_in_mem_cgroup
> is providing non-NULL task so it is always using task_css.
> 
> Let's ditch this function and use current->mm->memcg for
> sock_update_memcg and use task_css for task_in_mem_cgroup. This doesn't
> have any functional effect.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c | 24 +++++++-----------------
>  1 file changed, 7 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4069ec8f52be..fb8e9bd04a29 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -294,18 +294,6 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
>  	return mem_cgroup_from_css(css);
>  }
>  
> -static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
> -{
> -	if (p->mm)
> -		return rcu_dereference(p->mm->memcg);
> -
> -	/*
> -	 * If the process doesn't have mm struct anymore we have to fallback
> -	 * to the task_css.
> -	 */
> -	return mem_cgroup_from_css(task_css(p, memory_cgrp_id));
> -}
> -
>  /* Writing them here to avoid exposing memcg's inner layout */
>  #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
>  
> @@ -332,7 +320,7 @@ void sock_update_memcg(struct sock *sk)
>  		}
>  
>  		rcu_read_lock();
> -		memcg = mem_cgroup_from_task(current);
> +		memcg = rcu_dereference(current->mm->memcg);
>  		cg_proto = sk->sk_prot->proto_cgroup(memcg);
>  		if (cg_proto && memcg_proto_active(cg_proto) &&
>  		    css_tryget_online(&memcg->css)) {
> @@ -1091,12 +1079,14 @@ bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
>  		task_unlock(p);
>  	} else {
>  		/*
> -		 * All threads may have already detached their mm's, but the oom
> -		 * killer still needs to detect if they have already been oom
> -		 * killed to prevent needlessly killing additional tasks.
> +		 * All threads have already detached their mm's but we should
> +		 * still be able to at least guess the original memcg from the
> +		 * task_css. These two will match most of the time but there are
> +		 * corner cases where task->mm and task_css refer to a different
> +		 * cgroups.
>  		 */
>  		rcu_read_lock();
> -		task_memcg = mem_cgroup_from_task(task);
> +		task_memcg = mem_cgroup_from_css(task_css(task, memory_cgrp_id));
>  		css_get(&task_memcg->css);

I wonder why it's safe to call css_get here.

The patch itself looks good though,

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

>  		rcu_read_unlock();
>  	}
> -- 
> 2.1.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
