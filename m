Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 9ECAE6B005C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 03:14:12 -0400 (EDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 28 Jun 2012 08:14:10 +0100
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5S7Dktc2293838
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:13:46 +0100
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5S6wOMD014535
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 02:58:26 -0400
Date: Thu, 28 Jun 2012 09:13:42 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 11/20] mm, s390: Convert to use generic mmu_gather
Message-ID: <20120628091342.54d4f4eb@de.ibm.com>
In-Reply-To: <1340835199.10063.76.camel@twins>
References: <20120627211540.459910855@chello.nl>
	<20120627212831.353649870@chello.nl>
	<1340835199.10063.76.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A.
 Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Thu, 28 Jun 2012 00:13:19 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Wed, 2012-06-27 at 23:15 +0200, Peter Zijlstra wrote:
> > 
> > S390 doesn't need a TLB flush after ptep_get_and_clear_full() and
> > before __tlb_remove_page() because its ptep_get_and_clear*() family
> > already does a full TLB invalidate. Therefore force it to use
> > tlb_fast_mode. 
> 
> On that.. ptep_get_and_clear() says:
> 
> /*                                                                                             
>  * This is hard to understand. ptep_get_and_clear and ptep_clear_flush                         
>  * both clear the TLB for the unmapped pte. The reason is that                                 
>  * ptep_get_and_clear is used in common code (e.g. change_pte_range)                           
>  * to modify an active pte. The sequence is                                                    
>  *   1) ptep_get_and_clear                                                                     
>  *   2) set_pte_at                                                                             
>  *   3) flush_tlb_range                                                                        
>  * On s390 the tlb needs to get flushed with the modification of the pte                       
>  * if the pte is active. The only way how this can be implemented is to                        
>  * have ptep_get_and_clear do the tlb flush. In exchange flush_tlb_range                       
>  * is a nop.                                                                                   
>  */ 
> 
> I think there is another way, arch_{enter,leave}_lazy_mmu_mode() seems
> to wrap these sites so you can do as SPARC64 and PPC do and batch
> through there.
> 
> That should save a number of TLB invalidates..

Unfortunately that is not good enough. The point is that a pte that can
be referenced by another cpu may not be modified without using one of
the special instructions that flushes the TLBs on all cpu at the same
time. It really is one pte at a time if more than one cpu attached a
particular mm.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
