Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 119F76B004F
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 05:50:09 -0500 (EST)
Date: Fri, 2 Dec 2011 11:50:05 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] page_cgroup: add helper function to get swap_cgroup
Message-ID: <20111202105005.GB29180@tiehlicka.suse.cz>
References: <1322822427-7691-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1322822427-7691-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, jweiner@redhat.com, bsingharora@gmail.com

On Fri 02-12-11 18:40:27, Bob Liu wrote:
> There are multi places need to get swap_cgroup, so add a helper
> function:
> static struct swap_cgroup *swap_cgroup_getsc(swp_entry_t ent,
>                                 struct swap_cgroup_ctrl **ctrl);
> to simple the code.
> 
> v1 -> v2:
>  - add parameter struct swap_cgroup_ctrl **ctrl suggested by Michal
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Thanks.

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/page_cgroup.c |   57 ++++++++++++++++++++++-------------------------------
>  1 files changed, 24 insertions(+), 33 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index f0559e0..1970e8a 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -362,6 +362,27 @@ not_enough_page:
>  	return -ENOMEM;
>  }
>  
> +static struct swap_cgroup *swap_cgroup_getsc(swp_entry_t ent,
> +					struct swap_cgroup_ctrl **ctrl)
> +{
> +	int type = swp_type(ent);
> +	unsigned long offset = swp_offset(ent);
> +	unsigned long idx = offset / SC_PER_PAGE;
> +	unsigned long pos = offset & SC_POS_MASK;
> +	struct swap_cgroup_ctrl *temp_ctrl;
> +	struct page *mappage;
> +	struct swap_cgroup *sc;
> +
> +	temp_ctrl = &swap_cgroup_ctrl[type];
> +	if (ctrl)
> +		*ctrl = temp_ctrl;
> +
> +	mappage = temp_ctrl->map[idx];
> +	sc = page_address(mappage);
> +	sc += pos;
> +	return sc;
> +}
> +
>  /**
>   * swap_cgroup_cmpxchg - cmpxchg mem_cgroup's id for this swp_entry.
>   * @end: swap entry to be cmpxchged
> @@ -374,21 +395,13 @@ not_enough_page:
>  unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
>  					unsigned short old, unsigned short new)
>  {
> -	int type = swp_type(ent);
> -	unsigned long offset = swp_offset(ent);
> -	unsigned long idx = offset / SC_PER_PAGE;
> -	unsigned long pos = offset & SC_POS_MASK;
>  	struct swap_cgroup_ctrl *ctrl;
> -	struct page *mappage;
>  	struct swap_cgroup *sc;
>  	unsigned long flags;
>  	unsigned short retval;
>  
> -	ctrl = &swap_cgroup_ctrl[type];
> +	sc = swap_cgroup_getsc(ent, &ctrl);
>  
> -	mappage = ctrl->map[idx];
> -	sc = page_address(mappage);
> -	sc += pos;
>  	spin_lock_irqsave(&ctrl->lock, flags);
>  	retval = sc->id;
>  	if (retval == old)
> @@ -409,21 +422,13 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
>   */
>  unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>  {
> -	int type = swp_type(ent);
> -	unsigned long offset = swp_offset(ent);
> -	unsigned long idx = offset / SC_PER_PAGE;
> -	unsigned long pos = offset & SC_POS_MASK;
>  	struct swap_cgroup_ctrl *ctrl;
> -	struct page *mappage;
>  	struct swap_cgroup *sc;
>  	unsigned short old;
>  	unsigned long flags;
>  
> -	ctrl = &swap_cgroup_ctrl[type];
> +	sc = swap_cgroup_getsc(ent, &ctrl);
>  
> -	mappage = ctrl->map[idx];
> -	sc = page_address(mappage);
> -	sc += pos;
>  	spin_lock_irqsave(&ctrl->lock, flags);
>  	old = sc->id;
>  	sc->id = id;
> @@ -440,21 +445,7 @@ unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>   */
>  unsigned short lookup_swap_cgroup(swp_entry_t ent)
>  {
> -	int type = swp_type(ent);
> -	unsigned long offset = swp_offset(ent);
> -	unsigned long idx = offset / SC_PER_PAGE;
> -	unsigned long pos = offset & SC_POS_MASK;
> -	struct swap_cgroup_ctrl *ctrl;
> -	struct page *mappage;
> -	struct swap_cgroup *sc;
> -	unsigned short ret;
> -
> -	ctrl = &swap_cgroup_ctrl[type];
> -	mappage = ctrl->map[idx];
> -	sc = page_address(mappage);
> -	sc += pos;
> -	ret = sc->id;
> -	return ret;
> +	return swap_cgroup_getsc(ent, NULL)->id;
>  }
>  
>  int swap_cgroup_swapon(int type, unsigned long max_pages)
> -- 
> 1.7.0.4
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
