Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 83E976B0005
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 08:40:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b7-v6so879415pgv.5
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 05:40:11 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id a11-v6si2584465pfo.68.2018.06.13.05.40.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 05:40:10 -0700 (PDT)
Received: from eucas1p2.samsung.com (unknown [182.198.249.207])
	by mailout1.w1.samsung.com (KnoxPortal) with ESMTP id 20180613124004euoutp013991e6226021b43bd288932dcabb380c~3uKH4aarB2933629336euoutp01n
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 12:40:04 +0000 (GMT)
Subject: Re: [PATCH] mm: cma: honor __GFP_ZERO flag in cma_alloc()
From: Marek Szyprowski <m.szyprowski@samsung.com>
Date: Wed, 13 Jun 2018 14:40:00 +0200
MIME-Version: 1.0
In-Reply-To: <20180613122359.GA8695@bombadil.infradead.org>
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <20180613124001eucas1p2422f7916367ce19fecd40d6131990383~3uKFrT3ML1977219772eucas1p2G@eucas1p2.samsung.com>
Content-Type: text/plain; charset="utf-8"
References: <CGME20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2@eucas1p2.samsung.com>
	<20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2~3rI_9nj8b0455904559eucas1p2C@eucas1p2.samsung.com>
	<20180613122359.GA8695@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

Hi Matthew,

On 2018-06-13 14:24, Matthew Wilcox wrote:
> On Wed, Jun 13, 2018 at 10:58:37AM +0200, Marek Szyprowski wrote:
>> cma_alloc() function has gfp mask parameter, so users expect that it
>> honors typical memory allocation related flags. The most imporant from
>> the security point of view is handling of __GFP_ZERO flag, because memory
>> allocated by this function usually can be directly remapped to userspace
>> by device drivers as a part of multimedia processing and ignoring this
>> flag might lead to leaking some kernel structures to userspace.
>> Some callers of this function (for example arm64 dma-iommu glue code)
>> already assumed that the allocated buffers are cleared when this flag
>> is set. To avoid such issues, add simple code for clearing newly
>> allocated buffer when __GFP_ZERO flag is set. Callers will be then
>> updated to skip implicit clearing or adjust passed gfp flags.
> I think the documentation for this function needs improving.  For example,
> GFP_ATOMIC does not work (it takes a mutex lock, so it can sleep).
> At the very least, the kernel-doc needs:
>
>   * Context: Process context (may sleep even if GFP flags indicate otherwise).
>
> Unless someone wants to rework this allocator to use spinlocks instead
> of mutexes ...

It is not only the matter of the spinlocks. GFP_ATOMIC is not supported 
by the
memory compaction code, which is used in alloc_contig_range(). Right, this
should be also noted in the documentation.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland
