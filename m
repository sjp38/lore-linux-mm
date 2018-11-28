Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF346B4C1C
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 03:56:08 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d3so11718426pgv.23
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 00:56:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t62sor9042148pfa.72.2018.11.28.00.56.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Nov 2018 00:56:06 -0800 (PST)
MIME-Version: 1.0
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <0100016737801f14-84f1265d-4577-4dcf-ad57-90dbc8e0a78f-000000@email.amazonses.com>
 <20181121213853.GL3065@bombadil.infradead.org> <c5ccde1e-a711-ad33-537c-2d5a0bd9edd4@arm.com>
 <20181122082336.GA2049@infradead.org> <555dd63a-0634-6a39-7abc-121e02273cb2@suse.cz>
 <20181126080213.GA17809@infradead.org>
In-Reply-To: <20181126080213.GA17809@infradead.org>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Wed, 28 Nov 2018 16:55:54 +0800
Message-ID: <CANMq1KBYAgoPh37e+BPz7xK4z3jJ4Gm30Gs662+_gTdM8v0QDA@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hch@infradead.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Robin Murphy <robin.murphy@arm.com>, willy@infradead.org, Christoph Lameter <cl@linux.com>, Levin Alexander <Alexander.Levin@microsoft.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Huaisheng Ye <yehs1@lenovo.com>, Tomasz Figa <tfiga@google.com>, Will Deacon <will.deacon@arm.com>, lkml <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Michal Hocko <mhocko@suse.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, David Rientjes <rientjes@google.com>, Matthias Brugger <matthias.bgg@gmail.com>, yingjoe.chen@mediatek.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Nov 26, 2018 at 4:02 PM Christoph Hellwig <hch@infradead.org> wrote:
>
> On Fri, Nov 23, 2018 at 01:23:41PM +0100, Vlastimil Babka wrote:
> > Is this also true for caches created by kmem_cache_create(), that
> > debugging options can result in not respecting the alignment passed to
> > kmem_cache_create()? That would be rather bad, IMHO.
>
> That's what I understood in the discussion.  If not it would make
> our live simpler, but would need to be well document.

>From my experiment, adding `slub_debug` to command line does _not_
break the alignment of kmem_cache_alloc'ed objects.

We do see an increase in slab_size
(/sys/kernel/slab/io-pgtable_armv7s_l2/slab_size), from 1024 to 3072
(probably because slub needs to allocate space on each side for the
red zone/padding, while keeping the alignment?)

> Christoph can probably explain the alignment choices in slub.
>
> >
> > > But I do agree with the sentiment of not wanting to spread GFP_DMA32
> > > futher into the slab allocator.
> >
> > I don't see a problem with GFP_DMA32 for custom caches. Generic
> > kmalloc() would be worse, since it would have to create a new array of
> > kmalloc caches. But that's already ruled out due to the alignment.
>
> True, purely slab probably isn't too bad.
