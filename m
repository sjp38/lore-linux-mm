Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E53866B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:21:52 -0500 (EST)
Subject: Re: [PATCH 09/25] ia64: Preemptible mmu_gather
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <AANLkTikgpX16=ouGCpKqDtr7w-AUWLQNU7cFi4vKWbt+@mail.gmail.com>
References: <20110125173111.720927511@chello.nl>
	 <20110125174907.664402563@chello.nl>
	 <AANLkTikgpX16=ouGCpKqDtr7w-AUWLQNU7cFi4vKWbt+@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 25 Jan 2011 21:22:23 +0100
Message-ID: <1295986943.28776.1108.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Tony Luck <tony.luck@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2011-01-25 at 12:12 -0800, Tony Luck wrote:
> On Tue, Jan 25, 2011 at 9:31 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> =
wrote:
> >  struct mmu_gather {
> >        struct mm_struct        *mm;
> >        unsigned int            nr;             /* =3D=3D ~0U =3D> fast =
mode */
> > +       unsigned int            max;
> >        unsigned char           fullmm;         /* non-zero means full m=
m flush */
> >        unsigned char           need_flush;     /* really unmapped some =
PTEs? */
> >        unsigned long           start_addr;
> >        unsigned long           end_addr;
> > -       struct page             *pages[FREE_PTE_NR];
> > +       struct page             **pages;
> > +       struct page             *local[8];
> >  };
>=20
> Overall it looks OK - builds, boots & runs too. One question about
> the above bit ... why "8" elements in the local[] array?  This ought to b=
e
> a #define, maybe with a comment explaining the significance. It doesn't
> seem to fill out struct mmu_gather to some "nice" size.  I can't think
> of why batching 8 at a time (in the fallback cannot allocate **pages case=
)
> is a good number. So is there some science to the choice, or did you
> pluck 8 out of the air?=20

Yeah, pretty much a random number small enough to make struct mmu_gather
fit on stack, the reason its not 1 is that a few more entries increase
performance a little and freeing more pages increases the chance the
page allocation works next time around.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
