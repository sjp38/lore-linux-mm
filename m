Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 7A4726B0044
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 18:36:19 -0400 (EDT)
Date: Thu, 23 Aug 2012 00:35:42 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 33/36] autonuma: powerpc port
Message-ID: <20120822223542.GG8107@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
 <1345647560-30387-34-git-send-email-aarcange@redhat.com>
 <1345672907.2617.44.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345672907.2617.44.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>

On Thu, Aug 23, 2012 at 08:01:47AM +1000, Benjamin Herrenschmidt wrote:
> On Wed, 2012-08-22 at 16:59 +0200, Andrea Arcangeli wrote:
> > diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
> > index 2e0e411..5f03079 100644
> > --- a/arch/powerpc/include/asm/pgtable.h
> > +++ b/arch/powerpc/include/asm/pgtable.h
> > @@ -33,10 +33,56 @@ static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
> >  static inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
> >  static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
> >  static inline int pte_special(pte_t pte)	{ return pte_val(pte) & _PAGE_SPECIAL; }
> > -static inline int pte_present(pte_t pte)	{ return pte_val(pte) & _PAGE_PRESENT; }
> > +static inline int pte_present(pte_t pte)	{ return pte_val(pte) &
> > +							(_PAGE_PRESENT|_PAGE_NUMA_PTE); }
> 
> Is this absolutely necessary ? (testing two bits). It somewhat changes
> the semantics of "pte_present" which I don't really like.

I'm actually surprised you don't already check for PROTNONE
there. Anyway yes this is necessary, the whole concept of NUMA hinting
page faults is to make the pte not present, and to set another bit (be
it a reserved bit or PROTNONE doesn't change anything in that
respect). But another bit replacing _PAGE_PRESENT must exist.

This change is zero cost at runtime, and 0x1 or 0x3 won't change a
thing for the CPU.

> >  static inline int pte_none(pte_t pte)		{ return (pte_val(pte) & ~_PTE_NONE_MASK) == 0; }
> >  static inline pgprot_t pte_pgprot(pte_t pte)	{ return __pgprot(pte_val(pte) & PAGE_PROT_BITS); }
> >  
> > +#ifdef CONFIG_AUTONUMA
> > +static inline int pte_numa(pte_t pte)
> > +{
> > +       return (pte_val(pte) &
> > +               (_PAGE_NUMA_PTE|_PAGE_PRESENT)) == _PAGE_NUMA_PTE;
> > +}
> > +
> > +#endif
> 
> Why the ifdef and not anywhere else ?

The generic version is implemented in asm-generic/pgtable.h to avoid dups.

> > diff --git a/arch/powerpc/include/asm/pte-hash64-64k.h b/arch/powerpc/include/asm/pte-hash64-64k.h
> > index 59247e8..f7e1468 100644
> > --- a/arch/powerpc/include/asm/pte-hash64-64k.h
> > +++ b/arch/powerpc/include/asm/pte-hash64-64k.h
> > @@ -7,6 +7,8 @@
> >  #define _PAGE_COMBO	0x10000000 /* this is a combo 4k page */
> >  #define _PAGE_4K_PFN	0x20000000 /* PFN is for a single 4k page */
> >  
> > +#define _PAGE_NUMA_PTE 0x40000000 /* Adjust PTE_RPN_SHIFT below */
> > +
> >  /* For 64K page, we don't have a separate _PAGE_HASHPTE bit. Instead,
> >   * we set that to be the whole sub-bits mask. The C code will only
> >   * test this, so a multi-bit mask will work. For combo pages, this
> > @@ -36,7 +38,7 @@
> >   * That gives us a max RPN of 34 bits, which means a max of 50 bits
> >   * of addressable physical space, or 46 bits for the special 4k PFNs.
> >   */
> > -#define PTE_RPN_SHIFT	(30)
> > +#define PTE_RPN_SHIFT	(31)
> 
> I'm concerned. We are already running short on RPN bits. We can't spare
> more. If you absolutely need a PTE bit, we'll need to explore ways to
> free some, but just reducing the RPN isn't an option.

No way to do it without a spare bit.

Note that this is now true for sched-numa rewrite as well because it
also introduced the NUMA hinting page faults of AutoNUMA (except what
it does during the fault is different there, but the mechanism of
firing them and the need of a spare pte bit is identical).

But you must have a bit for protnone, don't you? You can implement it
with prot none, I can add the vma as parameter to some function to
achieve it if you need. It may be good idea to do anyway even if
there's no need on x86 at this point.

> Think of what happens if PTE_4K_PFN is set...

It may very well broken with PTE_4K_PFN is set, I'm not familiar with
that. If that's the case we'll just add an option to prevent
AUTONUMA=y to be set if PTE_4K_PFN is set thanks for the info.

> Also you conveniently avoided all the other pte-*.h variants meaning you
> broke the build for everything except ppc64 with 64k pages.

This can only be enabled on PPC64 in KConfig so no problem about
ppc32.

> > diff --git a/mm/autonuma.c b/mm/autonuma.c
> > index ada6c57..a4da3f3 100644
> > --- a/mm/autonuma.c
> > +++ b/mm/autonuma.c
> > @@ -25,7 +25,7 @@ unsigned long autonuma_flags __read_mostly =
> >  #ifdef CONFIG_AUTONUMA_DEFAULT_ENABLED
> >  	|(1<<AUTONUMA_ENABLED_FLAG)
> >  #endif
> > -	|(1<<AUTONUMA_SCAN_PMD_FLAG);
> > +	|(0<<AUTONUMA_SCAN_PMD_FLAG);
> 
> That changes the default accross all architectures, is that ok vs.
> Andrea ?

:) Indeed! But the next patch (34) undoes this hack. I just merged the
patch with "git am" and then introduced a proper way for the arch to
specify if the PMD scan is supported or not in an incremental
patch. Adding ppc64 support, and making the PMD scan mode arch
conditional are two separate things so I thought it was cleaner
keeping those in two separate patches but I can fold them if you
prefer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
