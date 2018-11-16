Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9E16B096B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 07:07:51 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id e141so4151433oig.11
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 04:07:51 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u9si13097469otb.172.2018.11.16.04.07.50
        for <linux-mm@kvack.org>;
        Fri, 16 Nov 2018 04:07:50 -0800 (PST)
Subject: Re: [PATCH 5/5] mm, memory_hotplug: be more verbose for memory
 offline failures
References: <20181116083020.20260-1-mhocko@kernel.org>
 <20181116083020.20260-6-mhocko@kernel.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <68bb826c-104f-3c53-28fe-5e9a55df1d1e@arm.com>
Date: Fri, 16 Nov 2018 17:37:45 +0530
MIME-Version: 1.0
In-Reply-To: <20181116083020.20260-6-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



On 11/16/2018 02:00 PM, Michal Hocko wrote:
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
> index 88d50e74e3fe..c82193db4be6 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1388,10 +1388,8 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  						    page_is_file_cache(page));
>  
>  		} else {
> -#ifdef CONFIG_DEBUG_VM
> -			pr_alert("failed to isolate pfn %lx\n", pfn);
> +			pr_warn("failed to isolate pfn %lx\n", pfn);
>  			dump_page(page, "isolation failed");
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
> +				pr_warn("migrating pfn %lx failed ret:%d ",
> +				       page_to_pfn(page), ret);
> +				dump_page(page, "migration failure");
> +			}
>  			putback_movable_pages(&source);
> +		}
>  	}
>  out:
>  	return ret;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a919ba5cb3c8..ec2c7916dc2d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7845,6 +7845,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	return false;
>  unmovable:
>  	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
> +	dump_page(pfn_to_page(pfn+iter), "unmovable page");
>  	return true;
>  }

This seems to have fixed the previous build problem because of the migrate_pages()
return code. Otherwise looks good.

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
