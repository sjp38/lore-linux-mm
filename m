Message-ID: <416106BB.9090908@cyberone.com.au>
Date: Mon, 04 Oct 2004 18:15:55 +1000
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
References: <20041001182221.GA3191@logos.cnet> <415E12A9.7000507@cyberone.com.au> <20041002030857.GB4635@logos.cnet>
In-Reply-To: <20041002030857.GB4635@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, arjanv@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Marcelo Tosatti wrote:

>On Sat, Oct 02, 2004 at 12:30:01PM +1000, Nick Piggin wrote:
>
>>
>>Marcelo Tosatti wrote:
>>
>>
>>>With such a thing in place we can build a mechanism for kswapd 
>>>(or a separate kernel thread, if needed) to notice when we are low on 
>>>high order pages, and use the coalescing algorithm instead blindly 
>>>freeing unique pages from LRU in the hope to build large physically 
>>>contiguous memory areas.
>>>
>>>Comments appreciated.
>>>
>>>
>>>
>>Hi Marcelo,
>>Seems like a good idea... even with regular dumb kswapd "merging",
>>you may easily get stuck for example on systems without swap...
>>
>>Anyway, I'd like to get those beat kswapd patches in first. Then
>>your mechanism just becomes something like:
>>
>>   if order-0 pages are low {
>>       try to free memory
>>   }
>>   else if order-1 or higher pages are low {
>>        try to coalesce_memory
>>        if that fails, try to free memory
>>   }
>>
>
>Hi Nick!
>
>

Sorry, I'd been away for the weekend which is why I didn't get a
chance to reply to you.

>I understand that kswapd is broken, and it needs to go into the page reclaim path 
>to free pages when we are out of high order pages (what your 
>"beat kswapd" patches do and fix high-order failures by doing so), but 
>Linus's argument against it seems to be that "it potentially frees too much pages" 
>causing harm to the system. He also says this has been tried in the past, 
>with not nice results.
>
>

Not quite. I think a (the) big thing with my patch is that it will
check order-0...n watermarks when an order-n allocation is made.

So if there is no order >2 allocations happening, it won't attempt
to keep higher order memory available (until someone attempts an
allocation).

Basically, it gets kswapd doing the work when it would otherwise
have to be done in direct reclaim, *OR* otherwise indefinitely fail
if the allocations aren't blockable.

>And that is why its has not been merged into mainline.
>
>Is my interpretation correct?
>
>But right, kswapd needs to get fixed to honour high order
>pages.
>
>

Well Linus was silent on the issue after I answered his concerns.
I mailed him privately and he basically said that it seems sane,
and he is waiting for patches. Of course, by that stage it was
fairly late into 2.6.9, and the current behaviour isn't a regression,
so I'm shooting for 2.6.10.

Your defragmentor should sit very nicely on top of it, of course.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
