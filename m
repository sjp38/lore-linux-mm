Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A6D086B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:12:59 -0500 (EST)
Received: by iyj17 with SMTP id 17so5748966iyj.14
        for <linux-mm@kvack.org>; Tue, 25 Jan 2011 12:12:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110125174907.664402563@chello.nl>
References: <20110125173111.720927511@chello.nl>
	<20110125174907.664402563@chello.nl>
Date: Tue, 25 Jan 2011 12:12:56 -0800
Message-ID: <AANLkTikgpX16=ouGCpKqDtr7w-AUWLQNU7cFi4vKWbt+@mail.gmail.com>
Subject: Re: [PATCH 09/25] ia64: Preemptible mmu_gather
From: Tony Luck <tony.luck@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 25, 2011 at 9:31 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wr=
ote:
> =A0struct mmu_gather {
> =A0 =A0 =A0 =A0struct mm_struct =A0 =A0 =A0 =A0*mm;
> =A0 =A0 =A0 =A0unsigned int =A0 =A0 =A0 =A0 =A0 =A0nr; =A0 =A0 =A0 =A0 =
=A0 =A0 /* =3D=3D ~0U =3D> fast mode */
> + =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0max;
> =A0 =A0 =A0 =A0unsigned char =A0 =A0 =A0 =A0 =A0 fullmm; =A0 =A0 =A0 =A0 =
/* non-zero means full mm flush */
> =A0 =A0 =A0 =A0unsigned char =A0 =A0 =A0 =A0 =A0 need_flush; =A0 =A0 /* r=
eally unmapped some PTEs? */
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 start_addr;
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 end_addr;
> - =A0 =A0 =A0 struct page =A0 =A0 =A0 =A0 =A0 =A0 *pages[FREE_PTE_NR];
> + =A0 =A0 =A0 struct page =A0 =A0 =A0 =A0 =A0 =A0 **pages;
> + =A0 =A0 =A0 struct page =A0 =A0 =A0 =A0 =A0 =A0 *local[8];
> =A0};

Overall it looks OK - builds, boots & runs too. One question about
the above bit ... why "8" elements in the local[] array?  This ought to be
a #define, maybe with a comment explaining the significance. It doesn't
seem to fill out struct mmu_gather to some "nice" size.  I can't think
of why batching 8 at a time (in the fallback cannot allocate **pages case)
is a good number. So is there some science to the choice, or did you
pluck 8 out of the air?

Thanks

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
