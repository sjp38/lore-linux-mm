Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id AB5616B006C
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 19:43:05 -0500 (EST)
Received: by pabli10 with SMTP id li10so18952929pab.2
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 16:43:05 -0800 (PST)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id kt1si8684149pdb.20.2015.03.02.16.43.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 16:43:04 -0800 (PST)
Received: by pdbfp1 with SMTP id fp1so6584580pdb.7
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 16:43:04 -0800 (PST)
Date: Tue, 3 Mar 2015 09:42:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
Message-ID: <20150303004251.GA22742@blaptop>
References: <20150224154318.GA14939@dhcp22.suse.cz>
 <20150225000809.GA6468@blaptop>
 <35FD53F367049845BC99AC72306C23D10458D6173BDC@CNBJMBX05.corpusers.net>
 <20150227052805.GA20805@blaptop>
 <35FD53F367049845BC99AC72306C23D10458D6173BDE@CNBJMBX05.corpusers.net>
 <20150227064425.GB20805@blaptop>
 <35FD53F367049845BC99AC72306C23D10458D6173BDF@CNBJMBX05.corpusers.net>
 <20150227133714.GA25947@blaptop>
 <20150228135014.GA25311@blaptop>
 <35FD53F367049845BC99AC72306C23D10458D6173BE3@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D10458D6173BE3@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>

On Mon, Mar 02, 2015 at 09:59:20AM +0800, Wang, Yalin wrote:
> > -----Original Message-----
> > From: Minchan Kim [mailto:minchan.kim@gmail.com] On Behalf Of Minchan Kim
> > Sent: Saturday, February 28, 2015 9:50 PM
> > To: Wang, Yalin
> > Cc: Michal Hocko; Andrew Morton; linux-kernel@vger.kernel.org; linux-
> > mm@kvack.org; Rik van Riel; Johannes Weiner; Mel Gorman; Shaohua Li
> > Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
> > 
> > On Fri, Feb 27, 2015 at 10:37:14PM +0900, Minchan Kim wrote:
> > > On Fri, Feb 27, 2015 at 03:50:29PM +0800, Wang, Yalin wrote:
> > > > > -----Original Message-----
> > > > > From: Minchan Kim [mailto:minchan.kim@gmail.com] On Behalf Of Minchan
> > Kim
> > > > > Sent: Friday, February 27, 2015 2:44 PM
> > > > > To: Wang, Yalin
> > > > > Cc: Michal Hocko; Andrew Morton; linux-kernel@vger.kernel.org; linux-
> > > > > mm@kvack.org; Rik van Riel; Johannes Weiner; Mel Gorman; Shaohua Li
> > > > > Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
> > > > >
> > > > > On Fri, Feb 27, 2015 at 01:48:48PM +0800, Wang, Yalin wrote:
> > > > > > > -----Original Message-----
> > > > > > > From: Minchan Kim [mailto:minchan.kim@gmail.com] On Behalf Of
> > Minchan
> > > > > Kim
> > > > > > > Sent: Friday, February 27, 2015 1:28 PM
> > > > > > > To: Wang, Yalin
> > > > > > > Cc: Michal Hocko; Andrew Morton; linux-kernel@vger.kernel.org;
> > linux-
> > > > > > > mm@kvack.org; Rik van Riel; Johannes Weiner; Mel Gorman; Shaohua
> > Li
> > > > > > > Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
> > > > > > >
> > > > > > > Hello,
> > > > > > >
> > > > > > > On Fri, Feb 27, 2015 at 11:37:18AM +0800, Wang, Yalin wrote:
> > > > > > > > This patch add ClearPageDirty() to clear AnonPage dirty flag,
> > > > > > > > the Anonpage mapcount must be 1, so that this page is only used
> > by
> > > > > > > > the current process, not shared by other process like fork().
> > > > > > > > if not clear page dirty for this anon page, the page will never
> > be
> > > > > > > > treated as freeable.
> > > > > > >
> > > > > > > In case of anonymous page, it has PG_dirty when VM adds it to
> > > > > > > swap cache and clear it in clear_page_dirty_for_io. That's why
> > > > > > > I added ClearPageDirty if we found it in swapcache.
> > > > > > > What case am I missing? It would be better to understand if you
> > > > > > > describe specific scenario.
> > > > > > >
> > > > > > > Thanks.
> > > > > > >
> > > > > > > >
> > > > > > > > Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> > > > > > > > ---
> > > > > > > >  mm/madvise.c | 15 +++++----------
> > > > > > > >  1 file changed, 5 insertions(+), 10 deletions(-)
> > > > > > > >
> > > > > > > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > > > > > > index 6d0fcb8..257925a 100644
> > > > > > > > --- a/mm/madvise.c
> > > > > > > > +++ b/mm/madvise.c
> > > > > > > > @@ -297,22 +297,17 @@ static int madvise_free_pte_range(pmd_t
> > *pmd,
> > > > > > > unsigned long addr,
> > > > > > > >  			continue;
> > > > > > > >
> > > > > > > >  		page = vm_normal_page(vma, addr, ptent);
> > > > > > > > -		if (!page)
> > > > > > > > +		if (!page || !PageAnon(page)
> > || !trylock_page(page))
> > > > > > > >  			continue;
> > > > > > > >
> > > > > > > >  		if (PageSwapCache(page)) {
> > > > > > > > -			if (!trylock_page(page))
> > > > > > > > +			if (!try_to_free_swap(page))
> > > > > > > >  				continue;
> > > > > > > > -
> > > > > > > > -			if (!try_to_free_swap(page)) {
> > > > > > > > -				unlock_page(page);
> > > > > > > > -				continue;
> > > > > > > > -			}
> > > > > > > > -
> > > > > > > > -			ClearPageDirty(page);
> > > > > > > > -			unlock_page(page);
> > > > > > > >  		}
> > > > > > > >
> > > > > > > > +		if (page_mapcount(page) == 1)
> > > > > > > > +			ClearPageDirty(page);
> > > > > > > > +		unlock_page(page);
> > > > > > > >  		/*
> > > > > > > >  		 * Some of architecture(ex, PPC) don't update TLB
> > > > > > > >  		 * with set_pte_at and tlb_remove_tlb_entry so for
> > > > > > > > --
> > > > > > Yes, for page which is in SwapCache, it is correct,
> > > > > > But for anon page which is not in SwapCache, it is always
> > > > > > PageDirty(), so we should also clear dirty bit to make it freeable,
> > > > >
> > > > > No. Every anon page starts from !PageDirty and it has PG_dirty
> > > > > only when it's addeded into swap cache. If vm_swap_full turns on,
> > > > > a page in swap cache could have PG_dirty via try_to_free_swap again.
> > > >
> > > > mmm..
> > > > sometimes you can see an anon page PageDirty(), but it is not in
> > swapcache,
> > > > for example, handle_pte_fault()-->do_swap_page()-->try_to_free_swap(),
> > > > at this time, the page is deleted from swapcache and is marked
> > PageDirty(),
> > >
> > > That's what I missed. It's clear and would be simple patch so
> > > could you send a patch to fix this issue with detailed description
> > > like above?
> > >
> > > >
> > > >
> > > > > So, Do you have concern about swapped-out pages when MADV_FREE is
> > > > > called? If so, please look at my patch.
> > > > >
> > > > > https://lkml.org/lkml/2015/2/25/43
> > > > >
> > > > > It will zap the swapped out page. So, this is not a issue any more?
> > > > >
> > > > > >
> > > > > > Another problem  is that if an anon page is shared by more than one
> > > > > process,
> > > > > > This happened when fork(), the anon page will be copy on write,
> > > > > > In this case, we should not clear page dirty,
> > > > > > This is not correct for other process which don't call MADV_FREE
> > syscall.
> > > > >
> > > > > You mean we shouldn't inherit MADV_FREE attribute?
> > > > > Why?
> > > >
> > > > Is it correct behavior if code like this:
> > > >
> > > > Parent:
> > > > ptr1 = malloc(len);
> > > > memset(ptr1, 'a', len);
> > > > fork();
> > > > if (I am parent)
> > > > 	madvise_free(ptr1, len);
> > > >
> > > > child:
> > > > sleep(10);
> > > > parse_data(ptr1, len);  // child may see zero, not 'a',
> > > > 			// is it the right behavior that the programer want?
> > > >
> > > > Because child don't call madvise_free(), so it should see 'a', not zero
> > page.
> > > > Isn't it ?
> > >
> > > You're absolutely right. Thanks.
> > > But I doubt your fix is best. Most of fork will do exec soonish so
> > > it's not a good idea to make MADV_FREE void even though hinted pages
> > > are shared when the syscall was called.
> > > How about checking the page is shared or not in reclaim path?
> > > If it is still shared, we shouldn't discard it.
> > 
> > I got confused. With looking at copy_one_pte, it copys from src_pte
> > and not clear dirty bit if it's not a shared mapping.
> > If so, in your example, child pte has pte dirty bit on while parent
> > has clean bit by madvise_free so that VM shouldn't discard the page.
> > No?
> > 
> It is not always true that src_pte has dirty bit.
> For example ,
> If a page have been swap into swap partition,
> The pte have become a swap entry,
> Then a read fault happened,
> The pte will be a page pte without dirty bit,
> Am I ritht?

Parent A, Child B

1. Page : swapped-out, A: !pte_present B: !pte_present, A or B does madvise_free

It's not pte_present so madvise_free will be void

2. Page : swapped-in, PageSwapCache A: pte_clean by swapin-read fault
   B: !pte_present, A does madvise_free

madvise_free will do try_to_free_swap but other process(ie, B) is still
reference the swap slot so it will fail so madvise_free by A will be void.

3. Page: swappined-in, !PageSwapCache A: pte_clean by swapin-read fault
   B: !pte_clean by swapin-read fault, A does madvise_free

Since the page is removed from swap cache, it has PG_dirty so we couldn't
discard the page(ie, we should swap out, not discard).

Is there any usecase I am missing?

Anyway, relying on PageDirty for madvise_free rather than pte_dirty
makes lots of confuse. Originally, PageDirty flag for anonymous page
is for avoidng unnecessary swapout so I will cook a patch and send RFC.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
