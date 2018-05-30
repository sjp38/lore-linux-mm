Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 778976B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 05:12:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t195-v6so12125415wmt.9
        for <linux-mm@kvack.org>; Wed, 30 May 2018 02:12:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u6-v6si646680edp.400.2018.05.30.02.12.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 May 2018 02:12:07 -0700 (PDT)
Date: Wed, 30 May 2018 11:12:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [External]  Re: [RFC PATCH v2 00/12] get rid of
 GFP_ZONE_TABLE/BAD
Message-ID: <20180530091206.GB27180@dhcp22.suse.cz>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <20180522183728.GB20441@dhcp22.suse.cz>
 <HK2PR03MB16847646E90A10E2D48CEA8E926B0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180524121853.GG20441@dhcp22.suse.cz>
 <HK2PR03MB1684ED6EC6859A88A196DC0C92690@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180528133733.GF27180@dhcp22.suse.cz>
 <HK2PR03MB1684C44F2408F3927B1A21BC926C0@HK2PR03MB1684.apcprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <HK2PR03MB1684C44F2408F3927B1A21BC926C0@HK2PR03MB1684.apcprd03.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng HS1 Ye <yehs1@lenovo.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Wed 30-05-18 09:02:13, Huaisheng HS1 Ye wrote:
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On Behalf Of Michal Hocko
> Sent: Monday, May 28, 2018 9:38 PM
> > > In my opinion, originally there shouldn't be such many wrong
> > > combinations of these bottom 3 bits. For any user, whether or
> > > driver and fs, they should make a decision that which zone is they
> > > preferred. Matthew's idea is great, because with it the user must
> > > offer an unambiguous flag to gfp zone bits.
> > 
> > Well, I would argue that those shouldn't really care about any zones at
> > all. All they should carea bout is whether they really need a low mem
> > zone (aka directly accessible to the kernel), highmem or they are the
> > allocation is generally movable. Mixing zones into the picture just
> > makes the whole thing more complicated and error prone.
> 
> Dear Michal,
> 
> I don't quite understand that. I think those, mostly drivers, need to
> get the correct zone they want. ZONE_DMA32 is an example, if drivers can be
> satisfied with a low mem zone, why they mark the gfp flags as
> 'GFP_KERNEL|__GFP_DMA32'?
> GFP_KERNEL is enough to make sure a directly accessible low mem, but it is
> obvious that they want to get a DMA accessible zone below 4G.

They want a specific pfn range. Not a _zone_. Zone is an MM abstraction
to manage memory. And not a great one as the time has shown. We have
moved away from the per-zone reclaim because it just turned out to be
problematic. Leaking this abstraction to users was a mistake IMHO. It
was surely convenient but we can clearly see it was just confusing and
many users just got it wrong.

I do agree with Christoph in other email that the proper way for DMA
users is to use the existing DMA API which is more towards what they
need. Set a restriction on dma-able memory ranges.
-- 
Michal Hocko
SUSE Labs
