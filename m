Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id ECCE86B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 10:33:40 -0500 (EST)
Date: Tue, 20 Dec 2011 16:33:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] memcg: simplify page cache charging.
Message-ID: <20111220153337.GO10565@tiehlicka.suse.cz>
References: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
 <20111214164922.05fb4afe.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111214164922.05fb4afe.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Wed 14-12-11 16:49:22, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This patch is a clean up. No functional/logical changes.
> 
> Because of commit ef6a3c6311, FUSE uses replace_page_cache() instead
> of add_to_page_cache(). Then, mem_cgroup_cache_charge() is not
> called against FUSE's pages from splice.
> 
> So, Now, mem_cgroup_cache_charge() doesn't receive a page on LRU
> unless it's not SwapCache.

too many negations makes it hard to read. What about:

mem_cgroup_cache_charge gets pages that are not on LRU with exception of
PageSwapCache pages.

> For checking, WARN_ON_ONCE(PageLRU(page)) is added.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Makes sense.
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |   31 +++++++++----------------------
>  1 files changed, 9 insertions(+), 22 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a9e92a6..947c62c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2710,6 +2710,7 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  				gfp_t gfp_mask)
>  {
>  	struct mem_cgroup *memcg = NULL;
> +	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
>  	int ret;
>  
>  	if (mem_cgroup_disabled())
> @@ -2719,31 +2720,17 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  
>  	if (unlikely(!mm))
>  		mm = &init_mm;
> +	if (!page_is_file_cache(page))
> +		type = MEM_CGROUP_CHARGE_TYPE_SHMEM;
>  
> -	if (page_is_file_cache(page)) {
> -		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &memcg, true);
> -		if (ret || !memcg)
> -			return ret;
> -
> -		/*
> -		 * FUSE reuses pages without going through the final
> -		 * put that would remove them from the LRU list, make
> -		 * sure that they get relinked properly.
> -		 */
> -		__mem_cgroup_commit_charge_lrucare(page, memcg,
> -					MEM_CGROUP_CHARGE_TYPE_CACHE);
> -		return ret;
> -	}
> -	/* shmem */
> -	if (PageSwapCache(page)) {
> +	if (!PageSwapCache(page)) {
> +		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type);
> +		WARN_ON_ONCE(PageLRU(page));
> +	} else { /* page is swapcache/shmem */
>  		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &memcg);
>  		if (!ret)
> -			__mem_cgroup_commit_charge_swapin(page, memcg,
> -					MEM_CGROUP_CHARGE_TYPE_SHMEM);
> -	} else
> -		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
> -					MEM_CGROUP_CHARGE_TYPE_SHMEM);
> -
> +			__mem_cgroup_commit_charge_swapin(page, memcg, type);
> +	}
>  	return ret;
>  }
>  
> -- 
> 1.7.4.1
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
