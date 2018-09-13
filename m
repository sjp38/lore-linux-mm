Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE9428E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 06:57:51 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id 51-v6so4446782wra.18
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 03:57:51 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id d16-v6si3357552wrp.194.2018.09.13.03.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Sep 2018 03:57:50 -0700 (PDT)
Date: Thu, 13 Sep 2018 12:57:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 01/11] asm-generic/tlb: Provide a comment
Message-ID: <20180913105738.GW24124@hirez.programming.kicks-ass.net>
References: <20180913092110.817204997@infradead.org>
 <20180913092811.894806629@infradead.org>
 <20180913123014.0d9321b8@mschwideX1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180913123014.0d9321b8@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Thu, Sep 13, 2018 at 12:30:14PM +0200, Martin Schwidefsky wrote:

> > + * The mmu_gather data structure is used by the mm code to implement the
> > + * correct and efficient ordering of freeing pages and TLB invalidations.
> > + *
> > + * This correct ordering is:
> > + *
> > + *  1) unhook page
> > + *  2) TLB invalidate page
> > + *  3) free page
> > + *
> > + * That is, we must never free a page before we have ensured there are no live
> > + * translations left to it. Otherwise it might be possible to observe (or
> > + * worse, change) the page content after it has been reused.
> > + *
> 
> This first comment already includes the reason why s390 is probably better off
> with its own mmu-gather implementation. It depends on the situation if we have
> 
> 1) unhook the page and do a TLB flush at the same time
> 2) free page
> 
> or
> 
> 1) unhook page
> 2) free page
> 3) final TLB flush of the whole mm

that's the fullmm case, right?

> A variant of the second order we had in the past is to do the mm TLB flush first,
> then the unhooks and frees of the individual pages. The are some tricky corners
> switching between the two variants, see finish_arch_post_lock_switch.
> 
> The point is: we *never* have the order 1) unhook, 2) TLB invalidate, 3) free.
> If there is concurrency due to a multi-threaded application we have to do the
> unhook of the page-table entry and the TLB flush with a single instruction.

You can still get the thing you want if for !fullmm you have a no-op
tlb_flush() implementation, assuming your arch page-table frobbing thing
has the required TLB flush in.

Note that that's not utterly unlike how the PowerPC/Sparc hash things
work, they clear and invalidate entries different from others and don't
use the mmu_gather tlb-flush.
