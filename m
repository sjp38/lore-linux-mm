Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id F24C28E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 06:34:17 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id f2so27286qtg.14
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 03:34:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j16si15978589qvp.114.2019.01.07.03.34.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 03:34:16 -0800 (PST)
Subject: Re: [PATCH v4] mm: remove extra drain pages on pcp list
References: <20181221170228.10686-1-richard.weiyang@gmail.com>
 <20190105233141.2329-1-richard.weiyang@gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <f9391cab-38a6-bd61-9bb8-93c33861d968@redhat.com>
Date: Mon, 7 Jan 2019 12:34:13 +0100
MIME-Version: 1.0
In-Reply-To: <20190105233141.2329-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de

On 06.01.19 00:31, Wei Yang wrote:
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
> From this snippet we can see current logic is isolate and drain pcp list
> for each pageblock and drain pcp list again for the whole range.
> 
> start_isolate_page_range is responsible for isolating the given pfn
> range. One part of that job is to make sure that also pages that are on
> the allocator pcp lists are properly isolated. Otherwise they could be
> reused and the range wouldn't be completely isolated until the memory is
> freed back.  While there is no strict guarantee here because pages might
> get allocated at any time before drain_all_pages is called there doesn't
> seem to be any strong demand for such a guarantee.
> 
> In any case, draining is already done at the isolation level and there
> is no need to do it again later by start_isolate_page_range callers
> (memory hotplug and CMA allocator currently). Therefore remove pointless
> draining in existing callers to make the code more clear and
> functionally correct.
> 
> [mhocko@suse.com: provide a clearer changelog for the last two paragraph]
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: David Hildenbrand <david@redhat.com>

> 
> ---
> v4:
>   * adjust last two paragraph changelog from Michal's comment
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
> 


-- 

Thanks,

David / dhildenb
