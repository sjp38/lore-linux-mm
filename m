Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A106C6B27B3
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 16:39:14 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id h10so11017275plk.12
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 13:39:14 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h127si20757330pfe.204.2018.11.21.13.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Nov 2018 13:39:13 -0800 (PST)
Date: Wed, 21 Nov 2018 13:38:53 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page
 tables
Message-ID: <20181121213853.GL3065@bombadil.infradead.org>
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <0100016737801f14-84f1265d-4577-4dcf-ad57-90dbc8e0a78f-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0100016737801f14-84f1265d-4577-4dcf-ad57-90dbc8e0a78f-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Nicolas Boichat <drinkcat@chromium.org>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com

On Wed, Nov 21, 2018 at 06:20:02PM +0000, Christopher Lameter wrote:
> On Sun, 11 Nov 2018, Nicolas Boichat wrote:
> 
> > This is a follow-up to the discussion in [1], to make sure that the page
> > tables allocated by iommu/io-pgtable-arm-v7s are contained within 32-bit
> > physical address space.
> 
> Page tables? This means you need a page frame? Why go through the slab
> allocators?

Because this particular architecture has sub-page-size PMD page tables.
We desperately need to hoist page table allocation out of the architectures;
there're a bunch of different implementations and they're mostly bad,
one way or another.

For each level of page table we generally have three cases:

1. single page
2. sub-page, naturally aligned
3. multiple pages, naturally aligned

for 1 and 3, the page allocator will do just fine.
for 2, we should have a per-MM page_frag allocator.  s390 already has
something like this, although it's more complicated.  ppc also has
something a little more complex for the cases when it's configured with
a 64k page size but wants to use a 4k page table entry.

I'd like x86 to be able to simply do:

#define pte_alloc_one(mm, addr)	page_alloc_table(mm, addr, 0)
#define pmd_alloc_one(mm, addr)	page_alloc_table(mm, addr, 0)
#define pud_alloc_one(mm, addr)	page_alloc_table(mm, addr, 0)
#define p4d_alloc_one(mm, addr)	page_alloc_table(mm, addr, 0)

An architecture with 4k page size and needing a 16k PMD would do:

#define pmd_alloc_one(mm, addr) page_alloc_table(mm, addr, 2)

while an architecture with a 64k page size needing a 4k PTE would do:

#define ARCH_PAGE_TABLE_FRAG
#define pte_alloc_one(mm, addr) pagefrag_alloc_table(mm, addr, 4096)

I haven't had time to work on this, but perhaps someone with a problem
that needs fixing would like to, instead of burying yet another awful
implementation away in arch/ somewhere.
