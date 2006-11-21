Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id kALBcK4P113504
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 11:38:20 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kALBflVg3031184
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 12:41:47 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kALBcJet012277
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 12:38:20 +0100
Date: Tue, 21 Nov 2006 12:37:08 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
Message-ID: <20061121113708.GB8122@osiris.boeblingen.de.ibm.com>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-ia64@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 19, 2006 at 05:21:40PM +0900, KAMEZAWA Hiroyuki wrote:
> This is a patch for virtual memmap on sparsemem against 2.6.19-rc2.
> booted well on my Tiger4.
> 
> In this time, this is just a RFC. comments on patch and advises for benchmarking
> is welcome. (memory hotplug case is not well handled yet.)
> 
> ia64's SPARSEMEM uses SPARSEMEM_EXTREME. This requires 2-level table lookup by
> software for page_to_pfn()/pfn_to_page(). virtual memmap can remove that costs.
> But will consume more TLBs.
> 
> For make patches simple, pfn_valid() uses sparsemem's logic. 
> 
> - Kame
> ==
> This patch maps sparsemem's *sparse* memmap into contiguous virtual address range
> starting from virt_memmap_start.
> 
> By this, pfn_to_page, page_to_pfn can be implemented as 
> #define pfn_to_page(pfn)		(virt_memmap_start + (pfn))
> #define page_to_pfn(pg)			(pg - virt_memmap_start)
> 
> 
> Difference from ia64's VIRTUAL_MEMMAP are
> * pfn_valid() uses sparsemem's logic.
> * memmap is allocated per SECTION_SIZE, so there will be some of RESERVED pages.
> * no holes in MAX_ORDER range. so HOLE_IN_ZONE=n here.
> 
> Todo
> - fix vmalloc() case in memory hotadd. (maybe __get_vm_area() can be used.)

Better late than never, but here is a reply as well :)

Is this supposed to replace ia64's vmem_map?
I'm asking because on s390 we need a vmem_map too, but don't want to be
limited by the sparsemem restrictions (especially SECTION_SIZE that is).
In addition we have a shared memory device driver (dcss) with which it
is possible to attach some shared memory. Because of that it is
necessary to be able to add some additional struct pages on-the-fly.
This is not very different to memory hotplug; I think it's even easier,
since all we need are some initialized struct pages.

Currently I have a working prototype that does all that but still needs
a lot of cleanup and some error handling. It is (of course) heavily
inspired by ia64's vmem_map implementation.

I'd love to go for a generic implementation, but if that is based on
sparsemem it doesn't make too much sense on s390.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
