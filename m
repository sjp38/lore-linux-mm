Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 410959003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 03:17:58 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so15070526wib.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 00:17:57 -0700 (PDT)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id p2si13248844wjf.71.2015.07.24.00.17.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jul 2015 00:17:56 -0700 (PDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 24 Jul 2015 08:17:55 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4BC302190023
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 08:17:28 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6O7HpOY31654132
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:17:51 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6O7Hp5r006112
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 01:17:51 -0600
Date: Fri, 24 Jul 2015 09:17:49 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] mm: Flush the TLB for a single address in a huge page
Message-ID: <20150724091749.766df0d7@mschwide>
In-Reply-To: <20150723164921.GH27052@e104818-lin.cambridge.arm.com>
References: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com>
	<alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com>
	<CAHkRjk7=VMG63VfZdWbZqYu8FOa9M+54Mmdro661E2zt3WToog@mail.gmail.com>
	<55B021B1.5020409@intel.com>
	<20150723104938.GA27052@e104818-lin.cambridge.arm.com>
	<20150723141303.GB23799@redhat.com>
	<20150723164921.GH27052@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Thu, 23 Jul 2015 17:49:21 +0100
Catalin Marinas <catalin.marinas@arm.com> wrote:

> On Thu, Jul 23, 2015 at 03:13:03PM +0100, Andrea Arcangeli wrote:
> > On Thu, Jul 23, 2015 at 11:49:38AM +0100, Catalin Marinas wrote:
> > > On Thu, Jul 23, 2015 at 12:05:21AM +0100, Dave Hansen wrote:
> > > > On 07/22/2015 03:48 PM, Catalin Marinas wrote:
> > > > > You are right, on x86 the tlb_single_page_flush_ceiling seems to be
> > > > > 33, so for an HPAGE_SIZE range the code does a local_flush_tlb()
> > > > > always. I would say a single page TLB flush is more efficient than a
> > > > > whole TLB flush but I'm not familiar enough with x86.
> > > > 
> > > > The last time I looked, the instruction to invalidate a single page is
> > > > more expensive than the instruction to flush the entire TLB. 
> [...]
> > > Another question is whether flushing a single address is enough for a
> > > huge page. I assumed it is since tlb_remove_pmd_tlb_entry() only adjusts
> [...]
> > > the mmu_gather range by PAGE_SIZE (rather than HPAGE_SIZE) and
> > > no-one complained so far. AFAICT, there are only 3 architectures
> > > that don't use asm-generic/tlb.h but they all seem to handle this
> > > case:
> > 
> > Agreed that archs using the generic tlb.h that sets the tlb->end to
> > address+PAGE_SIZE should be fine with the flush_tlb_page.
> > 
> > > arch/arm: it implements tlb_remove_pmd_tlb_entry() in a similar way to
> > > the generic one
> > > 
> > > arch/s390: tlb_remove_pmd_tlb_entry() is a no-op
> > 
> > I guess s390 is fine too but I'm not convinced that the fact it won't
> > adjust the tlb->start/end is a guarantees that flush_tlb_page is
> > enough when a single 2MB TLB has to be invalidated (not during range
> > zapping).

tlb_remove_pmd_tlb_entry() is a no-op because pmdp_get_and_clear_full()
already did the job. s390 is special in regard to TLB flushing, the
machines have the requirement that a pte/pmd needs to be invalidated
with specific instruction if there is a process that might use the
translation path. In this case the IDTE instruction needs to be used
which sets the invalid bit in the pmd *and* flushes the TLB at the
same time. The code still tries to be lazy and do batched flushes to
improve performance. All in all quite complicated..

> > For the range zapping, could the arch decide to unconditionally flush
> > the whole TLB without doing the tlb->start/end tracking by overriding
> > tlb_gather_mmu in a way that won't call __tlb_reset_range? There seems
> > to be quite some flexibility in the per-arch tlb_gather_mmu setup in
> > order to unconditionally set tlb->start/end to the total range zapped,
> > without actually narrowing it down during the pagetable walk.
> 
> You are right, looking at the s390 code, tlb_finish_mmu() flushes the
> whole TLB, so the ranges don't seem to matter. I'm cc'ing the s390
> maintainers to confirm whether this patch affects them in any way:
> 
> https://lkml.org/lkml/2015/7/22/521
> 
> IIUC, all the functions touched by this patch are implemented by s390 in
> its specific way, so I don't think it makes any difference:
> 
> pmdp_set_access_flags
> pmdp_clear_flush_young
> pmdp_huge_clear_flush
> pmdp_splitting_flush
> pmdp_invalidate

tlb_finish_mmu may flush all entries for a specific address space, not
the whole TLB. And it does so only for batched operations. If all changes
to the page tables have been done with IPTE/IDTE then flush_mm will not
be set and no full address space flush is done.

But to answer the question: s390 is fine with the change outlined in
https://lkml.org/lkml/2015/7/22/521

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
