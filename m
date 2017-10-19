Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4976B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:12:55 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y39so3691747wrd.17
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 02:12:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k10si11175393wre.505.2017.10.19.02.12.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 02:12:54 -0700 (PDT)
Subject: Re: [PATCH 4/8] mm: Only drain per-cpu pagevecs once per pagevec
 usage
References: <20171018075952.10627-1-mgorman@techsingularity.net>
 <20171018075952.10627-5-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a9f2fc7c-906d-a49e-8e8f-d1024dc754ac@suse.cz>
Date: Thu, 19 Oct 2017 11:12:52 +0200
MIME-Version: 1.0
In-Reply-To: <20171018075952.10627-5-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On 10/18/2017 09:59 AM, Mel Gorman wrote:
> When a pagevec is initialised on the stack, it is generally used multiple
> times over a range of pages, looking up entries and then releasing them.
> On each pagevec_release, the per-cpu deferred LRU pagevecs are drained
> on the grounds the page being released may be on those queues and the
> pages may be cache hot. In many cases only the first drain is necessary
> as it's unlikely that the range of pages being walked is racing against
> LRU addition.  Even if there is such a race, the impact is marginal where
> as constantly redraining the lru pagevecs costs.

Right, the drain is only to a local cpu, not all of them, so that kind
of "racing" shouldn't be even possible.

> This patch ensures that pagevec is only drained once in a given lifecycle
> without increasing the cache footprint of the pagevec structure. Only

Well, strictly speaking it does prevent decreasing the cache footprint
by removing the 'cold' field later :)

> sparsetruncate tiny is shown here as large files have many exceptional
> entries and calls pagecache_release less frequently.
> 
> sparsetruncate (tiny)
>                               4.14.0-rc4             4.14.0-rc4
>                         batchshadow-v1r1          onedrain-v1r1
> Min          Time      141.00 (   0.00%)      141.00 (   0.00%)
> 1st-qrtle    Time      142.00 (   0.00%)      142.00 (   0.00%)
> 2nd-qrtle    Time      142.00 (   0.00%)      142.00 (   0.00%)
> 3rd-qrtle    Time      143.00 (   0.00%)      143.00 (   0.00%)
> Max-90%      Time      144.00 (   0.00%)      144.00 (   0.00%)
> Max-95%      Time      146.00 (   0.00%)      145.00 (   0.68%)
> Max-99%      Time      198.00 (   0.00%)      194.00 (   2.02%)
> Max          Time      254.00 (   0.00%)      208.00 (  18.11%)
> Amean        Time      145.12 (   0.00%)      144.30 (   0.56%)
> Stddev       Time       12.74 (   0.00%)        9.62 (  24.49%)
> Coeff        Time        8.78 (   0.00%)        6.67 (  24.06%)
> Best99%Amean Time      144.29 (   0.00%)      143.82 (   0.32%)
> Best95%Amean Time      142.68 (   0.00%)      142.31 (   0.26%)
> Best90%Amean Time      142.52 (   0.00%)      142.19 (   0.24%)
> Best75%Amean Time      142.26 (   0.00%)      141.98 (   0.20%)
> Best50%Amean Time      141.90 (   0.00%)      141.71 (   0.13%)
> Best25%Amean Time      141.80 (   0.00%)      141.43 (   0.26%)
> 
> The impact on bonnie is marginal and within the noise because a significant
> percentage of the file being truncated has been reclaimed and consists of
> shadow entries which reduce the hotness of the pagevec_release path.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  include/linux/pagevec.h | 4 +++-
>  mm/swap.c               | 5 ++++-
>  2 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
> index 4dcd5506f1ed..4231979be982 100644
> --- a/include/linux/pagevec.h
> +++ b/include/linux/pagevec.h
> @@ -16,7 +16,8 @@ struct address_space;
>  
>  struct pagevec {
>  	unsigned long nr;
> -	unsigned long cold;
> +	bool cold;
> +	bool drained;

'drained' sounds a bit misleading to me, I would expect it to refer to
*this* pagevec. What about e.g. "lru_drained"?

Thanks

>  	struct page *pages[PAGEVEC_SIZE];
>  };
>  
> @@ -45,6 +46,7 @@ static inline void pagevec_init(struct pagevec *pvec, int cold)
>  {
>  	pvec->nr = 0;
>  	pvec->cold = cold;
> +	pvec->drained = false;
>  }
>  
>  static inline void pagevec_reinit(struct pagevec *pvec)
> diff --git a/mm/swap.c b/mm/swap.c
> index a77d68f2c1b6..31bd9d8a5db7 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -833,7 +833,10 @@ EXPORT_SYMBOL(release_pages);
>   */
>  void __pagevec_release(struct pagevec *pvec)
>  {
> -	lru_add_drain();
> +	if (!pvec->drained) {
> +		lru_add_drain();
> +		pvec->drained = true;
> +	}
>  	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
>  	pagevec_reinit(pvec);
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
