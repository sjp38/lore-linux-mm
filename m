Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3876B7941
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 04:37:42 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id w15so85642edl.21
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 01:37:42 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c23si68536edv.143.2018.12.06.01.37.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 01:37:40 -0800 (PST)
Subject: Re: [PATCH v4 2/3] mm: Add support for kmem caches in DMA32 zone
References: <20181205054828.183476-1-drinkcat@chromium.org>
 <20181205054828.183476-3-drinkcat@chromium.org>
 <5eddd264-5527-a98e-fc8b-31ea89f474db@suse.cz>
 <CANMq1KAL7TcVa4xF8=NdK2cs0VakEq5i6MyCvfmYTGCmJ78-ag@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <09f56edb-2dab-c023-2164-dd7b5cef6afb@suse.cz>
Date: Thu, 6 Dec 2018 10:34:38 +0100
MIME-Version: 1.0
In-Reply-To: <CANMq1KAL7TcVa4xF8=NdK2cs0VakEq5i6MyCvfmYTGCmJ78-ag@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Boichat <drinkcat@chromium.org>
Cc: Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org, Matthew Wilcox <willy@infradead.org>

On 12/6/18 4:49 AM, Nicolas Boichat wrote:
>> So it would be fine even unchanged. The check would anyway need some
>> more love to catch the same with __GFP_DMA to be consistent and cover
>> all corner cases.
> Yes, the test is not complete. If we really wanted this to be
> accurate, we'd need to check that GFP_* exactly matches SLAB_CACHE_*.
> 
> The only problem with dropping this is test that we should restore
> GFP_DMA32 warning/errors somewhere else (as Christopher pointed out
> here: https://lkml.org/lkml/2018/11/22/430), especially for kmalloc
> case.

I meant just dropping that patch hunk, not the whole test. Then the test
stays as it is and will keep warning anyone calling kmalloc(GFP_DMA32).
It would also warn anyone calling kmem_cache_alloc(GFP_DMA32) on
SLAB_CACHE_DMA32 cache, but since the gfp can be just dropped, and you
as the only user of this so far will do that, it's fine?

> Maybe this can be done in kmalloc_slab.
