Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8546B0005
	for <linux-mm@kvack.org>; Sat,  3 Feb 2018 07:24:41 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y44so13800644wry.8
        for <linux-mm@kvack.org>; Sat, 03 Feb 2018 04:24:41 -0800 (PST)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id g9si3602282wra.190.2018.02.03.04.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Feb 2018 04:24:38 -0800 (PST)
Date: Sat, 3 Feb 2018 13:24:22 +0100
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: Re: [PATCH v3 1/1] mm: page_alloc: skip over regions of invalid pfns
 on UMA
Message-ID: <20180203122422.GA11832@vmlxhi-102.adit-jv.com>
References: <20180124143545.31963-1-erosca@de.adit-jv.com>
 <20180124143545.31963-2-erosca@de.adit-jv.com>
 <20180129184746.GK21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180129184746.GK21609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eugeniu Rosca <erosca@de.adit-jv.com>

Hello Michal,

On Mon, Jan 29, 2018 at 07:47:46PM +0100, Michal Hocko wrote:
> On Wed 24-01-18 15:35:45, Eugeniu Rosca wrote:
> [...]
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 76c9688b6a0a..4a3d5936a9a0 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5344,14 +5344,12 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
> >  			goto not_early;
> >  
> >  		if (!early_pfn_valid(pfn)) {
> > -#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> >  			/*
> >  			 * Skip to the pfn preceding the next valid one (or
> >  			 * end_pfn), such that we hit a valid pfn (or end_pfn)
> >  			 * on our next iteration of the loop.
> >  			 */
> >  			pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
> > -#endif
> >  			continue;
> 
> Wouldn't it be just simpler to have ifdef CONFIG_HAVE_MEMBLOCK rather
> than define memblock_next_valid_pfn for !HAVE_MEMBLOCK and then do the
> (pfn + 1 ) - 1 games.

This sounds to me like you prefer the earlier v2 of this patch.

To my understanding, the difference between v2 and v3 is mainly
meaningful for architectures which don't define CONFIG_HAVE_MEMBLOCK.
One of them is ARCH=tile (for which kbuild test robot reported a compile
failure for v1 of my patch). Out of curiosity, I compiled
mm/page_alloc.o for ARCH=tile using [PATCH v2] and [PATCH v3], then
disassembled the objects using `objdump -D` and compared the results.

What I see is that the disassembled versions of memmap_init_zone()
fully match. To me, this means that the main difference between v2 and
v3 is about code readability. This is definitely an important aspect
too, but I must admit I don't have a very strong opinion here. I expect
this to be arbitrated by MM developers and eventually by the MM
gatekeepers/maintainers.

For the record, to achieve the same boot time improvement, the
alternatives on our side are:
- enable CONFIG_NUMA, just to benefit from the ~140ms speedup in boot
  time. Besides the increase of kernel image size, this also leads to
  annoying "Numa node 0:" noise in backtrace and stackdump output,
  which is not interesting for a non-NUMA system.
- ship the patch to our customers, in spite of not being accepted by MM
  community. This is a risky and unhealthy path, which we don't like.

That said, I really hope this won't be the last comment in the thread
and appropriate suggestions will come on how to go forward.

Thank you,
Eugeniu.

> I am usually against ifdefs in the code but that
> would require a larger surgery to memmap_init_zone.
> 
> To be completely honest, I would like to see HAVE_MEMBLOCK_NODE_MAP
> gone.
> 
> Other than that, the patch looks sane to me.
> 
> >  		}
> >  		if (!early_pfn_in_nid(pfn, nid))
> > -- 
> > 2.15.1
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
