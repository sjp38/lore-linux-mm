Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id EC56F8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 13:36:37 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id z72-v6so3967531itc.8
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 10:36:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 15-v6sor4669148itk.111.2018.09.18.10.36.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 10:36:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aNhNeR==XKQ9gHxt1p-9JS0EkjMSyWtgYi886oumh9rA@mail.gmail.com>
References: <cover.1535462971.git.andreyknvl@google.com> <f39cdef4fde40b6d2ef356db3e0126bda0e1e8c7.1535462971.git.andreyknvl@google.com>
 <CACT4Y+aNhNeR==XKQ9gHxt1p-9JS0EkjMSyWtgYi886oumh9rA@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 18 Sep 2018 19:36:35 +0200
Message-ID: <CAAeHK+xFV0x3g0_HUp_TtACR1dsjXCGdzFyw0BHEmrwqdXi-Og@mail.gmail.com>
Subject: Re: [PATCH v6 13/18] khwasan: add bug reporting routines
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Sep 12, 2018 at 7:50 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Aug 29, 2018 at 1:35 PM, Andrey Konovalov <andreyknvl@google.com> wrote:

>> +#ifdef CONFIG_KASAN_HW
>
> We already have #ifdef CONFIG_KASAN_HW section below with additional
> functions for KASAN_HW and empty stubs otherwise. I would add this one
> there as well.

Will do in v7.

>
>> +void print_tags(u8 addr_tag, const void *addr);
>> +#else
>> +static inline void print_tags(u8 addr_tag, const void *addr) { }
>> +#endif

>> +void *find_first_bad_addr(void *addr, size_t size)
>> +{
>> +       u8 tag = get_tag(addr);
>> +       void *untagged_addr = reset_tag(addr);
>> +       u8 *shadow = (u8 *)kasan_mem_to_shadow(untagged_addr);
>> +       void *first_bad_addr = untagged_addr;
>> +
>> +       while (*shadow == tag && first_bad_addr < untagged_addr + size) {
>
> I think it's better to check that are within bounds before accessing
> shadow. Otherwise it's kinda potential out-of-bounds access ;)
> I know that we _should_ not do an oob here, but still.
> Also feels that this function can be shortened to something like:
>
> u8 tag = get_tag(addr);
> void *p = reset_tag(addr);
> void *end = p + size;
>
> while (p < end && tag == *(u8 *)kasan_mem_to_shadow(p))
>         p += KASAN_SHADOW_SCALE_SIZE;
> return p;

Will do in v7.
