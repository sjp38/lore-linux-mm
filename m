Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0EAB86B025F
	for <linux-mm@kvack.org>; Mon, 30 May 2016 01:43:58 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id f8so55872438pag.2
        for <linux-mm@kvack.org>; Sun, 29 May 2016 22:43:58 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id vb10si48335449pab.56.2016.05.29.22.43.56
        for <linux-mm@kvack.org>;
        Sun, 29 May 2016 22:43:56 -0700 (PDT)
Date: Mon, 30 May 2016 14:45:06 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 0/6] Introduce ZONE_CMA
Message-ID: <20160530054506.GB25079@js1304-P5Q-DELUXE>
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160526080454.GA11823@shbuild888>
 <20160527052820.GA13661@js1304-P5Q-DELUXE>
 <20160527062527.GA32297@shbuild888>
 <20160527064218.GA14858@js1304-P5Q-DELUXE>
 <20160527072702.GA7782@shbuild888>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160527072702.GA7782@shbuild888>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Feng Tang <feng.tang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rui Teng <rui.teng@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, May 27, 2016 at 03:27:02PM +0800, Feng Tang wrote:
> On Fri, May 27, 2016 at 02:42:18PM +0800, Joonsoo Kim wrote:
> > On Fri, May 27, 2016 at 02:25:27PM +0800, Feng Tang wrote:
> > > On Fri, May 27, 2016 at 01:28:20PM +0800, Joonsoo Kim wrote:
> > > > On Thu, May 26, 2016 at 04:04:54PM +0800, Feng Tang wrote:
> > > > > On Thu, May 26, 2016 at 02:22:22PM +0800, js1304@gmail.com wrote:
> > > > > > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > > > 
> > >  
> > > > > > FYI, there is another attempt [3] trying to solve this problem in lkml.
> > > > > > And, as far as I know, Qualcomm also has out-of-tree solution for this
> > > > > > problem.
> > > > > 
> > > > > This may be a little off-topic :) Actually, we have used another way in
> > > > > our products, that we disable the fallback from MIGRATETYE_MOVABLE to
> > > > > MIGRATETYPE_CMA completely, and only allow free CMA memory to be used
> > > > > by file page cache (which is easy to be reclaimed by its nature). 
> > > > > We did it by adding a GFP_PAGE_CACHE to every allocation request for
> > > > > page cache, and the MM will try to pick up an available free CMA page
> > > > > first, and goes to normal path when fail. 
> > > > 
> > > > Just wonder, why do you allow CMA memory to file page cache rather
> > > > than anonymous page? I guess that anonymous pages would be more easily
> > > > migrated/reclaimed than file page cache. In fact, some of our product
> > > > uses anonymous page adaptation to satisfy similar requirement by
> > > > introducing GFP_CMA. AFAIK, some of chip vendor also uses "anonymous
> > > > page first adaptation" to get better success rate.
> > > 
> > > The biggest problem we faced is to allocate big chunk of CMA memory,
> > > say 256MB in a whole, or 9 pieces of 20MB buffers, so the speed
> > > is not the biggest concern, but whether all the cma pages be reclaimed.
> > 
> > Okay. Our product have similar workload.
> > 
> > > With the MOVABLE fallback, there may be many types of bad guys from device
> > > drivers/kernel or different subsystems, who refuse to return the borrowed
> > > cma pages, so I took a lazy way by only allowing page cache to use free
> > > cma pages, and we see good results which could pass most of the test for
> > > allocating big chunks. 
> > 
> > Could you explain more about why file page cache rather than anonymous page?
> > If there is a reason, I'd like to test it by myself.
> 
> I didn't make it clear. This is not for anonymous page, but for MIGRATETYPE_MOVABLE.

Anonymous page is one of the pages with MIGRATETYPE_MOVABLE. So, you
can also restrict CMA memory only for anonymous page like as you did
for file page cache. Some of our product used this work around so I'd
like to know if there is a reason.

> 
> following is the patch to disable the kernel default sharing (kernel 3.14)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1b5f20e..a5e698f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -974,7 +974,11 @@ static int fallbacks[MIGRATE_TYPES][4] = {
>  	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,     MIGRATE_RESERVE },
>  	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,     MIGRATE_RESERVE },
>  #ifdef CONFIG_CMA
> -	[MIGRATE_MOVABLE]     = { MIGRATE_CMA,         MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
> +	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
>  	[MIGRATE_CMA]         = { MIGRATE_RESERVE }, /* Never used */
>  	[MIGRATE_CMA_ISOLATE] = { MIGRATE_RESERVE }, /* Never used */
>  #else
> @@ -1414,6 +1418,18 @@ void free_hot_cold_page(struct page *page, int cold)
>  	local_irq_save(flags);
>  	__count_vm_event(PGFREE);
>  
> +#ifndef CONFIG_USE_CMA_FALLBACK
> +	if (migratetype == MIGRATE_CMA) {
> +		free_one_page(zone, page, 0, MIGRATE_CMA);
> +		local_irq_restore(flags);
> +		return;
> +	}
> +#endif
> +
> 
> > 
> > > One of the customer used to use a CMA sharing patch from another vendor
> > > on our Socs, which can't pass these tests and finally took our page cache
> > > approach.
> > 
> > CMA has too many problems so each vendor uses their own adaptation. I'd
> > like to solve this code fragmentation by fixing problems on upstream
> > kernel and this ZONE_CMA is one of that effort. If you can share the
> > pointer for your adaptation, it would be very helpful to me.
> 
> As I said, I started to work on CMA problem back in 2014, and faced many
> of these failure in reclamation problems. I didn't have time and capability
> to track/analyze each and every failure, but decided to go another way by
> only allowing the page cache to use CMA.  And frankly speaking, I don't have
> detailed data for performance measurement, but some rough one, that it
> did improve the cma page reclaiming and the usage rate.

Okay!

> Our patches was based on 3.14 (the Android Mashmallow kenrel). Earlier this
> year I finally got some free time, and worked on cleaning them for submission
> to LKML, and found your cma improving patches merged in 4.1 or 4.2, so I gave
> up as my patches is more hacky :)
> 
> The sharing patch is here FYI:

Thanks for sharing!! It will be helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
