Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2786B0038
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 19:30:55 -0400 (EDT)
Received: by padck2 with SMTP id ck2so19798423pad.0
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 16:30:55 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id pu4si1848859pbb.18.2015.08.04.16.30.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Aug 2015 16:30:54 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so10322892pdr.2
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 16:30:54 -0700 (PDT)
Date: Wed, 5 Aug 2015 08:31:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] vmscan: fix increasing nr_isolated incurred by
 putback unevictable pages
Message-ID: <20150804233108.GA662@bgram>
References: <1438684808-12707-1-git-send-email-jaewon31.kim@samsung.com>
 <20150804150937.ee3b62257e77911a2f41a48e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150804150937.ee3b62257e77911a2f41a48e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jaewon Kim <jaewon31.kim@samsung.com>, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

Hello,

On Tue, Aug 04, 2015 at 03:09:37PM -0700, Andrew Morton wrote:
> On Tue, 04 Aug 2015 19:40:08 +0900 Jaewon Kim <jaewon31.kim@samsung.com> wrote:
> 
> > reclaim_clean_pages_from_list() assumes that shrink_page_list() returns
> > number of pages removed from the candidate list. But shrink_page_list()
> > puts back mlocked pages without passing it to caller and without
> > counting as nr_reclaimed. This incurrs increasing nr_isolated.
> > To fix this, this patch changes shrink_page_list() to pass unevictable
> > pages back to caller. Caller will take care those pages.
> > 
> > ..
> >
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1157,7 +1157,7 @@ cull_mlocked:
> >  		if (PageSwapCache(page))
> >  			try_to_free_swap(page);
> >  		unlock_page(page);
> > -		putback_lru_page(page);
> > +		list_add(&page->lru, &ret_pages);
> >  		continue;
> >  
> >  activate_locked:
> 
> Is this going to cause a whole bunch of mlocked pages to be migrated
> whereas in current kernels they stay where they are?
> 

It fixes two issues.

1. With unevictable page, cma_alloc will be successful.

Exactly speaking, cma_alloc of current kernel will fail due to unevictable pages.

2. fix leaking of NR_ISOLATED counter of vmstat

With it, too_many_isolated works. Otherwise, it could make hang until
the process get SIGKILL.

So, I think it's stable material.

Acked-by: Minchan Kim <minchan@kernel.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
