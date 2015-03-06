Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0EDD86B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 02:12:46 -0500 (EST)
Received: by pdjz10 with SMTP id z10so21949405pdj.11
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 23:12:45 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ri5si13185755pdb.115.2015.03.05.23.12.43
        for <linux-mm@kvack.org>;
        Thu, 05 Mar 2015 23:12:44 -0800 (PST)
Date: Fri, 6 Mar 2015 16:13:22 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 13/16] mm/cma: populate ZONE_CMA and use this zone when
 GFP_HIGHUSERMOVABLE
Message-ID: <20150306071322.GA15051@js1304-P5Q-DELUXE>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1423726340-4084-14-git-send-email-iamjoonsoo.kim@lge.com>
 <87vbiia3i9.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87vbiia3i9.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Mar 03, 2015 at 01:58:46PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > Until now, reserved pages for CMA are managed altogether with normal
> > page in the same zone. This approach has numorous problems and fixing
> > them isn't easy. To fix this situation, ZONE_CMA is introduced in
> > previous patch, but, not yet populated. This patch implement population
> > of ZONE_CMA by stealing reserved pages from normal zones. This stealing
> > break one uncertain assumption on zone, that is, zone isn't overlapped.
> > In the early of this series, some check is inserted to every zone's span
> > iterator to handle zone overlap so there would be no problem with
> > this assumption break.
> >
> > To utilize this zone, user should use GFP_HIGHUSERMOVABLE, because
> > these pages are only applicable for movable type and ZONE_CMA could
> > contain highmem.
> >
> > Implementation itself is very easy to understand. Do steal when cma
> > area is initialized and recalculate values for per zone data structure.
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  include/linux/gfp.h |   10 ++++++++--
> >  include/linux/mm.h  |    1 +
> >  mm/cma.c            |   23 ++++++++++++++++-------
> >  mm/page_alloc.c     |   42 +++++++++++++++++++++++++++++++++++++++---
> >  4 files changed, 64 insertions(+), 12 deletions(-)
> >
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index 619eb20..d125440 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -186,6 +186,12 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
> >  #define OPT_ZONE_DMA32 ZONE_NORMAL
> >  #endif
> >  
> > +#ifdef CONFIG_CMA
> > +#define OPT_ZONE_CMA ZONE_CMA
> > +#else
> > +#define OPT_ZONE_CMA ZONE_MOVABLE
> > +#endif
> > +
> 
> Does that mean with CONFIG_CMA we always try ZONE_CMA first and then
> fallback to ZONE_MOVABLE ? If so won't we hit termporary CMA allocation
> failures that can result with pinned movable pages ?

Hello, Aneesh.

IIUC, Johannes's fair allocation policy patchset makes us uses
individual zones fairly. So, before freepage on ZONE_CMA is exhausted,
ZONE_MOVABLE will be used. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
