Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f42.google.com (mail-vn0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 75074900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 13:42:57 -0400 (EDT)
Received: by vnbg62 with SMTP id g62so9984027vnb.4
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 10:42:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x15si14490839vdg.60.2015.06.05.10.42.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 10:42:56 -0700 (PDT)
Message-ID: <5571DF9C.4030404@redhat.com>
Date: Fri, 05 Jun 2015 10:42:52 -0700
From: Laura Abbott <labbott@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] cma: allow concurrent cma pages allocation for multi-cma
 areas
References: <000001d09f66$056b67f0$104237d0$@yang@samsung.com>	<5571BFBE.3070209@redhat.com> <CA+pa1O2xTnWdP6bbPNnBM=P2oMAaLJf9hWZd+KOL12BJp4R-3Q@mail.gmail.com>
In-Reply-To: <CA+pa1O2xTnWdP6bbPNnBM=P2oMAaLJf9hWZd+KOL12BJp4R-3Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <mina86@mina86.com>
Cc: Weijie Yang <weijie.yang@samsung.com>, iamjoonsoo.kim@lge.com, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Weijie Yang <weijie.yang.kh@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 06/05/2015 10:19 AM, MichaA? Nazarewicz wrote:
> On Fri, Jun 05 2015, Laura Abbott wrote:
>> On 06/05/2015 01:01 AM, Weijie Yang wrote:
>>> Currently we have to hold the single cma_mutex when alloc cma pages,
>>> it is ok when there is only one cma area in system.
>>> However, when there are several cma areas, such as in our Android smart
>>> phone, the single cma_mutex prevents concurrent cma page allocation.
>>>
>>> This patch removes the single cma_mutex and uses per-cma area alloc_lock,
>>> this allows concurrent cma pages allocation for different cma areas while
>>> protects access to the same pageblocks.
>>>
>>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
>
>> Last I knew alloc_contig_range needed to be serialized which is why we
>> still had the global CMA mutex. https://lkml.org/lkml/2014/2/18/462
>>
>> So NAK unless something has changed to allow this.
>
> This patch should be fine.
>
> Change youa??ve pointed to would get rid of any serialisation around
> alloc_contig_range which is dangerous, but since CMA regions are
> pageblock-aligned:
>
>      /*
>       * Sanitise input arguments.
>       * Pages both ends in CMA area could be merged into adjacent unmovable
>       * migratetype page by page allocator's buddy algorithm. In the case,
>       * you couldn't get a contiguous memory, which is not what we want.
>       */
>      alignment = max(alignment,
>          (phys_addr_t)PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order));
>      base = ALIGN(base, alignment);
>      size = ALIGN(size, alignment);
>      limit &= ~(alignment - 1);
>
> synchronising allocation in each area should work fine.
>

Okay yes, you are correct. I was somehow thinking that different CMA regions
could end up in the same pageblock. This is documented in alloc_contig_range
but can we put a comment explaining this here too? It seems to come up
every time locking here is discussed.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
