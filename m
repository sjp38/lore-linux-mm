Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2CB106B005A
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 18:05:51 -0400 (EDT)
Date: Thu, 16 Jul 2009 00:04:45 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: Warn once when a page is freed with PG_mlocked set V2
Message-ID: <20090715220445.GA1823@cmpxchg.org>
References: <20090715125822.GB29749@csn.ul.ie> <alpine.DEB.1.10.0907151027410.23643@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0907151027410.23643@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Jiri Slaby <jirislaby@gmail.com>
List-ID: <linux-mm.kvack.org>

Hello Christoph,

On Wed, Jul 15, 2009 at 10:31:54AM -0400, Christoph Lameter wrote:
> On Wed, 15 Jul 2009, Mel Gorman wrote:
> 
> > -static inline int free_pages_check(struct page *page)
> > +static inline int free_pages_check(struct page *page, int wasMlocked)
> >  {
> > +	WARN_ONCE(wasMlocked, KERN_WARNING
> > +		"Page flag mlocked set for process %s at pfn:%05lx\n"
> > +		"page:%p flags:0x%lX\n",
> > +		current->comm, page_to_pfn(page),
> > +		page, page->flags|__PG_MLOCKED);
> > +
> >  	if (unlikely(page_mapcount(page) |
> 
> There is already a free_page_mlocked() that is only called if the mlock
> bit is set. Move it into there to avoid having to run two checks in the
> hot codee path?
> 
> Also __free_pages_ok() now has a TestClearMlocked in the hot code path.
> Would it be possible to get rid of the unconditional use of an atomic
> operation? Just check the bit and clear it later in free_page_mlocked()?

That was initially done, but free_pages_check() checks for that flag
and did bad_page() on those mlocked ones.  Now, one idea was to not
check the mlocked flag at all in free_pages_check() as we handle it
differently anyway.  But I think we might still want to check for it
in tail-pages of higher order blocks.

And if you move that warning after free_pages_check(), the interesting
bits for the warning have been wiped already.

But we can get rid of the locked test-and-clear despite all the other
issues, patch below.

	Hannes
