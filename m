Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 388EE6B06E7
	for <linux-mm@kvack.org>; Sat, 12 May 2018 07:35:09 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id g12-v6so8034522qtj.22
        for <linux-mm@kvack.org>; Sat, 12 May 2018 04:35:09 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.208])
        by mx.google.com with ESMTPS id n55-v6si5369428qtf.313.2018.05.12.04.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 May 2018 04:35:08 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [PATCH v1] include/linux/gfp.h: getting rid of
 GFP_ZONE_TABLE/BAD
Date: Sat, 12 May 2018 11:35:00 +0000
Message-ID: <HK2PR03MB1684BC9802BC2E5C1BF2DC74929E0@HK2PR03MB1684.apcprd03.prod.outlook.com>
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
> Sent: Friday, May 11, 2018 9:26 PM>=20
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
I am afraid we couldn't do that, because __GFP_MOVABLE would be used potent=
ially with other __GFPs like __GFP_DMA and __GFP_DMA32.
Let's go back to the previous example.
We assume ZONE_DMA equals to 0, and ZONE_DMA32 equals to 1. After encoding =
with ZONE_NORMAL (which equals to 2), we could get that.

#define __GFP_DMA		((__force gfp_t)OPT_ZONE_DMA ^ ZONE_NORMAL)
#define __GFP_DMA32	((__force gfp_t)OPT_ZONE_DMA32 ^ ZONE_NORMAL)
__GPF_DMA	=3D 0b 0010
__GPF_DMA32	=3D 0b 0011

We assume ZONE_MOVABLE equals to 3,
#define __GFP_MOVABLE   ((__force gfp_t)(___GFP_MOVABLE | (ZONE_MOVABLE ^ Z=
ONE_NORMAL)))
__GFP_MOVABLE =3D 0b 1001

If we OR'ing __GFP_MOVABLE and either __GFP_DMA or __GFP_DMA32, we could ge=
t same result as '0b 1011'.
This is unacceptable, because inline function gfp_zone couldn't distinguish=
 that is a request of ZONE_DMA or ZONE_DMA32 from parameter flags.

Once more, I think if we want to encode ZONE_MOVABLE to __GFP_MOVABLE, then=
 the operation of __GFP_MOVABLE OR'ing with any other __GFP* would have ris=
k.

Sincerely,
Huaisheng Ye

> One thing that does need to change is:
>=20
> -#define GFP_HIGHUSER_MOVABLE    (GFP_HIGHUSER | __GFP_MOVABLE)
> +#define GFP_HIGHUSER_MOVABLE    (GFP_USER | __GFP_MOVABLE)
>=20
> otherwise we'll be OR'ing ZONE_MOVABLE and ZONE_HIGHMEM together.
>=20
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
