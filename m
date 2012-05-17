Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 3F2596B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 08:15:34 -0400 (EDT)
Date: Thu, 17 May 2012 13:14:59 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC][PATCH 4/6] arm, mm: Convert arm to generic tlb
Message-ID: <20120517121459.GA18593@arm.com>
References: <20110302175928.022902359@chello.nl>
 <20110302180259.109909335@chello.nl>
 <20120517030551.GA11623@linux-sh.org>
 <20120517093022.GA14666@arm.com>
 <20120517095124.GN23420@flint.arm.linux.org.uk>
 <1337254086.4281.26.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337254086.4281.26.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, May 17, 2012 at 12:28:06PM +0100, Peter Zijlstra wrote:
> On Thu, 2012-05-17 at 10:51 +0100, Russell King wrote:
> > On Thu, May 17, 2012 at 10:30:23AM +0100, Catalin Marinas wrote:
> > > Another minor thing is that on newer ARM processors (Cortex-A15) we
> > > need the TLB shootdown even on UP systems, so tlb_fast_mode should
> > > always return 0. Something like below (untested):
> > 
> > No Catalin, we need this for virtually all ARMv7 CPUs whether they're UP
> > or SMP, not just for A15, because of the speculative prefetch which can
> > re-load TLB entries from the page tables at _any_ time.
> 
> Hmm,. so this is mostly because of the confusion/coupling between
> tlb_remove_page() and tlb_remove_table() I guess. Since I don't see the
> freeing of the actual pages being a problem with speculative TLB
> reloads, just the page-tables.

The TLB on newer ARM cores can cache intermediate entries (e.g. pmd) as
long as they are valid, even if the full translation is not possible
(e.g. because the pte entry is 0). With fast_mode, this could lead to
the MMU reading the already freed pte page as it was pointed at by the
old pmd.

Older ARMv7 CPUs (Cortex-A8), don't do this intermediate caching and UP
should be fine with fast_mode==1 as we already track the pte range via
tlb_remove_tlb_entry(). The MMU on ARM is treated like any another agent
that accesses the memory, so standard memory ordering issues apply In
theory Linux can clear the pmd, free the page and it is re-used shortly
after while the MMU hasn't observed the pmd_clear() yet (we don't have a
barrier in this function).

> Should we introduce a tlb_remove_table() regardless of
> HAVE_RCU_TABLE_FREE which always queues the tables regardless of
> tlb_fast_mode()? 

This would probably work as well (or we just add support for
HAVE_RCU_TABLE_FREE on ARM).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
