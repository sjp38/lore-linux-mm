Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF55B440615
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 11:22:07 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id h7so9088842wjy.6
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 08:22:07 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o39si13863558wrc.14.2017.02.17.08.22.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 08:22:06 -0800 (PST)
Date: Fri, 17 Feb 2017 11:22:02 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 2/7] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170217162202.GE23735@cmpxchg.org>
References: <cover.1487100204.git.shli@fb.com>
 <5c38c5f4d91e92ce86ee4f253e49c78708094632.1487100204.git.shli@fb.com>
 <20170216175253.GB20791@cmpxchg.org>
 <20170217003524.GA95440@shli-mbp.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170217003524.GA95440@shli-mbp.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Thu, Feb 16, 2017 at 04:35:25PM -0800, Shaohua Li wrote:
> On Thu, Feb 16, 2017 at 12:52:53PM -0500, Johannes Weiner wrote:
> > On Tue, Feb 14, 2017 at 11:36:08AM -0800, Shaohua Li wrote:
> > > @@ -126,4 +126,24 @@ static __always_inline enum lru_list page_lru(struct page *page)
> > >  
> > >  #define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
> > >  
> > > +/*
> > > + * lazyfree pages are clean anonymous pages. They have SwapBacked flag cleared
> > > + * to destinguish normal anonymous pages.
> > > + */
> > > +static inline void set_page_lazyfree(struct page *page)
> > > +{
> > > +	VM_BUG_ON_PAGE(!PageAnon(page) || !PageSwapBacked(page), page);
> > > +	ClearPageSwapBacked(page);
> > > +}
> > > +
> > > +static inline void clear_page_lazyfree(struct page *page)
> > > +{
> > > +	VM_BUG_ON_PAGE(!PageAnon(page) || PageSwapBacked(page), page);
> > > +	SetPageSwapBacked(page);
> > > +}
> > > +
> > > +static inline bool page_is_lazyfree(struct page *page)
> > > +{
> > > +	return PageAnon(page) && !PageSwapBacked(page);
> > > +}
> > 
> > Sorry for not getting to v2 in time, but I have to say I strongly
> > agree with your first iterations and would much prefer this to be
> > open-coded.
> > 
> > IMO this needlessly introduces a new state opaquely called "lazyfree",
> > when really that's just anonymous pages that don't need to be swapped
> > before reclaim - PageAnon && !PageSwapBacked. Very simple MM concept.
> > 
> > That especially shows when we later combine it with page_is_file_cache
> > checks like the next patch does.
> > 
> > The rest of the patch looks good to me.
> 
> Thanks! I do agree checking PageSwapBacked is clearer, but Minchan convinced me
> because of the accounting issue. Where do you suggest we should put the
> accounting to?

I now proposed quite a few changes to the setting and clearing sites,
so it's harder to judge, but AFAICT once those sites are consolidated,
open-coding the stat updates as well shouldn't be too bad, right?

One site to clear during MADV_FREE, one site to set during reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
