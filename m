Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47E2D6B2878
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 19:52:59 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id m13so12104578pls.15
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 16:52:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r2sor30764195pgv.24.2018.11.21.16.52.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 16:52:58 -0800 (PST)
MIME-Version: 1.0
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <20181111090341.120786-3-drinkcat@chromium.org> <01000167378bf31a-a639b46c-4d1d-43de-9bed-9cdd9c07fa94-000000@email.amazonses.com>
In-Reply-To: <01000167378bf31a-a639b46c-4d1d-43de-9bed-9cdd9c07fa94-000000@email.amazonses.com>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Thu, 22 Nov 2018 08:52:46 +0800
Message-ID: <CANMq1KD4j=Zh1izN8Ujn3+ZsdMMzCLPurfkXTkM9TyQaTptjFw@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] mm: Add support for SLAB_CACHE_DMA32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com

On Thu, Nov 22, 2018 at 2:32 AM Christopher Lameter <cl@linux.com> wrote:
>
> On Sun, 11 Nov 2018, Nicolas Boichat wrote:
>
> > SLAB_CACHE_DMA32 is only available after explicit kmem_cache_create calls,
> > no default cache is created for kmalloc. Add a test in check_slab_flags
> > for this.
>
> This does not define the dma32 kmalloc array. Is that intentional?

Yes that's intentional, AFAICT there is no user, so there is no point
creating the cache.

 (okay, I could find one, but it's probably broken:
git grep GFP_DMA32 | grep k[a-z]*alloc
drivers/media/platform/vivid/vivid-osd.c: dev->video_vbase =
kzalloc(dev->video_buffer_size, GFP_KERNEL | GFP_DMA32);
).

> In that
> case you need to fail any request for GFP_DMA32 coming in via kmalloc.

Well, we do check for these in check_slab_flags (aka GFP_SLAB_BUG_MASK
before patch 1/3 of this series), so, with or without this patch,
calls with GFP_DMA32 will end up failing in check_slab_flags.
