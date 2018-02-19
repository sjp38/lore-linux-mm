Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 60CA36B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 03:26:51 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x77so4179589wmd.0
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 00:26:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v124si3562687wme.232.2018.02.19.00.26.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Feb 2018 00:26:50 -0800 (PST)
Date: Mon, 19 Feb 2018 09:26:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm, compaction: correct the bounds of
 __fragmentation_index()
Message-ID: <20180219082649.GD21134@dhcp22.suse.cz>
References: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
 <1518972475-11340-2-git-send-email-robert.m.harris@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1518972475-11340-2-git-send-email-robert.m.harris@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.m.harris@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Yafang Shao <laoar.shao@gmail.com>, Kangmin Park <l4stpr0gr4m@gmail.com>, Mel Gorman <mgorman@suse.de>, Yisheng Xie <xieyisheng1@huawei.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Vinayak Menon <vinmenon@codeaurora.org>

On Sun 18-02-18 16:47:55, robert.m.harris@oracle.com wrote:
> From: "Robert M. Harris" <robert.m.harris@oracle.com>
> 
> __fragmentation_index() calculates a value used to determine whether
> compaction should be favoured over page reclaim in the event of allocation
> failure.  The calculation itself is opaque and, on inspection, does not
> match its existing description.  The function purports to return a value
> between 0 and 1000, representing units of 1/1000.  Barring the case of a
> pathological shortfall of memory, the lower bound is instead 500.  This is
> significant because it is the default value of sysctl_extfrag_threshold,
> i.e. the value below which compaction should be avoided in favour of page
> reclaim for costly pages.
> 
> This patch implements and documents a modified version of the original
> expression that returns a value in the range 0 <= index < 1000.  It amends
> the default value of sysctl_extfrag_threshold to preserve the existing
> behaviour.

It is not really clear to me what is the actual problem you are trying
to solve by this patch. Is there any bug or are you just trying to
improve the current implementation to be more effective?

> Signed-off-by: Robert M. Harris <robert.m.harris@oracle.com>
> ---
>  Documentation/sysctl/vm.txt |  2 +-
>  mm/compaction.c             |  2 +-
>  mm/vmstat.c                 | 47 +++++++++++++++++++++++++++++++++++----------
>  3 files changed, 39 insertions(+), 12 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 5025ff9..384a78b 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -237,7 +237,7 @@ of memory, values towards 1000 imply failures are due to fragmentation and -1
>  implies that the allocation will succeed as long as watermarks are met.
>  
>  The kernel will not compact memory in a zone if the
> -fragmentation index is <= extfrag_threshold. The default value is 500.
> +fragmentation index is <= extfrag_threshold. The default value is 0.
>  
>  ==============================================================
>  
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 10cd757..9db6ef4 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1730,7 +1730,7 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
>  	return ret;
>  }
>  
> -int sysctl_extfrag_threshold = 500;
> +int sysctl_extfrag_threshold;
>  
>  /**
>   * try_to_compact_pages - Direct compact to satisfy a high-order allocation
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 40b2db6..013f1af 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1044,15 +1044,22 @@ static void fill_contig_page_info(struct zone *zone,
>  }
>  
>  /*
> - * A fragmentation index only makes sense if an allocation of a requested
> - * size would fail. If that is true, the fragmentation index indicates
> - * whether external fragmentation or a lack of memory was the problem.
> - * The value can be used to determine if page reclaim or compaction
> - * should be used
> + * If there is no block of at least the requested size, implying that an
> + * allocation would fail, then it might be possible to conjure one by
> + * compaction.  As this is expensive it is reserved for those cases in which
> + * there is a relatively high degree of fragmentation.  For low degrees, page
> + * reclaim is more appropriate since an allocation failure is more likely to be
> + * caused by a lack of memory.
> + *
> + * This function calculates an index in the range 0 to 1, expressed in units of
> + * 1/1000, indicating low and high fragmentation respectively.  The special
> + * value of -1 indicates that free blocks of sufficient size are available and
> + * that an allocation should therefore succeed.
>   */
>  static int __fragmentation_index(unsigned int order, struct contig_page_info *info)
>  {
>  	unsigned long requested = 1UL << order;
> +	int result;
>  
>  	if (WARN_ON_ONCE(order >= MAX_ORDER))
>  		return 0;
> @@ -1060,17 +1067,37 @@ static int __fragmentation_index(unsigned int order, struct contig_page_info *in
>  	if (!info->free_blocks_total)
>  		return 0;
>  
> -	/* Fragmentation index only makes sense when a request would fail */
>  	if (info->free_blocks_suitable)
>  		return -1000;
>  
>  	/*
> -	 * Index is between 0 and 1 so return within 3 decimal places
> +	 * If the number of requested-size blocks that could be constructed if
> +	 * all free blocks were compacted is
> +	 *
> +	 *	B = info->free_pages/requested
> +	 *
> +	 * then, conceptually, the number of fragments into which each
> +	 * requested-size block has been split is
> +	 *
> +	 *	N = info->free_blocks_total/B
>  	 *
> -	 * 0 => allocation would fail due to lack of memory
> -	 * 1 => allocation would fail due to fragmentation
> +	 * In the least and most fragmented cases all free memory resides on
> +	 * either the order - 1 free list or the base page free list
> +	 * respecively, thus the range of this function is given by
> +	 * 2 <= N <= requested.  The fragmentation index,
> +	 *
> +	 *	F = 1 - 2/N,
> +	 *
> +	 * has the more useful range of 0 < F <= 1.  In order to inhibit
> +	 * compaction in the event of a pathological shortfall of memory this
> +	 * function truncates and returns
> +	 *
> +	 *	F - 1/info->free_blocks_total
>  	 */
> -	return 1000 - div_u64( (1000+(div_u64(info->free_pages * 1000ULL, requested))), info->free_blocks_total);
> +	result = 1000 - div_u64((1000 + (div_u64(info->free_pages * 2000ULL,
> +			requested))), info->free_blocks_total);
> +
> +	return (result < 0) ? 0 : result;
>  }
>  
>  /* Same as __fragmentation index but allocs contig_page_info on stack */
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
