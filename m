Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E5C946B2CFD
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:23:44 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x98-v6so5742919ede.0
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:23:44 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 95si15563207edq.82.2018.11.23.04.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 04:23:43 -0800 (PST)
Subject: Re: [PATCH v2 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page
 tables
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <0100016737801f14-84f1265d-4577-4dcf-ad57-90dbc8e0a78f-000000@email.amazonses.com>
 <20181121213853.GL3065@bombadil.infradead.org>
 <c5ccde1e-a711-ad33-537c-2d5a0bd9edd4@arm.com>
 <20181122082336.GA2049@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <555dd63a-0634-6a39-7abc-121e02273cb2@suse.cz>
Date: Fri, 23 Nov 2018 13:23:41 +0100
MIME-Version: 1.0
In-Reply-To: <20181122082336.GA2049@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Robin Murphy <robin.murphy@arm.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Levin Alexander <Alexander.Levin@microsoft.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Nicolas Boichat <drinkcat@chromium.org>, Huaisheng Ye <yehs1@lenovo.com>, Tomasz Figa <tfiga@google.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Michal Hocko <mhocko@suse.com>, linux-arm-kernel@lists.infradead.org, David Rientjes <rientjes@google.com>, Matthias Brugger <matthias.bgg@gmail.com>, yingjoe.chen@mediatek.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On 11/22/18 9:23 AM, Christoph Hellwig wrote:
> On Wed, Nov 21, 2018 at 10:26:26PM +0000, Robin Murphy wrote:
>> TBH, if this DMA32 stuff is going to be contentious we could possibly just
>> rip out the offending kmem_cache - it seemed like good practice for the
>> use-case, but provided kzalloc(SZ_1K, gfp | GFP_DMA32) can be relied upon to
>> give the same 1KB alignment and chance of succeeding as the equivalent
>> kmem_cache_alloc(), then we could quite easily make do with that instead.
> 
> Neither is the slab support for kmalloc, not do kmalloc allocations
> have useful alignment apparently (at least if you use slub debug).

Is this also true for caches created by kmem_cache_create(), that
debugging options can result in not respecting the alignment passed to
kmem_cache_create()? That would be rather bad, IMHO.

> But I do agree with the sentiment of not wanting to spread GFP_DMA32
> futher into the slab allocator.

I don't see a problem with GFP_DMA32 for custom caches. Generic
kmalloc() would be worse, since it would have to create a new array of
kmalloc caches. But that's already ruled out due to the alignment.

> I think you want a simple genalloc allocator for this rather special
> use case.

I would prefer if slab could support it, as it doesn't have to
preallocate. OTOH if the allocations are GFP_ATOMIC as suggested later
in the thread, and need to always succeed, then preallocation could be
better, and thus maybe genalloc.
