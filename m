Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 875526B38FA
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 00:43:15 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id o18-v6so7904316ybp.13
        for <linux-mm@kvack.org>; Sat, 25 Aug 2018 21:43:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x128-v6sor3117026ybe.136.2018.08.25.21.43.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 25 Aug 2018 21:43:13 -0700 (PDT)
Received: from mail-yw1-f50.google.com (mail-yw1-f50.google.com. [209.85.161.50])
        by smtp.gmail.com with ESMTPSA id d185-v6sm4784541ywf.100.2018.08.25.21.43.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Aug 2018 21:43:11 -0700 (PDT)
Received: by mail-yw1-f50.google.com with SMTP id w202-v6so4493434yww.3
        for <linux-mm@kvack.org>; Sat, 25 Aug 2018 21:43:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
References: <20180822153012.173508681@infradead.org> <20180822154046.823850812@infradead.org>
 <20180822155527.GF24124@hirez.programming.kicks-ass.net> <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
 <20180823133958.GA1496@brain-police> <20180824084717.GK24124@hirez.programming.kicks-ass.net>
 <D74A89DF-0D89-4AB6-8A6B-93BEC9A83595@gmail.com> <20180824180438.GS24124@hirez.programming.kicks-ass.net>
 <56A9902F-44BE-4520-A17C-26650FCC3A11@gmail.com> <CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com>
 <9A38D3F4-2F75-401D-8B4D-83A844C9061B@gmail.com> <CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
 <8E0D8C66-6F21-4890-8984-B6B3082D4CC5@gmail.com> <CALCETrWdeKBcEs7zAbpEM1YdYiT2UBXwPtF0mMTvcDX_KRpz1A@mail.gmail.com>
 <20180826112341.f77a528763e297cbc36058fa@kernel.org> <CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Sat, 25 Aug 2018 21:43:09 -0700
Message-ID: <CAGXu5j+xUbq_mu=2jvH2Vu+mviteZJqdPNTrxpaijwsuDdN-sw@mail.gmail.com>
Subject: Re: TLB flushes on fixmap changes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Masami Hiramatsu <mhiramat@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Sat, Aug 25, 2018 at 9:21 PM, Andy Lutomirski <luto@kernel.org> wrote:
> On Sat, Aug 25, 2018 at 7:23 PM, Masami Hiramatsu <mhiramat@kernel.org> wrote:
>> On Fri, 24 Aug 2018 21:23:26 -0700
>> Andy Lutomirski <luto@kernel.org> wrote:
>>> Couldn't text_poke() use kmap_atomic()?  Or, even better, just change CR3?
>>
>> No, since kmap_atomic() is only for x86_32 and highmem support kernel.
>> In x86-64, it seems that returns just a page address. That is not
>> good for text_poke, since it needs to make a writable alias for RO
>> code page. Hmm, maybe, can we mimic copy_oldmem_page(), it uses ioremap_cache?
>>
>
> I just re-read text_poke().  It's, um, horrible.  Not only is the
> implementation overcomplicated and probably buggy, but it's SLOOOOOW.
> It's totally the wrong API -- poking one instruction at a time
> basically can't be efficient on x86.  The API should either poke lots
> of instructions at once or should be text_poke_begin(); ...;
> text_poke_end();.
>
> Anyway, the attached patch seems to boot.  Linus, Kees, etc: is this
> too scary of an approach?  With the patch applied, text_poke() is a
> fantastic exploit target.  On the other hand, even without the patch
> applied, text_poke() is every bit as juicy.

I tried to convince Ingo to use this method for doing "write rarely"
and he soundly rejected it. :) I've always liked this because AFAICT,
it's local to the CPU. I had proposed it in
https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/commit/?h=kspp/write-rarely&id=9ab0cb2618ebbc51f830ceaa06b7d2182fe1a52d

With that, text_poke() mostly becomes:

rare_write_begin()
memcpy(addr, opcode, len);
rare_write_end()

As for juiciness, if an attacker already has execution control, they
can do more interesting things than text_poke(). But regardless, yes,
it's always made me uncomfortable. :)

-Kees

-- 
Kees Cook
Pixel Security
