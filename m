Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58C4D6B0007
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 08:27:16 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id d6-v6so778927plo.2
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 05:27:16 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50100.outbound.protection.outlook.com. [40.107.5.100])
        by mx.google.com with ESMTPS id f9si2874578pgq.255.2018.04.06.05.27.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 06 Apr 2018 05:27:15 -0700 (PDT)
Subject: Re: [RFC PATCH v2 13/15] khwasan: add hooks implementation
References: <cover.1521828273.git.andreyknvl@google.com>
 <ba4a74ba1bc48dd66a3831143c3119d13c291fe3.1521828274.git.andreyknvl@google.com>
 <805d1e85-2d3c-2327-6e6c-f14a56dc0b67@virtuozzo.com>
 <CAAeHK+yg5ODeDy7k9fako5mcCLLnBrO729Zp_-UtDuzh3hZgZA@mail.gmail.com>
 <0c4397da-e231-0044-986f-b8468314be76@virtuozzo.com>
 <CAAeHK+xmCLe85_QNDam_BVTp9wVzjxgvko2+0JapJCzmciGa5g@mail.gmail.com>
 <0857f052-a27a-501e-8923-c6f31510e4fe@virtuozzo.com>
 <CAAeHK+xnHeznZwofNQVDcBCCMnaEQ6fcRxOcrFM-qQFUsZ51Rg@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <0f448799-3a06-a25d-d604-21db3e8577fc@virtuozzo.com>
Date: Fri, 6 Apr 2018 15:27:55 +0300
MIME-Version: 1.0
In-Reply-To: <CAAeHK+xnHeznZwofNQVDcBCCMnaEQ6fcRxOcrFM-qQFUsZ51Rg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, Michael Weiser <michael.weiser@gmx.de>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Steve Capper <steve.capper@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Herbert Xu <herbert@gondor.apana.org.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, kvmarm@lists.cs.columbia.edu, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>



On 04/06/2018 03:14 PM, Andrey Konovalov wrote:
> On Thu, Apr 5, 2018 at 3:02 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>> On 04/04/2018 08:00 PM, Andrey Konovalov wrote:
>>> On Wed, Apr 4, 2018 at 2:39 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>>>>>>
>>>>>> You can save tag somewhere in page struct and make page_address() return tagged address.
>>>>>>
>>>>>> I'm not sure it might be even possible to squeeze the tag into page->flags on some configurations,
>>>>>> see include/linux/page-flags-layout.h
>>>>>
>>>>> One page can contain multiple objects with different tags, so we would
>>>>> need to save the tag for each of them.
>>>>
>>>> What do you mean? Slab page? The per-page tag is needed only for !PageSlab pages.
>>>> For slab pages we have kmalloc/kmem_cache_alloc() which already return properly tagged address.
>>>>
>>>> But the page allocator returns a pointer to struct page. One has to call page_address(page)
>>>> to use that page. Returning 'ignore-me'-tagged address from page_address() makes the whole
>>>> class of bugs invisible to KHWASAN. This is a serious downside comparing to classic KASAN which can
>>>> detect missuses of page allocator API.
>>>
>>> Yes, slab page. Here's an example:
>>>
>>> 1. do_get_write_access() allocates frozen_buffer with jbd2_alloc,
>>> which calls kmem_cache_alloc, and then saves the result to
>>> jh->b_frozen_data.
>>>
>>> 2. jbd2_journal_write_metadata_buffer() takes the value of
>>> jh_in->b_frozen_data and calls virt_to_page() (and offset_in_page())
>>> on it.
>>>
>>> 3. jbd2_journal_write_metadata_buffer() then calls kmap_atomic(),
>>> which calls page_address(), on the resulting page address.
>>>
>>> The tag gets erased. The page belongs to slab and can contain multiple
>>> objects with different tags.
>>>
>>
>> I see. Ideally that kind of problem should be fixed by reworking/redesigning such code,
>> however jbd2_journal_write_metadata_buffer() is far from the only place which
>> does that trick. Fixing all of them would be a huge task probably, so ignoring such
>> accesses seems to be the only choice we have.
>>
>> Nevertheless, this doesn't mean that we should ignore *all* accesses to !slab memory.
> 
> So you mean we need to find a way to ignore accesses via pointers
> returned by page_address(), but still check accesses through all other
> pointers tagged with 0xFF? I don't see an obvious way to do this. I'm
> open to suggestions though.
> 

I'm saying that we need to ignore accesses to slab objects if pointer
to slab object obtained via page_address() + offset_in_page() trick, but don't ignore
anything else.

So, save tag somewhere in page struct and poison shadow with that tag. Make page_address() to
return tagged address for all !PageSlab() pages. For PageSlab() pages page_address() should return
0xff tagged address, so we could ignore such accesses.
