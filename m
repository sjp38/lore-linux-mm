Received: from Cantor.suse.de (Cantor.suse.de [194.112.123.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA16301
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 17:37:18 -0500
Message-ID: <19981123233550.34576@boole.suse.de>
Date: Mon, 23 Nov 1998 23:35:50 +0100
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Re: Running 2.1.129 at extrem load [patch] (Was: Linux-2.1.129..)
References: <19981123215359.45625@boole.suse.de> <Pine.LNX.3.96.981123224942.6626B-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.96.981123224942.6626B-100000@mirkwood.dummy.home>; from Rik van Riel on Mon, Nov 23, 1998 at 10:59:38PM +0100
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm <linux-mm@kvack.org>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>


> >  	struct page *next_hash;
> >  	atomic_t count;
> > -	unsigned int unused;
> > +	unsigned int lifetime;
> >  	unsigned long flags;	/* atomic flags, some possibly updated asynchronously */
> 
> Hmm, this looks suspiciously like a new incarnation of
> page aging (which we want to avoid, at least in some
> parts of the kernel).

Yep ... we should avoid removing this `unused'.

> > --- linux-2.1.129/mm/filemap.c	Thu Nov 19 20:44:18 1998
> > +++ linux/mm/filemap.c	Mon Nov 23 13:38:47 1998
> > @@ -167,15 +167,14 @@
> >  	case 1:
> >  		/* is it a swap-cache or page-cache page? */
> >  		if (page->inode) {
> > -			/* Throw swap-cache pages away more aggressively */
> > -			if (PageSwapCache(page)) {
> > -				delete_from_swap_cache(page);
> > -				return 1;
> > -			}
> >  			if (test_and_clear_bit(PG_referenced, &page->flags))
> >  				break;
> >  			if (pgcache_under_min())
> >  				break;
> > +			if (PageSwapCache(page)) {
> > +				delete_from_swap_cache(page);
> > +				return 1;
> > +			}
> 
> This piece looks good and will result in us keeping swap cached
> pages when the page cache is low. We might want to include this
> in the current kernel tree, together with the removal of the
> free_after construction.

Hmmm ... don't forget the change in __get_free_pages(). Without this
page I see random SIGBUS at extreme load killing random processes.

[...]

> Sorry Werner, but this is exactly the place where we need to
> remove any from of page aging. We can do some kind of aging
> in the swap cache, page cache and buffer cache, but doing
> aging here is just prohibitively expensive and needs to be
> removed.
> 
> IMHO a better construction be to have a page->fresh flag
> which would be set on unmapping from swap_out(). Then
> shrink_mmap() would free pages with page->fresh reset
> and reset page->fresh if it is set. This way we can
> free a page at it's second scan so we avoid freeing
> a page that was just unmapped (and giving each page a
> bit of a chance to undergo cheap aging).

Furthermore highly used pages should go not to often
into the swap cache ... this leads to something like
a score list of often used pages.  Such a score value
instead of a flag could be easily decreased by
shrink_mmap() scanning all pages.


          Werner
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
