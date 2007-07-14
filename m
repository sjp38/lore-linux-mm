Date: Sat, 14 Jul 2007 10:35:39 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: unlockless reclaim
Message-ID: <20070714083539.GD1198@wotan.suse.de>
References: <20070712041115.GH32414@wotan.suse.de> <20070712122039.2702724f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070712122039.2702724f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 12, 2007 at 12:20:39PM -0700, Andrew Morton wrote:
> On Thu, 12 Jul 2007 06:11:15 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > unlock_page is pretty expensive. Even after my patches to optimise the
> > memory order and away the waitqueue hit for uncontended pages, it is
> > still a locked operation, which may be anywhere up to hundreds of cycles
> > on some CPUs.
> > 
> > When we reclaim a page, we don't need to "unlock" it as such, because
> > we know there will be no contention (if there was, it would be a bug
> > because the page is just about to get freed).
> > 
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > 
> > Index: linux-2.6/include/linux/page-flags.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/page-flags.h
> > +++ linux-2.6/include/linux/page-flags.h
> > @@ -115,6 +115,8 @@
> >  		test_and_set_bit(PG_locked, &(page)->flags)
> >  #define ClearPageLocked(page)		\
> >  		clear_bit(PG_locked, &(page)->flags)
> > +#define __ClearPageLocked(page)		\
> > +		__clear_bit(PG_locked, &(page)->flags)
> >  #define TestClearPageLocked(page)	\
> >  		test_and_clear_bit(PG_locked, &(page)->flags)
> >  
> > Index: linux-2.6/mm/vmscan.c
> > ===================================================================
> > --- linux-2.6.orig/mm/vmscan.c
> > +++ linux-2.6/mm/vmscan.c
> > @@ -576,7 +576,7 @@ static unsigned long shrink_page_list(st
> >  			goto keep_locked;
> >  
> >  free_it:
> > -		unlock_page(page);
> > +		__ClearPageLocked(page);
> >  		nr_reclaimed++;
> >  		if (!pagevec_add(&freed_pvec, page))
> >  			__pagevec_release_nonlru(&freed_pvec);
> 
> I really hate this patch :(  For the usual reasons.
> 
> I'd have thought that such a terrifying point-cannon-at-someone-else's-foot
> hack would at least merit a comment explaining (fully) to the reader why it
> is a safe thing to do at this site.

OK, comments are fair enough although we already do similar things
to clear other flags here and in the page allocator path itself so
I thought it was already deemed kosher. I'll add some in a next
iteration.

 
> And explaining to them why __pagevec_release_nonlru() immediately
> contradicts the assumption which this code is making.

Again fair enough. I'll send it sometime when you've got less mm
stuff in your tree I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
