Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7EF6B000C
	for <linux-mm@kvack.org>; Sun,  6 May 2018 05:32:29 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g138so19001205qke.22
        for <linux-mm@kvack.org>; Sun, 06 May 2018 02:32:29 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.203])
        by mx.google.com with ESMTPS id c24-v6si210979qtg.360.2018.05.06.02.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 May 2018 02:32:28 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [PATCH 2/3] include/linux/gfp.h: use unsigned int
 in gfp_zone
Date: Sun, 6 May 2018 09:32:15 +0000
Message-ID: <HK2PR03MB168459A1C4FB2B7D3E1F6A4A92840@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525416729-108201-1-git-send-email-yehs1@lenovo.com>
 <1525416729-108201-3-git-send-email-yehs1@lenovo.com>
 <20180504133533.GR4535@dhcp22.suse.cz>
 <20180504154004.GB29829@bombadil.infradead.org>
In-Reply-To: <20180504154004.GB29829@bombadil.infradead.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


> On Fri, May 04, 2018 at 03:35:33PM +0200, Michal Hocko wrote:
> > On Fri 04-05-18 14:52:08, Huaisheng Ye wrote:
> > > Suggest using unsigned int instead of int for bit within gfp_zone.
> > > @@ -401,7 +401,7 @@ static inline bool gfpflags_allow_blocking(const
> gfp_t gfp_flags)
> > >  static inline enum zone_type gfp_zone(gfp_t flags)
> > >  {
> > >  	enum zone_type z;
> > > -	int bit =3D (__force int) (flags & GFP_ZONEMASK);
> > > +	unsigned int bit =3D (__force unsigned int) (flags & GFP_ZONEMASK);
> > >
> > >  	z =3D (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
> > >  					 ((1 << GFP_ZONES_SHIFT) - 1);
>=20
> That reminds me.  I wanted to talk about getting rid of GFP_ZONE_TABLE.
> Instead, we should encode the zone number in the bottom three bits of
> the gfp mask, while preserving the rules that ZONE_NORMAL gets encoded
> as zero (so GFP_KERNEL | GFP_HIGHMEM continues to work) and also leaving
> __GFP_MOVABLE in bit 3 so that it can continue to be used as a flag.
>=20
> So I was thinking ...
>=20
> -#define ___GFP_DMA             0x01u
> -#define ___GFP_HIGHMEM         0x02u
> -#define ___GFP_DMA32           0x04u
> +#define ___GFP_ZONE_MASK	0x07u
>=20
> #define __GFP_DMA	((__force gfp_t)OPT_ZONE_DMA ^ ZONE_NORMAL)
> #define __GFP_HIGHMEM	((__force gfp_t)OPT_ZONE_HIGHMEM ^
> ZONE_NORMAL)
> #define __GFP_DMA32	((__force gfp_t)OPT_ZONE_DMA32 ^
> ZONE_NORMAL)
> #define __GFP_MOVABLE	((__force gfp_t)ZONE_MOVABLE ^ ZONE_NORMAL | \
> 			 ___GFP_MOVABLE)
> #define GFP_ZONEMASK	((__force gfp_t)___GFP_ZONE_MASK |
> ___GFP_MOVABLE)
>=20
> Then we can delete GFP_ZONE_TABLE and GFP_ZONE_BAD.
> gfp_zone simply becomes:
>=20
> static inline enum zone_type gfp_zone(gfp_t flags)
> {
> 	return ((__force int)flags & ___GFP_ZONE_MASK) ^ ZONE_NORMAL;
> }
>=20
> Huaisheng Ye, would you have time to investigate this idea?

Dear Matthew and Michal,

This idea is great, we can replace GFP_ZONE_TABLE and GFP_ZONE_BAD with it.
I have realized it preliminarily based on your code and tested it on a 2 so=
ckets platform. Fortunately, we got a positive test result.

I made some adjustments for __GFP_HIGHMEM, this flag is special than others=
, because the return result of gfp_zone has two possibilities, which depend=
 on ___GFP_MOVABLE has been enabled or disabled.
When ___GFP_MOVABLE has been enabled, ZONE_MOVABLE shall be returned. When =
disabled, OPT_ZONE_HIGHMEM shall be used.

#define __GFP_DMA	((__force gfp_t)OPT_ZONE_DMA ^ ZONE_NORMAL)
#define __GFP_HIGHMEM	((__force gfp_t)ZONE_MOVABLE ^ ZONE_NORMAL)
#define __GFP_DMA32	((__force gfp_t)OPT_ZONE_DMA32 ^ ZONE_NORMAL)
#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allo=
wed */
#define GFP_ZONEMASK	((__force gfp_t)___GFP_ZONE_MASK | ___GFP_MOVABLE)

The present situation is that, based on this change, the bits of flags, __G=
FP_DMA and __GFP_HIGHMEM and __GFP_DMA32, have been encoded.
That is totally different from existing code, you know in kernel scope, the=
re are many drivers or subsystems use these flags directly to realize bit m=
anipulations like this below,
swiotlb-xen.c (drivers\xen):	flags &=3D ~(__GFP_DMA | __GFP_HIGHMEM);
extent_io.c (fs\btrfs):			mask &=3D ~(__GFP_DMA32|__GFP_HIGHMEM);

Because of these flags have been encoded, the above operations can cause pr=
oblem.
I am trying to get a solution to resolve it. Any progress will be reported.

Sincerely,
Huaisheng Ye
Linux kernel | Lenovo
