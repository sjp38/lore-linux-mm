Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4C96B0025
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 09:43:27 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id z23so1564398iob.23
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 06:43:27 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i78sor741161ioe.260.2018.03.20.06.43.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 06:43:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <dd58d047-2a57-fcf5-b555-6e9630b52670@oracle.com>
References: <cover.1520017438.git.andreyknvl@google.com> <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
 <dd58d047-2a57-fcf5-b555-6e9630b52670@oracle.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 20 Mar 2018 14:43:23 +0100
Message-ID: <CAAeHK+zA4qt8mnpOb3v8TJyKKQZ-4z8VCcdDfeUHZ38_ELw=BA@mail.gmail.com>
Subject: Re: [RFC PATCH 09/14] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anthony Yznaga <anthony.yznaga@oracle.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Tue, Mar 20, 2018 at 1:44 AM, Anthony Yznaga
<anthony.yznaga@oracle.com> wrote:
> Hi Andrey,
>
> On 3/2/18 11:44 AM, Andrey Konovalov wrote:
>> void kasan_poison_kfree(void *ptr, unsigned long ip)
>>  {
>> +     struct page *page;
>> +
>> +     page = virt_to_head_page(ptr)
>
> An untagged addr should be passed to virt_to_head_page(), no?

Hi!

virt_to_head_page() relies on virt_to_phys(), and the latter will be
fixed to accept tagged pointers in the next patchset.

Thanks!

>
>> +
>> +     if (unlikely(!PageSlab(page))) {
>> +             if (reset_tag(ptr) != page_address(page)) {
>> +                     /* Report invalid-free here */
>> +                     return;
>> +             }
>> +             kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
>> +                                     khwasan_random_tag());
>> +     } else {
>> +             __kasan_slab_free(page->slab_cache, ptr, ip);
>> +     }
>>  }
>>
>>  void kasan_kfree_large(void *ptr, unsigned long ip)
>>  {
>> +     struct page *page = virt_to_page(ptr);
>> +     struct page *head_page = virt_to_head_page(ptr);
>
> Same as above and for virt_to_page() as well.
>
> Anthony
>
>
>> +
>> +     if (reset_tag(ptr) != page_address(head_page)) {
>> +             /* Report invalid-free here */
>> +             return;
>> +     }
>> +
>> +     kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
>> +                     khwasan_random_tag());
>>  }
