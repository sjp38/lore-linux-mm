Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 60ACE6B0035
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 09:31:10 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id w7so741450qcr.12
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 06:31:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d7si26512146qag.107.2014.07.16.06.31.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jul 2014 06:31:09 -0700 (PDT)
Date: Wed, 16 Jul 2014 09:30:50 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140716133050.GA4644@nhori.redhat.com>
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
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 15, 2014 at 05:48:43PM -0400, Johannes Weiner wrote:
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
> 
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

With tweaking a bit, this patch solved the problem, thanks!

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

We have mem_cgroup_commit_charge() later in __add_to_page_cache_locked(),
so adding "if (!PageHuge(page))" for it is necessary too.

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

My kernel is based on mmotm-2014-07-09-17-08, where mem_cgroup_uncharge_page()
does not exist any more. Maybe mem_cgroup_uncharge(page) seems correct.

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

ditto.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
