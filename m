Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5CC6B3F9F
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 04:54:17 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d22-v6so11391831pfn.3
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 01:54:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g3-v6sor4418695plo.94.2018.08.27.01.54.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 01:54:16 -0700 (PDT)
Date: Mon, 27 Aug 2018 18:54:03 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180827185403.7b46fae4@roar.ozlabs.ibm.com>
In-Reply-To: <20180827082045.GA24124@hirez.programming.kicks-ass.net>
References: <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
	<CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
	<20180823133958.GA1496@brain-police>
	<20180824084717.GK24124@hirez.programming.kicks-ass.net>
	<20180824113214.GK24142@hirez.programming.kicks-ass.net>
	<20180824113953.GL24142@hirez.programming.kicks-ass.net>
	<20180827150008.13bce08f@roar.ozlabs.ibm.com>
	<20180827074701.GW24124@hirez.programming.kicks-ass.net>
	<20180827180458.4af9b2ac@roar.ozlabs.ibm.com>
	<4ef8a2aa44db971340b0bcc4f73d639455dd4282.camel@kernel.crashing.org>
	<20180827082045.GA24124@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Mon, 27 Aug 2018 10:20:45 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Mon, Aug 27, 2018 at 06:09:50PM +1000, Benjamin Herrenschmidt wrote:
> 
> > Sadly our architecture requires a precise match between the page size
> > specified in the tlbie instruction and the entry in the TLB or it won't
> > be flushed.  
> 
> Argh.. OK I see. That is rather unfortunate and does seem to require
> something along the lines of tlb_remove_check_page_size_change().

Or we can do better with some more of our own data in mmu_gather,
but things that probably few or no other architectures want. I've
held off trying to put any crap in generic code because there's
other lower hanging fruit still, but I'd really rather just give
archs the ability to put their own data in there. I don't really
see a downside to it (divergence of course, but the existing
proliferation of code is much harder to follow than some data that
would be maintained and used purely by the arch, and beats having
to implement entirely your own mmu_gather).

Thanks,
Nick
