Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE086B74AA
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 09:02:11 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so9631277edt.23
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 06:02:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si19785edv.158.2018.12.05.06.02.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 06:02:09 -0800 (PST)
Subject: Re: [PATCH v4 2/3] mm: Add support for kmem caches in DMA32 zone
References: <20181205054828.183476-1-drinkcat@chromium.org>
 <20181205054828.183476-3-drinkcat@chromium.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5eddd264-5527-a98e-fc8b-31ea89f474db@suse.cz>
Date: Wed, 5 Dec 2018 14:59:09 +0100
MIME-Version: 1.0
In-Reply-To: <20181205054828.183476-3-drinkcat@chromium.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Boichat <drinkcat@chromium.org>, Will Deacon <will.deacon@arm.com>
Cc: Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org, Matthew Wilcox <willy@infradead.org>

On 12/5/18 6:48 AM, Nicolas Boichat wrote:
> In some cases (e.g. IOMMU ARMv7s page allocator), we need to allocate
> data structures smaller than a page with GFP_DMA32 flag.
> 
> This change makes it possible to create a custom cache in DMA32 zone
> using kmem_cache_create, then allocate memory using kmem_cache_alloc.
> 
> We do not create a DMA32 kmalloc cache array, as there are currently
> no users of kmalloc(..., GFP_DMA32). The new test in check_slab_flags
> ensures that such calls still fail (as they do before this change).
> 
> Fixes: ad67f5a6545f ("arm64: replace ZONE_DMA with ZONE_DMA32")

Same as my comment for 1/3.

> Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>

In general,
Acked-by: Vlastimil Babka <vbabka@suse.cz>

Some comments below:

> ---
> 
> Changes since v2:
>  - Clarified commit message
>  - Add entry in sysfs-kernel-slab to document the new sysfs file
> 
> (v3 used the page_frag approach)
> 
> Documentation/ABI/testing/sysfs-kernel-slab |  9 +++++++++
>  include/linux/slab.h                        |  2 ++
>  mm/internal.h                               |  8 ++++++--
>  mm/slab.c                                   |  4 +++-
>  mm/slab.h                                   |  3 ++-
>  mm/slab_common.c                            |  2 +-
>  mm/slub.c                                   | 18 +++++++++++++++++-
>  7 files changed, 40 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
> index 29601d93a1c2ea..d742c6cfdffbe9 100644
> --- a/Documentation/ABI/testing/sysfs-kernel-slab
> +++ b/Documentation/ABI/testing/sysfs-kernel-slab
> @@ -106,6 +106,15 @@ Description:
>  		are from ZONE_DMA.
>  		Available when CONFIG_ZONE_DMA is enabled.
>  
> +What:		/sys/kernel/slab/cache/cache_dma32
> +Date:		December 2018
> +KernelVersion:	4.21
> +Contact:	Nicolas Boichat <drinkcat@chromium.org>
> +Description:
> +		The cache_dma32 file is read-only and specifies whether objects
> +		are from ZONE_DMA32.
> +		Available when CONFIG_ZONE_DMA32 is enabled.

I don't have a strong opinion. It's a new file, yeah, but consistent
with already existing ones. I'd leave the decision with SL*B maintainers.

>  What:		/sys/kernel/slab/cache/cpu_slabs
>  Date:		May 2007
>  KernelVersion:	2.6.22
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 11b45f7ae4057c..9449b19c5f107a 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -32,6 +32,8 @@
>  #define SLAB_HWCACHE_ALIGN	((slab_flags_t __force)0x00002000U)
>  /* Use GFP_DMA memory */
>  #define SLAB_CACHE_DMA		((slab_flags_t __force)0x00004000U)
> +/* Use GFP_DMA32 memory */
> +#define SLAB_CACHE_DMA32	((slab_flags_t __force)0x00008000U)
>  /* DEBUG: Store the last owner for bug hunting */
>  #define SLAB_STORE_USER		((slab_flags_t __force)0x00010000U)
>  /* Panic if kmem_cache_create() fails */
> diff --git a/mm/internal.h b/mm/internal.h
> index a2ee82a0cd44ae..fd244ad716eaf8 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -14,6 +14,7 @@
>  #include <linux/fs.h>
>  #include <linux/mm.h>
>  #include <linux/pagemap.h>
> +#include <linux/slab.h>
>  #include <linux/tracepoint-defs.h>
>  
>  /*
> @@ -34,9 +35,12 @@
>  #define GFP_CONSTRAINT_MASK (__GFP_HARDWALL|__GFP_THISNODE)
>  
>  /* Check for flags that must not be used with a slab allocator */
> -static inline gfp_t check_slab_flags(gfp_t flags)
> +static inline gfp_t check_slab_flags(gfp_t flags, slab_flags_t slab_flags)
>  {
> -	gfp_t bug_mask = __GFP_DMA32 | __GFP_HIGHMEM | ~__GFP_BITS_MASK;
> +	gfp_t bug_mask = __GFP_HIGHMEM | ~__GFP_BITS_MASK;
> +
> +	if (!IS_ENABLED(CONFIG_ZONE_DMA32) || !(slab_flags & SLAB_CACHE_DMA32))
> +		bug_mask |= __GFP_DMA32;

I'll point out that this is not even strictly needed AFAICS, as only
flags passed to kmem_cache_alloc() are checked - the cache->allocflags
derived from SLAB_CACHE_DMA32 are appended only after check_slab_flags()
(in both SLAB and SLUB AFAICS). And for a cache created with
SLAB_CACHE_DMA32, the caller of kmem_cache_alloc() doesn't need to also
include __GFP_DMA32, the allocation will be from ZONE_DMA32 regardless.
So it would be fine even unchanged. The check would anyway need some
more love to catch the same with __GFP_DMA to be consistent and cover
all corner cases.

>  
>  	if (unlikely(flags & bug_mask)) {
>  		gfp_t invalid_mask = flags & bug_mask;
