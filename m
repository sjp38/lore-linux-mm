Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1286B3B3D
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 10:20:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id s1-v6so9648425pfm.22
        for <linux-mm@kvack.org>; Sun, 26 Aug 2018 07:20:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n15-v6sor3799116pfg.28.2018.08.26.07.20.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 Aug 2018 07:20:31 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: TLB flushes on fixmap changes
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <CAGXu5j+xUbq_mu=2jvH2Vu+mviteZJqdPNTrxpaijwsuDdN-sw@mail.gmail.com>
Date: Sun, 26 Aug 2018 07:20:28 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <952A64F0-90B3-4E2F-B410-7E20BE90D617@amacapital.net>
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
 <CAGXu5j+xUbq_mu=2jvH2Vu+mviteZJqdPNTrxpaijwsuDdN-sw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>



> On Aug 25, 2018, at 9:43 PM, Kees Cook <keescook@chromium.org> wrote:
>=20
>> On Sat, Aug 25, 2018 at 9:21 PM, Andy Lutomirski <luto@kernel.org> wrote:=

>>> On Sat, Aug 25, 2018 at 7:23 PM, Masami Hiramatsu <mhiramat@kernel.org> w=
rote:
>>> On Fri, 24 Aug 2018 21:23:26 -0700
>>> Andy Lutomirski <luto@kernel.org> wrote:
>>>> Couldn't text_poke() use kmap_atomic()?  Or, even better, just change C=
R3?
>>>=20
>>> No, since kmap_atomic() is only for x86_32 and highmem support kernel.
>>> In x86-64, it seems that returns just a page address. That is not
>>> good for text_poke, since it needs to make a writable alias for RO
>>> code page. Hmm, maybe, can we mimic copy_oldmem_page(), it uses ioremap_=
cache?
>>>=20
>>=20
>> I just re-read text_poke().  It's, um, horrible.  Not only is the
>> implementation overcomplicated and probably buggy, but it's SLOOOOOW.
>> It's totally the wrong API -- poking one instruction at a time
>> basically can't be efficient on x86.  The API should either poke lots
>> of instructions at once or should be text_poke_begin(); ...;
>> text_poke_end();.
>>=20
>> Anyway, the attached patch seems to boot.  Linus, Kees, etc: is this
>> too scary of an approach?  With the patch applied, text_poke() is a
>> fantastic exploit target.  On the other hand, even without the patch
>> applied, text_poke() is every bit as juicy.
>=20
> I tried to convince Ingo to use this method for doing "write rarely"
> and he soundly rejected it. :) I've always liked this because AFAICT,
> it's local to the CPU. I had proposed it in
> https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/commit/?h=3D=
kspp/write-rarely&id=3D9ab0cb2618ebbc51f830ceaa06b7d2182fe1a52d

Ingo, can you clarify why you hate it?  I personally would rather use CR3, b=
ut CR0 seems like a fine first step, at least for text_poke.

>=20
> With that, text_poke() mostly becomes:
>=20
> rare_write_begin()
> memcpy(addr, opcode, len);
> rare_write_end()
>=20
> As for juiciness, if an attacker already has execution control, they
> can do more interesting things than text_poke(). But regardless, yes,
> it's always made me uncomfortable. :)
>=20
> -Kees
>=20
> --=20
> Kees Cook
> Pixel Security
