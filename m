Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 728706B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 21:18:04 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j15-v6so636649pfi.10
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 18:18:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u13-v6si11223271plq.320.2018.07.24.18.18.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 18:18:03 -0700 (PDT)
Date: Tue, 24 Jul 2018 18:18:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: move mirrored memory specific code outside of
 memmap_init_zone
Message-Id: <20180724181800.3f25fdf8bcf0d8fd05ea1f43@linux-foundation.org>
In-Reply-To: <20180724235520.10200-4-pasha.tatashin@oracle.com>
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
	<20180724235520.10200-4-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Tue, 24 Jul 2018 19:55:20 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> memmap_init_zone, is getting complex, because it is called from different
> contexts: hotplug, and during boot, and also because it must handle some
> architecture quirks. One of them is mirroed memory.
> 
> Move the code that decides whether to skip mirrored memory outside of
> memmap_init_zone, into a separate function.

Conflicts a bit with the page_alloc.c hunk from
http://ozlabs.org/~akpm/mmots/broken-out/mm-page_alloc-remain-memblock_next_valid_pfn-on-arm-arm64.patch.  Please check my fixup:

void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
		unsigned long start_pfn, enum memmap_context context,
		struct vmem_altmap *altmap)
{
	unsigned long pfn, end_pfn = start_pfn + size;
	struct page *page;

	if (highest_memmap_pfn < end_pfn - 1)
		highest_memmap_pfn = end_pfn - 1;

	/*
	 * Honor reservation requested by the driver for this ZONE_DEVICE
	 * memory
	 */
	if (altmap && start_pfn == altmap->base_pfn)
		start_pfn += altmap->reserve;

	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
		/*
		 * There can be holes in boot-time mem_map[]s handed to this
		 * function.  They do not exist on hotplugged memory.
		 */
		if (context == MEMMAP_EARLY) {
			if (!early_pfn_valid(pfn)) {
				pfn = next_valid_pfn(pfn) - 1;
				continue;
			}
			if (!early_pfn_in_nid(pfn, nid))
				continue;
			if (overlap_memmap_init(zone, &pfn))
				continue;
			if (defer_init(nid, pfn, end_pfn))
				break;
		}

		page = pfn_to_page(pfn);
		__init_single_page(page, pfn, zone, nid);
		if (context == MEMMAP_HOTPLUG)
			SetPageReserved(page);

		/*
		 * Mark the block movable so that blocks are reserved for
		 * movable at startup. This will force kernel allocations
		 * to reserve their blocks rather than leaking throughout
		 * the address space during boot when many long-lived
		 * kernel allocations are made.
		 *
		 * bitmap is created for zone's valid pfn range. but memmap
		 * can be created for invalid pages (for alignment)
		 * check here not to call set_pageblock_migratetype() against
		 * pfn out of zone.
		 */
		if (!(pfn & (pageblock_nr_pages - 1))) {
			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
			cond_resched();
		}
	}
}
