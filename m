Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3023B6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 02:53:27 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a66so38135668wme.1
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 23:53:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x194si3872475wmf.38.2016.06.28.23.53.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Jun 2016 23:53:25 -0700 (PDT)
Subject: Re: [patch] mm, compaction: make sure freeing scanner isn't
 persistently expensive
References: <alpine.DEB.2.10.1606281839050.101842@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6685fe19-753d-7d76-aced-3bb071d7c81d@suse.cz>
Date: Wed, 29 Jun 2016 08:53:22 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1606281839050.101842@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/29/2016 03:39 AM, David Rientjes wrote:
> It's possible that the freeing scanner can be consistently expensive if
> memory is well compacted toward the end of the zone with few free pages
> available in that area.
>
> If all zone memory is synchronously compacted, say with
> /proc/sys/vm/compact_memory, and thp is faulted, it is possible to
> iterate a massive amount of memory even with the per-zone cached free
> position.
>
> For example, after compacting all memory and faulting thp for heap, it
> was observed that compact_free_scanned increased as much as 892518911 4KB
> pages while compact_stall only increased by 171.  The freeing scanner
> iterated ~20GB of memory for each compaction stall.
>
> To address this, if too much memory is spanned on the freeing scanner's
> freelist when releasing back to the system, return the low pfn rather than
> the high pfn.  It's declared that the freeing scanner will become too
> expensive if the high pfn is used, so use the low pfn instead.
>
> The amount of memory declared as too expensive to iterate is subjectively
> chosen at COMPACT_CLUSTER_MAX << PAGE_SHIFT, which is 512MB with 4KB
> pages.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Hmm, I don't know. Seems it only works around one corner case of a 
larger issue. The cost for the scanning was already paid, the patch 
prevents it from being paid again, but only until the scanners are reset.

Note also that THP's no longer do direct compaction by default in recent 
kernels.

To fully solve the freepage scanning issue, we should probably pick and 
finish one of the proposed reworks from Joonsoo or myself, or the 
approach that replaces free scanner with direct freelist allocations.

> ---
>  mm/compaction.c | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -47,10 +47,16 @@ static inline void count_compact_events(enum vm_event_item item, long delta)
>  #define pageblock_start_pfn(pfn)	block_start_pfn(pfn, pageblock_order)
>  #define pageblock_end_pfn(pfn)		block_end_pfn(pfn, pageblock_order)
>
> +/*
> + * Releases isolated free pages back to the buddy allocator.  Returns the pfn
> + * that should be cached for the next compaction of this zone, depending on how
> + * much memory the free pages span.
> + */
>  static unsigned long release_freepages(struct list_head *freelist)
>  {
>  	struct page *page, *next;
>  	unsigned long high_pfn = 0;
> +	unsigned long low_pfn = -1UL;
>
>  	list_for_each_entry_safe(page, next, freelist, lru) {
>  		unsigned long pfn = page_to_pfn(page);
> @@ -58,8 +64,18 @@ static unsigned long release_freepages(struct list_head *freelist)
>  		__free_page(page);
>  		if (pfn > high_pfn)
>  			high_pfn = pfn;
> +		if (pfn < low_pfn)
> +			low_pfn = pfn;
>  	}
>
> +	/*
> +	 * If the list of freepages spans too much memory, the cached position
> +	 * should be updated to the lowest pfn to prevent the freeing scanner
> +	 * from becoming too expensive.
> +	 */
> +	if ((high_pfn - low_pfn) > (COMPACT_CLUSTER_MAX << PAGE_SHIFT))
> +		return low_pfn;
> +
>  	return high_pfn;
>  }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
