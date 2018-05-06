Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9896B0010
	for <linux-mm@kvack.org>; Sun,  6 May 2018 14:55:38 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r9-v6so12395886pgp.12
        for <linux-mm@kvack.org>; Sun, 06 May 2018 11:55:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f11-v6si20722086plo.352.2018.05.06.11.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 06 May 2018 11:55:36 -0700 (PDT)
Date: Sun, 6 May 2018 11:55:32 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [External]  Re: [PATCH 2/3] include/linux/gfp.h: use unsigned
 int in gfp_zone
Message-ID: <20180506185532.GA13604@bombadil.infradead.org>
References: <1525416729-108201-1-git-send-email-yehs1@lenovo.com>
 <1525416729-108201-3-git-send-email-yehs1@lenovo.com>
 <20180504133533.GR4535@dhcp22.suse.cz>
 <20180504154004.GB29829@bombadil.infradead.org>
 <HK2PR03MB168459A1C4FB2B7D3E1F6A4A92840@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180506134814.GB7362@bombadil.infradead.org>
 <HK2PR03MB168447008C658172FFDA402992840@HK2PR03MB1684.apcprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <HK2PR03MB168447008C658172FFDA402992840@HK2PR03MB1684.apcprd03.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng HS1 Ye <yehs1@lenovo.com>
Cc: Michal Hocko <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, May 06, 2018 at 04:17:06PM +0000, Huaisheng HS1 Ye wrote:
> Upload my current patch and testing platform info for reference. This patch has been tested 
> on a two sockets platform.

Thank you!

> It works, but some drivers or subsystem shall be modified to fit
> these new type __GFP flags.
> They use these flags directly to realize bit manipulations like this
> below.
> 
> eg.
> swiotlb-xen.c (drivers\xen):    flags &= ~(__GFP_DMA | __GFP_HIGHMEM);
> extent_io.c (fs\btrfs):         mask &= ~(__GFP_DMA32|__GFP_HIGHMEM);
> 
> Because of these flags have been encoded within this patch, the
> above operations can cause problem.

I don't think this actually causes problems.  At least, no additional
problems.  These users will successfully clear __GFP_DMA and __GFP_HIGHMEM
no matter what values GFP_DMA and GFP_HIGHMEM have; the only problem will
be if someone calls them with a zone type they're not expecting (eg DMA32
for the first one or DMA for the second; or MOVABLE for either of them).
The thing is, they're already buggy in those circumstances.

>   */
> -#define __GFP_DMA      ((__force gfp_t)___GFP_DMA)
> -#define __GFP_HIGHMEM  ((__force gfp_t)___GFP_HIGHMEM)
> -#define __GFP_DMA32    ((__force gfp_t)___GFP_DMA32)
> +#define __GFP_DMA      ((__force gfp_t)OPT_ZONE_DMA ^ ZONE_NORMAL)
> +#define __GFP_HIGHMEM  ((__force gfp_t)ZONE_MOVABLE ^ ZONE_NORMAL)
> +#define __GFP_DMA32    ((__force gfp_t)OPT_ZONE_DMA32 ^ ZONE_NORMAL)
>  #define __GFP_MOVABLE  ((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
[...]
>  static inline enum zone_type gfp_zone(gfp_t flags)
> {
>         enum zone_type z;
> -       int bit = (__force int) (flags & GFP_ZONEMASK);
> +       z = ((__force unsigned int)flags & ___GFP_ZONE_MASK) ^ ZONE_NORMAL;
> 
> -       z = (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
> -                                        ((1 << GFP_ZONES_SHIFT) - 1);
> -       VM_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> +       if (z > OPT_ZONE_HIGHMEM) {
> +               z = OPT_ZONE_HIGHMEM +
> +                       !!((__force unsigned int)flags & ___GFP_MOVABLE);
> +       }
>         return z;
>  }

How about:

+#define __GFP_HIGHMEM  ((__force gfp_t)OPT_ZONE_HIGHMEM ^ ZONE_NORMAL)
-#define __GFP_MOVABLE  ((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
+#define __GFP_MOVABLE  ((__force gfp_t)ZONE_MOVABLE ^ ZONE_NORMAL | \
+					___GFP_MOVABLE)

Then I think you can just make it:

static inline enum zone_type gfp_zone(gfp_t flags)
{
	return ((__force int)flags & ___GFP_ZONE_MASK) ^ ZONE_NORMAL;
}

> @@ -370,42 +368,15 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
>  #error GFP_ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
>  #endif

You should be able to delete GFP_ZONES_SHIFT too.
