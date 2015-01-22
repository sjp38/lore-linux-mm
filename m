Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8729B6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 18:49:39 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id u10so4379050lbd.9
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 15:49:38 -0800 (PST)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com. [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id yv9si19470024lbb.103.2015.01.22.15.49.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 15:49:37 -0800 (PST)
Received: by mail-la0-f54.google.com with SMTP id hv19so4541294lab.13
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 15:49:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150122144147.019eedc41f189eac44c3c4cd@freescale.com>
References: <20150120140200.aa7ba0eb28d95e456972e178@freescale.com>
	<20150120230150.GA14475@cloud>
	<20150120160738.edfe64806cc8b943beb1dfa0@linux-foundation.org>
	<CAC5umyieZn7ppXkKb45O=C=BF+iv6R_A1Dwfhro=cBJzFeovrA@mail.gmail.com>
	<20150122014550.GA21444@js1304-P5Q-DELUXE>
	<20150122144147.019eedc41f189eac44c3c4cd@freescale.com>
Date: Fri, 23 Jan 2015 08:49:36 +0900
Message-ID: <CAC5umyiF52cykH2_5TD0yzXb+842gywpe-+XZHEwmrDe0nYCPw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: fix undefined reference to `.kernel_map_pages' on
 PPC builds
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kim Phillips <kim.phillips@freescale.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, josh@joshtriplett.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Al Viro <viro@zeniv.linux.org.uk>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Jens Axboe <axboe@fb.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

2015-01-23 5:41 GMT+09:00 Kim Phillips <kim.phillips@freescale.com>:
> On Thu, 22 Jan 2015 10:45:51 +0900
> Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>
>> On Wed, Jan 21, 2015 at 09:57:59PM +0900, Akinobu Mita wrote:
>> > 2015-01-21 9:07 GMT+09:00 Andrew Morton <akpm@linux-foundation.org>:
>> > > On Tue, 20 Jan 2015 15:01:50 -0800 josh@joshtriplett.org wrote:
>> > >
>> > >> On Tue, Jan 20, 2015 at 02:02:00PM -0600, Kim Phillips wrote:
>> > >> > It's possible to configure DEBUG_PAGEALLOC without PAGE_POISONING on
>> > >> > ppc.  Fix building the generic kernel_map_pages() implementation in
>> > >> > this case:
>> > >> >
>> > >> >   LD      init/built-in.o
>> > >> > mm/built-in.o: In function `free_pages_prepare':
>> > >> > mm/page_alloc.c:770: undefined reference to `.kernel_map_pages'
>> > >> > mm/built-in.o: In function `prep_new_page':
>> > >> > mm/page_alloc.c:933: undefined reference to `.kernel_map_pages'
>> > >> > mm/built-in.o: In function `map_pages':
>> > >> > mm/compaction.c:61: undefined reference to `.kernel_map_pages'
>> > >> > make: *** [vmlinux] Error 1
>> >
>> > kernel_map_pages() is static inline function since commit 031bc5743f15
>> > ("mm/debug-pagealloc: make debug-pagealloc boottime configurable").
>> >
>> > But there is old declaration in 'arch/powerpc/include/asm/cacheflush.h'.
>> > Removing it or changing s/kernel_map_pages/__kernel_map_pages/ in this
>> > header file or something can fix this problem?
>> >
>> > The architecture which has ARCH_SUPPORTS_DEBUG_PAGEALLOC
>> > including PPC should not build mm/debug-pagealloc.o
>>
>> Yes, architecture with ARCH_SUPPORTS_DEBUG_PAGEALLOC should not build
>> mm/debug-pagealloc.o. I attach the patch to remove old declaration.
>> I hope it will fix Kim's problem.
>>
>> -------------->8------------------
>> From 7cb9d1ed8a785df152cb8934e187031c8ebd1bb2 Mon Sep 17 00:00:00 2001
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Date: Thu, 22 Jan 2015 10:28:58 +0900
>> Subject: [PATCH] mm/debug_pagealloc: fix build failure on ppc and some other
>>  archs
>>
>> Kim Phillips reported following build failure.
>>
>>   LD      init/built-in.o
>>   mm/built-in.o: In function `free_pages_prepare':
>>   mm/page_alloc.c:770: undefined reference to `.kernel_map_pages'
>>   mm/built-in.o: In function `prep_new_page':
>>   mm/page_alloc.c:933: undefined reference to `.kernel_map_pages'
>>   mm/built-in.o: In function `map_pages':
>>   mm/compaction.c:61: undefined reference to `.kernel_map_pages'
>>   make: *** [vmlinux] Error 1
>>
>> Reason for this problem is that commit 031bc5743f15
>> ("mm/debug-pagealloc: make debug-pagealloc boottime configurable") forgot
>> to remove old declaration of kernel_map_pages() in some architectures.
>> This patch removes them to fix build failure.
>>
>> Reported-by: Kim Phillips <kim.phillips@freescale.com>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> ---
>
> Thanks. Now I get this:
>
>   LD      init/built-in.o
> mm/built-in.o: In function `kernel_map_pages':
> include/linux/mm.h:2076: undefined reference to `.__kernel_map_pages'
> include/linux/mm.h:2076: undefined reference to `.__kernel_map_pages'
> include/linux/mm.h:2076: undefined reference to `.__kernel_map_pages'
> Makefile:925: recipe for target 'vmlinux' failed
> make: *** [vmlinux] Error 1
>
> but, AFAICT, that's not because this patch is invalid: it's because
> __kernel_map_pages() isn't implemented in
> arch/powerpc/mm/pgtable_64.c, i.e., for non-PPC_STD_MMU_64 PPC64
> machines.

Then, in order to use generic __kernel_map_pages() in mm/debug-pagealloc.c,
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC shouldn't be selected in
arch/powerpc/Kconfig, when CONFIG_PPC_STD_MMU_64 isn't defined.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
