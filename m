Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 980476B0269
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 01:22:01 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id u18so185864527ita.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 22:22:01 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id r202si199096itb.73.2016.09.21.22.22.00
        for <linux-mm@kvack.org>;
        Wed, 21 Sep 2016 22:22:01 -0700 (PDT)
Date: Thu, 22 Sep 2016 14:30:03 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v5 1/6] mm/page_alloc: don't reserve ZONE_HIGHMEM for
 ZONE_MOVABLE request
Message-ID: <20160922053003.GA27958@js1304-P5Q-DELUXE>
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1472447255-10584-2-git-send-email-iamjoonsoo.kim@lge.com>
 <87sht0y1rq.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87sht0y1rq.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 16, 2016 at 08:44:17AM +0530, Aneesh Kumar K.V wrote:
> js1304@gmail.com writes:
> 
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> > Freepage on ZONE_HIGHMEM doesn't work for kernel memory so it's not that
> > important to reserve. When ZONE_MOVABLE is used, this problem would
> > theorectically cause to decrease usable memory for GFP_HIGHUSER_MOVABLE
> > allocation request which is mainly used for page cache and anon page
> > allocation. So, fix it.
> >
> > And, defining sysctl_lowmem_reserve_ratio array by MAX_NR_ZONES - 1 size
> > makes code complex. For example, if there is highmem system, following
> > reserve ratio is activated for *NORMAL ZONE* which would be easyily
> > misleading people.
> >
> >  #ifdef CONFIG_HIGHMEM
> >  32
> >  #endif
> >
> > This patch also fix this situation by defining sysctl_lowmem_reserve_ratio
> > array by MAX_NR_ZONES and place "#ifdef" to right place.
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  include/linux/mmzone.h | 2 +-
> >  mm/page_alloc.c        | 7 ++++---
> >  2 files changed, 5 insertions(+), 4 deletions(-)
> >
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index d572b78..e3f39af 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -877,7 +877,7 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
> >  					void __user *, size_t *, loff_t *);
> >  int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
> >  					void __user *, size_t *, loff_t *);
> > -extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
> > +extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES];
> >  int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
> >  					void __user *, size_t *, loff_t *);
> >  int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 4f7d5d7..a8310de 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -198,17 +198,18 @@ static void __free_pages_ok(struct page *page, unsigned int order);
> >   * TBD: should special case ZONE_DMA32 machines here - in those we normally
> >   * don't need any ZONE_NORMAL reservation
> >   */
> > -int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
> > +int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES] = {
> >  #ifdef CONFIG_ZONE_DMA
> >  	 256,
> >  #endif
> >  #ifdef CONFIG_ZONE_DMA32
> >  	 256,
> >  #endif
> > -#ifdef CONFIG_HIGHMEM
> >  	 32,
> > +#ifdef CONFIG_HIGHMEM
> > +	 INT_MAX,
> >  #endif
> > -	 32,
> > +	 INT_MAX,
> >  };
> >
> >  EXPORT_SYMBOL(totalram_pages);
> > -- 
> > 1.9.1
> 
> We can also do things like below to make it readable ?
> 
> #ifdef CONFIG_ZONE_DMA
> 	[ZONE_DMA] = 256,
> #endif

It looks more readable! I will change it.

> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
