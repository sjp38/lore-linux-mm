Date: Mon, 15 May 2000 16:38:22 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [RFC] do_try_to_free_pages() fundamental error, active/inactive page
 list
Message-ID: <Pine.LNX.4.21.0005151614580.20410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi Linus,

I've been playing around a bit with do_try_to_free_pages().
Some while ago I discovered that scanning less pages in
shrink_mmap() would give better page aging. Today I've gone
all the way and just set the 'priority' in do_try_to_free_pages()
to a higher value (16).

The result is better page aging and better performance. To me
this mainly suggests that the current fail-through approach of
do_try_to_free_pages() is wrong.

This idea is only reconfirmed by the fact that kswapd cpu usage
"spikes" when the system suddenly runs low of memory after a period
of no memory pressure. Kswapd finds itself in the situation where
all pages in the lru queue are used and there are no immediately
freeable pages available.

Needless to say, this kswapd frenzy is detrimental for performance
and shouldn't be happening.

The solution I propose is to make sure we have a number of freeable
pages around, so kswapd can "refill" the freeable list before we
have to push really hard. In effect something like the BSD active/
inactive list thing. I've been working on it for the last few weeks
and believe this is probably the only way we can avoid the kswapd
spikes and the corresponding system-stalls-for-20-seconds thing...

regards,

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
