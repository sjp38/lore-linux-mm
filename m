Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 796806B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 12:32:16 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b203-v6so5181332wme.2
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 09:32:16 -0700 (PDT)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id w8-v6si5356243wrr.280.2018.07.05.09.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 09:32:14 -0700 (PDT)
Subject: Re: [RFC PATCH v1] powerpc/radix/kasan: KASAN support for Radix
References: <20170729140901.5887-1-bsingharora@gmail.com>
 <d00f364a-1683-7981-f912-7014d48dc9ad@virtuozzo.com>
 <CAKTCnznzKtZWD25pYysGosns6GQLOnqAOS-BV90FtLOuLwS36Q@mail.gmail.com>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <269e0e4b-7eb2-6f89-4a52-4cf2d114b4b0@c-s.fr>
Date: Thu, 5 Jul 2018 18:32:12 +0200
MIME-Version: 1.0
In-Reply-To: <CAKTCnznzKtZWD25pYysGosns6GQLOnqAOS-BV90FtLOuLwS36Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: kasan-dev@googlegroups.com, linux-mm <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, Dmitry Vyukov <dvyukov@google.com>

Hello Balbir,

Are you still working on KASAN support ?

Thanks,
Christophe

Le 08/08/2017 A  03:18, Balbir Singh a A(C)critA :
> On Mon, Aug 7, 2017 at 10:30 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>> On 07/29/2017 05:09 PM, Balbir Singh wrote:
>>> This is the first attempt to implement KASAN for radix
>>> on powerpc64. Aneesh Kumar implemented KASAN for hash 64
>>> in limited mode (support only for kernel linear mapping)
>>> (https://lwn.net/Articles/655642/)
>>>
>>> This patch does the following:
>>> 1. Defines its own zero_page,pte,pmd and pud because
>>> the generic PTRS_PER_PTE, etc are variables on ppc64
>>> book3s. Since the implementation is for radix, we use
>>> the radix constants. This patch uses ARCH_DEFINES_KASAN_ZERO_PTE
>>> for that purpose
>>> 2. There is a new function check_return_arch_not_ready()
>>> which is defined for ppc64/book3s/radix and overrides the
>>> checks in check_memory_region_inline() until the arch has
>>> done kasan setup is done for the architecture. This is needed
>>> for powerpc. A lot of functions are called in real mode prior
>>> to MMU paging init, we could fix some of this by using
>>> the kasan_early_init() bits, but that just maps the zero
>>> page and does not do useful reporting. For this RFC we
>>> just delay the checks in mem* functions till kasan_init()
>>
>> check_return_arch_not_ready() works only for outline instrumentation
>> and without stack instrumentation.
>>
>> I guess this works for you only because CONFIG_KASAN_SHADOW_OFFSET is not defined.
>> Therefore test for CFLAGS_KASAN can't pass, as '-fasan-shadow-offset= ' is invalid option,
>> so CFLAGS_KASAN_MINIMAL is used instead. Or maybe you just used gcc 4.9.x which don't have
>> full kasan support.
>> This is also the reason why some tests doesn't pass for you.
>>
>> For stack instrumentation you'll have to implement kasan_early_init() and define CONFIG_KASAN_SHADOW_OFFSET.
> 
> Yep, I noticed that a little later when reading the build log,
> scripts/Makefile.kasan does
> print a warning. I guess we'll need to do early_init() because
> kasan_init() can happen only
> once we've setup our memblocks after parsing the device-tree.
> 
>>
>>> 3. This patch renames memcpy/memset/memmove to their
>>> equivalent __memcpy/__memset/__memmove and for files
>>> that skip KASAN via KASAN_SANITIZE, we use the __
>>> variants. This is largely based on Aneesh's patchset
>>> mentioned above
>>> 4. In paca.c, some explicit memcpy inserted by the
>>> compiler/linker is replaced via explicit memcpy
>>> for structure content copying
>>> 5. prom_init and a few other files have KASAN_SANITIZE
>>> set to n, I think with the delayed checks (#2 above)
>>> we might be able to work around many of them
>>> 6. Resizing of virtual address space is done a little
>>> aggressively the size is reduced to 1/4 and totally
>>> to 1/2. For the RFC it was considered OK, since this
>>> is just a debug tool for developers. This can be revisited
>>> in the final implementation
>>>
>>> Tests:
>>>
>>> I ran test_kasan.ko and it reported errors for all test
>>> cases except for
>>>
>>> kasan test: memcg_accounted_kmem_cache allocate memcg accounted object
>>> kasan test: kasan_stack_oob out-of-bounds on stack
>>> kasan test: kasan_global_oob out-of-bounds global variable
>>> kasan test: use_after_scope_test use-after-scope on int
>>> kasan test: use_after_scope_test use-after-scope on array
>>>
>>> Based on my understanding of the test, which is an expected
>>> kasan bug report after each test starting with a "===" line.
>>>
>>
>> Right, with exception of memc_accounted_kmem_cache test.
>> The rest are expected to produce the kasan report unless CLFAGS_KASAN_MINIMAL
>> used.
>> use_after_scope tests also require fresh gcc 7.
> 
> 
> Yep, Thanks for the review!
> 
> I'll work on a v2 and resend the patches
> 
> Balbir Singh.
> 
