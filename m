Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EC2B76B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 08:35:06 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=ISO-8859-1
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LDV003XOV2D8A50@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 23 Dec 2010 13:35:03 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LDV000IVV2CQU@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 23 Dec 2010 13:35:01 +0000 (GMT)
Date: Thu, 23 Dec 2010 14:35:00 +0100
From: Tomasz Fujak <t.fujak@samsung.com>
Subject: Re: [PATCHv8 00/12] Contiguous Memory Allocator
In-reply-to: <20101223121917.GG3636@n2100.arm.linux.org.uk>
Message-id: <4D135004.3070904@samsung.com>
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
 <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com>
 <20101223100642.GD3636@n2100.arm.linux.org.uk>
 <00ea01cba290$4d67f500$e837df00$%szyprowski@samsung.com>
 <20101223121917.GG3636@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Kyungmin Park' <kmpark@infradead.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org'Michal Nazarewicz' <mina86@mina86.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, 'Andrew Morton' <akpm@linux-foundation.org>, linux-media@vger.kernel.org, 'Johan MOSSBERG' <johan.xx.mossberg@stericsson.com>, 'Ankita Garg' <ankita@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Dear Mr. King,

AFAIK the CMA is the fourth attempt since 2008 taken to solve the
multimedia memory allocation issue on some embedded devices. Most
notably on ARM, that happens to be present in the SoCs we care about
along the IOMMU-incapable multimedia IPs.

I understand that you have your guidelines taken from the ARM
specification, but this approach is not helping us. The mainline kernel
is server- and desktop-centric for various reasons I am not going to
dwell into. We're trying hard to solve the physical memory fragmentation
issue for some time now, only to hear "this is not acceptable, go
somewhere else". So we did - the CMA is targeted towards mm, NOT the
ARM. While I do not exactly know how you see your role in ARM kernel
development, we have shown a few times that this issue is important for
us, and we'd like to solve it. So if you could give a glimpse of what is
acceptable, given the existing circumstances, we could possibly help
developing that solution. Namely:
1. ARM-compatible SoC
2. Multimedia IP blocks requiring large amounts of contiguous memory
2. No IOMMU or SG in said blocks
4. Unused memory reserved for said multimedia drivers should  be used by
the kernel
5. Multimedia allocation scenarios must always be working (under some
constraints of course), within sane time limit
6. The solution shall have minimal delta to upstream linux (none?)

While the obvious CMA uses are the ones you'd mostly like to avoid, we
haven't tried to post anything like that along.
This way no obvious spec abuse is made, and we minimize the delta to the
upstream - it's even better than current state, when you have dma
coherent memory doing exactly what you claim is forbidden (unpredictable
results could possibly happen).

As the feedback from the first CMA patches confirm, the issue we're
trying to solve here is real. Yet no real solution exists to my
knowledge. I understand the ARM holding my try to just wait till all the
relevant chips do have an IOMMU, but here and now there is a SOC we are
going to use. No IMOMMU, no SG. So would you please help us - or if for
some reason you can't, just not make our work any harder?

BTW why is the lowmem unmap not feasible? Is it the section entries in
the page tables scattered throughout the system? I was unable to find
the answer so far.

Best regards
-- 
Tomasz Fujak
Samsung Electronics Poland R&D

On 2010-12-23 13:19, Russell King - ARM Linux wrote:
> On Thu, Dec 23, 2010 at 11:58:08AM +0100, Marek Szyprowski wrote:
>> Actually this contiguous memory allocator is a better replacement for
>> alloc_pages() which is used by dma_alloc_coherent(). It is a generic
>> framework that is not tied only to ARM architecture.
> ... which is open to abuse.  What I'm trying to find out is - if it
> can't be used for DMA, what is it to be used for?
>
> Or are we inventing an everything-but-ARM framework?
>
>>> In other words, do we _actually_ have a use for this which doesn't
>>> involve doing something like allocating 32MB of memory from it,
>>> remapping it so that it's DMA coherent, and then performing DMA
>>> on the resulting buffer?
>> This is an arm specific problem, also related to dma_alloc_coherent()
>> allocator. To be 100% conformant with ARM specification we would
>> probably need to unmap all pages used by the dma_coherent allocator
>> from the LOW MEM area. This is doable, but completely not related
>> to the CMA and this patch series.
> You've already been told why we can't unmap pages from the kernel
> direct mapping.
>
> Okay, so I'm just going to assume that CMA has _no_ _business_ being
> used on ARM, and is not something that should interest anyone in the
> ARM community.
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
