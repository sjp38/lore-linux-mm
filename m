Message-ID: <41131FA6.4070402@yahoo.com.au>
Date: Fri, 06 Aug 2004 16:05:26 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] 1/4: rework alloc_pages
References: <41130FB1.5020001@yahoo.com.au>	<20040805221958.49049229.akpm@osdl.org>	<41131732.7060606@yahoo.com.au> <20040805223725.246b0950.akpm@osdl.org>
In-Reply-To: <20040805223725.246b0950.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>Andrew Morton wrote:
>>
>>>Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>>>
>>>
>>>>Previously the ->protection[] logic was broken. It was difficult to follow
>>>>and basically didn't use the asynch reclaim watermarks properly.
>>>
>>>
>>>eh?
>>>
>>>Broken how?
>>>
>>
>>min = (1<<order) + z->protection[alloc_type];
>>
>>This value is used both as the condition for waking kswapd, and
>>whether or not to enter synch reclaim.
>>
>>What should happen is kswapd gets woken at pages_low, and synch
>>reclaim is started at pages_min.
> 
> 
> Are you aware of this:
> 
> void wakeup_kswapd(struct zone *zone)
> {
> 	if (zone->free_pages > zone->pages_low)
> 		return;
> 
> ?
> 

Err, yes?

> 
>>pages_low + protection and pages_min + protection, etc.
> 
> 
> Nick, sorry, but I shouldn't have to expend these many braincells
> decrypting your work.  Please: much better explanations, more testing
> results.  This stuff is fiddly, sensitive and has a habit of blowing up in
> our faces weeks later.  We need to be cautious.  The barriers are higher
> nowadays.
> 
> 

OK previously, in a nutshell:

	for_each_zone(z) {
		if (z->free_pages < z->protection)
			continue;
		else
			goto got_pg;
	}

	for_each_zone(z)
		wakeup_kswapd(z);

	for_each_zone(z) {
		if (z->free_pages < z->protection)
			continue;
		else
			goto got_pg;
	}

	try_to_free_pages();

	try again;

After my patch:
	for_each_zone(z) {
		if (z->free_pages < z->pages_low + z->protection)
			continue;
		else
			goto got_pg;
	}

	for_each_zone(z)
		wakeup_kswapd(z);

	for_each_zone(z) {
		if (z->free_pages < z->pages_min + z->protection)
			continue;
		else
			goto got_pg;
	}

	try_to_free_pages();

	try again;

Ie, we have the (pages_low - pages_min) buffer after waking kswapd
before entering synch reclaim. Previously there was no buffer. I thought
this was the point of background reclaim. I don't know if I can explain
it any better than that sorry.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
