Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F08C36B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 21:18:58 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q66so9513220qki.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 18:18:58 -0700 (PDT)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id w67si140375qkc.114.2017.08.07.18.18.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 18:18:57 -0700 (PDT)
Received: by mail-qt0-x241.google.com with SMTP id d10so2071396qtb.4
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 18:18:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d00f364a-1683-7981-f912-7014d48dc9ad@virtuozzo.com>
References: <20170729140901.5887-1-bsingharora@gmail.com> <d00f364a-1683-7981-f912-7014d48dc9ad@virtuozzo.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 8 Aug 2017 11:18:56 +1000
Message-ID: <CAKTCnznzKtZWD25pYysGosns6GQLOnqAOS-BV90FtLOuLwS36Q@mail.gmail.com>
Subject: Re: [RFC PATCH v1] powerpc/radix/kasan: KASAN support for Radix
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, kasan-dev@googlegroups.com, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>

On Mon, Aug 7, 2017 at 10:30 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> On 07/29/2017 05:09 PM, Balbir Singh wrote:
>> This is the first attempt to implement KASAN for radix
>> on powerpc64. Aneesh Kumar implemented KASAN for hash 64
>> in limited mode (support only for kernel linear mapping)
>> (https://lwn.net/Articles/655642/)
>>
>> This patch does the following:
>> 1. Defines its own zero_page,pte,pmd and pud because
>> the generic PTRS_PER_PTE, etc are variables on ppc64
>> book3s. Since the implementation is for radix, we use
>> the radix constants. This patch uses ARCH_DEFINES_KASAN_ZERO_PTE
>> for that purpose
>> 2. There is a new function check_return_arch_not_ready()
>> which is defined for ppc64/book3s/radix and overrides the
>> checks in check_memory_region_inline() until the arch has
>> done kasan setup is done for the architecture. This is needed
>> for powerpc. A lot of functions are called in real mode prior
>> to MMU paging init, we could fix some of this by using
>> the kasan_early_init() bits, but that just maps the zero
>> page and does not do useful reporting. For this RFC we
>> just delay the checks in mem* functions till kasan_init()
>
> check_return_arch_not_ready() works only for outline instrumentation
> and without stack instrumentation.
>
> I guess this works for you only because CONFIG_KASAN_SHADOW_OFFSET is not defined.
> Therefore test for CFLAGS_KASAN can't pass, as '-fasan-shadow-offset= ' is invalid option,
> so CFLAGS_KASAN_MINIMAL is used instead. Or maybe you just used gcc 4.9.x which don't have
> full kasan support.
> This is also the reason why some tests doesn't pass for you.
>
> For stack instrumentation you'll have to implement kasan_early_init() and define CONFIG_KASAN_SHADOW_OFFSET.

Yep, I noticed that a little later when reading the build log,
scripts/Makefile.kasan does
print a warning. I guess we'll need to do early_init() because
kasan_init() can happen only
once we've setup our memblocks after parsing the device-tree.

>
>> 3. This patch renames memcpy/memset/memmove to their
>> equivalent __memcpy/__memset/__memmove and for files
>> that skip KASAN via KASAN_SANITIZE, we use the __
>> variants. This is largely based on Aneesh's patchset
>> mentioned above
>> 4. In paca.c, some explicit memcpy inserted by the
>> compiler/linker is replaced via explicit memcpy
>> for structure content copying
>> 5. prom_init and a few other files have KASAN_SANITIZE
>> set to n, I think with the delayed checks (#2 above)
>> we might be able to work around many of them
>> 6. Resizing of virtual address space is done a little
>> aggressively the size is reduced to 1/4 and totally
>> to 1/2. For the RFC it was considered OK, since this
>> is just a debug tool for developers. This can be revisited
>> in the final implementation
>>
>> Tests:
>>
>> I ran test_kasan.ko and it reported errors for all test
>> cases except for
>>
>> kasan test: memcg_accounted_kmem_cache allocate memcg accounted object
>> kasan test: kasan_stack_oob out-of-bounds on stack
>> kasan test: kasan_global_oob out-of-bounds global variable
>> kasan test: use_after_scope_test use-after-scope on int
>> kasan test: use_after_scope_test use-after-scope on array
>>
>> Based on my understanding of the test, which is an expected
>> kasan bug report after each test starting with a "===" line.
>>
>
> Right, with exception of memc_accounted_kmem_cache test.
> The rest are expected to produce the kasan report unless CLFAGS_KASAN_MINIMAL
> used.
> use_after_scope tests also require fresh gcc 7.


Yep, Thanks for the review!

I'll work on a v2 and resend the patches

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
