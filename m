Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 297DF6B0565
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 13:47:12 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g71so16622151wmg.13
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 10:47:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si12822004wrp.425.2017.07.28.10.47.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 10:47:10 -0700 (PDT)
Date: Fri, 28 Jul 2017 19:47:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/5] mm, memory_hotplug: allocate memmap from the
 added memory range for sparse-vmemmap
Message-ID: <20170728174705.GA18993@dhcp22.suse.cz>
References: <20170726083333.17754-1-mhocko@kernel.org>
 <20170726083333.17754-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726083333.17754-4-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dan Williams <dan.j.williams@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>

On Wed 26-07-17 10:33:31, Michal Hocko wrote:
[...]
> @@ -312,7 +324,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>  	}
>  
>  	for (i = start_sec; i <= end_sec; i++) {
> -		err = __add_section(nid, section_nr_to_pfn(i), want_memblock);
> +		err = __add_section(nid, section_nr_to_pfn(i), want_memblock, altmap);
>  
>  		/*
>  		 * EEXIST is finally dealt with by ioresource collision
[...]
> diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> index 483ba270d522..42d6721cfb71 100644
> --- a/mm/sparse-vmemmap.c
> +++ b/mm/sparse-vmemmap.c
> @@ -794,8 +798,20 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat, unsigned long st
>  		goto out;
>  	}
>  
> +	/*
> +	 * TODO get rid of this somehow - we want to postpone the full
> +	 * initialization until memmap_init_zone.
> +	 */
>  	memset(memmap, 0, sizeof(struct page) * PAGES_PER_SECTION);
>  
> +	/*
> +	 * now that we have a valid vmemmap mapping we can use
> +	 * pfn_to_page and flush struct pages which back the
> +	 * memmap
> +	 */
> +	if (altmap && altmap->flush_alloc_pfns)
> +		altmap->flush_alloc_pfns(altmap);
> +
>  	section_mark_present(ms);
>  
>  	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);

I have only now realized that flush_alloc_pfns would go over the same
range of pfns for each section again and again. I haven't noticed that
because my memblock has one section but larger memblocks (2GB on x86
with a lot of memory) would see that issue. So I will fold the following
into the patch.
---
commit 2658f448af25aa2d2ff7fea12e60a8fe78966f9b
Author: Michal Hocko <mhocko@suse.com>
Date:   Fri Jul 28 19:45:25 2017 +0200

    fold me "mm, memory_hotplug: allocate memmap from the added memory range for sparse-vmemmap"
    
    - rewind base pfn of the vmem_altmap when flushing one section
      (mark_vmemmap_pages) because we do not want to flush the same range
      all over again when memblock has more than one section

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 7aec9272fe4d..55f82c652d51 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -18,7 +18,7 @@ struct device;
  *  is mapped to the vmemmap - see mark_vmemmap_pages
  */
 struct vmem_altmap {
-	const unsigned long base_pfn;
+	unsigned long base_pfn;
 	const unsigned long reserve;
 	unsigned long free;
 	unsigned long align;
@@ -48,6 +48,9 @@ static inline void mark_vmemmap_pages(struct vmem_altmap *self)
 		struct page *page = pfn_to_page(pfn);
 		__SetPageVmemmap(page);
 	}
+
+	self->alloc = 0;
+	self->base_pfn += nr_pages + self->reserve;
 }
 /**
  * struct dev_pagemap - metadata for ZONE_DEVICE mappings
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
