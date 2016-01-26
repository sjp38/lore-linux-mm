Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB2F6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 18:11:38 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id u68so91474021ykd.2
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:11:38 -0800 (PST)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id v1si1242139ywe.138.2016.01.26.15.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 15:11:37 -0800 (PST)
Received: by mail-yk0-x22f.google.com with SMTP id v14so220056885ykd.3
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:11:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160126145153.44e4f38b04200209d133c0a3@linux-foundation.org>
References: <20160126000639.358.89668.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20160126141152.e1043d14502dcca17813afb3@linux-foundation.org>
	<CAPcyv4hytzxpNt2RT6b5M6iuqz6V3GdSnO3eHwqpHVt4gfXPxg@mail.gmail.com>
	<20160126145153.44e4f38b04200209d133c0a3@linux-foundation.org>
Date: Tue, 26 Jan 2016 15:11:36 -0800
Message-ID: <CAPcyv4im4yQqLqRW9DsNRVsRTgWH1CPu1diJryZ4T57rDCWrzg@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: support CONFIG_ZONE_DEVICE + CONFIG_ZONE_DMA
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Jerome Glisse <j.glisse@gmail.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

On Tue, Jan 26, 2016 at 2:51 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 26 Jan 2016 14:33:48 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
>
>> >> Towards this end, alias ZONE_DMA and ZONE_DEVICE to work around needing
>> >> to maintain a unique zone number for ZONE_DEVICE.  Record the geometry
>> >> of ZONE_DMA at init (->init_spanned_pages) and use that information in
>> >> is_zone_device_page() to differentiate pages allocated via
>> >> devm_memremap_pages() vs true ZONE_DMA pages.  Otherwise, use the
>> >> simpler definition of is_zone_device_page() when ZONE_DMA is turned off.
>> >>
>> >> Note that this also teaches the memory hot remove path that the zone may
>> >> not have sections for all pfn spans (->zone_dyn_start_pfn).
>> >>
>> >> A user visible implication of this change is potentially an unexpectedly
>> >> high "spanned" value in /proc/zoneinfo for the DMA zone.
>> >
>> > Well, all these icky tricks are to avoid increasing ZONES_SHIFT, yes?
>> > Is it possible to just use ZONES_SHIFT=3?
>>
>> Last I tried I hit this warning in mm/memory.c
>>
>> #warning Unfortunate NUMA and NUMA Balancing config, growing
>> page-frame for last_cpupid.
>
> Well yes, it may take a bit of work - perhaps salvaging a bit from
> somewhere else if poss.  But that might provide a better overall
> solution so could you please have a think?
>

Will do, especially since other efforts are feeling the pinch on the
MAX_NR_ZONES limitation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
