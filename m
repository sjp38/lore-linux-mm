Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F11B26B0005
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 11:04:10 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t26-v6so4901863pfh.0
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 08:04:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q19-v6sor3525205pgg.56.2018.07.31.08.04.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 08:04:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8240d4f9-c8df-cfe9-119d-6e933f8b13df@virtuozzo.com>
References: <cover.1530018818.git.andreyknvl@google.com> <a2a93370d43ec85b02abaf8d007a15b464212221.1530018818.git.andreyknvl@google.com>
 <09cb5553-d84a-0e62-5174-315c14b88833@arm.com> <CAAeHK+yC3XRPoTByhH1QPrX45pG3QY_2Q4gz=dfDgxfzu1Fyfw@mail.gmail.com>
 <8240d4f9-c8df-cfe9-119d-6e933f8b13df@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 31 Jul 2018 17:03:48 +0200
Message-ID: <CACT4Y+Y=61VwwETQP3FwAN16ompSNJOCyDCG6Ew1Bm5f_Fe1Lw@mail.gmail.com>
Subject: Re: [PATCH v4 13/17] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, vincenzo.frascino@arm.com, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Mark Brand <markbrand@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

On Tue, Jul 31, 2018 at 4:50 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 07/31/2018 04:05 PM, Andrey Konovalov wrote:
>> On Wed, Jul 25, 2018 at 3:44 PM, Vincenzo Frascino@Foss
>> <vincenzo.frascino@arm.com> wrote:
>>> On 06/26/2018 02:15 PM, Andrey Konovalov wrote:
>>>
>>>> @@ -325,18 +341,41 @@ void kasan_init_slab_obj(struct kmem_cache *cache,
>>>> const void *object)
>>>>     void *kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t
>>>> flags)
>>>>   {
>>>> -       return kasan_kmalloc(cache, object, cache->object_size, flags);
>>>> +       object = kasan_kmalloc(cache, object, cache->object_size, flags);
>>>> +       if (IS_ENABLED(CONFIG_KASAN_HW) && unlikely(cache->ctor)) {
>>>> +               /*
>>>> +                * Cache constructor might use object's pointer value to
>>>> +                * initialize some of its fields.
>>>> +                */
>>>> +               cache->ctor(object);
>>>>
>>> This seams breaking the kmem_cache_create() contract: "The @ctor is run when
>>> new pages are allocated by the cache."
>>> (https://elixir.bootlin.com/linux/v3.7/source/mm/slab_common.c#L83)
>>>
>>> Since there might be preexisting code relying on it, this could lead to
>>> global side effects. Did you verify that this is not the case?
>>>
>>> Another concern is performance related if we consider this solution suitable
>>> for "near-production", since with the current implementation you call the
>>> ctor (where present) on an object multiple times and this ends up memsetting
>>> and repopulating the memory every time (i.e. inode.c: inode_init_once). Do
>>> you know what is the performance impact?
>>
>> We can assign tags to objects with constructors when a slab is
>> allocated and call constructors once as usual. The downside is that
>> such object would always have the same tag when it is reallocated, so
>> we won't catch use-after-frees.
>
> Actually you should do this for SLAB_TYPESAFE_BY_RCU slabs. Usually they are with ->ctors but there
> are few without constructors.
> We can't reinitialize or even retag them. The latter will definitely cause false-positive use-after-free reports.

Somewhat offtopic, but I can't understand how SLAB_TYPESAFE_BY_RCU
slabs can be useful without ctors or at least memset(0). Objects in
such slabs need to be type-stable, but I can't understand how it's
possible to establish type stability without a ctor... Are these bugs?
Or I am missing something subtle? What would be a canonical usage of
SLAB_TYPESAFE_BY_RCU slab without a ctor?
