Date: Mon, 27 Aug 2007 14:04:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] alloc_pages(): permit get_zeroed_page(GFP_ATOMIC)
 from interrupt context
Message-Id: <20070827140440.d2109ea5.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0708271357220.6435@schroedinger.engr.sgi.com>
References: <200708232107.l7NL7XDt026979@imap1.linux-foundation.org>
	<Pine.LNX.4.64.0708271308380.5457@schroedinger.engr.sgi.com>
	<20070827133347.424f83a6.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271357220.6435@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, thomas.jarosch@intra2net.com
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007 14:00:04 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 27 Aug 2007, Andrew Morton wrote:
> 
> > > > I think it makes sense to permit a non-BUGging get_zeroed_page(GFP_ATOMIC)
> > > > from interrupt context.
> > > 
> > > AFAIK this works now. GFP_ATOMIC does not set __GFP_HIGHMEM and thus the 
> > > check
> > > 
> > > 	VM_BUG_ON((gfp_flags & __GFP_HIGHMEM) && in_interrupt());
> > > 
> > > does not trigger
> > 
> > The crash happens in
> > 
> > 	clear_highpage
> > 	->kmap_atomic
> > 	  ->kmap_atomic_prot
> > 	    ->BUG_ON(!pte_none(*(kmap_pte-idx)));
> > 
> > ie: this CPU held a kmap slot when the interrupt happened.
> 
> I guess I do not get what the problem is then. AFAIK: You cannot get there 
> if you do a get_zeroed_page(GFP_ATOMIC). We should have bugged in 
> get_zeroed_page() before we even got to clear_highpage.
> 

: static inline void prep_zero_page(struct page *page, int order, gfp_t gfp_flags)
: {
: 	int i;
: 
: 	VM_BUG_ON((gfp_flags & (__GFP_WAIT | __GFP_HIGHMEM)) == __GFP_HIGHMEM);

__GFP_HIGHMEM is not set.

: 	/*
: 	 * clear_highpage() will use KM_USER0, so it's a bug to use __GFP_ZERO
: 	 * and __GFP_HIGHMEM from hard or soft interrupt context.
: 	 */
: 	VM_BUG_ON((gfp_flags & __GFP_HIGHMEM) && in_interrupt());

__GFP_HIGHMEM is not set

: 	for (i = 0; i < (1 << order); i++)
: 		clear_highpage(page + i);

kmap_atomic() goes boom.

: }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
