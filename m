Date: Fri, 14 Jan 2000 03:13:48 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <Pine.LNX.4.10.10001131650520.2250-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10001140304570.7119-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@nl.linux.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2000, Linus Torvalds wrote:

> HOWEVER, I don't think this is going to be a huge issue in most cases. And
> if people don't need non-DMA memory, then the pages we "swapped" out are
> going to stay in RAM anyway, so it's not going to hurt us.
> 
> Anyway, I obviously do agree that I may well be wrong, and that real life
> is going to come back and bite us, and we'll end up having to not do it
> this way. However, I'd prefer trying the "conceptually simple" path first,
> and only if it turns out that yes, I was completely wrong, do we try to
> fix it up with magic heuristics etc.

hm., i think we'll see this with ISA soundcards (still the majority) if
used as modules. Right now kswapd just gives up too easy and says 'no such
page', on a box with lots of RAM and all DMA allocated in process VM
space.

Anyway, the patch and suggestion of passing in a single zone is i believe
completely wrong, because it advances mm->swap_address, which unfairly
selects a given range to be checked for only one zone. So i think it's
either zone-bitmaps (or equivalent multi-zone logic) or what you
suggested, to have no zone-awareness in swap_out() for now at all.

(i believe this is also going to bite us with the IA64 port - kswapd will
have no information to free pages from the right node, we could solve this
already with a zone bitmap, or by starting per-zone kswapds. The latter
one looks like overkill to me, but it's conceptually cleaner than bitmaps
and and does not have a limitation on the number of zones. Might not be a
highprio issue though.)

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
