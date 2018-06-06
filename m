Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 278746B0005
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 05:07:21 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id k62-v6so3275047oiy.1
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 02:07:21 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id 127-v6si9321454oie.236.2018.06.06.02.07.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jun 2018 02:07:19 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: kernel panic in reading /proc/kpageflags when enabling
 RAM-simulated PMEM
Date: Wed, 6 Jun 2018 09:06:30 +0000
Message-ID: <20180606090630.GA27065@hori1.linux.bs1.fc.nec.co.jp>
References: <20180605005402.GA22975@hori1.linux.bs1.fc.nec.co.jp>
 <20180605011836.GA32444@bombadil.infradead.org>
 <20180605073500.GA23766@hori1.linux.bs1.fc.nec.co.jp>
 <20180606051624.GA16021@hori1.linux.bs1.fc.nec.co.jp>
 <20180606080408.GA31794@techadventures.net>
 <20180606085319.GA32052@techadventures.net>
In-Reply-To: <20180606085319.GA32052@techadventures.net>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <FA01F9358404DB46B837CAE13C18D29C@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Matthew Wilcox <willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "mingo@kernel.org" <mingo@kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

On Wed, Jun 06, 2018 at 10:53:19AM +0200, Oscar Salvador wrote:
> On Wed, Jun 06, 2018 at 10:04:08AM +0200, Oscar Salvador wrote:
> > On Wed, Jun 06, 2018 at 05:16:24AM +0000, Naoya Horiguchi wrote:
> > > On Tue, Jun 05, 2018 at 07:35:01AM +0000, Horiguchi Naoya(=1B$BKY8}=
=1B(B =1B$BD>Li=1B(B) wrote:
> > > > On Mon, Jun 04, 2018 at 06:18:36PM -0700, Matthew Wilcox wrote:
> > > > > On Tue, Jun 05, 2018 at 12:54:03AM +0000, Naoya Horiguchi wrote:
> > > > > > Reproduction precedure is like this:
> > > > > >  - enable RAM based PMEM (with a kernel boot parameter like mem=
map=3D1G!4G)
> > > > > >  - read /proc/kpageflags (or call tools/vm/page-types with no a=
rguments)
> > > > > >  (- my kernel config is attached)
> > > > > >
> > > > > > I spent a few days on this, but didn't reach any solutions.
> > > > > > So let me report this with some details below ...
> > > > > >
> > > > > > In the critial page request, stable_page_flags() is called with=
 an argument
> > > > > > page whose ->compound_head was somehow filled with '0xfffffffff=
fffffff'.
> > > > > > And compound_head() returns (struct page *)(head - 1), which ex=
plains the
> > > > > > address 0xfffffffffffffffe in the above message.
> > > > >
> > > > > Hm.  compound_head shares with:
> > > > >
> > > > >                         struct list_head lru;
> > > > >                                 struct list_head slab_list;     /=
* uses lru */
> > > > >                                 struct {        /* Partial pages =
*/
> > > > >                                         struct page *next;
> > > > >                         unsigned long _compound_pad_1;  /* compou=
nd_head */
> > > > >                         unsigned long _pt_pad_1;        /* compou=
nd_head */
> > > > >                         struct dev_pagemap *pgmap;
> > > > >                 struct rcu_head rcu_head;
> > > > >
> > > > > None of them should be -1.
> > > > >
> > > > > > It seems that this kernel panic happens when reading kpageflags=
 of pfn range
> > > > > > [0xbffd7, 0xc0000), which coresponds to a 'reserved' range.
> > > > > >
> > > > > > [    0.000000] user-defined physical RAM map:
> > > > > > [    0.000000] user: [mem 0x0000000000000000-0x000000000009fbff=
] usable
> > > > > > [    0.000000] user: [mem 0x000000000009fc00-0x000000000009ffff=
] reserved
> > > > > > [    0.000000] user: [mem 0x00000000000f0000-0x00000000000fffff=
] reserved
> > > > > > [    0.000000] user: [mem 0x0000000000100000-0x00000000bffd6fff=
] usable
> > > > > > [    0.000000] user: [mem 0x00000000bffd7000-0x00000000bfffffff=
] reserved
> > > > > > [    0.000000] user: [mem 0x00000000feffc000-0x00000000feffffff=
] reserved
> > > > > > [    0.000000] user: [mem 0x00000000fffc0000-0x00000000ffffffff=
] reserved
> > > > > > [    0.000000] user: [mem 0x0000000100000000-0x000000013fffffff=
] persistent (type 12)
> > > > > >
> > > > > > So I guess 'memmap=3D' parameter might badly affect the memory =
initialization process.
> > > > > >
> > > > > > This problem doesn't reproduce on v4.17, so some pre-released p=
atch introduces it.
> > > > > > I hope this info helps you find the solution/workaround.
> > > > >
> > > > > Can you try bisecting this?  It could be one of my patches to reo=
rder struct
> > > > > page, or it could be one of Pavel's deferred page initialisation =
patches.
> > > > > Or something else ;-)
> > > >
> > > > Thank you for the comment. I'm trying bisecting now, let you know t=
he result later.
> > > >
> > > > And I found that my statement "not reproduce on v4.17" was wrong (I=
 used
> > > > different kvm guests, which made some different test condition and =
misguided me),
> > > > this seems an older (at least < 4.15) bug.
> > >
> > > (Cc: Pavel)
> > >
> > > Bisection showed that the following commit introduced this issue:
> > >
> > >   commit f7f99100d8d95dbcf09e0216a143211e79418b9f
> > >   Author: Pavel Tatashin <pasha.tatashin@oracle.com>
> > >   Date:   Wed Nov 15 17:36:44 2017 -0800
> > >
> > >       mm: stop zeroing memory during allocation in vmemmap
> > >
> > > This patch postpones struct page zeroing to later stage of memory ini=
tialization.
> > > My kernel config disabled CONFIG_DEFERRED_STRUCT_PAGE_INIT so two cal=
lsites of
> > > __init_single_page() were never reached. So in such case, struct page=
s populated
> > > by vmemmap_pte_populate() could be left uninitialized?
> > > And I'm not sure yet how this issue becomes visible with memmap=3D se=
tting.
> >
> > I think that this becomes visible because memmap=3Dx!y creates a persis=
tent memory region:
> >
> > parse_memmap_one
> > {
> > 	...
> >         } else if (*p =3D=3D '!') {
> >                 start_at =3D memparse(p+1, &p);
> >                 e820__range_add(start_at, mem_size, E820_TYPE_PRAM);
> > 	...
> > }
> >
> > and this region it is not added neither in memblock.memory nor in membl=
ock.reserved.
> > Ranges in memblock.memory get zeroed in memmap_init_zone(), while membl=
ock.reserved get zeroed
> > in free_low_memory_core_early():
> >
> > static unsigned long __init free_low_memory_core_early(void)
> > {
> > 	...
> > 	for_each_reserved_mem_region(i, &start, &end)
> > 		reserve_bootmem_region(start, end);
> > 	...
> > }
> >
> >
> > Maybe I am mistaken, but I think that persistent memory regions should =
be marked as reserved.
> > A comment in do_mark_busy() suggests this:
> >
> > static bool __init do_mark_busy(enum e820_type type, struct resource *r=
es)
> > {
> >
> > 	...
> >         /*
> >          * Treat persistent memory like device memory, i.e. reserve it
> >          * for exclusive use of a driver
> >          */
> > 	...
> > }
> >
> >
> > I wonder if something like this could work and if so, if it is right (i=
 haven't tested it yet):
> >
> > diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> > index 71c11ad5643e..3c9686ef74e5 100644
> > --- a/arch/x86/kernel/e820.c
> > +++ b/arch/x86/kernel/e820.c
> > @@ -1247,6 +1247,11 @@ void __init e820__memblock_setup(void)
> >                 if (end !=3D (resource_size_t)end)
> >                         continue;
> >
> > +               if (entry->type =3D=3D E820_TYPE_PRAM || entry->type =
=3D=3D E820_TYPE_PMEM) {
> > +                       memblock_reserve(entry->addr, entry->size);
> > +                       continue;
> > +               }
> > +
> >                 if (entry->type !=3D E820_TYPE_RAM && entry->type !=3D =
E820_TYPE_RESERVED_KERN)
> >                         continue;
>
> It does not seem to work, so the reasoning might be incorrect.

Thank you for the comment.

One note is that the memory region with "broken struct page" is a typical
reserved region, not a pmem region. Strangely reading offset 0xbffd7 of
/proc/kpageflags is OK if pmem region does not exist, but NG if pmem region=
 exists.
Reading the offset like 0x100000 (on pmem region) does not cause the crash,
so pmem region seems properly set up.

[    0.000000] user-defined physical RAM map:
[    0.000000] user: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] user: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] user: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] user: [mem 0x0000000000100000-0x00000000bffd6fff] usable
[    0.000000] user: [mem 0x00000000bffd7000-0x00000000bfffffff] reserved  =
 =3D=3D=3D> "broken struct page" region
[    0.000000] user: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] user: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] user: [mem 0x0000000100000000-0x000000013fffffff] persistent=
 (type 12) =3D> pmem region
[    0.000000] user: [mem 0x0000000140000000-0x000000023fffffff] usable

Thanks,
Naoya Horiguchi=
