Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE086B0069
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 07:19:09 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t18so113532wmt.7
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 04:19:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o9si1960173wmo.50.2017.01.13.04.19.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 04:19:08 -0800 (PST)
Date: Fri, 13 Jan 2017 13:19:05 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: alloc_contig: re-allow CMA to compact FS pages
Message-ID: <20170113121905.GJ25212@dhcp22.suse.cz>
References: <20170113115155.24335-1-l.stach@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113115155.24335-1-l.stach@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

On Fri 13-01-17 12:51:55, Lucas Stach wrote:
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

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks for catching that.

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
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
