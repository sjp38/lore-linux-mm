Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 611896B2ECE
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 22:04:49 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q64so3477921pfa.18
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 19:04:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n12sor62435578pgs.60.2018.11.22.19.04.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 19:04:48 -0800 (PST)
MIME-Version: 1.0
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <0100016737801f14-84f1265d-4577-4dcf-ad57-90dbc8e0a78f-000000@email.amazonses.com>
 <20181121213853.GL3065@bombadil.infradead.org> <c5ccde1e-a711-ad33-537c-2d5a0bd9edd4@arm.com>
 <20181122082336.GA2049@infradead.org>
In-Reply-To: <20181122082336.GA2049@infradead.org>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Fri, 23 Nov 2018 11:04:36 +0800
Message-ID: <CANMq1KALUmxkhE8aaYzEbd7YodF1296KdVympOP+2mWVQ9zmDA@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hch@infradead.org
Cc: Robin Murphy <robin.murphy@arm.com>, willy@infradead.org, Christoph Lameter <cl@linux.com>, Levin Alexander <Alexander.Levin@microsoft.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Huaisheng Ye <yehs1@lenovo.com>, Tomasz Figa <tfiga@google.com>, Will Deacon <will.deacon@arm.com>, lkml <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Michal Hocko <mhocko@suse.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, David Rientjes <rientjes@google.com>, Matthias Brugger <matthias.bgg@gmail.com>, yingjoe.chen@mediatek.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Nov 22, 2018 at 4:23 PM Christoph Hellwig <hch@infradead.org> wrote:
>
> On Wed, Nov 21, 2018 at 10:26:26PM +0000, Robin Murphy wrote:
> > TBH, if this DMA32 stuff is going to be contentious we could possibly just
> > rip out the offending kmem_cache - it seemed like good practice for the
> > use-case, but provided kzalloc(SZ_1K, gfp | GFP_DMA32) can be relied upon to
> > give the same 1KB alignment and chance of succeeding as the equivalent
> > kmem_cache_alloc(), then we could quite easily make do with that instead.
>
> Neither is the slab support for kmalloc, not do kmalloc allocations
> have useful alignment apparently (at least if you use slub debug).
>
> But I do agree with the sentiment of not wanting to spread GFP_DMA32
> futher into the slab allocator.
>
> I think you want a simple genalloc allocator for this rather special
> use case.

So I had a look at genalloc, we'd need to add pre-allocated memory
using gen_pool_add [1]. There can be up to 4096 L2 page tables, so we
may need to pre-allocate 4MB of memory (1KB per L2 page table). We
could add chunks on demand, but then it'd be difficult to free them up
(genalloc does not have a "gen_pool_remove" call). So basically if the
full 4MB end up being requested, we'd be stuck with that until the
iommu domain is freed (on the arm64 Mediatek platforms I looked at,
there is only one iommu domain, and it never gets freed).

page_frag would at least have a chance to reclaim those pages (if I
understand Christoph's statement correctly)

Robin: Do you have some ideas of the lifetime/usage of L2 tables? If
they are usually few of them, or if they don't get reclaimed easily,
some on demand genalloc allocation would be ok (or even 4MB allocation
on init, if we're willing to take that hit). If they get allocated and
freed together, maybe page_frag is a better option?

Thanks,

[1] https://www.kernel.org/doc/html/v4.19/core-api/genalloc.html
