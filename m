Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 653686B0031
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 03:55:32 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id k14so486926wgh.8
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 00:55:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10si22929428wjb.84.2014.07.16.00.55.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 00:55:30 -0700 (PDT)
Date: Wed, 16 Jul 2014 09:55:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140716075528.GB7121@dhcp22.suse.cz>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715155537.GA19454@nhori.bos.redhat.com>
 <20140715160735.GB29269@dhcp22.suse.cz>
 <20140715173439.GU29639@cmpxchg.org>
 <20140715184358.GA31550@nhori.bos.redhat.com>
 <20140715190454.GW29639@cmpxchg.org>
 <20140715204953.GA21016@nhori.bos.redhat.com>
 <20140715214843.GX29639@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140715214843.GX29639@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 15-07-14 17:48:43, Johannes Weiner wrote:
> On Tue, Jul 15, 2014 at 04:49:53PM -0400, Naoya Horiguchi wrote:
> > I feel that these 2 messages have the same cause (just appear differently).
> > __add_to_page_cache_locked() (and mem_cgroup_try_charge()) can be called
> > for hugetlb, while we avoid calling mem_cgroup_migrate()/mem_cgroup_uncharge()
> > for hugetlb. This seems to make page_cgroup of the hugepage inconsistent,
> > and results in the bad page bug ("page dumped because: cgroup check failed").
> > So maybe some more PageHuge check is necessary around the charging code.
> 
> This struck me as odd because I don't remember removing a PageHuge()
> call in the charge path and wondered how it worked before my changes:
> apparently it just checked PageCompound() in mem_cgroup_charge_file().

I have noticed the PageCompound check during review which made me look
into history but 52d4b9ac0b98 (memcg: allocate all page_cgroup at boot)
didn't mention why it added it so I considered it hack-at-the-time which
is not actual anymore. Sorry I should have been more careful.

> So it's not fallout of the new uncharge batching code, but was already
> broken during the rewrite of the charge API because then hugetlb pages
> entered the charging code.
> 
> Anyway, we don't have file-specific charging code anymore, and the
> PageCompound() check would have required changing anyway for THP
> cache.  So I guess the solution is checking PageHuge() in charge,
> uncharge, and migrate for now.  Oh well.
> 
> How about this?

Looks good to me. I do not know why you have moved the charge function
out of __page_cache_release (the function would deserve a better name
btw. - lru_page_release would sound little bit better to me and it would
be quite natural place for the uncharge as well) when you already check
PageHuge in __put_compound_page. But that is just a minor thing.

> diff --git a/mm/filemap.c b/mm/filemap.c
> index 9c99d6868a5e..b61194273b56 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -564,9 +564,12 @@ static int __add_to_page_cache_locked(struct page *page,
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	VM_BUG_ON_PAGE(PageSwapBacked(page), page);
>  
> -	error = mem_cgroup_try_charge(page, current->mm, gfp_mask, &memcg);
> -	if (error)
> -		return error;
> +	if (!PageHuge(page)) {
> +		error = mem_cgroup_try_charge(page, current->mm,
> +					      gfp_mask, &memcg);
> +		if (error)
> +			return error;
> +	}
>  
>  	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
>  	if (error) {
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 7f5a42403fae..dabed2f08609 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -781,7 +781,8 @@ static int move_to_new_page(struct page *newpage, struct page *page,
>  		if (!PageAnon(newpage))
>  			newpage->mapping = NULL;
>  	} else {
> -		mem_cgroup_migrate(page, newpage, false);
> +		if (!PageHuge(page))
> +			mem_cgroup_migrate(page, newpage, false);
>  		if (remap_swapcache)
>  			remove_migration_ptes(page, newpage);
>  		if (!PageAnon(page))
> diff --git a/mm/swap.c b/mm/swap.c
> index 3461f2f5be20..97b6ec132398 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -62,12 +62,12 @@ static void __page_cache_release(struct page *page)
>  		del_page_from_lru_list(page, lruvec, page_off_lru(page));
>  		spin_unlock_irqrestore(&zone->lru_lock, flags);
>  	}
> -	mem_cgroup_uncharge(page);
>  }
>  
>  static void __put_single_page(struct page *page)
>  {
>  	__page_cache_release(page);
> +	mem_cgroup_uncharge_page(page);
>  	free_hot_cold_page(page, false);
>  }
>  
> @@ -75,7 +75,10 @@ static void __put_compound_page(struct page *page)
>  {
>  	compound_page_dtor *dtor;
>  
> -	__page_cache_release(page);
> +	if (!PageHuge(page)) {
> +		__page_cache_release(page);
> +		mem_cgroup_uncharge_page(page);
> +	}
>  	dtor = get_compound_page_dtor(page);
>  	(*dtor)(page);
>  }

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
