Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1226B0272
	for <linux-mm@kvack.org>; Thu, 24 May 2018 01:19:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w7-v6so301295pfd.9
        for <linux-mm@kvack.org>; Wed, 23 May 2018 22:19:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v5-v6si19212015pfe.63.2018.05.23.22.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 22:19:24 -0700 (PDT)
Date: Wed, 23 May 2018 22:19:19 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH v2 00/12] get rid of GFP_ZONE_TABLE/BAD
Message-ID: <20180524051919.GA9819@bombadil.infradead.org>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <20180522183728.GB20441@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180522183728.GB20441@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Huaisheng Ye <yehs2007@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, alexander.levin@verizon.com, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>

On Tue, May 22, 2018 at 08:37:28PM +0200, Michal Hocko wrote:
> So why is this any better than the current code. Sure I am not a great
> fan of GFP_ZONE_TABLE because of how it is incomprehensible but this
> doesn't look too much better, yet we are losing a check for incompatible
> gfp flags. The diffstat looks really sound but then you just look and
> see that the large part is the comment that at least explained the gfp
> zone modifiers somehow and the debugging code. So what is the selling
> point?

I have a plan, but it's not exactly fully-formed yet.

One of the big problems we have today is that we have a lot of users
who have constraints on the physical memory they want to allocate,
but we have very limited abilities to provide them with what they're
asking for.  The various different ZONEs have different meanings on
different architectures and are generally a mess.

If we had eight ZONEs, we could offer:

ZONE_16M	// 24 bit
ZONE_256M	// 28 bit
ZONE_LOWMEM	// CONFIG_32BIT only
ZONE_4G		// 32 bit
ZONE_64G	// 36 bit
ZONE_1T		// 40 bit
ZONE_ALL	// everything larger
ZONE_MOVABLE	// movable allocations; no physical address guarantees

#ifdef CONFIG_64BIT
#define ZONE_NORMAL	ZONE_ALL
#else
#define ZONE_NORMAL	ZONE_LOWMEM
#endif

This would cover most driver DMA mask allocations; we could tweak the
offered zones based on analysis of what people need.

#define GFP_HIGHUSER		(GFP_USER | ZONE_ALL)
#define GFP_HIGHUSER_MOVABLE	(GFP_USER | ZONE_MOVABLE)

One other thing I want to see is that fallback from zones happens from
highest to lowest normally (ie if you fail to allocate in 1T, then you
try to allocate from 64G), but movable allocations hapen from lowest
to highest.  So ZONE_16M ends up full of page cache pages which are
readily evictable for the rare occasions when we need to allocate memory
below 16MB.

I'm sure there are lots of good reasons why this won't work, which is
why I've been hesitant to propose it before now.
