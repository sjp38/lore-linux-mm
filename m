Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id C8B2E8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 12:48:42 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id c46-v6so4237432otd.12
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:48:42 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s128-v6si4190647ois.140.2018.09.14.09.48.40
        for <linux-mm@kvack.org>;
        Fri, 14 Sep 2018 09:48:40 -0700 (PDT)
Date: Fri, 14 Sep 2018 17:48:57 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC][PATCH 01/11] asm-generic/tlb: Provide a comment
Message-ID: <20180914164857.GG6236@arm.com>
References: <20180913092110.817204997@infradead.org>
 <20180913092811.894806629@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180913092811.894806629@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

Hi Peter,

On Thu, Sep 13, 2018 at 11:21:11AM +0200, Peter Zijlstra wrote:
> Write a comment explaining some of this..

This comment is much-needed, thanks! Some comments inline.

> + * The mmu_gather API consists of:
> + *
> + *  - tlb_gather_mmu() / tlb_finish_mmu(); start and finish a mmu_gather
> + *
> + *    Finish in particular will issue a (final) TLB invalidate and free
> + *    all (remaining) queued pages.
> + *
> + *  - tlb_start_vma() / tlb_end_vma(); marks the start / end of a VMA
> + *
> + *    Defaults to flushing at tlb_end_vma() to reset the range; helps when
> + *    there's large holes between the VMAs.
> + *
> + *  - tlb_remove_page() / __tlb_remove_page()
> + *  - tlb_remove_page_size() / __tlb_remove_page_size()
> + *
> + *    __tlb_remove_page_size() is the basic primitive that queues a page for
> + *    freeing. __tlb_remove_page() assumes PAGE_SIZE. Both will return a
> + *    boolean indicating if the queue is (now) full and a call to
> + *    tlb_flush_mmu() is required.
> + *
> + *    tlb_remove_page() and tlb_remove_page_size() imply the call to
> + *    tlb_flush_mmu() when required and has no return value.
> + *
> + *  - tlb_change_page_size()

This doesn't seem to exist in my tree.
[since realised you rename to it in the next patch]

> + *
> + *    call before __tlb_remove_page*() to set the current page-size; implies a
> + *    possible tlb_flush_mmu() call.
> + *
> + *  - tlb_flush_mmu() / tlb_flush_mmu_tlbonly() / tlb_flush_mmu_free()
> + *
> + *    tlb_flush_mmu_tlbonly() - does the TLB invalidate (and resets
> + *                              related state, like the range)
> + *
> + *    tlb_flush_mmu_free() - frees the queued pages; make absolutely
> + *			     sure no additional tlb_remove_page()
> + *			     calls happen between _tlbonly() and this.
> + *
> + *    tlb_flush_mmu() - the above two calls.
> + *
> + *  - mmu_gather::fullmm
> + *
> + *    A flag set by tlb_gather_mmu() to indicate we're going to free
> + *    the entire mm; this allows a number of optimizations.
> + *
> + *    XXX list optimizations

On arm64, we can elide the invalidation altogether because we won't
re-allocate the ASID. We also have an invalidate-by-ASID (mm) instruction,
which we could use if we needed to.

> + *
> + *  - mmu_gather::need_flush_all
> + *
> + *    A flag that can be set by the arch code if it wants to force
> + *    flush the entire TLB irrespective of the range. For instance
> + *    x86-PAE needs this when changing top-level entries.
> + *
> + * And requires the architecture to provide and implement tlb_flush().
> + *
> + * tlb_flush() may, in addition to the above mentioned mmu_gather fields, make
> + * use of:
> + *
> + *  - mmu_gather::start / mmu_gather::end
> + *
> + *    which (when !need_flush_all; fullmm will have start = end = ~0UL) provides
> + *    the range that needs to be flushed to cover the pages to be freed.

I don't understand the mention of need_flush_all here -- I didn't think it
was used by the core code at all.

> + *
> + *  - mmu_gather::freed_tables
> + *
> + *    set when we freed page table pages
> + *
> + *  - tlb_get_unmap_shift() / tlb_get_unmap_size()
> + *
> + *    returns the smallest TLB entry size unmapped in this range
> + *
> + * Additionally there are a few opt-in features:
> + *
> + *  HAVE_MMU_GATHER_PAGE_SIZE
> + *
> + *  This ensures we call tlb_flush() every time tlb_change_page_size() actually
> + *  changes the size and provides mmu_gather::page_size to tlb_flush().

Ah, you add this later in the series. I think Nick reckoned we could get rid
of this (the page_size field) eventually...

Will
