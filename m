Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id C817B6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 16:48:15 -0500 (EST)
Received: by mail-yk0-f182.google.com with SMTP id u68so88961925ykd.2
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:48:15 -0800 (PST)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id i63si1138554ywe.375.2016.01.26.13.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 13:48:15 -0800 (PST)
Received: by mail-yk0-x22d.google.com with SMTP id u68so88961619ykd.2
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:48:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56A7E846.30607@suse.cz>
References: <20160126000639.358.89668.stgit@dwillia2-desk3.amr.corp.intel.com>
	<56A7E846.30607@suse.cz>
Date: Tue, 26 Jan 2016 13:48:14 -0800
Message-ID: <CAPcyv4iQHDXw9ah7fOqEjHGCVpnLAyyx+KWNTdQ-vCzAEk7GgA@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: support CONFIG_ZONE_DEVICE + CONFIG_ZONE_DMA
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Jerome Glisse <j.glisse@gmail.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@fedoraproject.org>

On Tue, Jan 26, 2016 at 1:42 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 26.1.2016 1:06, Dan Williams wrote:
>> It appears devices requiring ZONE_DMA are still prevalent (see link
>> below).  For this reason the proposal to require turning off ZONE_DMA to
>> enable ZONE_DEVICE is untenable in the short term.  We want a single
>> kernel image to be able to support legacy devices as well as next
>> generation persistent memory platforms.
>>
>> Towards this end, alias ZONE_DMA and ZONE_DEVICE to work around needing
>> to maintain a unique zone number for ZONE_DEVICE.  Record the geometry
>> of ZONE_DMA at init (->init_spanned_pages) and use that information in
>> is_zone_device_page() to differentiate pages allocated via
>> devm_memremap_pages() vs true ZONE_DMA pages.  Otherwise, use the
>> simpler definition of is_zone_device_page() when ZONE_DMA is turned off.
>>
>> Note that this also teaches the memory hot remove path that the zone may
>> not have sections for all pfn spans (->zone_dyn_start_pfn).
>>
>> A user visible implication of this change is potentially an unexpectedly
>> high "spanned" value in /proc/zoneinfo for the DMA zone.
>
> [+CC Joonsoo, Laura]
>
> Sounds like quite a hack :(

Indeed...

> Would it be possible to extend the bits encoding
> zone? Potentially, ZONE_CMA could be added one day...

Not without impacting the ability to quickly lookup the numa node and
parent section for a page.  See ZONES_WIDTH, NODES_WIDTH, and
SECTIONS_WIDTH.

My initial implementation of ZONE_DEVICE ran into this conflict when
ZONES_SHIFT is > 2, and I fell back to cannibalizing ZONE_DMA.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
