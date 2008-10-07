Date: Tue, 7 Oct 2008 10:57:33 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [BUG] SLOB's krealloc() seems bust
In-Reply-To: <1223397455.13453.385.camel@calx>
Message-ID: <alpine.LFD.2.00.0810071053540.3208@nehalem.linux-foundation.org>
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>  <48EB6D2C.30806@linux-foundation.org>  <1223391655.13453.344.camel@calx>  <1223395846.26330.55.camel@lappy.programming.kicks-ass.net> <1223397455.13453.385.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linuxfoundation.org>, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>


On Tue, 7 Oct 2008, Matt Mackall wrote:
>
> Thanks, Peter. I know we're way late in the 2.6.27 cycle, so I'll leave
> it to Linus and Andrew to decide how to queue this up.

Well, since it seems to be clearly broken without it, I'd take it, but now 
I'm kind of waiting for the resolution on whether that second "-1" is 
correct or not.

>From a quick look at mm/slob.c I see Pekka's point that ->units does look 
like the real size in units, not the "size plus header", and that the 
second -1 may be bogus.

But I don't know the code.

Peter - can you check with that

>  	if (slob_page(sp))
> -		return ((slob_t *)block - 1)->units + SLOB_UNIT;
> +		return (((slob_t *)block - 1)->units - 1) * SLOB_UNIT;

thing using

-		return ((slob_t *)block - 1)->units + SLOB_UNIT;
+		return ((slob_t *)block - 1)->units * SLOB_UNIT;

instead? 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
