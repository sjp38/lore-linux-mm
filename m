Date: Fri, 12 May 2000 21:36:13 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.10.10005121200590.4959-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10005122128580.6188-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Fri, 12 May 2000, Linus Torvalds wrote:

> > i initially tested pre7-9 and it showed bad behavior: high kswapd activity
> > trying to balance highmem, while the pagecache is primarily filled from
> > the highmem. I dont think this can be fixed without 'silencing'
> > ZONE_HIGHMEM's balancing activities: the pagecache allocates from highmem
> > so it puts direct pressure on the highmem zone.
> 
> If this is true, then that is a bug in the allocator.

i just re-checked final pre7-2.3.99, and saw similar behavior. Once
ZONE_HIGHMEM is empty kswapd eats ~6% CPU time (constantly running),
highmem freecount (in /proc/meminfo) fluctuating slightly above zero, but
pagecache is not growing anymore - although there is still lots of
ZONE_NORMAL RAM around.

> anyway. So before you touch the memory allocator logic, you might want to
> change the
> 
> 	if (tsk->need_resched)
> 		schedule();
> 
> to a 
> 
> 	if (tsk->need_resched)
> 		goto sleep;
> 
> (and add a "sleep:" thing to inside the if-statement that makes us go to
> sleep). That way, if we end up scheduling away from kswapd, we won't waste
> time scheduling back unless we really should.

ok, will try this, and will try to find where it fails.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
