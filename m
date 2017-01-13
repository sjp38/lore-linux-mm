Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 578BC6B025E
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 08:24:10 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r144so16028821wme.0
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 05:24:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u17si11220084wru.322.2017.01.13.05.24.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 05:24:09 -0800 (PST)
Subject: Re: [PATCH] mm: alloc_contig: re-allow CMA to compact FS pages
References: <20170113115155.24335-1-l.stach@pengutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b7c0b216-5777-ecb3-589a-24288c2eeec8@suse.cz>
Date: Fri, 13 Jan 2017 14:24:00 +0100
MIME-Version: 1.0
In-Reply-To: <20170113115155.24335-1-l.stach@pengutronix.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.deJoonsoo Kim <iamjoonsoo.kim@lge.com>

On 01/13/2017 12:51 PM, Lucas Stach wrote:
> Commit 73e64c51afc5 (mm, compaction: allow compaction for GFP_NOFS requests)
> changed compation to skip FS pages if not explicitly allowed to touch them,
> but missed to update the CMA compact_control.
>
> This leads to a very high isolation failure rate, crippling performance of
> CMA even on a lightly loaded system. Re-allow CMA to compact FS pages by
> setting the correct GFP flags, restoring CMA behavior and performance to
> the kernel 4.9 level.
>
> Fixes: 73e64c51afc5 (mm, compaction: allow compaction for GFP_NOFS requests)
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

It's true that this restores the behavior for CMA to 4.9. But it also reveals 
that CMA always implicitly assumed to be called from non-fs context. That's 
expectable for the original CMA use-case of drivers for devices such as cameras, 
but I now wonder if there's danger when CMA gets invoked via dma-cma layer with 
generic cma range for e.g. a disk device... I guess that would be another 
argument for scoped GFP_NOFS, which should then be applied to adjust the 
gfp_mask here. Or we could apply at least memalloc_noio_flags() right now, which 
should already handle the disk device -> dma -> cma scenario?

> ---
>  mm/page_alloc.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8d5d82c8a85a..eced9fee582b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7255,6 +7255,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  		.zone = page_zone(pfn_to_page(start)),
>  		.mode = MIGRATE_SYNC,
>  		.ignore_skip_hint = true,
> +		.gfp_mask = GFP_KERNEL,
>  	};
>  	INIT_LIST_HEAD(&cc.migratepages);
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
