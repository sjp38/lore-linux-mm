Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6666B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 03:12:34 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u63so1571037wmu.0
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 00:12:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t131si1119133wmf.99.2017.02.22.00.12.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 00:12:33 -0800 (PST)
Date: Wed, 22 Feb 2017 09:12:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: provide shmem statistics
Message-ID: <20170222081230.GC5753@dhcp22.suse.cz>
References: <20170221164343.32252-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170221164343.32252-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Chris Down <cdown@fb.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 21-02-17 11:43:43, Johannes Weiner wrote:
> Cgroups currently don't report how much shmem they use, which can be
> useful data to have, in particular since shmem is included in the
> cache/file item while being reclaimed like anonymous memory.
> 
> Add a counter to track shmem pages during charging and uncharging.

Yes this is indeed useful. Accounting shmem to the page cache was a
mistake because this is more than confusing. Sad we cannot fix that.
I would have just one concern with this patch. You are relying on
PageSwapBacked check but it looks like we are going to implement
MADV_FREE by dropping this flag. I know we do not support MADV_FREE
on shared mappings but if we ever do then the accounting will become
subtly broken. Can/Should we rely on shmem_mapping() check instead?

Other than that the patch looks good to me.

> Reported-by: Chris Down <cdown@fb.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  Documentation/cgroup-v2.txt |  5 +++++
>  include/linux/memcontrol.h  |  1 +
>  mm/memcontrol.c             | 28 ++++++++++++++++++++--------
>  3 files changed, 26 insertions(+), 8 deletions(-)
> 
> diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> index 4cc07ce3b8dd..d99389ce7b01 100644
> --- a/Documentation/cgroup-v2.txt
> +++ b/Documentation/cgroup-v2.txt
> @@ -867,6 +867,11 @@ PAGE_SIZE multiple when read back.
>  
>  		Amount of memory used in network transmission buffers
>  
> +	  shmem
> +
> +		Amount of cached filesystem data that is swap-backed,
> +		such as tmpfs, shm segments, shared anonymous mmap()s
> +
>  	  file_mapped
>  
>  		Amount of cached filesystem data mapped with mmap()
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 61d20c17f3b7..47bdf727d1ad 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -46,6 +46,7 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
>  	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
>  	MEM_CGROUP_STAT_RSS_HUGE,	/* # of pages charged as anon huge */
> +	MEM_CGROUP_STAT_SHMEM,		/* # of pages charged as shmem */
>  	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
>  	MEM_CGROUP_STAT_DIRTY,          /* # of dirty pages in page cache */
>  	MEM_CGROUP_STAT_WRITEBACK,	/* # of pages under writeback */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9c9cde768d40..49409f5c0238 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -102,6 +102,7 @@ static const char * const mem_cgroup_stat_names[] = {
>  	"cache",
>  	"rss",
>  	"rss_huge",
> +	"shmem",
>  	"mapped_file",
>  	"dirty",
>  	"writeback",
> @@ -601,9 +602,13 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
>  	if (PageAnon(page))
>  		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS],
>  				nr_pages);
> -	else
> +	else {
>  		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
>  				nr_pages);
> +		if (PageSwapBacked(page))
> +			__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SHMEM],
> +				       nr_pages);
> +	}
>  
>  	if (compound) {
>  		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> @@ -5200,6 +5205,8 @@ static int memory_stat_show(struct seq_file *m, void *v)
>  	seq_printf(m, "sock %llu\n",
>  		   (u64)stat[MEMCG_SOCK] * PAGE_SIZE);
>  
> +	seq_printf(m, "shmem %llu\n",
> +		   (u64)stat[MEM_CGROUP_STAT_SHMEM] * PAGE_SIZE);
>  	seq_printf(m, "file_mapped %llu\n",
>  		   (u64)stat[MEM_CGROUP_STAT_FILE_MAPPED] * PAGE_SIZE);
>  	seq_printf(m, "file_dirty %llu\n",
> @@ -5468,8 +5475,8 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
>  
>  static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
>  			   unsigned long nr_anon, unsigned long nr_file,
> -			   unsigned long nr_huge, unsigned long nr_kmem,
> -			   struct page *dummy_page)
> +			   unsigned long nr_kmem, unsigned long nr_huge,
> +			   unsigned long nr_shmem, struct page *dummy_page)
>  {
>  	unsigned long nr_pages = nr_anon + nr_file + nr_kmem;
>  	unsigned long flags;
> @@ -5487,6 +5494,7 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
>  	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS], nr_anon);
>  	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_CACHE], nr_file);
>  	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE], nr_huge);
> +	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_SHMEM], nr_shmem);
>  	__this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT], pgpgout);
>  	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
>  	memcg_check_events(memcg, dummy_page);
> @@ -5499,6 +5507,7 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
>  static void uncharge_list(struct list_head *page_list)
>  {
>  	struct mem_cgroup *memcg = NULL;
> +	unsigned long nr_shmem = 0;
>  	unsigned long nr_anon = 0;
>  	unsigned long nr_file = 0;
>  	unsigned long nr_huge = 0;
> @@ -5531,9 +5540,9 @@ static void uncharge_list(struct list_head *page_list)
>  		if (memcg != page->mem_cgroup) {
>  			if (memcg) {
>  				uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
> -					       nr_huge, nr_kmem, page);
> -				pgpgout = nr_anon = nr_file =
> -					nr_huge = nr_kmem = 0;
> +					       nr_kmem, nr_huge, nr_shmem, page);
> +				pgpgout = nr_anon = nr_file = nr_kmem = 0;
> +				nr_huge = nr_shmem = 0;
>  			}
>  			memcg = page->mem_cgroup;
>  		}
> @@ -5547,8 +5556,11 @@ static void uncharge_list(struct list_head *page_list)
>  			}
>  			if (PageAnon(page))
>  				nr_anon += nr_pages;
> -			else
> +			else {
>  				nr_file += nr_pages;
> +				if (PageSwapBacked(page))
> +					nr_shmem += nr_pages;
> +			}
>  			pgpgout++;
>  		} else {
>  			nr_kmem += 1 << compound_order(page);
> @@ -5560,7 +5572,7 @@ static void uncharge_list(struct list_head *page_list)
>  
>  	if (memcg)
>  		uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
> -			       nr_huge, nr_kmem, page);
> +			       nr_kmem, nr_huge, nr_shmem, page);
>  }
>  
>  /**
> -- 
> 2.11.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
