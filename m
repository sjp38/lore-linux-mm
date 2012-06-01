Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 269D86B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 07:07:16 -0400 (EDT)
Date: Fri, 1 Jun 2012 13:07:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] rename MEM_CGROUP_CHARGE_TYPE_MAPPED as
 MEM_CGROUP_CHARGE_TYPE_ANON
Message-ID: <20120601110712.GD30196@tiehlicka.suse.cz>
References: <4FC89D22.6020802@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FC89D22.6020802@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, akpm@linux-foundation.org, cgroups@vger.kernel.org

On Fri 01-06-12 19:44:50, KAMEZAWA Hiroyuki wrote:
> Now, in memcg, 2 "MAPPED" enum/macro are found
>  MEM_CGROUP_CHARGE_TYPE_MAPPED
>  MEM_CGROUP_STAT_FILE_MAPPED
> 
> Their names looks similar to each other but the former is used for
> accounting anonymous memory, the latter is mapped-file.
> (I've received questions caused by this naming issue 3 times..)
> 
> This patch renames MEM_CGROUP_CHARGE_TYPE_MAPPED  as MEM_CGROUP_CHARGE_TYPE_ANON.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Yes, this has been really confusing
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |   16 ++++++++--------
>  1 files changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 76bc54c..f4534d7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -392,7 +392,7 @@ static bool move_file(void)
>  
>  enum charge_type {
>  	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
> -	MEM_CGROUP_CHARGE_TYPE_MAPPED,
> +	MEM_CGROUP_CHARGE_TYPE_ANON,
>  	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
>  	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
>  	MEM_CGROUP_CHARGE_TYPE_SWAPOUT,	/* for accounting swapcache */
> @@ -2538,7 +2538,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>  		spin_unlock_irq(&zone->lru_lock);
>  	}
>  
> -	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> +	if (ctype == MEM_CGROUP_CHARGE_TYPE_ANON)
>  		anon = true;
>  	else
>  		anon = false;
> @@ -2747,7 +2747,7 @@ int mem_cgroup_newpage_charge(struct page *page,
>  	VM_BUG_ON(page->mapping && !PageAnon(page));
>  	VM_BUG_ON(!mm);
>  	return mem_cgroup_charge_common(page, mm, gfp_mask,
> -					MEM_CGROUP_CHARGE_TYPE_MAPPED);
> +					MEM_CGROUP_CHARGE_TYPE_ANON);
>  }
>  
>  static void
> @@ -2861,7 +2861,7 @@ void mem_cgroup_commit_charge_swapin(struct page *page,
>  				     struct mem_cgroup *memcg)
>  {
>  	__mem_cgroup_commit_charge_swapin(page, memcg,
> -					  MEM_CGROUP_CHARGE_TYPE_MAPPED);
> +					  MEM_CGROUP_CHARGE_TYPE_ANON);
>  }
>  
>  void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg)
> @@ -2969,7 +2969,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	anon = PageAnon(page);
>  
>  	switch (ctype) {
> -	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
> +	case MEM_CGROUP_CHARGE_TYPE_ANON:
>  		/*
>  		 * Generally PageAnon tells if it's the anon statistics to be
>  		 * updated; but sometimes e.g. mem_cgroup_uncharge_page() is
> @@ -3029,7 +3029,7 @@ void mem_cgroup_uncharge_page(struct page *page)
>  	if (page_mapped(page))
>  		return;
>  	VM_BUG_ON(page->mapping && !PageAnon(page));
> -	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_MAPPED);
> +	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_ANON);
>  }
>  
>  void mem_cgroup_uncharge_cache_page(struct page *page)
> @@ -3454,7 +3454,7 @@ int mem_cgroup_prepare_migration(struct page *page,
>  	 * mapcount will be finally 0 and we call uncharge in end_migration().
>  	 */
>  	if (PageAnon(page))
> -		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
> +		ctype = MEM_CGROUP_CHARGE_TYPE_ANON;
>  	else if (page_is_file_cache(page))
>  		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
>  	else
> @@ -3493,7 +3493,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
>  	unlock_page_cgroup(pc);
>  	anon = PageAnon(used);
>  	__mem_cgroup_uncharge_common(unused,
> -		anon ? MEM_CGROUP_CHARGE_TYPE_MAPPED
> +		anon ? MEM_CGROUP_CHARGE_TYPE_ANON
>  		     : MEM_CGROUP_CHARGE_TYPE_CACHE);
>  
>  	/*
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
