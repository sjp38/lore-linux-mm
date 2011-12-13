Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 519A86B0274
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 11:21:38 -0500 (EST)
Date: Tue, 13 Dec 2011 17:21:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] memcg: Use gfp_mask __GFP_NORETRY in try charge
Message-ID: <20111213162126.GE30440@tiehlicka.suse.cz>
References: <1323742587-9084-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1323742587-9084-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Mon 12-12-11 18:16:27, Ying Han wrote:
> In __mem_cgroup_try_charge() function, the parameter "oom" is passed from the
> caller indicating whether or not the charge should enter memcg oom kill. In
> fact, we should be able to eliminate that by using the existing gfp_mask and
> __GFP_NORETRY flag.
> 
> This patch removed the "oom" parameter, and add the __GFP_NORETRY flag into
> gfp_mask for those doesn't want to enter memcg oom. There is no functional
> change for those setting false to "oom" like mem_cgroup_move_parent(), but
> __GFP_NORETRY now is checked for those even setting true to "oom".
> 
> The __GFP_NORETRY is used in page allocator to bypass retry and oom kill. I
> believe there is a reason for callers to use that flag, and in memcg charge
> we need to respect it as well.

What is the reason for this change?
To be honest it makes the oom condition more obscure. __GFP_NORETRY
documentation doesn't say anything about OOM and one would have to know
details about allocator internals to follow this. 
So I am not saying the patch is bad but I would need some strong reason
to like it ;)

> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  mm/memcontrol.c |   26 +++++++++++++-------------
>  1 files changed, 13 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 894e0d2..4c49ca0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2065,8 +2065,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  				   gfp_t gfp_mask,
>  				   unsigned int nr_pages,
> -				   struct mem_cgroup **ptr,
> -				   bool oom)
> +				   struct mem_cgroup **ptr)
>  {
>  	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>  	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> @@ -2149,7 +2148,7 @@ again:
>  		}
>  
>  		oom_check = false;
> -		if (oom && !nr_oom_retries) {
> +		if (!(gfp_mask & __GFP_NORETRY) && !nr_oom_retries) {
>  			oom_check = true;
>  			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
>  		}
> @@ -2167,7 +2166,7 @@ again:
>  			css_put(&memcg->css);
>  			goto nomem;
>  		case CHARGE_NOMEM: /* OOM routine works */
> -			if (!oom) {
> +			if (gfp_mask & __GFP_NORETRY) {
>  				css_put(&memcg->css);
>  				goto nomem;
>  			}
> @@ -2456,10 +2455,11 @@ static int mem_cgroup_move_parent(struct page *page,
>  	if (isolate_lru_page(page))
>  		goto put;
>  
> +	gfp_mask |= __GFP_NORETRY;
>  	nr_pages = hpage_nr_pages(page);
>  
>  	parent = mem_cgroup_from_cont(pcg);
> -	ret = __mem_cgroup_try_charge(NULL, gfp_mask, nr_pages, &parent, false);
> +	ret = __mem_cgroup_try_charge(NULL, gfp_mask, nr_pages, &parent);
>  	if (ret || !parent)
>  		goto put_back;
>  
> @@ -2492,7 +2492,6 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
>  	struct mem_cgroup *memcg = NULL;
>  	unsigned int nr_pages = 1;
>  	struct page_cgroup *pc;
> -	bool oom = true;
>  	int ret;
>  
>  	if (PageTransHuge(page)) {
> @@ -2502,13 +2501,13 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
>  		 * Never OOM-kill a process for a huge page.  The
>  		 * fault handler will fall back to regular pages.
>  		 */
> -		oom = false;
> +		gfp_mask |= __GFP_NORETRY;
>  	}
>  
>  	pc = lookup_page_cgroup(page);
>  	BUG_ON(!pc); /* XXX: remove this and move pc lookup into commit */
>  
> -	ret = __mem_cgroup_try_charge(mm, gfp_mask, nr_pages, &memcg, oom);
> +	ret = __mem_cgroup_try_charge(mm, gfp_mask, nr_pages, &memcg);
>  	if (ret || !memcg)
>  		return ret;
>  
> @@ -2571,7 +2570,7 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  		mm = &init_mm;
>  
>  	if (page_is_file_cache(page)) {
> -		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &memcg, true);
> +		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &memcg);
>  		if (ret || !memcg)
>  			return ret;
>  
> @@ -2629,13 +2628,13 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
>  	if (!memcg)
>  		goto charge_cur_mm;
>  	*ptr = memcg;
> -	ret = __mem_cgroup_try_charge(NULL, mask, 1, ptr, true);
> +	ret = __mem_cgroup_try_charge(NULL, mask, 1, ptr);
>  	css_put(&memcg->css);
>  	return ret;
>  charge_cur_mm:
>  	if (unlikely(!mm))
>  		mm = &init_mm;
> -	return __mem_cgroup_try_charge(mm, mask, 1, ptr, true);
> +	return __mem_cgroup_try_charge(mm, mask, 1, ptr);
>  }
>  
>  static void
> @@ -3024,6 +3023,7 @@ int mem_cgroup_prepare_migration(struct page *page,
>  	int ret = 0;
>  
>  	*ptr = NULL;
> +	gfp_mask |= __GFP_NORETRY;
>  
>  	VM_BUG_ON(PageTransHuge(page));
>  	if (mem_cgroup_disabled())
> @@ -3075,7 +3075,7 @@ int mem_cgroup_prepare_migration(struct page *page,
>  		return 0;
>  
>  	*ptr = memcg;
> -	ret = __mem_cgroup_try_charge(NULL, gfp_mask, 1, ptr, false);
> +	ret = __mem_cgroup_try_charge(NULL, gfp_mask, 1, ptr);
>  	css_put(&memcg->css);/* drop extra refcnt */
>  	if (ret || *ptr == NULL) {
>  		if (PageAnon(page)) {
> @@ -4765,7 +4765,7 @@ one_by_one:
>  			cond_resched();
>  		}
>  		ret = __mem_cgroup_try_charge(NULL,
> -					GFP_KERNEL, 1, &memcg, false);
> +					GFP_KERNEL | __GFP_NORETRY, 1, &memcg);
>  		if (ret || !memcg)
>  			/* mem_cgroup_clear_mc() will do uncharge later */
>  			return -ENOMEM;
> -- 
> 1.7.3.1
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
