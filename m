Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 67A406B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 01:44:37 -0500 (EST)
Received: by pdjg10 with SMTP id g10so18969280pdj.1
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 22:44:37 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id q8si4299489pdp.62.2015.02.26.22.44.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Feb 2015 22:44:36 -0800 (PST)
Received: by pablj1 with SMTP id lj1so4340725pab.13
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 22:44:36 -0800 (PST)
Date: Fri, 27 Feb 2015 15:44:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
Message-ID: <20150227064425.GB20805@blaptop>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <20150224154318.GA14939@dhcp22.suse.cz>
 <20150225000809.GA6468@blaptop>
 <35FD53F367049845BC99AC72306C23D10458D6173BDC@CNBJMBX05.corpusers.net>
 <20150227052805.GA20805@blaptop>
 <35FD53F367049845BC99AC72306C23D10458D6173BDE@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D10458D6173BDE@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>

On Fri, Feb 27, 2015 at 01:48:48PM +0800, Wang, Yalin wrote:
> > -----Original Message-----
> > From: Minchan Kim [mailto:minchan.kim@gmail.com] On Behalf Of Minchan Kim
> > Sent: Friday, February 27, 2015 1:28 PM
> > To: Wang, Yalin
> > Cc: Michal Hocko; Andrew Morton; linux-kernel@vger.kernel.org; linux-
> > mm@kvack.org; Rik van Riel; Johannes Weiner; Mel Gorman; Shaohua Li
> > Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
> > 
> > Hello,
> > 
> > On Fri, Feb 27, 2015 at 11:37:18AM +0800, Wang, Yalin wrote:
> > > This patch add ClearPageDirty() to clear AnonPage dirty flag,
> > > the Anonpage mapcount must be 1, so that this page is only used by
> > > the current process, not shared by other process like fork().
> > > if not clear page dirty for this anon page, the page will never be
> > > treated as freeable.
> > 
> > In case of anonymous page, it has PG_dirty when VM adds it to
> > swap cache and clear it in clear_page_dirty_for_io. That's why
> > I added ClearPageDirty if we found it in swapcache.
> > What case am I missing? It would be better to understand if you
> > describe specific scenario.
> > 
> > Thanks.
> > 
> > >
> > > Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> > > ---
> > >  mm/madvise.c | 15 +++++----------
> > >  1 file changed, 5 insertions(+), 10 deletions(-)
> > >
> > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > index 6d0fcb8..257925a 100644
> > > --- a/mm/madvise.c
> > > +++ b/mm/madvise.c
> > > @@ -297,22 +297,17 @@ static int madvise_free_pte_range(pmd_t *pmd,
> > unsigned long addr,
> > >  			continue;
> > >
> > >  		page = vm_normal_page(vma, addr, ptent);
> > > -		if (!page)
> > > +		if (!page || !PageAnon(page) || !trylock_page(page))
> > >  			continue;
> > >
> > >  		if (PageSwapCache(page)) {
> > > -			if (!trylock_page(page))
> > > +			if (!try_to_free_swap(page))
> > >  				continue;
> > > -
> > > -			if (!try_to_free_swap(page)) {
> > > -				unlock_page(page);
> > > -				continue;
> > > -			}
> > > -
> > > -			ClearPageDirty(page);
> > > -			unlock_page(page);
> > >  		}
> > >
> > > +		if (page_mapcount(page) == 1)
> > > +			ClearPageDirty(page);
> > > +		unlock_page(page);
> > >  		/*
> > >  		 * Some of architecture(ex, PPC) don't update TLB
> > >  		 * with set_pte_at and tlb_remove_tlb_entry so for
> > > --
> Yes, for page which is in SwapCache, it is correct,
> But for anon page which is not in SwapCache, it is always
> PageDirty(), so we should also clear dirty bit to make it freeable,

No. Every anon page starts from !PageDirty and it has PG_dirty
only when it's addeded into swap cache. If vm_swap_full turns on,
a page in swap cache could have PG_dirty via try_to_free_swap again.
So, Do you have concern about swapped-out pages when MADV_FREE is
called? If so, please look at my patch.

https://lkml.org/lkml/2015/2/25/43

It will zap the swapped out page. So, this is not a issue any more?

> 
> Another problem  is that if an anon page is shared by more than one process,
> This happened when fork(), the anon page will be copy on write,
> In this case, we should not clear page dirty,
> This is not correct for other process which don't call MADV_FREE syscall.

You mean we shouldn't inherit MADV_FREE attribute?
Why?

parent:
ptr1 = malloc(len);
        -> allocator calls mmap(len);
memset(ptr1, 'a', len);
free(ptr1);
        -> allocator calss madvise_free(ptr1, len);
..
..
        -> VM discard hinted pages

fork();

child:

ptr2 = malloc(len)
        -> allocator reuses the chunk allocated from parent.
so, child will see zero pages from ptr2 but he doesn't write
anything so garbage|zero page anything is okay to him.


> 
> Thanks
> 
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
