Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 9FFE96B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 18:13:57 -0400 (EDT)
Message-ID: <1341007903.2563.41.camel@pasglop>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 30 Jun 2012 08:11:43 +1000
In-Reply-To: <20120629152645.GG17837@arm.com>
References: 
	<CA+55aFy6m967fMxyBsRoXVecdpGtSphXi_XdhwS0DB81Qaocdw@mail.gmail.com>
	 <CA+55aFzLNsVRkp_US8rAmygEkQpp1s1YdakV86Ck-4RZM7TTdA@mail.gmail.com>
	 <20120628091627.GB8573@arm.com> <1340879984.20977.80.camel@pasglop>
	 <1340881196.28750.16.camel@twins> <20120628145327.GA17242@arm.com>
	 <1340900425.28750.73.camel@twins>
	 <CA+55aFwByDWu5bP__e3sw34E7s88f_2P=8m=i6SuP6s+NZgF6w@mail.gmail.com>
	 <1340902329.28750.83.camel@twins> <1340920641.20977.103.camel@pasglop>
	 <20120629152645.GG17837@arm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Fri, 2012-06-29 at 16:26 +0100, Catalin Marinas wrote:
> On Thu, Jun 28, 2012 at 10:57:21PM +0100, Benjamin Herrenschmidt wrote:
> > On Thu, 2012-06-28 at 18:52 +0200, Peter Zijlstra wrote:
> > > No I think you're right (as always).. also an IPI will not force
> > > schedule the thread that might be running on the receiving cpu, also
> > > we'd have to wait for any such schedule to complete in order to
> > > guarantee the mm isn't lazily used anymore.
> > > 
> > > Bugger.. 
> > 
> > You can still do it if the mm count is 1 no ? Ie, current is the last
> > holder of a reference to the mm struct... which will probably be the
> > common case for short lived programs.
> 
> BTW, can we not move the free_pgtables() call in exit_mmap() to
> __mmdrop()? Something like below but I'm not entirely sure about its
> implications:

The main one is that it might remain active on another core for a
-loooong- time if that cores is only running kernel threads or otherwise
idle, thus wasting memory etc...

Also, mm_count being 1 is probably the common case for many short lived
processes, so it should be fine, I don't think the count can every
increase back at that point can it ? (we could make sure it doesn't,
mark the mm as dead and WARN loudly if somebody tries to increase the
count).

The advantage of doing a "detach & flush" IPI if the count is larger is
that you already do the IPI for flushing anyway, so you just add a
detach to the path.

That avoids the problem of the mm staying around for too long as well.

Cheers,
Ben.

> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b36d08c..507ee9f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1372,6 +1372,7 @@ extern void unlink_file_vma(struct vm_area_struct *);
>  extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
>  	unsigned long addr, unsigned long len, pgoff_t pgoff);
>  extern void exit_mmap(struct mm_struct *);
> +extern void exit_pgtables(struct mm_struct *mm);
>  
>  extern int mm_take_all_locks(struct mm_struct *mm);
>  extern void mm_drop_all_locks(struct mm_struct *mm);
> diff --git a/kernel/fork.c b/kernel/fork.c
> index ab5211b..3412b1a 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -588,6 +588,7 @@ struct mm_struct *mm_alloc(void)
>  void __mmdrop(struct mm_struct *mm)
>  {
>  	BUG_ON(mm == &init_mm);
> +	exit_pgtables(mm);
>  	mm_free_pgd(mm);
>  	destroy_context(mm);
>  	mmu_notifier_mm_destroy(mm);
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 074b487..d9ebfdb 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2269,7 +2269,6 @@ void exit_mmap(struct mm_struct *mm)
>  {
>  	struct mmu_gather tlb;
>  	struct vm_area_struct *vma;
> -	unsigned long nr_accounted = 0;
>  
>  	/* mm's last user has gone, and its about to be pulled down */
>  	mmu_notifier_release(mm);
> @@ -2291,11 +2290,23 @@ void exit_mmap(struct mm_struct *mm)
>  
>  	lru_add_drain();
>  	flush_cache_mm(mm);
> -	tlb_gather_mmu(&tlb, mm, 1);
> +	tlb_gather_mmu(&tlb, mm, 0);
>  	/* update_hiwater_rss(mm) here? but nobody should be looking */
>  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
>  	unmap_vmas(&tlb, vma, 0, -1);
> +	tlb_finish_mmu(&tlb, 0, -1);
> +}
> +
> +void exit_pgtables(struct mm_struct *mm)
> +{
> +	struct mmu_gather tlb;
> +	struct vm_area_struct *vma;
> +	unsigned long nr_accounted = 0;
>  
> +	vma = mm->mmap;
> +	if (!vma)
> +		return;
> +	tlb_gather_mmu(&tlb, mm, 1);
>  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, TASK_SIZE);
>  	tlb_finish_mmu(&tlb, 0, -1);
>  
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
