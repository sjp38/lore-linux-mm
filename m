Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 918F56B0038
	for <linux-mm@kvack.org>; Tue, 16 May 2017 00:34:39 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id j62so49721912uaj.12
        for <linux-mm@kvack.org>; Mon, 15 May 2017 21:34:39 -0700 (PDT)
Received: from mail-ua0-x22c.google.com (mail-ua0-x22c.google.com. [2607:f8b0:400c:c08::22c])
        by mx.google.com with ESMTPS id p63si5160477vkp.205.2017.05.15.21.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 21:34:38 -0700 (PDT)
Received: by mail-ua0-x22c.google.com with SMTP id e28so92554009uah.0
        for <linux-mm@kvack.org>; Mon, 15 May 2017 21:34:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 15 May 2017 21:34:17 -0700
Message-ID: <CACT4Y+ZVrs9XDk5QXkQyej+xFwKrgnGn-RPBC+pL5znUp2aSCg@mail.gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, May 15, 2017 at 6:16 PM,  <js1304@gmail.com> wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Hello, all.
>
> This is an attempt to recude memory consumption of KASAN. Please see
> following description to get the more information.
>
> 1. What is per-page shadow memory

Hi Joonsoo,

First I need to say that this is great work. I wanted KASAN to consume
1/8-th of _kernel_ memory rather than total physical memory for a long
time.

However, this implementation does not work inline instrumentation. And
the inline instrumentation is the main mode for KASAN. Outline
instrumentation is merely a rudiment to support gcc 4.9, and it needs
to be removed as soon as we stop caring about gcc 4.9 (do we at all?
is it the current compiler in any distro? Ubuntu 12 has 4.8, Ubuntu 14
already has 5.4. And if you build gcc yourself or get a fresher
compiler from somewhere else, you hopefully get something better than
4.9).

Here is an example boot+scp log with inline instrumentation:
https://gist.githubusercontent.com/dvyukov/dfdc8b6972ddd260b201a85d5d5cdb5d/raw/2a032cd5be371c7ad6cad8f14c0a0610e6fa772e/gistfile1.txt

Joonsoo, can you think of a way to take advantages of your approach,
but make it work with inline instrumentation?

Will it work if we map a single zero page for whole shadow initially,
and then lazily map real shadow pages only for kernel memory, and then
remap it again to zero pages when the whole KASAN_SHADOW_SCALE_SHIFT
range of pages becomes unused (similarly to what you do in
kasan_unmap_shadow())?





> This patch introduces infrastructure to support per-page shadow memory.
> Per-page shadow memory is the same with original shadow memory except
> the granualarity. It's one byte shows the shadow value for the page.
> The purpose of introducing this new shadow memory is to save memory
> consumption.
>
> 2. Problem of current approach
>
> Until now, KASAN needs shadow memory for all the range of the memory
> so the amount of statically allocated memory is so large. It causes
> the problem that KASAN cannot run on the system with hard memory
> constraint. Even if KASAN can run, large memory consumption due to
> KASAN changes behaviour of the workload so we cannot validate
> the moment that we want to check.
>
> 3. How does this patch fix the problem
>
> This patch tries to fix the problem by reducing memory consumption for
> the shadow memory. There are two observations.
>
> 1) Type of memory usage can be distinguished well.
> 2) Shadow memory is manipulated/checked in byte unit only for slab,
> kernel stack and global variable. Shadow memory for other usecases
> just show KASAN_FREE_PAGE or 0 (means valid) in page unit.
>
> With these two observations, I think an optimized way to support
> KASAN feature.
>
> 1) Introduces per-page shadow that cover all the memory
> 2) Checks validity of the access through per-page shadow except
> that checking object is a slab, kernel stack, global variable
> 3) For those byte accessible types of object, allocate/map original
> shadow by on-demand and checks validity of the access through
> original shadow
>
> Instead original shadow statically consumes 1/8 bytes of the amount of
> total memory, per-page shadow statically consumes 1/PAGE_SIZE bytes of it.
> Extra memory is required for a slab, kernel stack and global variable by
> on-demand in runtime, however, it would not be larger than before.
>
> 4. Result
>
> Following is the result of the memory consumption on my QEMU system.
> 'runtime' shows the maximum memory usage for on-demand shadow allocation
> during the kernel build workload.
>
> base vs patched
>
> MemTotal: 858 MB vs 987 MB
> runtime: 0 MB vs 30MB
> Net Available: 858 MB vs 957 MB
>
> For 4096 MB QEMU system
>
> MemTotal: 3477 MB vs 4000 MB
> runtime: 0 MB vs 50MB
>
> base vs patched (2048 MB QEMU system)
> 204 s vs 224 s
> Net Available: 3477 MB vs 3950 MB
>
> Thanks.
>
> Joonsoo Kim (11):
>   mm/kasan: rename XXX_is_zero to XXX_is_nonzero
>   mm/kasan: don't fetch the next shadow value speculartively
>   mm/kasan: handle unaligned end address in zero_pte_populate
>   mm/kasan: extend kasan_populate_zero_shadow()
>   mm/kasan: introduce per-page shadow memory infrastructure
>   mm/kasan: mark/unmark the target range that is for original shadow
>     memory
>   x86/kasan: use per-page shadow memory
>   mm/kasan: support on-demand shadow allocation/mapping
>   x86/kasan: support on-demand shadow mapping
>   mm/kasan: support dynamic shadow memory free
>   mm/kasan: change the order of shadow memory check
>
>  arch/arm64/mm/kasan_init.c       |  17 +-
>  arch/x86/include/asm/kasan.h     |   8 +
>  arch/x86/include/asm/processor.h |   4 +
>  arch/x86/kernel/cpu/common.c     |   4 +-
>  arch/x86/kernel/setup_percpu.c   |   2 +
>  arch/x86/mm/kasan_init_64.c      | 191 ++++++++++++--
>  include/linux/kasan.h            |  71 ++++-
>  kernel/fork.c                    |   7 +
>  mm/kasan/kasan.c                 | 555 +++++++++++++++++++++++++++++++++------
>  mm/kasan/kasan.h                 |  22 +-
>  mm/kasan/kasan_init.c            | 158 ++++++++---
>  mm/kasan/report.c                |  28 ++
>  mm/page_alloc.c                  |  10 +
>  mm/slab.c                        |   9 +
>  mm/slab_common.c                 |  11 +-
>  mm/slub.c                        |   8 +
>  16 files changed, 957 insertions(+), 148 deletions(-)
>
> --
> 2.7.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
