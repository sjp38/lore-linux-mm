Message-ID: <413BB55B.9000106@yahoo.com.au>
Date: Mon, 06 Sep 2004 10:54:51 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/3] beat kswapd with the proverbial clue-bat
References: <413AA7B2.4000907@yahoo.com.au> <Pine.LNX.4.58.0409050911450.2331@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0409050911450.2331@ppc970.osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:

>
>On Sun, 5 Sep 2004, Nick Piggin wrote:
>
>>So my solution? Just teach kswapd and the watermark code about higher
>>order allocations in a fairly simple way. If pages_low is (say), 1024KB,
>>we now also require 512KB of order-1 and above pages, 256K of order-2
>>and up, 128K of order 3, etc. (perhaps we should stop at about order-3?)
>>
>
>I'm pretty sure we did something like this (where we not only required a
>certain amount of memory free, but also a certain buddy availability) for
>a short while in the 2.3.x timeframe or something like that, and that it
>caused problems for some machines that just kept on trying to free memory.
>
>

OK. As I explained in a follow up, my paragraph you quoted was a bit
confused. We don't try to keep any higher order allocations free by
checking the watermarks unless we're trying to make an allocation of
that order in the first place.

So if order 0 allocations are the only thing that ever get done, then
everything proceeds as before. If we do an order 1 allocation, we'll
only kick kswapd if we're low on memory that can satisfy order 1 allocs.

So it is only ever going to free pages when they really are being requested.
Also, if the required memory just can't be freed, kswapd will give up and
forget about it (ie. kswapd_max_order = 0;)

>I wrote a program at the time to check why, but I've long since lost it, 
>so I re-created it just now (probably buggy as hell), and append it here 
>for you to debug the dang thing.
>
>In it's first rough draft (ie "it might be totally wrong") using this 
>script:
>
>

It looks correct to me. It does give a good argument for defragmentation.
But that is a bit orthogonal to what my patches do: they make kswapd work
properly to free higher order memory. The current alternatives are to do
the exact same work (lots of scanning) in allocator context, or fail the
allocation.

If someone wants to make that work, "lots of scanning" into "a bit of
defragmenting", great.

>
>Now, this test-result is not "real life", in that the whole point of the 
>buddy allocator is that it is good at trying to keep higher orders free, 
>and as such real life should behave much better. But this _is_ pretty 
>accurate for the case where we totally ran out of memory and are trying
>to randomly free one page here and one page there. That's where buddy 
>doesn't much help us, so this kind of shows the worst case.
>
>(Rule: you should not allow the machine to get to this point, exactly 
>because at the < ~5% free point, buddy stops being very effective).
>
>Notice how you may need to free 20% of memory to get a 2**3 allocation, if 
>you have totally depleted your pages. And it's much worse if you have very 
>little memory to begin with.
>
>Anyway. I haven't debugged this program, so it may have serious bugs, and 
>be off by an order of magnitude or two. Whatever. If I'm wrong, somebody 
>can fix the program/script and see what the real numbers are.
>
>

No, Andrew just recently reported that order-1 allocations were needing to
free 20MB or more (on systems with not really huge memories IIRC). So I
think your program could be reasonably close to real life.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
