Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BADD86B0003
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 01:43:44 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c62so3999152pfk.21
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 22:43:44 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id n66si4458397pfb.213.2018.02.10.22.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Feb 2018 22:43:43 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: The usage of page_mapping() in architecture code
Date: Sun, 11 Feb 2018 14:43:39 +0800
Message-ID: <87vaf4xbz8.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Dave Hansen <dave.hansen@intel.com>, Chen Liqin <liqin.linux@gmail.com>, Russell King <linux@armlinux.org.uk>, Yoshinori Sato <ysato@users.sourceforge.jp>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Vineet Gupta <vgupta@synopsys.com>, Ley Foon Tan <lftan@altera.com>, Ralf Baechle <ralf@linux-mips.org>, Andi Kleen <ak@linux.intel.com>
Cc: linux-mm@kvack.org

Hi, All,

To optimize the scalability of swap cache, it is made more dynamic
than before.  That is, after being swapped off, the address space of
the swap device will be freed too.  So the usage of page_mapping()
need to be audited to make sure the address space of the swap device
will not be used after it is freed.  For most cases it is OK, because
to call page_mapping(), the page, page table, or LRU list will be
locked.  But I found at least one usage isn't safe.  When
page_mapping() is called in architecture specific code to flush dcache
or sync between dcache and icache.

The typical usage models are,


1) Check whether page_mapping() is NULL, which is safe

2) Call mapping_mapped() to check whether the backing file is mapped
   to user space.

3) Iterate all vmas via the interval tree (mapping->i_mmap) to flush dcache


2) and 3) isn't safe, because no lock to prevent swap device from
swapping off is held.  But I found the code is for file address space
only, not for swap cache.  For example, for flush_dcache_page() in
arch/parisc/kernel/cache.c,


void flush_dcache_page(struct page *page)
{
	struct address_space *mapping = page_mapping(page);
	struct vm_area_struct *mpnt;
	unsigned long offset;
	unsigned long addr, old_addr = 0;
	pgoff_t pgoff;

	if (mapping && !mapping_mapped(mapping)) {
		set_bit(PG_dcache_dirty, &page->flags);
		return;
	}

	flush_kernel_dcache_page(page);

	if (!mapping)
		return;

	pgoff = page->index;

	/* We have carefully arranged in arch_get_unmapped_area() that
	 * *any* mappings of a file are always congruently mapped (whether
	 * declared as MAP_PRIVATE or MAP_SHARED), so we only need
	 * to flush one address here for them all to become coherent */

	flush_dcache_mmap_lock(mapping);
	vma_interval_tree_foreach(mpnt, &mapping->i_mmap, pgoff, pgoff) {
		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
		addr = mpnt->vm_start + offset;

		/* The TLB is the engine of coherence on parisc: The
		 * CPU is entitled to speculate any page with a TLB
		 * mapping, so here we kill the mapping then flush the
		 * page along a special flush only alias mapping.
		 * This guarantees that the page is no-longer in the
		 * cache for any process and nor may it be
		 * speculatively read in (until the user or kernel
		 * specifically accesses it, of course) */

		flush_tlb_page(mpnt, addr);
		if (old_addr == 0 || (old_addr & (SHM_COLOUR - 1))
				      != (addr & (SHM_COLOUR - 1))) {
			__flush_cache_page(mpnt, addr, page_to_phys(page));
			if (old_addr)
				printk(KERN_ERR "INEQUIVALENT ALIASES 0x%lx and 0x%lx in file %pD\n", old_addr, addr, mpnt->vm_file);
			old_addr = addr;
		}
	}
	flush_dcache_mmap_unlock(mapping);
}


if page is an anonymous page in swap cache, "mapping &&
!mapping_mapped()" will be true, so we will delay flushing.  But if my
understanding of the code were correct, we should call
flush_kernel_dcache() because the kernel may access the page during
swapping in/out.

The code in other architectures follow the similar logic.  Would it be
better for page_mapping() here to return NULL for anonymous pages even
if they are in swap cache?  Of course we need to change the function
name.  page_file_mapping() appears a good name, but that has been used
already.  Any suggestion?

Is my understanding correct?  Could you help me on this?

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
