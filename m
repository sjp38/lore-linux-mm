Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A6B906B27D9
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 10:16:38 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id m13so14316850pls.15
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 07:16:38 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y3-v6si49572146pfe.42.2018.11.22.07.16.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Nov 2018 07:16:37 -0800 (PST)
Date: Thu, 22 Nov 2018 07:16:32 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page
 tables
Message-ID: <20181122151632.GP3065@bombadil.infradead.org>
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <0100016737801f14-84f1265d-4577-4dcf-ad57-90dbc8e0a78f-000000@email.amazonses.com>
 <20181121213853.GL3065@bombadil.infradead.org>
 <c5ccde1e-a711-ad33-537c-2d5a0bd9edd4@arm.com>
 <20181122023558.GO3065@bombadil.infradead.org>
 <20181122082602.GB2049@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122082602.GB2049@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Robin Murphy <robin.murphy@arm.com>, Michal Hocko <mhocko@suse.com>, Will Deacon <will.deacon@arm.com>, Levin Alexander <Alexander.Levin@microsoft.com>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>, Nicolas Boichat <drinkcat@chromium.org>, Huaisheng Ye <yehs1@lenovo.com>, David Rientjes <rientjes@google.com>, yingjoe.chen@mediatek.com, Vlastimil Babka <vbabka@suse.cz>, Tomasz Figa <tfiga@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Matthias Brugger <matthias.bgg@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, iommu@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

On Thu, Nov 22, 2018 at 12:26:02AM -0800, Christoph Hellwig wrote:
> On Wed, Nov 21, 2018 at 06:35:58PM -0800, Matthew Wilcox wrote:
> > I think you should look at using the page_frag allocator here.  You can
> > use whatever GFP_DMA flags you like.
> 
> So I actually tries to use page_frag to solve the XFS unaligned kmalloc
> allocations problem, and I don't think it is the right hammer for this
> nail (or any other nail outside of networking).
> 
> The problem with the page_frag allocator is that it never reuses
> fragments returned to the page, but only only frees the page once all
> fragments are freed.  This means that if you have some long(er) term
> allocations you are effectively creating memory leaks.

Yes, your allocations from the page_frag allocator have to have similar
lifetimes.  I thought that would be ideal for XFS though; as I understood
the problem, these were per-IO allocations, and IOs to the same filesystem
tend to take roughly the same amount of time.  Sure, in an error case,
some IOs will take a long time before timing out, but it should be OK
to have pages unavailable during that time in these rare situations.
What am I missing?
