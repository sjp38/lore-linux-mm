Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3355B8D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 09:59:48 -0500 (EST)
Date: Mon, 28 Feb 2011 14:57:50 +0000
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [PATCH 06/17] arm: mmu_gather rework
Message-ID: <20110228145750.GA4911@flint.arm.linux.org.uk>
References: <20110217162327.434629380@chello.nl> <20110217163235.106239192@chello.nl> <1298565253.2428.288.camel@twins> <1298657083.2428.2483.camel@twins> <20110225215123.GA10026@flint.arm.linux.org.uk> <1298893487.2428.10537.camel@twins> <1298902727.2428.10867.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298902727.2428.10867.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, "Luck,Tony" <tony.luck@intel.com>, PaulMundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>

On Mon, Feb 28, 2011 at 03:18:47PM +0100, Peter Zijlstra wrote:
> On Mon, 2011-02-28 at 12:44 +0100, Peter Zijlstra wrote:
> >   unmap_region()
> >     tlb_gather_mmu()
> >     unmap_vmas()
> >       for (; vma; vma = vma->vm_next)
> >         unmao_page_range()
> >           tlb_start_vma() -> flush cache range
> 
> So why is this correct? Can't we race with a concurrent access to the
> memory region (munmap() vs other thread access race)? While
> unmap_region() callers will have removed the vma from the tree so faults
> will not be satisfied, TLBs might still be present and allow us to
> access the memory and thereby reloading it in the cache.

It is my understanding that code sections between tlb_gather_mmu() and
tlb_finish_mmu() are non-preemptible - that was the case once upon a
time when this stuff first appeared.  If that's changed then that
change has introduced an unnoticed bug.

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
