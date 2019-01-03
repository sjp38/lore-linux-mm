Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 252A58E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 08:56:13 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c3so34073245eda.3
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 05:56:13 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p18si7954444edc.306.2019.01.03.05.56.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 05:56:11 -0800 (PST)
Date: Thu, 3 Jan 2019 14:56:09 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v3] mm: remove extra drain pages on pcp list
Message-ID: <20190103135609.GP31793@dhcp22.suse.cz>
References: <20181218204656.4297-1-richard.weiyang@gmail.com>
 <20181221170228.10686-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181221170228.10686-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de, david@redhat.com

On Sat 22-12-18 01:02:28, Wei Yang wrote:
> In current implementation, there are two places to isolate a range of
> page: __offline_pages() and alloc_contig_range(). During this procedure,
> it will drain pages on pcp list.
> 
> Below is a brief call flow:
> 
>   __offline_pages()/alloc_contig_range()
>       start_isolate_page_range()
>           set_migratetype_isolate()
>               drain_all_pages()
>       drain_all_pages()                 <--- A
> 
> >From this snippet we can see current logic is isolate and drain pcp list
> for each pageblock and drain pcp list again for the whole range.
> 
> While the drain at A is not necessary. The reason is
> start_isolate_page_range() will set the migrate type of a range to
> MIGRATE_ISOLATE. After doing so, this range will never be allocated from
> Buddy, neither to a real user nor to pcp list. This means the procedure
> to drain pages on pcp list after start_isolate_page_range() will not
> drain any page in the target range.

I am still not happy with the changelog. I would suggest the following
instead

"
start_isolate_page_range is responsible for isolating the given pfn
range. One part of that job is to make sure that also pages that are on
the allocator pcp lists are properly isolated. Otherwise they could be
reused and the range wouldn't be completely isolated until the memory is
freed back.  While there is no strict guarantee here because pages might
get allocated at any time before drain_all_pages is called there doesn't
seem to be any strong demand for such a guarantee.

In any case, draining is already done at the isolation level and there
is no need to do it again later by start_isolate_page_range callers
(memory hotplug and CMA allocator currently). Therefore remove pointless
draining in existing callers to make the code more clear and
functionally correct.
"
 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

With something like that, you can add
Acked-by: Michal Hocko <mhocko@suse.com>

> 
> ---
> v3:
>   * it is not proper to rely on caller to drain pages, so keep to drain
>     pages during iteration and remove the one in callers.
> v2: adjust changelog with MIGRATE_ISOLATE effects for the isolated range
> ---
>  mm/memory_hotplug.c | 1 -
>  mm/page_alloc.c     | 1 -
>  2 files changed, 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 6910e0eea074..d2fa6cbbb2db 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1599,7 +1599,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  
>  	cond_resched();
>  	lru_add_drain_all();
> -	drain_all_pages(zone);
>  
>  	pfn = scan_movable_pages(start_pfn, end_pfn);
>  	if (pfn) { /* We have movable pages */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f1edd36a1e2b..d9ee4bb3a1a7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8041,7 +8041,6 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  	 */
>  
>  	lru_add_drain_all();
> -	drain_all_pages(cc.zone);
>  
>  	order = 0;
>  	outer_start = start;
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
