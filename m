Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE0426B2831
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 00:54:35 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j189-v6so3896123oih.11
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 21:54:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n63-v6si2391292oif.143.2018.08.22.21.54.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 21:54:34 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7N4nKHE054358
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 00:54:33 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2m1kcmdjxy-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 00:54:33 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <benh@au1.ibm.com>;
	Thu, 23 Aug 2018 05:54:31 +0100
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
From: Benjamin Herrenschmidt <benh@au1.ibm.com>
Reply-To: benh@au1.ibm.com
Date: Thu, 23 Aug 2018 14:54:20 +1000
In-Reply-To: <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
References: <20180822153012.173508681@infradead.org>
	 <20180822154046.823850812@infradead.org>
	 <20180822155527.GF24124@hirez.programming.kicks-ass.net>
	 <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
	 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
Mime-Version: 1.0
Message-Id: <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, 2018-08-22 at 20:59 -0700, Linus Torvalds wrote:
> On Wed, Aug 22, 2018 at 8:45 PM Nicholas Piggin <npiggin@gmail.com> wrote:
> > 
> > powerpc/radix has no such issue, it already does this tracking.
> 
> Yeah, I now realize that this was why you wanted to add that hacky
> thing to the generic code, so that you can add the tlb_flush_pgtable()
> call.
> 
> I thought it was because powerpc had some special flush instruction
> for it, and the regular tlb flush didn't do it. But no. It was because
> the regular code had lost the tlb flush _entirely_, because powerpc
> didn't want it.

Heh :-) Well, back on hash we didn't (we do now with Radix) but I
wouldn't blame us for the generic code being broken ... the RCU table
freeing was in arch/powerpc at the time :-) I don't think it was us
making it generic :)

> > We were discussing this a couple of months ago, I wasn't aware of ARM's
> > issue but I suggested x86 could go the same way as powerpc.
> 
> The problem is that x86 _used_ to do this all correctly long long ago.
> 
> And then we switched over to the "generic" table flushing (which
> harkens back to the powerpc code).

Yes, we wrote it the RCU stuff to solve the races with SW walking,
which is completely orthogonal with HW walking & TLB content. We didn't
do the move to generic code though ;-)

> Which actually turned out to be not generic at all, and did not flush
> the internal pages like x86 used to (back when x86 just used
> tlb_remove_page for everything).

Well, having RCU do the flushing is rather generic, it makes sense
whenever there's somebody doing a SW walk *and* you don't have IPIs to
synchronize your flushes (ie, anybody with HW TLB invalidation
broadcast basically, so ARM and us).

> So as a result, x86 had unintentionally lost the TLB flush we used to
> have, because tlb_remove_table() had lost the tlb flushing because of
> a powerpc quirk.

This is a somewhat odd way of putting the "blame" :-) But yeah ok...

> You then added it back as a hacky per-architecture hook (apparently
> having realized that you never did it at all), which didn't fix the
> unintentional lack of flushing on x86.
> 
> So now we're going to do it right.  No more "oh, powerpc didn't need
> to flush because the hash tables weren't in the tlb at all" thing in
> the generic code that then others need to work around.

So we do need a different flush instruction for the page tables vs. the
normal TLB pages. 

Cheers,
Ben.
