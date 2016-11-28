Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC6366B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:54:35 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xr1so22551986wjb.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:54:35 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 185si27313712wmr.36.2016.11.28.11.54.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:54:34 -0800 (PST)
Date: Mon, 28 Nov 2016 14:54:21 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
Message-ID: <20161128195421.GA22236@cmpxchg.org>
References: <20161127131954.10026-1-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161127131954.10026-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Sun, Nov 27, 2016 at 01:19:54PM +0000, Mel Gorman wrote:
> While it is recognised that this is a mixed bag of results, the patch
> helps a lot more workloads than it hurts and intuitively, avoiding the
> zone->lock in some cases is a good thing.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

This seems like a net gain to me, and the patch loos good too.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> @@ -255,6 +255,24 @@ enum zone_watermarks {
>  	NR_WMARK
>  };
>  
> +/*
> + * One per migratetype for order-0 pages and one per high-order up to
> + * and including PAGE_ALLOC_COSTLY_ORDER. This may allow unmovable
> + * allocations to contaminate reclaimable pageblocks if high-order
> + * pages are heavily used.

I think that should be fine. Higher order allocations rely on being
able to compact movable blocks, not on reclaim freeing contiguous
blocks, so poisoning reclaimable blocks is much less of a concern than
poisoning movable blocks. And I'm not aware of any 0 < order < COSTLY
movable allocations that would put movable blocks into an HO cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
