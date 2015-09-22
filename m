Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7A30E6B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 05:03:15 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so182346968wic.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:03:15 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id wc12si23025481wic.115.2015.09.22.02.03.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 02:03:14 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so149798614wic.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:03:13 -0700 (PDT)
Date: Tue, 22 Sep 2015 11:03:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 4.3-rc1 dirty page count underflow (cgroup-related?)
Message-ID: <20150922090311.GB25888@dhcp22.suse.cz>
References: <55FC24C2.8020501@intel.com>
 <xr93pp1cmc0t.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93pp1cmc0t.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)" <cgroups@vger.kernel.org>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>

[I am sorry I didn't get to this earlier because I was at an internal
conference last week]

On Mon 21-09-15 01:06:58, Greg Thelen wrote:
[...]
> >From f5c39c2e8471c10fe0464ca7b6e6f743ce6920a6 Mon Sep 17 00:00:00 2001
> From: Greg Thelen <gthelen@google.com>
> Date: Sat, 19 Sep 2015 16:21:18 -0700
> Subject: [PATCH] memcg: fix dirty page migration
> 
> The problem starts with a file backed dirty page which is charged to a
> memcg.  Then page migration is used to move oldpage to newpage.
> Migration:
> - copies the oldpage's data to newpage
> - clears oldpage.PG_dirty
> - sets newpage.PG_dirty
> - uncharges oldpage from memcg
> - charges newpage to memcg
> 
> Clearing oldpage.PG_dirty decrements the charged memcg's dirty page
> count.  However, because newpage is not yet charged, setting
> newpage.PG_dirty does not increment the memcg's dirty page count.  After
> migration completes newpage.PG_dirty is eventually cleared, often in
> account_page_cleaned().  At this time newpage is charged to a memcg so
> the memcg's dirty page count is decremented which causes underflow
> because the count was not previously incremented by migration.  This
> underflow causes balance_dirty_pages() to see a very large unsigned
> number of dirty memcg pages which leads to aggressive throttling of
> buffered writes by processes in non root memcg.

Very well spotted!

> This issue:
> - can harm performance of non root memcg buffered writes.
> - can report too small (even negative) values in
>   memory.stat[(total_)dirty] counters of all memcg, including the root.
> 
> To avoid polluting migrate.c with #ifdef CONFIG_MEMCG checks, introduce
> page_memcg() and set_page_memcg() helpers.
> 
> Test:
>     0) setup and enter limited memcg
>     mkdir /sys/fs/cgroup/test
>     echo 1G > /sys/fs/cgroup/test/memory.limit_in_bytes
>     echo $$ > /sys/fs/cgroup/test/cgroup.procs
> 
>     1) buffered writes baseline
>     dd if=/dev/zero of=/data/tmp/foo bs=1M count=1k
>     sync
>     grep ^dirty /sys/fs/cgroup/test/memory.stat
> 
>     2) buffered writes with compaction antagonist to induce migration
>     yes 1 > /proc/sys/vm/compact_memory &
>     rm -rf /data/tmp/foo
>     dd if=/dev/zero of=/data/tmp/foo bs=1M count=1k
>     kill %
>     sync
>     grep ^dirty /sys/fs/cgroup/test/memory.stat
> 
>     3) buffered writes without antagonist, should match baseline
>     rm -rf /data/tmp/foo
>     dd if=/dev/zero of=/data/tmp/foo bs=1M count=1k
>     sync
>     grep ^dirty /sys/fs/cgroup/test/memory.stat
> 
>                        (speed, dirty residue)
>              unpatched                       patched
>     1) 841 MB/s 0 dirty pages          886 MB/s 0 dirty pages
>     2) 611 MB/s -33427456 dirty pages  793 MB/s 0 dirty pages
>     3) 114 MB/s -33427456 dirty pages  891 MB/s 0 dirty pages
> 
>     Notice that unpatched baseline performance (1) fell after
>     migration (3): 841 -> 114 MB/s.  In the patched kernel, post
>     migration performance matches baseline.
> 
> Fixes: c4843a7593a9 ("memcg: add per cgroup dirty page accounting")
> Cc: <stable@vger.kernel.org> # 4.2+
> Reported-by: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  include/linux/mm.h | 21 +++++++++++++++++++++
>  mm/migrate.c       | 12 +++++++++++-
>  2 files changed, 32 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 91c08f6f0dc9..80001de019ba 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -905,6 +905,27 @@ static inline void set_page_links(struct page *page, enum zone_type zone,
>  #endif
>  }
>  
> +#ifdef CONFIG_MEMCG
> +static inline struct mem_cgroup *page_memcg(struct page *page)
> +{
> +	return page->mem_cgroup;
> +}
> +
> +static inline void set_page_memcg(struct page *page, struct mem_cgroup *memcg)
> +{
> +	page->mem_cgroup = memcg;
> +}
> +#else
> +static inline struct mem_cgroup *page_memcg(struct page *page)
> +{
> +	return NULL;
> +}
> +
> +static inline void set_page_memcg(struct page *page, struct mem_cgroup *memcg)
> +{
> +}
> +#endif
> +
>  /*
>   * Some inline functions in vmstat.h depend on page_zone()
>   */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index c3cb566af3e2..6116b8f64d27 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -740,6 +740,15 @@ static int move_to_new_page(struct page *newpage, struct page *page,
>  	if (PageSwapBacked(page))
>  		SetPageSwapBacked(newpage);
>  
> +	/*
> +	 * Indirectly called below, migrate_page_copy() copies PG_dirty and thus
> +	 * needs newpage's memcg set to transfer memcg dirty page accounting.
> +	 * So perform memcg migration in two steps:
> +	 * 1. set newpage->mem_cgroup (here)
> +	 * 2. clear page->mem_cgroup (below)
> +	 */
> +	set_page_memcg(newpage, page_memcg(page));
> +
>  	mapping = page_mapping(page);
>  	if (!mapping)
>  		rc = migrate_page(mapping, newpage, page, mode);
> @@ -756,9 +765,10 @@ static int move_to_new_page(struct page *newpage, struct page *page,
>  		rc = fallback_migrate_page(mapping, newpage, page, mode);
>  
>  	if (rc != MIGRATEPAGE_SUCCESS) {
> +		set_page_memcg(newpage, NULL);
>  		newpage->mapping = NULL;
>  	} else {
> -		mem_cgroup_migrate(page, newpage, false);
> +		set_page_memcg(page, NULL);
>  		if (page_was_mapped)
>  			remove_migration_ptes(page, newpage);
>  		page->mapping = NULL;
> -- 
> 2.6.0.rc0.131.gf624c3d

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
