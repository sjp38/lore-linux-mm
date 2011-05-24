Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C13BC8D003B
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:18:16 -0400 (EDT)
Received: by bwz17 with SMTP id 17so8410706bwz.14
        for <linux-mm@kvack.org>; Tue, 24 May 2011 07:18:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DDA1B18.3080201@ladisch.de>
References: <BANLkTi==cinS1bZc_ARRbnYT3YD+FQr8gA@mail.gmail.com>
	<20110519145921.GE9854@dumpdata.com>
	<4DD53E2B.2090002@ladisch.de>
	<BANLkTinO1xR4XTN2B325pKCpJ3AjC9YidA@mail.gmail.com>
	<4DD60F57.8030000@ladisch.de>
	<s5htycp6b25.wl%tiwai@suse.de>
	<BANLkTi=P6WP-+BiqEwCRTxaNTqNHT988wA@mail.gmail.com>
	<4DDA1B18.3080201@ladisch.de>
Date: Tue, 24 May 2011 16:18:11 +0200
Message-ID: <BANLkTikOEssVJ6mXOUxt=BUFX6ERqxMWwg@mail.gmail.com>
Subject: Re: mmap() implementation for pci_alloc_consistent() memory?
From: Leon Woestenberg <leon.woestenberg@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Clemens Ladisch <clemens@ladisch.de>
Cc: Takashi Iwai <tiwai@suse.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Clemens,

On Mon, May 23, 2011 at 10:30 AM, Clemens Ladisch <clemens@ladisch.de> wrote:
> Leon Woestenberg wrote:
>> Having dma_mmap_coherent() there is good for one or two archs, but how
>> can we built portable drivers if the others arch's are still missing?
>
> Easy: Resolve all issues, implement it for all the other arches, and add
> it to the official DMA API.
>
>> How would dma_mmap_coherent() look like on x86?
>
> X86 and some others are always coherent; just use vm_insert_page() or
> remap_page_range().
>
Hello Clemens,

On Mon, May 23, 2011 at 10:30 AM, Clemens Ladisch <clemens@ladisch.de> wrote:
> Leon Woestenberg wrote:
>> Having dma_mmap_coherent() there is good for one or two archs, but how
>> can we built portable drivers if the others arch's are still missing?
>
> Easy: Resolve all issues, implement it for all the other arches, and add
> it to the official DMA API.
>
I could send patches, but I would get bashed. Would be a learning
experience though (and a long email thread).

>> How would dma_mmap_coherent() look like on x86?
>
> X86 and some others are always coherent; just use vm_insert_page() or
> remap_page_range().
>

For x86 (my current test system) I tend to go with remap_page_range()
so that the mapping is done before the pages are actually touched.

With that I leave the work-in-progress (dma_mmap_coherent) aside for a
moment, I'll revisit that later on ARM.

However, I still feel I'm treading sandy waters, not familiar enough
with the VM internals.

Does memory allocated with pci_alloc_consistent() need a get_page() in
the driver before I  remap_page_range() it?
Does memory allocated with __get_free_pages() need a get_page() in the
driver before I  remap_page_range() it?

And how about set_bit(PG_reserved, ...) on those pages? Is that
something of the past?

#if 0
...
<vm_insert_page implementation here, disabled>
...
#else /* remap_pfn_range */
#warning Using remap_pfn_range
static int buffer_mmap(struct file *file, struct vm_area_struct *vma)
{
        unsigned long vsize, vsize2;
        void *vaddr, *vaddr2;
        unsigned long start = vma->vm_start;

         * VM_RESERVED: prevent the pages from being swapped out */
        vma->vm_flags |= VM_RESERVED;
        vma->vm_private_data = file->private_data;

        /* allocated using __get_free_pages() or pci_alloc_consistent() */
        vaddr = buffer_virt;
        vsize = buffer_size;

        /* iterate over pages */
        vaddr2 = vaddr;
        vsize2 = vsize;
        while (vsize2 > 0) {
                printk(KERN_DEBUG "get_page(page=%p)\n", virt_to_page(vaddr2));
                get_page(virt_to_page(vaddr2));
                //set_bit(PG_reserved, &(virt_to_page(vaddr2)->flags));
                vaddr2 += PAGE_SIZE;
                vsize2 -= PAGE_SIZE;
        }
        remap_pfn_range(vma, vma->vm_start,
page_to_pfn(virt_to_page(vaddr)), vsize, vma->vm_page_prot);
        return 0;
}
#endif



Thanks for the explanation,

Regards,
-- 
Leon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
