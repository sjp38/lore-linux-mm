Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 677836B03EF
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:23:34 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id b123so20733291itb.3
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:23:34 -0800 (PST)
Received: from mail-it0-x229.google.com (mail-it0-x229.google.com. [2607:f8b0:4001:c0b::229])
        by mx.google.com with ESMTPS id a93si5228112ioj.95.2016.11.18.02.23.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 02:23:33 -0800 (PST)
Received: by mail-it0-x229.google.com with SMTP id l8so20341956iti.1
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 02:23:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161116173217.GB3224@e104818-lin.cambridge.arm.com>
References: <20161102210054.16621-1-labbott@redhat.com> <20161102210054.16621-6-labbott@redhat.com>
 <20161102225241.GA19591@remoulade> <3724ea58-3c04-1248-8359-e2927da03aaf@redhat.com>
 <20161103155106.GF25852@remoulade> <20161114181937.GG3096@e104818-lin.cambridge.arm.com>
 <06569a6b-3846-5e18-28c1-7c16a9697663@redhat.com> <20161115183508.GJ3096@e104818-lin.cambridge.arm.com>
 <95d1f7bb-d451-3b0a-1a32-957a24023a49@redhat.com> <20161116173217.GB3224@e104818-lin.cambridge.arm.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 18 Nov 2016 10:23:32 +0000
Message-ID: <CAKv+Gu93ugEdruK4VrwL4ZxoDw1yJeZ=F34gZUC-WdNw2G=0Ng@mail.gmail.com>
Subject: Re: [PATCHv2 5/6] arm64: Use __pa_symbol for _end
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "x86@kernel.org" <x86@kernel.org>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>

On 16 November 2016 at 17:32, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On Tue, Nov 15, 2016 at 04:09:07PM -0800, Laura Abbott wrote:
>> On 11/15/2016 10:35 AM, Catalin Marinas wrote:
>> > I'm fine with __pa_symbol use entirely from under arch/arm64. But if you
>> > want to use __pa_symbol, I tried to change most (all?) places where
>> > necessary, together with making virt_to_phys() only deal with the kernel
>> > linear mapping. Not sure it looks cleaner, especially the
>> > __va(__pa_symbol()) cases (we could replace the latter with another
>> > macro and proper comment):
>>
>> I agree everything should be converted over, I was considering doing
>> that in a separate patch but this covers everything nicely. Are you
>> okay with me folding this in? (Few comments below)
>
> Yes. I would also like Ard to review it since he introduced the current
> __virt_to_phys() macro.
>

I think this is a clear improvement. I didn't dare to propose it at
the time, due to the fallout, but it is obviously much better to have
separate accessors than to have runtime tests to decide something that
is already known at compile time. My only concern is potential uses in
generic code: I think there may be something in the handling of
initramfs, or freeing the __init segment (I know it had 'init' in the
name :-)) that refers to the physical address of symbols, but I don't
remember exactly what it is.

Did you test it with a initramfs?

>> > diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
>> > index eac3dbb7e313..e02f45e5ee1b 100644
>> > --- a/arch/arm64/include/asm/memory.h
>> > +++ b/arch/arm64/include/asm/memory.h
>> > @@ -169,15 +169,22 @@ extern u64                    kimage_voffset;
>> >   */
>> >  #define __virt_to_phys_nodebug(x) ({                                       \
>> >     phys_addr_t __x = (phys_addr_t)(x);                             \
>> > -   __x & BIT(VA_BITS - 1) ? (__x & ~PAGE_OFFSET) + PHYS_OFFSET :   \
>> > -                            (__x - kimage_voffset); })
>> > +   VM_BUG_ON(!(__x & BIT(VA_BITS - 1)));                           \
>> > +   ((__x & ~PAGE_OFFSET) + PHYS_OFFSET);                           \
>> > +})
>>
>> I do think this is easier to understand vs the ternary operator.
>> I'll add a comment detailing the use of __pa vs __pa_symbol somewhere
>> as well.
>
> Of course, a comment is welcome (I just did a quick hack to check that
> it works).
>
>> > --- a/arch/arm64/include/asm/mmu_context.h
>> > +++ b/arch/arm64/include/asm/mmu_context.h
>> > @@ -44,7 +44,7 @@ static inline void contextidr_thread_switch(struct task_struct *next)
>> >   */
>> >  static inline void cpu_set_reserved_ttbr0(void)
>> >  {
>> > -   unsigned long ttbr = virt_to_phys(empty_zero_page);
>> > +   unsigned long ttbr = __pa_symbol(empty_zero_page);
>> >
>> >     write_sysreg(ttbr, ttbr0_el1);
>> >     isb();
>> > @@ -113,7 +113,7 @@ static inline void cpu_install_idmap(void)
>> >     local_flush_tlb_all();
>> >     cpu_set_idmap_tcr_t0sz();
>> >
>> > -   cpu_switch_mm(idmap_pg_dir, &init_mm);
>> > +   cpu_switch_mm(__va(__pa_symbol(idmap_pg_dir)), &init_mm);
>>
>> Yes, the __va(__pa_symbol(..)) idiom needs to be macroized and commented...
>
> Indeed. At the same time we should also replace the LMADDR macro in
> hibernate.c with whatever you come up with.
>
>> > diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.c
>> > index d55a7b09959b..81c03c74e5fe 100644
>> > --- a/arch/arm64/kernel/hibernate.c
>> > +++ b/arch/arm64/kernel/hibernate.c
>> > @@ -51,7 +51,7 @@
>> >  extern int in_suspend;
>> >
>> >  /* Find a symbols alias in the linear map */
>> > -#define LMADDR(x)  phys_to_virt(virt_to_phys(x))
>> > +#define LMADDR(x)  __va(__pa_symbol(x))
>>
>> ...Perhaps just borrowing this macro?
>
> Yes but I don't particularly like the name, especially since it goes
> into a .h file. Maybe __lm_sym_addr() or something else if you have a
> better idea.
>
>> > diff --git a/arch/arm64/mm/physaddr.c b/arch/arm64/mm/physaddr.c
>> > index 874c78201a2b..98dae943e496 100644
>> > --- a/arch/arm64/mm/physaddr.c
>> > +++ b/arch/arm64/mm/physaddr.c
>> > @@ -14,8 +14,8 @@ unsigned long __virt_to_phys(unsigned long x)
>> >              */
>> >             return (__x & ~PAGE_OFFSET) + PHYS_OFFSET;
>> >     } else {
>> > -           VIRTUAL_BUG_ON(x < kimage_vaddr || x >= (unsigned long)_end);
>> > -           return (__x - kimage_voffset);
>> > +           WARN_ON(1);
>>
>> Was the deletion of the BUG_ON here intentional? VIRTUAL_BUG_ON
>> is the check enabled by CONFIG_DEBUG_VIRTUAL vs just CONFIG_DEBUG_VM.
>> I intentionally kept CONFIG_DEBUG_VIRTUAL separate since the checks
>> are expensive.
>
> I wanted to always get a warning but fall back to __phys_addr_symbol()
> so that I can track down other uses of __virt_to_phys() on kernel
> symbols without killing the kernel. A better option would have been
> VIRTUAL_WARN_ON (or *_ONCE) but we don't have it. VM_WARN_ON, as you
> said, is independent of CONFIG_DEBUG_VIRTUAL.
>
> We could as well kill the system with VIRTUAL_BUG_ON in this case but I
> thought we should be more gentle until all the __virt_to_phys use-cases
> are sorted out.
>
> --
> Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
