Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8106B055D
	for <linux-mm@kvack.org>; Thu, 17 May 2018 23:04:02 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g5-v6so3736047ioc.4
        for <linux-mm@kvack.org>; Thu, 17 May 2018 20:04:02 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.16])
        by mx.google.com with ESMTPS id i139-v6si5605944ioi.280.2018.05.17.20.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 20:04:00 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [PATCH v1] include/linux/gfp.h: getting rid of
 GFP_ZONE_TABLE/BAD
Date: Fri, 18 May 2018 03:03:35 +0000
Message-ID: <HK2PR03MB1684A5EE7432CAF9763608D992900@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525968625-40825-1-git-send-email-yehs1@lenovo.com>
 <20180510163023.GB30442@bombadil.infradead.org>
 <HK2PR03MB16843E14AD56B3E546D9F52D929F0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180511132613.GA30263@bombadil.infradead.org>
In-Reply-To: <20180511132613.GA30263@bombadil.infradead.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> From: Matthew Wilcox [mailto:willy@infradead.org]
> Sent: Friday, May 11, 2018 9:26 PM
> On Fri, May 11, 2018 at 03:24:34AM +0000, Huaisheng HS1 Ye wrote:
> > > From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On B=
ehalf Of
> Matthew
> > > Wilcox
> > > On Fri, May 11, 2018 at 12:10:25AM +0800, Huaisheng Ye wrote:
> > > > -#define __GFP_DMA	((__force gfp_t)___GFP_DMA)
> > > > -#define __GFP_HIGHMEM	((__force gfp_t)___GFP_HIGHMEM)
> > > > -#define __GFP_DMA32	((__force gfp_t)___GFP_DMA32)
> > > > +#define __GFP_DMA	((__force gfp_t)OPT_ZONE_DMA ^ ZONE_NORMAL)
> > > > +#define __GFP_HIGHMEM	((__force gfp_t)ZONE_MOVABLE ^ ZONE_NORMAL)
> > > > +#define __GFP_DMA32	((__force gfp_t)OPT_ZONE_DMA32 ^ ZONE_NORMAL)
> > >
> > > No, you've made gfp_zone even more complex than it already is.
> > > If you can't use OPT_ZONE_HIGHMEM here, then this is a waste of time.
> > >
> > Dear Matthew,
> >
> > The reason why I don't use OPT_ZONE_HIGHMEM for __GFP_HIGHMEM	 directly=
 is that,
> for x86_64 platform there is no CONFIG_HIGHMEM, so OPT_ZONE_HIGHMEM shall=
 always be
> equal to ZONE_NORMAL.
>=20
> Right.  On 64-bit platforms, if somebody asks for HIGHMEM, they should
> get NORMAL pages.
>=20
> > For gfp_zone it is impossible to distinguish the meaning of lowest 3 bi=
ts in flags.
> How can gfp_zone to understand it comes from OPT_ZONE_HIGHMEM or ZONE_NOR=
MAL?
> > And the most pained thing is that, if __GFP_HIGHMEM with movable flag e=
nabled, it
> means that ZONE_MOVABLE shall be returned.
> > That is different from ZONE_DMA, ZONE_DMA32 and ZONE_NORMAL.
>=20
> The point of this exercise is to actually encode the zone number in
> the bottom bits of the GFP flags instead of something which has to be
> interpreted into a zone number.  When somebody sets __GFP_MOVABLE, they
> should also be setting ZONE_MOVABLE:
>=20
> -#define __GFP_MOVABLE   ((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE=
 allowed */
> +#define __GFP_MOVABLE   ((__force gfp_t)(___GFP_MOVABLE | (ZONE_MOVABLE =
^ ZONE_NORMAL)))
>=20
> One thing that does need to change is:
>=20
> -#define GFP_HIGHUSER_MOVABLE    (GFP_HIGHUSER | __GFP_MOVABLE)
> +#define GFP_HIGHUSER_MOVABLE    (GFP_USER | __GFP_MOVABLE)
>=20
> otherwise we'll be OR'ing ZONE_MOVABLE and ZONE_HIGHMEM together.

Dear Matthew,

After thinking it over and over, I am afraid there is something needs to be=
 discussed here.
You know current X86_64 config file of kernel doesn't enable CONFIG_HIGHMEM=
, that is to say from this below,

#define __GFP_HIGHMEM	((__force gfp_t)OPT_ZONE_HIGHMEM ^ ZONE_NORMAL)

__GFP_HIGHMEM should equal to 0b0000, same as the value of ZONE_NORMAL gets=
 encoded.
If we define __GFP_MOVABLE like this,

#define __GFP_MOVABLE   ((__force gfp_t)(___GFP_MOVABLE | (ZONE_MOVABLE ^ Z=
ONE_NORMAL)))

Just like your introduced before, with this modification when somebody sets=
 __GFP_MOVABLE, they should also be setting ZONE_MOVABLE.
That brings us a problem, current mm (GFP_ZONE_TABLE) treats __GFP_MOVABLE =
as ZONE_NORMAL with movable policy, if without __GFP_HIGHMEM.
The mm shall allocate a page or pages from migrate movable list of ZONE_NOR=
MAL's freelist.
So that conflicts with this modification. And I have checked current kernel=
, some of function directly set parameter gfp like this.

For example, in fs/ext4/extents.c __read_extent_tree_block,
	bh =3D sb_getblk_gfp(inode->i_sb, pblk, __GFP_MOVABLE | GFP_NOFS);

for these situations, I think only modify GFP_HIGHUSER_MOVABLE is not enoug=
h. I am preparing a workaround to solve this in the V2 patch.
Later I will upload it to email loop.

Sincerely,
Huaisheng Ye


> > I was thinking...
> > Whether it is possible to use other judgement condition to decide OPT_Z=
ONE_HIGHMEM
> or ZONE_MOVABLE shall be returned from gfp_zone.
> >
> > Sincerely,
> > Huaisheng Ye
> >
> >
> > > >  static inline enum zone_type gfp_zone(gfp_t flags)
> > > >  {
> > > >  	enum zone_type z;
> > > > -	int bit =3D (__force int) (flags & GFP_ZONEMASK);
> > > > +	z =3D ((__force unsigned int)flags & ___GFP_ZONE_MASK) ^ ZONE_NOR=
MAL;
> > > > +
> > > > +	if (z > OPT_ZONE_HIGHMEM)
> > > > +		z =3D OPT_ZONE_HIGHMEM +
> > > > +			!!((__force unsigned int)flags & ___GFP_MOVABLE);
> > > >
> > > > -	z =3D (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
> > > > -					 ((1 << GFP_ZONES_SHIFT) - 1);
> > > > -	VM_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> > > > +	VM_BUG_ON(z > ZONE_MOVABLE);
> > > >  	return z;
> > > >  }
> >
