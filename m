Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3105F6B000D
	for <linux-mm@kvack.org>; Thu, 24 May 2018 08:23:30 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k27-v6so1190439wre.23
        for <linux-mm@kvack.org>; Thu, 24 May 2018 05:23:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k5-v6si6563059edc.350.2018.05.24.05.23.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 05:23:25 -0700 (PDT)
Date: Thu, 24 May 2018 14:23:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v2 00/12] get rid of GFP_ZONE_TABLE/BAD
Message-ID: <20180524122323.GH20441@dhcp22.suse.cz>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <20180522183728.GB20441@dhcp22.suse.cz>
 <20180524051919.GA9819@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180524051919.GA9819@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Huaisheng Ye <yehs2007@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, alexander.levin@verizon.com, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>

On Wed 23-05-18 22:19:19, Matthew Wilcox wrote:
> On Tue, May 22, 2018 at 08:37:28PM +0200, Michal Hocko wrote:
> > So why is this any better than the current code. Sure I am not a great
> > fan of GFP_ZONE_TABLE because of how it is incomprehensible but this
> > doesn't look too much better, yet we are losing a check for incompatible
> > gfp flags. The diffstat looks really sound but then you just look and
> > see that the large part is the comment that at least explained the gfp
> > zone modifiers somehow and the debugging code. So what is the selling
> > point?
> 
> I have a plan, but it's not exactly fully-formed yet.
> 
> One of the big problems we have today is that we have a lot of users
> who have constraints on the physical memory they want to allocate,
> but we have very limited abilities to provide them with what they're
> asking for.  The various different ZONEs have different meanings on
> different architectures and are generally a mess.

Agreed.

> If we had eight ZONEs, we could offer:

No, please no more zones. What we have is quite a maint. burden on its
own. Ideally we should only have lowmem, highmem and special/device
zones for directly kernel accessible memory, the one that the kernel
cannot or must not use and completely special memory managed out of
the page allocator. All the remaining constrains should better be
implemented on top.

> ZONE_16M	// 24 bit
> ZONE_256M	// 28 bit
> ZONE_LOWMEM	// CONFIG_32BIT only
> ZONE_4G		// 32 bit
> ZONE_64G	// 36 bit
> ZONE_1T		// 40 bit
> ZONE_ALL	// everything larger
> ZONE_MOVABLE	// movable allocations; no physical address guarantees
> 
> #ifdef CONFIG_64BIT
> #define ZONE_NORMAL	ZONE_ALL
> #else
> #define ZONE_NORMAL	ZONE_LOWMEM
> #endif
> 
> This would cover most driver DMA mask allocations; we could tweak the
> offered zones based on analysis of what people need.

But those already do have aproper API, IIUC. So do we really need to
make our GFP_*/Zone API more complicated than it already is?

> #define GFP_HIGHUSER		(GFP_USER | ZONE_ALL)
> #define GFP_HIGHUSER_MOVABLE	(GFP_USER | ZONE_MOVABLE)
> 
> One other thing I want to see is that fallback from zones happens from
> highest to lowest normally (ie if you fail to allocate in 1T, then you
> try to allocate from 64G), but movable allocations hapen from lowest
> to highest.  So ZONE_16M ends up full of page cache pages which are
> readily evictable for the rare occasions when we need to allocate memory
> below 16MB.
> 
> I'm sure there are lots of good reasons why this won't work, which is
> why I've been hesitant to propose it before now.

I am worried you are playing with a can of worms...
-- 
Michal Hocko
SUSE Labs
