Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EF386B000D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 09:06:02 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id a10-v6so2571489itc.9
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 06:06:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 68-v6sor864552itt.148.2018.07.31.06.06.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 06:06:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <09cb5553-d84a-0e62-5174-315c14b88833@arm.com>
References: <cover.1530018818.git.andreyknvl@google.com> <a2a93370d43ec85b02abaf8d007a15b464212221.1530018818.git.andreyknvl@google.com>
 <09cb5553-d84a-0e62-5174-315c14b88833@arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 31 Jul 2018 15:05:59 +0200
Message-ID: <CAAeHK+yC3XRPoTByhH1QPrX45pG3QY_2Q4gz=dfDgxfzu1Fyfw@mail.gmail.com>
Subject: Re: [PATCH v4 13/17] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vincenzo.frascino@arm.com
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Mark Brand <markbrand@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

On Wed, Jul 25, 2018 at 3:44 PM, Vincenzo Frascino@Foss
<vincenzo.frascino@arm.com> wrote:
> On 06/26/2018 02:15 PM, Andrey Konovalov wrote:
>
>> @@ -325,18 +341,41 @@ void kasan_init_slab_obj(struct kmem_cache *cache,
>> const void *object)
>>     void *kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t
>> flags)
>>   {
>> -       return kasan_kmalloc(cache, object, cache->object_size, flags);
>> +       object = kasan_kmalloc(cache, object, cache->object_size, flags);
>> +       if (IS_ENABLED(CONFIG_KASAN_HW) && unlikely(cache->ctor)) {
>> +               /*
>> +                * Cache constructor might use object's pointer value to
>> +                * initialize some of its fields.
>> +                */
>> +               cache->ctor(object);
>>
> This seams breaking the kmem_cache_create() contract: "The @ctor is run when
> new pages are allocated by the cache."
> (https://elixir.bootlin.com/linux/v3.7/source/mm/slab_common.c#L83)
>
> Since there might be preexisting code relying on it, this could lead to
> global side effects. Did you verify that this is not the case?
>
> Another concern is performance related if we consider this solution suitable
> for "near-production", since with the current implementation you call the
> ctor (where present) on an object multiple times and this ends up memsetting
> and repopulating the memory every time (i.e. inode.c: inode_init_once). Do
> you know what is the performance impact?

We can assign tags to objects with constructors when a slab is
allocated and call constructors once as usual. The downside is that
such object would always have the same tag when it is reallocated, so
we won't catch use-after-frees. But that is probably something we'll
have to deal with if we're aiming for "near-production". I'll add this
change to v5, thanks!
