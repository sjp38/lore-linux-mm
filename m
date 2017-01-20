Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC2BB6B02E5
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 19:05:54 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 80so77096023pfy.2
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 16:05:54 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d21si4947924pgi.331.2017.01.19.16.05.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 16:05:53 -0800 (PST)
Date: Thu, 19 Jan 2017 16:05:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 06/12] mm: track active portions of a section at boot
Message-Id: <20170119160552.7bdc2e41f19bd52987a752bc@linux-foundation.org>
In-Reply-To: <148486363375.19694.14661926204436340901.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148486359570.19694.18265063120757801811.stgit@dwillia2-desk3.amr.corp.intel.com>
	<148486363375.19694.14661926204436340901.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>, linux-nvdimm@ml01.01.org, Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

On Thu, 19 Jan 2017 14:07:13 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> section active bitmask, each bit representing 2MB (SECTION_SIZE (128M) /
> map_active bitmask length (64)).
> 
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1083,6 +1083,8 @@ struct mem_section_usage {
>  	unsigned long pageblock_flags[0];
>  };
>  
> +void section_active_init(unsigned long pfn, unsigned long nr_pages);
> +
>  struct page;
>  struct page_ext;
>  struct mem_section {
> @@ -1224,6 +1226,7 @@ void sparse_init(void);
>  #else
>  #define sparse_init()	do {} while (0)
>  #define sparse_index_init(_sec, _nid)  do {} while (0)
> +#define section_active_init(_pfn, _nr_pages) do {} while (0)

Using a #define for this is crappy.  A static inline does typechecking
and can suppress unused-var warnings in callers.

>  #endif /* CONFIG_SPARSEMEM */
>  
>  /*
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 68ccf5bcdbb2..9a3ab6c245a8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6352,10 +6352,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>  
>  	/* Print out the early node map */
>  	pr_info("Early memory node ranges\n");
> -	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
> +	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
>  		pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
>  			(u64)start_pfn << PAGE_SHIFT,
>  			((u64)end_pfn << PAGE_SHIFT) - 1);
> +		section_active_init(start_pfn, end_pfn - start_pfn);

section_active_init() can be __init, methinks.  We don't want to carry
the extra .text after boot.

--- a/include/linux/mmzone.h~mm-track-active-portions-of-a-section-at-boot-fix
+++ a/include/linux/mmzone.h
@@ -1083,7 +1083,7 @@ struct mem_section_usage {
 	unsigned long pageblock_flags[0];
 };
 
-void section_active_init(unsigned long pfn, unsigned long nr_pages);
+void __init section_active_init(unsigned long pfn, unsigned long nr_pages);
 
 struct page;
 struct page_ext;
@@ -1226,6 +1226,10 @@ void sparse_init(void);
 #else
 #define sparse_init()	do {} while (0)
 #define sparse_index_init(_sec, _nid)  do {} while (0)
+static inline void section_active_init(unsigned long pfn,
+				       unsigned long nr_pages)
+{
+}
 #define section_active_init(_pfn, _nr_pages) do {} while (0)
 #endif /* CONFIG_SPARSEMEM */
 
--- a/mm/sparse.c~mm-track-active-portions-of-a-section-at-boot-fix
+++ a/mm/sparse.c
@@ -168,13 +168,13 @@ void __meminit mminit_validate_memmodel_
 	}
 }
 
-static int section_active_index(phys_addr_t phys)
+static int __init section_active_index(phys_addr_t phys)
 {
 	return (phys & ~(PA_SECTION_MASK)) / SECTION_ACTIVE_SIZE;
 }
 
-static unsigned long section_active_mask(unsigned long pfn,
-		unsigned long nr_pages)
+static unsigned long __init section_active_mask(unsigned long pfn,
+						unsigned long nr_pages)
 {
 	int idx_start, idx_size;
 	phys_addr_t start, size;
@@ -195,7 +195,7 @@ static unsigned long section_active_mask
 	return ((1UL << idx_size) - 1) << idx_start;
 }
 
-void section_active_init(unsigned long pfn, unsigned long nr_pages)
+void __init section_active_init(unsigned long pfn, unsigned long nr_pages)
 {
 	int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
 	int i, start_sec = pfn_to_section_nr(pfn);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
