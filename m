Message-ID: <41918715.1080008@cyberone.com.au>
Date: Wed, 10 Nov 2004 14:12:21 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
References: <20041109164642.GE7632@logos.cnet>	<20041109121945.7f35d104.akpm@osdl.org>	<20041109174125.GF7632@logos.cnet>	<20041109133343.0b34896d.akpm@osdl.org>	<20041109182622.GA8300@logos.cnet>	<20041109142257.1d1411e1.akpm@osdl.org>	<4191675B.3090903@cyberone.com.au>	<419181D5.1090308@cyberone.com.au> <20041109185640.32c8871b.akpm@osdl.org>
In-Reply-To: <20041109185640.32c8871b.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Nick Piggin <piggin@cyberone.com.au> wrote:
>
>>Shall we crank up min_free_kbytes a bit?
>>
>
>May as well.  or we could do something fancy in register_netdevice().
>
>

OK. If you look at my tables, in practice 2.6.8 will actually be
keeping more memory free anyway, in the form of ZONE_DMA free. So
we could quadruple min_free_kbytes, *but* 2.6.10's kswapd will
then free a lot further than 2.6.8.

So I'd advocate doubling min_free_kbytes, *and* squashing watermarks
together.


>> We could also compress the watermarks, while increasing pages_min? That
>> will increase the GFP_ATOMIC buffer as well, without having free memory
>> run away on us (eg pages_min = 2*x, pages_low = 5*x/2, pages_high = 3*x)?
>>
>
>There are also hidden intermediate levels for rt-policy tasks.
>
>
>

Yep, they all get keyed off pages_min - so if we just double pages_min,
we're effectively doubling that GFP_ATOMIC buffer and the rt_task
buffer(*), while halving the asynch reclaim marks (pages_low and
pages_high).

Now combine that with doubling min_free_kbytes, and we have our
quadrupled GFP_ATOMIC buffer, restoring parity with 2.6.8, while also
keeping the asynch reclaim marks in the same place. Make sense?

(*) The rt_task buffer was broken in 2.6.8 anyway because rt tasks could
allocate far more than GFP_ATOMIC allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
