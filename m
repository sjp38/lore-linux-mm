Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B28866B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:28:19 -0400 (EDT)
Date: Thu, 29 Jul 2010 17:28:14 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
In-Reply-To: <20100729221426.GA28699@n2100.arm.linux.org.uk>
Message-ID: <alpine.DEB.2.00.1007291723310.21024@router.home>
References: <20100728155617.GA5401@barrios-desktop> <alpine.DEB.2.00.1007281158150.21717@router.home> <20100728225756.GA6108@barrios-desktop> <alpine.DEB.2.00.1007291038100.16510@router.home> <20100729161856.GA16420@barrios-desktop>
 <alpine.DEB.2.00.1007291132210.17734@router.home> <20100729170313.GB16420@barrios-desktop> <alpine.DEB.2.00.1007291222410.17734@router.home> <20100729183320.GH18923@n2100.arm.linux.org.uk> <1280436919.16922.11246.camel@nimitz>
 <20100729221426.GA28699@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jul 2010, Russell King - ARM Linux wrote:

> We don't map lowmem in using 4K pages.  That would be utter madness
> given the small TLB size ARM processors tend to have.  Instead, we
> map lowmem using 1MB section mappings (which occupy one entry in the
> L1 page table.)  Modifying these mappings requires all page tables
> in the system to be updated - which given that we're SMP etc. now
> is not practical.
>
> So the idea that we can remap a section of memory for the mem_map
> struct (as suggested several times in this thread) isn't possible
> without having it allocated in something like vmalloc space.
> Plus, of course, that if you did such a remapping in the lowmem
> mapping, the pages which were there become unusable as they lose
> their virtual mapping (thereby causing phys_to_virt/virt_to_phys
> on their addresses to break.)  Therefore, you only gain even more
> problems by this method.

A 1M page dedicated to vmemmap would only be used for memmap and only be
addressed using the virtual memory address. The pfn to page and vice versa
mapping that is the basic mechamism for virt_to_page and friends is then
straightforward. Nothing breaks.

memory-model.h:
#elif defined(CONFIG_SPARSEMEM_VMEMMAP)

/* memmap is virtually contiguous.  */
#define __pfn_to_page(pfn)      (vmemmap + (pfn))
#define __page_to_pfn(page)     (unsigned long)((page) - vmemmap)


However, if you have such a sparse address space you would not want 1M
blocks for memmap but rather 4k pages. So yes you would need to use
vmalloc space (or reserve another virtual range for that purpose).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
