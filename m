Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F20B6B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 08:21:44 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n6so1780882pfg.19
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 05:21:44 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id i188si8144550pgc.180.2018.01.19.05.21.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 05:21:42 -0800 (PST)
Date: Fri, 19 Jan 2018 14:21:33 +0100
From: Petr Tesarik <ptesarik@suse.com>
Subject: Re: [PATCH] Fix explanation of lower bits in the SPARSEMEM mem_map
 pointer
Message-ID: <20180119142133.379d5145@ezekiel.suse.cz>
In-Reply-To: <20180119123956.GZ6584@dhcp22.suse.cz>
References: <20180119080908.3a662e6f@ezekiel.suse.cz>
	<20180119123956.GZ6584@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>

On Fri, 19 Jan 2018 13:39:56 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 19-01-18 08:09:08, Petr Tesarik wrote:
> [...]
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 67f2e3c38939..7522a6987595 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -1166,8 +1166,16 @@ extern unsigned long usemap_size(void);
> >  
> >  /*
> >   * We use the lower bits of the mem_map pointer to store
> > - * a little bit of information.  There should be at least
> > - * 3 bits here due to 32-bit alignment.
> > + * a little bit of information.  The pointer is calculated
> > + * as mem_map - section_nr_to_pfn(pnum).  The result is
> > + * aligned to the minimum alignment of the two values:
> > + *   1. All mem_map arrays are page-aligned.
> > + *   2. section_nr_to_pfn() always clears PFN_SECTION_SHIFT
> > + *      lowest bits.  PFN_SECTION_SHIFT is arch-specific
> > + *      (equal SECTION_SIZE_BITS - PAGE_SHIFT), and the
> > + *      worst combination is powerpc with 256k pages,
> > + *      which results in PFN_SECTION_SHIFT equal 6.
> > + * To sum it up, at least 6 bits are available.
> >   */  
> 
> This is _much_ better indeed. Do you think we can go one step further
> and add BUG_ON into the sparse code to guarantee that every mmemap
> is indeed aligned properly so that SECTION_MAP_LAST_BIT-1 bits are never
> used?

This is easy for the section_nr_to_pfn() part. I'd just add:

  BUILD_BUG_ON(PFN_SECTION_SHIFT < SECTION_MAP_LAST_BIT);

But for the mem_map arrays... Do you mean adding a run-time BUG_ON into
all allocation paths?

Note that mem_map arrays can be allocated by:

  a) __earlyonly_bootmem_alloc
  b) memblock_virt_alloc_try_nid
  c) memblock_virt_alloc_try_nid_raw
  d) alloc_remap (only arch/tile still has it)

Some allocation paths are in mm/sparse.c, others are
mm/sparse-vmemmap.c, so it becomes a bit messy, but since it's
a single line in each, it may work.

Petr T

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
