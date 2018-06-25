Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB856B026F
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 10:26:39 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id h3-v6so9580130otj.15
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 07:26:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y187-v6sor5720960oiy.38.2018.06.25.07.26.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 07:26:38 -0700 (PDT)
MIME-Version: 1.0
References: <20180622210542.2025-1-malat@debian.org> <20180625140346.GM28965@dhcp22.suse.cz>
In-Reply-To: <20180625140346.GM28965@dhcp22.suse.cz>
From: Mathieu Malaterre <malat@debian.org>
Date: Mon, 25 Jun 2018 16:26:24 +0200
Message-ID: <CA+7wUsx3CzFP_NBL2ecW6ciFSjGGPnYo3L0NUe40aqUKd2ysiw@mail.gmail.com>
Subject: Re: [PATCH] mm/memblock: add missing include <linux/bootmem.h> and #ifdef
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Stefan Agner <stefan@agner.ch>, Joe Perches <joe@perches.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 25, 2018 at 4:03 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 22-06-18 23:05:41, Mathieu Malaterre wrote:
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
> > As seen in commit 6cc22dc08a24 ("revert "mm/memblock: add missing include
> > <linux/bootmem.h>"") #ifdef blockers were missing which lead to compilation
> > failure on mips/ia64 where CONFIG_NO_BOOTMEM=n.
> >
> > Suggested-by: Tony Luck <tony.luck@intel.com>
> > Signed-off-by: Mathieu Malaterre <malat@debian.org>
>
> I was not aware of -Wmissing-prototypes

(not tested) sparse would report something like:

symbol 'memblock_virt_alloc_try_nid_raw' was not declared. Should it be static?

> > ---
> >  mm/memblock.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 4c98672bc3e2..f4b6766d7907 100644
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
> > @@ -1226,6 +1227,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
> >       return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
> >  }
> >
> > +#if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)
>
> Why do you need CONFIG_HAVE_MEMBLOCK dependency?
> mm/Makefile says
> obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
>
> so we even do not compile this code for !HAVE_MEMBLOCK AFAICS.

Right, that can be simplified. I took it directly from Tony. I
originally found it more readable since it matched sentinels used for
the prototypes in <linux/bootmem.h>

$ grep -B 7 memblock_virt_alloc_try_nid_raw include/linux/bootmem.h | head -1
#if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)

I'll send a v2 shortly.

> >  /**
> >   * memblock_virt_alloc_internal - allocate boot memory block
> >   * @size: size of memory block to be allocated in bytes
> > @@ -1433,6 +1435,7 @@ void * __init memblock_virt_alloc_try_nid(
> >             (u64)max_addr);
> >       return NULL;
> >  }
> > +#endif
> >
> >  /**
> >   * __memblock_free_early - free boot memory block
> > --
> > 2.11.0
>
> --
> Michal Hocko
> SUSE Labs
