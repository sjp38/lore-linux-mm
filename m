Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E15C6B41AB
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 13:34:42 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id q12-v6so11367845pgp.6
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 10:34:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p29-v6sor448608pgb.295.2018.08.27.10.34.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 10:34:41 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: TLB flushes on fixmap changes
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20180827170511.6bafa15cbc102ae135366e86@kernel.org>
Date: Mon, 27 Aug 2018 10:34:36 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <01DA0BDD-7504-4209-8A8F-20B27CF6A1C7@gmail.com>
References: <D74A89DF-0D89-4AB6-8A6B-93BEC9A83595@gmail.com>
 <20180824180438.GS24124@hirez.programming.kicks-ass.net>
 <56A9902F-44BE-4520-A17C-26650FCC3A11@gmail.com>
 <CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com>
 <9A38D3F4-2F75-401D-8B4D-83A844C9061B@gmail.com>
 <CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
 <8E0D8C66-6F21-4890-8984-B6B3082D4CC5@gmail.com>
 <CALCETrWdeKBcEs7zAbpEM1YdYiT2UBXwPtF0mMTvcDX_KRpz1A@mail.gmail.com>
 <20180826112341.f77a528763e297cbc36058fa@kernel.org>
 <CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
 <20180826090958.GT24124@hirez.programming.kicks-ass.net>
 <20180827120305.01a6f26267c64610cadec5d8@kernel.org>
 <4BF82052-4738-441C-8763-26C85003F2C9@gmail.com>
 <20180827170511.6bafa15cbc102ae135366e86@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

at 1:05 AM, Masami Hiramatsu <mhiramat@kernel.org> wrote:

> On Sun, 26 Aug 2018 20:26:09 -0700
> Nadav Amit <nadav.amit@gmail.com> wrote:
>=20
>> at 8:03 PM, Masami Hiramatsu <mhiramat@kernel.org> wrote:
>>=20
>>> On Sun, 26 Aug 2018 11:09:58 +0200
>>> Peter Zijlstra <peterz@infradead.org> wrote:
>>>=20
>>>> On Sat, Aug 25, 2018 at 09:21:22PM -0700, Andy Lutomirski wrote:
>>>>> I just re-read text_poke().  It's, um, horrible.  Not only is the
>>>>> implementation overcomplicated and probably buggy, but it's =
SLOOOOOW.
>>>>> It's totally the wrong API -- poking one instruction at a time
>>>>> basically can't be efficient on x86.  The API should either poke =
lots
>>>>> of instructions at once or should be text_poke_begin(); ...;
>>>>> text_poke_end();.
>>>>=20
>>>> I don't think anybody ever cared about performance here. Only
>>>> correctness. That whole text_poke_bp() thing is entirely tricky.
>>>=20
>>> Agreed. Self modification is a special event.
>>>=20
>>>> FWIW, before text_poke_bp(), text_poke() would only be used from
>>>> stop_machine, so all the other CPUs would be stuck busy-waiting =
with
>>>> IRQs disabled. These days, yeah, that's lots more dodgy, but yes
>>>> text_mutex should be serializing all that.
>>>=20
>>> I'm still not sure that speculative page-table walk can be done
>>> over the mutex. Also, if the fixmap area is for aliasing
>>> pages (which always mapped to memory), what kind of
>>> security issue can happen?
>>=20
>> The PTE is accessible from other cores, so just as we assume for L1TF =
that
>> the every addressable memory might be cached in L1, we should assume =
and
>> PTE might be cached in the TLB when it is present.
>=20
> Ok, so other cores can accidentally cache the PTE in TLB, (and no way
> to shoot down explicitly?)

There is way (although current it does not). But it seems that the =
consensus
is that it is better to avoid it being mapped at all in remote cores.

>> Although the mapping is for an alias, there are a couple of issues =
here.
>> First, this alias mapping is writable, so it might an attacker to =
change the
>> kernel code (following another initial attack).
>=20
> Combined with some buffer overflow, correct? If the attacker already =
can
> write a kernel data directly, he is in the kernel mode.

Right.

>=20
>> Second, the alias mapping is
>> never explicitly flushed. We may assume that once the original =
mapping is
>> removed/changed, a full TLB flush would take place, but there is no
>> guarantee it actually takes place.
>=20
> Hmm, would this means a full TLB flush will not flush alias mapping?
> (or, the full TLB flush just doesn't work?)

It will flush the alias mapping, but currently there is no such explicit
flush.

>>> Anyway, from the viewpoint of kprobes, either per-cpu fixmap or
>>> changing CR3 sounds good to me. I think we don't even need per-cpu,
>>> it can call a thread/function on a dedicated core (like the first
>>> boot processor) and wait :) This may prevent leakage of pte change
>>> to other cores.
>>=20
>> I implemented per-cpu fixmap, but I think that it makes more sense to =
take
>> peterz approach and set an entry in the PGD level. Per-CPU fixmap =
either
>> requires to pre-populate various levels in the page-table hierarchy, =
or
>> conditionally synchronize whenever module memory is allocated, since =
they
>> can share the same PGD, PUD & PMD. While usually the synchronization =
is not
>> needed, the possibility that synchronization is needed complicates =
locking.
>=20
> Could you point which PeterZ approach you said? I guess it will be
> make a clone of PGD and use it for local page mapping (as new mm).
> If so, yes it sounds perfectly fine to me.

The thread is too long. What I think is best is having a mapping in the =
PGD
level. I=E2=80=99ll try to give it a shot, and see what I get.

>> Anyhow, having fixed addresses for the fixmap can be used to =
circumvent
>> KASLR.
>=20
> I think text_poke doesn't mind using random address :)
>=20
>> I don=E2=80=99t think a dedicated core is needed. Anyhow there is a =
lock
>> (text_mutex), so use_mm() can be used after acquiring the mutex.
>=20
> Hmm, use_mm() said;
>=20
> /*
> * use_mm
> *      Makes the calling kernel thread take on the specified
> *      mm context.
> *      (Note: this routine is intended to be called only
> *      from a kernel thread context)
> */
>=20
> So maybe we need a dedicated kernel thread for safeness?

Yes, it says so. But I am not sure it cannot be changed, at least for =
this
specific use-case. Switching kernel threads just for patching seems to =
me as
an overkill.

Let me see if I can get something half-reasonable doing so...
