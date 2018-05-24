Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7D296B000A
	for <linux-mm@kvack.org>; Thu, 24 May 2018 11:18:21 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x32-v6so1158044pld.16
        for <linux-mm@kvack.org>; Thu, 24 May 2018 08:18:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p4-v6si2239960pli.573.2018.05.24.08.18.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 24 May 2018 08:18:20 -0700 (PDT)
Date: Thu, 24 May 2018 08:18:18 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH v2 00/12] get rid of GFP_ZONE_TABLE/BAD
Message-ID: <20180524151818.GA21245@bombadil.infradead.org>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <20180522183728.GB20441@dhcp22.suse.cz>
 <20180524051919.GA9819@bombadil.infradead.org>
 <20180524122323.GH20441@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180524122323.GH20441@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Huaisheng Ye <yehs2007@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, alexander.levin@verizon.com, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>

On Thu, May 24, 2018 at 02:23:23PM +0200, Michal Hocko wrote:
> > If we had eight ZONEs, we could offer:
> 
> No, please no more zones. What we have is quite a maint. burden on its
> own. Ideally we should only have lowmem, highmem and special/device
> zones for directly kernel accessible memory, the one that the kernel
> cannot or must not use and completely special memory managed out of
> the page allocator. All the remaining constrains should better be
> implemented on top.

I believe you when you say that they're a maintenance pain.  Is that
maintenance pain because they're so specialised?  ie if we had more,
could we solve our pain by making them more generic?

> > ZONE_16M	// 24 bit
> > ZONE_256M	// 28 bit
> > ZONE_LOWMEM	// CONFIG_32BIT only
> > ZONE_4G		// 32 bit
> > ZONE_64G	// 36 bit
> > ZONE_1T		// 40 bit
> > ZONE_ALL	// everything larger
> > ZONE_MOVABLE	// movable allocations; no physical address guarantees
> > 
> > #ifdef CONFIG_64BIT
> > #define ZONE_NORMAL	ZONE_ALL
> > #else
> > #define ZONE_NORMAL	ZONE_LOWMEM
> > #endif
> > 
> > This would cover most driver DMA mask allocations; we could tweak the
> > offered zones based on analysis of what people need.
> 
> But those already do have aproper API, IIUC. So do we really need to
> make our GFP_*/Zone API more complicated than it already is?

I don't want to change the driver API (setting the DMA mask, etc),
but we don't actually have a good API to the page allocator for the
implementation of dma_alloc_foo() to request pages.  More or less,
architectures do:

	if (mask < 4GB)
		alloc_page(GFP_DMA)
	else if (mask < 64EB)
		alloc_page(GFP_DMA32)
	else
		alloc_page(GFP_HIGHMEM)

it more-or-less sucks that the devices with 28-bit DMA limits are forced
to allocate from the low 16MB when they're perfectly capable of using the
low 256MB.  Sure, my proposal doesn't help 27 or 26 bit DMA mask devices,
but those are pretty rare.

I'm sure you don't need reminding what a mess vmalloc_32 is, and the
implementation of saa7146_vmalloc_build_pgtable() just hurts.

> > #define GFP_HIGHUSER		(GFP_USER | ZONE_ALL)
> > #define GFP_HIGHUSER_MOVABLE	(GFP_USER | ZONE_MOVABLE)
> > 
> > One other thing I want to see is that fallback from zones happens from
> > highest to lowest normally (ie if you fail to allocate in 1T, then you
> > try to allocate from 64G), but movable allocations hapen from lowest
> > to highest.  So ZONE_16M ends up full of page cache pages which are
> > readily evictable for the rare occasions when we need to allocate memory
> > below 16MB.
> > 
> > I'm sure there are lots of good reasons why this won't work, which is
> > why I've been hesitant to propose it before now.
> 
> I am worried you are playing with a can of worms...

Yes.  Me too.
