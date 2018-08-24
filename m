Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2C326B3167
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 16:24:58 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g12-v6so118920plo.1
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 13:24:58 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v18-v6sor2183823pgj.123.2018.08.24.13.24.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 13:24:57 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: TLB flushes on fixmap changes
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com>
Date: Fri, 24 Aug 2018 13:24:54 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <9A38D3F4-2F75-401D-8B4D-83A844C9061B@gmail.com>
References: <20180822153012.173508681@infradead.org>
 <20180822154046.823850812@infradead.org>
 <20180822155527.GF24124@hirez.programming.kicks-ass.net>
 <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
 <20180823133958.GA1496@brain-police>
 <20180824084717.GK24124@hirez.programming.kicks-ass.net>
 <D74A89DF-0D89-4AB6-8A6B-93BEC9A83595@gmail.com>
 <20180824180438.GS24124@hirez.programming.kicks-ass.net>
 <56A9902F-44BE-4520-A17C-26650FCC3A11@gmail.com>
 <CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

at 12:31 PM, Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Fri, Aug 24, 2018 at 11:36 AM Nadav Amit <nadav.amit@gmail.com> wrote:
>>> Urgh.. weren't the fixmaps per cpu? Bah, I remember looking at this
>>> during PTI, but I seem to have forgotten everything again.
>> 
>> [ Changed the title. Sorry for hijacking the thread. ]
>> 
>> Since:
>> 
>> native_set_fixmap()->set_pte_vaddr()->pgd_offset_k()
> 
> The fixmaps should be entirely fixed after bootup to constant
> mappings, except for the KMAP ones, and they are indexed per-cpu.
> 
> That's what my mental model is, at least.
> 
> Can you actually find something that changes the fixmaps after boot
> (again, ignoring kmap)?

At least the alternatives mechanism appears to do so.
 
IIUC the following path is possible when adding a module:

	jump_label_add_module()
	->__jump_label_update()
	->arch_jump_label_transform()
	->__jump_label_transform()
	->text_poke_bp()
	->text_poke()
	->set_fixmap()
	
And a similar path can happen when static_key_enable/disable() is called.
