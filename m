Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0958E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 13:09:25 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id v20-v6so2965028iom.14
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 10:09:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k30-v6sor11487623jaj.122.2018.09.18.10.09.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 10:09:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aJ36LGLG=TVOGQoJ+fB4Xc9CjdxAs8KZpUm3AsNEoHFw@mail.gmail.com>
References: <cover.1535462971.git.andreyknvl@google.com> <19d757c2cafc277f0143a8ac34e179061f3487f5.1535462971.git.andreyknvl@google.com>
 <CACT4Y+aJ36LGLG=TVOGQoJ+fB4Xc9CjdxAs8KZpUm3AsNEoHFw@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 18 Sep 2018 19:09:22 +0200
Message-ID: <CAAeHK+xBX4X0oxhjOrjJfwdqcvU80VPhUsi38mEczzHRb01Wew@mail.gmail.com>
Subject: Re: [PATCH v6 06/18] khwasan, arm64: untag virt address in
 __kimg_to_phys and _virt_addr_is_linear
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Sep 12, 2018 at 6:33 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Aug 29, 2018 at 1:35 PM, Andrey Konovalov <andreyknvl@google.com> wrote:

>> +#ifdef CONFIG_KASAN_HW
>> +#define KASAN_TAG_SHIFTED(tag)         ((unsigned long)(tag) << 56)
>> +#define KASAN_SET_TAG(addr, tag)       (((addr) & ~KASAN_TAG_SHIFTED(0xff)) | \
>> +                                               KASAN_TAG_SHIFTED(tag))
>> +#define KASAN_RESET_TAG(addr)          KASAN_SET_TAG(addr, 0xff)
>> +#endif
>> +
>
>
> Wouldn't it be better to
> #define KASAN_RESET_TAG(addr) addr
> when CONFIG_KASAN_HW is not enabled, and then not duplicate the macros
> below? That's what we do in kasan.h for all hooks.
> I see that a subsequent patch duplicates yet another macro in this
> file. While we could use:
>
> #define __kimg_to_phys(addr)   (KASAN_RESET_TAG(addr) - kimage_voffset)
>
> with and without kasan. Duplicating them increases risk that somebody
> will change only the non-kasan version but forget kasan version.

Will do in v7.
