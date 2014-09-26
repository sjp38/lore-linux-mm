Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC5A6B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:11:05 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id cm18so6013969qab.0
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 07:11:05 -0700 (PDT)
Received: from n23.mail01.mtsvc.net (mailout32.mail01.mtsvc.net. [216.70.64.70])
        by mx.google.com with ESMTPS id w4si5963676qaj.69.2014.09.26.07.11.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Sep 2014 07:11:01 -0700 (PDT)
Message-ID: <542573EE.8070103@hurleysoftware.com>
Date: Fri, 26 Sep 2014 10:10:54 -0400
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: Re: page allocator bug in 3.16?
References: <54246506.50401@hurleysoftware.com>	<20140925143555.1f276007@as>	<5424AAD0.9010708@hurleysoftware.com>	<542512AD.9070304@vmware.com>	<20140926054005.5c7985c0@as>	<542543D8.8020604@vmware.com> <CAF6AEGvOkPq5LQR76-VbspYyCvUxL1=W-dLc4g_aWX2wkUmRpg@mail.gmail.com> <54255EA5.3030207@redhat.com>
In-Reply-To: <54255EA5.3030207@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Rob Clark <robdclark@gmail.com>, Thomas Hellstrom <thellstrom@vmware.com>
Cc: Chuck Ebbert <cebbert.lkml@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickens <hughd@google.com>, Linux kernel <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@kernel.org>, Ingo Molnar <mingo@kernel.org>, Leann Ogasawara <leann.ogasawara@canonical.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>

[ +cc Leann Ogasawara, Marek Szyprowski, Kyungmin Park, Arnd Bergmann ]

On 09/26/2014 08:40 AM, Rik van Riel wrote:
> On 09/26/2014 08:28 AM, Rob Clark wrote:
>> On Fri, Sep 26, 2014 at 6:45 AM, Thomas Hellstrom
>> <thellstrom@vmware.com> wrote:
>>> On 09/26/2014 12:40 PM, Chuck Ebbert wrote:
>>>> On Fri, 26 Sep 2014 09:15:57 +0200 Thomas Hellstrom
>>>> <thellstrom@vmware.com> wrote:
>>>>
>>>>> On 09/26/2014 01:52 AM, Peter Hurley wrote:
>>>>>> On 09/25/2014 03:35 PM, Chuck Ebbert wrote:
>>>>>>> There are six ttm patches queued for 3.16.4:
>>>>>>>
>>>>>>> drm-ttm-choose-a-pool-to-shrink-correctly-in-ttm_dma_pool_shrink_scan.patch
>>>>>>>
>>>>>>>
> drm-ttm-fix-handling-of-ttm_pl_flag_topdown-v2.patch
>>>>>>> drm-ttm-fix-possible-division-by-0-in-ttm_dma_pool_shrink_scan.patch
>>>>>>>
>>>>>>>
> drm-ttm-fix-possible-stack-overflow-by-recursive-shrinker-calls.patch
>>>>>>> drm-ttm-pass-gfp-flags-in-order-to-avoid-deadlock.patch 
>>>>>>> drm-ttm-use-mutex_trylock-to-avoid-deadlock-inside-shrinker-functions.patch
>>>>>>
>>>>>>>
> Thanks for info, Chuck.
>>>>>>
>>>>>> Unfortunately, none of these fix TTM dma allocation doing
>>>>>> CMA dma allocation, which is the root problem.
>>>>>>
>>>>>> Regards, Peter Hurley
>>>>> The problem is not really in TTM but in CMA, There was a guy
>>>>> offering to fix this in the CMA code but I guess he didn't
>>>>> probably because he didn't receive any feedback.
>>>>>
>>>> Yeah, the "solution" to this problem seems to be "don't enable
>>>> CMA on x86". Maybe it should even be disabled in the config
>>>> system.
>>> Or, as previously suggested, don't use CMA for order 0 (single
>>> page) allocations....
>>
>> On devices that actually need CMA pools to arrange for memory to be
>> in certain ranges, I think you probably do want to have order 0
>> pages come from the CMA pool.
>>
>> Seems like disabling CMA on x86 (where it should be unneeded) is
>> the better way, IMO
> 
> CMA has its uses on x86. For example, CMA is used to allocate 1GB huge
> pages.
> 
> There may also be people with devices that do not scatter-gather, and
> need a large physically contiguous buffer, though there should be
> relatively few of those on x86.
> 
> I suspect it makes most sense to do DMA allocations up to PAGE_ORDER
> through the normal allocator on x86, and only invoking CMA for larger
> allocations.

The code that uses CMA to satisfy DMA allocations on x86 is
specific to the x86 arch and was added in 2011 as a means of _testing_
CMA in KVM:

commit 0a2b9a6ea93650b8a00f9fd5ee8fdd25671e2df6
Author: Marek Szyprowski <m.szyprowski@samsung.com>
Date:   Thu Dec 29 13:09:51 2011 +0100

    X86: integrate CMA with DMA-mapping subsystem
    
    This patch adds support for CMA to dma-mapping subsystem for x86
    architecture that uses common pci-dma/pci-nommu implementation. This
    allows to test CMA on KVM/QEMU and a lot of common x86 boxes.
    
    Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
    Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
    CC: Michal Nazarewicz <mina86@mina86.com>
    Acked-by: Arnd Bergmann <arnd@arndb.de>

(no x86 maintainer acks?).

Unfortunately, this code is enabled whenever CMA is enabled, rather
than as a separate test configuration.

So, while enabling CMA may have other purposes on x86, using it for
x86 swiotlb and nommu dma allocations is not one of the them.

And Ubuntu should not be enabling CONFIG_DMA_CMA for their i386
and amd64 configurations, as this is trying to drive _all_ dma mapping
allocations through a _very_ small window (which is killing GPU
performance).

Regards,
Peter Hurley


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
