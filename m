Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14EA56B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 18:14:35 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id t56so25619328qte.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 15:14:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n4si7169049qtb.99.2017.01.12.15.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 15:14:34 -0800 (PST)
Date: Thu, 12 Jan 2017 18:14:31 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] Memory hotplug, ZONE_DEVICE, and the future of
 struct page
Message-ID: <20170112231430.GA10096@redhat.com>
References: <CAPcyv4hWNL7=MmnUj65A+gz=eHAnUrVzqV+24QiNQDW--ag8WQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4hWNL7=MmnUj65A+gz=eHAnUrVzqV+24QiNQDW--ag8WQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, linux-block@vger.kernel.org, Stephen Bates <sbates@raithlin.com>, Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

On Thu, Jan 12, 2017 at 02:43:03PM -0800, Dan Williams wrote:
> Back when we were first attempting to support DMA for DAX mappings of
> persistent memory the plan was to forgo 'struct page' completely and
> develop a pfn-to-scatterlist capability for the dma-mapping-api. That
> effort died in this thread:
> 
>     https://lkml.org/lkml/2015/8/14/3
> 
> ...where we learned that the dependencies on struct page for dma
> mapping are deeper than a PFN_PHYS() conversion for some
> architectures. That was the moment we pivoted to ZONE_DEVICE and
> arranged for a 'struct page' to be available for any persistent memory
> range that needs to be the target of DMA. ZONE_DEVICE enables any
> device-driver that can target "System RAM" to also be able to target
> persistent memory through a DAX mapping.
> 
> Since that time the "page-less" DAX path has continued to mature [1]
> without growing new dependencies on struct page, but at the same time
> continuing to rely on ZONE_DEVICE to satisfy get_user_pages().
> 
> Peer-to-peer DMA appears to be evolving from a niche embedded use case
> to something general purpose platforms will need to comprehend. The
> "map_peer_resource" [2] approach looks to be headed to the same
> destination as the pfn-to-scatterlist effort. It's difficult to avoid
> 'struct page' for describing DMA operations without custom driver
> code.
> 
> With that background, a statement and a question to discuss at LSF/MM:
> 
> General purpose DMA, i.e. any DMA setup through the dma-mapping-api,
> requires pfn_to_page() support across the entire physical address
> range mapped.

Note that in my case it is even worse. The pfn of the page does not
correspond to anything so it need to go through a special function
to find if a page can be mapped for another device and to provide a
valid pfn at which the page can be access by other device.

Basicly the PCIE bar is like a window into the device memory that is
dynamicly remap to specific page of the device memory. Not all device
memory can be expose through PCIE bar because of PCIE issues.

> 
> Is ZONE_DEVICE the proper vehicle for this? We've already seen that it
> collides with platform alignment assumptions [3], and if there's a
> wider effort to rework memory hotplug [4] it seems DMA support should
> be part of the discussion.

Obvioulsy i would like to join this discussion :)

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
