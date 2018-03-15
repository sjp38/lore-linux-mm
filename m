Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 586556B0003
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 12:51:39 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w20-v6so2266114plp.13
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:51:39 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00092.outbound.protection.outlook.com. [40.107.0.92])
        by mx.google.com with ESMTPS id g1si1251734pgq.219.2018.03.15.09.51.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 09:51:38 -0700 (PDT)
Subject: Re: [RFC PATCH 09/14] khwasan: add hooks implementation
References: <cover.1520017438.git.andreyknvl@google.com>
 <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
 <CAG_fn=XjN2zQQrL1r-pv5rMhLgmvOyh8LS9QF0PQ8Y7gk4AVug@mail.gmail.com>
 <CAAeHK+wGHsFeDP_QMQRzWGTFg10bxfJPxx-_7Ja-_uTP8GJtCA@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <7f8e8f46-791e-7e8f-551b-f93aa64bcf6e@virtuozzo.com>
Date: Thu, 15 Mar 2018 19:52:07 +0300
MIME-Version: 1.0
In-Reply-To: <CAAeHK+wGHsFeDP_QMQRzWGTFg10bxfJPxx-_7Ja-_uTP8GJtCA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>



On 03/13/2018 08:00 PM, Andrey Konovalov wrote:
> On Tue, Mar 13, 2018 at 4:05 PM, 'Alexander Potapenko' via kasan-dev
> <kasan-dev@googlegroups.com> wrote:
>> On Fri, Mar 2, 2018 at 8:44 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>>  void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
>>>  {
>>> -       return (void *)ptr;
>>> +       unsigned long redzone_start, redzone_end;
>>> +       u8 tag;
>>> +       struct page *page;
>>> +
>>> +       if (!READ_ONCE(khwasan_enabled))
>>> +               return (void *)ptr;
>>> +
>>> +       if (unlikely(ptr == NULL))
>>> +               return NULL;
>>> +
>>> +       page = virt_to_page(ptr);
>>> +       redzone_start = round_up((unsigned long)(ptr + size),
>>> +                               KASAN_SHADOW_SCALE_SIZE);
>>> +       redzone_end = (unsigned long)ptr + (PAGE_SIZE << compound_order(page));
>>> +
>>> +       tag = khwasan_random_tag();
>>> +       kasan_poison_shadow(ptr, redzone_start - (unsigned long)ptr, tag);
>>> +       kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
>>> +               khwasan_random_tag());
> 
>> Am I understanding right that the object and the redzone may receive
>> identical tags here?
> 
> Correct.
> 
>> Does it make sense to generate the redzone tag from the object tag
>> (e.g. by addding 1 to it)?
> 
> Yes, I think so, will do!
> 

Wouldn't be better to have some reserved tag value for invalid memory (redzones/free), so that
we catch access to such memory with 100% probability?
