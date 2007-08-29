Message-ID: <46D4BA53.5070005@yahoo.com.au>
Date: Wed, 29 Aug 2007 10:14:11 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] : mm : / Patch / code : Suggestion :snip kswapd &get_page_from_freelist()
 : No more no page failures. (WHY????)
References: <000501c7e9b5$7f73db00$6501a8c0@earthlink.net>
In-Reply-To: <000501c7e9b5$7f73db00$6501a8c0@earthlink.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mitchell Erblich <erblichs@earthlink.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mitchell Erblich wrote:
> Nick Piggin wrote:

> --------
> Nick Piggin, et al,
> 
>     First diffs would generate alot of noise, since I rip and insert
>     alot of code based on whether I think the code is REALLY
>     needed for MY TEST environment. These suggestions are
>     basicly minimal merge suggestions between my
>     development envir and the public Linux tree.

That's OK. So long as the patch is against a well known tree, it
is just less ambiguous even if it doesn't actually compile :)


> 
>     Now the why for this SUGGESTION/PATCH...
> 
> 
>>When we're in the (min,low) watermark range, we'll wake up kswapd
>>_before_ allocating anything, so what is better about the change to
>>wake up kswapd after allocating? Can you perhaps come up with an
>>example situation also to make this more clear?
> 
> 
> Answer
>     Will GFP_ATOMIC alloc be failing at that point? If yes, then why
>     not allow kswapd attempt to prevent this condition from occuring?
>     The existing code reads that the first call to get_page_from_freelist()
>     has returned no page. Now you are going to start up something that
>     is at best going to take millisecs to start helping out. Won't it first
>     grab some pages to do its work? So we are going to be lower
>     in free memory right when it starts up. Right?

GFP_ATOMIC will not be failing at this point (also, kswapd could
probably have reclaimed several hundred or thousand pages in 1ms,
but that's besides the point -- we do have correct buffering here).

The watermarks go roughly like this:

high -- kswapd stops reclaiming
low  -- kswapd is started by any allocation, nothing else happens
min  -- non-GFP_ATOMIC can't go below this point; enter direct reclaim
min/X-- GFP_ATOMIC allocations fail below this point
0    -- PF_MEMALLOC fails.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
