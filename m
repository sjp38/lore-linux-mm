Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DE43D6B0003
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 13:47:55 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id m3so5391012pgd.20
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 10:47:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b1-v6si9859321pld.281.2018.01.29.10.47.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 10:47:54 -0800 (PST)
Date: Mon, 29 Jan 2018 19:47:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/1] mm: page_alloc: skip over regions of invalid pfns
 on UMA
Message-ID: <20180129184746.GK21609@dhcp22.suse.cz>
References: <20180124143545.31963-1-erosca@de.adit-jv.com>
 <20180124143545.31963-2-erosca@de.adit-jv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180124143545.31963-2-erosca@de.adit-jv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugeniu Rosca <erosca@de.adit-jv.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 24-01-18 15:35:45, Eugeniu Rosca wrote:
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 76c9688b6a0a..4a3d5936a9a0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5344,14 +5344,12 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  			goto not_early;
>  
>  		if (!early_pfn_valid(pfn)) {
> -#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  			/*
>  			 * Skip to the pfn preceding the next valid one (or
>  			 * end_pfn), such that we hit a valid pfn (or end_pfn)
>  			 * on our next iteration of the loop.
>  			 */
>  			pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
> -#endif
>  			continue;

Wouldn't it be just simpler to have ifdef CONFIG_HAVE_MEMBLOCK rather
than define memblock_next_valid_pfn for !HAVE_MEMBLOCK and then do the
(pfn + 1 ) - 1 games. I am usually against ifdefs in the code but that
would require a larger surgery to memmap_init_zone.

To be completely honest, I would like to see HAVE_MEMBLOCK_NODE_MAP
gone.

Other than that, the patch looks sane to me.

>  		}
>  		if (!early_pfn_in_nid(pfn, nid))
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
