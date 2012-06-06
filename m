Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 5E5546B00B3
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 09:45:50 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so11420917pbb.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 06:45:49 -0700 (PDT)
Message-ID: <4FCF5F04.7030207@gmail.com>
Date: Wed, 06 Jun 2012 19:15:40 +0530
From: Subash Patel <subashrp@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 0/2] ARM: DMA-mapping: new extensions for buffer sharing
 (part 2)
References: <1338988657-20770-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1338988657-20770-1-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subash.ramaswamy@linaro.org>, Sumit Semwal <sumit.semwal@linaro.org>, Abhinav Kochhar <abhinav.k@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

Hello Marek,

Thanks for the patch. We had found below two challenges when using UMM 
related to the cache invalidate/flush after/before performing the DMA 
operations:

a) when using HIGH_MEM pages, the page-table walk consumed lot of time 
to get the KVA of each page. Moreover the overhead was from the spinlock 
we acquire/release for each of the page.

b) One of my colleague tried to map/unmap the buffers only once instead 
of every time(which results in this problem) and we didn't find 
significant performance improvement. The reason is (as per my knowledge) 
when we give address range to cache controller to invalidate/flush out, 
the hardware operation is too fast(if there were any cache lines 
associated with the pages at all) to add any overhead to the CPU operation.

But this patch makes logical flow for dma-mapping one step closer :) I 
will adopt it as part of pulling all your new patches, and will keep you 
updated of any new findings.

Regards,
Subash

On 06/06/2012 06:47 PM, Marek Szyprowski wrote:
> Hello,
>
> This is a continuation of the dma-mapping extensions posted in the
> following thread:
> http://thread.gmane.org/gmane.linux.kernel.mm/78644
>
> We noticed that some advanced buffer sharing use cases usually require
> creating a dma mapping for the same memory buffer for more than one
> device. Usually also such buffer is never touched with CPU, so the data
> are processed by the devices.
>
>  From the DMA-mapping perspective this requires to call one of the
> dma_map_{page,single,sg} function for the given memory buffer a few
> times, for each of the devices. Each dma_map_* call performs CPU cache
> synchronization, what might be a time consuming operation, especially
> when the buffers are large. We would like to avoid any useless and time
> consuming operations, so that was the main reason for introducing
> another attribute for DMA-mapping subsystem: DMA_ATTR_SKIP_CPU_SYNC,
> which lets dma-mapping core to skip CPU cache synchronization in certain
> cases.
>
> The proposed patches have been generated on top of the ARM DMA-mapping
> redesign patch series on Linux v3.4-rc7. They are also available on the
> following GIT branch:
>
> git://git.linaro.org/people/mszyprowski/linux-dma-mapping.git 3.4-rc7-arm-dma-v10-ext
>
> with all require patches on top of vanilla v3.4-rc7 kernel. I will
> resend them rebased onto v3.5-rc1 soon.
>
> Best regards
> Marek Szyprowski
> Samsung Poland R&D Center
>
>
> Patch summary:
>
> Marek Szyprowski (2):
>    common: DMA-mapping: add DMA_ATTR_SKIP_CPU_SYNC attribute
>    ARM: dma-mapping: add support for DMA_ATTR_SKIP_CPU_SYNC attribute
>
>   Documentation/DMA-attributes.txt |   24 ++++++++++++++++++++++++
>   arch/arm/mm/dma-mapping.c        |   20 +++++++++++---------
>   include/linux/dma-attrs.h        |    1 +
>   3 files changed, 36 insertions(+), 9 deletions(-)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
