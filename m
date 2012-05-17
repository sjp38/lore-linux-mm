Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 472766B0081
	for <linux-mm@kvack.org>; Thu, 17 May 2012 12:59:39 -0400 (EDT)
Message-ID: <1337273959.4281.62.camel@twins>
Subject: Re: [RFC][PATCH 4/6] arm, mm: Convert arm to generic tlb
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 17 May 2012 18:59:19 +0200
In-Reply-To: <1337273053.4281.50.camel@twins>
References: <20110302175928.022902359@chello.nl>
	 <20110302180259.109909335@chello.nl> <20120517030551.GA11623@linux-sh.org>
	 <20120517093022.GA14666@arm.com>
	 <20120517095124.GN23420@flint.arm.linux.org.uk>
	 <1337254086.4281.26.camel@twins> <20120517160012.GB18593@arm.com>
	 <1337271884.4281.46.camel@twins> <1337272396.4281.48.camel@twins>
	 <1337273053.4281.50.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, 2012-05-17 at 18:44 +0200, Peter Zijlstra wrote:
>=20
> So the RCU code can from ppc in commit
> 267239116987d64850ad2037d8e0f3071dc3b5ce, which has similar behaviour.
> Also I suspect the mm_users < 2 test will be incorrect for ARM since
> even the one user can be concurrent with your speculation engine.
>=20
>=20
Right, last mail, I promise, I've confused myself enough already! :-)

OK, so ppc/sparc are special (forgot all about s390) I think by the time
they are done with unmap_page_range() their hardware hash-tables are
empty and nobody but software page-table walkers will still access the
linux page tables.

So when we do free_pgtables() to clean up the actual page-tables.
Power/Sparc need to RCU free this to allow concurrent software
page-table walkers like gup_fast.

Thus I don't think they need to tlb flush again because their hardware
doesn't actually walk the link page-tables, it walks hash-tables, which
by this time are empty.

Now if x86/Xen were to use this, it would indeed also need to TLB flush
when freeing the page-tables, since its hardware walkers do indeed
traverse these pages and we need to sync against them.

So my first patch in the tlb-unify tree is actually buggy.

Humm,. what to do adding a tlb flush in there might slow down ppc/sparc
unnecessarily.. dave/ben? I guess we need more knobs :-(


Now its quite possible I've utterly confused myself and everybody
reading, apologies for that, I shall rest and purge all from memory and
start over before commenting more..=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
