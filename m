Date: Thu, 19 Oct 2006 09:39:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
In-Reply-To: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0610190932310.8072@schroedinger.engr.sgi.com>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Oct 2006, KAMEZAWA Hiroyuki wrote:

> For make patches simple, pfn_valid() uses sparsemem's logic. 

Hmm... pfn_valid is much less costly if you use ia64's scheme. You can 
simply probe without having to walk tables.

> This patch maps sparsemem's *sparse* memmap into contiguous virtual address range
> starting from virt_memmap_start.

Could you make that a static address instead of a variable? Also we 
already have vmem_map (ia64 specific) and mem_map. The logic here is the 
same as FLATMEM. Why not use the definitions for FLATMEM?
 
> * memmap is allocated per SECTION_SIZE, so there will be some of RESERVED pages.
> * no holes in MAX_ORDER range. so HOLE_IN_ZONE=n here.

Good. Had a patch here to do the same but I do not have time to get to 
it. Surely wish that this will become the default config and that we can 
get rid of at least some of the memory models.

> +#ifdef CONFIG_VMEMMAP_SPARSEMEM
> +extern struct page *virt_memmap_start;

extern struct page[] would be better performance wise. Use the definitions 
for FLATMEM?

> +		if (pte_none(*pte))
> +			set_pte(pte, pfn_pte(__pa(map) >> PAGE_SHIFT, PAGE_KERNEL));

Would it be possible to add support for larger page sizes? On x86_64 we 
probably would like to use 2MB pages and it may be good to have 
configurable page size on ia64.

The virtual memmap has the potential of becoming the default for x86_64 
and many other platforms that already map memory. There is no performance 
difference between FLATMEM and this virtual memmap approach if there are 
already mappings in play.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
