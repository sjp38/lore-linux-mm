Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id A2DFE6B0087
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:56:42 -0500 (EST)
Date: Tue, 29 Jan 2013 15:56:39 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 5/6] memcg: introduce
 swap_cgroup_init()/swap_cgroup_free()
Message-ID: <20130129145639.GG29574@dhcp22.suse.cz>
References: <510658E3.1020306@oracle.com>
 <510658F7.6050806@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <510658F7.6050806@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org

On Mon 28-01-13 18:54:47, Jeff Liu wrote:
> Introduce swap_cgroup_init()/swap_cgroup_free() to allocate buffers when creating the first
> non-root memcg and deallocate buffers on the last non-root memcg is gone.

I think this deserves more words ;) At least it would be good to
describe contexts from which init and free might be called. What are the
locking rules.
Also swap_cgroup_destroy sounds more in pair with swap_cgroup_init.

Please add the users of those function here as well. It is much easier
to review.
 
> Signed-off-by: Jie Liu <jeff.liu@oracle.com>
> CC: Glauber Costa <glommer@parallels.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Mel Gorman <mgorman@suse.de>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Sha Zhengju <handai.szj@taobao.com>
> 
> ---
>  include/linux/page_cgroup.h |   12 +++++
>  mm/page_cgroup.c            |  108 +++++++++++++++++++++++++++++++++++++++----
>  2 files changed, 110 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 777a524..1255cc9 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -113,6 +113,8 @@ extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
>  extern unsigned short lookup_swap_cgroup_id(swp_entry_t ent);
>  extern int swap_cgroup_swapon(int type, unsigned long max_pages);
>  extern void swap_cgroup_swapoff(int type);
> +extern int swap_cgroup_init(void);
> +extern void swap_cgroup_free(void);
>  #else
>  
>  static inline
> @@ -138,6 +140,16 @@ static inline void swap_cgroup_swapoff(int type)
>  	return;
>  }
>  
> +static inline int swap_cgroup_init(void)
> +{
> +	return 0;
> +}
> +
> +static inline void swap_cgroup_free(void)
> +{
> +	return;
> +}
> +
>  #endif /* CONFIG_MEMCG_SWAP */
>  
>  #endif /* !__GENERATING_BOUNDS_H */
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 189fbf5..0ebd127 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -362,14 +362,28 @@ static int swap_cgroup_prepare(int type)
>  	unsigned long idx, max;
>  
>  	ctrl = &swap_cgroup_ctrl[type];
> +	if (!ctrl->length) {
> +		/*
> +		 * Bypass the buffer allocation if the corresponding swap
> +		 * partition/file was turned off.
> +		 */
> +		pr_debug("couldn't allocate swap_cgroup on a disabled swap "
> +			 "partition or file, index: %d\n", type);

Do we really need to log this? I guess your scenario is:
swapon part1
swapon part2
swapon part3
swapoff part2
create first non-root cgroup

which is perfectly ok and I do not see any reason to log it.

> +		return 0;
> +	}
> +
>  	ctrl->map = vzalloc(ctrl->length * sizeof(void *));
> -	if (!ctrl->map)
> +	if (!ctrl->map) {
> +		ctrl->length = 0;
>  		goto nomem;
> +	}
>  
>  	for (idx = 0; idx < ctrl->length; idx++) {
>  		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
> -		if (!page)
> +		if (!page) {
> +			ctrl->length = 0;
>  			goto not_enough_page;
> +		}
>  		ctrl->map[idx] = page;
>  	}
>  	return 0;
> @@ -383,6 +397,32 @@ nomem:

ctrl->length = 0 under this label would be probably nicer than keeping
it at two places.

>  	return -ENOMEM;
>  }
>  
> +/*
> + * free buffer for swap_cgroup.
> + */
> +static void swap_cgroup_teardown(int type)
> +{
> +	struct page **map;
> +	unsigned long length;
> +	struct swap_cgroup_ctrl *ctrl;
> +
> +	ctrl = &swap_cgroup_ctrl[type];
> +	map = ctrl->map;
> +	length = ctrl->length;
> +	ctrl->map = NULL;
> +	ctrl->length = 0;
> +
> +	if (map) {

allocation path checks for ctrl->length so it would be good to unify
both. They are handling the same case (gone swap).

> +		unsigned long i;
> +		for (i = 0; i < length; i++) {
> +			struct page *page = map[i];
> +			if (page)
> +				__free_page(page);
> +		}
> +		vfree(map);
> +	}
> +}
> +
>  static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
>  					struct swap_cgroup_ctrl **ctrlp)
>  {
> @@ -474,6 +514,56 @@ unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
>  	return sc ? sc->id : 0;
>  }
>  
> +/*
> + * Allocate swap cgroup accounting structures when the first non-root
> + * memcg is created.
> + */
> +int swap_cgroup_init(void)
> +{
> +	unsigned int type;
> +
> +	if (!do_swap_account)
> +		return 0;
> +
> +	if (atomic_add_return(1, &memsw_accounting_users) != 1)
> +		return 0;
> +
> +	mutex_lock(&swap_cgroup_mutex);
> +	for (type = 0; type < nr_swapfiles; type++) {
> +		if (swap_cgroup_prepare(type) < 0) {
> +			mutex_unlock(&swap_cgroup_mutex);
> +			goto nomem;
> +		}
> +	}

You should clean up those types that were successful...

> +	mutex_unlock(&swap_cgroup_mutex);
> +	return 0;
> +
> +nomem:
> +	pr_info("couldn't allocate enough memory for swap_cgroup "
> +		"while creating non-root memcg.\n");
> +	return -ENOMEM;
> +}
> +
> +/*
> + * Deallocate swap cgroup accounting structures on the last non-root
> + * memcg removal.
> + */
> +void swap_cgroup_free(void)
> +{
> +	unsigned int type;
> +
> +	if (!do_swap_account)
> +		return;
> +
> +	if (atomic_sub_return(1, &memsw_accounting_users))
> +		return;
> +
> +	mutex_lock(&swap_cgroup_mutex);
> +	for (type = 0; type < nr_swapfiles; type++)
> +		swap_cgroup_teardown(type);
> +	mutex_unlock(&swap_cgroup_mutex);
> +}
> +
>  int swap_cgroup_swapon(int type, unsigned long max_pages)
>  {
>  	unsigned long length;
> @@ -482,20 +572,18 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
>  	if (!do_swap_account)
>  		return 0;
>  
> -	if (!atomic_read(&memsw_accounting_users))
> -		return 0;
> -
>  	length = DIV_ROUND_UP(max_pages, SC_PER_PAGE);
>  
>  	ctrl = &swap_cgroup_ctrl[type];
>  	mutex_lock(&swap_cgroup_mutex);
>  	ctrl->length = length;
>  	spin_lock_init(&ctrl->lock);
> -	if (swap_cgroup_prepare(type)) {
> -		/* memory shortage */
> -		ctrl->length = 0;
> -		mutex_unlock(&swap_cgroup_mutex);
> -		goto nomem;
> +	if (atomic_read(&memsw_accounting_users)) {
> +		if (swap_cgroup_prepare(type)) {
> +			/* memory shortage */
> +			mutex_unlock(&swap_cgroup_mutex);
> +			goto nomem;
> +		}
>  	}
>  	mutex_unlock(&swap_cgroup_mutex);
>  
> -- 
> 1.7.9.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
