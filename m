Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 4EA616B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 19:34:22 -0500 (EST)
Date: Tue, 27 Nov 2012 22:34:10 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm: fix balloon_page_movable() page->flags check
Message-ID: <20121128003409.GB7401@t510.redhat.com>
References: <20121127145708.c7173d0d.akpm@linux-foundation.org>
 <1ccb1c95a52185bcc6009761cb2829197e2737ea.1354058194.git.aquini@redhat.com>
 <20121127155201.ddfea7e1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121127155201.ddfea7e1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>

On Tue, Nov 27, 2012 at 03:52:01PM -0800, Andrew Morton wrote:
> On Tue, 27 Nov 2012 21:31:10 -0200
> Rafael Aquini <aquini@redhat.com> wrote:
> 
> > This patch fixes the following crash by fixing and enhancing the way 
> > page->flags are tested to identify a ballooned page.
> > 
> > ---8<---
> > BUG: unable to handle kernel NULL pointer dereference at 0000000000000194
> > IP: [<ffffffff8122b354>] isolate_migratepages_range+0x344/0x7b0
> > --->8---
> > 
> > The NULL pointer deref was taking place because balloon_page_movable()
> > page->flags tests were incomplete and we ended up 
> > inadvertently poking at private pages.
> > 
> > ....
> >
> >  /*
> > + * __balloon_page_flags - helper to perform balloon @page ->flags tests.
> > + *
> > + * As balloon pages are got from Buddy, and we do not play with page->flags
> > + * at driver level (exception made when we get the page lock for compaction),
> > + * therefore we can safely identify a ballooned page by checking if the
> > + * NR_PAGEFLAGS rightmost bits from the page->flags are all cleared.
> > + * This approach also helps on skipping ballooned pages that are locked for
> > + * compaction or release, thus mitigating their racy check at
> > + * balloon_page_movable()
> > + */
> > +#define BALLOON_PAGE_FLAGS_MASK       ((1UL << NR_PAGEFLAGS) - 1)
> 
> hm, this seems a bit fragile.
> 
> What's actually going on here?  You're assuming that a page fresh from
> buddy has all flags 0..NR_PAGEFLAGS cleared?
>
 
Yes, thats the idea, as when we get pages from freelists, they are all checked 
by prep_new_page()->check_new_page() before buffered_rmqueue() returns them.
By the path we use to get balloon pages, if the page has any of 0..NR_PAGEFLAGS
flags set at the alloc time it's regarded as bad_page by check_new_page(),
and we go after another victim.


> That may be true, I'm unsure.  Please take a look at
> PAGE_FLAGS_CHECK_AT_FREE and PAGE_FLAGS_CHECK_AT_PREP and work out why
> the heck these aren't the same thing!

Humm, I can't think of why, either... As I've followed the prep path, I didn't
notice that difference. I'll look at it closer, though.


>
> Either way around, doing
> 
> 	#define BALLOON_PAGE_FLAGS_MASK PAGE_FLAGS_CHECK_AT_PREP
> 
> seems rather more maintainable.

As usual, your suggestion is far way better than my orinal proposal :)


> 
> > +static inline bool __balloon_page_flags(struct page *page)
> > +{
> > +	return page->flags & BALLOON_PAGE_FLAGS_MASK ? false : true;
> 
> We have a neater way of doing the scalar-to-boolean conversion:
> 
> 	return !(page->flags & BALLOON_PAGE_FLAGS_MASK);
> 

ditto! :)


Do you want me to resubmit this patch with the changes you suggested?


Cheers!
Rafael

> > +}
> > +
> > +/*
> >   * __is_movable_balloon_page - helper to perform @page mapping->flags tests
> >   */
> >  static inline bool __is_movable_balloon_page(struct page *page)
> > @@ -135,8 +152,8 @@ static inline bool balloon_page_movable(struct page *page)
> >  	 * Before dereferencing and testing mapping->flags, lets make sure
> >  	 * this is not a page that uses ->mapping in a different way
> >  	 */
> > -	if (!PageSlab(page) && !PageSwapCache(page) && !PageAnon(page) &&
> > -	    !page_mapped(page))
> > +	if (__balloon_page_flags(page) && !page_mapped(page) &&
> > +	    page_count(page) == 1)
> >  		return __is_movable_balloon_page(page);
> >  
> >  	return false;
> >
> > ...
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
