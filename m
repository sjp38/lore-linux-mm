Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC76F6B0003
	for <linux-mm@kvack.org>; Mon, 28 May 2018 12:13:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x23-v6so7594357pfm.7
        for <linux-mm@kvack.org>; Mon, 28 May 2018 09:13:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5-v6si30248346pfd.73.2018.05.28.09.13.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 09:13:49 -0700 (PDT)
Date: Mon, 28 May 2018 15:37:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [External]  Re: [RFC PATCH v2 00/12] get rid of
 GFP_ZONE_TABLE/BAD
Message-ID: <20180528133733.GF27180@dhcp22.suse.cz>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <20180522183728.GB20441@dhcp22.suse.cz>
 <HK2PR03MB16847646E90A10E2D48CEA8E926B0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180524121853.GG20441@dhcp22.suse.cz>
 <HK2PR03MB1684ED6EC6859A88A196DC0C92690@HK2PR03MB1684.apcprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <HK2PR03MB1684ED6EC6859A88A196DC0C92690@HK2PR03MB1684.apcprd03.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng HS1 Ye <yehs1@lenovo.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Fri 25-05-18 09:43:09, Huaisheng HS1 Ye wrote:
> From: Michal Hocko [mailto:mhocko@kernel.org]
> Sent: Thursday, May 24, 2018 8:19 PM> 
> > > Let me try to reply your questions.
> > > Exactly, GFP_ZONE_TABLE is too complicated. I think there are two advantages
> > > from the series of patches.
> > >
> > > 1. XOR operation is simple and efficient, GFP_ZONE_TABLE/BAD need to do twice
> > > shift operations, the first is for getting a zone_type and the second is for
> > > checking the to be returned type is a correct or not. But with these patch XOR
> > > operation just needs to use once. Because the bottom 3 bits of GFP bitmask have
> > > been used to represent the encoded zone number, we can say there is no bad zone
> > > number if all callers could use it without buggy way. Of course, the returned
> > > zone type in gfp_zone needs to be no more than ZONE_MOVABLE.
> > 
> > But you are losing the ability to check for wrong usage. And it seems
> > that the sad reality is that the existing code do screw up.
> 
> In my opinion, originally there shouldn't be such many wrong
> combinations of these bottom 3 bits. For any user, whether or
> driver and fs, they should make a decision that which zone is they
> preferred. Matthew's idea is great, because with it the user must
> offer an unambiguous flag to gfp zone bits.

Well, I would argue that those shouldn't really care about any zones at
all. All they should carea bout is whether they really need a low mem
zone (aka directly accessible to the kernel), highmem or they are the
allocation is generally movable. Mixing zones into the picture just
makes the whole thing more complicated and error prone.
[...]
> > That being said. I am not saying that I am in love with GFP_ZONE_TABLE.
> > It always makes my head explode when I look there but it seems to work
> > with the current code and it is optimized for it. If you want to change
> > this then you should make sure you describe reasons _why_ this is an
> > improvement. And I would argue that "we can have more zones" is a
> > relevant one.
> 
> Yes, GFP_ZONE_TABLE is too complicated. The patches have 4 advantages as below.
> 
> * The address zone modifiers have new operation method, that is, user should decide which zone is preferred at first, then give the encoded zone number to bottom 3 bits in GFP mask. That is much direct and clear than before.
> 
> * No bad zone combination, because user should choose just one address zone modifier always.
> * Better performance and efficiency, current gfp_zone has to take shifting operation twice for GFP_ZONE_TABLE and GFP_ZONE_BAD. With these patches, gfp_zone() just needs one XOR.
> * Up to 8 zones can be used. At least it isn't a disadvantage, right?

This should be a part of the changelog. Please note that you should
provide some number if you claim performance benefits. The complexity
will always be subjective.
-- 
Michal Hocko
SUSE Labs
