Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DB3058D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 16:53:42 -0500 (EST)
Date: Fri, 25 Feb 2011 21:51:24 +0000
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [PATCH 06/17] arm: mmu_gather rework
Message-ID: <20110225215123.GA10026@flint.arm.linux.org.uk>
References: <20110217162327.434629380@chello.nl> <20110217163235.106239192@chello.nl> <1298565253.2428.288.camel@twins> <1298657083.2428.2483.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298657083.2428.2483.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, "Luck,Tony" <tony.luck@intel.com>, PaulMundt <lethal@linux-sh.org>

On Fri, Feb 25, 2011 at 07:04:43PM +0100, Peter Zijlstra wrote:
> I'm not quite sure why you chose to add range tracking on
> pte_free_tlb(), the only affected code path seems to be unmap_region()
> where you'll use a flush_tlb_range(), but its buggy, the pte_free_tlb()
> range is much larger than 1 page, and if you do it there you also need
> it for all the other p??_free_tlb() functions.

My reasoning is to do with the way the LPAE stuff works.  For the
explaination below, I'm going to assume a 2 level page table system
for simplicity.

The first thing to realise is that if we have L2 entries, then we'll
have unmapped them first using the usual tlb shootdown interfaces.

However, when we're freeing the page tables themselves, we should
already have removed the L2 entries, so all we have are the L1 entries.
In most 'normal' processors, these aren't cached in any way.

Howver, with LPAE, these are cached.  I'm told that any TLB flush for an
address which is covered by the L1 entry will cause that cached entry to
be invalidated.

So really this is about getting rid of cached L1 entries, and not the
usual TLB lookaside entries that you'd come to expect.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
