Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id 52DA56B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 11:20:45 -0500 (EST)
Received: by mail-bk0-f49.google.com with SMTP id my13so2394223bkb.22
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 08:20:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p46si526386eem.21.2013.12.16.08.20.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 08:20:43 -0800 (PST)
Date: Mon, 16 Dec 2013 17:20:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: 3.13-rc breaks MEMCG_SWAP
Message-ID: <20131216162042.GC26797@dhcp22.suse.cz>
References: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 16-12-13 00:36:05, Hugh Dickins wrote:
[...]

OK, I went through the patch and it looks good except for suspicious
ctrl->lock handling in swap_cgroup_reassign (see below). I am just
suggesting to split it into 4 parts

* swap_cgroup_mutex -> swap_cgroup_lock
* swapon cleanup
* drop irqsave when taking ctrl->lock
* mem_cgroup_reparent_swap

but I will leave the split up to you. Just make sure that the fix is a
separate patch, please.

[...]
> --- 3.13-rc4/mm/page_cgroup.c	2013-02-18 15:58:34.000000000 -0800
> +++ linux/mm/page_cgroup.c	2013-12-15 14:34:36.312485960 -0800
> @@ -322,7 +322,8 @@ void __meminit pgdat_page_cgroup_init(st
>  
>  #ifdef CONFIG_MEMCG_SWAP
>  
> -static DEFINE_MUTEX(swap_cgroup_mutex);
> +static DEFINE_SPINLOCK(swap_cgroup_lock);
> +

This one is worth a separate patch IMO.

>  struct swap_cgroup_ctrl {
>  	struct page **map;
>  	unsigned long length;
> @@ -353,14 +354,11 @@ struct swap_cgroup {
>  /*
>   * allocate buffer for swap_cgroup.
>   */
> -static int swap_cgroup_prepare(int type)
> +static int swap_cgroup_prepare(struct swap_cgroup_ctrl *ctrl)
>  {
>  	struct page *page;
> -	struct swap_cgroup_ctrl *ctrl;
>  	unsigned long idx, max;
>  
> -	ctrl = &swap_cgroup_ctrl[type];
> -
>  	for (idx = 0; idx < ctrl->length; idx++) {
>  		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
>  		if (!page)

This with swap_cgroup_swapon should be in a separate patch as a cleanup.

> @@ -407,18 +405,17 @@ unsigned short swap_cgroup_cmpxchg(swp_e
>  {
>  	struct swap_cgroup_ctrl *ctrl;
>  	struct swap_cgroup *sc;
> -	unsigned long flags;
>  	unsigned short retval;
>  
>  	sc = lookup_swap_cgroup(ent, &ctrl);
>  
> -	spin_lock_irqsave(&ctrl->lock, flags);
> +	spin_lock(&ctrl->lock);
>  	retval = sc->id;
>  	if (retval == old)
>  		sc->id = new;
>  	else
>  		retval = 0;
> -	spin_unlock_irqrestore(&ctrl->lock, flags);
> +	spin_unlock(&ctrl->lock);
>  	return retval;
>  }
>  
> @@ -435,14 +432,13 @@ unsigned short swap_cgroup_record(swp_en
>  	struct swap_cgroup_ctrl *ctrl;
>  	struct swap_cgroup *sc;
>  	unsigned short old;
> -	unsigned long flags;
>  
>  	sc = lookup_swap_cgroup(ent, &ctrl);
>  
> -	spin_lock_irqsave(&ctrl->lock, flags);
> +	spin_lock(&ctrl->lock);
>  	old = sc->id;
>  	sc->id = id;
> -	spin_unlock_irqrestore(&ctrl->lock, flags);
> +	spin_unlock(&ctrl->lock);
>  
>  	return old;
>  }

I would prefer these two in a separate patch as well. I have no idea why
these were IRQ aware as this was never needed AFAICS.
e9e58a4ec3b10 is not very specific...

> @@ -451,19 +447,60 @@ unsigned short swap_cgroup_record(swp_en
>   * lookup_swap_cgroup_id - lookup mem_cgroup id tied to swap entry
>   * @ent: swap entry to be looked up.
>   *
> - * Returns CSS ID of mem_cgroup at success. 0 at failure. (0 is invalid ID)
> + * Returns ID of mem_cgroup at success. 0 at failure. (0 is invalid ID)
>   */
>  unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
>  {
>  	return lookup_swap_cgroup(ent, NULL)->id;
>  }
>  
> +/**
> + * swap_cgroup_reassign - assign all old entries to new (before old is freed).
> + * @old: id of emptied memcg whose entries are now to be reassigned
> + * @new: id of parent memcg to which those entries are to be assigned
> + *
> + * Returns number of entries reassigned, for debugging or for statistics.
> + */
> +long swap_cgroup_reassign(unsigned short old, unsigned short new)
> +{
> +	long reassigned = 0;
> +	int type;
> +
> +	for (type = 0; type < MAX_SWAPFILES; type++) {
> +		struct swap_cgroup_ctrl *ctrl = &swap_cgroup_ctrl[type];
> +		unsigned long idx;
> +
> +		for (idx = 0; idx < ACCESS_ONCE(ctrl->length); idx++) {
> +			struct swap_cgroup *sc, *scend;
> +
> +			spin_lock(&swap_cgroup_lock);
> +			if (idx >= ACCESS_ONCE(ctrl->length))
> +				goto unlock;
> +			sc = page_address(ctrl->map[idx]);
> +			for (scend = sc + SC_PER_PAGE; sc < scend; sc++) {
> +				if (sc->id != old)
> +					continue;

Is this safe? What prevents from race when id is set to old?

> +				spin_lock(&ctrl->lock);
> +				if (sc->id == old) {

Also it seems that compiler is free to optimize this test away, no?
You need ACCESS_ONCE here as well, I guess.

> +					sc->id = new;
> +					reassigned++;
> +				}
> +				spin_unlock(&ctrl->lock);
> +			}
> +unlock:
> +			spin_unlock(&swap_cgroup_lock);
> +			cond_resched();
> +		}
> +	}
> +	return reassigned;
> +}
> +
>  int swap_cgroup_swapon(int type, unsigned long max_pages)
>  {
>  	void *array;
>  	unsigned long array_size;
>  	unsigned long length;
> -	struct swap_cgroup_ctrl *ctrl;
> +	struct swap_cgroup_ctrl ctrl;
>  
>  	if (!do_swap_account)
>  		return 0;
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
