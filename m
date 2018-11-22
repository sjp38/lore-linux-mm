Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EECE36B2BDD
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 10:19:45 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id p9so3274083pfj.3
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 07:19:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t63si3837576pgd.78.2018.11.22.07.19.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Nov 2018 07:19:44 -0800 (PST)
Date: Thu, 22 Nov 2018 07:19:41 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page
 tables
Message-ID: <20181122151941.GA2681@infradead.org>
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <0100016737801f14-84f1265d-4577-4dcf-ad57-90dbc8e0a78f-000000@email.amazonses.com>
 <20181121213853.GL3065@bombadil.infradead.org>
 <c5ccde1e-a711-ad33-537c-2d5a0bd9edd4@arm.com>
 <20181122023558.GO3065@bombadil.infradead.org>
 <20181122082602.GB2049@infradead.org>
 <20181122151632.GP3065@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122151632.GP3065@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@infradead.org>, Robin Murphy <robin.murphy@arm.com>, Michal Hocko <mhocko@suse.com>, Will Deacon <will.deacon@arm.com>, Levin Alexander <Alexander.Levin@microsoft.com>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>, Nicolas Boichat <drinkcat@chromium.org>, Huaisheng Ye <yehs1@lenovo.com>, David Rientjes <rientjes@google.com>, yingjoe.chen@mediatek.com, Vlastimil Babka <vbabka@suse.cz>, Tomasz Figa <tfiga@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Matthias Brugger <matthias.bgg@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, iommu@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

On Thu, Nov 22, 2018 at 07:16:32AM -0800, Matthew Wilcox wrote:
> Yes, your allocations from the page_frag allocator have to have similar
> lifetimes.  I thought that would be ideal for XFS though; as I understood
> the problem, these were per-IO allocations, and IOs to the same filesystem
> tend to take roughly the same amount of time.  Sure, in an error case,
> some IOs will take a long time before timing out, but it should be OK
> to have pages unavailable during that time in these rare situations.
> What am I missing?

No, thee are allocations for meatada buffers, which can stay around
for a long time.  Worse still that depends on usage, so one buffer
allocated from ma page might basically stay around forever, while
another one might get reclaimed very quickly.
