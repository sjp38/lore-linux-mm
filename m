Date: Tue, 4 Jan 2005 11:58:13 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page fault scalability patch V14 [5/7]: x86_64 atomic pte
 operations
In-Reply-To: <m1652ddljp.fsf@muc.de>
Message-ID: <Pine.LNX.4.58.0501041154560.1083@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org>
 <Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org>
 <Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412011545060.5721@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com> <m1652ddljp.fsf@muc.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Jan 2005, Andi Kleen wrote:

> Christoph Lameter <clameter@sgi.com> writes:
>
> I bet this has been never tested.

I tested this back in October and it worked fine. Would you be able to
test your proposed modifications and send me a patch?

> > +#define pmd_test_and_populate(mm, pmd, pte) \
> > +		(cmpxchg((int *)pmd, PMD_NONE, _PAGE_TABLE | __pa(pte)) == PMD_NONE)
> > +#define pud_test_and_populate(mm, pud, pmd) \
> > +		(cmpxchg((int *)pgd, PUD_NONE, _PAGE_TABLE | __pa(pmd)) == PUD_NONE)
> > +#define pgd_test_and_populate(mm, pgd, pud) \
> > +		(cmpxchg((int *)pgd, PGD_NONE, _PAGE_TABLE | __pa(pud)) == PGD_NONE)
> > +
>
> Shouldn't this all be (long *)pmd ? page table entries on x86-64 are 64bit.
> Also why do you cast at all? i think the macro should handle an arbitary
> pointer.

The macro checks for the size of the pointer and then generates the
appropriate cmpxchg instruction. pgd_t is a struct which may be
problematic for the cmpxchg macros.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
