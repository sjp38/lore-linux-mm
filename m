Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3AE6B0087
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 04:56:59 -0500 (EST)
Date: Thu, 17 Dec 2009 09:56:41 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: CPU consumption is going as high as 95% on ARM Cortex A8
Message-ID: <20091217095641.GA399@n2100.arm.linux.org.uk>
References: <19F8576C6E063C45BE387C64729E73940449F43857@dbde02.ent.ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <19F8576C6E063C45BE387C64729E73940449F43857@dbde02.ent.ti.com>
Sender: owner-linux-mm@kvack.org
To: "Hiremath, Vaibhav" <hvaibhav@ti.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 11:08:31AM +0530, Hiremath, Vaibhav wrote:
> Issue/Usage :- 
> -------------
> The V4l2-Capture driver captures the data from video decoder into buffer
> and the application does some processing on this buffer. The mmap
> implementation can be found at drivers/media/video/videobuf-dma-contig.c,
> function__videobuf_mmap_mapper().

        vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);

will result in the memory being mapped as 'Strongly Ordered', resulting
in there being multiple mappings with differing types.  In later
kernels, we have pgprot_dmacoherent() and I'd suggest changing the above
macro for that.

> Without PAGE_READONLY/PAGE_SHARED
> 
> Important bits are [0-9] - 0x383
> 
> With PAGE_READONLY/PAGE_SHARED set
> 
> Important bits are [0-9] - 0x38F

So the difference is the C and B bits, which is more or less expected
with the change you've made.

> 
> The lines inside function "cpu_v7_set_pte_ext", is using the flag as shown below -
> 
>    tst     r1, #L_PTE_USER
>    orrne   r3, r3, #PTE_EXT_AP1
>    tstne   r3, #PTE_EXT_APX
>    bicne   r3, r3, #PTE_EXT_APX | PTE_EXT_AP0
> 
> Without PAGE_READONLY/PAGE_SHARED		With flags set
> 
> Access perm = reserved				Access Perm = Read Only

The bits you quote above are L_PTE_* bits, so you need to be careful
decoding them.  0x383 gives

	L_PTE_EXEC|L_PTE_USER|L_PTE_WRITE|L_PTE_YOUNG|L_PTE_PRESENT

which is as expected, and will be translated into: APX=0 AP1=1 AP0=0
which is user r/o, system r/w.  The same will be true of 0x38f.

> - I tried the same thing with another platform (ARM9) and it works fine there.
> 
> Can somebody help me to understand the flag PAGE_SHARED/PAGE_READONLY
> and access permissions? Am I debugging this into right path? Does
> anybody have seen/observed similar issue before?

I think you're just seeing the effects of 'strongly ordered' memory
rather than anything actually wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
