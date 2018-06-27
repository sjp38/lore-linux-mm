Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E46426B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 06:05:23 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id i14-v6so990875wrq.1
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 03:05:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i193-v6si3629464wmf.175.2018.06.27.03.05.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 03:05:22 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5R9xJ2h063814
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 06:05:20 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jv8dhgcfe-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 06:05:20 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 27 Jun 2018 11:05:17 +0100
Date: Wed, 27 Jun 2018 13:05:08 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] mm/memblock: add missing include <linux/bootmem.h>
References: <20180622210542.2025-1-malat@debian.org>
 <20180625171513.31845-1-malat@debian.org>
 <20180625180717.GS28965@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180625180717.GS28965@dhcp22.suse.cz>
Message-Id: <20180627100508.GB4291@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mathieu Malaterre <malat@debian.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Stefan Agner <stefan@agner.ch>, Joe Perches <joe@perches.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 25, 2018 at 08:07:17PM +0200, Michal Hocko wrote:
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
> 
> > Suggested-by: Tony Luck <tony.luck@intel.com>
> > Suggested-by: Michal Hocko <mhocko@kernel.org>
> > Signed-off-by: Mathieu Malaterre <malat@debian.org>
> 
> Anyway this looks better. I wish we can actually get rid of bootmem
> allocator which would simplify this as well but that is another topic.

There only 5 arches with bootmem left :)

I've started looking into it, but it goes slow :(
 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
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
> >  	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
> >  }
> >  
> > +#if defined(CONFIG_NO_BOOTMEM)
> >  /**
> >   * memblock_virt_alloc_internal - allocate boot memory block
> >   * @size: size of memory block to be allocated in bytes
> > @@ -1431,6 +1433,7 @@ void * __init memblock_virt_alloc_try_nid(
> >  	      (u64)max_addr);
> >  	return NULL;
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
> 

-- 
Sincerely yours,
Mike.
