Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 99B0E6B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 08:56:11 -0400 (EDT)
Date: Wed, 4 Jul 2012 14:56:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/7] memcg: remove MEMCG_NR_FILE_MAPPED
Message-ID: <20120704125608.GF29842@tiehlicka.suse.cz>
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com>
 <1340881111-5576-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340881111-5576-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Thu 28-06-12 18:58:31, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> While accounting memcg page stat, it's not worth to use MEMCG_NR_FILE_MAPPED
> as an extra layer of indirection because of the complexity and presumed
> performance overhead. We can use MEM_CGROUP_STAT_FILE_MAPPED directly.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/memcontrol.h |   25 +++++++++++++++++--------
>  mm/memcontrol.c            |   24 +-----------------------
>  mm/rmap.c                  |    4 ++--
>  3 files changed, 20 insertions(+), 33 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 83e7ba9..20b0f2d 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -27,9 +27,18 @@ struct page_cgroup;
>  struct page;
>  struct mm_struct;
>  
> -/* Stats that can be updated by kernel. */
> -enum mem_cgroup_page_stat_item {
> -	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
> +/*
> + * Statistics for memory cgroup.
> + */
> +enum mem_cgroup_stat_index {
> +	/*
> +	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> +	 */
> +	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> +	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> +	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> +	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
> +	MEM_CGROUP_STAT_NSTATS,
>  };
>  
>  struct mem_cgroup_reclaim_cookie {
> @@ -164,17 +173,17 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
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
> @@ -349,12 +358,12 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
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
> index a2677e0..ebed1ca 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -77,20 +77,6 @@ static int really_do_swap_account __initdata = 0;
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
> -	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> -	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> -	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> -	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
> -	MEM_CGROUP_STAT_NSTATS,
> -};
> -
>  static const char * const mem_cgroup_stat_names[] = {
>  	"cache",
>  	"rss",
> @@ -1926,7 +1912,7 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
>  }
>  
>  void mem_cgroup_update_page_stat(struct page *page,
> -				 enum mem_cgroup_page_stat_item idx, int val)
> +				 enum mem_cgroup_stat_index idx, int val)
>  {
>  	struct mem_cgroup *memcg;
>  	struct page_cgroup *pc = lookup_page_cgroup(page);
> @@ -1939,14 +1925,6 @@ void mem_cgroup_update_page_stat(struct page *page,
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
> index 2144160..d6b93df 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1148,7 +1148,7 @@ void page_add_file_rmap(struct page *page)
>  	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>  	if (atomic_inc_and_test(&page->_mapcount)) {
>  		__inc_zone_page_state(page, NR_FILE_MAPPED);
> -		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED);
> +		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
>  	}
>  	mem_cgroup_end_update_page_stat(page, &locked, &flags);
>  }
> @@ -1202,7 +1202,7 @@ void page_remove_rmap(struct page *page)
>  					      NR_ANON_TRANSPARENT_HUGEPAGES);
>  	} else {
>  		__dec_zone_page_state(page, NR_FILE_MAPPED);
> -		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
> +		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
>  	}
>  	/*
>  	 * It would be tidy to reset the PageAnon mapping here,
> -- 
> 1.7.1
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
