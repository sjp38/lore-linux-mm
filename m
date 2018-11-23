Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31AB16B3049
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:15:22 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g12-v6so15361095plo.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:15:22 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t129-v6si58274723pfb.16.2018.11.23.04.15.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 04:15:21 -0800 (PST)
Subject: Re: [PATCH v2 3/3] iommu/io-pgtable-arm-v7s: Request DMA32 memory,
 and improve debugging
References: <20181111090341.120786-1-drinkcat@chromium.org>
 <20181111090341.120786-4-drinkcat@chromium.org>
 <20181121164638.GD24883@arm.com> <20181121180000.GU12932@dhcp22.suse.cz>
 <CANMq1KCHGZ2vEWg+OQQ-SwvHcU-oMp4qKzEYfLwRYD5ZmRdRsA@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f5411603-2d06-916c-473d-1a40a5463876@suse.cz>
Date: Fri, 23 Nov 2018 13:15:16 +0100
MIME-Version: 1.0
In-Reply-To: <CANMq1KCHGZ2vEWg+OQQ-SwvHcU-oMp4qKzEYfLwRYD5ZmRdRsA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Boichat <drinkcat@chromium.org>, mhocko@kernel.org
Cc: Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com

On 11/22/18 2:20 AM, Nicolas Boichat wrote:
> On Thu, Nov 22, 2018 at 2:02 AM Michal Hocko <mhocko@kernel.org> wrote:
>>
>> On Wed 21-11-18 16:46:38, Will Deacon wrote:
>>> On Sun, Nov 11, 2018 at 05:03:41PM +0800, Nicolas Boichat wrote:
>>>
>>> It's a bit grotty that GFP_DMA32 doesn't just map to GFP_DMA on 32-bit
>>> architectures, since then we wouldn't need this #ifdeffery afaict.
>>
>> But GFP_DMA32 should map to GFP_KERNEL on 32b, no? Or what exactly is
>> going on in here?
> 
> GFP_DMA32 will fail due to check_slab_flags (aka GFP_SLAB_BUG_MASK
> before patch 1/3 of this series)... But yes, it may be neater if there
> was transparent remapping of GFP_DMA32/SLAB_CACHE_DMA32 to
> GFP_DMA/SLAB_CACHE_DMA on 32-bit arch...

I don't know about ARM, but AFAIK on x86 DMA means within first 4MB of
physical memory, and DMA32 means within first 4GB. It doesn't matter if
the CPU is running in 32bit or 64bit mode. But, when it runs 32bit, the
kernel can direct map less than 4GB anyway, which means it doesn't need
the extra DMA32 zone, i.e. GFP_KERNEL can only get you memory that's
also acceptable for GFP_DMA32.
But, DMA is still DMA, i.e. first 4MB. Remapping GFP_DMA32 to GFP_DMA on
x86 wouldn't work, as the GFP_DMA32 allocations would then only use
those 4MB and exhaust it very fast.

>> --
>> Michal Hocko
>> SUSE Labs
