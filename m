Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id A5BCD6B0032
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 01:57:38 -0400 (EDT)
Received: by pddn5 with SMTP id n5so9800237pdd.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 22:57:38 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id ku6si8293573pab.228.2015.03.30.22.57.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 22:57:37 -0700 (PDT)
Received: by pdrw1 with SMTP id w1so1530910pdr.0
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 22:57:37 -0700 (PDT)
Date: Tue, 31 Mar 2015 14:57:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/4] mm: move lazy free pages to inactive list
Message-ID: <20150331055729.GC16825@blaptop>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
 <1426036838-18154-3-git-send-email-minchan@kernel.org>
 <20150320154358.51bcf3cbceeb8fbbdb2b58e5@linux-foundation.org>
 <20150330053502.GB3008@blaptop>
 <20150330142010.5d14fbc07e05180cc3ecce5c@linux-foundation.org>
 <20150331044525.GB16825@blaptop>
 <20150330222847.f255962c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150330222847.f255962c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com

On Mon, Mar 30, 2015 at 10:28:47PM -0700, Andrew Morton wrote:
> On Tue, 31 Mar 2015 13:45:25 +0900 Minchan Kim <minchan@kernel.org> wrote:
> > > 
> > > deactivate_page() doesn't look at or alter PageReferenced().  Should it?
> > 
> > Absolutely true. Thanks.
> > Here it goes.
> > 
> > >From 2b2c92eb73a1cceac615b9abd4c0f5f0c3395ff5 Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Tue, 31 Mar 2015 13:38:46 +0900
> > Subject: [PATCH] mm: lru_deactivate_fn should clear PG_referenced
> > 
> > deactivate_page aims for accelerate for reclaiming through
> > moving pages from active list to inactive list so we should
> > clear PG_referenced for the goal.
> > 
> > ...
> >
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -800,6 +800,7 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
> >  
> >  		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
> >  		ClearPageActive(page);
> > +		ClearPageReferenced(page);
> >  		add_page_to_lru_list(page, lruvec, lru);
> >  
> >  		__count_vm_event(PGDEACTIVATE);
> 
> What if we have
> 
> 	PageLRU(page) && !PageActive(page) && PageReferenced(page)
> 
> if we really want to "accelerate the reclaim of @page" then we should
> clear PG_referenced there too.

The function's name is *deactivate*_page. IOW, I think it should work
for only pages in active list, IMHO.

> 
> (And what about page_referenced(page) :))

Yes, I considered it when you mentioned PG_referenced. Now, madvise_free
clear out access bit of page table when the syscall is called so
shrink_page_list could reclaim pages easily.

Of course, we could clear access bit by page_referenced for general purpose,
not only madvise_free but it would hurt performance for madvise_free so
I'd like to leave it unless there is a need for the function.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
