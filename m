Date: Thu, 4 Nov 2004 20:47:51 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 2/3] higher order watermarks
Message-ID: <20041104224751.GA13679@logos.cnet>
References: <417F5584.2070400@yahoo.com.au> <417F55B9.7090306@yahoo.com.au> <417F5604.3000908@yahoo.com.au> <20041104085745.GA7186@logos.cnet> <418A1EA6.70500@yahoo.com.au> <20041104095545.GA7902@logos.cnet> <418AD20D.4000201@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <418AD20D.4000201@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 05, 2004 at 12:06:21PM +1100, Nick Piggin wrote:
> Marcelo Tosatti wrote:
> >Hi Nick!
> >
> >On Thu, Nov 04, 2004 at 11:20:54PM +1100, Nick Piggin wrote:
> >
> 
> >>So now what we need to do in order to calculate, say the amount of memory
> >>that will satisfy order-2 *and above* (this is important) is the 
> >>following:
> >>
> >>	z->free_pages - (order[0].nr_free << 0) - (order[1].nr_free << 1)
> >
> >
> >Shouldnt that be then
> >
> >free_pages -= z->free_area[o].nr_free << o;
> >
> >instead of the current 
> >
> >free_pages -= z->free_area[order].nr_free << o;
> >
> >No?
> >
> 
> Yes, you're absolutely right. Sorry, this is what you were getting
> at all along :P
> 
> >
> >>to find order-3 and above, you also need to subtract (order[2].nr_free << 
> >>2).
> >>
> >>I quite liked this method because it has progressively less cost on lower
> >>order allocations, and for order-0 we don't need to do any calculation.
> >
> >
> >OK, now I get it. The only think which bugs me is the multiplication of 
> >values with different meanings.
> >
> 
> Yeah it's wrong, of course. Good catch, thanks.
> 
> If you would care to send a patch Marcelo? I don't have a recent
> -mm on hand at the moment. Would that be alright?

Sure, I'll prepare a patch. 

This typo probably means that the current code is not actually working as 
intented - did any of you receive any feedback on this patch, wrt high order allocation
intensive driver setup/workload, Nick and Andrew? 

I have been using a simple module which allocates a big number of high order
allocations in a row (for the defragmentation code testing), I'll give it a
shot tomorrow to test Nick's high-order-kswapd scheme effectiveness. 

Anyway, here is the patch:

Description:
Fix typo in Nick's kswapd-high-order awareness patch

--- linux-2.6.10-rc1-mm2/mm/page_alloc.c.orig	2004-11-04 22:52:00.505365136 -0200
+++ linux-2.6.10-rc1-mm2/mm/page_alloc.c	2004-11-04 22:52:03.121967352 -0200
@@ -733,7 +733,7 @@
 		return 0;
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
-		free_pages -= z->free_area[order].nr_free << o;
+		free_pages -= z->free_area[o].nr_free << o;
 
 		/* Require fewer higher order pages to be free */
 		min >>= 1;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
