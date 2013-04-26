Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 2407A6B0002
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 07:17:43 -0400 (EDT)
Date: Fri, 26 Apr 2013 13:17:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add anon_hugepage stat
Message-ID: <20130426111739.GF31157@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1304251440190.27228@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1304251440190.27228@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Thu 25-04-13 14:41:17, David Rientjes wrote:
> This exports the amount of anonymous transparent hugepages for each memcg
> via memory.stat in bytes.
> 
> This is helpful to determine the hugepage utilization for individual jobs
> on the system in comparison to rss and opportunities where MADV_HUGEPAGE
> may be helpful.

Yes, useful and I had it on my todo list for quite some time. Never got
to it though. Thanks!

> Signed-off-by: David Rientjes <rientjes@google.com>

After documentation is update as poited out by Andrew.
Acked-by: Michal Hocko <mhocko@suse.cz>

One minor nit bellow:
> ---
>  include/linux/memcontrol.h |  3 ++-
>  mm/huge_memory.c           |  2 ++
>  mm/memcontrol.c            | 13 +++++++++----
>  mm/rmap.c                  | 18 +++++++++++++++---
>  4 files changed, 28 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -32,7 +32,8 @@ struct kmem_cache;
>  
>  /* Stats that can be updated by kernel. */
>  enum mem_cgroup_page_stat_item {
> -	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
> +	MEMCG_NR_FILE_MAPPED,	/* # of pages charged as file rss */
> +	MEMCG_NR_ANON_HUGEPAGE,	/* # of anon transparent hugepages */

This is confusing because it would suggest that hpages is the unit but
you are accounting in regular pages as a unit.

>  };
>  
>  struct mem_cgroup_reclaim_cookie {
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1651,6 +1651,8 @@ static void __split_huge_page_refcount(struct page *page)
>  	atomic_sub(tail_count, &page->_count);
>  	BUG_ON(atomic_read(&page->_count) <= 0);
>  
> +	mem_cgroup_update_page_stat(page, MEMCG_NR_ANON_HUGEPAGE,
> +				    -HPAGE_PMD_NR);
				^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

>  	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
>  	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -91,10 +91,11 @@ enum mem_cgroup_stat_index {
>  	/*
>  	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
>  	 */
> -	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> -	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> -	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> -	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
> +	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
> +	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
> +	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
> +	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
> +	MEM_CGROUP_STAT_ANON_HUGEPAGE,	/* # of anon transparent hugepages */

Same here.

>  	MEM_CGROUP_STAT_NSTATS,
>  };
>  
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
