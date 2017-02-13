Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA8F6B0038
	for <linux-mm@kvack.org>; Sun, 12 Feb 2017 23:57:34 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f5so150932719pgi.1
        for <linux-mm@kvack.org>; Sun, 12 Feb 2017 20:57:34 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 81si8964910pfh.264.2017.02.12.20.57.32
        for <linux-mm@kvack.org>;
        Sun, 12 Feb 2017 20:57:33 -0800 (PST)
Date: Mon, 13 Feb 2017 13:57:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V2 2/7] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170213045731.GA27544@bbox>
References: <cover.1486163864.git.shli@fb.com>
 <3914c9f53c343357c39cb891210da31aa30ad3a9.1486163864.git.shli@fb.com>
 <20170210065022.GC25078@bbox>
 <20170210173008.GA86050@shli-mbp.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170210173008.GA86050@shli-mbp.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Hi Shaohua,

On Fri, Feb 10, 2017 at 09:30:09AM -0800, Shaohua Li wrote:

< snip >

> > > +static inline bool page_is_lazyfree(struct page *page)
> > > +{
> > > +	return PageAnon(page) && !PageSwapBacked(page);
> > > +}
> > > +
> > 
> > trivial:
> > 
> > How about using PageLazyFree for consistency with other PageXXX?
> > As well, use SetPageLazyFree/ClearPageLazyFree rather than using
> > raw {Set,Clear}PageSwapBacked.
> 
> So SetPageLazyFree == ClearPageSwapBacked, that would be weird. I personally
> prefer directly using {Set, Clear}PageSwapBacked, because reader can
> immediately know what's happening. If using the PageLazyFree, people always
> need to refer the code and check the relationship between PageLazyFree and
> PageSwapBacked.

I was not against so I was about to sending "No problem" now but I found your
patch 5 which accounts lazyfreeable pages in zone/node stat and handle them
in lru list management. Hmm, I think now we don't handle lazyfree pages with
separate LRU list so it's awkward to me although it may work. So, my idea is
we can handle it through wrapper regardless of LRU management.

For instance,

void SetLazyFreePage(struct page *page)
{
	if (!TestSetPageSwapBacked(page))
		inc_zone_page_state(page, NR_ZONE_LAZYFREE);
}


void ClearLazyFreePage(struct page *page)
{
	if (TestClearPageSwapBacked(page))
		dec_zone_page_state(page, NR_ZONE_LAZYFREE);
}

madvise_free_pte_range:
	SetLageFreePage(page);

activate_page,shrink_page_list:
	ClearLazyFreePage(page);

free_pages_prepare:
	if (PageMappingFlags(page)) {
		if (PageLazyFreePage(page))
			dec_zone_page_state(page, NR_ZONE_LAZYFREE);
		page->mapping = NULL;
	}

Surely, it's orthgonal issue regardless of using wrapper but it might
nudge you to use wrapper.

>  
> > >  static __always_inline void __update_lru_size(struct lruvec *lruvec,
> > >  				enum lru_list lru, enum zone_type zid,
> > >  				int nr_pages)
> > > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > > index 45e91dd..486494e 100644
> > > --- a/include/linux/swap.h
> > > +++ b/include/linux/swap.h
> > > @@ -279,7 +279,7 @@ extern void lru_add_drain_cpu(int cpu);
> > >  extern void lru_add_drain_all(void);
> > >  extern void rotate_reclaimable_page(struct page *page);
> > >  extern void deactivate_file_page(struct page *page);
> > > -extern void deactivate_page(struct page *page);
> > > +extern void mark_page_lazyfree(struct page *page);
> > 
> > trivial:
> > 
> > How about "deactivate_lazyfree_page"? IMO, it would show intention
> > clear that move the lazy free page to inactive list.
> > 
> > It's just matter of preference so I'm not strong against.
> 
> Yes, I thought about the name a little bit. Don't think we should use
> deactivate, because it sounds that only works for active page, while the
> function works for both active/inactive pages. I'm open to any suggestions.

Indeed.

I don't have better idea, either so my last suggestion is "demote_lazyfree_page".
It seems there are several papers/wikipedia to use *demote* in LRU managment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
