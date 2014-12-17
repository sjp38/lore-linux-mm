Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 565756B006E
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 11:53:21 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so16702038pab.35
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 08:53:21 -0800 (PST)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id u4si6308416pdd.185.2014.12.17.08.53.18
        for <linux-mm@kvack.org>;
        Wed, 17 Dec 2014 08:53:19 -0800 (PST)
Date: Wed, 17 Dec 2014 16:53:10 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: post-3.18 performance regression in TLB flushing code
Message-ID: <20141217165310.GJ870@arm.com>
References: <5490A5F8.6050504@sr71.net>
 <20141217100810.GA3461@arm.com>
 <CA+55aFyVxOw0upa=At6MmiNYEHzfPz4rE5bZUBCs9h4vKGh1iA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyVxOw0upa=At6MmiNYEHzfPz4rE5bZUBCs9h4vKGh1iA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave@sr71.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Simek <monstr@monstr.eu>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Dec 17, 2014 at 04:28:23PM +0000, Linus Torvalds wrote:
> On Wed, Dec 17, 2014 at 2:08 AM, Will Deacon <will.deacon@arm.com> wrote:
> >
> > I think there are a couple of things you could try to see if that 2% comes
> > back:
> >
> >   * Revert the patch and try the one here [1] instead (which only does part
> >     (1) of the above).
> >
> > -- or --
> >
> >   * Instead of adding the tlb->end check to tlb_flush_mmu, add it to
> >     tlb_flush_mmu_free
> 
> or just move the check back to tlb_flush_mmu() where it belongs.
> 
> I don't see why you moved it to "tlb_flush_mmu_tlbonly()" in the first
> place, or why you'd now want to add it to tlb_flush_mmu_free().
> 
> Both of those helper functions have two callers:
> 
>  - tlb_flush_mmu(). Doing it here (instead of in the helper functions)
> is the right thing to do
> 
>  - the "force_flush" case: we know we have added at least one page to
> the TLB state so checking for it is pointless.
> 
> So I'm not seeing why you wanted to do it in tlb_flush_mmu_tlbonly(),
> and now add it to tlb_flush_mmu_free(). That seems bogus.

I guess I was being overly cautious in case tlb_flush_mmu_tlbonly grows
additional users, but you're right.

> So why not just this trivial patch, to make the logic be the same it
> used to be (just using "end > 0" instead of the old "need_flush")?

Looks fine to me... Dave?

Will

> diff --git a/mm/memory.c b/mm/memory.c
> index c3b9097251c5..6efe36a998ba 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -235,9 +235,6 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long
>  
>  static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
>  {
> -	if (!tlb->end)
> -		return;
> -
>  	tlb_flush(tlb);
>  	mmu_notifier_invalidate_range(tlb->mm, tlb->start, tlb->end);
>  #ifdef CONFIG_HAVE_RCU_TABLE_FREE
> @@ -259,6 +256,9 @@ static void tlb_flush_mmu_free(struct mmu_gather *tlb)
>  
>  void tlb_flush_mmu(struct mmu_gather *tlb)
>  {
> +	if (!tlb->end)
> +		return;
> +
>  	tlb_flush_mmu_tlbonly(tlb);
>  	tlb_flush_mmu_free(tlb);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
