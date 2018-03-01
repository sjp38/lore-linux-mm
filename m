Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id ED7466B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 08:10:38 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k62so2626534pgd.11
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 05:10:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 70-v6si3093972pla.64.2018.03.01.05.10.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Mar 2018 05:10:37 -0800 (PST)
Date: Thu, 1 Mar 2018 14:10:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: fix memmap_init_zone pageblock alignment
Message-ID: <20180301131033.GH15057@dhcp22.suse.cz>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1519908465-12328-1-git-send-email-neelx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, stable@vger.kernel.org

On Thu 01-03-18 13:47:45, Daniel Vacek wrote:
> In move_freepages() a BUG_ON() can be triggered on uninitialized page structures
> due to pageblock alignment. Aligning the skipped pfns in memmap_init_zone() the
> same way as in move_freepages_block() simply fixes those crashes.

This changelog doesn't describe how the fix works. Why doesn't
memblock_next_valid_pfn return the first valid pfn as one would expect?

It would be also good put the panic info in the changelog.

> Fixes: b92df1de5d28 ("[mm] page_alloc: skip over regions of invalid pfns where possible")
> Signed-off-by: Daniel Vacek <neelx@redhat.com>
> Cc: stable@vger.kernel.org
> ---
>  mm/page_alloc.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index cb416723538f..9edee36e6a74 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5359,9 +5359,14 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  			/*
>  			 * Skip to the pfn preceding the next valid one (or
>  			 * end_pfn), such that we hit a valid pfn (or end_pfn)
> -			 * on our next iteration of the loop.
> +			 * on our next iteration of the loop. Note that it needs
> +			 * to be pageblock aligned even when the region itself
> +			 * is not as move_freepages_block() can shift ahead of
> +			 * the valid region but still depends on correct page
> +			 * metadata.
>  			 */
> -			pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
> +			pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
> +						~(pageblock_nr_pages-1)) - 1;
>  #endif
>  			continue;
>  		}
> -- 
> 2.16.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
