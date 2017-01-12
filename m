Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 394DE6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 17:43:05 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id a194so5782579oib.5
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 14:43:05 -0800 (PST)
Received: from mail-ot0-x232.google.com (mail-ot0-x232.google.com. [2607:f8b0:4003:c0f::232])
        by mx.google.com with ESMTPS id 61si4184549otp.77.2017.01.12.14.43.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 14:43:04 -0800 (PST)
Received: by mail-ot0-x232.google.com with SMTP id 65so3675120otq.2
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 14:43:04 -0800 (PST)
MIME-Version: 1.0
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 12 Jan 2017 14:43:03 -0800
Message-ID: <CAPcyv4hWNL7=MmnUj65A+gz=eHAnUrVzqV+24QiNQDW--ag8WQ@mail.gmail.com>
Subject: [LSF/MM TOPIC] Memory hotplug, ZONE_DEVICE, and the future of struct page
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-block@vger.kernel.org
Cc: Stephen Bates <sbates@raithlin.com>, Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

Back when we were first attempting to support DMA for DAX mappings of
persistent memory the plan was to forgo 'struct page' completely and
develop a pfn-to-scatterlist capability for the dma-mapping-api. That
effort died in this thread:

    https://lkml.org/lkml/2015/8/14/3

...where we learned that the dependencies on struct page for dma
mapping are deeper than a PFN_PHYS() conversion for some
architectures. That was the moment we pivoted to ZONE_DEVICE and
arranged for a 'struct page' to be available for any persistent memory
range that needs to be the target of DMA. ZONE_DEVICE enables any
device-driver that can target "System RAM" to also be able to target
persistent memory through a DAX mapping.

Since that time the "page-less" DAX path has continued to mature [1]
without growing new dependencies on struct page, but at the same time
continuing to rely on ZONE_DEVICE to satisfy get_user_pages().

Peer-to-peer DMA appears to be evolving from a niche embedded use case
to something general purpose platforms will need to comprehend. The
"map_peer_resource" [2] approach looks to be headed to the same
destination as the pfn-to-scatterlist effort. It's difficult to avoid
'struct page' for describing DMA operations without custom driver
code.

With that background, a statement and a question to discuss at LSF/MM:

General purpose DMA, i.e. any DMA setup through the dma-mapping-api,
requires pfn_to_page() support across the entire physical address
range mapped.

Is ZONE_DEVICE the proper vehicle for this? We've already seen that it
collides with platform alignment assumptions [3], and if there's a
wider effort to rework memory hotplug [4] it seems DMA support should
be part of the discussion.

---

This topic focuses on the mechanism to enable pfn_to_page() for an
arbitrary physical address range, and the proposed peer-to-peer DMA
topic [5] touches on the userspace presentation of this mechanism. I
might be good to combine these topics if there's interest? In any
event, I'm interested in both as well Michal's concern about memory
hotplug in general.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2016-November/007672.html
[2]: http://www.spinics.net/lists/linux-pci/msg44560.html
[3]: https://lkml.org/lkml/2016/12/1/740
[4]: http://www.spinics.net/lists/linux-mm/msg119369.html
[5]: http://marc.info/?l=linux-mm&m=148156541804940&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
