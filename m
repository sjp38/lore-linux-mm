Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA24429
	for <linux-mm@kvack.org>; Mon, 6 Jul 1998 07:08:23 -0400
Date: Mon, 6 Jul 1998 11:24:25 +0100
Message-Id: <199807061024.LAA00796@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980705185219.1574D-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.96.980705131034.327C-100000@dragon.bogus>
	<Pine.LNX.3.96.980705185219.1574D-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 5 Jul 1998 19:00:04 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On Sun, 5 Jul 1998, Andrea Arcangeli wrote:
>> Where does the cache is allocated? Is it allocated in the inode? If so
>> kswapd should shrink the inode before start swapping out! 

> The cache is also mapped into a process'es address space.
> Currently we would have to walk all pagetables to find a
> specific page ;(

Not in this case, where the file is just being copied.  For a copy, the
reads exist unmapped in the page cache; only mmap() creates mapped
pages.


> When Stephen and Ben have merged their PTE stuff, we can
> do the freeing much easier though...

In this case, it's not an issue, so we need to fix it for 2.2.

>> I had to ask "2.0.34 has balancing code implemented and
>> running?". The

> 2.0 has no balancing code at all. At least, not AFAIK...

It does: the Duff's device in try_to_free_page does it, and seems to
work well enough.  It was certainly tuned tightly enough: all of the
hard part of getting the kswap stuff working well in try_to_swap_out()
was to do with tuning the aggressiveness of swap relative to the buffer
and cache reclaim mechanisms so that the try_to_free_page loop works
well.  That's why the recent policies of adding little rules here and
there all over the mm layer have disturbed the balance so much, I think.

>> Is there a function call (such us shrink_mmap for mmap or
>> kmem_cache_reap() for slab or shrink_dcache_memory() for dcache) that
>> is able to shrink the cache allocated by cp file /dev/zero?

> shrink_mmap() can only shrink unlocked and clean buffer pages
> and unmapped cache pages. We need to go through either bdflush
> (for buffer) or try_to_swap_out() first, in order to make some
> easy victims for shrink_mmap()...

Only for mapped files, not files copied through the standard read/write
calls.

--Stephen

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
