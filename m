Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C13906B0266
	for <linux-mm@kvack.org>; Fri,  4 May 2018 13:50:16 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id y62so11623879qkb.15
        for <linux-mm@kvack.org>; Fri, 04 May 2018 10:50:16 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.195])
        by mx.google.com with ESMTPS id l66si6509495qke.363.2018.05.04.10.50.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 10:50:15 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [PATCH 2/3] include/linux/gfp.h: use unsigned int
 in gfp_zone
Date: Fri, 4 May 2018 17:50:00 +0000
Message-ID: <HK2PR03MB1684D51A63D851A9BED42C3A92860@HK2PR03MB1684.apcprd03.prod.outlook.com>
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

OK, it is a great pleasure for me, let me think about how it works in detai=
l.

Sincerely,
Huaisheng, Ye
OS Team | Lenovo
