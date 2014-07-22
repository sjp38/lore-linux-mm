Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5D76B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 19:51:08 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so464234pdb.33
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 16:51:08 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id u2si515970pbz.202.2014.07.22.16.51.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jul 2014 16:51:07 -0700 (PDT)
Message-ID: <53CEF8E8.3080607@codeaurora.org>
Date: Tue, 22 Jul 2014 16:51:04 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCHv4 5/5] arm64: Add atomic pool for non-coherent and CMA
 allocations.
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org> <1404324218-4743-6-git-send-email-lauraa@codeaurora.org> <201407222006.44666.arnd@arndb.de> <20140722210352.GA10604@arm.com>
In-Reply-To: <20140722210352.GA10604@arm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <Will.Deacon@arm.com>, David Riley <davidriley@chromium.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ritesh Harjain <ritesh.harjani@gmail.com>

On 7/22/2014 2:03 PM, Catalin Marinas wrote:
> On Tue, Jul 22, 2014 at 07:06:44PM +0100, Arnd Bergmann wrote:
[...]
>>> +               if (!addr)
>>> +                       goto destroy_genpool;
>>> +
>>> +               memset(addr, 0, atomic_pool_size);
>>> +               __dma_flush_range(addr, addr + atomic_pool_size);
>>
>> It also seems weird to flush the cache on a virtual address of
>> an uncacheable mapping. Is that well-defined?
> 
> Yes. According to D5.8.1 (Data and unified caches), "if cache
> maintenance is performed on a memory location, the effect of that cache
> maintenance is visible to all aliases of that physical memory location.
> These properties are consistent with implementing all caches that can
> handle data accesses as Physically-indexed, physically-tagged (PIPT)
> caches".
> 

This was actually unintentional on my part. I'm going to clean this up
to flush via the existing cached mapping to make it clearer what's going
on.

>> In the CMA case, the
>> original mapping should already be uncached here, so you don't need
>> to flush it.
> 
> I don't think it is non-cacheable already, at least not for arm64 (CMA
> can be used on coherent architectures as well).
> 

Memory allocated via dma_alloc_from_contiguous is not guaranteed to be
uncached. On arm, we allocate the page of memory and the remap it as
appropriate.

>> In the alloc_pages() case, I think you need to unmap
>> the pages from the linear mapping instead.
> 
> Even if unmapped, it would not remove dirty cache lines (which are
> associated with physical addresses anyway). But we don't need to worry
> about unmapping anyway, see above (that's unless we find some
> architecture implementation where having such cacheable/non-cacheable
> aliases is not efficient enough, the efficiency is not guaranteed by the
> ARM ARM, just the correct behaviour).
> 

Let's hope that never happens.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
