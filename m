Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8A36B0012
	for <linux-mm@kvack.org>; Wed, 18 May 2011 15:35:08 -0400 (EDT)
Received: by pzk4 with SMTP id 4so1139645pzk.14
        for <linux-mm@kvack.org>; Wed, 18 May 2011 12:35:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110518154055.GA7037@dumpdata.com>
References: <BANLkTimo=yXTrgjQHn9746oNdj97Fb-Y9Q@mail.gmail.com>
	<20110518144129.GB4296@dumpdata.com>
	<BANLkTikxzEb7UkUfxmdHhHMc04P4bmKGXQ@mail.gmail.com>
	<20110518154055.GA7037@dumpdata.com>
Date: Wed, 18 May 2011 21:35:06 +0200
Message-ID: <BANLkTi=yXq_avxZPRrhfw55kadeZRH-aaw@mail.gmail.com>
Subject: Re: driver mmap implementation for memory allocated with pci_alloc_consistent()?
From: Leon Woestenberg <leon.woestenberg@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-pci@vger.kernel.org, linux-mm@kvack.org

Hello Konrad,

On Wed, May 18, 2011 at 5:40 PM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Wed, May 18, 2011 at 05:03:41PM +0200, Leon Woestenberg wrote:
>> On Wed, May 18, 2011 at 4:41 PM, Konrad Rzeszutek Wilk
>> <konrad.wilk@oracle.com> wrote:
>> > On Wed, May 18, 2011 at 03:02:30PM +0200, Leon Woestenberg wrote:
>> >>
>> >> memory allocated with pci_alloc_consistent() returns the (kernel)
>> >> virtual address and the bus address (which may be different from the
>> >> physical memory address).
>> >>
>> >> What is the correct implementation of the driver mmap (file operation
>> >> method) for such memory?
>> >
>>
>> I could not find PCI driver examples calling vm_insert_page() and I am
>> know I can trip into the different memory type pointers easily.
>
> ttm_bo_vm.c ?
> fb_defio.c ?
>
None of which use pci/dma_alloc_consistent().

Obviously, I have no complete understanding of the Linux memory
management subsystem, and the info on vm_insert_page() is rather
shallow in the case of pci_alloc_consistent().

http://lxr.linux.no/#linux+v2.6.38/mm/memory.c#L1789

1789        update_mmu_cache(vma, addr, pte); /* XXX: why not for
insert_page? */


I tried this:

static int buffer_mmap(struct file *file, struct vm_area_struct *vma)
{
        ...

	/* pages must not be cached as this would result in cache line sized
	accesses to the end point */
	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
	/* VM_RESERVED: prevent the pages from being swapped out */
	vma->vm_flags |= VM_RESERVED;
	vma->vm_private_data = file->private_data;

	/* vaddr is the (virtual) address returned by pci_alloc_consistent();
	 * vsize is the corresponding size */

	start = vma->vm_start;
	/* size is page-aligned */
	while (vsize > 0) {
		printk(KERN_DEBUG "vaddr = %p\n", lro_char->engine->ringbuffer_virt);
		printk(KERN_DEBUG "start = %p\n", start);
		struct page *page = virt_to_page(vaddr);
		printk(KERN_DEBUG "page = %p\n", page);
		printk(KERN_DEBUG "vm_insert_page(...0x%08lx)\n", (unsigned long)vaddr);
		/* insert the given page into vma, mapped at the given start address */
		err = vm_insert_page(vma, start, page);
		if (err) {
			printk(KERN_DEBUG "vm_insert_page()\n");
			return err;
		}
		start += PAGE_SIZE;
		vaddr += PAGE_SIZE;
		vsize -= PAGE_SIZE;
	}
	return 0;
}

which hard crashes my system.

Any ideas on a generic function that mmap() pci_alloc_consistent()
memory to user space?

Thanks,
-- 
Leon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
