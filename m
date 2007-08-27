Date: Mon, 27 Aug 2007 14:00:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/1] alloc_pages(): permit get_zeroed_page(GFP_ATOMIC)
 from interrupt context
In-Reply-To: <20070827133347.424f83a6.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708271357220.6435@schroedinger.engr.sgi.com>
References: <200708232107.l7NL7XDt026979@imap1.linux-foundation.org>
 <Pine.LNX.4.64.0708271308380.5457@schroedinger.engr.sgi.com>
 <20070827133347.424f83a6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, thomas.jarosch@intra2net.com
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007, Andrew Morton wrote:

> > > I think it makes sense to permit a non-BUGging get_zeroed_page(GFP_ATOMIC)
> > > from interrupt context.
> > 
> > AFAIK this works now. GFP_ATOMIC does not set __GFP_HIGHMEM and thus the 
> > check
> > 
> > 	VM_BUG_ON((gfp_flags & __GFP_HIGHMEM) && in_interrupt());
> > 
> > does not trigger
> 
> The crash happens in
> 
> 	clear_highpage
> 	->kmap_atomic
> 	  ->kmap_atomic_prot
> 	    ->BUG_ON(!pte_none(*(kmap_pte-idx)));
> 
> ie: this CPU held a kmap slot when the interrupt happened.

I guess I do not get what the problem is then. AFAIK: You cannot get there 
if you do a get_zeroed_page(GFP_ATOMIC). We should have bugged in 
get_zeroed_page() before we even got to clear_highpage.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
