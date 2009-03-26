Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 21AE26B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 00:13:51 -0400 (EDT)
Subject: tlb_gather_mmu() and semantics of "fullmm"
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Thu, 26 Mar 2009 16:01:14 +1100
Message-Id: <1238043674.25062.823.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi !

I'd like to clarify something about the semantics of the "full_mm_flush"
argument of tlb_gather_mmu().

The reason is that it can either mean:

 - All the mappings for that mm are being flushed

or

 - The above +plus+ the mm is dead and has no remaining user. IE, we
can relax some of the rules because we know the mappings cannot be
accessed concurrently, and thus the PTEs cannot be reloaded into the
TLB.

If it means the later (which it does in practice today, since we only
call it from exit_mmap(), unless I missed an important detail), then I
could implement some optimisations in my own arch code, but more
importantly, I believe we might also be able to optimize the generic
(and x86) code to avoid flushing the TLB when the batch of pages fills
up, before freeing the pages.

That would have the side effect of speeding up exit of large processes
by limiting the number of tlb flushes they do. Since the TLB would need
to be flushed only once at the end for archs that may carry more than
one context in their TLB, and possibly not at all on x86 since it
doesn't and the context isn't active any more.

Or am I missing something ?

Cheers,
Ben.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
