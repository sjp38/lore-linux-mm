Date: Thu, 2 Dec 1999 16:54:11 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: set_pte() is no longer atomic with PAE36.
In-Reply-To: <199912021427.OAA03199@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9912021650370.3157-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 2 Dec 1999, Stephen C. Tweedie wrote:

> Ingo, do we not have a bit of a problem with set_pte() on PAE36-enabled
> builds now?
> 
> 	#define set_pte(pteptr, pteval) ((*(pteptr)) = (pteval))

hm, looks like we'll have to use cmpxchg8b.

> would seem to be a problem: the 64-bit write is not atomic.  When
> setting an unused pte, we want the word containing the page present bit
> to be the last word written.  When clearing a pte, though, we need the
> page present bit to be cleared before we invalidate the high order word,
> otherwise we're in trouble if another cpu populates its tlb whilte the
> pte is in an inconsistent (but valid, to the cpu) state.

yep, right. if you change the PAE clear_pte() to use cmpxchg8b, does it
fix the boot problems you see?

> Modifying an existing pte (eg. for COW) is probably even harder: do we
> need to clear the page-present bit while we modify the high word?
> Simply setting the dirty or accessed bits should pose no such problem,
> but relocating a page looks as if it could bite here.
> 
> Basically, as long as we can assume that another cpu will only ever see
> a pte with the page-present bit clear or a completely valid pte, all
> should be fine.  Or have I missed something fundamental?

i think we should definitely update 64-bit ptes atomically, this could be
especially important for multiple threads mapping/unmapping areas and
building TLBs. This could also be a security risk. (just imagine half of
the pte being seen on one CPU and the TLB goes to the wrong place.)

i think we still have some other problem, but this is a definitive bug i
believe, yes.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
