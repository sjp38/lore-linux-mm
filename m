Date: Thu, 2 Dec 1999 14:27:47 GMT
Message-Id: <199912021427.OAA03199@dukat.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: set_pte() is no longer atomic with PAE36.
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

Ingo, do we not have a bit of a problem with set_pte() on PAE36-enabled
builds now?

	#define set_pte(pteptr, pteval) ((*(pteptr)) = (pteval))

would seem to be a problem: the 64-bit write is not atomic.  When
setting an unused pte, we want the word containing the page present bit
to be the last word written.  When clearing a pte, though, we need the
page present bit to be cleared before we invalidate the high order word,
otherwise we're in trouble if another cpu populates its tlb whilte the
pte is in an inconsistent (but valid, to the cpu) state.

Modifying an existing pte (eg. for COW) is probably even harder: do we
need to clear the page-present bit while we modify the high word?
Simply setting the dirty or accessed bits should pose no such problem,
but relocating a page looks as if it could bite here.

Basically, as long as we can assume that another cpu will only ever see
a pte with the page-present bit clear or a completely valid pte, all
should be fine.  Or have I missed something fundamental?

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
