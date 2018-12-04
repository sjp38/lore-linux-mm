Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D9B816B6E08
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:37:26 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id g7so4664822plp.10
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:37:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s7sor21787571plp.27.2018.12.04.01.37.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 01:37:25 -0800 (PST)
MIME-Version: 1.0
References: <20181111090341.120786-1-drinkcat@chromium.org>
In-Reply-To: <20181111090341.120786-1-drinkcat@chromium.org>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Tue, 4 Dec 2018 17:37:13 +0800
Message-ID: <CANMq1KDxmRcWhtaJbrLHqx6yPGkNaK7WNYYf+iFjH1e8XdrwRg@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Matthias Brugger <matthias.bgg@gmail.com>, hch@infradead.org, Matthew Wilcox <willy@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, Hsin-Yi Wang <hsinyi@chromium.org>, Daniel Kurtz <djkurtz@chromium.org>

On Sun, Nov 11, 2018 at 5:04 PM Nicolas Boichat <drinkcat@chromium.org> wrote:
>
> This is a follow-up to the discussion in [1], to make sure that the page
> tables allocated by iommu/io-pgtable-arm-v7s are contained within 32-bit
> physical address space.
>
> [1] https://lists.linuxfoundation.org/pipermail/iommu/2018-November/030876.html

Hi everyone,

Let's try to summarize here.

First, we confirmed that this is a regression, and IOMMU errors happen
on 4.19 and linux-next/master on MT8173 (elm, Acer Chromebook R13).
The issue most likely starts from ad67f5a6545f ("arm64: replace
ZONE_DMA with ZONE_DMA32"), i.e. 4.15, and presumably breaks a number
of Mediatek platforms (and maybe others?).

We have a few options here:
1. This series [2], that adds support for GFP_DMA32 slab caches,
_without_ adding kmalloc caches (since there are no users of
kmalloc(..., GFP_DMA32)). I think I've addressed all the comments on
the 3 patches, and AFAICT this solution works fine.
2. genalloc. That works, but unless we preallocate 4MB for L2 tables
(which is wasteful as we usually only need a handful of L2 tables),
we'll need changes in the core (use GFP_ATOMIC) to allow allocating on
demand, and as it stands we'd have no way to shrink the allocation.
3. page_frag [3]. That works fine, and the code is quite simple. One
drawback is that fragments in partially freed pages cannot be reused
(from limited experiments, I see that IOMMU L2 tables are rarely
freed, so it's unlikely a whole page would get freed). But given the
low number of L2 tables, maybe we can live with that.

I think 2 is out. Any preference between 1 and 3? I think 1 makes
better use of the memory, so that'd be my preference. But I'm probably
missing something.

[2] https://patchwork.kernel.org/cover/10677529/, 3 patches
[3] https://patchwork.codeaurora.org/patch/671639/

Thanks,

Nicolas
