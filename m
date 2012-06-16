Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 834556B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 02:33:29 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B19DE3EE0BD
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:33:27 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B85A45DE4E
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:33:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 75AA945DE4F
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:33:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 69EF21DB803E
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:33:27 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 10E3B1DB802F
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 15:33:27 +0900 (JST)
Message-ID: <4FDC2834.7010705@jp.fujitsu.com>
Date: Sat, 16 Jun 2012 15:31:16 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] memcg: remove MEMCG_NR_FILE_MAPPED
References: <1339761611-29033-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1339761611-29033-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

(2012/06/15 21:00), Sha Zhengju wrote:
> While doing memcg page stat accounting, there's no need to use MEMCG_NR_FILE_MAPPED
> as an intermediate, we can use MEM_CGROUP_STAT_FILE_MAPPED directly.
> 
> Signed-off-by: Sha Zhengju<handai.szj@taobao.com>

I'm sorry but my recent patch modified mem_cgroup_stat_index and this will hunk with
mm tree. (not visible in linux-next yet.)

I have no objection to the patch. I'm grad if you'll update this and repost, later.

Thanks,
-Kame


> ---
>   include/linux/memcontrol.h |   22 ++++++++++++++++------
>   mm/memcontrol.c            |   25 +------------------------
>   mm/rmap.c                  |    4 ++--
>   3 files changed, 19 insertions(+), 32 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index f94efd2..a337c2e 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -27,9 +27,19 @@ struct page_cgroup;
>   struct page;
>   struct mm_struct;
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
> +	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> +	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
> +	MEM_CGROUP_STAT_NSTATS,
>   };
> 
>   struct mem_cgroup_reclaim_cookie {
> @@ -170,17 +180,17 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
>   }
> 
>   void mem_cgroup_update_page_stat(struct page *page,
> -				 enum mem_cgroup_page_stat_item idx,
> +				 enum mem_cgroup_stat_index idx,
>   				 int val);
> 
>   static inline void mem_cgroup_inc_page_stat(struct page *page,
> -					    enum mem_cgroup_page_stat_item idx)
> +					    enum mem_cgroup_stat_index idx)
>   {
>   	mem_cgroup_update_page_stat(page, idx, 1);
>   }
> 
>   static inline void mem_cgroup_dec_page_stat(struct page *page,
> -					    enum mem_cgroup_page_stat_item idx)
> +					    enum mem_cgroup_stat_index idx)
>   {
>   	mem_cgroup_update_page_stat(page, idx, -1);
>   }
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7685d4a..9102b8c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -77,21 +77,6 @@ static int really_do_swap_account __initdata = 0;
>   #endif
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
> -	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> -	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
> -	MEM_CGROUP_STAT_NSTATS,
> -};
> -
>   enum mem_cgroup_events_index {
>   	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
>   	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
> @@ -1958,7 +1943,7 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
>   }
> 
>   void mem_cgroup_update_page_stat(struct page *page,
> -				 enum mem_cgroup_page_stat_item idx, int val)
> +				 enum mem_cgroup_stat_index idx, int val)
>   {
>   	struct mem_cgroup *memcg;
>   	struct page_cgroup *pc = lookup_page_cgroup(page);
> @@ -1971,14 +1956,6 @@ void mem_cgroup_update_page_stat(struct page *page,
>   	if (unlikely(!memcg || !PageCgroupUsed(pc)))
>   		return;
> 
> -	switch (idx) {
> -	case MEMCG_NR_FILE_MAPPED:
> -		idx = MEM_CGROUP_STAT_FILE_MAPPED;
> -		break;
> -	default:
> -		BUG();
> -	}
> -
>   	this_cpu_add(memcg->stat->count[idx], val);
>   }
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 5b5ad58..7e4e481 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1154,7 +1154,7 @@ void page_add_file_rmap(struct page *page)
>   	mem_cgroup_begin_update_page_stat(page,&locked,&flags);
>   	if (atomic_inc_and_test(&page->_mapcount)) {
>   		__inc_zone_page_state(page, NR_FILE_MAPPED);
> -		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED);
> +		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
>   	}
>   	mem_cgroup_end_update_page_stat(page,&locked,&flags);
>   }
> @@ -1208,7 +1208,7 @@ void page_remove_rmap(struct page *page)
>   					      NR_ANON_TRANSPARENT_HUGEPAGES);
>   	} else {
>   		__dec_zone_page_state(page, NR_FILE_MAPPED);
> -		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
> +		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
>   	}
>   	/*
>   	 * It would be tidy to reset the PageAnon mapping here,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
