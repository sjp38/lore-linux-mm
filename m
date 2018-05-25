Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38AE56B0003
	for <linux-mm@kvack.org>; Fri, 25 May 2018 05:43:27 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id l204-v6so12649318ita.1
        for <linux-mm@kvack.org>; Fri, 25 May 2018 02:43:27 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.2])
        by mx.google.com with ESMTPS id k78-v6si569536iod.76.2018.05.25.02.43.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 02:43:24 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [RFC PATCH v2 00/12] get rid of
 GFP_ZONE_TABLE/BAD
Date: Fri, 25 May 2018 09:43:09 +0000
Message-ID: <HK2PR03MB1684ED6EC6859A88A196DC0C92690@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <20180522183728.GB20441@dhcp22.suse.cz>
 <HK2PR03MB16847646E90A10E2D48CEA8E926B0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180524121853.GG20441@dhcp22.suse.cz>
In-Reply-To: <20180524121853.GG20441@dhcp22.suse.cz>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

From: Michal Hocko [mailto:mhocko@kernel.org]
Sent: Thursday, May 24, 2018 8:19 PM>=20
> > Let me try to reply your questions.
> > Exactly, GFP_ZONE_TABLE is too complicated. I think there are two advan=
tages
> > from the series of patches.
> >
> > 1. XOR operation is simple and efficient, GFP_ZONE_TABLE/BAD need to do=
 twice
> > shift operations, the first is for getting a zone_type and the second i=
s for
> > checking the to be returned type is a correct or not. But with these pa=
tch XOR
> > operation just needs to use once. Because the bottom 3 bits of GFP bitm=
ask have
> > been used to represent the encoded zone number, we can say there is no =
bad zone
> > number if all callers could use it without buggy way. Of course, the re=
turned
> > zone type in gfp_zone needs to be no more than ZONE_MOVABLE.
>=20
> But you are losing the ability to check for wrong usage. And it seems
> that the sad reality is that the existing code do screw up.

In my opinion, originally there shouldn't be such many wrong combinations o=
f these bottom 3 bits. For any user, whether or driver and fs, they should =
make a decision that which zone is they preferred. Matthew's idea is great,=
 because with it the user must offer an unambiguous flag to gfp zone bits.

Ideally, before any user wants to modify the address zone modifier, they sh=
ould clear it firstly, then ORing the GFP zone flag which comes from the zo=
ne they prefer.
With these patches, we can loudly announce that, the bottom 3 bits of zone =
mask couldn't accept internal ORing operations.
The operations like __GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM is illegal. The=
 current GFP_ZONE_TABLE is precisely the root of this problem, that is __GF=
P_DMA, __GFP_DMA32 and __GFP_HIGHMEM are formatted as 0x1, 0x2 and 0x4.

>=20
> > 2. GFP_ZONE_TABLE has limit with the amount of zone types. Current GFP_=
ZONE_TABLE
> > is 32 bits, in general, there are 4 zone types for most ofX86_64 platfo=
rm, they
> > are ZONE_DMA, ZONE_DMA32, ZONE_NORMAL and ZONE_MOVABLE. If we want to e=
xpand the
> > amount of zone types to larger than 4, the zone shift should be 3.
>=20
> But we do not want to expand the number of zones IMHO. The existing zoo
> is quite a maint. pain.
>=20
> That being said. I am not saying that I am in love with GFP_ZONE_TABLE.
> It always makes my head explode when I look there but it seems to work
> with the current code and it is optimized for it. If you want to change
> this then you should make sure you describe reasons _why_ this is an
> improvement. And I would argue that "we can have more zones" is a
> relevant one.

Yes, GFP_ZONE_TABLE is too complicated. The patches have 4 advantages as be=
low.

* The address zone modifiers have new operation method, that is, user shoul=
d decide which zone is preferred at first, then give the encoded zone numbe=
r to bottom 3 bits in GFP mask. That is much direct and clear than before.

* No bad zone combination, because user should choose just one address zone=
 modifier always.
* Better performance and efficiency, current gfp_zone has to take shifting =
operation twice for GFP_ZONE_TABLE and GFP_ZONE_BAD. With these patches, gf=
p_zone() just needs one XOR.
* Up to 8 zones can be used. At least it isn't a disadvantage, right?

Sincerely,
Huaisheng Ye
