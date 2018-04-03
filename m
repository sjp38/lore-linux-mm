Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5877E6B000C
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 11:00:01 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id w197so16549258iod.23
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 08:00:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n3-v6sor333524ite.120.2018.04.03.08.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Apr 2018 08:00:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <805d1e85-2d3c-2327-6e6c-f14a56dc0b67@virtuozzo.com>
References: <cover.1521828273.git.andreyknvl@google.com> <ba4a74ba1bc48dd66a3831143c3119d13c291fe3.1521828274.git.andreyknvl@google.com>
 <805d1e85-2d3c-2327-6e6c-f14a56dc0b67@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 3 Apr 2018 16:59:58 +0200
Message-ID: <CAAeHK+yg5ODeDy7k9fako5mcCLLnBrO729Zp_-UtDuzh3hZgZA@mail.gmail.com>
Subject: Re: [RFC PATCH v2 13/15] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, Michael Weiser <michael.weiser@gmx.de>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Steve Capper <steve.capper@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Herbert Xu <herbert@gondor.apana.org.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, kvmarm@lists.cs.columbia.edu, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 30, 2018 at 7:47 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> On 03/23/2018 09:05 PM, Andrey Konovalov wrote:
>> This commit adds KHWASAN hooks implementation.
>>
>> 1. When a new slab cache is created, KHWASAN rounds up the size of the
>>    objects in this cache to KASAN_SHADOW_SCALE_SIZE (== 16).
>>
>> 2. On each kmalloc KHWASAN generates a random tag, sets the shadow memory,
>>    that corresponds to this object to this tag, and embeds this tag value
>>    into the top byte of the returned pointer.
>>
>> 3. On each kfree KHWASAN poisons the shadow memory with a random tag to
>>    allow detection of use-after-free bugs.
>>
>> The rest of the logic of the hook implementation is very much similar to
>> the one provided by KASAN. KHWASAN saves allocation and free stack metadata
>> to the slab object the same was KASAN does this.
>>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> ---
>>  mm/kasan/khwasan.c | 200 ++++++++++++++++++++++++++++++++++++++++++++-
>>  1 file changed, 197 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/kasan/khwasan.c b/mm/kasan/khwasan.c
>> index da4b17997c71..e8bed5a078c7 100644
>> --- a/mm/kasan/khwasan.c
>> +++ b/mm/kasan/khwasan.c
>> @@ -90,69 +90,260 @@ void *khwasan_reset_tag(const void *addr)
>>       return reset_tag(addr);
>>  }
>>
>> +void kasan_poison_shadow(const void *address, size_t size, u8 value)
>> +{
>> +     void *shadow_start, *shadow_end;
>> +
>> +     /* Perform shadow offset calculation based on untagged address */
>> +     address = reset_tag(address);
>> +
>> +     shadow_start = kasan_mem_to_shadow(address);
>> +     shadow_end = kasan_mem_to_shadow(address + size);
>> +
>> +     memset(shadow_start, value, shadow_end - shadow_start);
>> +}
>> +
>>  void kasan_unpoison_shadow(const void *address, size_t size)
>>  {
>> +     /* KHWASAN only allows 16-byte granularity */
>> +     size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
>> +     kasan_poison_shadow(address, size, get_tag(address));
>>  }
>>
>
>
> This is way too much of copy-paste/code duplication. Ideally, you should have only
> check_memory_region() stuff separated, the rest (poisoning/unpoisoning, slabs management) should be
> in common.c code.
>
> So it should be something like this:
>
> in kasan.h
> ...
> #ifdef CONFIG_KASAN_CLASSIC
> #define KASAN_FREE_PAGE         0xFF  /* page was freed */
> #define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
> #define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
> #define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
> #else
> #define KASAN_FREE_PAGE         0xFE
> #define KASAN_PAGE_REDZONE      0xFE
> #define KASAN_KMALLOC_REDZONE   0xFE
> #define KASAN_KMALLOC_FREE      0xFE
> #endif
>
> ...
>
> #ifdef CONFIG_KASAN_CLASSIC
> static inline void *reset_tag(const void *addr)
> {
>         return (void *)addr;
> }
> static inline u8 get_tag(const void *addr)
> {
>         return 0;
> }
> #else
> static inline u8 get_tag(const void *addr)
> {
>         return (u8)((u64)addr >> KHWASAN_TAG_SHIFT);
> }
>
> static inline void *reset_tag(const void *addr)
> {
>         return set_tag(addr, KHWASAN_TAG_KERNEL);
> }
> #endif
>
>
> in kasan/common.c:
>
>
> void kasan_poison_shadow(const void *address, size_t size, u8 value)
> {
>         void *shadow_start, *shadow_end;
>
>         address = reset_tag(address);
>
>         shadow_start = kasan_mem_to_shadow(address);
>         shadow_end = kasan_mem_to_shadow(address + size);
>
>         memset(shadow_start, value, shadow_end - shadow_start);
> }
>
> void kasan_unpoison_shadow(const void *address, size_t size)
> {
>
>         kasan_poison_shadow(address, size, get_tag(address));
>
>         if (size & KASAN_SHADOW_MASK) {
>                 u8 *shadow = (u8 *)kasan_mem_to_shadow(address + size);
>
>                 if (IS_ENABLED(CONFIG_KASAN_TAGS)
>                         *shadow = get_tag(address);
>                 else
>                         *shadow = size & KASAN_SHADOW_MASK;
>         }
> }
>
> void kasan_free_pages(struct page *page, unsigned int order)
> {
>         if (likely(!PageHighMem(page)))
>                 kasan_poison_shadow(page_address(page),
>                                 PAGE_SIZE << order,
>                                 KASAN_FREE_PAGE);
> }
>
> etc.

OK, I'll rework this part.

>
>
>
>>  void check_memory_region(unsigned long addr, size_t size, bool write,
>>                               unsigned long ret_ip)
>>  {
>> +     u8 tag;
>> +     u8 *shadow_first, *shadow_last, *shadow;
>> +     void *untagged_addr;
>> +
>> +     tag = get_tag((const void *)addr);
>> +
>> +     /* Ignore accesses for pointers tagged with 0xff (native kernel
>> +      * pointer tag) to suppress false positives caused by kmap.
>> +      *
>> +      * Some kernel code was written to account for archs that don't keep
>> +      * high memory mapped all the time, but rather map and unmap particular
>> +      * pages when needed. Instead of storing a pointer to the kernel memory,
>> +      * this code saves the address of the page structure and offset within
>> +      * that page for later use. Those pages are then mapped and unmapped
>> +      * with kmap/kunmap when necessary and virt_to_page is used to get the
>> +      * virtual address of the page. For arm64 (that keeps the high memory
>> +      * mapped all the time), kmap is turned into a page_address call.
>> +
>> +      * The issue is that with use of the page_address + virt_to_page
>> +      * sequence the top byte value of the original pointer gets lost (gets
>> +      * set to 0xff.
>> +      */
>> +     if (tag == 0xff)
>> +             return;
>
> You can save tag somewhere in page struct and make page_address() return tagged address.
>
> I'm not sure it might be even possible to squeeze the tag into page->flags on some configurations,
> see include/linux/page-flags-layout.h

One page can contain multiple objects with different tags, so we would
need to save the tag for each of them.

>
>
>>  void *kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
>>  {
>> +     if (!READ_ONCE(khwasan_enabled))
>> +             return object;
>
> ...
>
>>  void *kasan_kmalloc(struct kmem_cache *cache, const void *object,
>>                       size_t size, gfp_t flags)
>>  {
>
>> +     if (!READ_ONCE(khwasan_enabled))
>> +             return (void *)object;
>> +
>
> ...
>
>>  void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
>>  {
>
> ...
>
>> +
>> +     if (!READ_ONCE(khwasan_enabled))
>> +             return (void *)ptr;
>> +
>
> I don't see any possible way of khwasan_enabled being 0 here.

Can't kmem_cache_alloc be called for the temporary caches that are
used before the slab allocator and kasan are initialized?

>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/805d1e85-2d3c-2327-6e6c-f14a56dc0b67%40virtuozzo.com.
> For more options, visit https://groups.google.com/d/optout.
