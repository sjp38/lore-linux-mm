Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C66F68D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 06:41:30 -0400 (EDT)
Subject: Re: [PATCH 12/20] mm: Extended batches for generic mmu_gather
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110419130633.3d8cd5ae.akpm@linux-foundation.org>
References: <20110401121258.211963744@chello.nl>
	 <20110401121725.892956392@chello.nl>
	 <20110419130633.3d8cd5ae.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 20 Apr 2011 12:40:40 +0200
Message-ID: <1303296040.8345.156.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Tue, 2011-04-19 at 13:06 -0700, Andrew Morton wrote:
> On Fri, 01 Apr 2011 14:13:10 +0200
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>=20
> > Instead of using a single batch (the small on-stack, or an allocated
> > page), try and extend the batch every time it runs out and only flush
> > once either the extend fails or we're done.
>=20
> why?

To avoid sending extra TLB invalidates.

> > @@ -86,22 +86,48 @@ struct mmu_gather {
> >  #ifdef CONFIG_HAVE_RCU_TABLE_FREE
> >  	struct mmu_table_batch	*batch;
> >  #endif
> > +	unsigned int		need_flush : 1,	/* Did free PTEs */
> > +				fast_mode  : 1; /* No batching   */
>=20
> mmu_gather.fast_mode gets modified in several places apparently without
> locking to protect itself.  I don't think that these modifications will
> accidentally trash need_flush, mainly by luck.

The other way around I'd think.

> Please review the concurrency issues here and document them clearly.

Its an on-stack structure, there is no concurrency. /me shall add a
comment.

> > +#ifdef CONFIG_SMP
> > +  #define tlb_fast_mode(tlb) (tlb->fast_mode)
> > +#else
> > +  #define tlb_fast_mode(tlb) 1
> > +#endif
>=20
> Mutter.
>=20
> Could have been written in C.

Fixed in my last patch uninlining bits

> Will cause a compile error with, for example, tlb_fast_mode(tlb + 1).

Well, that'd actually be a good reason to keep the macro ;-)

> > +static inline int tlb_next_batch(struct mmu_gather *tlb)
> >  {
> > +	struct mmu_gather_batch *batch;
> > =20
> > +	batch =3D tlb->active;
> > +	if (batch->next) {
> > +		tlb->active =3D batch->next;
> > +		return 1;
> >  	}
> > +
> > +	batch =3D (void *)__get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
>=20
> A comment explaining the gfp_t decision would be useful.

Done

> > +	if (!batch)
> > +		return 0;
> > +
> > +	batch->next =3D NULL;
> > +	batch->nr   =3D 0;
> > +	batch->max  =3D MAX_GATHER_BATCH;
> > +
> > +	tlb->active->next =3D batch;
> > +	tlb->active =3D batch;
> > +
> > +	return 1;
> >  }
> > =20
> >  /* tlb_gather_mmu
> > @@ -114,16 +140,13 @@ tlb_gather_mmu(struct mmu_gather *tlb, s
> >  {
> >  	tlb->mm =3D mm;
> > =20
> > +	tlb->fullmm     =3D fullmm;
> > +	tlb->need_flush =3D 0;
> > +	tlb->fast_mode  =3D (num_possible_cpus() =3D=3D 1);
>=20
> The changelog didn't tell us why we switched from num_online_cpus() to
> num_possible_cpus().

And that is a very good question... somehow I remember a conversation
with BenH about this, but on second thought that might have been about
his pgtable_free_tlb() optimization (which is somewhat similar).

Let me restore that to num_online_cpus() and maybe do a later patch
removing fast_mode all together as Hugh suggested, since even UP might
have benefit from the batching due to less zone-lock activity on bulk
frees.

> > +	tlb->local.next =3D NULL;
> > +	tlb->local.nr   =3D 0;
> > +	tlb->local.max  =3D ARRAY_SIZE(tlb->__pages);
> > +	tlb->active     =3D &tlb->local;
> > =20
> >  #ifdef CONFIG_HAVE_RCU_TABLE_FREE
> >  	tlb->batch =3D NULL;
> >
> > ...
> >
> > @@ -177,15 +205,24 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
> > +	batch =3D tlb->active;
> > +	batch->pages[batch->nr++] =3D page;
> > +	VM_BUG_ON(batch->nr > batch->max);
> > +	if (batch->nr =3D=3D batch->max) {
> > +		if (!tlb_next_batch(tlb))
> > +			return 0;
> > +	}
>=20
> Moving the VM_BUG_ON() down to after the if() would save a few cycles.

Done.

> > +	return batch->max - batch->nr;
> >  }
> > =20
> >  /* tlb_remove_page
> >=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
