Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6AC6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 17:51:55 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id x125so674058pfb.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 14:51:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w70si4726407pfa.98.2016.01.26.14.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 14:51:54 -0800 (PST)
Date: Tue, 26 Jan 2016 14:51:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm: support CONFIG_ZONE_DEVICE + CONFIG_ZONE_DMA
Message-Id: <20160126145153.44e4f38b04200209d133c0a3@linux-foundation.org>
In-Reply-To: <CAPcyv4hytzxpNt2RT6b5M6iuqz6V3GdSnO3eHwqpHVt4gfXPxg@mail.gmail.com>
References: <20160126000639.358.89668.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20160126141152.e1043d14502dcca17813afb3@linux-foundation.org>
	<CAPcyv4hytzxpNt2RT6b5M6iuqz6V3GdSnO3eHwqpHVt4gfXPxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Rik van Riel <riel@redhat.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Jerome Glisse <j.glisse@gmail.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

On Tue, 26 Jan 2016 14:33:48 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> >> Towards this end, alias ZONE_DMA and ZONE_DEVICE to work around needing
> >> to maintain a unique zone number for ZONE_DEVICE.  Record the geometry
> >> of ZONE_DMA at init (->init_spanned_pages) and use that information in
> >> is_zone_device_page() to differentiate pages allocated via
> >> devm_memremap_pages() vs true ZONE_DMA pages.  Otherwise, use the
> >> simpler definition of is_zone_device_page() when ZONE_DMA is turned off.
> >>
> >> Note that this also teaches the memory hot remove path that the zone may
> >> not have sections for all pfn spans (->zone_dyn_start_pfn).
> >>
> >> A user visible implication of this change is potentially an unexpectedly
> >> high "spanned" value in /proc/zoneinfo for the DMA zone.
> >
> > Well, all these icky tricks are to avoid increasing ZONES_SHIFT, yes?
> > Is it possible to just use ZONES_SHIFT=3?
> 
> Last I tried I hit this warning in mm/memory.c
> 
> #warning Unfortunate NUMA and NUMA Balancing config, growing
> page-frame for last_cpupid.

Well yes, it may take a bit of work - perhaps salvaging a bit from
somewhere else if poss.  But that might provide a better overall
solution so could you please have a think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
