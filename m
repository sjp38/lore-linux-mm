Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 945CA8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 07:52:09 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 90-v6so2440700pla.18
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 04:52:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a3-v6si21814579plc.50.2018.09.19.04.52.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Sep 2018 04:52:08 -0700 (PDT)
Date: Wed, 19 Sep 2018 13:51:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 01/11] asm-generic/tlb: Provide a comment
Message-ID: <20180919115158.GD24124@hirez.programming.kicks-ass.net>
References: <20180913092110.817204997@infradead.org>
 <20180913092811.894806629@infradead.org>
 <20180914164857.GG6236@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180914164857.GG6236@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Fri, Sep 14, 2018 at 05:48:57PM +0100, Will Deacon wrote:

> > + *  - mmu_gather::fullmm
> > + *
> > + *    A flag set by tlb_gather_mmu() to indicate we're going to free
> > + *    the entire mm; this allows a number of optimizations.
> > + *
> > + *    XXX list optimizations
> 
> On arm64, we can elide the invalidation altogether because we won't
> re-allocate the ASID. We also have an invalidate-by-ASID (mm) instruction,
> which we could use if we needed to.

Right, but I was also struggling to put into words the normal fullmm
case.

I now ended up with:

--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -82,7 +82,11 @@
  *    A flag set by tlb_gather_mmu() to indicate we're going to free
  *    the entire mm; this allows a number of optimizations.
  *
- *    XXX list optimizations
+ *    - We can ignore tlb_{start,end}_vma(); because we don't
+ *      care about ranges. Everything will be shot down.
+ *
+ *    - (RISC) architectures that use ASIDs can cycle to a new ASID
+ *      and delay the invalidation until ASID space runs out.
  *
  *  - mmu_gather::need_flush_all
  *

Does that about cover things; or do we need more?

> > + *
> > + *  - mmu_gather::need_flush_all
> > + *
> > + *    A flag that can be set by the arch code if it wants to force
> > + *    flush the entire TLB irrespective of the range. For instance
> > + *    x86-PAE needs this when changing top-level entries.
> > + *
> > + * And requires the architecture to provide and implement tlb_flush().
> > + *
> > + * tlb_flush() may, in addition to the above mentioned mmu_gather fields, make
> > + * use of:
> > + *
> > + *  - mmu_gather::start / mmu_gather::end
> > + *
> > + *    which (when !need_flush_all; fullmm will have start = end = ~0UL) provides
> > + *    the range that needs to be flushed to cover the pages to be freed.
> 
> I don't understand the mention of need_flush_all here -- I didn't think it
> was used by the core code at all.

The core does indeed not use that flag; but if the architecture set
that, the range is still ignored.

Can you suggest clearer wording?
