Date: Fri, 12 May 2000 11:15:52 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.10.10005121839370.3348-100000@elte.hu>
Message-ID: <Pine.LNX.4.10.10005121111340.4959-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


Ingo, one thing struck me.. Have you actually tested unmodified 99-pre7?

You said that you've been running the "standard kernel with the highmem
modification" for a few weeks on a 8GB machine, and that makes me wonder
if you maybe didn't even try pre7 without your mod?

What _used_ to happen with multi-zone setups was that if on ezone started
to need balancing, you got a lot of page-out activity in the other zones
too, because vmscan would _only_ look at the LRU information, and would
happily page stuff out from the zones that weren't affected at all. On a
highmem machine this means, for example, that if the regular memory zone
(or the DMA zone) got under pressure, we would start paging out highmem
pages too as we encountered them in vmscan.

With such a setup, your patch makes lots of sense - trying to decouple the
highmem zone as much as possible. But the more recent kernels should be
better at not touching zones that don't need touching (it will still
change the LRU information, though).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
