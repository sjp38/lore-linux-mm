Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 34F188E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 07:54:26 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id k204-v6so15221711ite.1
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 04:54:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1-v6sor12010658ioc.205.2018.09.19.04.54.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 04:54:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+YicYhmzrKf84=oJJErdFKSNM70cmoN3m_zzERcUQ_-Fg@mail.gmail.com>
References: <cover.1535462971.git.andreyknvl@google.com> <4267d0903e0fdf9c261b91cf8a2bf0f71047a43c.1535462971.git.andreyknvl@google.com>
 <CACT4Y+YicYhmzrKf84=oJJErdFKSNM70cmoN3m_zzERcUQ_-Fg@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 19 Sep 2018 13:54:23 +0200
Message-ID: <CAAeHK+xMjDwZkKDn_0aVWERkjv6B-hFKjn0coGo4LbcPBds4Ew@mail.gmail.com>
Subject: Re: [PATCH v6 14/18] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Sep 12, 2018 at 8:30 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Aug 29, 2018 at 1:35 PM, Andrey Konovalov <andreyknvl@google.com> wrote:

>>  void kasan_unpoison_shadow(const void *address, size_t size)
>>  {
>> -       kasan_poison_shadow(address, size, 0);
>> +       u8 tag = get_tag(address);
>> +
>> +       /* Perform shadow offset calculation based on untagged address */
>
> The comment is not super-useful. It would be more useful to say why we
> need to do this.
> Most callers explicitly untag pointer passed to this function, for
> some it's unclear if the pointer contains tag or not.
> For example, __hwasan_tag_memory -- what does it accept? Tagged or untagged?

There are some callers that pass tagged pointers to this functions,
e.g. ksize or kasan_unpoison_object_data. I'll expand the comment.

>
>
>> +       address = reset_tag(address);
>> +
>> +       kasan_poison_shadow(address, size, tag);
>>
>>         if (size & KASAN_SHADOW_MASK) {
>>                 u8 *shadow = (u8 *)kasan_mem_to_shadow(address + size);
>> -               *shadow = size & KASAN_SHADOW_MASK;
>> +
>> +               if (IS_ENABLED(CONFIG_KASAN_HW))
>> +                       *shadow = tag;
>> +               else
>> +                       *shadow = size & KASAN_SHADOW_MASK;
>>         }
>>  }
>
>
> It seems that this function is just different for kasan and khwasan.
> Currently for kasan we have:
>
> kasan_poison_shadow(address, size, tag);
> if (size & KASAN_SHADOW_MASK) {
>         u8 *shadow = (u8 *)kasan_mem_to_shadow(address + size);
>         *shadow = size & KASAN_SHADOW_MASK;
> }
>
> But what we want to say for khwasan is:
>
> kasan_poison_shadow(address, round_up(size, KASAN_SHADOW_SCALE_SIZE),
> get_tag(address));
>
> Not sure if we want to keep a common implementation or just have
> separate implementations...

As per offline discussion leaving as is.


>>  void kasan_free_pages(struct page *page, unsigned int order)
>> @@ -235,6 +248,7 @@ void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
>>                         slab_flags_t *flags)
>>  {
>>         unsigned int orig_size = *size;
>> +       unsigned int redzone_size = 0;
>
> This variable seems to be always initialized below. We don't general
> initialize local variables in this case.

Will fix in v7.

>>  void check_memory_region(unsigned long addr, size_t size, bool write,
>>                                 unsigned long ret_ip)
>>  {
>> +       u8 tag;
>> +       u8 *shadow_first, *shadow_last, *shadow;
>> +       void *untagged_addr;
>> +
>> +       tag = get_tag((const void *)addr);
>> +
>> +       /* Ignore accesses for pointers tagged with 0xff (native kernel
>
> /* on a separate line

Will fix in v7.

>
>> +        * pointer tag) to suppress false positives caused by kmap.
>> +        *
>> +        * Some kernel code was written to account for archs that don't keep
>> +        * high memory mapped all the time, but rather map and unmap particular
>> +        * pages when needed. Instead of storing a pointer to the kernel memory,
>> +        * this code saves the address of the page structure and offset within
>> +        * that page for later use. Those pages are then mapped and unmapped
>> +        * with kmap/kunmap when necessary and virt_to_page is used to get the
>> +        * virtual address of the page. For arm64 (that keeps the high memory
>> +        * mapped all the time), kmap is turned into a page_address call.
>> +
>> +        * The issue is that with use of the page_address + virt_to_page
>> +        * sequence the top byte value of the original pointer gets lost (gets
>> +        * set to KHWASAN_TAG_KERNEL (0xFF).
>
> Missed closing bracket.

Will fix in v7.
