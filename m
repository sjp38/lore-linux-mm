Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 126F26B0006
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 11:20:40 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id b141-v6so432924ywh.12
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 08:20:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t128-v6sor2082942ybf.33.2018.07.23.08.20.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 08:20:34 -0700 (PDT)
Date: Mon, 23 Jul 2018 11:23:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 02/10] mm: workingset: tell cache transitions from
 workingset thrashing
Message-ID: <20180723152323.GA3699@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-3-hannes@cmpxchg.org>
 <CAK8P3a3Nsmt54-ed_gWNev3CBS6_Sv5QGOw4G0sY4ZXOi1R4_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK8P3a3Nsmt54-ed_gWNev3CBS6_Sv5QGOw4G0sY4ZXOi1R4_Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Linux-MM <linux-mm@kvack.org>, cgroups@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>

Hi Arnd,

On Mon, Jul 23, 2018 at 03:36:09PM +0200, Arnd Bergmann wrote:
> On Thu, Jul 12, 2018 at 7:29 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > How many page->flags does this leave us with on 32-bit?
> >
> >         20 bits are always page flags
> >
> >         21 if you have an MMU
> >
> >         23 with the zone bits for DMA, Normal, HighMem, Movable
> >
> >         29 with the sparsemem section bits
> >
> >         30 if PAE is enabled
> >
> >         31 with this patch.
> >
> > So on 32-bit PAE, that leaves 1 bit for distinguishing two NUMA
> > nodes. If that's not enough, the system can switch to discontigmem and
> > re-gain the 6 or 7 sparsemem section bits.
> >
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> It seems we ran out of bits on arm64 in randconfig builds:
> 
> In file included from /git/arm-soc/include/linux/kernel.h:10,
>                  from /git/arm-soc/arch/arm64/mm/init.c:20:
> /git/arm-soc/arch/arm64/mm/init.c: In function 'mem_init':
> /git/arm-soc/include/linux/compiler.h:357:38: error: call to
> '__compiletime_assert_618' declared with attribute error: BUILD_BUG_ON
> failed: sizeof(struct page) > (1 << STRUCT_PAGE_MAX_SHIFT)

This BUILD_BUG_ON() is to make sure we're sizing the VMEMMAP struct
page array properly (address space divided by struct page size).

>From the code:

/*
 * Log2 of the upper bound of the size of a struct page. Used for sizing
 * the vmemmap region only, does not affect actual memory footprint.
 * We don't use sizeof(struct page) directly since taking its size here
 * requires its definition to be available at this point in the inclusion
 * chain, and it may not be a power of 2 in the first place.
 */
#define STRUCT_PAGE_MAX_SHIFT	6

> Apparently this triggered
> 
> #if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <=
> BITS_PER_LONG - NR_PAGEFLAGS
> #define LAST_CPUPID_WIDTH LAST_CPUPID_SHIFT
> #else
> #define LAST_CPUPID_WIDTH 0
> #endif
> 
> and in turn
> 
> #if defined(CONFIG_NUMA_BALANCING) && LAST_CPUPID_WIDTH == 0
> #define LAST_CPUPID_NOT_IN_PAGE_FLAGS
> #endif
> 
> and that _last_cpupid in struct page made sizeof(struct page) larger than 64.
> 
> This is for a randconfig build, see https://pastebin.com/YuwSTah3
> for the configuration file, some of the relevant options are
> 
> CONFIG_64BIT=y
> CONFIG_MEMCG=y
> CONFIG_SPARSEMEM=y
> CONFIG_ARM64_PA_BITS=52
> CONFIG_ARM64_64K_PAGES=y
> CONFIG_NR_CPUS=64
> CONFIG_NUMA_BALANCING=y
> # CONFIG_SPARSEMEM_VMEMMAP is not set

However, the check isn't conditional on that config option. And when
VMEMMAP is disabled, we need 22 additional bits to identify the sparse
memory sections in page->flags as well:

> CONFIG_NODES_SHIFT=2
> # CONFIG_ARCH_USES_PG_UNCACHED is not set
> CONFIG_MEMORY_FAILURE=y
> CONFIG_IDLE_PAGE_TRACKING=y
> 
> #define MAX_NR_ZONES 3
> #define ZONES_SHIFT 2
> #define MAX_PHYSMEM_BITS 52
> #define SECTION_SIZE_BITS 30
> #define SECTIONS_WIDTH 22

^^^ Those we get back with VMEMMAP enabled.

So for configs for which the check is intended, it passes. We just
need to make it conditional to those.

---
