Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8AA76B026D
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 06:50:02 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w95so10143637wrc.20
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 03:50:02 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j9si788542edf.166.2017.12.04.03.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 03:50:01 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vB4BnK6r022299
	for <linux-mm@kvack.org>; Mon, 4 Dec 2017 06:50:00 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2en46ww75q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 04 Dec 2017 06:49:21 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Mon, 4 Dec 2017 11:49:15 -0000
Date: Mon, 4 Dec 2017 11:49:09 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/5] mm: memory_hotplug: memblock to track partially
 removed vmemmap mem
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <e17d447381b3f13d4d7d314916ca273b6f60d287.1511433386.git.ar@linux.vnet.ibm.com>
 <20171130145134.el3qq7pr3q4xqglz@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171130145134.el3qq7pr3q4xqglz@dhcp22.suse.cz>
Message-Id: <20171204114908.GC6373@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, realean2@ie.ibm.com

On Thu 30 Nov 2017, 15:51, Michal Hocko wrote:
> On Thu 23-11-17 11:14:38, Andrea Reale wrote:
> > When hot-removing memory we need to free vmemmap memory.
> > However, depending on the memory is being removed, it might
> > not be always possible to free a full vmemmap page / huge-page
> > because part of it might still be used.
> > 
> > Commit ae9aae9eda2d ("memory-hotplug: common APIs to support page tables
> > hot-remove") introduced a workaround for x86
> > hot-remove, by which partially unused areas are filled with
> > the 0xFD constant. Full pages are only removed when fully
> > filled by 0xFDs.
> > 
> > This commit introduces a MEMBLOCK_UNUSED_VMEMMAP memblock flag, with
> > the goal of using it in place of 0xFDs. For now, this will be used for
> > the arm64 port of memory hot remove, but the idea is to eventually use
> > the same mechanism for x86 as well.
> 
> Why cannot you use the same approach as x86 have? Have a look at the
> vmemmap_free at al.
> 

This arm64 hot-remove version (including vmemmap_free) is indeed an
almost 1-to-1 port of the x86 approach. 

If you look at the first version of the patchset we submitted a while 
ago (https://lkml.org/lkml/2017/4/11/540), we were initially using the
x86 approach of filling unsued page structs with 0xFDs. Commenting on
that, Mark suggested (and, indeed, I agree with him) that relying on a
magic constant for marking some portions of physical memory was quite
ugly. That is why we have used memblock for the purpose in this revised
patchset.

If you have a different view and any concrete suggestion on how to
improve this, it is definitely very well welcome. 

> > Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
> > Signed-off-by: Maciej Bielski <m.bielski@virtualopensystems.com>
> > ---
> >  include/linux/memblock.h | 12 ++++++++++++
> >  mm/memblock.c            | 32 ++++++++++++++++++++++++++++++++
> >  2 files changed, 44 insertions(+)
> > 
> > diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> > index bae11c7..0daec05 100644
> > --- a/include/linux/memblock.h
> > +++ b/include/linux/memblock.h
> > @@ -26,6 +26,9 @@ enum {
> >  	MEMBLOCK_HOTPLUG	= 0x1,	/* hotpluggable region */
> >  	MEMBLOCK_MIRROR		= 0x2,	/* mirrored region */
> >  	MEMBLOCK_NOMAP		= 0x4,	/* don't add to kernel direct mapping */
> > +#ifdef CONFIG_MEMORY_HOTREMOVE
> > +	MEMBLOCK_UNUSED_VMEMMAP	= 0x8,  /* Mark VMEMAP blocks as dirty */
> > +#endif
> >  };
> >  
> >  struct memblock_region {
> > @@ -90,6 +93,10 @@ int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
> >  int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
> >  int memblock_clear_nomap(phys_addr_t base, phys_addr_t size);
> >  ulong choose_memblock_flags(void);
> > +#ifdef CONFIG_MEMORY_HOTREMOVE
> > +int memblock_mark_unused_vmemmap(phys_addr_t base, phys_addr_t size);
> > +int memblock_clear_unused_vmemmap(phys_addr_t base, phys_addr_t size);
> > +#endif
> >  
> >  /* Low level functions */
> >  int memblock_add_range(struct memblock_type *type,
> > @@ -182,6 +189,11 @@ static inline bool memblock_is_nomap(struct memblock_region *m)
> >  	return m->flags & MEMBLOCK_NOMAP;
> >  }
> >  
> > +#ifdef CONFIG_MEMORY_HOTREMOVE
> > +bool memblock_is_vmemmap_unused_range(struct memblock_type *mt,
> > +		phys_addr_t start, phys_addr_t end);
> > +#endif
> > +
> >  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> >  int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
> >  			    unsigned long  *end_pfn);
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 9120578..30d5aa4 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -809,6 +809,18 @@ int __init_memblock memblock_clear_nomap(phys_addr_t base, phys_addr_t size)
> >  	return memblock_setclr_flag(base, size, 0, MEMBLOCK_NOMAP);
> >  }
> >  
> > +#ifdef CONFIG_MEMORY_HOTREMOVE
> > +int __init_memblock memblock_mark_unused_vmemmap(phys_addr_t base,
> > +		phys_addr_t size)
> > +{
> > +	return memblock_setclr_flag(base, size, 1, MEMBLOCK_UNUSED_VMEMMAP);
> > +}
> > +int __init_memblock memblock_clear_unused_vmemmap(phys_addr_t base,
> > +		phys_addr_t size)
> > +{
> > +	return memblock_setclr_flag(base, size, 0, MEMBLOCK_UNUSED_VMEMMAP);
> > +}
> > +#endif
> >  /**
> >   * __next_reserved_mem_region - next function for for_each_reserved_region()
> >   * @idx: pointer to u64 loop variable
> > @@ -1696,6 +1708,26 @@ void __init_memblock memblock_trim_memory(phys_addr_t align)
> >  	}
> >  }
> >  
> > +#ifdef CONFIG_MEMORY_HOTREMOVE
> > +bool __init_memblock memblock_is_vmemmap_unused_range(struct memblock_type *mt,
> > +		phys_addr_t start, phys_addr_t end)
> > +{
> > +	u64 i;
> > +	struct memblock_region *r;
> > +
> > +	i = memblock_search(mt, start);
> > +	r = &(mt->regions[i]);
> > +	while (r->base < end) {
> > +		if (!(r->flags & MEMBLOCK_UNUSED_VMEMMAP))
> > +			return 0;
> > +
> > +		r = &(memblock.memory.regions[++i]);
> > +	}
> > +
> > +	return 1;
> > +}
> > +#endif
> > +
> >  void __init_memblock memblock_set_current_limit(phys_addr_t limit)
> >  {
> >  	memblock.current_limit = limit;
> > -- 
> > 2.7.4
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Thanks,
Andrea

> 
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
