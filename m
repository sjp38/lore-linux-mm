Date: Thu, 4 Nov 1999 23:30:01 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [Patch] shm cleanups
In-Reply-To: <Pine.LNX.4.10.9911042000300.647-100000@imladris.dummy.home>
Message-ID: <Pine.LNX.4.10.9911042319530.8880-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, MM mailing list <linux-mm@kvack.org>, woodman@missioncriticallinux.com, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Nov 1999, Rik van Riel wrote:

> I think I see what is going on here. Kswapd sees that memory is
> low an "frees" a bunch of high memory pages, causing those pages
> to be shifted to low memory so the total number of free pages
> stays just as low as when kswapd started.

hm, kswapd should really be immune against this.

> This can result in in-memory swap storms, we should probably
> limit the number of in-transit async himem pages to 256 or some
> other even smaller number.

i introduced some stupid balancing bugs, and i wrongly thought that the
fixes are already in 2.3.25, but no, it's the pre1-2.3.26 kernel that is
supposed to have balancing right. basically the fix is to restore the
original behavior of not counting high memory in memory pressure. This
might sound an unfair policy, but the real critical resource is low
memory. If this ever proves to be a problematic approach then we still can
make it more sophisticated.

[Christoph, are you still seeing the same kind of bad swapping behavior
with pre1-2.3.26?]

-- mingo

ps. some people might ask why we want to swap on an 8GB box, but i think
it's really an issue in production systems to provide some kind of 'rubber
wall' instead of 'hard concrete' if the system is reaching its limits.
adding (99% unused) swap space does exactly this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
