Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id D48ED90002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 00:30:51 -0400 (EDT)
Received: by paceu11 with SMTP id eu11so8059595pac.4
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 21:30:51 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id rm11si4752140pab.81.2015.03.10.21.30.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 21:30:51 -0700 (PDT)
Received: by pablj1 with SMTP id lj1so7976235pab.10
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 21:30:50 -0700 (PDT)
Date: Wed, 11 Mar 2015 13:30:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/4] mm: move lazy free pages to inactive list
Message-ID: <20150311043043.GB4794@blaptop>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
 <1426036838-18154-3-git-send-email-minchan@kernel.org>
 <35FD53F367049845BC99AC72306C23D10458D6173C04@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D10458D6173C04@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>

On Wed, Mar 11, 2015 at 10:14:51AM +0800, Wang, Yalin wrote:
> > -----Original Message-----
> > From: Minchan Kim [mailto:minchan@kernel.org]
> > Sent: Wednesday, March 11, 2015 9:21 AM
> > To: Andrew Morton
> > Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; Michal Hocko;
> > Johannes Weiner; Mel Gorman; Rik van Riel; Shaohua Li; Wang, Yalin; Minchan
> > Kim
> > Subject: [PATCH 3/4] mm: move lazy free pages to inactive list
> > 
> > MADV_FREE is hint that it's okay to discard pages if there is
> > memory pressure and we uses reclaimers(ie, kswapd and direct reclaim)
> > to free them so there is no worth to remain them in active anonymous LRU
> > so this patch moves them to inactive LRU list's head.
> > 
> > This means that MADV_FREE-ed pages which were living on the inactive list
> > are reclaimed first because they are more likely to be cold rather than
> > recently active pages.
> > 
> > A arguable issue for the approach would be whether we should put it to
> > head or tail in inactive list. I selected *head* because kernel cannot
> > make sure it's really cold or warm for every MADV_FREE usecase but
> > at least we know it's not *hot* so landing of inactive head would be
> > comprimise for various usecases.
> > 
> > This is fixing a suboptimal behavior of MADV_FREE when pages living on
> > the active list will sit there for a long time even under memory
> > pressure while the inactive list is reclaimed heavily. This basically
> > breaks the whole purpose of using MADV_FREE to help the system to free
> > memory which is might not be used.
> > 
> > Acked-by: Michal Hocko <mhocko@suse.cz>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  include/linux/swap.h |  1 +
> >  mm/madvise.c         |  2 ++
> >  mm/swap.c            | 35 +++++++++++++++++++++++++++++++++++
> >  3 files changed, 38 insertions(+)
> > 
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index cee108c..0428e4c 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -308,6 +308,7 @@ extern void lru_add_drain_cpu(int cpu);
> >  extern void lru_add_drain_all(void);
> >  extern void rotate_reclaimable_page(struct page *page);
> >  extern void deactivate_file_page(struct page *page);
> > +extern void deactivate_page(struct page *page);
> >  extern void swap_setup(void);
> > 
> >  extern void add_page_to_unevictable_list(struct page *page);
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index ebe692e..22e8f0c 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -340,6 +340,8 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned
> > long addr,
> >  		ptent = pte_mkold(ptent);
> >  		ptent = pte_mkclean(ptent);
> >  		set_pte_at(mm, addr, pte, ptent);
> > +		if (PageActive(page))
> > +			deactivate_page(page);
> >  		tlb_remove_tlb_entry(tlb, pte, addr);
> >  	}
> 
> I think this place should be changed like this:
>   +		if (!page_referenced(page, false, NULL, NULL, NULL) && PageActive(page))
>   +			deactivate_page(page);
> Because we don't know if other processes are reference this page,
> If it is true, don't need deactivate this page.

The page_referenced is too much heavy operation to do it
in madvise_free fast path.
If other processes(parent or child) referenced the page,
shrink_page_list in slow path could filter it out and
activates the page.

In addition, shared case for anon pages happens by fork mostly
so we could expect child will do exec soonish in many cases.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
