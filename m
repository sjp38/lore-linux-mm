Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3286B0008
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 08:39:09 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w9-v6so12173497plp.0
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 05:39:09 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0134.outbound.protection.outlook.com. [104.47.0.134])
        by mx.google.com with ESMTPS id f6-v6si3120400plf.70.2018.04.04.05.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 04 Apr 2018 05:39:08 -0700 (PDT)
Subject: Re: [RFC PATCH v2 13/15] khwasan: add hooks implementation
References: <cover.1521828273.git.andreyknvl@google.com>
 <ba4a74ba1bc48dd66a3831143c3119d13c291fe3.1521828274.git.andreyknvl@google.com>
 <805d1e85-2d3c-2327-6e6c-f14a56dc0b67@virtuozzo.com>
 <CAAeHK+yg5ODeDy7k9fako5mcCLLnBrO729Zp_-UtDuzh3hZgZA@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <0c4397da-e231-0044-986f-b8468314be76@virtuozzo.com>
Date: Wed, 4 Apr 2018 15:39:50 +0300
MIME-Version: 1.0
In-Reply-To: <CAAeHK+yg5ODeDy7k9fako5mcCLLnBrO729Zp_-UtDuzh3hZgZA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, Michael Weiser <michael.weiser@gmx.de>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Steve Capper <steve.capper@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Herbert Xu <herbert@gondor.apana.org.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, kvmarm@lists.cs.columbia.edu, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On 04/03/2018 05:59 PM, Andrey Konovalov wrote:

>>
>>
>>>  void check_memory_region(unsigned long addr, size_t size, bool write,
>>>                               unsigned long ret_ip)
>>>  {
>>> +     u8 tag;
>>> +     u8 *shadow_first, *shadow_last, *shadow;
>>> +     void *untagged_addr;
>>> +
>>> +     tag = get_tag((const void *)addr);
>>> +
>>> +     /* Ignore accesses for pointers tagged with 0xff (native kernel
>>> +      * pointer tag) to suppress false positives caused by kmap.
>>> +      *
>>> +      * Some kernel code was written to account for archs that don't keep
>>> +      * high memory mapped all the time, but rather map and unmap particular
>>> +      * pages when needed. Instead of storing a pointer to the kernel memory,
>>> +      * this code saves the address of the page structure and offset within
>>> +      * that page for later use. Those pages are then mapped and unmapped
>>> +      * with kmap/kunmap when necessary and virt_to_page is used to get the
>>> +      * virtual address of the page. For arm64 (that keeps the high memory
>>> +      * mapped all the time), kmap is turned into a page_address call.
>>> +
>>> +      * The issue is that with use of the page_address + virt_to_page
>>> +      * sequence the top byte value of the original pointer gets lost (gets
>>> +      * set to 0xff.
>>> +      */
>>> +     if (tag == 0xff)
>>> +             return;
>>
>> You can save tag somewhere in page struct and make page_address() return tagged address.
>>
>> I'm not sure it might be even possible to squeeze the tag into page->flags on some configurations,
>> see include/linux/page-flags-layout.h
> 
> One page can contain multiple objects with different tags, so we would
> need to save the tag for each of them.

What do you mean? Slab page? The per-page tag is needed only for !PageSlab pages.
For slab pages we have kmalloc/kmem_cache_alloc() which already return properly tagged address.

But the page allocator returns a pointer to struct page. One has to call page_address(page)
to use that page. Returning 'ignore-me'-tagged address from page_address() makes the whole
class of bugs invisible to KHWASAN. This is a serious downside comparing to classic KASAN which can
detect missuses of page allocator API.



>>
>>
>>>  void *kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
>>>  {
>>> +     if (!READ_ONCE(khwasan_enabled))
>>> +             return object;
>>
>> ...
>>
>>>  void *kasan_kmalloc(struct kmem_cache *cache, const void *object,
>>>                       size_t size, gfp_t flags)
>>>  {
>>
>>> +     if (!READ_ONCE(khwasan_enabled))
>>> +             return (void *)object;
>>> +
>>
>> ...
>>
>>>  void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
>>>  {
>>
>> ...
>>
>>> +
>>> +     if (!READ_ONCE(khwasan_enabled))
>>> +             return (void *)ptr;
>>> +
>>
>> I don't see any possible way of khwasan_enabled being 0 here.
> 
> Can't kmem_cache_alloc be called for the temporary caches that are
> used before the slab allocator and kasan are initialized?

kasan_init() runs before allocators are initialized.
slab allocator obviously has to be initialized before it can be used.
