Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2463F8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 11:34:47 -0500 (EST)
Subject: Re: [PATCH 06/17] arm: mmu_gather rework
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110217163235.106239192@chello.nl>
References: <20110217162327.434629380@chello.nl>
	 <20110217163235.106239192@chello.nl>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 24 Feb 2011 17:34:13 +0100
Message-ID: <1298565253.2428.288.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Russell King <rmk@arm.linux.org.uk>, "Luck,Tony" <tony.luck@intel.com>, PaulMundt <lethal@linux-sh.org>

On Thu, 2011-02-17 at 17:23 +0100, Peter Zijlstra wrote:
> plain text document attachment
> (peter_zijlstra-arm-preemptible_mmu_gather.patch)
> Fix up the arm mmu_gather code to conform to the new API.

So akpm noted that this one doesn't apply anymore because of:

commit 06824ba824b3e9f2fedb38bee79af0643198ed7f
Author: Russell King <rmk+kernel@arm.linux.org.uk>
Date:   Sun Feb 20 12:16:45 2011 +0000

    ARM: tlb: delay page freeing for SMP and ARMv7 CPUs
   =20
    We need to delay freeing any mapped page on SMP and ARMv7 systems to
    ensure that the data is not accessed by other CPUs, or is used for
    speculative prefetch with ARMv7.  This includes not only mapped pages
    but also pages used for the page tables themselves.
   =20
    This avoids races with the MMU/other CPUs accessing pages after they've
    been freed but before we've invalidated the TLB.
   =20
    Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>


Which raises a nice point about shift_arg_pages() which calls
free_pgd_range(), the other architectures that look similar to arm in
this respect are ia64 and sh, do they suffer the same problem?

It doesn't look hard to fold the requirements for this into the generic
tlb range support (patch 14 in this series).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
