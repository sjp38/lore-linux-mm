Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 918CA6B73F6
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 06:01:18 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 143so10938907pgc.3
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 03:01:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 38sor27192421pld.67.2018.12.05.03.01.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 03:01:17 -0800 (PST)
MIME-Version: 1.0
References: <20181205054828.183476-1-drinkcat@chromium.org>
 <20181205054828.183476-3-drinkcat@chromium.org> <20181205095557.GE1286@dhcp22.suse.cz>
In-Reply-To: <20181205095557.GE1286@dhcp22.suse.cz>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Wed, 5 Dec 2018 19:01:03 +0800
Message-ID: <CANMq1KCnpSUKoz83LcEgAkhCi8QVPH715xtgdQD23r-tYusrPw@mail.gmail.com>
Subject: Re: [PATCH v4 2/3] mm: Add support for kmem caches in DMA32 zone
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org, Matthew Wilcox <willy@infradead.org>

On Wed, Dec 5, 2018 at 5:56 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 05-12-18 13:48:27, Nicolas Boichat wrote:
> > In some cases (e.g. IOMMU ARMv7s page allocator), we need to allocate
> > data structures smaller than a page with GFP_DMA32 flag.
> >
> > This change makes it possible to create a custom cache in DMA32 zone
> > using kmem_cache_create, then allocate memory using kmem_cache_alloc.
> >
> > We do not create a DMA32 kmalloc cache array, as there are currently
> > no users of kmalloc(..., GFP_DMA32). The new test in check_slab_flags
> > ensures that such calls still fail (as they do before this change).
>
> The changelog should be much more specific about decisions made here.
> First of all it would be nice to mention the usecase.

Ok, I'll copy most of the cover letter text here (i.e. the fact that
IOMMU wants physical memory <4GB for L2 page tables, why it's better
than genalloc/page_frag).

> Secondly, why do we need a new sysfs file? Who is going to consume it?

We have cache_dma, so it seems consistent to add cache_dma32.

I wasn't aware of tools/vm/slabinfo.c, so I can add support for
cache_dma32 in a follow-up patch. Any other user I should take care
of?

> Then why do we need SLAB_MERGE_SAME to cover GFP_DMA32 as well?

SLAB_MERGE_SAME tells us which flags _need_ to be the same for the
slabs to be merged. We don't want slab caches with GFP_DMA32 and
~GFP_DMA32 to be merged, so it should be in there.
(https://elixir.bootlin.com/linux/v4.19.6/source/mm/slab_common.c#L342).

> I
> thought the whole point is to use dedicated slab cache. Who is this
> going to merge with?

Well, if there was another SLAB cache requiring 1KB GFP_DMA32
elements, then I don't see why we would not merge the caches. This is
what happens with this IOMMU L2 tables cache pre-CONFIG_ZONE_DMA32 on
arm64 (output on some 3.18 kernel below), and what would happen on
arm32 since we still use GFP_DMA.

/sys/kernel/slab # ls -l | grep dt-0001024
drwxr-xr-x. 2 root root 0 Dec  5 02:25 :dt-0001024
lrwxrwxrwx. 1 root root 0 Dec  5 02:25 dma-kmalloc-1024 -> :dt-0001024
lrwxrwxrwx. 1 root root 0 Dec  5 02:25 io-pgtable_armv7s_l2 -> :dt-0001024

Thanks!

> --
> Michal Hocko
> SUSE Labs
