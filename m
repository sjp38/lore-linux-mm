Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id BE4F56B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 01:53:06 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so50989768pab.7
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 22:53:06 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id oz9si2907252pdb.15.2015.01.20.22.53.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 20 Jan 2015 22:53:04 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NII0050ULZ6T070@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jan 2015 06:57:06 +0000 (GMT)
Date: Wed, 21 Jan 2015 09:52:57 +0300
From: Sergey Dyasly <s.dyasly@samsung.com>
Subject: Re: [RFC][PATCH RESEND] mm: vmalloc: remove ioremap align constraint
Message-id: <20150121095257.ce97fb984ed7b9572cb1cc6a@samsung.com>
In-reply-to: <5891256.RkdjYUxedq@wuerfel>
References: <1419328813-2211-1-git-send-email-d.safonov@partner.samsung.com>
 <11656044.WGcPr1b8t8@wuerfel>
 <20150103185946.1d4fad32bb3de9ac9bdcfb88@gmail.com>
 <5891256.RkdjYUxedq@wuerfel>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, Dmitry Safonov <d.safonov@partner.samsung.com>, linux-mm@kvack.org, Nicolas Pitre <nicolas.pitre@linaro.org>, Russell King <linux@arm.linux.org.uk>, Dyasly Sergey <s.dyasly@samsung.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, James Bottomley <JBottomley@parallels.com>, Arnd Bergmann <arnd.bergmann@linaro.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>

On Sun, 04 Jan 2015 17:38:06 +0100
Arnd Bergmann <arnd@arndb.de> wrote:

> On Saturday 03 January 2015 18:59:46 Sergey Dyasly wrote:
> > Hi Arnd,
> > 
> > First, some background information. We originally encountered high fragmentation
> > issue in vmalloc area:
> > 
> > 	1. Total size of vmalloc area was 400 MB.
> > 	2. 200 MB of vmalloc area was consumed by ioremaps of various sizes.
> > 	3. Largest contiguous chunk of vmalloc area was 12 MB.
> > 	4. ioremap of 10 MB failed due to 8 MB alignment requirement.
> 
> Interesting, can you describe how you end up with that many ioremap mappings?
> 200MB seems like a lot. Do you perhaps get a lot of duplicate entries for the
> same hardware registers, or maybe a leak?
> 
> Can you send the output of /proc/vmallocinfo?
>  
> > It was decided to further increase the size of vmalloc area to resolve the above
> > issue. And I don't like that solution because it decreases the amount of lowmem.
> 
> If all the mappings are in fact required, have you considered using
> CONFIG_VMSPLIT_2G split to avoid the use of highmem?
> 
> > Now let's see how ioremap uses supersections. Judging from current implementation
> > of __arm_ioremap_pfn_caller:
> > 
> > 	#if !defined(CONFIG_SMP) && !defined(CONFIG_ARM_LPAE)
> > 		if (pfn >= 0x100000 && !((paddr | size | addr) & ~SUPERSECTION_MASK)) {
> > 			remap_area_supersections();
> > 		} else if (!((paddr | size | addr) & ~PMD_MASK)) {
> > 			remap_area_sections();
> > 		} else
> > 	#endif
> > 			err = ioremap_page_range();
> > 
> > supersections and sections mappings are used only in !SMP && !LPAE case.
> > Otherwise, mapping is created using the usual 4K pages (and we are using SMP).
> > The suggested patch removes alignment requirements for ioremap but it means that
> > sections will not be used in !SMP case. So another solution is required.
> > 
> > __get_vm_area_node has align parameter, maybe it can be used to specify the
> > required alignment of ioremap operation? Because I find current generic fls
> > algorithm to be very restrictive in cases when it's not necessary to use such
> > a big alignment.
> 
> I think using next-power-of-two alignment generally helps limit the effects of
> fragmentation the same way that the buddy allocator works.
> 
> Since the section and supersection maps are only used with non-SMP non-LPAE
> (why is that the case btw?),

vmap/vunmap mechanism works that way. ARM is using 2 levels of page tables:
PGD and PTE; and that provides the needed level of indirection. Every mm
contains a copy of init_mm's pgd mappings for kernel and they point to the same
set of PTEs. vmap/vunmap manipulates only with *pgd->pte and the change becomes
visible to every mm. This is impossible to do for sections because they use
PGD entries directly.

> it would however make sense to use the default
> (7 + PAGE_SHIFT) instead of the ARM-specific 24 here if one of them is set,
> I don't see any downsides to that.

This makes sense. I'll prepare a patch for that.

> 
> 	Arnd


-- 
Sergey Dyasly <s.dyasly@samsung.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
