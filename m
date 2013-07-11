Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 5705D6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 09:40:04 -0400 (EDT)
Date: Thu, 11 Jul 2013 15:39:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 1/6] memcg: remove MEMCG_NR_FILE_MAPPED
Message-ID: <20130711133958.GH21667@dhcp22.suse.cz>
References: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
 <1373044902-27445-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373044902-27445-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, fengguang.wu@intel.com, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

I think this one can go in now also without the rest of the series.
It is a good clean up

On Sat 06-07-13 01:21:42, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> While accounting memcg page stat, it's not worth to use MEMCG_NR_FILE_MAPPED
> as an extra layer of indirection because of the complexity and presumed
> performance overhead. We can use MEM_CGROUP_STAT_FILE_MAPPED directly.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: Fengguang Wu <fengguang.wu@intel.com>
> Reviewed-by: Greg Thelen <gthelen@google.com>
> cc: Andrew Morton <akpm@linux-foundation.org>
> cc: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/memcontrol.h |   27 +++++++++++++++++++--------
>  mm/memcontrol.c            |   25 +------------------------
>  mm/rmap.c                  |    4 ++--
>  3 files changed, 22 insertions(+), 34 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 7b4d9d7..d166aeb 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -30,9 +30,20 @@ struct page;
>  struct mm_struct;
>  struct kmem_cache;
>  
> -/* Stats that can be updated by kernel. */
> -enum mem_cgroup_page_stat_item {
> -	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
> +/*
> + * The corresponding mem_cgroup_stat_names is defined in mm/memcontrol.c,
> + * These two lists should keep in accord with each other.
> + */
> +enum mem_cgroup_stat_index {
> +	/*
> +	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> +	 */
> +	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
> +	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
> +	MEM_CGROUP_STAT_RSS_HUGE,	/* # of pages charged as anon huge */
> +	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
> +	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
> +	MEM_CGROUP_STAT_NSTATS,
>  };
>  
>  struct mem_cgroup_reclaim_cookie {
> @@ -165,17 +176,17 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
>  }
>  
>  void mem_cgroup_update_page_stat(struct page *page,
> -				 enum mem_cgroup_page_stat_item idx,
> +				 enum mem_cgroup_stat_index idx,
>  				 int val);
>  
>  static inline void mem_cgroup_inc_page_stat(struct page *page,
> -					    enum mem_cgroup_page_stat_item idx)
> +					    enum mem_cgroup_stat_index idx)
>  {
>  	mem_cgroup_update_page_stat(page, idx, 1);
>  }
>  
>  static inline void mem_cgroup_dec_page_stat(struct page *page,
> -					    enum mem_cgroup_page_stat_item idx)
> +					    enum mem_cgroup_stat_index idx)
>  {
>  	mem_cgroup_update_page_stat(page, idx, -1);
>  }
> @@ -349,12 +360,12 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
>  }
>  
>  static inline void mem_cgroup_inc_page_stat(struct page *page,
> -					    enum mem_cgroup_page_stat_item idx)
> +					    enum mem_cgroup_stat_index idx)
>  {
>  }
>  
>  static inline void mem_cgroup_dec_page_stat(struct page *page,
> -					    enum mem_cgroup_page_stat_item idx)
> +					    enum mem_cgroup_stat_index idx)
>  {
>  }
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6e120e4..f9acf49 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -85,21 +85,6 @@ static int really_do_swap_account __initdata = 0;
>  #endif
>  
>  
> -/*
> - * Statistics for memory cgroup.
> - */
> -enum mem_cgroup_stat_index {
> -	/*
> -	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> -	 */
> -	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
> -	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
> -	MEM_CGROUP_STAT_RSS_HUGE,	/* # of pages charged as anon huge */
> -	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
> -	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
> -	MEM_CGROUP_STAT_NSTATS,
> -};
> -
>  static const char * const mem_cgroup_stat_names[] = {
>  	"cache",
>  	"rss",
> @@ -2307,7 +2292,7 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
>  }
>  
>  void mem_cgroup_update_page_stat(struct page *page,
> -				 enum mem_cgroup_page_stat_item idx, int val)
> +				 enum mem_cgroup_stat_index idx, int val)
>  {
>  	struct mem_cgroup *memcg;
>  	struct page_cgroup *pc = lookup_page_cgroup(page);
> @@ -2320,14 +2305,6 @@ void mem_cgroup_update_page_stat(struct page *page,
>  	if (unlikely(!memcg || !PageCgroupUsed(pc)))
>  		return;
>  
> -	switch (idx) {
> -	case MEMCG_NR_FILE_MAPPED:
> -		idx = MEM_CGROUP_STAT_FILE_MAPPED;
> -		break;
> -	default:
> -		BUG();
> -	}
> -
>  	this_cpu_add(memcg->stat->count[idx], val);
>  }
>  
> diff --git a/mm/rmap.c b/mm/rmap.c
> index cd356df..3a3e03e 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1114,7 +1114,7 @@ void page_add_file_rmap(struct page *page)
>  	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>  	if (atomic_inc_and_test(&page->_mapcount)) {
>  		__inc_zone_page_state(page, NR_FILE_MAPPED);
> -		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED);
> +		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
>  	}
>  	mem_cgroup_end_update_page_stat(page, &locked, &flags);
>  }
> @@ -1158,7 +1158,7 @@ void page_remove_rmap(struct page *page)
>  					      NR_ANON_TRANSPARENT_HUGEPAGES);
>  	} else {
>  		__dec_zone_page_state(page, NR_FILE_MAPPED);
> -		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
> +		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
>  		mem_cgroup_end_update_page_stat(page, &locked, &flags);
>  	}
>  	if (unlikely(PageMlocked(page)))
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
