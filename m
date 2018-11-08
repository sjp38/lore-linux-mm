Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2746B0590
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 02:16:54 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id b11-v6so12643960oii.19
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 23:16:54 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j188-v6si1326941oib.106.2018.11.07.23.16.52
        for <linux-mm@kvack.org>;
        Wed, 07 Nov 2018 23:16:53 -0800 (PST)
Subject: Re: [RFC PATCH 5/5] mm, memory_hotplug: be more verbose for memory
 offline failures
References: <20181107101830.17405-1-mhocko@kernel.org>
 <20181107101830.17405-6-mhocko@kernel.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <b23ebcb3-e4f1-be78-bd5f-84c685979ab7@arm.com>
Date: Thu, 8 Nov 2018 12:46:47 +0530
MIME-Version: 1.0
In-Reply-To: <20181107101830.17405-6-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



On 11/07/2018 03:48 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> There is only very limited information printed when the memory offlining
> fails:
> [ 1984.506184] rac1 kernel: memory offlining [mem 0x82600000000-0x8267fffffff] failed due to signal backoff
> 
> This tells us that the failure is triggered by the userspace
> intervention but it doesn't tell us much more about the underlying
> reason. It might be that the page migration failes repeatedly and the
> userspace timeout expires and send a signal or it might be some of the
> earlier steps (isolation, memory notifier) takes too long.
> 
> If the migration failes then it would be really helpful to see which
> page that and its state. The same applies to the isolation phase. If we
> fail to isolate a page from the allocator then knowing the state of the
> page would be helpful as well.
> 
> Dump the page state that fails to get isolated or migrated. This will
> tell us more about the failure and what to focus on during debugging.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memory_hotplug.c | 12 ++++++++----
>  mm/page_alloc.c     |  1 +
>  2 files changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 1badac89c58e..bf214beccda3 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1388,10 +1388,8 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  						    page_is_file_cache(page));
>  
>  		} else {
> -#ifdef CONFIG_DEBUG_VM
> -			pr_alert("failed to isolate pfn %lx\n", pfn);
> +			pr_warn("failed to isolate pfn %lx\n", pfn)>  			dump_page(page, "isolation failed");
> -#endif
>  			put_page(page);
>  			/* Because we don't have big zone->lock. we should
>  			   check this again here. */
> @@ -1411,8 +1409,14 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  		/* Allocate a new page from the nearest neighbor node */
>  		ret = migrate_pages(&source, new_node_page, NULL, 0,
>  					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
> -		if (ret)
> +		if (ret) {
> +			list_for_each_entry(page, &source, lru) {
> +				pr_warn("migrating pfn %lx failed ",
> +				       page_to_pfn(page), ret);

Seems like pr_warn() needs to have %d in here to print 'ret'. Though
dumping return code from migrate_pages() makes sense, wondering if
it is required for each and every page which failed to migrate here
or just one instance is enough.

> +				dump_page(page, NULL);
> +			}

s/NULL/failed to migrate/ for dump_page().

>  			putback_movable_pages(&source);
> +		}
>  	}
>  out:
>  	return ret;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a919ba5cb3c8..23267767bf98 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7845,6 +7845,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	return false;
>  unmovable:
>  	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
> +	dump_page(pfn_to_page(pfn+iter), "has_unmovable_pages");

s/has_unmovable_pages/is unmovable/

If we eally care about the function name, then dump_page() should be
followed by dump_stack() like the case in some other instances.

>  	return true;

This will be dumped from HugeTLB and CMA allocation paths as well through
alloc_contig_range(). But it should be okay as those occurrences should be
rare and dumping page state then will also help.
