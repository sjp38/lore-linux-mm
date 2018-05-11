Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE64A6B0653
	for <linux-mm@kvack.org>; Thu, 10 May 2018 23:24:48 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id h15-v6so3388262qkh.3
        for <linux-mm@kvack.org>; Thu, 10 May 2018 20:24:48 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.202])
        by mx.google.com with ESMTPS id l63-v6si2167531qkd.341.2018.05.10.20.24.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 20:24:47 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [PATCH v1] include/linux/gfp.h: getting rid of
 GFP_ZONE_TABLE/BAD
Date: Fri, 11 May 2018 03:24:34 +0000
Message-ID: <HK2PR03MB16843E14AD56B3E546D9F52D929F0@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525968625-40825-1-git-send-email-yehs1@lenovo.com>
 <20180510163023.GB30442@bombadil.infradead.org>
In-Reply-To: <20180510163023.GB30442@bombadil.infradead.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On Behal=
f Of Matthew
> Wilcox
> On Fri, May 11, 2018 at 12:10:25AM +0800, Huaisheng Ye wrote:
> > -#define __GFP_DMA	((__force gfp_t)___GFP_DMA)
> > -#define __GFP_HIGHMEM	((__force gfp_t)___GFP_HIGHMEM)
> > -#define __GFP_DMA32	((__force gfp_t)___GFP_DMA32)
> > +#define __GFP_DMA	((__force gfp_t)OPT_ZONE_DMA ^ ZONE_NORMAL)
> > +#define __GFP_HIGHMEM	((__force gfp_t)ZONE_MOVABLE ^ ZONE_NORMAL)
> > +#define __GFP_DMA32	((__force gfp_t)OPT_ZONE_DMA32 ^ ZONE_NORMAL)
>=20
> No, you've made gfp_zone even more complex than it already is.
> If you can't use OPT_ZONE_HIGHMEM here, then this is a waste of time.
>=20
Dear Matthew,

The reason why I don't use OPT_ZONE_HIGHMEM for __GFP_HIGHMEM	 directly is =
that, for x86_64 platform there is no CONFIG_HIGHMEM, so OPT_ZONE_HIGHMEM s=
hall always be equal to ZONE_NORMAL.

For gfp_zone it is impossible to distinguish the meaning of lowest 3 bits i=
n flags. How can gfp_zone to understand it comes from OPT_ZONE_HIGHMEM or Z=
ONE_NORMAL?
And the most pained thing is that, if __GFP_HIGHMEM with movable flag enabl=
ed, it means that ZONE_MOVABLE shall be returned.
That is different from ZONE_DMA, ZONE_DMA32 and ZONE_NORMAL.

I was thinking...
Whether it is possible to use other judgement condition to decide OPT_ZONE_=
HIGHMEM or ZONE_MOVABLE shall be returned from gfp_zone.

Sincerely,
Huaisheng Ye


> >  static inline enum zone_type gfp_zone(gfp_t flags)
> >  {
> >  	enum zone_type z;
> > -	int bit =3D (__force int) (flags & GFP_ZONEMASK);
> > +	z =3D ((__force unsigned int)flags & ___GFP_ZONE_MASK) ^ ZONE_NORMAL;
> > +
> > +	if (z > OPT_ZONE_HIGHMEM)
> > +		z =3D OPT_ZONE_HIGHMEM +
> > +			!!((__force unsigned int)flags & ___GFP_MOVABLE);
> >
> > -	z =3D (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
> > -					 ((1 << GFP_ZONES_SHIFT) - 1);
> > -	VM_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> > +	VM_BUG_ON(z > ZONE_MOVABLE);
> >  	return z;
> >  }
