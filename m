Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA28885
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 16:03:06 -0500
Date: Wed, 25 Nov 1998 21:02:56 GMT
Message-Id: <199811252102.VAA05466@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <Pine.LNX.3.96.981125173723.11080C-100000@mirkwood.dummy.home>
References: <199811251446.OAA01094@dax.scot.redhat.com>
	<Pine.LNX.3.96.981125173723.11080C-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, jfm2@club-internet.fr, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 25 Nov 1998 17:47:18 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

>> WRONG.  We can very very easily unlink pages from a process's pte
>> (hence reducing the process's RSS) without removing that page from
>> memory.  It's trivial.  We do it all the time.  Rik, you should
>> probably try to work out how try_to_swap_out() actually works one of
>> these days.

> I just looked in mm/vmscan.c of kernel version 2.1.129, and
> line 173, 191 and 205 feature a prominent:
> 			free_page_and_swap_cache(page);

It is not there in 2.1.130-pre3, however. :) That misses the point,
though.  The point is that it is trivial to remove these mappings
without freeing the swap cache, and the code you point to confirms this:
vmscan actually has to go to _extra_ trouble to free the underlying
cache if that is wanted (the shared page case is the same, hence the
unuse_page call at the end of try_to_swap_out() (also removed in
2.1.130-3).  The default action of the free_page alone removes the
mapping but not the cache entry, and the functionality of leaving the
cache present is already there.

> Oh, one question. Can we attach a swap page to the swap cache
> while there's no program using it? This way we can implement
> a very primitive swapin readahead right now, improving the
> algorithm as we go along...

Yes, rw_swap_page(READ, nowait) does exactly that: it primes the swap
cache asynchronously but does not map it anywhere.  It should be
completely safe right now: the normal swap read is just a special case
of this.

> IMHO it would be a big loss to have dirty pages in the swap
> cache. Writing out swap pages is cheap since we do proper
> I/O clustering ...

> Besides, having a large/huge clean swap cache means that we
> can very easily free up memory when we need to, this is
> essential for NFS buffers, networking stuff, etc.

Yep, absolutely: agreed on both counts.  This is exactly how 2.1.130-3
works! 

> If we keep a quota of 20% of memory in buffers and unmapped
> cache, we can also do away with a buffer for the 8 and 16kB
> area's. We can always find some contiguous area in swap/page
> cache that we can free...

That will kill performance if you have a large simulation which has a
legitimate need to keep 90% of physical memory full of anonymous pages.
I'd rather do without that 20% magic limit if we can.  The only special
limit we really need is to make sure that kswapd keeps far enough in
advance of interrupt memory load that the free list doesn't empty.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
