Date: Fri, 6 Aug 2004 08:01:43 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] 1/4: rework alloc_pages
In-Reply-To: <41131FA6.4070402@yahoo.com.au>
Message-ID: <Pine.LNX.4.44.0408060759550.8229-100000@dhcp83-102.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Aug 2004, Nick Piggin wrote:

> 	for_each_zone(z) {
> 		if (z->free_pages < z->pages_low + z->protection)
> 			continue;
> 		else
> 			goto got_pg;
> 	}
> 
> 	for_each_zone(z)
> 		wakeup_kswapd(z);

Note that since kswapd does NOT take z->protection into account,
you could end up doing too much asynchronous page recycling from
the highmem zone while having stale pages sitting around in the
normal zone.

As long as we have the lowmem protection switched off by default
we should be fine, though.  Either that, or wakeup_kswapd should
tell kswapd what the threshold is ...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
