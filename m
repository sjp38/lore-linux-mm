Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 698656B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 14:11:08 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id u188so119738895wmu.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 11:11:08 -0800 (PST)
Received: from claranet-outbound-smtp05.uk.clara.net (claranet-outbound-smtp05.uk.clara.net. [195.8.89.38])
        by mx.google.com with ESMTP id ko8si3603952wjb.26.2016.01.26.11.11.07
        for <linux-mm@kvack.org>;
        Tue, 26 Jan 2016 11:11:07 -0800 (PST)
Message-ID: <f210f47beb9713da6ca43bac792cdbbf.squirrel@ssl-webmail-vh.clara.net>
In-Reply-To: <20160126060028.GB2053@sudip-laptop>
References: 
    <20160126000639.358.89668.stgit@dwillia2-desk3.amr.corp.intel.com>
    <20160126060028.GB2053@sudip-laptop>
Date: Tue, 26 Jan 2016 19:10:51 -0000
Subject: Re: [RFC PATCH] mm: support CONFIG_ZONE_DEVICE + CONFIG_ZONE_DMA
From: "Mark" <markk@clara.co.uk>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, linux-nvdimm@ml01.01.org, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Jerome Glisse <j.glisse@gmail.com>

On Tue, January 26, 2016 06:00, Sudip Mukherjee wrote:
> On Mon, Jan 25, 2016 at 04:06:40PM -0800, Dan Williams wrote:
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
>>
>> Cc: H. Peter Anvin <hpa@zytor.com>
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Jerome Glisse <j.glisse@gmail.com>
>> Cc: Christoph Hellwig <hch@lst.de>
>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>> Link: https://bugzilla.kernel.org/show_bug.cgi?id=110931
>> Fixes: 033fbae988fc ("mm: ZONE_DEVICE for "device memory"")
>> Reported-by: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
>
> It should actually be Reported-by: Mark <markk@clara.co.uk>
>
> Hi Mark,
> Can you please test this patch available at
> https://patchwork.kernel.org/patch/8116991/
> in your setup..

I applied that patch to 4.5-rc1 and it seems to work. At least, there is
no error message in dmesg output any more. I didn't actually try using the
parallel port (need to find a parallel printer cable). Presumably a
parallel printer would work whether DMA is used or not, just slower and
using more CPU time in the PIO case. Also, I don't have any hardware that
needs CONFIG_ZONE_DEVICE.

The config file I used to compile the kernel can be downloaded from
https://www.mediafire.com/?1do33bkko41ypo3
if anyone feels like taking a look.

Perhaps someone with one of the affected PCI sound cards could also test
the patch, since those presumably don't work/build at all without it.
Hopefully someone else has a PC with native parallel port to confirm the
fix. (Native floppy controller may be another affected device.)


Mark


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
