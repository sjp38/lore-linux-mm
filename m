Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 90A4C6B006C
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 11:37:59 -0500 (EST)
Date: Wed, 28 Nov 2012 11:37:36 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -v2 -mm] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121128163736.GV24381@cmpxchg.org>
References: <20121125120524.GB10623@dhcp22.suse.cz>
 <20121125135542.GE10623@dhcp22.suse.cz>
 <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <50B403CA.501@jp.fujitsu.com>
 <20121127194813.GP24381@cmpxchg.org>
 <20121127205431.GA2433@dhcp22.suse.cz>
 <20121127205944.GB2433@dhcp22.suse.cz>
 <20121128152631.GT24381@cmpxchg.org>
 <20121128160447.GH12309@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121128160447.GH12309@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

On Wed, Nov 28, 2012 at 05:04:47PM +0100, Michal Hocko wrote:
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 095d2b4..5abe441 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -57,13 +57,14 @@ extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
>  				gfp_t gfp_mask);
>  /* for swap handling */
>  extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
> -		struct page *page, gfp_t mask, struct mem_cgroup **memcgp);
> +		struct page *page, gfp_t mask, struct mem_cgroup **memcgp,
> +		bool oom);

Ok, now I feel almost bad for asking, but why the public interface,
too?  You only ever pass "true" in there and this is unlikely to
change anytime soon, no?

> @@ -3754,7 +3753,8 @@ int mem_cgroup_newpage_charge(struct page *page,
>  static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
>  					  struct page *page,
>  					  gfp_t mask,
> -					  struct mem_cgroup **memcgp)
> +					  struct mem_cgroup **memcgp,
> +					  bool oom)
>  {
>  	struct mem_cgroup *memcg;
>  	struct page_cgroup *pc;
> @@ -3776,20 +3776,21 @@ static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
>  	if (!memcg)
>  		goto charge_cur_mm;
>  	*memcgp = memcg;
> -	ret = __mem_cgroup_try_charge(NULL, mask, 1, memcgp, true);
> +	ret = __mem_cgroup_try_charge(NULL, mask, 1, memcgp, oom);
>  	css_put(&memcg->css);
>  	if (ret == -EINTR)
>  		ret = 0;
>  	return ret;
>  charge_cur_mm:
> -	ret = __mem_cgroup_try_charge(mm, mask, 1, memcgp, true);
> +	ret = __mem_cgroup_try_charge(mm, mask, 1, memcgp, oom);
>  	if (ret == -EINTR)
>  		ret = 0;
>  	return ret;
>  }

Only this one is needed...

> @@ -3851,7 +3852,7 @@ void mem_cgroup_commit_charge_swapin(struct page *page,
>  }
>  
>  int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> -				gfp_t gfp_mask)
> +				gfp_t gfp_mask, bool oom)
>  {
>  	struct mem_cgroup *memcg = NULL;
>  	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
> @@ -3863,10 +3864,10 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  		return 0;
>  
>  	if (!PageSwapCache(page))
> -		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type);
> +		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type, oom);
>  	else { /* page is swapcache/shmem */
>  		ret = __mem_cgroup_try_charge_swapin(mm, page,
> -						     gfp_mask, &memcg);
> +						     gfp_mask, &memcg, oom);
>  		if (!ret)
>  			__mem_cgroup_commit_charge_swapin(page, memcg, type);
>  	}

...for this site.

> diff --git a/mm/memory.c b/mm/memory.c
> index 6891d3b..afad903 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2991,7 +2991,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		}
>  	}
>  
> -	if (mem_cgroup_try_charge_swapin(mm, page, GFP_KERNEL, &ptr)) {
> +	if (mem_cgroup_try_charge_swapin(mm, page, GFP_KERNEL, &ptr, true)) {
>  		ret = VM_FAULT_OOM;
>  		goto out_page;
>  	}

Can not happen for shmem, the fault handler uses vma->vm_ops->fault.

> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 2f8e429..8ec511e 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -828,7 +828,7 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
>  	int ret = 1;
>  
>  	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page,
> -					 GFP_KERNEL, &memcg)) {
> +					 GFP_KERNEL, &memcg, true)) {
>  		ret = -ENOMEM;
>  		goto out_nolock;
>  	}

Can not happen for shmem, uses shmem_unuse() instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
