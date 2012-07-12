Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 5C84A6B004D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 22:26:21 -0400 (EDT)
Date: Thu, 12 Jul 2012 11:26:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm v3] mm: have order > 0 compaction start off where it
 left
Message-ID: <20120712022622.GA27120@bbox>
References: <4FECCB89.2050400@redhat.com>
 <20120628143546.d02d13f9.akpm@linux-foundation.org>
 <1341250950.16969.6.camel@lappy>
 <4FF2435F.2070302@redhat.com>
 <20120703101024.GG13141@csn.ul.ie>
 <20120703144808.4daa4244.akpm@linux-foundation.org>
 <4FF3ABA1.3070808@kernel.org>
 <20120704004219.47d0508d.akpm@linux-foundation.org>
 <4FF3F864.3000204@kernel.org>
 <20120711161800.763dbef0@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120711161800.763dbef0@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Sasha Levin <levinsasha928@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaschut@sandia.gov, kamezawa.hiroyu@jp.fujitsu.com, Dave Jones <davej@redhat.com>

Hi Rik,

On Wed, Jul 11, 2012 at 04:18:00PM -0400, Rik van Riel wrote:
> This patch makes the comment for cc->wrapped longer, explaining
> what is really going on. It also incorporates the comment fix
> pointed out by Minchan.
> 
> Additionally, Minchan found that, when no pages get isolated,
> high_pte could be a value that is much lower than desired,

s/high_pte/high_pfn

> which might potentially cause compaction to skip a range of
> pages.
> 
> Only assign zone->compact_cache_free_pfn if we actually
> isolated free pages for compaction.
> 
> Split out the calculation to get the start of the last page
> block in a zone into its own, commented function.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Minchan Kim <minchan@kernel.org>

> ---
>  include/linux/mmzone.h |    2 +-
>  mm/compaction.c        |   30 ++++++++++++++++++++++--------
>  mm/internal.h          |    6 +++++-
>  3 files changed, 28 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index e629594..e957fa1 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -370,7 +370,7 @@ struct zone {
>  	spinlock_t		lock;
>  	int                     all_unreclaimable; /* All pages pinned */
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> -	/* pfn where the last order > 0 compaction isolated free pages */
> +	/* pfn where the last incremental compaction isolated free pages */
>  	unsigned long		compact_cached_free_pfn;
>  #endif
>  #ifdef CONFIG_MEMORY_HOTPLUG
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 2668b77..3812c3e 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -472,10 +472,11 @@ static void isolate_freepages(struct zone *zone,
>  		 * looking for free pages, the search will restart here as
>  		 * page migration may have returned some pages to the allocator
>  		 */
> -		if (isolated)
> +		if (isolated) {
>  			high_pfn = max(high_pfn, pfn);
> -		if (cc->order > 0)
> -			zone->compact_cached_free_pfn = high_pfn;
> +			if (cc->order > 0)
> +				zone->compact_cached_free_pfn = high_pfn;
> +		}
>  	}
>  
>  	/* split_free_page does not map the pages */
> @@ -569,6 +570,21 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	return ISOLATE_SUCCESS;
>  }
>  
> +/*
> + * Returns the start pfn of the laste page block in a zone.

s/laste/last/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
