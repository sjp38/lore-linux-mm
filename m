Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C00526B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:38:47 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id k23so16720549qtc.14
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 09:38:47 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k42si2980651qtf.429.2017.11.27.09.38.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 09:38:46 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vARHYQtq052786
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:38:45 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2egnf8nw9p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:38:44 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Mon, 27 Nov 2017 17:38:42 -0000
Date: Mon, 27 Nov 2017 17:38:36 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/5] mm: memory_hotplug: memblock to track partially
 removed vmemmap mem
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <e17d447381b3f13d4d7d314916ca273b6f60d287.1511433386.git.ar@linux.vnet.ibm.com>
 <f21d2b81-e0f5-b186-22e3-ded138505dc9@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <f21d2b81-e0f5-b186-22e3-ded138505dc9@arm.com>
Message-Id: <20171127173835.GC12687@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com, realean2@ie.ibm.com, mhocko@suse.com, m.bielski@virtualopensystems.com, scott.branden@broadcom.com, catalin.marinas@arm.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arunks@qti.qualcomm.com, qiuxishi@huawei.com

Hi Robin,

On Mon 27 Nov 2017, 15:20, Robin Murphy wrote:
> On 23/11/17 11:14, Andrea Reale wrote:
> >When hot-removing memory we need to free vmemmap memory.
> 
> What problems arise if we don't? Is it only for the sake of freeing up some
> pages here and there, or is there something more fundamental?
>

It is just for freeing up pages, but imho we are talking about a relevant
number of pages. For example, assuming 4K pages, to describe one hot
added section of 1GB of new memory we need ~14MBs of vmemmap space (if
my back of the envelope math is not wrong). This
memory would be leaked if we do not do the cleanup in hot remove. 
If we do hot remove sections many times in the lifetime of a system, 
this quantity can become sizeable.

> >However, depending on the memory is being removed, it might
> >not be always possible to free a full vmemmap page / huge-page
> >because part of it might still be used.
> >
> >Commit ae9aae9eda2d ("memory-hotplug: common APIs to support page tables
> >hot-remove") introduced a workaround for x86
> >hot-remove, by which partially unused areas are filled with
> >the 0xFD constant. Full pages are only removed when fully
> >filled by 0xFDs.
> >
> >This commit introduces a MEMBLOCK_UNUSED_VMEMMAP memblock flag, with
> >the goal of using it in place of 0xFDs. For now, this will be used for
> >the arm64 port of memory hot remove, but the idea is to eventually use
> >the same mechanism for x86 as well.
> >
> >Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
> >Signed-off-by: Maciej Bielski <m.bielski@virtualopensystems.com>
> >---
> >  include/linux/memblock.h | 12 ++++++++++++
> >  mm/memblock.c            | 32 ++++++++++++++++++++++++++++++++
> >  2 files changed, 44 insertions(+)
> >
> >diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> >index bae11c7..0daec05 100644
> >--- a/include/linux/memblock.h
> >+++ b/include/linux/memblock.h
> >@@ -26,6 +26,9 @@ enum {
> >  	MEMBLOCK_HOTPLUG	= 0x1,	/* hotpluggable region */
> >  	MEMBLOCK_MIRROR		= 0x2,	/* mirrored region */
> >  	MEMBLOCK_NOMAP		= 0x4,	/* don't add to kernel direct mapping */
> >+#ifdef CONFIG_MEMORY_HOTREMOVE
> >+	MEMBLOCK_UNUSED_VMEMMAP	= 0x8,  /* Mark VMEMAP blocks as dirty */
> 
> I'm not sure I get what "dirty" is supposed to mean in this context. Also,
> this appears to be specific to CONFIG_SPARSEMEM_VMEMMAP, whilst only
> tangentially related to CONFIG_MEMORY_HOTREMOVE, so the dependencies look a
> bit off.
> 
> In fact, now that I think about it, why does this need to be in memblock at
> all? If it is specific to sparsemem, shouldn't the section map already be
> enough to tell us what's supposed to be present or not?
> 
> Robin.

The story is: when we are hot-removing one section, we cannot be sure that
the full block  can be fully removed, for example,
because we might have used only a portion of it at hot-add time and the
rest might have been used by other hot adds we are not aware of.
So when we hot-remove, we mark the page structs of the removed memory,
and we only remove the full page when it is all marked.
This is exactly symmetrical to the issue described in commit
ae9aae9eda2d ("memory-hotplug: common APIs to support page tables
hot-remove") - introducing hot-remove for x86. 

In that commit, partially unused vmemmap pages where filled with the
0XFD constant. In the previous iteration of this patchset, it was
rightfully suggested that marking the pages by writing inside them was
not the best way to achieve the result. That's why we reverted to do
this marking using memblock. This is only used in memory hot remove,
that's why the CONFIG_MEMORY_HOTREMOVE dependency. 

Right now, I cannot think of how I could use sparse mem to tell: the
only thing I know at the moment of trying to free a vmemmap block is that I
have some physical addresses that might or not be in use to describe some
pages. I canot think of any way to know which struct pages could be occupying this
vmemmap block, besides maybe walking all pagetables and check if I have
some matching mapping.
However, I might be missing something, so suggestions are welcome.

Thanks,
Andrea

> >+#endif
> >  };
> >  struct memblock_region {
> >@@ -90,6 +93,10 @@ int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
> >  int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
> >  int memblock_clear_nomap(phys_addr_t base, phys_addr_t size);
> >  ulong choose_memblock_flags(void);
> >+#ifdef CONFIG_MEMORY_HOTREMOVE
> >+int memblock_mark_unused_vmemmap(phys_addr_t base, phys_addr_t size);
> >+int memblock_clear_unused_vmemmap(phys_addr_t base, phys_addr_t size);
> >+#endif
> >  /* Low level functions */
> >  int memblock_add_range(struct memblock_type *type,
> >@@ -182,6 +189,11 @@ static inline bool memblock_is_nomap(struct memblock_region *m)
> >  	return m->flags & MEMBLOCK_NOMAP;
> >  }
> >+#ifdef CONFIG_MEMORY_HOTREMOVE
> >+bool memblock_is_vmemmap_unused_range(struct memblock_type *mt,
> >+		phys_addr_t start, phys_addr_t end);
> >+#endif
> >+
> >  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> >  int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
> >  			    unsigned long  *end_pfn);
> >diff --git a/mm/memblock.c b/mm/memblock.c
> >index 9120578..30d5aa4 100644
> >--- a/mm/memblock.c
> >+++ b/mm/memblock.c
> >@@ -809,6 +809,18 @@ int __init_memblock memblock_clear_nomap(phys_addr_t base, phys_addr_t size)
> >  	return memblock_setclr_flag(base, size, 0, MEMBLOCK_NOMAP);
> >  }
> >+#ifdef CONFIG_MEMORY_HOTREMOVE
> >+int __init_memblock memblock_mark_unused_vmemmap(phys_addr_t base,
> >+		phys_addr_t size)
> >+{
> >+	return memblock_setclr_flag(base, size, 1, MEMBLOCK_UNUSED_VMEMMAP);
> >+}
> >+int __init_memblock memblock_clear_unused_vmemmap(phys_addr_t base,
> >+		phys_addr_t size)
> >+{
> >+	return memblock_setclr_flag(base, size, 0, MEMBLOCK_UNUSED_VMEMMAP);
> >+}
> >+#endif
> >  /**
> >   * __next_reserved_mem_region - next function for for_each_reserved_region()
> >   * @idx: pointer to u64 loop variable
> >@@ -1696,6 +1708,26 @@ void __init_memblock memblock_trim_memory(phys_addr_t align)
> >  	}
> >  }
> >+#ifdef CONFIG_MEMORY_HOTREMOVE
> >+bool __init_memblock memblock_is_vmemmap_unused_range(struct memblock_type *mt,
> >+		phys_addr_t start, phys_addr_t end)
> >+{
> >+	u64 i;
> >+	struct memblock_region *r;
> >+
> >+	i = memblock_search(mt, start);
> >+	r = &(mt->regions[i]);
> >+	while (r->base < end) {
> >+		if (!(r->flags & MEMBLOCK_UNUSED_VMEMMAP))
> >+			return 0;
> >+
> >+		r = &(memblock.memory.regions[++i]);
> >+	}
> >+
> >+	return 1;
> >+}
> >+#endif
> >+
> >  void __init_memblock memblock_set_current_limit(phys_addr_t limit)
> >  {
> >  	memblock.current_limit = limit;
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
