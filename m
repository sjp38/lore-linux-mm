Message-ID: <419181D5.1090308@cyberone.com.au>
Date: Wed, 10 Nov 2004 13:49:57 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
References: <20041109164642.GE7632@logos.cnet>	<20041109121945.7f35d104.akpm@osdl.org>	<20041109174125.GF7632@logos.cnet>	<20041109133343.0b34896d.akpm@osdl.org>	<20041109182622.GA8300@logos.cnet> <20041109142257.1d1411e1.akpm@osdl.org> <4191675B.3090903@cyberone.com.au>
In-Reply-To: <4191675B.3090903@cyberone.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Nick Piggin wrote:

>
> (*) I'm beginning to think they're due to me accidentally bumping the
>    page watermarks when 'fixing' them. I'll check that out presently.
>
>
That's basically it...

2.6.8 and 2.6.10-rc both have the same watermarks (in pages):

-----------
 From SysRq+M:

       pages_min   pages_low   pages_high
dma        4          8          12
normal   234        468         702
high     128        256         384

However, 2.6.10-rc has all 0's in its ->protection maps, 2.6.8 looks like:
       gfp_dma     gfp_normal  gfp_high
dma        8         476         732
normal     0         468         724
high       0         0           256

Because 2.6.8 basically keys the entire alloc_pages behaviour off the
->protection map (and look: the diagonal corresponds to pages_low for
each zone).
-----------


Following is the minimum free pages for each zone at which some action
will happen for order-0 (ZONE_NORMAL) allocations:

2.6.8
                             | GFP_KERNEL        | GFP_ATOMIC
allocate immediately         | 477 dma, 469 norm | 12 dma, 469 norm
allocate after waking kswapd | 477 dma, 469 norm | 12 dma, 352 norm
allocate after synch reclaim | 477 dma, 469 norm | n/a

2.6.10-rc
                             | GFP_KERNEL        | GFP_ATOMIC
allocate immediately         |   9 dma, 469 norm |  9 dma, 469 norm
allocate after waking kswapd |   5 dma, 234 norm |  3 dma,  88 norm
allocate after synch reclaim |   5 dma, 234 norm |  n/a

So the buffer between GFP_KERNEL and GFP_ATOMIC allocations is:

2.6.8      | 465 dma, 117 norm, 582 tot = 2328K
2.6.10-rc  |   2 dma, 146 norm, 148 tot =  592K

Although you can see that, theoretically 2.6.10 has a much better layout
of numbers, and an increased ZONE_NORMAL buffer, 2.6.8's weird ZONE_DMA
handling gives it 4 times the amount of buffer between GFP_KERNEL and
GFP_ATOMIC allocations.

Shall we crank up min_free_kbytes a bit?

We could also compress the watermarks, while increasing pages_min? That
will increase the GFP_ATOMIC buffer as well, without having free memory
run away on us (eg pages_min = 2*x, pages_low = 5*x/2, pages_high = 3*x)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
