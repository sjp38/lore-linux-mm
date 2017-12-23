Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C8B09680CE3
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 00:33:20 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 3so10146583ioz.9
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 21:33:20 -0800 (PST)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id b63si1973723iod.5.2017.12.22.21.33.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 21:33:19 -0800 (PST)
Message-ID: <5A3DEA6A.9080709@huawei.com>
Date: Sat, 23 Dec 2017 13:32:26 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] does ioremap() cause memory leak?
References: <5A3B76EE.8020001@huawei.com>
In-Reply-To: <5A3B76EE.8020001@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Toshi Kani <toshi.kani@hp.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, lious.lilei@hisilicon.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LinuxArm <linuxarm@huawei.com>

On 2017/12/21 16:55, Xishi Qiu wrote:

> When we use iounmap() to free the mapping, it calls unmap_vmap_area() to clear page table,
> but do not free the memory of page table, right?
> 
> So when use ioremap() to mapping another area(incluce the area before), it may use
> large mapping(e.g. ioremap_pmd_enabled()), so the original page table memory(e.g. pte memory)
> will be lost, it cause memory leak, right?
> 
> Thanks,
> Xishi Qiu
> 
> 
> .
> 

Hi, here is another question from lious.lilei@hisilicon.com


As ARM-ARM said

?The architecture permits the caching of any translation table entry that has been returned from memory without a

fault, provided that the entry does not, itself, cause a Translation fault, an Address size fault, or an Access Flag fault.

This means that the entries that can be cached include:

? Entries in translation tables that point to subsequent tables to be used in that stage of translation.

? Stage 2 translation table entries used as part of a stage 1 translation table walk

? Stage 2 translation table entries used to translate the output address of the stage 1 translation.?

 

this means pgd, pud, pmd, pte all can be cached in TLB if itself have not a fault.

 

the scenario want page walk from:

4K:    pgd0 --> pud0 --> pmd0 --> pte0 (4K)

To

2M:   pgd0 --> pud0 --> pte1(2M)

 

--> is connect next pagetable

-X-> is disconnect next pagetable

 

I have seen the ioremap and iounmap software flow for ARM64 in Kernel version 4.14.

When I use ioremap to get a valid virtual address for a device address, Kernel would use ioremap_page_range to config the pagetable.

In ioremap_page_range function, if there is no pud, pmd or pte, Kernel would alloc one page for it. And then Kernel write the valid value into the address.

When I use iounmap to release this area, Kernel would write zero into the last level pagetable, then execute tlbi vaae1is to flush the tlb. But I haven`t seen Kernel would free the used page for pud, pmd or pte.

 

So there is a scene, I config Kernel to use 4K pagetable, and enable CONFIG_HAVE_ARCH_HUGE_VMAP. The when I use ioremap, Kernel would config 1G, 2M or 4K pagetable according to the size.

First I use ioremap to ask for 4K size. Kernel returns a virtual address VA1. Then I use iounmap to free this area. Kernel would write zero into the VA1`s level3 pagetable. Then when Kernel wants to get VA1 back, Kernel would send a tlbi vaae1is.

 

the page become follow:

1. 4K:   pgd0 --> pud0 --> pmd0 --> pte0 (4K)

2. pte0 write 0

3. 4K:   pgd0 --> pud0 --> pmd0(still valid) -X-> pte0 (4K,not valid)

4. tlbi vaae1is

 

Sencond I use ioremap to ask for 2M size. Kernel would config a 2M page, then return the virtual address. And Kernel just allocates the same virtual address VA1 for me. But I see in the ioremap_page_range software flow, Kernel just write the valid value into the level2 pagetable address, and doesn`t release the allocated page for the previous level3 pagetable. And when Kernel modifies the level2 pagetable, it also doesn`t follow the ARM break-before-make flow.

 

the page change as follow:

1.pgd0 --> pud0 --> pmd0(still valid) -X-> pte0 (4K,not valid)

2.write pmd0(still valid) to block for 2M.

3.expect pgd0 --> pud0 --> pte1(2M)

 

but because pmd0(4K pmd, still valid) before becoming to pte(2M pte), maybe have a speculative access between 1 and 3.

the pgd0, pud0, pmd0 have no fault will be cached in TBL, the pte0 have fault so can't be cached, this speculative access will be drop(no exception).

and the page change as:

1.pgd0 --> pud0 --> pmd0(still valid) -X-> pte0 (4K,not valid)

2.speculative access the same VA(pgd0 --> pud0 --> pmd0(still valid) -X-> pte0 (4K,not valid)). cache the pgd0, pud0, pmd0.

3.write pmd0 from pmd to block(pte) for 2M.

4.the page walker maybe pgd0 --> pud0 --> pmd0(cached in TLB) --> 0x0 (translation fault)

 

So I have two questions for this scene.

1. When the same virtual address allocated from ioremap, first is 4K size, second is 2M size, if Kernel would leak memory.

2. Kernel modifies the old invalid 4K pagetable to 2M, but doesn`t follow the ARM break-before-make flow, CPU maybe get the old invalid 4K pagetable information, then Kernel would panic.

 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
