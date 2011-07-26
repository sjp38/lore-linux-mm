Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4DABF6B0169
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 08:56:47 -0400 (EDT)
Received: from eu_spt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LOX005KLYML6J@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 26 Jul 2011 13:56:45 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LOX00FSIYMJFX@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 26 Jul 2011 13:56:44 +0100 (BST)
Date: Tue, 26 Jul 2011 14:56:38 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 1/8] ARM: dma-mapping: remove offset parameter to prepare
 for generic dma_ops
In-reply-to: <20110703152826.GL21898@n2100.arm.linux.org.uk>
Message-id: <00c401cc4b93$75bae4c0$6130ae40$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <1308556213-24970-2-git-send-email-m.szyprowski@samsung.com>
 <20110703152826.GL21898@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, Marek Szyprowski <m.szyprowski@samsung.com>

Hello,

On Sunday, July 03, 2011 5:28 PM Russell King wrote:

> On Mon, Jun 20, 2011 at 09:50:06AM +0200, Marek Szyprowski wrote:
> > This patch removes the need for offset parameter in dma bounce
> > functions. This is required to let dma-mapping framework on ARM
> > architecture use common, generic dma-mapping helpers.
> 
> I really don't like this.  Really as in hate.  Why?  I've said in the past
> that the whole idea of getting rid of the sub-range functions is idiotic.
> 
> If you have to deal with cache coherence, what you _really_ want is an
> API which tells you the size of the original buffer and the section of
> that buffer which you want to handle - because the edges of the buffer
> need special handling.
> 
> Lets say that you have a buffer which is 256 bytes long, misaligned to
> half a cache line.  Let's first look at the sequence for whole-buffer:
> 
> 1. You map it for DMA from the device.  This means you writeback the
>    first and last cache lines to perserve any data shared in the
>    overlapping cache line.  The remainder you can just invalidate.
> 
> 2. You want to access the buffer, so you use the sync_for_cpu function.
>    If your CPU doesn't do any speculative prefetching, then you don't
>    need to do anything.  If you do, you have to invalidate the buffer,
>    but you must preserve the overlapping cache lines which again must
>    be written back.
> 
> 3. You transfer ownership back to the device using sync_for_device.
>    As you may have caused cache lines to be read in, again you need to
>    invalidate, and the overlapping cache lines must be written back.
> 
> Now, if you ask for a sub-section of the buffer to be sync'd, you can
> actually eliminate those writebacks which are potentially troublesome,
> and which could corrupt neighbouring data.
> 
> If you get rid of the sub-buffer functions and start using the whole
> buffer functions for that purpose, you no longer know whether the
> partial cache lines are part of the buffer or not, so you have to write
> those back every time too.
> 
> So far, we haven't had any reports of corruption of this type (maybe
> folk using the sync functions are rare on ARM - thankfully) but getting
> rid of the range sync functions means that solving this becomes a lot
> more difficult because we've lost the information to make the decision.

Well, right now I haven't heard anyone who wants to remove 
dma_sync_single_range_for_{cpu,device}. All this is about internal
implementation and dma_map_ops which uses the simplified calls, not
exposed to the drivers or any public API. 

I also see no reason why we loose the information. All drivers are still
required to call dma_map_{single,page} to aquire dma address first. This
way DMA mapping subsystem perfectly knows that the range from returned 
dma_addr to dma_addr+size has been used for dma operations. All calls to
dma_sync_single_* operations takes dma_addr as one of the arguments, so
there is no problem to check which dma range this particular sync 
operation fits.

In my patch I have shown that it is perfectly possible to use the common
dma_map_ops structure on ARM and unify dma mapping implementation a bit
with other architectures.

IMHO this is the right way. There is a need for custom dma mapping 
implementations (mainly related to taking the advantage of iommu controllers
available on newer SoCs). I would really like to avoid another set of ifdefs
or sequences of "if (iommu_supported())" all over the dma-mapping code. Even
now all this code is hard to understand in the first read (due to coherent/
non-coherent sub-architectures and dmabounce code mixed in).

> So I've always believed - and continue to do so - that those who want
> to get rid of the range sync functions are misguided and are storing up
> problems for the future.

I never said that I want to remove these operations from drivers API.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
