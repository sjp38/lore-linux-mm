Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7AF886B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 01:00:38 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so92701174pab.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 22:00:38 -0800 (PST)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id 87si39015595pfs.35.2016.01.25.22.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 22:00:37 -0800 (PST)
Received: by mail-pf0-x22f.google.com with SMTP id 65so6595981pfd.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 22:00:37 -0800 (PST)
Date: Tue, 26 Jan 2016 11:30:28 +0530
From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [RFC PATCH] mm: support CONFIG_ZONE_DEVICE + CONFIG_ZONE_DMA
Message-ID: <20160126060028.GB2053@sudip-laptop>
References: <20160126000639.358.89668.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160126000639.358.89668.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Mark <markk@clara.co.uk>
Cc: akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Jerome Glisse <j.glisse@gmail.com>

On Mon, Jan 25, 2016 at 04:06:40PM -0800, Dan Williams wrote:
> It appears devices requiring ZONE_DMA are still prevalent (see link
> below).  For this reason the proposal to require turning off ZONE_DMA to
> enable ZONE_DEVICE is untenable in the short term.  We want a single
> kernel image to be able to support legacy devices as well as next
> generation persistent memory platforms.
> 
> Towards this end, alias ZONE_DMA and ZONE_DEVICE to work around needing
> to maintain a unique zone number for ZONE_DEVICE.  Record the geometry
> of ZONE_DMA at init (->init_spanned_pages) and use that information in
> is_zone_device_page() to differentiate pages allocated via
> devm_memremap_pages() vs true ZONE_DMA pages.  Otherwise, use the
> simpler definition of is_zone_device_page() when ZONE_DMA is turned off.
> 
> Note that this also teaches the memory hot remove path that the zone may
> not have sections for all pfn spans (->zone_dyn_start_pfn).
> 
> A user visible implication of this change is potentially an unexpectedly
> high "spanned" value in /proc/zoneinfo for the DMA zone.
> 
> Cc: H. Peter Anvin <hpa@zytor.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Jerome Glisse <j.glisse@gmail.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=110931
> Fixes: 033fbae988fc ("mm: ZONE_DEVICE for "device memory"")
> Reported-by: Sudip Mukherjee <sudipm.mukherjee@gmail.com>

It should actually be Reported-by: Mark <markk@clara.co.uk>

Hi Mark,
Can you please test this patch available at https://patchwork.kernel.org/patch/8116991/
in your setup..

regards
sudip

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
