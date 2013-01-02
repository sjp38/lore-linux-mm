Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 594426B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 08:35:26 -0500 (EST)
Date: Wed, 2 Jan 2013 14:35:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V3 7/8] memcg: disable memcg page stat accounting code
 when not in use
Message-ID: <20130102133518.GF22160@dhcp22.suse.cz>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
 <1356456477-14780-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1356456477-14780-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>, Mel Gorman <mgorman@suse.de>

[CCing Mel]

On Wed 26-12-12 01:27:57, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> It's inspired by a similar optimization from Glauber Costa
> (memcg: make it suck faster; https://lkml.org/lkml/2012/9/25/154).
> Here we use jump label to patch the memcg page stat accounting code
> in or out when not used. when the first non-root memcg comes to
> life the code is patching in otherwise it is out.

Mel had a workload which shown quite a big regression when memcg is
enabled with no cgroups but root (it was a page fault microbench AFAIR
but I do not have a link handy) so it would be nice to check how much
this patch helps and what are the other places which could benefit from
the static key.

> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

Anyway, I like this as a first step (and the patch description should be
explicit about that). See other comments bellow.

> ---
>  include/linux/memcontrol.h |    9 +++++++++
>  mm/memcontrol.c            |    8 ++++++++
>  2 files changed, 17 insertions(+)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1d22b81..3c4430c 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -56,6 +56,9 @@ struct mem_cgroup_reclaim_cookie {
>  };
>  
>  #ifdef CONFIG_MEMCG
> +
> +extern struct static_key memcg_in_use_key;
> +
>  /*
>   * All "charge" functions with gfp_mask should use GFP_KERNEL or
>   * (gfp_mask & GFP_RECLAIM_MASK). In current implementatin, memcg doesn't
> @@ -158,6 +161,9 @@ extern atomic_t memcg_moving;
>  static inline void mem_cgroup_begin_update_page_stat(struct page *page,
>  					bool *locked, unsigned long *flags)
>  {
> +	if (!static_key_false(&memcg_in_use_key))
> +		return;

Maybe static_key checks could be wrapped by a helper function with a
more obvious name (mem_cgroup_in_use())?

> +
>  	if (mem_cgroup_disabled())
>  		return;

I would assume the check ordering would be vice versa.

>  	rcu_read_lock();
> @@ -171,6 +177,9 @@ void __mem_cgroup_end_update_page_stat(struct page *page,
>  static inline void mem_cgroup_end_update_page_stat(struct page *page,
>  					bool *locked, unsigned long *flags)
>  {
> +	if (!static_key_false(&memcg_in_use_key))
> +		return;
> +
>  	if (mem_cgroup_disabled())
>  		return;

ditto

>  	if (*locked)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0cb5187..a2f73d7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -531,6 +531,8 @@ enum res_type {
>  #define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
>  #define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
>  

/*
 * TODO comment what it is used for, please
 */
> +struct static_key memcg_in_use_key;
> +
>  static void mem_cgroup_get(struct mem_cgroup *memcg);
>  static void mem_cgroup_put(struct mem_cgroup *memcg);
>  
> @@ -2226,6 +2228,9 @@ void mem_cgroup_update_page_stat(struct page *page,
>  	struct page_cgroup *pc = lookup_page_cgroup(page);
>  	unsigned long uninitialized_var(flags);

This artifact can be removed.

> +	if (!static_key_false(&memcg_in_use_key))
> +		return;
> +
>  	if (mem_cgroup_disabled())
>  		return;
>  
> @@ -6340,6 +6345,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>  		parent = mem_cgroup_from_cont(cont->parent);
>  		memcg->use_hierarchy = parent->use_hierarchy;
>  		memcg->oom_kill_disable = parent->oom_kill_disable;
> +
> +		static_key_slow_inc(&memcg_in_use_key);

Please wrap this into a function because later we will probably want to
do an action depending on whether this is a first onlined group (e.g.
sync stats etc...).

>  	}
>  
>  	if (parent && parent->use_hierarchy) {
> @@ -6407,6 +6414,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
>  	kmem_cgroup_destroy(memcg);
>  
>  	memcg_dangling_add(memcg);
> +	static_key_slow_dec(&memcg_in_use_key);
>  	mem_cgroup_put(memcg);

memcg could be still alive at this moment (e.g. due to swap or kmem
charges). This is not a big issue with the current state of the patch
set as you ignore MEM_CGROUP_STAT_SWAP now but you shouldn't rely on
that. We also have a proper place for it already (disarm_static_keys).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
