Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C713B800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 07:43:56 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id q2so2339482wrg.5
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 04:43:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a11si109118wmh.277.2018.01.24.04.43.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Jan 2018 04:43:55 -0800 (PST)
Date: Wed, 24 Jan 2018 13:43:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Fix explanation of lower bits in the SPARSEMEM mem_map
 pointer
Message-ID: <20180124124353.GE28465@dhcp22.suse.cz>
References: <20180119080908.3a662e6f@ezekiel.suse.cz>
 <20180119123956.GZ6584@dhcp22.suse.cz>
 <20180119142133.379d5145@ezekiel.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180119142133.379d5145@ezekiel.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Tesarik <ptesarik@suse.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>

On Fri 19-01-18 14:21:33, Petr Tesarik wrote:
> On Fri, 19 Jan 2018 13:39:56 +0100
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Fri 19-01-18 08:09:08, Petr Tesarik wrote:
> > [...]
> > > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > > index 67f2e3c38939..7522a6987595 100644
> > > --- a/include/linux/mmzone.h
> > > +++ b/include/linux/mmzone.h
> > > @@ -1166,8 +1166,16 @@ extern unsigned long usemap_size(void);
> > >  
> > >  /*
> > >   * We use the lower bits of the mem_map pointer to store
> > > - * a little bit of information.  There should be at least
> > > - * 3 bits here due to 32-bit alignment.
> > > + * a little bit of information.  The pointer is calculated
> > > + * as mem_map - section_nr_to_pfn(pnum).  The result is
> > > + * aligned to the minimum alignment of the two values:
> > > + *   1. All mem_map arrays are page-aligned.
> > > + *   2. section_nr_to_pfn() always clears PFN_SECTION_SHIFT
> > > + *      lowest bits.  PFN_SECTION_SHIFT is arch-specific
> > > + *      (equal SECTION_SIZE_BITS - PAGE_SHIFT), and the
> > > + *      worst combination is powerpc with 256k pages,
> > > + *      which results in PFN_SECTION_SHIFT equal 6.
> > > + * To sum it up, at least 6 bits are available.
> > >   */  
> > 
> > This is _much_ better indeed. Do you think we can go one step further
> > and add BUG_ON into the sparse code to guarantee that every mmemap
> > is indeed aligned properly so that SECTION_MAP_LAST_BIT-1 bits are never
> > used?
> 
> This is easy for the section_nr_to_pfn() part. I'd just add:
> 
>   BUILD_BUG_ON(PFN_SECTION_SHIFT < SECTION_MAP_LAST_BIT);
> 
> But for the mem_map arrays... Do you mean adding a run-time BUG_ON into
> all allocation paths?
> 
> Note that mem_map arrays can be allocated by:
> 
>   a) __earlyonly_bootmem_alloc
>   b) memblock_virt_alloc_try_nid
>   c) memblock_virt_alloc_try_nid_raw
>   d) alloc_remap (only arch/tile still has it)
> 
> Some allocation paths are in mm/sparse.c, others are
> mm/sparse-vmemmap.c, so it becomes a bit messy, but since it's
> a single line in each, it may work.

Yeah, it is a mess. So I will leave it up to you. I do not want to block
your comment update which is a nice improvement. So with or without the
runtime check feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
