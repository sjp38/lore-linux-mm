Date: Wed, 3 May 2000 00:26:10 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
In-Reply-To: <Pine.LNX.4.10.10005021439320.12403-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0005030008150.1677-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 May 2000, Linus Torvalds wrote:

>I'd rather get rid of it entirely, yes, as I hate having "crud" around

We can get rid of it entirely if you want, it's only an optimization.

The object of the swap entry bitflag is _only_ to swapout the same page in
the same place across a swapin-write fault. It seems to do the trick to
me.

Making swap cache dirty will take a swap entry locked indefinitely (well,
really also swapin read fault take swap entry locked indefinitely...) and
it have to be a kind of dirty swap cache that doesn't get written to disk
in the usual behaviour but it have to be written to disk only when we go
low on memory and we try to unmap it. The only advantage of dirty cache
over swap-entry-logic is that we can do write-swapin/swapout without
dropping the buffer headers from the page in between but the buffer
headers could go away very fast anyway due memory pressure...

>that nobody realizes isn't really even active any more (and your one-liner

The trick is still active (too much active since sometime we forget to
clear the bitflag ;).

If you want to drop it let me know.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
