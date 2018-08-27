Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4912A6B41F7
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 14:54:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id n17-v6so12219606pff.17
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 11:54:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f4-v6sor1695pff.67.2018.08.27.11.54.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 11:54:45 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: TLB flushes on fixmap changes
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CALCETrWxwpr+Xx0mCK1HUkanmCDOSRbw50VmebgoAgeNaaPAKg@mail.gmail.com>
Date: Mon, 27 Aug 2018 11:54:42 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <0000D631-FDDF-4273-8F3C-714E6825E59B@gmail.com>
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
 <01DA0BDD-7504-4209-8A8F-20B27CF6A1C7@gmail.com>
 <CALCETrWxwpr+Xx0mCK1HUkanmCDOSRbw50VmebgoAgeNaaPAKg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Masami Hiramatsu <mhiramat@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

at 11:45 AM, Andy Lutomirski <luto@kernel.org> wrote:

> On Mon, Aug 27, 2018 at 10:34 AM, Nadav Amit <nadav.amit@gmail.com> =
wrote:
>> at 1:05 AM, Masami Hiramatsu <mhiramat@kernel.org> wrote:
>>=20
>>> On Sun, 26 Aug 2018 20:26:09 -0700
>>> Nadav Amit <nadav.amit@gmail.com> wrote:
>>>=20
>>>> at 8:03 PM, Masami Hiramatsu <mhiramat@kernel.org> wrote:
>>>>=20
>>>>> On Sun, 26 Aug 2018 11:09:58 +0200
>>>>> Peter Zijlstra <peterz@infradead.org> wrote:
>>>>>=20
>>>>>> On Sat, Aug 25, 2018 at 09:21:22PM -0700, Andy Lutomirski wrote:
>>>>>>> I just re-read text_poke().  It's, um, horrible.  Not only is =
the
>>>>>>> implementation overcomplicated and probably buggy, but it's =
SLOOOOOW.
>>>>>>> It's totally the wrong API -- poking one instruction at a time
>>>>>>> basically can't be efficient on x86.  The API should either poke =
lots
>>>>>>> of instructions at once or should be text_poke_begin(); ...;
>>>>>>> text_poke_end();.
>>>>>>=20
>>>>>> I don't think anybody ever cared about performance here. Only
>>>>>> correctness. That whole text_poke_bp() thing is entirely tricky.
>>>>>=20
>>>>> Agreed. Self modification is a special event.
>>>>>=20
>>>>>> FWIW, before text_poke_bp(), text_poke() would only be used from
>>>>>> stop_machine, so all the other CPUs would be stuck busy-waiting =
with
>>>>>> IRQs disabled. These days, yeah, that's lots more dodgy, but yes
>>>>>> text_mutex should be serializing all that.
>>>>>=20
>>>>> I'm still not sure that speculative page-table walk can be done
>>>>> over the mutex. Also, if the fixmap area is for aliasing
>>>>> pages (which always mapped to memory), what kind of
>>>>> security issue can happen?
>>>>=20
>>>> The PTE is accessible from other cores, so just as we assume for =
L1TF that
>>>> the every addressable memory might be cached in L1, we should =
assume and
>>>> PTE might be cached in the TLB when it is present.
>>>=20
>>> Ok, so other cores can accidentally cache the PTE in TLB, (and no =
way
>>> to shoot down explicitly?)
>>=20
>> There is way (although current it does not). But it seems that the =
consensus
>> is that it is better to avoid it being mapped at all in remote cores.
>>=20
>>>> Although the mapping is for an alias, there are a couple of issues =
here.
>>>> First, this alias mapping is writable, so it might an attacker to =
change the
>>>> kernel code (following another initial attack).
>>>=20
>>> Combined with some buffer overflow, correct? If the attacker already =
can
>>> write a kernel data directly, he is in the kernel mode.
>>=20
>> Right.
>>=20
>>>> Second, the alias mapping is
>>>> never explicitly flushed. We may assume that once the original =
mapping is
>>>> removed/changed, a full TLB flush would take place, but there is no
>>>> guarantee it actually takes place.
>>>=20
>>> Hmm, would this means a full TLB flush will not flush alias mapping?
>>> (or, the full TLB flush just doesn't work?)
>>=20
>> It will flush the alias mapping, but currently there is no such =
explicit
>> flush.
>>=20
>>>>> Anyway, from the viewpoint of kprobes, either per-cpu fixmap or
>>>>> changing CR3 sounds good to me. I think we don't even need =
per-cpu,
>>>>> it can call a thread/function on a dedicated core (like the first
>>>>> boot processor) and wait :) This may prevent leakage of pte change
>>>>> to other cores.
>>>>=20
>>>> I implemented per-cpu fixmap, but I think that it makes more sense =
to take
>>>> peterz approach and set an entry in the PGD level. Per-CPU fixmap =
either
>>>> requires to pre-populate various levels in the page-table =
hierarchy, or
>>>> conditionally synchronize whenever module memory is allocated, =
since they
>>>> can share the same PGD, PUD & PMD. While usually the =
synchronization is not
>>>> needed, the possibility that synchronization is needed complicates =
locking.
>>>=20
>>> Could you point which PeterZ approach you said? I guess it will be
>>> make a clone of PGD and use it for local page mapping (as new mm).
>>> If so, yes it sounds perfectly fine to me.
>>=20
>> The thread is too long. What I think is best is having a mapping in =
the PGD
>> level. I=E2=80=99ll try to give it a shot, and see what I get.
>>=20
>>>> Anyhow, having fixed addresses for the fixmap can be used to =
circumvent
>>>> KASLR.
>>>=20
>>> I think text_poke doesn't mind using random address :)
>>>=20
>>>> I don=E2=80=99t think a dedicated core is needed. Anyhow there is a =
lock
>>>> (text_mutex), so use_mm() can be used after acquiring the mutex.
>>>=20
>>> Hmm, use_mm() said;
>>>=20
>>> /*
>>> * use_mm
>>> *      Makes the calling kernel thread take on the specified
>>> *      mm context.
>>> *      (Note: this routine is intended to be called only
>>> *      from a kernel thread context)
>>> */
>>>=20
>>> So maybe we need a dedicated kernel thread for safeness?
>>=20
>> Yes, it says so. But I am not sure it cannot be changed, at least for =
this
>> specific use-case. Switching kernel threads just for patching seems =
to me as
>> an overkill.
>>=20
>> Let me see if I can get something half-reasonable doing so...
>=20
> I don't understand at all how a kernel thread helps.  The useful bit
> is to have a dedicated mm, which would involve setting up an mm_struct
> and mapping the kernel and module text, EFI-style, in the user portion
> of the mm.  But, to do the text_poke(), we'd just use the mm *without
> calling use_mm*.
>=20
> In other words, the following sequence should be (almost) just fine:
>=20
> typedef struct {
>  struct mm_struct *prev;
> } temporary_mm_state_t;
>=20
> temporary_mm_state_t use_temporary_mm(struct mm_struct *mm)
> {
>    temporary_mm_state_t state;
>=20
>    lockdep_assert_irqs_disabled();
>    state.prev =3D this_cpu_read(cpu_tlbstate.loaded_mm);
>    switch_mm_irqs_off(NULL, mm, current);
> }
>=20
> void unuse_temporary_mm(temporary_mm_state_t prev)
> {
>    lockdep_assert_irqs_disabled();
>    switch_mm_irqs_off(NULL, prev.prev, current);
> }
>=20
> The only thing wrong with this that I can see is that it interacts
> poorly with perf.  But perf is *already* busted in this regard.  The
> following (whitespace damaged, sorry) should fix it:
>=20
> commit b62bff5a8406d252de752cfe75068d0b73b9cdf0
> Author: Andy Lutomirski <luto@kernel.org>
> Date:   Mon Aug 27 11:41:55 2018 -0700
>=20
>    x86/nmi: Fix some races in NMI uaccess
>=20
>    In NMI context, we might be in the middle of context switching or =
in
>    the middle of switch_mm_irqs_off().  In either case, CR3 might not
>    match current->mm, which could cause copy_from_user_nmi() and
>    friends to read the wrong memory.
>=20
>    Fix it by adding a new nmi_uaccess_okay() helper and checking it in
>    copy_from_user_nmi() and in __copy_from_user_nmi()'s callers.
>=20
>    Signed-off-by: Andy Lutomirski <luto@kernel.org>
>=20
> diff --git a/arch/x86/events/core.c b/arch/x86/events/core.c
> index 5f4829f10129..dfb2f7c0d019 100644
> --- a/arch/x86/events/core.c
> +++ b/arch/x86/events/core.c
> @@ -2465,7 +2465,7 @@ perf_callchain_user(struct
> perf_callchain_entry_ctx *entry, struct pt_regs *regs
>=20
>     perf_callchain_store(entry, regs->ip);
>=20
> -    if (!current->mm)
> +    if (!nmi_uaccess_okay())
>         return;
>=20
>     if (perf_callchain_user32(regs, entry))
> diff --git a/arch/x86/include/asm/tlbflush.h =
b/arch/x86/include/asm/tlbflush.h
> index 89a73bc31622..b23b2625793b 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -230,6 +230,22 @@ struct tlb_state {
> };
> DECLARE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate);
>=20
> +/*
> + * Blindly accessing user memory from NMI context can be dangerous
> + * if we're in the middle of switching the current user task or
> + * switching the loaded mm.  It can also be dangerous if we
> + * interrupted some kernel code that was temporarily using a
> + * different mm.
> + */
> +static inline bool nmi_uaccess_okay(void)
> +{
> +    struct mm_struct *loaded_mm =3D =
this_cpu_read(cpu_tlbstate.loaded_mm);
> +    struct mm_struct *current_mm =3D current->mm;
> +
> +    return current_mm && loaded_mm =3D=3D current_mm &&
> +        loaded_mm->pgd =3D=3D __va(read_cr3_pa());
> +}
> +
> /* Initialize cr4 shadow for this CPU. */
> static inline void cr4_init_shadow(void)
> {
> diff --git a/arch/x86/lib/usercopy.c b/arch/x86/lib/usercopy.c
> index c8c6ad0d58b8..c5f758430be2 100644
> --- a/arch/x86/lib/usercopy.c
> +++ b/arch/x86/lib/usercopy.c
> @@ -19,6 +19,9 @@ copy_from_user_nmi(void *to, const void __user
> *from, unsigned long n)
>     if (__range_not_ok(from, n, TASK_SIZE))
>         return n;
>=20
> +    if (!nmi_uaccess_okay())
> +        return n;
> +
>     /*
>      * Even though this function is typically called from NMI/IRQ =
context
>      * disable pagefaults so that its behaviour is consistent even =
when
> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index 457b281b9339..f4b41d5a93dd 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -345,6 +345,9 @@ void switch_mm_irqs_off(struct mm_struct *prev,
> struct mm_struct *next,
>          */
>         trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH, =
TLB_FLUSH_ALL);
>     } else {
> +        /* Let NMI code know that CR3 may not match expectations. */
> +        this_cpu_write(cpu_tlbstate.loaded_mm, NULL);
> +
>         /* The new ASID is already up to date. */
>         load_new_mm_cr3(next->pgd, new_asid, false);
>=20
> What do you all think?

I agree in general. But I think that current->mm would need to be =
loaded, as
otherwise I am afraid it would break switch_mm_irqs_off().
