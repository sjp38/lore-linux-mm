Message-ID: <4517CB69.9030600@shadowen.org>
Date: Mon, 25 Sep 2006 13:28:25 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: virtual mmap basics
References: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Lets say we have memory of MAX_PFN pages.
> 
> Then we need a page struct array with MAX_PFN page structs to manage
> that memory called mem_map.
> 
> For mmap processing without virtualization (FLATMEM) (simplified)
> we have:
> 
> #define pfn_valid(pfn)		(pfn < max_pfn)
> #define pfn_to_page(pfn)	&mem_map[pfn]
> #define page_to_pfn(page)     	(page - mem_map))
> 
> which is then used to build the commonly used functions:
> 
> #define virt_to_page(kaddr)     pfn_to_page(kaddr >> PAGE_SHIFT)
> #define page_address(page)	(page_to_pfn(page) << PAGE_SHIFT)
> 
> Virtual Memmory Map
> -------------------
> 
> For a virtual memory map we reserve a virtual memory area
> VMEMMAP_START ... VMEMMAP_START + max_pfn * sizeof(page_struct))
> vmem_map is defined to be a pointer to struct page. It is a constant
> pointing to VMEMMAP_START. 
> 
> We use page tables to manage the virtual memory map. Page tables
> may be sparse. Pages in the area used for page structs may be missing.
> Software may dynamically add new page table entries to make new
> ranges of pfn's valid. Its like sparse.
> 
> The basic functions then become:
> 
> #define pfn_valid(pfn)		(pfn < max_pfn && valid_page_table_entry(pfn))
> #define pfn_to_page(pfn)	&vmem_map[pfn]
> #define page_to_pfn(page)     	(page - vmem_map))
> 
> We only loose (apart from additional TLB use if this memory was not 
> already using page tables) on pfn_valid when we have to traverse the page 
> table via valid_page_table_entry() if the processor does not have an 
> instruction to check that condition. We could avoid the page table 
> traversal by having the page fault handler deal with it somehow. But then 
> pfn_valid is not that frequent an operation.

pfn_valid is most commonly required on virtual mem_map setups as its
implementation (currently) violates the 'contiguious and present' out to
MAX_ORDER constraint that the buddy expects.  So we have additional
frequent checks on pfn_valid in the allocator to check for it when there
are holes within zones (which is virtual memmaps in all but name).

We also need to consider the size of the mem_map.  The reason we have a
problem with smaller machines is that virtual space in zone NORMAL is
limited.  The mem_map here has to be contigious and spase in KVA, this
is exactly the resource we are short of.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
