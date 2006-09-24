Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k8OGxInx020594
	for <linux-mm@kvack.org>; Sun, 24 Sep 2006 11:59:18 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k8OGthDu55880789
	for <linux-mm@kvack.org>; Sun, 24 Sep 2006 09:55:43 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k8OGxHnB58336414
	for <linux-mm@kvack.org>; Sun, 24 Sep 2006 09:59:17 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1GRXK1-0004kF-00
	for <linux-mm@kvack.org>; Sun, 24 Sep 2006 09:59:17 -0700
Date: Sun, 24 Sep 2006 09:59:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: virtual mmap basics
Message-ID: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Lets say we have memory of MAX_PFN pages.

Then we need a page struct array with MAX_PFN page structs to manage
that memory called mem_map.

For mmap processing without virtualization (FLATMEM) (simplified)
we have:

#define pfn_valid(pfn)		(pfn < max_pfn)
#define pfn_to_page(pfn)	&mem_map[pfn]
#define page_to_pfn(page)     	(page - mem_map))

which is then used to build the commonly used functions:

#define virt_to_page(kaddr)     pfn_to_page(kaddr >> PAGE_SHIFT)
#define page_address(page)	(page_to_pfn(page) << PAGE_SHIFT)

Virtual Memmory Map
-------------------

For a virtual memory map we reserve a virtual memory area
VMEMMAP_START ... VMEMMAP_START + max_pfn * sizeof(page_struct))
vmem_map is defined to be a pointer to struct page. It is a constant
pointing to VMEMMAP_START. 

We use page tables to manage the virtual memory map. Page tables
may be sparse. Pages in the area used for page structs may be missing.
Software may dynamically add new page table entries to make new
ranges of pfn's valid. Its like sparse.

The basic functions then become:

#define pfn_valid(pfn)		(pfn < max_pfn && valid_page_table_entry(pfn))
#define pfn_to_page(pfn)	&vmem_map[pfn]
#define page_to_pfn(page)     	(page - vmem_map))

We only loose (apart from additional TLB use if this memory was not 
already using page tables) on pfn_valid when we have to traverse the page 
table via valid_page_table_entry() if the processor does not have an 
instruction to check that condition. We could avoid the page table 
traversal by having the page fault handler deal with it somehow. But then 
pfn_valid is not that frequent an operation.

virt_to_page and page_to_virt remain unchanged.

Sparse
------

Sparse currently does troublesome lookups for virt_to_page
and page_address.

#define page_to_pfn(pg) (pg - 
	section_mem_map_addr(nr_to_section(page_to_section(pg)))

#define pfn_to_page(pfn)
	 section_mem_map_addr(pfn_to_section(pfn)) + __pfn;

page_to_section is an extraction of flags from page->flags.

static inline struct mem_section *nr_to_section(unsigned long nr)
{
        if (!mem_section[SECTION_NR_TO_ROOT(nr)])
                return NULL;
        return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
}

static inline struct page *section_mem_map_addr(struct mem_section 
*section)
{
        unsigned long map = section->section_mem_map;
        map &= SECTION_MAP_MASK;
        return (struct page *)map;
}

So we have a mininum of a couple of table lookups and one page->flags 
retrieval (okay that may be argued to be in cache) in virt_to_page versus 
*none* in the virtual memory map case. Similar troublesome code is
there fore the reverse case.

pfn_valid requires at least 3 lookups. Which may be equivalent
to walking to page table over 3 levels if the processor has no command to 
make the hardware do it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
