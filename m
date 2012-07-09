Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 222376B0072
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:02:40 -0400 (EDT)
Date: Mon, 9 Jul 2012 17:02:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 04/11] mm: memcg: push down PageSwapCache check into
 uncharge entry functions
Message-ID: <20120709150236.GG4627@tiehlicka.suse.cz>
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
 <1341449103-1986-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341449103-1986-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-07-12 02:44:56, Johannes Weiner wrote:
> Not all uncharge paths need to check if the page is swapcache, some of
> them can know for sure.
> 
> Push down the check into all callsites of uncharge_common() so that
> the patch that removes some of them is more obvious.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

with the fix later in the thread
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |   18 ++++++++++++------
>  1 files changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4ea19c6..a3bf414 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2920,8 +2920,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
>  	if (mem_cgroup_disabled())
>  		return NULL;
>  
> -	if (PageSwapCache(page))
> -		return NULL;
> +	VM_BUG_ON(PageSwapCache(page));
>  
>  	if (PageTransHuge(page)) {
>  		nr_pages <<= compound_order(page);
> @@ -3018,6 +3017,8 @@ void mem_cgroup_uncharge_page(struct page *page)
>  	if (page_mapped(page))
>  		return;
>  	VM_BUG_ON(page->mapping && !PageAnon(page));
> +	if (PageSwapCache(page))
> +		return;
>  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_ANON, false);
>  }
>  
> @@ -3025,6 +3026,8 @@ void mem_cgroup_uncharge_cache_page(struct page *page)
>  {
>  	VM_BUG_ON(page_mapped(page));
>  	VM_BUG_ON(page->mapping);
> +	if (PageSwapCache(page))
> +		return;
>  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE, false);
>  }
>  
> @@ -3089,6 +3092,8 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>  	if (!swapout) /* this was a swap cache but the swap is unused ! */
>  		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
>  
> +	if (PageSwapCache(page))
> +		return;
>  	memcg = __mem_cgroup_uncharge_common(page, ctype, false);
>  
>  	/*
> @@ -3278,10 +3283,11 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
>  		unused = oldpage;
>  	}
>  	anon = PageAnon(used);
> -	__mem_cgroup_uncharge_common(unused,
> -		anon ? MEM_CGROUP_CHARGE_TYPE_ANON
> -		     : MEM_CGROUP_CHARGE_TYPE_CACHE,
> -		true);
> +	if (!PageSwapCache(page))
> +		__mem_cgroup_uncharge_common(unused,
> +					     anon ? MEM_CGROUP_CHARGE_TYPE_ANON
> +					     : MEM_CGROUP_CHARGE_TYPE_CACHE,
> +					     true);
>  	css_put(&memcg->css);
>  	/*
>  	 * We disallowed uncharge of pages under migration because mapcount
> -- 
> 1.7.7.6
> 

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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
