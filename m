Date: Sun, 14 May 2000 09:01:08 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: pre8: where has the anti-hog code gone?
In-Reply-To: <Pine.LNX.4.10.10005141319450.1494-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0005140855260.16064-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Sun, 14 May 2000, Ingo Molnar wrote:

> this seems to have done the trick here - no more NULL gfps. Any
> better generic suggestion than the explicit 'page transport'
> path between freeing and allocation points?

Mark the zone as a "steal-before-allocate" zone while
one user process is in the page stealer because it
could not find an easy page.

if (couldn't find an easy page) {
	atomic_inc(&zone->steal_before_allocate);
	try_to_free_pages();
	blah blah blah;
	atomic_dec(&zone->steal_before_allocate);
}

And the allocation path can be changed to always call
try_to_free_pages() if zone->steal_before_allocate is
set.

This way we won't just guarantee that we can keep the page
we just freed, but also that _other_ processes won't get
false hopes and/or run out of memory. Furthermore, by going
into try_to_free_pages() a bit more agressively we could
reduce memory fragmentation a bit (but I'm not sure if this
effect would be significant or not).

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
