Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF6C56B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 04:45:59 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id c7so24238942wjb.7
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 01:45:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g10si4357333wrc.189.2017.02.07.01.45.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 01:45:58 -0800 (PST)
Date: Tue, 7 Feb 2017 10:45:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: return 0 in case this node has no page
 within the zone
Message-ID: <20170207094557.GE5065@dhcp22.suse.cz>
References: <20170206154314.15705-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170206154314.15705-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 06-02-17 23:43:14, Wei Yang wrote:
> The whole memory space is divided into several zones and nodes may have no
> page in some zones. In this case, the __absent_pages_in_range() would
> return 0, since the range it is searching for is an empty range.
> 
> Also this happens more often to those nodes with higher memory range when
> there are more nodes, which is a trend for future architectures.

I do not understand this part. Why would we see more zones with zero pfn
range in higher memory ranges.

> This patch checks the zone range after clamp and adjustment, return 0 if
> the range is an empty range.

I assume the whole point of this patch is to save
__absent_pages_in_range which iterates over all memblock regions, right?
Is there any reason why for_each_mem_pfn_range cannot be changed to
honor the given start/end pfns instead? I can imagine that a small zone
would see a similar pointless iterations...

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/page_alloc.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6de9440e3ae2..51c60c0eadcb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5521,6 +5521,11 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
>  	adjust_zone_range_for_zone_movable(nid, zone_type,
>  			node_start_pfn, node_end_pfn,
>  			&zone_start_pfn, &zone_end_pfn);
> +
> +	/* If this node has no page within this zone, return 0. */
> +	if (zone_start_pfn == zone_end_pfn)
> +		return 0;
> +
>  	nr_absent = __absent_pages_in_range(nid, zone_start_pfn, zone_end_pfn);
>  
>  	/*
> -- 
> 2.11.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
