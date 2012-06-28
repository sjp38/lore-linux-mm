Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 6B4516B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 03:11:54 -0400 (EDT)
Message-ID: <1340867364.20977.65.camel@pasglop>
Subject: Re: [PATCH 02/20] mm: Add optional TLB flush to generic RCU
 page-table freeing
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 28 Jun 2012 17:09:24 +1000
In-Reply-To: <1340838106.10063.85.camel@twins>
References: <20120627211540.459910855@chello.nl>
	 <20120627212830.693232452@chello.nl>
	 <CA+55aFwa41fzvx8EZG_gODvw7hSpr+iP+w5fXp6jUcQh-4nFgQ@mail.gmail.com>
	 <1340838106.10063.85.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A.
 Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Thu, 2012-06-28 at 01:01 +0200, Peter Zijlstra wrote:
> On Wed, 2012-06-27 at 15:23 -0700, Linus Torvalds wrote:
> 
> > Plus it really isn't about hardware page table walkers at all. It's
> > more about the possibility of speculative TLB fils, it has nothing to
> > do with *how* they are done. Sure, it's likely that a software
> > pagetable walker wouldn't be something that gets called speculatively,
> > but it's not out of the question.
> > 
> Hmm, I would call gup_fast() as speculative as we can get in software.
> It does a lock-less walk of the page-tables. That's what the RCU free'd
> page-table stuff is for to begin with.

Strictly speaking it's not :-) To *begin with* (as in the origin of that
code) it comes from powerpc hash table code which walks the linux page
tables locklessly :-) It then came in handy with gup_fast :-)

> > IOW, if Sparc/PPC really want to guarantee that they never fill TLB
> > entries speculatively, and that if we are in a kernel thread they will
> > *never* fill the TLB with anything else, then make them enable
> > CONFIG_STRICT_TLB_FILL or something in their architecture Kconfig
> > files. 
> 
> Since we've dealt with the speculative software side by using RCU-ish
> stuff, the only thing that's left is hardware, now neither sparc64 nor
> ppc actually know about the linux page-tables from what I understood,
> they only look at their hash-table thing.

Some embedded ppc's know about the lowest level (SW loaded PMD) but
that's not an issue here. We flush these special TLB entries
specifically and synchronously in __pte_free_tlb().

> So even if the hardware did do speculative tlb fills, it would do them
> from the hash-table, but that's already cleared out.

Right,

Cheers,
Ben.

> 
> How about something like this
> 
> ---
> Subject: mm: Add missing TLB invalidate to RCU page-table freeing
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Thu Jun 28 00:49:33 CEST 2012
> 
> For normal systems we need a TLB invalidate before freeing the
> page-tables, the generic RCU based page-table freeing code lacked
> this.
> 
> This is because this code originally came from ppc where the hardware
> never walks the linux page-tables and thus this invalidate is not
> required.
> 
> Others, notably s390 which ran into this problem in cd94154cc6a
> ("[S390] fix tlb flushing for page table pages"), do very much need
> this TLB invalidation.
> 
> Therefore add it, with a Kconfig option to disable it so as to not
> unduly slow down PPC and SPARC64 which neither of them need it.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  arch/Kconfig         |    3 +++
>  arch/powerpc/Kconfig |    1 +
>  arch/sparc/Kconfig   |    1 +
>  mm/memory.c          |   18 ++++++++++++++++++
>  4 files changed, 23 insertions(+)
> 
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -231,6 +231,9 @@ config HAVE_ARCH_MUTEX_CPU_RELAX
>  config HAVE_RCU_TABLE_FREE
>  	bool
>  
> +config STRICT_TLB_FILL
> +	bool
> +
>  config ARCH_HAVE_NMI_SAFE_CMPXCHG
>  	bool
>  
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -127,6 +127,7 @@ config PPC
>  	select GENERIC_IRQ_SHOW_LEVEL
>  	select IRQ_FORCED_THREADING
>  	select HAVE_RCU_TABLE_FREE if SMP
> +	select STRICT_TLB_FILL
>  	select HAVE_SYSCALL_TRACEPOINTS
>  	select HAVE_BPF_JIT if PPC64
>  	select HAVE_ARCH_JUMP_LABEL
> --- a/arch/sparc/Kconfig
> +++ b/arch/sparc/Kconfig
> @@ -52,6 +52,7 @@ config SPARC64
>  	select HAVE_KRETPROBES
>  	select HAVE_KPROBES
>  	select HAVE_RCU_TABLE_FREE if SMP
> +	select STRICT_TLB_FILL
>  	select HAVE_MEMBLOCK
>  	select HAVE_MEMBLOCK_NODE_MAP
>  	select HAVE_SYSCALL_WRAPPERS
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -329,11 +329,27 @@ static void tlb_remove_table_rcu(struct 
>  	free_page((unsigned long)batch);
>  }
>  
> +#ifdef CONFIG_STRICT_TLB_FILL
> +/*
> + * Some archictures (sparc64, ppc) cannot refill TLBs after the they've removed
> + * the PTE entries from their hash-table. Their hardware never looks at the
> + * linux page-table structures, so they don't need a hardware TLB invalidate
> + * when tearing down the page-table structure itself.
> + */
> +static inline void tlb_table_flush_mmu(struct mmu_gather *tlb) { }
> +#else
> +static inline void tlb_table_flush_mmu(struct mmu_gather *tlb)
> +{
> +	tlb_flush_mmu(tlb);
> +}
> +#endif
> +
>  void tlb_table_flush(struct mmu_gather *tlb)
>  {
>  	struct mmu_table_batch **batch = &tlb->batch;
>  
>  	if (*batch) {
> +		tlb_table_flush_mmu(tlb);
>  		call_rcu_sched(&(*batch)->rcu, tlb_remove_table_rcu);
>  		*batch = NULL;
>  	}
> @@ -345,6 +361,7 @@ void tlb_remove_table(struct mmu_gather 
>  
>  	tlb->need_flush = 1;
>  
> +#ifdef CONFIG_STRICT_TLB_FILL
>  	/*
>  	 * When there's less then two users of this mm there cannot be a
>  	 * concurrent page-table walk.
> @@ -353,6 +370,7 @@ void tlb_remove_table(struct mmu_gather 
>  		__tlb_remove_table(table);
>  		return;
>  	}
> +#endif
>  
>  	if (*batch == NULL) {
>  		*batch = (struct mmu_table_batch *)__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
