Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 82AAB6B0044
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 21:57:11 -0500 (EST)
Date: Fri, 16 Jan 2009 03:57:08 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix assertion
Message-ID: <20090116025708.GJ17810@wotan.suse.de>
References: <20090114062816.GA15671@wotan.suse.de> <Pine.LNX.4.64.0901151132320.22151@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0901151132320.22151@quilx.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 15, 2009 at 11:35:45AM -0600, Christoph Lameter wrote:
> You still have a
> 
>   VM_BUG_ON(PageTail(page));
> 
> in page_cache_get_speculative() which will verify that the
> successfully acquired speculative reference is not a compound tail.

Good point.
 
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

Thanks

> 
> On Wed, 14 Jan 2009, Nick Piggin wrote:
> 
> > (I ran into this when debugging the lockless pagecache barrier problem btw)
> >
> > --
> >
> > This assertion is incorrect for lockless pagecache. By definition if we have an
> > unpinned page that we are trying to take a speculative reference to, it may
> > become the tail of a compound page at any time (if it is freed, then reallocated
> > as a compound page).
> >
> > It was still a valid assertion for the vmscan.c LRU isolation case, but it
> > doesn't seem incredibly helpful... if somebody wants it, they can put it back
> > directly where it applies in the vmscan code.
> >
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > ---
> > Index: linux-2.6/include/linux/mm.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/mm.h	2009-01-05 14:53:29.000000000 +1100
> > +++ linux-2.6/include/linux/mm.h	2009-01-05 14:53:54.000000000 +1100
> > @@ -270,7 +270,6 @@ static inline int put_page_testzero(stru
> >   */
> >  static inline int get_page_unless_zero(struct page *page)
> >  {
> > -	VM_BUG_ON(PageTail(page));
> >  	return atomic_inc_not_zero(&page->_count);
> >  }
> >
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
