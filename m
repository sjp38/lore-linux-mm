Date: Fri, 19 May 2000 15:28:36 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.21.0005190905200.1099-100000@inspiron.random>
Message-ID: <Pine.LNX.4.10.10005191519050.3542-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@conectiva.com.br>, Ingo Molnar <mingo@elte.hu>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Fri, 19 May 2000, Andrea Arcangeli wrote:

> On Fri, 19 May 2000, Rik van Riel wrote:
> 
> >I'm curious what would be so "very broken" about this?
> 
> You start eating from ZONE_DMA before you made empty ZONE_NORMAL.

THIS IS NOT A BUG!

It's a feature. I don't see why you insist on calling this a problem.

We do NOT keep free memory around just for DMA allocations. We
fundamentally keep free memory around because the buddy allocator (_any_
allocator, in fact) needs some slop in order to do a reasonable job at
allocating contiguous page regions, for example. We keep free memory
around because that way we have a "buffer" to allocate from atomically, so
that when network traffic occurs or there is other behaviour that requires
memory without being able to free it on the spot, we have memory to give.

Keeping only DMA memory around would be =bad=. It would mean, for example,
that when a new packet comes in on the network, it would always be
allocated from the DMA region, because the normal zone hasn't even been
balanced ("why balance it when we still have DMA memory?"). And that would
be a huge mistake, because that would mean, for example, that by selecting
the right allocation patterns and by opening sockets without reading the
data they receive the right way, somebody could force all of DMA memory to
be used up by network allocations that wouldn't be free'd.

In short, your very fundamental premise is BROKEN, Andrea. We want to keep
normal memory around, even if there is low memory available. The same is
true of high memory, for similar reasons. 

Face it. The original zone-only code had problems. One of the worst
problems was that it would try to free up a lot of "normal" memory if it
got low on DMA memory. Those problems have pretty much been fixed, and
they had _nothing_ to do with your "class" patches. They were bugs, plain
and simple, not design mistakes.

If you think you should have zero free normal pages, YOU have a design
mistake. We should not be that black-and-white. The whole point in having
the min/low/max stuff is to make memory allocation less susceptible to
border conditions, and turn a black-and-white situation into more of a
"levels of gray" situation.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
