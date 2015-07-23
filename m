Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6586B6B0260
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 10:13:08 -0400 (EDT)
Received: by qkfc129 with SMTP id c129so131157387qkf.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 07:13:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y39si5952695qgy.79.2015.07.23.07.13.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 07:13:07 -0700 (PDT)
Date: Thu, 23 Jul 2015 16:13:03 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Flush the TLB for a single address in a huge page
Message-ID: <20150723141303.GB23799@redhat.com>
References: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com>
 <alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com>
 <CAHkRjk7=VMG63VfZdWbZqYu8FOa9M+54Mmdro661E2zt3WToog@mail.gmail.com>
 <55B021B1.5020409@intel.com>
 <20150723104938.GA27052@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150723104938.GA27052@e104818-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jul 23, 2015 at 11:49:38AM +0100, Catalin Marinas wrote:
> On Thu, Jul 23, 2015 at 12:05:21AM +0100, Dave Hansen wrote:
> > On 07/22/2015 03:48 PM, Catalin Marinas wrote:
> > > You are right, on x86 the tlb_single_page_flush_ceiling seems to be
> > > 33, so for an HPAGE_SIZE range the code does a local_flush_tlb()
> > > always. I would say a single page TLB flush is more efficient than a
> > > whole TLB flush but I'm not familiar enough with x86.
> > 
> > The last time I looked, the instruction to invalidate a single page is
> > more expensive than the instruction to flush the entire TLB. 
> 
> I was thinking of the overall cost of re-populating the TLB after being
> nuked rather than the instruction itself.

Unless I'm not aware about timing differences in flushing 2MB TLB
entries vs flushing 4kb TLB entries with invlpg, the benchmarks that
have been run to tune the optimal tlb_single_page_flush_ceiling value,
should already guarantee us that this is a valid optimization (as we
just got one entry, we're not even close to the 33 ceiling that makes
it more a grey area).

> > That said, I can't imagine this will hurt anything.  We also have TLBs
> > that can mix 2M and 4k pages and I don't think we did back when we put
> > that code in originally.

Dave, I'm confused about this. We should still stick to an invariant
that we can't ever mix 2M and 4k TLB entries if their mappings end up
overlapping on the same physical memory (if this isn't enforced in
common code, some x86 implementation errata triggers, and it really
oopses with machine checks so it's not just theoretical). Perhaps I
misunderstood what you meant with mix 2M and 4k pages though.

> Another question is whether flushing a single address is enough for a
> huge page. I assumed it is since tlb_remove_pmd_tlb_entry() only adjusts

That's the primary reason why the range flush was used currently (and
it must be still used in pmdp_collapse_flush as that deals with 4k TLB
entries, but your patch correctly isn't touching that one).

I recall having used flush_tlb_page initially for the 2MB invalidates,
but then I switched to the range version purely to be safer. If we can
optimize this now I'd certainly be happy about that. Back then there
was not yet tlb_remove_pmd_tlb_entry which already started to optimize
things for this.

> the mmu_gather range by PAGE_SIZE (rather than HPAGE_SIZE) and
> no-one complained so far. AFAICT, there are only 3 architectures
> that don't use asm-generic/tlb.h but they all seem to handle this
> case:

Agreed that archs using the generic tlb.h that sets the tlb->end to
address+PAGE_SIZE should be fine with the flush_tlb_page.

> arch/arm: it implements tlb_remove_pmd_tlb_entry() in a similar way to
> the generic one
> 
> arch/s390: tlb_remove_pmd_tlb_entry() is a no-op

I guess s390 is fine too but I'm not convinced that the fact it won't
adjust the tlb->start/end is a guarantees that flush_tlb_page is
enough when a single 2MB TLB has to be invalidated (not during range
zapping).

For the range zapping, could the arch decide to unconditionally flush
the whole TLB without doing the tlb->start/end tracking by overriding
tlb_gather_mmu in a way that won't call __tlb_reset_range? There seems
to be quite some flexibility in the per-arch tlb_gather_mmu setup in
order to unconditionally set tlb->start/end to the total range zapped,
without actually narrowing it down during the pagetable walk.

This is why I was thinking a flush_tlb_pmd_huge_page might have been
safer. However if hugetlbfs is basically assuming flush_tlb_page works
like Dave said, and if s390 is fine as well, I think we can just apply
this patch which follows the generic tlb_remove_pmd_tlb_entry
optimization.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
