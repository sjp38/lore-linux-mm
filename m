Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 878BA6B0006
	for <linux-mm@kvack.org>; Thu, 24 May 2018 08:18:59 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x32-v6so897935pld.16
        for <linux-mm@kvack.org>; Thu, 24 May 2018 05:18:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4-v6si16597081pgs.16.2018.05.24.05.18.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 05:18:58 -0700 (PDT)
Date: Thu, 24 May 2018 14:18:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [External]  Re: [RFC PATCH v2 00/12] get rid of
 GFP_ZONE_TABLE/BAD
Message-ID: <20180524121853.GG20441@dhcp22.suse.cz>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <20180522183728.GB20441@dhcp22.suse.cz>
 <HK2PR03MB16847646E90A10E2D48CEA8E926B0@HK2PR03MB1684.apcprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <HK2PR03MB16847646E90A10E2D48CEA8E926B0@HK2PR03MB1684.apcprd03.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng HS1 Ye <yehs1@lenovo.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Wed 23-05-18 16:07:16, Huaisheng HS1 Ye wrote:
> From: Michal Hocko [mailto:mhocko@kernel.org]
> Sent: Wednesday, May 23, 2018 2:37 AM
> > 
> > On Mon 21-05-18 23:20:21, Huaisheng Ye wrote:
> > > From: Huaisheng Ye <yehs1@lenovo.com>
> > >
> > > Replace GFP_ZONE_TABLE and GFP_ZONE_BAD with encoded zone number.
> > >
> > > Delete ___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 from GFP bitmasks,
> > > the bottom three bits of GFP mask is reserved for storing encoded
> > > zone number.
> > >
> > > The encoding method is XOR. Get zone number from enum zone_type,
> > > then encode the number with ZONE_NORMAL by XOR operation.
> > > The goal is to make sure ZONE_NORMAL can be encoded to zero. So,
> > > the compatibility can be guaranteed, such as GFP_KERNEL and GFP_ATOMIC
> > > can be used as before.
> > >
> > > Reserve __GFP_MOVABLE in bit 3, so that it can continue to be used as
> > > a flag. Same as before, __GFP_MOVABLE respresents movable migrate type
> > > for ZONE_DMA, ZONE_DMA32, and ZONE_NORMAL. But when it is enabled with
> > > __GFP_HIGHMEM, ZONE_MOVABLE shall be returned instead of ZONE_HIGHMEM.
> > > __GFP_ZONE_MOVABLE is created to realize it.
> > >
> > > With this patch, just enabling __GFP_MOVABLE and __GFP_HIGHMEM is not
> > > enough to get ZONE_MOVABLE from gfp_zone. All callers should use
> > > GFP_HIGHUSER_MOVABLE or __GFP_ZONE_MOVABLE directly to achieve that.
> > >
> > > Decode zone number directly from bottom three bits of flags in gfp_zone.
> > > The theory of encoding and decoding is,
> > >         A ^ B ^ B = A
> > 
> > So why is this any better than the current code. Sure I am not a great
> > fan of GFP_ZONE_TABLE because of how it is incomprehensible but this
> > doesn't look too much better, yet we are losing a check for incompatible
> > gfp flags. The diffstat looks really sound but then you just look and
> > see that the large part is the comment that at least explained the gfp
> > zone modifiers somehow and the debugging code. So what is the selling
> > point?
> 
> Dear Michal,
> 
> Let me try to reply your questions.
> Exactly, GFP_ZONE_TABLE is too complicated. I think there are two advantages
> from the series of patches.
> 
> 1. XOR operation is simple and efficient, GFP_ZONE_TABLE/BAD need to do twice
> shift operations, the first is for getting a zone_type and the second is for
> checking the to be returned type is a correct or not. But with these patch XOR
> operation just needs to use once. Because the bottom 3 bits of GFP bitmask have
> been used to represent the encoded zone number, we can say there is no bad zone
> number if all callers could use it without buggy way. Of course, the returned
> zone type in gfp_zone needs to be no more than ZONE_MOVABLE.

But you are losing the ability to check for wrong usage. And it seems
that the sad reality is that the existing code do screw up.

> 2. GFP_ZONE_TABLE has limit with the amount of zone types. Current GFP_ZONE_TABLE
> is 32 bits, in general, there are 4 zone types for most ofX86_64 platform, they
> are ZONE_DMA, ZONE_DMA32, ZONE_NORMAL and ZONE_MOVABLE. If we want to expand the
> amount of zone types to larger than 4, the zone shift should be 3.

But we do not want to expand the number of zones IMHO. The existing zoo
is quite a maint. pain.
 
That being said. I am not saying that I am in love with GFP_ZONE_TABLE.
It always makes my head explode when I look there but it seems to work
with the current code and it is optimized for it. If you want to change
this then you should make sure you describe reasons _why_ this is an
improvement. And I would argue that "we can have more zones" is a
relevant one.
-- 
Michal Hocko
SUSE Labs
