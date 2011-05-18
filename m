Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA566B0012
	for <linux-mm@kvack.org>; Wed, 18 May 2011 11:03:43 -0400 (EDT)
Received: by pzk4 with SMTP id 4so992422pzk.14
        for <linux-mm@kvack.org>; Wed, 18 May 2011 08:03:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110518144129.GB4296@dumpdata.com>
References: <BANLkTimo=yXTrgjQHn9746oNdj97Fb-Y9Q@mail.gmail.com>
	<20110518144129.GB4296@dumpdata.com>
Date: Wed, 18 May 2011 17:03:41 +0200
Message-ID: <BANLkTikxzEb7UkUfxmdHhHMc04P4bmKGXQ@mail.gmail.com>
Subject: Re: driver mmap implementation for memory allocated with pci_alloc_consistent()?
From: Leon Woestenberg <leon.woestenberg@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-pci@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-mm@kvack.org

Hello,

On Wed, May 18, 2011 at 4:41 PM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Wed, May 18, 2011 at 03:02:30PM +0200, Leon Woestenberg wrote:
>>
>> memory allocated with pci_alloc_consistent() returns the (kernel)
>> virtual address and the bus address (which may be different from the
>> physical memory address).
>>
>> What is the correct implementation of the driver mmap (file operation
>> method) for such memory?
>
> You are going to use the physical address from the CPU side. So not
> the bus address. Instead use the virtual address and find the
> physical address from that. page_to_pfn() does a good job.
>
pci_alloc_consistent() returns a kernel virtual address. To find the
page I think virt_to_page() suits me better, right?

#define virt_to_page(kaddr)     pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)

> Then you can call 'vm_insert_page(vma...)'
>
> Or 'vm_insert_mixed'

Thanks, that opens a whole new learning curve experience.

Can I call vmalloc_to_page() on memory allocated with
pci_alloc_consistent()? If so, then remap_vmalloc_range() looks
promising.

I could not find PCI driver examples calling vm_insert_page() and I am
know I can trip into the different memory type pointers easily.

How does your suggestion relate to using the vma ops fault() (formerly
known as nopage() to mmap memory allocated by pci_alloc_consistent()?
i.e. Such as suggested in
http://www.gossamer-threads.com/lists/linux/kernel/702127#702127

> Use 'cscope' on the Linux kernel.

Thanks for the suggestion. How would cscope help me find
vm_insert_page() given my question?

On hind-sight all questions seem to be easy once finding the correct
Documentation / source-code in the first place. I usually use
http://lxr.linux.no/ and friends.


Regards,
-- 
Leon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
