Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2CEC06B0006
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 13:00:41 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 185so19861493iox.21
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 10:00:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k25sor2609929iob.102.2018.04.04.10.00.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Apr 2018 10:00:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0c4397da-e231-0044-986f-b8468314be76@virtuozzo.com>
References: <cover.1521828273.git.andreyknvl@google.com> <ba4a74ba1bc48dd66a3831143c3119d13c291fe3.1521828274.git.andreyknvl@google.com>
 <805d1e85-2d3c-2327-6e6c-f14a56dc0b67@virtuozzo.com> <CAAeHK+yg5ODeDy7k9fako5mcCLLnBrO729Zp_-UtDuzh3hZgZA@mail.gmail.com>
 <0c4397da-e231-0044-986f-b8468314be76@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 4 Apr 2018 19:00:35 +0200
Message-ID: <CAAeHK+xmCLe85_QNDam_BVTp9wVzjxgvko2+0JapJCzmciGa5g@mail.gmail.com>
Subject: Re: [RFC PATCH v2 13/15] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, Michael Weiser <michael.weiser@gmx.de>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Steve Capper <steve.capper@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Herbert Xu <herbert@gondor.apana.org.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, kvmarm@lists.cs.columbia.edu, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Wed, Apr 4, 2018 at 2:39 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>>>
>>> You can save tag somewhere in page struct and make page_address() return tagged address.
>>>
>>> I'm not sure it might be even possible to squeeze the tag into page->flags on some configurations,
>>> see include/linux/page-flags-layout.h
>>
>> One page can contain multiple objects with different tags, so we would
>> need to save the tag for each of them.
>
> What do you mean? Slab page? The per-page tag is needed only for !PageSlab pages.
> For slab pages we have kmalloc/kmem_cache_alloc() which already return properly tagged address.
>
> But the page allocator returns a pointer to struct page. One has to call page_address(page)
> to use that page. Returning 'ignore-me'-tagged address from page_address() makes the whole
> class of bugs invisible to KHWASAN. This is a serious downside comparing to classic KASAN which can
> detect missuses of page allocator API.

Yes, slab page. Here's an example:

1. do_get_write_access() allocates frozen_buffer with jbd2_alloc,
which calls kmem_cache_alloc, and then saves the result to
jh->b_frozen_data.

2. jbd2_journal_write_metadata_buffer() takes the value of
jh_in->b_frozen_data and calls virt_to_page() (and offset_in_page())
on it.

3. jbd2_journal_write_metadata_buffer() then calls kmap_atomic(),
which calls page_address(), on the resulting page address.

The tag gets erased. The page belongs to slab and can contain multiple
objects with different tags.

>>> I don't see any possible way of khwasan_enabled being 0 here.
>>
>> Can't kmem_cache_alloc be called for the temporary caches that are
>> used before the slab allocator and kasan are initialized?
>
> kasan_init() runs before allocators are initialized.
> slab allocator obviously has to be initialized before it can be used.

Checked the code, it seems you are right. Boot caches are created
after kasan_init() is called. I will remove khwasan_enabled.

Thanks!
