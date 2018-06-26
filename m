Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id C93486B0005
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 02:14:27 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id q6-v6so3948554otf.20
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 23:14:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u48-v6sor290891otf.172.2018.06.25.23.14.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 23:14:26 -0700 (PDT)
MIME-Version: 1.0
References: <20180622210542.2025-1-malat@debian.org> <20180625171513.31845-1-malat@debian.org>
 <20180625180717.GS28965@dhcp22.suse.cz>
In-Reply-To: <20180625180717.GS28965@dhcp22.suse.cz>
From: Mathieu Malaterre <malat@debian.org>
Date: Tue, 26 Jun 2018 08:14:13 +0200
Message-ID: <CA+7wUsy5oxp2tYZA=9Nissj7Ztv6OHnLtdsQ9cHvvGX1KTDyew@mail.gmail.com>
Subject: Re: [PATCH v2] mm/memblock: add missing include <linux/bootmem.h>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Stefan Agner <stefan@agner.ch>, Joe Perches <joe@perches.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 25, 2018 at 8:07 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 25-06-18 19:15:12, Mathieu Malaterre wrote:
> > Commit 26f09e9b3a06 ("mm/memblock: add memblock memory allocation apis")
> > introduced two new function definitions:
> >
> >   memblock_virt_alloc_try_nid_nopanic()
> >   memblock_virt_alloc_try_nid()
> >
> > Commit ea1f5f3712af ("mm: define memblock_virt_alloc_try_nid_raw")
> > introduced the following function definition:
> >
> >   memblock_virt_alloc_try_nid_raw()
> >
> > This commit adds an include of header file <linux/bootmem.h> to provide
> > the missing function prototypes. Silence the following gcc warning
> > (W=1):
> >
> >   mm/memblock.c:1334:15: warning: no previous prototype for `memblock_virt_alloc_try_nid_raw' [-Wmissing-prototypes]
> >   mm/memblock.c:1371:15: warning: no previous prototype for `memblock_virt_alloc_try_nid_nopanic' [-Wmissing-prototypes]
> >   mm/memblock.c:1407:15: warning: no previous prototype for `memblock_virt_alloc_try_nid' [-Wmissing-prototypes]
> >
> > It also adds #ifdef blockers to prevent compilation failure on mips/ia64
> > where CONFIG_NO_BOOTMEM=n. Because Makefile already does:
> >
> >   obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
> >
> > The #ifdef has been simplified from:
> >
> >   #if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)
> >
> > to simply:
> >
> >   #if defined(CONFIG_NO_BOOTMEM)
>
> Well, I would apreciate an explanation why do we need NO_BOOTMEM guard
> in the first place rather than why HAVE_MEMBLOCK is not needed.

Right, I am missing the explicit reference to commit 6cc22dc08a247b
("revert "mm/memblock: add missing include <linux/bootmem.h>""), I can
tweak the commit message in a v3.

> > Suggested-by: Tony Luck <tony.luck@intel.com>
> > Suggested-by: Michal Hocko <mhocko@kernel.org>
> > Signed-off-by: Mathieu Malaterre <malat@debian.org>
>
> Anyway this looks better. I wish we can actually get rid of bootmem
> allocator which would simplify this as well but that is another topic.
>
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks !

> > ---
> > v2: Simplify #ifdef
> >
> >  mm/memblock.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 03d48d8835ba..611a970ac902 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -20,6 +20,7 @@
> >  #include <linux/kmemleak.h>
> >  #include <linux/seq_file.h>
> >  #include <linux/memblock.h>
> > +#include <linux/bootmem.h>
> >
> >  #include <asm/sections.h>
> >  #include <linux/io.h>
> > @@ -1224,6 +1225,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
> >       return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
> >  }
> >
> > +#if defined(CONFIG_NO_BOOTMEM)
> >  /**
> >   * memblock_virt_alloc_internal - allocate boot memory block
> >   * @size: size of memory block to be allocated in bytes
> > @@ -1431,6 +1433,7 @@ void * __init memblock_virt_alloc_try_nid(
> >             (u64)max_addr);
> >       return NULL;
> >  }
> > +#endif
> >
> >  /**
> >   * __memblock_free_early - free boot memory block
> > --
> > 2.11.0
> >
>
> --
> Michal Hocko
> SUSE Labs
