Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 108AE6B0023
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:41:16 -0400 (EDT)
Date: Wed, 18 May 2011 11:40:56 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: driver mmap implementation for memory allocated with
 pci_alloc_consistent()?
Message-ID: <20110518154055.GA7037@dumpdata.com>
References: <BANLkTimo=yXTrgjQHn9746oNdj97Fb-Y9Q@mail.gmail.com>
 <20110518144129.GB4296@dumpdata.com>
 <BANLkTikxzEb7UkUfxmdHhHMc04P4bmKGXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTikxzEb7UkUfxmdHhHMc04P4bmKGXQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Woestenberg <leon.woestenberg@gmail.com>
Cc: linux-pci@vger.kernel.org, linux-mm@kvack.org

On Wed, May 18, 2011 at 05:03:41PM +0200, Leon Woestenberg wrote:
> Hello,
> 
> On Wed, May 18, 2011 at 4:41 PM, Konrad Rzeszutek Wilk
> <konrad.wilk@oracle.com> wrote:
> > On Wed, May 18, 2011 at 03:02:30PM +0200, Leon Woestenberg wrote:
> >>
> >> memory allocated with pci_alloc_consistent() returns the (kernel)
> >> virtual address and the bus address (which may be different from the
> >> physical memory address).
> >>
> >> What is the correct implementation of the driver mmap (file operation
> >> method) for such memory?
> >
> > You are going to use the physical address from the CPU side. So not
> > the bus address. Instead use the virtual address and find the
> > physical address from that. page_to_pfn() does a good job.
> >
> pci_alloc_consistent() returns a kernel virtual address. To find the
> page I think virt_to_page() suits me better, right?
> 
> #define virt_to_page(kaddr)     pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
> 
> > Then you can call 'vm_insert_page(vma...)'
> >
> > Or 'vm_insert_mixed'
> 
> Thanks, that opens a whole new learning curve experience.
> 
> Can I call vmalloc_to_page() on memory allocated with
> pci_alloc_consistent()? If so, then remap_vmalloc_range() looks
> promising.

No. That is b/c pci_alloc_consistent allocates pages from ..
well, this is a bit complex and varies on the platform. But _mostly_
if your device is 32-bit, it allocates it from ZONE_DMA32. Otherwise
it is from other zones. The 'vmalloc' pages are quite different and
are usually not exposed to the PCI devices, unless you do some extra
jumps (you need to kmap them).
> 
> I could not find PCI driver examples calling vm_insert_page() and I am
> know I can trip into the different memory type pointers easily.

ttm_bo_vm.c ?
fb_defio.c ?

> 
> How does your suggestion relate to using the vma ops fault() (formerly
> known as nopage() to mmap memory allocated by pci_alloc_consistent()?

You can use the pages that you had allocated via pci_alloc_consistent
and stitch them in the userspace vma.

> i.e. Such as suggested in
> http://www.gossamer-threads.com/lists/linux/kernel/702127#702127
> 
> > Use 'cscope' on the Linux kernel.
> 
> Thanks for the suggestion. How would cscope help me find
> vm_insert_page() given my question?

You can find examples of who uses it.
> 
> On hind-sight all questions seem to be easy once finding the correct
> Documentation / source-code in the first place. I usually use
> http://lxr.linux.no/ and friends.
> 
> 
> Regards,
> -- 
> Leon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
