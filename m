Message-ID: <40CFCF64.9010406@yahoo.com.au>
Date: Wed, 16 Jun 2004 14:41:08 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Keeping mmap'ed files in core regression in 2.6.7-rc
References: <20040608142918.GA7311@traveler.cistron.net>	<40CAA904.8080305@yahoo.com.au>	<20040614140642.GE13422@traveler.cistron.net>	<40CE66EE.8090903@yahoo.com.au>	<20040615143159.GQ19271@traveler.cistron.net>	<40CFBB75.1010702@yahoo.com.au>	<20040615205017.15dd1f1d.akpm@osdl.org>	<40CFC67D.6020205@yahoo.com.au> <20040615212336.17d0a396.akpm@osdl.org>
In-Reply-To: <20040615212336.17d0a396.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: miquels@cistron.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>>shrink_zone() will free arbitrarily large amounts of memory as the scanning
>>>priority increases.  Probably it shouldn't.
>>>
>>>
>>
>>Especially for kswapd, I think, because it can end up fighting with
>>memory allocators and think it is getting into trouble. It should
>>probably rather just keep putting along quietly.
>>
>>I have a few experimental patches that magnify this problem, so I'll
>>be looking at fixing it soon. The tricky part will be trying to
>>maintain a similar prev_priority / temp_priority balance.
> 
> 
> hm, I don't see why.  Why not simply bale from shrink_listing as soon as
> we've reclaimed SWAP_CLUSTER_MAX pages?
> 

Oh yeah, that would be the way to go about it. Your patch looks
alright as a platform to do achieve this.

> I got bored of shrink_zone() bugs and rewrote it again yesterday.  Haven't
> tested it much.  I really hate struct scan_control btw ;)
> 

Well I can keep it local here. I have some stuff which requires more
things to be passed up and down the call chains which gets annoying
passing lots of things by reference.

> 
> 
> 
> We've been futzing with the scan rates of the inactive and active lists far
> too much, and it's still not right (Anton reports interrupt-off times of over
> a second).
> 
> - We have this logic in there from 2.4.early (at least) which tries to keep
>   the inactive list 1/3rd the size of the active list.  Or something.
> 
>   I really cannot see any logic behind this, so toss it out and change the
>   arithmetic in there so that all pages on both lists have equal scan rates.
> 

I think it is somewhat to do with use-once logic. If your inactive list
remains full of use-once pages, you can happily scan them while putting
minimal pressure on the active list.

I don't think we need to try to keep it *at least* 1/3rd the size anymore.
 From distant memory, that may have been when the inactive list was more
of a "writeout queue". I don't know though, it might still be useful.

> - Chunk the work up so we never hold interrupts off for more that 32 pages
>   worth of scanning.
> 

Yeah this was a bit silly. Good fix.

> - Make the per-zone scan-count accumulators unsigned long rather than
>   atomic_t.
> 
>   Mainly because atomic_t's could conceivably overflow, but also because
>   access to these counters is racy-by-design anyway.
> 

Seems OK other than my one possible issue.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
