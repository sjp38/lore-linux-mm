Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 474276B0266
	for <linux-mm@kvack.org>; Mon,  7 May 2018 17:27:45 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t74-v6so10374623pgc.14
        for <linux-mm@kvack.org>; Mon, 07 May 2018 14:27:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n2-v6si18243325plk.433.2018.05.07.14.27.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 May 2018 14:27:43 -0700 (PDT)
Date: Mon, 7 May 2018 23:25:01 +0200
From: David Sterba <dsterba@suse.cz>
Subject: Re: [External]  Re: [PATCH 2/3] include/linux/gfp.h: use unsigned
 int in gfp_zone
Message-ID: <20180507212500.bdphwfhk55w6vlbb@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1525416729-108201-1-git-send-email-yehs1@lenovo.com>
 <1525416729-108201-3-git-send-email-yehs1@lenovo.com>
 <20180504133533.GR4535@dhcp22.suse.cz>
 <20180504154004.GB29829@bombadil.infradead.org>
 <HK2PR03MB168459A1C4FB2B7D3E1F6A4A92840@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180506134814.GB7362@bombadil.infradead.org>
 <HK2PR03MB168447008C658172FFDA402992840@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180506185532.GA13604@bombadil.infradead.org>
 <HK2PR03MB1684BF10B3B515BFABD35F8B929B0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180507184410.GA12361@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180507184410.GA12361@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Huaisheng HS1 Ye <yehs1@lenovo.com>, Michal Hocko <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, May 07, 2018 at 11:44:10AM -0700, Matthew Wilcox wrote:
> On Mon, May 07, 2018 at 05:16:50PM +0000, Huaisheng HS1 Ye wrote:
> > I hope it couldn't cause problem, but based on my analyzation it has the potential to go wrong if users still use the flags as usual, which are __GFP_DMA, __GFP_DMA32 and __GFP_HIGHMEM.
> > Let me take an example with my testing platform, these logics are much abstract, an example will be helpful.
> > 
> > There is a two sockets X86_64 server, No HIGHMEM and it has 16 + 16GB memories.
> > Its zone types shall be like this below,
> > 
> > ZONE_DMA		0		0b0000
> > ZONE_DMA32		1		0b0001
> > ZONE_NORMAL		2		0b0010
> > (OPT_ZONE_HIGHMEM)	2		0b0010
> > ZONE_MOVABLE		3		0b0011
> > ZONE_DEVICE		4		0b0100 (virtual zone)
> > __MAX_NR_ZONES	5
> > 
> > __GFP_DMA	= ZONE_DMA ^ ZONE_NORMAL= 0b0010
> > __GFP_DMA32	= ZONE_DMA32 ^ ZONE_NORMAL= 0b0011
> > __GFP_HIGHMEM = OPT_ZONE_HIGHMEM ^ ZONE_NORMAL = 0b0000
> > __GFP_MOVABLE	= ZONE_MOVABLE ^ ZONE_NORMAL | ___GFP_MOVABLE = 0b1001
> > 
> > Eg.
> > If a driver uses flags like this below,
> > Step 1:
> > gfp_mask  |  __GFP_DMA32;	
> > (0b 0000		|	0b 0011	= 0b 0011)
> > gfp_mask's low four bits shall equal to 0011, assuming no __GFP_MOVABLE
> > 
> > Step 2:
> > gfp_mask  & ~__GFP_DMA;	
> > (0b 0011	 & ~0b0010   = 0b0001)
> > gfp_mask's low four bits shall equal to 0001 now, then when it enter gfp_zone(),
> > 
> > return ((__force int)flags & ___GFP_ZONE_MASK) ^ ZONE_NORMAL;
> > (0b0001 ^ 0b0010 = 0b0011)
> > You know 0011 means that ZONE_MOVABLE will be returned.
> > In this case, error can be found, because gfp_mask needs to get ZONE_DMA32 originally.
> > But with existing GFP_ZONE_TABLE/BAD, it is correct. Because the bits are way of 0x1, 0x2, 0x4, 0x8
> 
> Yes, I understand your point here.  My point was that this was already a bug;
> the caller shouldn't simply be clearing __GFP_DMA; they really mean to clear
> all of the GFP_ZONE bits so that they allocate from ZONE_NORMAL.  And for
> that, they should be using ~GFP_ZONEMASK
> 
> Unless they already know, of course.  For example, this one in
> arch/x86/mm/pgtable.c is fine:
> 
>         if (strcmp(arg, "nohigh") == 0)
>                 __userpte_alloc_gfp &= ~__GFP_HIGHMEM;
> 
> because it knows that __userpte_alloc_gfp can only have __GFP_HIGHMEM set.
> 
> But something like btrfs should almost certainly be using ~GFP_ZONEMASK.

Agreed, the direct use of __GFP_DMA32 was added in 3ba7ab220e8918176c6f
to substitute GFP_NOFS, so the allocation flags are less restrictive but
still acceptable for allocation from slab.

The requirement from btrfs is to avoid highmem, the 'must be acceptable
for slab' requirement is more MM internal and should have been hidden
under some opaque flag mask. There was no strong need for that at the
time.
