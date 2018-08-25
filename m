Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B14526B32D6
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 22:29:22 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a26-v6so6903437pgw.7
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 19:29:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 1-v6sor2935026plp.97.2018.08.24.19.29.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 19:29:21 -0700 (PDT)
Date: Fri, 24 Aug 2018 19:29:02 -0700
In-Reply-To: <CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
References: <20180822153012.173508681@infradead.org> <20180822154046.823850812@infradead.org> <20180822155527.GF24124@hirez.programming.kicks-ass.net> <20180823134525.5f12b0d3@roar.ozlabs.ibm.com> <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com> <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com> <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com> <20180823133958.GA1496@brain-police> <20180824084717.GK24124@hirez.programming.kicks-ass.net> <D74A89DF-0D89-4AB6-8A6B-93BEC9A83595@gmail.com> <20180824180438.GS24124@hirez.programming.kicks-ass.net> <56A9902F-44BE-4520-A17C-26650FCC3A11@gmail.com> <CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com> <9A38D3F4-2F75-401D-8B4D-83A844C9061B@gmail.com> <CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: TLB flushes on fixmap changes
From: nadav.amit@gmail.com
Message-ID: <8E0D8C66-6F21-4890-8984-B6B3082D4CC5@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Masami Hiramatsu <mhiramat@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>



On August 24, 2018 5:58:43 PM PDT, Linus Torvalds <torvalds@linux-foundati=
on=2Eorg> wrote:
>Adding a few people to the cc=2E
>
>On Fri, Aug 24, 2018 at 1:24 PM Nadav Amit <nadav=2Eamit@gmail=2Ecom>
>wrote:
>> >
>> > Can you actually find something that changes the fixmaps after boot
>> > (again, ignoring kmap)?
>>
>> At least the alternatives mechanism appears to do so=2E
>>
>> IIUC the following path is possible when adding a module:
>>
>>         jump_label_add_module()
>>         ->__jump_label_update()
>>         ->arch_jump_label_transform()
>>         ->__jump_label_transform()
>>         ->text_poke_bp()
>>         ->text_poke()
>>         ->set_fixmap()
>
>Yeah, that looks a bit iffy=2E
>
>But making the tlb flush global wouldn't help=2E  This is running on a
>local core, and if there are other CPU's that can do this at the same
>time, then they'd just fight about the same mapping=2E
>
>Honestly, I think it's ok just because I *hope* this is all serialized
>anyway (jump_label_lock? But what about other users of text_poke?)=2E

The users should hold text_mutex=2E

>
>But I'd be a lot happier about it if it either used an explicit lock
>to make sure, or used per-cpu fixmap entries=2E

My concern is that despite the lock, one core would do a speculative page =
walk and cache a translation that soon after would become stale=2E

>
>And the tlb flush is done *after* the address is used, which is bogus
>anyway=2E

It seems to me that it is intended to remove the mapping that might be a s=
ecurity issue=2E=C2=A0

But anyhow, set_fixmap and clear_fixmap perform a local TLB flush, (in __s=
et_pte_vaddr()) so locally things should be fine=2E

>
>> And a similar path can happen when static_key_enable/disable() is
>called=2E
>
>Same comments=2E
>
>How about replacing that
>
>        local_irq_save(flags);
>       =2E=2E=2E do critical things here =2E=2E=2E
>        local_irq_restore(flags);
>
>in text_poke() with
>
>        static DEFINE_SPINLOCK(poke_lock);
>
>        spin_lock_irqsave(&poke_lock, flags);
>       =2E=2E=2E do critical things here =2E=2E=2E
>        spin_unlock_irqrestore(&poke_lock, flags);
>
>and moving the local_flush_tlb() to after the set_fixmaps, but before
>the access through the virtual address=2E
>
>But changing things to do a global tlb flush would just be wrong=2E

As I noted, I think that locking and local flushes as they are right now a=
re fine (besides the redundant flush)=2E

My concern is merely that speculative page walks on other cores would cach=
e stale entries=2E



--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E
