Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 07AD4828E1
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:55:18 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id xx9so28844992obc.2
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:55:18 -0800 (PST)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id n3si5016862oig.51.2016.02.29.09.55.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 09:55:17 -0800 (PST)
Received: by mail-oi0-x235.google.com with SMTP id m82so110318855oif.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:55:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D43AAB.2010802@suse.cz>
References: <20160128061914.32541.97351.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20160201214213.2bdf9b4e.akpm@linux-foundation.org>
	<56D43AAB.2010802@suse.cz>
Date: Mon, 29 Feb 2016 09:55:17 -0800
Message-ID: <CAPcyv4i587ow4yEFN+81rd=_kVL3YV1daU7cDM4V4YCAhDMRVA@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: CONFIG_NR_ZONES_EXTENDED
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Mark <markk@clara.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

On Mon, Feb 29, 2016 at 4:33 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 02/02/2016 06:42 AM, Andrew Morton wrote:
>>
>> On Wed, 27 Jan 2016 22:19:14 -0800 Dan Williams <dan.j.williams@intel.com>
>> wrote:
>>
>>> ZONE_DEVICE (merged in 4.3) and ZONE_CMA (proposed) are examples of new
>>> mm zones that are bumping up against the current maximum limit of 4
>>> zones, i.e. 2 bits in page->flags.  When adding a zone this equation
>>> still needs to be satisified:
>>>
>>>      SECTIONS_WIDTH + ZONES_WIDTH + NODES_SHIFT + LAST_CPUPID_SHIFT
>>>           <= BITS_PER_LONG - NR_PAGEFLAGS
>>>
>>> ZONE_DEVICE currently tries to satisfy this equation by requiring that
>>> ZONE_DMA be disabled, but this is untenable given generic kernels want
>>> to support ZONE_DEVICE and ZONE_DMA simultaneously.  ZONE_CMA would like
>>> to increase the amount of memory covered per section, but that limits
>>> the minimum granularity at which consecutive memory ranges can be added
>>> via devm_memremap_pages().
>>>
>>> The trade-off of what is acceptable to sacrifice depends heavily on the
>>> platform.  For example, ZONE_CMA is targeted for 32-bit platforms where
>>> page->flags is constrained, but those platforms likely do not care about
>>> the minimum granularity of memory hotplug.  A big iron machine with 1024
>>> numa nodes can likely sacrifice ZONE_DMA where a general purpose
>>> distribution kernel can not.
>>>
>>> CONFIG_NR_ZONES_EXTENDED is a configuration symbol that gets selected
>>> when the number of configured zones exceeds 4.  It documents the
>>> configuration symbols and definitions that get modified when ZONES_WIDTH
>>> is greater than 2.
>>>
>>> For now, it steals a bit from NODES_SHIFT.  Later on it can be used to
>>> document the definitions that get modified when a 32-bit configuration
>>> wants more zone bits.
>>
>>
>> So if you want ZONE_DMA, you're limited to 512 NUMA nodes?
>>
>> That seems reasonable.
>
>
> Sorry for the late reply, but it seems that with !SPARSEMEM, or with
> SPARSEMEM_VMEMMAP, reducing NUMA nodes isn't even necessary, because
> SECTIONS_WIDTH is zero (see the diagrams in linux/page-flags-layout.h). In
> my brief tests with 4.4 based kernel with SPARSEMEM_VMEMMAP it seems that
> with 1024 NUMA nodes and 8192 CPU's, there's still 7 bits left (i.e. 6 with
> CONFIG_NR_ZONES_EXTENDED).
>
> With the danger of becoming even more complex, could the limit also depend
> on CONFIG_SPARSEMEM/VMEMMAP to reflect that somehow?

In this case it's already part of the equation because:

config ZONE_DEVICE
       depends on MEMORY_HOTPLUG
       depends on MEMORY_HOTREMOVE

...and those in turn depend on SPARSEMEM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
