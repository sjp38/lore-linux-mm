Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 55CFD6B0005
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 04:04:12 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v5-v6so2675946wmh.6
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 01:04:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m184-v6sor966151wmd.84.2018.06.06.01.04.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Jun 2018 01:04:10 -0700 (PDT)
Date: Wed, 6 Jun 2018 10:04:08 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: kernel panic in reading /proc/kpageflags when enabling
 RAM-simulated PMEM
Message-ID: <20180606080408.GA31794@techadventures.net>
References: <20180605005402.GA22975@hori1.linux.bs1.fc.nec.co.jp>
 <20180605011836.GA32444@bombadil.infradead.org>
 <20180605073500.GA23766@hori1.linux.bs1.fc.nec.co.jp>
 <20180606051624.GA16021@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180606051624.GA16021@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Matthew Wilcox <willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "mingo@kernel.org" <mingo@kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

On Wed, Jun 06, 2018 at 05:16:24AM +0000, Naoya Horiguchi wrote:
> On Tue, Jun 05, 2018 at 07:35:01AM +0000, Horiguchi Naoya(a ?a?GBP c?'a1?) wrote:
> > On Mon, Jun 04, 2018 at 06:18:36PM -0700, Matthew Wilcox wrote:
> > > On Tue, Jun 05, 2018 at 12:54:03AM +0000, Naoya Horiguchi wrote:
> > > > Reproduction precedure is like this:
> > > >  - enable RAM based PMEM (with a kernel boot parameter like memmap=1G!4G)
> > > >  - read /proc/kpageflags (or call tools/vm/page-types with no arguments)
> > > >  (- my kernel config is attached)
> > > > 
> > > > I spent a few days on this, but didn't reach any solutions.
> > > > So let me report this with some details below ...
> > > > 
> > > > In the critial page request, stable_page_flags() is called with an argument
> > > > page whose ->compound_head was somehow filled with '0xffffffffffffffff'.
> > > > And compound_head() returns (struct page *)(head - 1), which explains the
> > > > address 0xfffffffffffffffe in the above message.
> > > 
> > > Hm.  compound_head shares with:
> > > 
> > >                         struct list_head lru;
> > >                                 struct list_head slab_list;     /* uses lru */
> > >                                 struct {        /* Partial pages */
> > >                                         struct page *next;
> > >                         unsigned long _compound_pad_1;  /* compound_head */
> > >                         unsigned long _pt_pad_1;        /* compound_head */
> > >                         struct dev_pagemap *pgmap;
> > >                 struct rcu_head rcu_head;
> > > 
> > > None of them should be -1.
> > > 
> > > > It seems that this kernel panic happens when reading kpageflags of pfn range
> > > > [0xbffd7, 0xc0000), which coresponds to a 'reserved' range.
> > > > 
> > > > [    0.000000] user-defined physical RAM map:
> > > > [    0.000000] user: [mem 0x0000000000000000-0x000000000009fbff] usable
> > > > [    0.000000] user: [mem 0x000000000009fc00-0x000000000009ffff] reserved
> > > > [    0.000000] user: [mem 0x00000000000f0000-0x00000000000fffff] reserved
> > > > [    0.000000] user: [mem 0x0000000000100000-0x00000000bffd6fff] usable
> > > > [    0.000000] user: [mem 0x00000000bffd7000-0x00000000bfffffff] reserved
> > > > [    0.000000] user: [mem 0x00000000feffc000-0x00000000feffffff] reserved
> > > > [    0.000000] user: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
> > > > [    0.000000] user: [mem 0x0000000100000000-0x000000013fffffff] persistent (type 12)
> > > > 
> > > > So I guess 'memmap=' parameter might badly affect the memory initialization process.
> > > > 
> > > > This problem doesn't reproduce on v4.17, so some pre-released patch introduces it.
> > > > I hope this info helps you find the solution/workaround.
> > > 
> > > Can you try bisecting this?  It could be one of my patches to reorder struct
> > > page, or it could be one of Pavel's deferred page initialisation patches.
> > > Or something else ;-)
> > 
> > Thank you for the comment. I'm trying bisecting now, let you know the result later.
> > 
> > And I found that my statement "not reproduce on v4.17" was wrong (I used
> > different kvm guests, which made some different test condition and misguided me),
> > this seems an older (at least < 4.15) bug.
> 
> (Cc: Pavel)
> 
> Bisection showed that the following commit introduced this issue:
> 
>   commit f7f99100d8d95dbcf09e0216a143211e79418b9f
>   Author: Pavel Tatashin <pasha.tatashin@oracle.com>
>   Date:   Wed Nov 15 17:36:44 2017 -0800
>   
>       mm: stop zeroing memory during allocation in vmemmap
> 
> This patch postpones struct page zeroing to later stage of memory initialization.
> My kernel config disabled CONFIG_DEFERRED_STRUCT_PAGE_INIT so two callsites of
> __init_single_page() were never reached. So in such case, struct pages populated
> by vmemmap_pte_populate() could be left uninitialized?
> And I'm not sure yet how this issue becomes visible with memmap= setting.

I think that this becomes visible because memmap=x!y creates a persistent memory region:

parse_memmap_one
{
	...
        } else if (*p == '!') {
                start_at = memparse(p+1, &p);
                e820__range_add(start_at, mem_size, E820_TYPE_PRAM);
	...
}

and this region it is not added neither in memblock.memory nor in memblock.reserved.
Ranges in memblock.memory get zeroed in memmap_init_zone(), while memblock.reserved get zeroed 
in free_low_memory_core_early():

static unsigned long __init free_low_memory_core_early(void)
{
	...
	for_each_reserved_mem_region(i, &start, &end)
		reserve_bootmem_region(start, end);
	...
}


Maybe I am mistaken, but I think that persistent memory regions should be marked as reserved.
A comment in do_mark_busy() suggests this:

static bool __init do_mark_busy(enum e820_type type, struct resource *res)
{

	...
        /*
         * Treat persistent memory like device memory, i.e. reserve it
         * for exclusive use of a driver
         */
	...
}


I wonder if something like this could work and if so, if it is right (i haven't tested it yet):

diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 71c11ad5643e..3c9686ef74e5 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -1247,6 +1247,11 @@ void __init e820__memblock_setup(void)
                if (end != (resource_size_t)end)
                        continue;
 
+               if (entry->type == E820_TYPE_PRAM || entry->type == E820_TYPE_PMEM) {
+                       memblock_reserve(entry->addr, entry->size);
+                       continue;
+               }
+
                if (entry->type != E820_TYPE_RAM && entry->type != E820_TYPE_RESERVED_KERN)
                        continue;

Best Regards
Oscar Salvador
