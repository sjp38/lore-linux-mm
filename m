Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41A056B02A8
	for <linux-mm@kvack.org>; Fri, 11 May 2018 09:26:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b64-v6so2944473pfl.13
        for <linux-mm@kvack.org>; Fri, 11 May 2018 06:26:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x5-v6si2695407pgo.564.2018.05.11.06.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 11 May 2018 06:26:16 -0700 (PDT)
Date: Fri, 11 May 2018 06:26:13 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [External]  Re: [PATCH v1] include/linux/gfp.h: getting rid of
 GFP_ZONE_TABLE/BAD
Message-ID: <20180511132613.GA30263@bombadil.infradead.org>
References: <1525968625-40825-1-git-send-email-yehs1@lenovo.com>
 <20180510163023.GB30442@bombadil.infradead.org>
 <HK2PR03MB16843E14AD56B3E546D9F52D929F0@HK2PR03MB1684.apcprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <HK2PR03MB16843E14AD56B3E546D9F52D929F0@HK2PR03MB1684.apcprd03.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng HS1 Ye <yehs1@lenovo.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, May 11, 2018 at 03:24:34AM +0000, Huaisheng HS1 Ye wrote:
> > From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On Behalf Of Matthew
> > Wilcox
> > On Fri, May 11, 2018 at 12:10:25AM +0800, Huaisheng Ye wrote:
> > > -#define __GFP_DMA	((__force gfp_t)___GFP_DMA)
> > > -#define __GFP_HIGHMEM	((__force gfp_t)___GFP_HIGHMEM)
> > > -#define __GFP_DMA32	((__force gfp_t)___GFP_DMA32)
> > > +#define __GFP_DMA	((__force gfp_t)OPT_ZONE_DMA ^ ZONE_NORMAL)
> > > +#define __GFP_HIGHMEM	((__force gfp_t)ZONE_MOVABLE ^ ZONE_NORMAL)
> > > +#define __GFP_DMA32	((__force gfp_t)OPT_ZONE_DMA32 ^ ZONE_NORMAL)
> > 
> > No, you've made gfp_zone even more complex than it already is.
> > If you can't use OPT_ZONE_HIGHMEM here, then this is a waste of time.
> > 
> Dear Matthew,
> 
> The reason why I don't use OPT_ZONE_HIGHMEM for __GFP_HIGHMEM	 directly is that, for x86_64 platform there is no CONFIG_HIGHMEM, so OPT_ZONE_HIGHMEM shall always be equal to ZONE_NORMAL.

Right.  On 64-bit platforms, if somebody asks for HIGHMEM, they should
get NORMAL pages.

> For gfp_zone it is impossible to distinguish the meaning of lowest 3 bits in flags. How can gfp_zone to understand it comes from OPT_ZONE_HIGHMEM or ZONE_NORMAL?
> And the most pained thing is that, if __GFP_HIGHMEM with movable flag enabled, it means that ZONE_MOVABLE shall be returned.
> That is different from ZONE_DMA, ZONE_DMA32 and ZONE_NORMAL.

The point of this exercise is to actually encode the zone number in
the bottom bits of the GFP flags instead of something which has to be
interpreted into a zone number.  When somebody sets __GFP_MOVABLE, they
should also be setting ZONE_MOVABLE:

-#define __GFP_MOVABLE   ((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
+#define __GFP_MOVABLE   ((__force gfp_t)(___GFP_MOVABLE | (ZONE_MOVABLE ^ ZONE_NORMAL)))

One thing that does need to change is:

-#define GFP_HIGHUSER_MOVABLE    (GFP_HIGHUSER | __GFP_MOVABLE)
+#define GFP_HIGHUSER_MOVABLE    (GFP_USER | __GFP_MOVABLE)

otherwise we'll be OR'ing ZONE_MOVABLE and ZONE_HIGHMEM together.

> I was thinking...
> Whether it is possible to use other judgement condition to decide OPT_ZONE_HIGHMEM or ZONE_MOVABLE shall be returned from gfp_zone.
> 
> Sincerely,
> Huaisheng Ye
> 
> 
> > >  static inline enum zone_type gfp_zone(gfp_t flags)
> > >  {
> > >  	enum zone_type z;
> > > -	int bit = (__force int) (flags & GFP_ZONEMASK);
> > > +	z = ((__force unsigned int)flags & ___GFP_ZONE_MASK) ^ ZONE_NORMAL;
> > > +
> > > +	if (z > OPT_ZONE_HIGHMEM)
> > > +		z = OPT_ZONE_HIGHMEM +
> > > +			!!((__force unsigned int)flags & ___GFP_MOVABLE);
> > >
> > > -	z = (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
> > > -					 ((1 << GFP_ZONES_SHIFT) - 1);
> > > -	VM_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> > > +	VM_BUG_ON(z > ZONE_MOVABLE);
> > >  	return z;
> > >  }
> 
