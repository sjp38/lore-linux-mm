Message-ID: <418AE202.20903@yahoo.com.au>
Date: Fri, 05 Nov 2004 13:14:26 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] higher order watermarks
References: <417F5584.2070400@yahoo.com.au> <417F55B9.7090306@yahoo.com.au> <417F5604.3000908@yahoo.com.au> <20041104085745.GA7186@logos.cnet> <418A1EA6.70500@yahoo.com.au> <20041104095545.GA7902@logos.cnet> <418AD20D.4000201@yahoo.com.au> <20041104224751.GA13679@logos.cnet>
In-Reply-To: <20041104224751.GA13679@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> On Fri, Nov 05, 2004 at 12:06:21PM +1100, Nick Piggin wrote:
> 

>>Yeah it's wrong, of course. Good catch, thanks.
>>
>>If you would care to send a patch Marcelo? I don't have a recent
>>-mm on hand at the moment. Would that be alright?
> 
> 
> Sure, I'll prepare a patch. 
> 
> This typo probably means that the current code is not actually working as 
> intented - did any of you receive any feedback on this patch, wrt high order allocation
> intensive driver setup/workload, Nick and Andrew? 
> 

I had tested it and it did do the right thing when fragmentation meant
higer order memory was completely depleted - previously atomic allocations
would just stop working, but the patches got them going again.

I did have one guy who tested the patches in a production sort of system
that was getting some allocation failures. He said they didn't make much
difference (increasing min_free_kbytes was effective).

So hopefully this should make things work better.

What would happen without the patch, is that if you had 0 order-2 pages free
and wanted to make an order-2 allocation, free_pages would never get
decremented, so it wouldn't detect the shortage.

> I have been using a simple module which allocates a big number of high order
> allocations in a row (for the defragmentation code testing), I'll give it a
> shot tomorrow to test Nick's high-order-kswapd scheme effectiveness. 
> 
> Anyway, here is the patch:
> 

ACK. Thanks.

> Description:
> Fix typo in Nick's kswapd-high-order awareness patch
> 
> --- linux-2.6.10-rc1-mm2/mm/page_alloc.c.orig	2004-11-04 22:52:00.505365136 -0200
> +++ linux-2.6.10-rc1-mm2/mm/page_alloc.c	2004-11-04 22:52:03.121967352 -0200
> @@ -733,7 +733,7 @@
>  		return 0;
>  	for (o = 0; o < order; o++) {
>  		/* At the next order, this order's pages become unavailable */
> -		free_pages -= z->free_area[order].nr_free << o;
> +		free_pages -= z->free_area[o].nr_free << o;
>  
>  		/* Require fewer higher order pages to be free */
>  		min >>= 1;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
