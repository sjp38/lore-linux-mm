Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1FE6B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 11:40:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t20-v6so6266150pgu.23
        for <linux-mm@kvack.org>; Fri, 04 May 2018 08:40:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w65si16331821pfa.18.2018.05.04.08.40.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 08:40:10 -0700 (PDT)
Date: Fri, 4 May 2018 08:40:04 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/3] include/linux/gfp.h: use unsigned int in gfp_zone
Message-ID: <20180504154004.GB29829@bombadil.infradead.org>
References: <1525416729-108201-1-git-send-email-yehs1@lenovo.com>
 <1525416729-108201-3-git-send-email-yehs1@lenovo.com>
 <20180504133533.GR4535@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180504133533.GR4535@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Huaisheng Ye <yehs1@lenovo.com>, akpm@linux-foundation.org, linux-mm@kvack.org, vbabka@suse.cz, mgorman@techsingularity.net, pasha.tatashin@oracle.com, alexander.levin@verizon.com, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, colyli@suse.de, chengnt@lenovo.com, linux-kernel@vger.kernel.org

On Fri, May 04, 2018 at 03:35:33PM +0200, Michal Hocko wrote:
> On Fri 04-05-18 14:52:08, Huaisheng Ye wrote:
> > Suggest using unsigned int instead of int for bit within gfp_zone.
> > @@ -401,7 +401,7 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
> >  static inline enum zone_type gfp_zone(gfp_t flags)
> >  {
> >  	enum zone_type z;
> > -	int bit = (__force int) (flags & GFP_ZONEMASK);
> > +	unsigned int bit = (__force unsigned int) (flags & GFP_ZONEMASK);
> >  
> >  	z = (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
> >  					 ((1 << GFP_ZONES_SHIFT) - 1);

That reminds me.  I wanted to talk about getting rid of GFP_ZONE_TABLE.
Instead, we should encode the zone number in the bottom three bits of
the gfp mask, while preserving the rules that ZONE_NORMAL gets encoded
as zero (so GFP_KERNEL | GFP_HIGHMEM continues to work) and also leaving
__GFP_MOVABLE in bit 3 so that it can continue to be used as a flag.

So I was thinking ...

-#define ___GFP_DMA             0x01u
-#define ___GFP_HIGHMEM         0x02u
-#define ___GFP_DMA32           0x04u
+#define ___GFP_ZONE_MASK	0x07u

#define __GFP_DMA	((__force gfp_t)OPT_ZONE_DMA ^ ZONE_NORMAL)
#define __GFP_HIGHMEM	((__force gfp_t)OPT_ZONE_HIGHMEM ^ ZONE_NORMAL)
#define __GFP_DMA32	((__force gfp_t)OPT_ZONE_DMA32 ^ ZONE_NORMAL)
#define __GFP_MOVABLE	((__force gfp_t)ZONE_MOVABLE ^ ZONE_NORMAL | \
			 ___GFP_MOVABLE)
#define GFP_ZONEMASK	((__force gfp_t)___GFP_ZONE_MASK | ___GFP_MOVABLE)

Then we can delete GFP_ZONE_TABLE and GFP_ZONE_BAD.
gfp_zone simply becomes:

static inline enum zone_type gfp_zone(gfp_t flags)
{
	return ((__force int)flags & ___GFP_ZONE_MASK) ^ ZONE_NORMAL;
}

Huaisheng Ye, would you have time to investigate this idea?
