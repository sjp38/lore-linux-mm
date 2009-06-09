Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 327D26B005A
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 09:10:39 -0400 (EDT)
Date: Tue, 9 Jun 2009 21:49:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [11/16] HWPOISON: check and isolate corrupted free
	pages v2
Message-ID: <20090609134903.GC6583@localhost>
References: <20090603846.816684333@firstfloor.org> <20090603184645.68FA21D0286@basil.firstfloor.org> <20090609100229.GE14820@wotan.suse.de> <20090609130304.GF5589@localhost> <20090609132847.GC15219@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090609132847.GC15219@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 09:28:47PM +0800, Nick Piggin wrote:
> On Tue, Jun 09, 2009 at 09:03:04PM +0800, Wu Fengguang wrote:
> > On Tue, Jun 09, 2009 at 06:02:29PM +0800, Nick Piggin wrote:
> > > On Wed, Jun 03, 2009 at 08:46:45PM +0200, Andi Kleen wrote:
> > > > 
> > > > From: Wu Fengguang <fengguang.wu@intel.com>
> > > > 
> > > > If memory corruption hits the free buddy pages, we can safely ignore them.
> > > > No one will access them until page allocation time, then prep_new_page()
> > > > will automatically check and isolate PG_hwpoison page for us (for 0-order
> > > > allocation).
> > > 
> > > It would be kinda nice if this could be done in the handler
> > > directly (ie. take the page directly out of the allocator
> > > or pcp list). Completely avoiding fastpaths would be a
> > > wonderful goal.
> > 
> > In fact Andi have code to do that. We prefer this one because
> > - it's simple
> > - it's good sanity check for possible software BUGs
> > - it mainly adds overhead to high order pages, which is acceptable
> 
> Yeah it's not bad. But we don't have much other non-debug options
> that check for random memory corruption like this. Given that the
> struct page is a very tiny proportion of memory, then I'm not
> totally convinced that all this checking in the page allocator is
> worthwhile for everyone. It's a much bigger cost if checks and
> branches have to be there just for hwpoison.

Maybe.

> And I don't think removing a free page from the page allocator is
> too much more complex than removing a live page from the pagecache ;)

There are usable functions for doing pagecache isolations, but no one
to isolate one specific page from the buddy system.

Plus, if we did present such a function, you'll then ask for it being
included in page_alloc.c, injecting a big chunk of dead code into the
really hot code blocks and possibly polluting the L2 cache. Will it be
better than just inserting several lines? Hardly. Smaller text itself
yields faster speed.

Thanks,
Fengguang

> 
> > 
> > Thanks,
> > Fengguang
> > 
> > > >  
> > > > +	/* Don't complain about poisoned pages */
> > > > +	if (PageHWPoison(page)) {
> > > > +		__ClearPageBuddy(page);
> > > > +		return;
> > > > +	}
> > > > +
> > 
> > I do think the above chunk is not absolutely necessary, though.
> > 
> > Thanks,
> > Fengguang
> > 
> > 
> > > >  	/*
> > > >  	 * Allow a burst of 60 reports, then keep quiet for that minute;
> > > >  	 * or allow a steady drip of one report per second.
> > > > @@ -650,7 +656,7 @@
> > > >  /*
> > > >   * This page is about to be returned from the page allocator
> > > >   */
> > > > -static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
> > > > +static inline int check_new_page(struct page *page)
> > > >  {
> > > >  	if (unlikely(page_mapcount(page) |
> > > >  		(page->mapping != NULL)  |
> > > > @@ -659,6 +665,18 @@
> > > >  		bad_page(page);
> > > >  		return 1;
> > > >  	}
> > > > +	return 0;
> > > > +}
> > > > +
> > > > +static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
> > > > +{
> > > > +	int i;
> > > > +
> > > > +	for (i = 0; i < (1 << order); i++) {
> > > > +		struct page *p = page + i;
> > > > +		if (unlikely(check_new_page(p)))
> > > > +			return 1;
> > > > +	}
> > > >  
> > > >  	set_page_private(page, 0);
> > > >  	set_page_refcounted(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
