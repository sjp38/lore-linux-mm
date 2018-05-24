Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40D4E6B0007
	for <linux-mm@kvack.org>; Thu, 24 May 2018 11:29:47 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y16-v6so1727262wrp.19
        for <linux-mm@kvack.org>; Thu, 24 May 2018 08:29:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h15-v6si1762474edr.264.2018.05.24.08.29.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 08:29:45 -0700 (PDT)
Date: Thu, 24 May 2018 17:29:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v2 00/12] get rid of GFP_ZONE_TABLE/BAD
Message-ID: <20180524152943.GA11881@dhcp22.suse.cz>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <20180522183728.GB20441@dhcp22.suse.cz>
 <20180524051919.GA9819@bombadil.infradead.org>
 <20180524122323.GH20441@dhcp22.suse.cz>
 <20180524151818.GA21245@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180524151818.GA21245@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Huaisheng Ye <yehs2007@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, alexander.levin@verizon.com, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>

On Thu 24-05-18 08:18:18, Matthew Wilcox wrote:
> On Thu, May 24, 2018 at 02:23:23PM +0200, Michal Hocko wrote:
> > > If we had eight ZONEs, we could offer:
> > 
> > No, please no more zones. What we have is quite a maint. burden on its
> > own. Ideally we should only have lowmem, highmem and special/device
> > zones for directly kernel accessible memory, the one that the kernel
> > cannot or must not use and completely special memory managed out of
> > the page allocator. All the remaining constrains should better be
> > implemented on top.
> 
> I believe you when you say that they're a maintenance pain.  Is that
> maintenance pain because they're so specialised?

Well, it used to be LRU balancing which is gone with the node reclaim
but that brings new challenges. Now as you say their meaning is not
really clear to users and that leads to bugs left and right.

> ie if we had more,
> could we solve our pain by making them more generic?

Well, if you have more you will consume more bits in the struct pages,
right?

[...]

> > But those already do have aproper API, IIUC. So do we really need to
> > make our GFP_*/Zone API more complicated than it already is?
> 
> I don't want to change the driver API (setting the DMA mask, etc),
> but we don't actually have a good API to the page allocator for the
> implementation of dma_alloc_foo() to request pages.  More or less,
> architectures do:
> 
> 	if (mask < 4GB)
> 		alloc_page(GFP_DMA)
> 	else if (mask < 64EB)
> 		alloc_page(GFP_DMA32)
> 	else
> 		alloc_page(GFP_HIGHMEM)
> 
> it more-or-less sucks that the devices with 28-bit DMA limits are forced
> to allocate from the low 16MB when they're perfectly capable of using the
> low 256MB.

Do we actually care all that much about those? If yes then we should
probably follow the ZONE_DMA (x86) path and use a CMA region for them.
I mean most devices should be good with very limited addressability or
below 4G, no?
-- 
Michal Hocko
SUSE Labs
