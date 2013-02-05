Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 88CBD6B00F3
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 02:10:26 -0500 (EST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MHQ00BLOJWFGS20@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 05 Feb 2013 07:10:24 +0000 (GMT)
Received: from [127.0.0.1] ([106.116.147.30])
 by eusync3.samsung.com (Oracle Communications Messaging Server 7u4-23.01
 (7.0.4.23.0) 64bit (built Aug 10 2011))
 with ESMTPA id <0MHQ00870JX8B880@eusync3.samsung.com> for linux-mm@kvack.org;
 Tue, 05 Feb 2013 07:10:24 +0000 (GMT)
Message-id: <5110B05B.5070109@samsung.com>
Date: Tue, 05 Feb 2013 08:10:19 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm: cma: fix accounting of CMA pages placed in high memory
References: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com>
 <20130204233430.GA2610@blaptop>
In-reply-to: <20130204233430.GA2610@blaptop>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, kyungmin.park@samsung.com

Hello,

On 2/5/2013 12:34 AM, Minchan Kim wrote:
> On Mon, Feb 04, 2013 at 11:27:05AM +0100, Marek Szyprowski wrote:
> > The total number of low memory pages is determined as
> > totalram_pages - totalhigh_pages, so without this patch all CMA
> > pageblocks placed in highmem were accounted to low memory.
>
> So what's the end user effect? With the effect, we have to decide
> routing it on stable.
>
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > ---
> >  mm/page_alloc.c |    4 ++++
> >  1 file changed, 4 insertions(+)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index f5bab0a..6415d93 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -773,6 +773,10 @@ void __init init_cma_reserved_pageblock(struct page *page)
> >  	set_pageblock_migratetype(page, MIGRATE_CMA);
> >  	__free_pages(page, pageblock_order);
> >  	totalram_pages += pageblock_nr_pages;
> > +#ifdef CONFIG_HIGHMEM
>
> We don't need #ifdef/#endif.

#ifdef is required to let this code compile when highmem is not enabled,
becuase totalhigh_pages is defined as 0, see include/linux/highmem.h

> > +	if (PageHighMem(page))
> > +		totalhigh_pages += pageblock_nr_pages;
> > +#endif
> >  }
> >  #endif
> >

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
