Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7D96B0010
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 13:00:36 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id r9so539937ioa.11
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 10:00:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v134sor331388ith.60.2018.03.13.10.00.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 10:00:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=XjN2zQQrL1r-pv5rMhLgmvOyh8LS9QF0PQ8Y7gk4AVug@mail.gmail.com>
References: <cover.1520017438.git.andreyknvl@google.com> <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
 <CAG_fn=XjN2zQQrL1r-pv5rMhLgmvOyh8LS9QF0PQ8Y7gk4AVug@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 13 Mar 2018 18:00:32 +0100
Message-ID: <CAAeHK+wGHsFeDP_QMQRzWGTFg10bxfJPxx-_7Ja-_uTP8GJtCA@mail.gmail.com>
Subject: Re: [RFC PATCH 09/14] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Tue, Mar 13, 2018 at 4:05 PM, 'Alexander Potapenko' via kasan-dev
<kasan-dev@googlegroups.com> wrote:
> On Fri, Mar 2, 2018 at 8:44 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>  void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
>>  {
>> -       return (void *)ptr;
>> +       unsigned long redzone_start, redzone_end;
>> +       u8 tag;
>> +       struct page *page;
>> +
>> +       if (!READ_ONCE(khwasan_enabled))
>> +               return (void *)ptr;
>> +
>> +       if (unlikely(ptr == NULL))
>> +               return NULL;
>> +
>> +       page = virt_to_page(ptr);
>> +       redzone_start = round_up((unsigned long)(ptr + size),
>> +                               KASAN_SHADOW_SCALE_SIZE);
>> +       redzone_end = (unsigned long)ptr + (PAGE_SIZE << compound_order(page));
>> +
>> +       tag = khwasan_random_tag();
>> +       kasan_poison_shadow(ptr, redzone_start - (unsigned long)ptr, tag);
>> +       kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
>> +               khwasan_random_tag());

> Am I understanding right that the object and the redzone may receive
> identical tags here?

Correct.

> Does it make sense to generate the redzone tag from the object tag
> (e.g. by addding 1 to it)?

Yes, I think so, will do!
