Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA08101
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 17:33:49 -0400
Date: Thu, 23 Jul 1998 22:28:39 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Good and bad news on 2.1.110, and a fix
In-Reply-To: <35B75FE8.63173E88@star.net>
Message-ID: <Pine.LNX.3.96.980723222349.18464C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bill Hawes <whawes@star.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Alan Cox <number6@the-village.bc.nu>, "David S. Miller" <davem@dm.cobaltmicro.com>, Ingo Molnar <mingo@valerie.inf.elte.hu>, Mark Hemment <markhe@nextd.demon.co.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 23 Jul 1998, Bill Hawes wrote:
> Stephen C. Tweedie wrote:
>  
> > The patch to page_alloc.c is a minimal fix for the fragmentation
> > problem.  It simply records allocation failures for high-order pages,
> > and forces free_memory_available to return false until a page of at
> > least that order becomes available.  The impact should be low, since

This sound suspiciously like the first version of
free_memory_available() that Linus introduced in
2.1.89...

> One possible downside is that kswapd infinite looping may become more
> likely, as we still have no way to determine when the memory

It will happen for sure; just think of what will happen
when that 64 kB DMA allocation fails on your 6 MB box :(

We saw the results in 2.1.89 and I don't see any reason
to repeat the experiments now, at least not until Bill's
patch for freeing inodes is merged...

> configuration makes it impossible to achieve the memory goal. I still
> see this "swap deadlock" in 110 (and all recent kernels) under low
> memory or by doing a swapoff. Any ideas on how to best determine an
> infeasible memory configuration?

Well, freepages.high should be a nice hint as to when to
stop; unfortunately it is used now instead of fragmentation
issues.

Maybe we want to count the number of order-3 memory structures
free and keep that number above a certain level (back to
Zlatko's 2.1.59 patch :-).

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
