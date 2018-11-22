Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE49F6B28F8
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 21:36:14 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c14so4552996pls.21
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 18:36:14 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g7si28726772plq.336.2018.11.21.18.36.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Nov 2018 18:36:13 -0800 (PST)
Date: Wed, 21 Nov 2018 18:35:58 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page
 tables
Message-ID: <20181122023558.GO3065@bombadil.infradead.org>
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <0100016737801f14-84f1265d-4577-4dcf-ad57-90dbc8e0a78f-000000@email.amazonses.com>
 <20181121213853.GL3065@bombadil.infradead.org>
 <c5ccde1e-a711-ad33-537c-2d5a0bd9edd4@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c5ccde1e-a711-ad33-537c-2d5a0bd9edd4@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christopher Lameter <cl@linux.com>, Nicolas Boichat <drinkcat@chromium.org>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com

On Wed, Nov 21, 2018 at 10:26:26PM +0000, Robin Murphy wrote:
> These are IOMMU page tables, rather than CPU ones, so we're already well
> outside arch code - indeed the original motivation of io-pgtable was to be
> entirely independent of the p*d types and arch-specific MM code (this Armv7
> short-descriptor format is already "non-native" when used by drivers in an
> arm64 kernel).

There was quite a lot of explanation missing from this patch description!

> There are various efficiency reasons for using regular kernel memory instead
> of coherent DMA allocations - for the most part it works well, we just have
> the odd corner case like this one where the 32-bit format gets used on
> 64-bit systems such that the tables themselves still need to be allocated
> below 4GB (although the final output address can point at higher memory by
> virtue of the IOMMU in question not implementing permissions and repurposing
> some of those PTE fields as extra address bits).
> 
> TBH, if this DMA32 stuff is going to be contentious we could possibly just
> rip out the offending kmem_cache - it seemed like good practice for the
> use-case, but provided kzalloc(SZ_1K, gfp | GFP_DMA32) can be relied upon to
> give the same 1KB alignment and chance of succeeding as the equivalent
> kmem_cache_alloc(), then we could quite easily make do with that instead.

I think you should look at using the page_frag allocator here.  You can
use whatever GFP_DMA flags you like.
