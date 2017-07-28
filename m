Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 610016B055A
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 11:12:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j79so241803600pfj.9
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 08:12:29 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id a94si4870886pli.289.2017.07.28.08.12.27
        for <linux-mm@kvack.org>;
        Fri, 28 Jul 2017 08:12:28 -0700 (PDT)
Date: Sat, 29 Jul 2017 00:12:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/3] mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem
Message-ID: <20170728151224.GA24201@bbox>
References: <1501224112-23656-1-git-send-email-minchan@kernel.org>
 <1501224112-23656-3-git-send-email-minchan@kernel.org>
 <20170728084634.foo3wjhsyydml6yj@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170728084634.foo3wjhsyydml6yj@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team <kernel-team@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-sh@vger.kernel.org, Jeff Dike <jdike@addtoit.com>, user-mode-linux-devel@lists.sourceforge.net, linux-arch@vger.kernel.org, Nadav Amit <nadav.amit@gmail.com>

On Fri, Jul 28, 2017 at 09:46:34AM +0100, Mel Gorman wrote:
> On Fri, Jul 28, 2017 at 03:41:51PM +0900, Minchan Kim wrote:
> > Nadav reported parallel MADV_DONTNEED on same range has a stale TLB
> > problem and Mel fixed it[1] and found same problem on MADV_FREE[2].
> > 
> > Quote from Mel Gorman
> > 
> > "The race in question is CPU 0 running madv_free and updating some PTEs
> > while CPU 1 is also running madv_free and looking at the same PTEs.
> > CPU 1 may have writable TLB entries for a page but fail the pte_dirty
> > check (because CPU 0 has updated it already) and potentially fail to flush.
> > Hence, when madv_free on CPU 1 returns, there are still potentially writable
> > TLB entries and the underlying PTE is still present so that a subsequent write
> > does not necessarily propagate the dirty bit to the underlying PTE any more.
> > Reclaim at some unknown time at the future may then see that the PTE is still
> > clean and discard the page even though a write has happened in the meantime.
> > I think this is possible but I could have missed some protection in madv_free
> > that prevents it happening."
> > 
> > This patch aims for solving both problems all at once and is ready for
> > other problem with KSM, MADV_FREE and soft-dirty story[3].
> > 
> > TLB batch API(tlb_[gather|finish]_mmu] uses [set|clear]_tlb_flush_pending
> > and mmu_tlb_flush_pending so that when tlb_finish_mmu is called, we can catch
> > there are parallel threads going on. In that case, flush TLB to prevent
> > for user to access memory via stale TLB entry although it fail to gather
> > pte entry.
> > 
> > I confiremd this patch works with [4] test program Nadav gave so this patch
> > supersedes "mm: Always flush VMA ranges affected by zap_page_range v2"
> > in current mmotm.
> > 
> > NOTE:
> > This patch modifies arch-specific TLB gathering interface(x86, ia64,
> > s390, sh, um). It seems most of architecture are straightforward but s390
> > need to be careful because tlb_flush_mmu works only if mm->context.flush_mm
> > is set to non-zero which happens only a pte entry really is cleared by
> > ptep_get_and_clear and friends. However, this problem never changes the
> > pte entries but need to flush to prevent memory access from stale tlb.
> > 
> > Any thoughts?
> > 
> 
> The cc list is somewhat ..... extensive, given the topic. Trim it if
> there is another version.

Most of them are maintainers and mailling list for each architecures
I am changing. I'm not sure what I can trim. As you said it's rather
extensive, I will trim mailing list for each arch but keep maintainers
and linux-arch.

> 
> > index 3f2eb76243e3..8c26961f0503 100644
> > --- a/arch/arm/include/asm/tlb.h
> > +++ b/arch/arm/include/asm/tlb.h
> > @@ -163,13 +163,26 @@ tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start
> >  #ifdef CONFIG_HAVE_RCU_TABLE_FREE
> >  	tlb->batch = NULL;
> >  #endif
> > +	set_tlb_flush_pending(tlb->mm);
> >  }
> >  
> >  static inline void
> >  tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
> >  {
> > -	tlb_flush_mmu(tlb);
> > +	/*
> > +	 * If there are parallel threads are doing PTE changes on same range
> > +	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
> > +	 * flush by batching, a thread has stable TLB entry can fail to flush
> > +	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> > +	 * if we detect parallel PTE batching threads.
> > +	 */
> > +	if (mm_tlb_flush_pending(tlb->mm, false) > 1) {
> > +		tlb->range_start = start;
> > +		tlb->range_end = end;
> > +	}
> >  
> > +	tlb_flush_mmu(tlb);
> > +	clear_tlb_flush_pending(tlb->mm);
> >  	/* keep the page table cache within bounds */
> >  	check_pgt_cache();
> >  
> 
> mm_tlb_flush_pending shouldn't be taking a barrier specific arg. I expect
> this to change in the future and cause a conflict. At least I think in
> this context, it's the conditional barrier stuff.
> 

Yub. I saw your comment to Nadav so I expect you want mm_tlb_flush_pending
be called under pte lock. However, I will use it out of pte lock where
tlb_finish_mmu, however, in that case, atomic op and barrier
to prevent compiler reordering between tlb flush and atomic_read
in mm_tlb_flush_pending are enough to work.

> That aside, it's very unfortunate that the return value of
> mm_tlb_flush_pending really matters. Knowing why 1 is magic there requires
> knowledge of the internals on a per-arch basis which is a bit nuts.
> Consider renaming this to mm_tlb_flush_parallel() to return true if there
> is a nr_pending > 1 with comments explaining why. I don't think any of
> the callers expect a nr_pending of 0 ever. That removes some knowledge of
> the specifics.

Okay. If you are not strong against, I prefer mm_tlb_flush_nested
which returns true if nr_pending > 1.

> 
> The arch-specific changes to tlb_gather_mmu are almost all identical.
> It's a little tricky to split the arch layer and core mm to have all
> the set/clear of mm_tlb_flush_pending handled by the core mm.  It's not
> required but it would be preferred. The set one is obvious. rename
> tlb_gather_mmu to arch_tlb_gather_mmu (including the generic implementation)
> and create a tlb_gather_mmu alias that calls arch_tlb_gather_mmu and
> set_tlb_flush_pending.
> 
> The clear is not as straight-forward but can be done by creating a new
> arch helper that handles this hunk on a per-arch basis
> 
> > +     if (mm_tlb_flush_pending(tlb->mm, false) > 1) {
> > +             tlb->start = start;
> > +             tlb->end = end;
> > +     }
> 
> It'll be churn initially but it means any different handling in the TLB
> batching area will be mostly a core concern.

Fair enough. I will respin next week.
Thanks for the review, Mel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
