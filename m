Date: Thu, 12 Jul 2007 01:00:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: unlockless reclaim
Message-Id: <20070712010007.164acc8e.akpm@linux-foundation.org>
In-Reply-To: <20070712075532.GB1830@wotan.suse.de>
References: <20070712041115.GH32414@wotan.suse.de>
	<20070712004339.0f5b7a2f.akpm@linux-foundation.org>
	<20070712075532.GB1830@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jul 2007 09:55:32 +0200 Nick Piggin <npiggin@suse.de> wrote:

> On Thu, Jul 12, 2007 at 12:43:39AM -0700, Andrew Morton wrote:
> > On Thu, 12 Jul 2007 06:11:15 +0200 Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > unlock_page is pretty expensive. Even after my patches to optimise the
> > > memory order and away the waitqueue hit for uncontended pages, it is
> > > still a locked operation, which may be anywhere up to hundreds of cycles
> > > on some CPUs.
> > > 
> > > When we reclaim a page, we don't need to "unlock" it as such, because
> > > we know there will be no contention (if there was, it would be a bug
> > > because the page is just about to get freed).
> > > 
> > > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > > 
> > > Index: linux-2.6/include/linux/page-flags.h
> > > ===================================================================
> > > --- linux-2.6.orig/include/linux/page-flags.h
> > > +++ linux-2.6/include/linux/page-flags.h
> > > @@ -115,6 +115,8 @@
> > >  		test_and_set_bit(PG_locked, &(page)->flags)
> > >  #define ClearPageLocked(page)		\
> > >  		clear_bit(PG_locked, &(page)->flags)
> > > +#define __ClearPageLocked(page)		\
> > > +		__clear_bit(PG_locked, &(page)->flags)
> > >  #define TestClearPageLocked(page)	\
> > >  		test_and_clear_bit(PG_locked, &(page)->flags)
> > >  
> > > Index: linux-2.6/mm/vmscan.c
> > > ===================================================================
> > > --- linux-2.6.orig/mm/vmscan.c
> > > +++ linux-2.6/mm/vmscan.c
> > > @@ -576,7 +576,7 @@ static unsigned long shrink_page_list(st
> > >  			goto keep_locked;
> > >  
> > >  free_it:
> > > -		unlock_page(page);
> > > +		__ClearPageLocked(page);
> > >  		nr_reclaimed++;
> > >  		if (!pagevec_add(&freed_pvec, page))
> > >  			__pagevec_release_nonlru(&freed_pvec);
> > 
> > mutter.
> > 
> > So why does __pagevec_release_nonlru() check the page refcount?
> 
> It doesn't

yes it does

> although it will have to return the count to zero of course.
> 
> I don't want to submit that because the lockless pagecache always needs
> the refcount to be checked :) And which I am actually going to submit to
> you after you chuck out a few patches.
> 
> But unlock_page is really murderous on my powerpc (with all the
> unlock-speeup patches, dd if=/dev/zero of=/dev/null of a huge sparse file
> goes up by 10% throughput on the G5!!).

well this change won't help that much.

mutter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
