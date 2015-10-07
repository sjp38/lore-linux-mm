Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id CF1816B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 15:17:06 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so225460968wic.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 12:17:06 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [146.101.78.143])
        by mx.google.com with ESMTPS id zb2si9198972wjc.95.2015.10.07.12.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Oct 2015 12:17:05 -0700 (PDT)
Subject: Re: [PATCH 4/4] dma-debug: Allow poisoning nonzero allocations
References: <cover.1443178314.git.robin.murphy@arm.com>
 <0405c6131def5aa179ff4ba5d4201ebde89cede3.1443178314.git.robin.murphy@arm.com>
 <20150925124447.GO21513@n2100.arm.linux.org.uk> <560585EB.3060908@arm.com>
 <20150929142727.e95a2d2ebff65dda86315248@linux-foundation.org>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <56156FAF.9020002@arm.com>
Date: Wed, 7 Oct 2015 20:17:03 +0100
MIME-Version: 1.0
In-Reply-To: <20150929142727.e95a2d2ebff65dda86315248@linux-foundation.org>
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "sakari.ailus@iki.fi" <sakari.ailus@iki.fi>, "sumit.semwal@linaro.org" <sumit.semwal@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>

On 29/09/15 22:27, Andrew Morton wrote:
[...]
> If I'm understanding things correctly, some allocators zero the memory
> by default and others do not.  And we have an unknown number of drivers
> which are assuming that the memory is zeroed.
>
> Correct?

That's precisely the motivation here, yes.

> If so, our options are
>
> a) audit all callers, find the ones which expect zeroed memory but
>     aren't passing __GFP_ZERO and fix them.
>
> b) convert all allocators to zero the memory by default.
>
> Obviously, a) is better.  How big a job is it?

This I'm not so sure of, hence the very tentative first step. For a very=20
crude guess at an an upper bound:

$ git grep -E '(dma|pci)_alloc_co(her|nsist)ent' drivers/ | wc -l
1148

vs.

$ git grep -E '(dma|pci)_zalloc_co(her|nsist)ent' drivers/ | wc -l
234

noting that the vast majority of the former are still probably benign,=20
but picking out those which aren't from the code alone without knowledge=20
of and/or access to the hardware might be non-trivial.

> This patch will help the process, if people use it.
>
>>>> +=09if (IS_ENABLED(CONFIG_DMA_API_DEBUG_POISON) && !(flags & __GFP_ZER=
O))
>>>> +=09=09memset(virt, DMA_ALLOC_POISON, size);
>>>> +
>>>
>>> This is likely to be slow in the case of non-cached memory and large
>>> allocations.  The config option should come with a warning.
>>
>> It depends on DMA_API_DEBUG, which already has a stern performance
>> warning, is additionally hidden behind EXPERT, and carries a slightly
>> flippant yet largely truthful warning that actually using it could break
>> pretty much every driver in your system; is that not enough?
>
> It might be helpful to provide a runtime knob as well - having to
> rebuild&reinstall just to enable/disable this feature is a bit painful.

Good point - there's always the global DMA debug disable knob, but this=20
particular feature probably does warrant finer-grained control to be=20
really practical. Having thought about it some more, it's also probably=20
wrong that this doesn't respect the dma_debug_driver filter, given that=20
it is actually invasive; in fixing that, how about if it also *only*=20
applied when a specific driver is filtered? Then there would be no=20
problematic "break anything and everything" mode, and the existing=20
debugfs controls should suffice.

Robin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
