Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA06986
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 15:15:50 -0400
Date: Thu, 23 Jul 1998 18:30:10 +0100
Message-Id: <199807231730.SAA13687@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Good and bad news on 2.1.110, and a fix
In-Reply-To: <35B75FE8.63173E88@star.net>
References: <199807231248.NAA04764@dax.dcs.ed.ac.uk>
	<35B75FE8.63173E88@star.net>
Sender: owner-linux-mm@kvack.org
To: Bill Hawes <whawes@star.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Alan Cox <number6@the-village.bc.nu>, "David S. Miller" <davem@dm.cobaltmicro.com>, Ingo Molnar <mingo@valerie.inf.elte.hu>, Mark Hemment <markhe@nextd.demon.co.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 23 Jul 1998 12:08:08 -0400, Bill Hawes <whawes@star.net> said:

> Your change to track the maximum failed allocation looks helpful, as
> this will focus extra swap attention when a problem actually occurs. So
> assuming that the client has a retry capability (as with NFS), it should
> improve recoverability.

> One possible downside is that kswapd infinite looping may become more
> likely, as we still have no way to determine when the memory
> configuration makes it impossible to achieve the memory goal. I still
> see this "swap deadlock" in 110 (and all recent kernels) under low
> memory or by doing a swapoff. Any ideas on how to best determine an
> infeasible memory configuration?

Yes.   One thing I had toyed with, and have implemented on test kernels
based on 2.1.108, was simply to keep a history of VM activity so that we
only base swapping performance on recent requests.  Ageing the
max_failed_order variable so that it is reset every second or so would
at least prevent a swap deadlock if the large allocation was only a
one-off event, but won't help if there is something like NFS repeatedly
demanding the memory.

That said, if NFS is deadlocked on a large allocation, then we have a
hung machine _anyway_, and if a swap storm is the only conceivable way
out of it, it's not clear that it's a bad thing to do!

> Under some conditions the most helpful action may be to let some
> allocations fail, to shed load or kill processes. (But selecting the
> right process to kill may not be easy ...)

Yes, and one thing we should perhaps do is to limit pageable allocations
such that they never exhaust the supply of higher order pages
completely.  However, that still won't help if it's atomic allocations
which are causing the shortage.  In this case, probably the only hope of
progress is a swapper which can actively return entire free zones.

Hmm, how about this for a thought: why not stall all pageable
allocations completely if we get into this situation, and give the
swapper enough breathing space to get a higher order page free?  The
situation should be sufficiently infrequent that it shouldn't impact
performance at all, and there are very few places which would need to
pass the new GFP_PAGEABLE flag into get_free_pages (or we could simply
apply it to all __GFP_LOW/__GFP_WAIT allocations).  

This will still fail if *all* user memory is fragmented, but the zoned
allocator would fix that too.  However, we're now getting into the
realms of the extremely unlikely, so it's probably not important to go
that far unless we have benchmarks which show it to be a problem.

I'm off at a wedding until Monday, so feel free to implement something
over the weekend yourself. :)

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
