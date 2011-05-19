Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E933E6B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:11:00 -0400 (EDT)
Received: by pzk4 with SMTP id 4so1841370pzk.14
        for <linux-mm@kvack.org>; Thu, 19 May 2011 15:10:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DD53E2B.2090002@ladisch.de>
References: <BANLkTi==cinS1bZc_ARRbnYT3YD+FQr8gA@mail.gmail.com>
	<20110519145921.GE9854@dumpdata.com>
	<4DD53E2B.2090002@ladisch.de>
Date: Fri, 20 May 2011 00:10:57 +0200
Message-ID: <BANLkTinO1xR4XTN2B325pKCpJ3AjC9YidA@mail.gmail.com>
Subject: Re: mmap() implementation for pci_alloc_consistent() memory?
From: Leon Woestenberg <leon.woestenberg@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Clemens Ladisch <clemens@ladisch.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Clemens, Konrad, others,

On Thu, May 19, 2011 at 5:58 PM, Clemens Ladisch <clemens@ladisch.de> wrote=
:
> Konrad Rzeszutek Wilk wrote:
>> On Thu, May 19, 2011 at 12:14:40AM +0200, Leon Woestenberg wrote:
>> > I cannot get my driver's mmap() to work. I allocate 64 KiB ringbuffer
>> > using pci_alloc_consistent(), then implement mmap() to allow programs
>> > to map that memory into their user space.
>> > ...
>> > int ringbuffer_vma_fault(struct vm_area_struct *vma, struct vm_fault *=
vmf)
>> > {
>> > =A0 =A0 =A0 =A0 /* the buffer allocated with pci_alloc_consistent() */
>> > =A0 =A0 void *vaddr =3D ringbuffer_virt;
>> > =A0 =A0 int ret;
>> >
>> > =A0 =A0 /* find the struct page that describes vaddr, the buffer
>> > =A0 =A0 =A0* allocated with pci_alloc_consistent() */
>> > =A0 =A0 struct page *page =3D virt_to_page(lro_char->engine->ringbuffe=
r_virt);
>> > =A0 =A0 vmf->page =3D page;
>> >
>> > =A0 =A0 =A0 =A0 /*** I have verified that vaddr, page, and the pfn cor=
respond with vaddr =3D pci_alloc_consistent() ***/
>> > =A0 =A0 ret =3D vm_insert_pfn(vma, address, page_to_pfn(page));
>>
>> address is the vmf->virtual_address?
>>
yes, I missed that line when removing some noise:

	unsigned long address =3D (unsigned long)vmf->virtual_address;

>> And is the page_to_pfn(page) value correct? As in:
>>
>> =A0 int pfn =3D page_to_pfn(page);
>>
>> =A0 WARN(pfn << PAGE_SIZE !=3D vaddr,"Something fishy.");
>>
Yes, this holds true.

I also verified that the pfn corresponds with the pfn of the virtual
address returned by pci_alloc_consistent().

>> Hm, I think I might have misled you now that I look at that WARN.
>>
>> The pfn to be supplied has to be physical page frame number. Which in
>> this case should be your bus addr shifted by PAGE_SIZE. Duh! Try that
>> value.
>
The physical address? Why? (Just learning here, this is no objection
to your suggestion.)

Also, the bus address is not the physical address, or not in general.
For example on IOMMU systems this certainly doesn't hold true.

So how can I reliably find the out the physical memory address of
pci_alloc_consistent() memory?

> There are wildly different implementations of pci_alloc_consistent
> (actually dma_alloc_coherent) that can return somewhat different
> virtual and/or physical addresses.
>
>> I think a better example might be the 'hpet_mmap' code
>
> Which is x86 and ia64 only.
>
>> > static int ringbuffer_mmap(struct file *file, struct vm_area_struct *v=
ma)
>> > {
>> > =A0 =A0 vma->vm_page_prot =3D pgprot_noncached(vma->vm_page_prot);
>
> So is this an architecture without coherent caches?
>
My aim is to have an architecture independent driver.

My goal is to make sure the CPU can poll for data that the PCI(e) bus
master writes into host memory.

> Or would you want to use pgprot_dmacoherent, if available?
>
Hmm, let me check that.

> I recently looked into this problem, and ended up with the code below.
> I then decided that streaming DMA mappings might be a better idea.
>
I got streaming DMA mappings working already. I cannot use them in my
case as streaming mappings are not cache-coherent in general.

Thanks for the code snippet, it seems x86 only though?

Regards,
--=20
Leon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
