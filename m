Date: Tue, 2 Aug 2005 17:03:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <Pine.LNX.4.58.0508020829010.3341@g5.osdl.org>
Message-ID: <Pine.LNX.4.61.0508021645050.4921@goblin.wat.veritas.com>
References: <OF3BCB86B7.69087CF8-ON42257051.003DCC6C-42257051.00420E16@de.ibm.com>
 <Pine.LNX.4.58.0508020829010.3341@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@osdl.org>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Aug 2005, Linus Torvalds wrote:
> 
> On the other hand, this being s390, maybe nobody cares?

You have a cruel streak.

But have I just realized a non-s390 problem with your pte_dirty
technique?  The ptep_set_wrprotect in fork's copy_one_pte.

That's specifically write-protecting the pte to force COW, but
leaving the dirty bit: so now get_user_pages will skip COW-ing it
(in all write cases, not just the peculiar ptrace force one).

We really do need to COW those in get_user_pages, don't we?
And although we could handle it by clearing dirty and doing a
set_page_dirty, it's a path we don't want to clutter further.

(Yes, there's another issue of a fork occurring while the pages
are already under get_user_pages, which is a significant issue for
InfiniBand; but I see that as a separate kind of race, which we can
reasonably disregard in this discussion - though it will need proper
attention, perhaps through Michael Tsirkin's PROT_DONTCOPY patch.)

The simple answer to Robin's pagetable update race is to say that
anyone using ptrace should be prepared for a pt race ;)

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
