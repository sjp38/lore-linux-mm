Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id B9A6B6B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:11:29 -0400 (EDT)
Received: by wibcx1 with SMTP id cx1so2492032wib.1
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 10:11:29 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id ep10si12392431wjd.3.2015.08.28.10.11.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 10:11:28 -0700 (PDT)
Received: by wicfv10 with SMTP id fv10so13289384wic.1
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 10:11:27 -0700 (PDT)
Date: Fri, 28 Aug 2015 19:11:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] memcg: flatten task_struct->memcg_oom
Message-ID: <20150828171125.GB21463@dhcp22.suse.cz>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-3-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440775530-18630-3-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Fri 28-08-15 11:25:28, Tejun Heo wrote:
> task_struct->memcg_oom is a sub-struct containing fields which are
> used for async memcg oom handling.  Most task_struct fields aren't
> packaged this way and it can lead to unnecessary alignment paddings.
> This patch flattens it.
> 
> * task.memcg_oom.memcg		-> task.memcg_in_oom
> * task.memcg_oom.gfp_mask	-> task.memcg_oom_gfp_mask
> * task.memcg_oom.order		-> task.memcg_oom_order
> * task.memcg_oom.may_oom	-> task.memcg_may_oom
> 
> In addition, task.memcg_may_oom is relocated to where other bitfields
> are which reduces the size of task_struct.

OK we will save 8B AFAICS which probably doesn't make much different for
this huge structure. But we already have memcg_kmem_skip_account bit
field there so another one makes sense. That alone would be sufficient
to save those bytes. Regarding the struct, I do not have a strong
opinion. I do not mind removing it.
 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memcontrol.h | 10 +++++-----
>  include/linux/sched.h      | 13 ++++++-------
>  mm/memcontrol.c            | 16 ++++++++--------
>  3 files changed, 19 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index ad800e6..3d28656 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -407,19 +407,19 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>  
>  static inline void mem_cgroup_oom_enable(void)
>  {
> -	WARN_ON(current->memcg_oom.may_oom);
> -	current->memcg_oom.may_oom = 1;
> +	WARN_ON(current->memcg_may_oom);
> +	current->memcg_may_oom = 1;
>  }
>  
>  static inline void mem_cgroup_oom_disable(void)
>  {
> -	WARN_ON(!current->memcg_oom.may_oom);
> -	current->memcg_oom.may_oom = 0;
> +	WARN_ON(!current->memcg_may_oom);
> +	current->memcg_may_oom = 0;
>  }
>  
>  static inline bool task_in_memcg_oom(struct task_struct *p)
>  {
> -	return p->memcg_oom.memcg;
> +	return p->memcg_in_oom;
>  }
>  
>  bool mem_cgroup_oom_synchronize(bool wait);
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index a4ab9da..ef73b54 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1451,7 +1451,9 @@ struct task_struct {
>  	unsigned sched_reset_on_fork:1;
>  	unsigned sched_contributes_to_load:1;
>  	unsigned sched_migrated:1;
> -
> +#ifdef CONFIG_MEMCG
> +	unsigned memcg_may_oom:1;
> +#endif
>  #ifdef CONFIG_MEMCG_KMEM
>  	unsigned memcg_kmem_skip_account:1;
>  #endif
> @@ -1782,12 +1784,9 @@ struct task_struct {
>  	unsigned long trace_recursion;
>  #endif /* CONFIG_TRACING */
>  #ifdef CONFIG_MEMCG
> -	struct memcg_oom_info {
> -		struct mem_cgroup *memcg;
> -		gfp_t gfp_mask;
> -		int order;
> -		unsigned int may_oom:1;
> -	} memcg_oom;
> +	struct mem_cgroup *memcg_in_oom;
> +	gfp_t memcg_oom_gfp_mask;
> +	int memcg_oom_order;
>  #endif
>  #ifdef CONFIG_UPROBES
>  	struct uprobe_task *utask;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 18ecf75..74abb31 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1652,7 +1652,7 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
>  
>  static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
>  {
> -	if (!current->memcg_oom.may_oom)
> +	if (!current->memcg_may_oom)
>  		return;
>  	/*
>  	 * We are in the middle of the charge context here, so we
> @@ -1669,9 +1669,9 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
>  	 * and when we know whether the fault was overall successful.
>  	 */
>  	css_get(&memcg->css);
> -	current->memcg_oom.memcg = memcg;
> -	current->memcg_oom.gfp_mask = mask;
> -	current->memcg_oom.order = order;
> +	current->memcg_in_oom = memcg;
> +	current->memcg_oom_gfp_mask = mask;
> +	current->memcg_oom_order = order;
>  }
>  
>  /**
> @@ -1693,7 +1693,7 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
>   */
>  bool mem_cgroup_oom_synchronize(bool handle)
>  {
> -	struct mem_cgroup *memcg = current->memcg_oom.memcg;
> +	struct mem_cgroup *memcg = current->memcg_in_oom;
>  	struct oom_wait_info owait;
>  	bool locked;
>  
> @@ -1721,8 +1721,8 @@ bool mem_cgroup_oom_synchronize(bool handle)
>  	if (locked && !memcg->oom_kill_disable) {
>  		mem_cgroup_unmark_under_oom(memcg);
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
> -		mem_cgroup_out_of_memory(memcg, current->memcg_oom.gfp_mask,
> -					 current->memcg_oom.order);
> +		mem_cgroup_out_of_memory(memcg, current->memcg_oom_gfp_mask,
> +					 current->memcg_oom_order);
>  	} else {
>  		schedule();
>  		mem_cgroup_unmark_under_oom(memcg);
> @@ -1739,7 +1739,7 @@ bool mem_cgroup_oom_synchronize(bool handle)
>  		memcg_oom_recover(memcg);
>  	}
>  cleanup:
> -	current->memcg_oom.memcg = NULL;
> +	current->memcg_in_oom = NULL;
>  	css_put(&memcg->css);
>  	return true;
>  }
> -- 
> 2.4.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
