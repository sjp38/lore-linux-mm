Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5983B8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 12:15:30 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id m15-v6so6773841ioj.22
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 09:15:30 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id p135-v6si8881650itp.58.2018.09.19.09.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Sep 2018 09:15:28 -0700 (PDT)
Date: Wed, 19 Sep 2018 18:15:14 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] s390/tlb: convert to generic mmu_gather
Message-ID: <20180919161514.GK24124@hirez.programming.kicks-ass.net>
References: <20180918125151.31744-1-schwidefsky@de.ibm.com>
 <20180918125151.31744-3-schwidefsky@de.ibm.com>
 <20180919123849.GF24124@hirez.programming.kicks-ass.net>
 <20180919162809.30b5c416@mschwideX1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180919162809.30b5c416@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Sep 19, 2018 at 04:28:09PM +0200, Martin Schwidefsky wrote:
> On Wed, 19 Sep 2018 14:38:49 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Tue, Sep 18, 2018 at 02:51:51PM +0200, Martin Schwidefsky wrote:

> > > +        page_table_free_rcu(tlb, (unsigned long *) pte, address);  
> > 
> > (whitespace damage, fixed)
> > 
> > Also, could you perhaps explain the need for that
> > page_table_alloc/page_table_free code? That is, I get the comment about
> > using 2K page-table fragments out of 4k physical page, but why this
> > custom allocator instead of kmem_cache? It feels like there's a little
> > extra complication, but it's not immediately obvious what.
> 
> The kmem_cache code uses the fields of struct page for its tracking.
> pgtable_page_ctor uses the same fields, e.g. for the ptl. Last time
> I tried to convert the page_table_alloc/page_table_free to kmem_cache
> it just crashed. Plus the split of 4K pages into 2 2K fragments is
> done on a per mm basis, that should help a little bit with fragmentation.

Fair enough, thanks for the information.

> > It's that ASCE limit that makes it impossible to use the generic
> > helpers, right?
> 
> There are two problems, one of them is related to the ASCE limit:
> 
> 1) s390 supports 4 different page table layouts. 2-levels (2^31 bytes) for 31-bit compat,
>    3-levels (2^42 bytes) as the default for 64-bit, 4-levels (2^53) if 4 tera-bytes are
>    not enough and 5-levels (2^64) for the bragging rights.
>    The pxd_free_tlb() turn into nops if the number of page table levels require it.

Shiny, I think we (x86) have to choose at boot time which paging mode we
want and have to stick to it.

> 2) The mm->context.flush_mm indication.
>    That goes back to this beauty in the architecture:
> 
>     * "A valid table entry must not be changed while it is attached
>     * to any CPU and may be used for translation by that CPU except to
>     * (1) invalidate the entry by using INVALIDATE PAGE TABLE ENTRY,
>     * or INVALIDATE DAT TABLE ENTRY, (2) alter bits 56-63 of a page
>     * table entry, or (3) make a change by means of a COMPARE AND SWAP
>     * AND PURGE instruction that purges the TLB."
> 
>    If one CPU is doing a mmu_gather page table operation on the only active thread
>    in the system the individual page table updates are done in a lazy fashion with
>    simple stores. If a second CPU picks up another thread for execution, the
>    attach_count is increased and the page table updates are done with IPTE/IDTE
>    from now on. But there might by TLBs of around that are not flushed yet.
>    We may *not* let the second CPU see these TLBs, otherwise the CPU may start an
>    instruction, then loose the TLB without being able to recreate it. Due to that
>    the CPU can end up with a half finished instruction it can not roll back nor
>    complete, ending in a check-stop. The simplest example is MVC with a length
>    of e.g. 256 bytes. The instruction has to complete with all 256 bytes moved,
>    or no bytes may have at all.
>    That is where the mm->context.flush_mm indication comes into play, if the
>    second CPU finds the bit set at the time it attaches a thread, it will to
>    an IDTE for flush all TLBs for the mm.

Oh man.. what fun. Still, this bit could easily be set in the
__*_free_tlb() functions afaict. Still 1) above is enough.

Thanks!
