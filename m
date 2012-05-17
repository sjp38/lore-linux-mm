Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 91C196B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 07:28:46 -0400 (EDT)
Message-ID: <1337254086.4281.26.camel@twins>
Subject: Re: [RFC][PATCH 4/6] arm, mm: Convert arm to generic tlb
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 17 May 2012 13:28:06 +0200
In-Reply-To: <20120517095124.GN23420@flint.arm.linux.org.uk>
References: <20110302175928.022902359@chello.nl>
	 <20110302180259.109909335@chello.nl> <20120517030551.GA11623@linux-sh.org>
	 <20120517093022.GA14666@arm.com>
	 <20120517095124.GN23420@flint.arm.linux.org.uk>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Paul Mundt <lethal@linux-sh.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, 2012-05-17 at 10:51 +0100, Russell King wrote:
> On Thu, May 17, 2012 at 10:30:23AM +0100, Catalin Marinas wrote:
> > Another minor thing is that on newer ARM processors (Cortex-A15) we
> > need the TLB shootdown even on UP systems, so tlb_fast_mode should
> > always return 0. Something like below (untested):
>=20
> No Catalin, we need this for virtually all ARMv7 CPUs whether they're UP
> or SMP, not just for A15, because of the speculative prefetch which can
> re-load TLB entries from the page tables at _any_ time.

Hmm,. so this is mostly because of the confusion/coupling between
tlb_remove_page() and tlb_remove_table() I guess. Since I don't see the
freeing of the actual pages being a problem with speculative TLB
reloads, just the page-tables.

Should we introduce a tlb_remove_table() regardless of
HAVE_RCU_TABLE_FREE which always queues the tables regardless of
tlb_fast_mode()?=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
