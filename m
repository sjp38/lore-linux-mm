Date: Mon, 25 Sep 2000 12:42:09 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: the new VM
In-Reply-To: <Pine.LNX.4.21.0009242143040.2029-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0009251229110.1459-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

i'd also like to share my experiences with recent kernels, compared to the
'old VM'. I frequently run high VM load multi-gigabyte systems with alot
of IRQ-side allocations as well, and it's surprising how sensitive these
systems' performance is to VM balance, despite gobs of RAM.

- The biggest difference under high allocation load is that the CPU usage
of kswapd and the synchronous VM balancing code has decreased
significantly. Under previous kernels it was not uncommon to see sudden
spikes in kswapd usage, and to see significant CPU time spent in
shrink_mmap() & friends. I suspect that this is because the new VM does
much less 'guessing' and blind list-walking.

- i'm also happy that __alloc_pages() now 'guarantees' allocation. This i
believe could simplify unrelated kernel code significantly. Eg. no need to
check for NULL pointers on most allocations, a GFP_KERNEL allocation
always succeeds, end of story. This behavior also has the 'nice'
side-effect of showing memory inbalance rather forcefully: the system
locks up ;-) A GFP_ATOMIC allocation obviously still has the potential to
fail, and must be handled properly.

all in one, the new VM balancing code looks really promising, despite all
the growing pains.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
