Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2BAF6B28A9
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 02:48:42 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j189-v6so4077232oih.11
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 23:48:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k145-v6si2663642oih.427.2018.08.22.23.48.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 23:48:41 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7N6i6tM042273
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 02:48:40 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2m1p1cv65s-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 02:48:40 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 23 Aug 2018 07:48:37 +0100
Date: Thu, 23 Aug 2018 08:48:28 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
In-Reply-To: <CA+55aFw3edpf6JBn-pbqYhtvMPZJ7VmJTkGfO_9=uQMO=dV32g@mail.gmail.com>
References: <20180822153012.173508681@infradead.org>
	<20180822154046.823850812@infradead.org>
	<20180822155527.GF24124@hirez.programming.kicks-ass.net>
	<20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
	<CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
	<776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
	<CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
	<CA+55aFw3edpf6JBn-pbqYhtvMPZJ7VmJTkGfO_9=uQMO=dV32g@mail.gmail.com>
MIME-Version: 1.0
Message-Id: <20180823084828.3d4d0527@mschwideX1>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, 22 Aug 2018 22:20:32 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Aug 22, 2018 at 10:11 PM Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > So instead, when you get to the actual "tlb_flush(tlb)", you do
> > exactly that - flush the tlb. And the mmu_gather structure shows you
> > how much you need to flush. If you see that "freed_tables" is set,
> > then you know that you need to also do the special instruction to
> > flush the inner level caches. The range continues to show the page
> > range.  
> 
> Note that this obviously works fine for a hashed table model too - you
> just ignore the "freed_tables" bit entirely and continue to do
> whatever you always did.
> 
> And we can ignore it on x86 too, because we just see the range, and we
> invalidate the range, and that will always invalidate the mid-level
> caching too.
> 
> So the new bit is literally for arm and powerpc-radix (and maybe
> s390), but we want to make the actual VM interface truly generic and
> not have one set of code with five different behaviors (which we
> _currently_ kind of have with the whole in addition to all the
> HAVE_RCU_TABLE_FREE etc config options that modify how the code works.
> 
> It would be good to also cut down on the millions of functions that
> each architecture can override, because Christ, it got very confusing
> at times to follow just how the code flowed from generic code to
> architecture-specific macros back to generic code and then
> arch-specific inline helper functions.
> 
> It's a maze of underscores and "page" vs "table", and "flush" vs "remove" etc.
> 
> But that "it would be good to really make everybody to use as much of
> the generic code as possible" and everybody have the same pattern,
> that's a future thing. But the whole "let's just add that
> "freed_tables" thing would be part of trying to get people to use the
> same overall pattern, even if some architectures might not care about
> that detail.

For s390 the new freed_tables bit looks to be step into the right
direction. Right now there is the flush_mm bit in the mm->context
that I use to keep track of the need for a global flush of the mm.
The flush_mm bit is currently used for both lazy PTE flushing and
TLB flushes for freed page table pages.

I'll look into it once the generic patch is merged. The switch to
the generic mmu_gather is certainly not a change that can be done
in a hurry, we had too many subtle TLB flush issues in the past.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
