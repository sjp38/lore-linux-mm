Message-ID: <417F5584.2070400@yahoo.com.au>
Date: Wed, 27 Oct 2004 18:00:04 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 0/3] teach kswapd about higher order allocations
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Can this get into mm please?

I haven't been able to do a huge amount of testing, because
there aren't many higher order allocations these days.

However:
I have got into situations where memory becomes completely
fragmented and the Gbe network card starts spewing a lot of
allocations failures. In some cases (eg. ifup) it will just
sit there indefinitely cranking out order:2 allocation
failures. These patches definitely fix those situations by
having kswapd free some higher order areas.

Higher order area watermarks are enforced lazily - that is,
if nobody is doing order 1 allocations, no attempt is ever
made to free order 1 areas, even if none are available. Also,
if kswapd can't free up the right amount of higher order areas,
it eventually gives up on them until being kicked again.

In this way, I don't think this patch has any overscanning
failure cases.

Note:
It generally doesn't take much work to free up memory to get
networking going because the skb allocations are transient,
so you only need some set number of higher order areas free,
and the network buffers just keep reusing them. Other allocations
don't tend to touch them much because the buddy allocator takes
low order pages first.

Linus was the only one with any real objections, but once I
explained myself better he thought this was fairly reasonable
(I think).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
