Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id B1FAC6B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 07:58:01 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id b6so13460726lbj.11
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 04:58:00 -0800 (PST)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com. [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id ss9si17819611lbb.89.2015.01.21.04.58.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 04:58:00 -0800 (PST)
Received: by mail-la0-f45.google.com with SMTP id gd6so16269688lab.4
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 04:58:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150120160738.edfe64806cc8b943beb1dfa0@linux-foundation.org>
References: <20150120140200.aa7ba0eb28d95e456972e178@freescale.com>
	<20150120230150.GA14475@cloud>
	<20150120160738.edfe64806cc8b943beb1dfa0@linux-foundation.org>
Date: Wed, 21 Jan 2015 21:57:59 +0900
Message-ID: <CAC5umyieZn7ppXkKb45O=C=BF+iv6R_A1Dwfhro=cBJzFeovrA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: fix undefined reference to `.kernel_map_pages' on
 PPC builds
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: josh@joshtriplett.org, Kim Phillips <kim.phillips@freescale.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Al Viro <viro@zeniv.linux.org.uk>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Jens Axboe <axboe@fb.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

2015-01-21 9:07 GMT+09:00 Andrew Morton <akpm@linux-foundation.org>:
> On Tue, 20 Jan 2015 15:01:50 -0800 josh@joshtriplett.org wrote:
>
>> On Tue, Jan 20, 2015 at 02:02:00PM -0600, Kim Phillips wrote:
>> > It's possible to configure DEBUG_PAGEALLOC without PAGE_POISONING on
>> > ppc.  Fix building the generic kernel_map_pages() implementation in
>> > this case:
>> >
>> >   LD      init/built-in.o
>> > mm/built-in.o: In function `free_pages_prepare':
>> > mm/page_alloc.c:770: undefined reference to `.kernel_map_pages'
>> > mm/built-in.o: In function `prep_new_page':
>> > mm/page_alloc.c:933: undefined reference to `.kernel_map_pages'
>> > mm/built-in.o: In function `map_pages':
>> > mm/compaction.c:61: undefined reference to `.kernel_map_pages'
>> > make: *** [vmlinux] Error 1

kernel_map_pages() is static inline function since commit 031bc5743f15
("mm/debug-pagealloc: make debug-pagealloc boottime configurable").

But there is old declaration in 'arch/powerpc/include/asm/cacheflush.h'.
Removing it or changing s/kernel_map_pages/__kernel_map_pages/ in this
header file or something can fix this problem?

The architecture which has ARCH_SUPPORTS_DEBUG_PAGEALLOC
including PPC should not build mm/debug-pagealloc.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
