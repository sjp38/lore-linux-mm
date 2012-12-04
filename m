Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 09F276B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 05:11:39 -0500 (EST)
Date: Tue, 4 Dec 2012 11:11:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH 1/3] memcg: refactor pages allocation/free for
 swap_cgroup
Message-ID: <20121204101137.GA1343@dhcp22.suse.cz>
References: <50BDB5E0.7030906@oracle.com>
 <50BDB5EB.70909@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50BDB5EB.70909@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>

On Tue 04-12-12 16:35:55, Jeff Liu wrote:
[...]
>  /*
> - * allocate buffer for swap_cgroup.
> + * Allocate pages for swap_cgroup upon a given type.
>   */
> -static int swap_cgroup_prepare(int type)
> +static int swap_cgroup_alloc_pages(int type)

I am not sure this name is better. The whole point of the function is
the prepare swap accounting internals. Yeah we are allocating here as
well but this is not that important.
It also feels strange that the function name suggests we allocate pages
but none of them are returned.

>  {
> -	struct page *page;
>  	struct swap_cgroup_ctrl *ctrl;
> -	unsigned long idx, max;
> +	unsigned long i, length, max;
>  
>  	ctrl = &swap_cgroup_ctrl[type];
> -
> -	for (idx = 0; idx < ctrl->length; idx++) {
> -		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
> +	length = ctrl->length;
> +	for (i = 0; i < length; i++) {
> +		struct page *page = alloc_page(GFP_KERNEL | __GFP_ZERO);
>  		if (!page)
>  			goto not_enough_page;
> -		ctrl->map[idx] = page;
> +		ctrl->map[i] = page;
>  	}
> +
>  	return 0;
> +
>  not_enough_page:
> -	max = idx;
> -	for (idx = 0; idx < max; idx++)
> -		__free_page(ctrl->map[idx]);
> +	max = i;
> +	for (i = 0; i < max; i++)
> +		__free_page(ctrl->map[i]);
>  
>  	return -ENOMEM;
>  }

Is there any reason for the local variables rename exercise?
I really do not like it.

>  
> +static void swap_cgroup_free_pages(int type)
> +{
> +	struct swap_cgroup_ctrl *ctrl;
> +	struct page **map;
> +
> +	ctrl = &swap_cgroup_ctrl[type];
> +	map = ctrl->map;
> +	if (map) {
> +		unsigned long length = ctrl->length;
> +		unsigned long i;
> +
> +		for (i = 0; i < length; i++) {
> +			struct page *page = map[i];
> +			if (page)
> +				__free_page(page);
> +		}
> +	}
> +}
> +

This function is not used in this patch so I would suggest moving it
into the #2.

>  static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
>  					struct swap_cgroup_ctrl **ctrlp)
>  {
> @@ -477,7 +497,7 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
>  	ctrl->length = length;
>  	ctrl->map = array;
>  	spin_lock_init(&ctrl->lock);
> -	if (swap_cgroup_prepare(type)) {
> +	if (swap_cgroup_alloc_pages(type)) {
>  		/* memory shortage */
>  		ctrl->map = NULL;
>  		ctrl->length = 0;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
