Date: Fri, 17 Mar 2000 15:15:32 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: More VM balancing issues..
In-Reply-To: <38D2BB5C.AC4A89C9@av.com>
Message-ID: <Pine.LNX.4.10.10003171509390.987-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christopher Zimmerman <zim@av.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 17 Mar 2000, Christopher Zimmerman wrote:
>
> No that didn't seem to help.  In fact the machine(1GB) just froze after a while.

The 1GB case is actually the most interesting of all, because in the 1GB
case you end up having a _really_ small "high memory" zone, I think (just 
a small zone that is comprised of the pages that can't be used in the
normal memory area due to needing some kernel VM space etc).

Which means that the balancing probably gets rather interesting for that
exact case.

Anyway, my patch was buggy - it made the per-zone "pages_high" depend on
only the zone size, but still leaves the actual comparisons towards the
"class" free pages count. Which just can't be right.

I'd like to try a "local decisions only" version of this, with no classes
etc. That's the simplest case, and it's the only case that I'm reasonable
confident cannot have any really strange behaviour due to pathologically
small zones, etc.

> I'm going to try out Konoj's patch next.  I also tried it out on the 2GB box and
> got and immediate highmem.c oops.  Maybe that oops hasn't been fully resolved.
> If it happens again I'll send you the info.

I'd sure like to see the oops. It may be that the strange balancing caused
by the thinko in my patch (see above) actually causes a hidden bug
somewhere to materialize.. I don't think the thinko itself should cause
any oopses, just strange balancing behaviour.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
