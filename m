Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 547D46B0008
	for <linux-mm@kvack.org>; Wed, 23 May 2018 12:07:36 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id s12-v6so18324360ioc.20
        for <linux-mm@kvack.org>; Wed, 23 May 2018 09:07:36 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.3])
        by mx.google.com with ESMTPS id n15-v6si2372199ith.18.2018.05.23.09.07.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 09:07:35 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [RFC PATCH v2 00/12] get rid of
 GFP_ZONE_TABLE/BAD
Date: Wed, 23 May 2018 16:07:16 +0000
Message-ID: <HK2PR03MB16847646E90A10E2D48CEA8E926B0@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <20180522183728.GB20441@dhcp22.suse.cz>
In-Reply-To: <20180522183728.GB20441@dhcp22.suse.cz>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

From: Michal Hocko [mailto:mhocko@kernel.org]
Sent: Wednesday, May 23, 2018 2:37 AM
>=20
> On Mon 21-05-18 23:20:21, Huaisheng Ye wrote:
> > From: Huaisheng Ye <yehs1@lenovo.com>
> >
> > Replace GFP_ZONE_TABLE and GFP_ZONE_BAD with encoded zone number.
> >
> > Delete ___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 from GFP bitmasks,
> > the bottom three bits of GFP mask is reserved for storing encoded
> > zone number.
> >
> > The encoding method is XOR. Get zone number from enum zone_type,
> > then encode the number with ZONE_NORMAL by XOR operation.
> > The goal is to make sure ZONE_NORMAL can be encoded to zero. So,
> > the compatibility can be guaranteed, such as GFP_KERNEL and GFP_ATOMIC
> > can be used as before.
> >
> > Reserve __GFP_MOVABLE in bit 3, so that it can continue to be used as
> > a flag. Same as before, __GFP_MOVABLE respresents movable migrate type
> > for ZONE_DMA, ZONE_DMA32, and ZONE_NORMAL. But when it is enabled with
> > __GFP_HIGHMEM, ZONE_MOVABLE shall be returned instead of ZONE_HIGHMEM.
> > __GFP_ZONE_MOVABLE is created to realize it.
> >
> > With this patch, just enabling __GFP_MOVABLE and __GFP_HIGHMEM is not
> > enough to get ZONE_MOVABLE from gfp_zone. All callers should use
> > GFP_HIGHUSER_MOVABLE or __GFP_ZONE_MOVABLE directly to achieve that.
> >
> > Decode zone number directly from bottom three bits of flags in gfp_zone=
.
> > The theory of encoding and decoding is,
> >         A ^ B ^ B =3D A
>=20
> So why is this any better than the current code. Sure I am not a great
> fan of GFP_ZONE_TABLE because of how it is incomprehensible but this
> doesn't look too much better, yet we are losing a check for incompatible
> gfp flags. The diffstat looks really sound but then you just look and
> see that the large part is the comment that at least explained the gfp
> zone modifiers somehow and the debugging code. So what is the selling
> point?

Dear Michal,

Let me try to reply your questions.
Exactly, GFP_ZONE_TABLE is too complicated. I think there are two advantage=
s
from the series of patches.

1. XOR operation is simple and efficient, GFP_ZONE_TABLE/BAD need to do twi=
ce
shift operations, the first is for getting a zone_type and the second is fo=
r
checking the to be returned type is a correct or not. But with these patch =
XOR
operation just needs to use once. Because the bottom 3 bits of GFP bitmask =
have
been used to represent the encoded zone number, we can say there is no bad =
zone
number if all callers could use it without buggy way. Of course, the return=
ed
zone type in gfp_zone needs to be no more than ZONE_MOVABLE.

2. GFP_ZONE_TABLE has limit with the amount of zone types. Current GFP_ZONE=
_TABLE
is 32 bits, in general, there are 4 zone types for most ofX86_64 platform, =
they
are ZONE_DMA, ZONE_DMA32, ZONE_NORMAL and ZONE_MOVABLE. If we want to expan=
d the
amount of zone types to larger than 4, the zone shift should be 3. That is =
to say,
a 32 bits zone table is not enough to store all zone types.
And the most painful thing is that, current GFP bitmasks' space is quite
space-constrained it only have four ___GFP_XXX could be used as below,

	#define ___GFP_DMA		0x01u
	#define ___GFP_HIGHMEM	0x02u
	#define ___GFP_DMA32		0x04u
	(___GFP_NORMAL equals to 0x00)

If we use the implementation of these patches, there is a maximum of 8 zone=
 types
could be used. The method of encoding and decoding is quite simple and user=
s could
have an intuitive feeling for this as below, and the most important is that=
, there
is no BAD zone types eventually.

	A ^ B ^ B =3D A

And by the way, our v3 patches are ready, but the smtp of Gmail is quite un=
stable
for some firewall reason in my side, I will try to resend them ASAP.

Sincerely,
Huaisheng Ye
