Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4A2800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 15:25:46 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id e195so2426251wmd.9
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 12:25:46 -0800 (PST)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id n71si5662405wmi.28.2018.01.22.12.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 12:25:43 -0800 (PST)
Date: Mon, 22 Jan 2018 21:25:30 +0100
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: Re: [PATCH v2 1/1] mm: page_alloc: skip over regions of invalid pfns
 on UMA
Message-ID: <20180122202530.GA24724@vmlxhi-102.adit-jv.com>
References: <20180121144753.3109-1-erosca@de.adit-jv.com>
 <20180121144753.3109-2-erosca@de.adit-jv.com>
 <20180122012156.GA10428@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180122012156.GA10428@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Matthew and thanks for your feedback and review comments!

On Sun, Jan 21, 2018 at 05:21:56PM -0800, Matthew Wilcox wrote:
> 
> I like the patch.  I think it could be better.
> 
> > +++ b/mm/page_alloc.c
> > @@ -5344,7 +5344,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
> >  			goto not_early;
> >  
> >  		if (!early_pfn_valid(pfn)) {
> > -#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> > +#ifdef CONFIG_HAVE_MEMBLOCK
> >  			/*
> >  			 * Skip to the pfn preceding the next valid one (or
> >  			 * end_pfn), such that we hit a valid pfn (or end_pfn)
> 
> This ifdef makes me sad.  Here's more of the context:
> 
>                 if (!early_pfn_valid(pfn)) {
> #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>                         /*
>                          * Skip to the pfn preceding the next valid one (or
>                          * end_pfn), such that we hit a valid pfn (or end_pfn)
>                          * on our next iteration of the loop.
>                          */
>                         pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
> #endif
>                         continue;
>                 }
> 
> This is crying out for:
> 
> #ifdef CONFIG_HAVE_MEMBLOCK
> unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
> #else
> static inline unsigned long memblock_next_valid_pfn(unsigned long pfn,
> 		unsigned long max_pfn)
> {
> 	return pfn + 1;
> }
> #endif
> 
> in a header file somewhere.
> 

Here is what I came up with, based on your proposal:

---------------------------------------------------------

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 7ed0f7782d16..9efd592c5da4 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -187,7 +187,6 @@ int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
 			    unsigned long  *end_pfn);
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 			  unsigned long *out_end_pfn, int *out_nid);
-unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
 
 /**
  * for_each_mem_pfn_range - early memory pfn range iterator
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ea818ff739cd..b82b30522585 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2064,8 +2064,14 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn,
 
 #ifdef CONFIG_HAVE_MEMBLOCK
 void zero_resv_unavail(void);
+unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
 #else
 static inline void zero_resv_unavail(void) {}
+static inline unsigned long memblock_next_valid_pfn(unsigned long pfn,
+						    unsigned long max_pfn)
+{
+	return pfn + 1;
+}
 #endif
 
 extern void set_dma_reserve(unsigned long new_dma_reserve);
diff --git a/mm/memblock.c b/mm/memblock.c
index 46aacdfa4f4d..ad48cf200e3b 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1100,6 +1100,7 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
 	if (out_nid)
 		*out_nid = r->nid;
 }
+#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
 						      unsigned long max_pfn)
@@ -1129,6 +1130,7 @@ unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
 		return min(PHYS_PFN(type->regions[right].base), max_pfn);
 }
 
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 /**
  * memblock_set_node - set node ID on memblock regions
  * @base: base of area to set node ID for
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 76c9688b6a0a..4a3d5936a9a0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5344,14 +5344,12 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			goto not_early;
 
 		if (!early_pfn_valid(pfn)) {
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 			/*
 			 * Skip to the pfn preceding the next valid one (or
 			 * end_pfn), such that we hit a valid pfn (or end_pfn)
 			 * on our next iteration of the loop.
 			 */
 			pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
-#endif
 			continue;
 		}
 		if (!early_pfn_in_nid(pfn, nid))

---------------------------------------------------------

Here are the sanity checks and tests done (all on v4.15-rc9):
- compiled natively on x86_64
- cross-compiled for ARCH=arm64 (NUMA=y/n), ARCH=tile (for which kbuild
  test robot reported a build failure with [PATCH v1])
- no new issues reported by:
  - checkpatch --strict
  - make W=1
  - make CHECK="/path/to/smatch -p=kernel --two-passes --spammy" C=2 mm/
  - make C=2 CF="-D__CHECK_ENDIAN__"  -Wunused-function mm/
  - cppcheck --force --enable=all --inconclusive mm/
- re-tested on H3ULCB and confirmed the same behavior as with [PATCH v2]

If no other comments, I will submit [PATCH v3] in the next days.

Many thanks!

Best regards,
Eugeniu,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
