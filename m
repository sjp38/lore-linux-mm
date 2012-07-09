Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 278416B006E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:05:37 -0400 (EDT)
Date: Mon, 9 Jul 2012 17:05:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 05/11] mm: memcg: only check for PageSwapCache when
 uncharging anon
Message-ID: <20120709150533.GH4627@tiehlicka.suse.cz>
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
 <1341449103-1986-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341449103-1986-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-07-12 02:44:57, Johannes Weiner wrote:
> Only anon pages that are uncharged at the time of the last page table
> mapping vanishing may be in swapcache.
> 
> When shmem pages, file pages, swap-freed anon pages, or just migrated
> pages are uncharged, they are known for sure to be not in swapcache.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |   13 ++++---------
>  1 files changed, 4 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a3bf414..3d56b4e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3026,8 +3026,6 @@ void mem_cgroup_uncharge_cache_page(struct page *page)
>  {
>  	VM_BUG_ON(page_mapped(page));
>  	VM_BUG_ON(page->mapping);
> -	if (PageSwapCache(page))
> -		return;
>  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE, false);
>  }
>  
> @@ -3092,8 +3090,6 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>  	if (!swapout) /* this was a swap cache but the swap is unused ! */
>  		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
>  
> -	if (PageSwapCache(page))
> -		return;
>  	memcg = __mem_cgroup_uncharge_common(page, ctype, false);
>  
>  	/*
> @@ -3283,11 +3279,10 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
>  		unused = oldpage;
>  	}
>  	anon = PageAnon(used);
> -	if (!PageSwapCache(page))
> -		__mem_cgroup_uncharge_common(unused,
> -					     anon ? MEM_CGROUP_CHARGE_TYPE_ANON
> -					     : MEM_CGROUP_CHARGE_TYPE_CACHE,
> -					     true);
> +	__mem_cgroup_uncharge_common(unused,
> +				     anon ? MEM_CGROUP_CHARGE_TYPE_ANON
> +				     : MEM_CGROUP_CHARGE_TYPE_CACHE,
> +				     true);
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
