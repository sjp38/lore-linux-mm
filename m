Message-ID: <41131322.2090006@yahoo.com.au>
Date: Fri, 06 Aug 2004 15:12:02 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] 1/4: rework alloc_pages
References: <41130FB1.5020001@yahoo.com.au>
In-Reply-To: <41130FB1.5020001@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Here are a few of the more harmless mm patches I have been sitting on
> for a while. They've had some testing in my tree (which does get used
> by a handful of people).
> 
> 
> ------------------------------------------------------------------------
> 
> 
> This reworks alloc_pages a bit.
> 
> Previously the ->protection[] logic was broken. It was difficult to follow
> and basically didn't use the asynch reclaim watermarks properly.
> 
> This one uses ->protection only for lower-zone protection, and gives the
> allocator flexibility to add the watermarks as desired.
> 

Note that this patch strictly enforces the lower zone protection (which is
currently disabled anyway) instead of allowing GFP_ATOMIC allocations to
get at them.

It also does a few minor things like not taking rt_task into account during
the first loop (because the kswapd reclaim watermarks shouldn't depend on
that), and also only checking rt_task if !in_interrupt.

The biggest thing it does is use the kswapd watermarks correctly - and I've
generally observed lower allocstall, and kswapd being more productive.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
