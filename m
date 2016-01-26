Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4FF036B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 17:11:54 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id x125so163392pfb.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 14:11:54 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r6si4453777pap.212.2016.01.26.14.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 14:11:53 -0800 (PST)
Date: Tue, 26 Jan 2016 14:11:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm: support CONFIG_ZONE_DEVICE + CONFIG_ZONE_DMA
Message-Id: <20160126141152.e1043d14502dcca17813afb3@linux-foundation.org>
In-Reply-To: <20160126000639.358.89668.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20160126000639.358.89668.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Rik van Riel <riel@redhat.com>, linux-nvdimm@ml01.01.org, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Jerome Glisse <j.glisse@gmail.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

On Mon, 25 Jan 2016 16:06:40 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> It appears devices requiring ZONE_DMA are still prevalent (see link
> below).  For this reason the proposal to require turning off ZONE_DMA to
> enable ZONE_DEVICE is untenable in the short term.

More than "short term".  When can we ever nuke ZONE_DMA?

This was a pretty big goof - the removal of ZONE_DMA whizzed straight
past my attention, alas.  In fact I never noticed the patch at all
until I got some conflicts in -next a few weeks later (wasn't cc'ed). 
And then I didn't read the changelog closely enough.

>  We want a single
> kernel image to be able to support legacy devices as well as next
> generation persistent memory platforms.

yup.
 
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

Well, all these icky tricks are to avoid increasing ZONES_SHIFT, yes? 
Is it possible to just use ZONES_SHIFT=3?

Also, this "dynamically added pfn of the zone" thing is a new concept
and I think it should be more completely documented somewhere in the
code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
