Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA906B7729
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 19:41:50 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id s14so18158709pfk.16
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 16:41:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n12sor29350300pgs.60.2018.12.05.16.41.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 16:41:49 -0800 (PST)
MIME-Version: 1.0
References: <20181205054828.183476-1-drinkcat@chromium.org>
 <20181205054828.183476-3-drinkcat@chromium.org> <20181205072528.l7blg6y24ggblh4m@master>
 <CANMq1KCi-k_4-66pMfvByzsjpf1H6_bvC82Ow0b_jEH6B3LHwA@mail.gmail.com> <20181205121807.evmslrimsv4pdtza@master>
In-Reply-To: <20181205121807.evmslrimsv4pdtza@master>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Thu, 6 Dec 2018 08:41:36 +0800
Message-ID: <CANMq1KD3vPpd1-=JpcOGRUyt97V+9+zJ9Yf-Qw5CZCPJBqNyHA@mail.gmail.com>
Subject: Re: [PATCH v4 2/3] mm: Add support for kmem caches in DMA32 zone
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: richard.weiyang@gmail.com
Cc: Will Deacon <will.deacon@arm.com>, Michal Hocko <mhocko@suse.com>, Levin Alexander <Alexander.Levin@microsoft.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Huaisheng Ye <yehs1@lenovo.com>, Matthew Wilcox <willy@infradead.org>, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, David Rientjes <rientjes@google.com>, yingjoe.chen@mediatek.com, Vlastimil Babka <vbabka@suse.cz>, Tomasz Figa <tfiga@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Matthias Brugger <matthias.bgg@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Robin Murphy <robin.murphy@arm.com>, lkml <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, iommu@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

On Wed, Dec 5, 2018 at 8:18 PM Wei Yang <richard.weiyang@gmail.com> wrote:
>
> On Wed, Dec 05, 2018 at 03:39:51PM +0800, Nicolas Boichat wrote:
> >On Wed, Dec 5, 2018 at 3:25 PM Wei Yang <richard.weiyang@gmail.com> wrote:
> >>
> >> On Wed, Dec 05, 2018 at 01:48:27PM +0800, Nicolas Boichat wrote:
> >> >In some cases (e.g. IOMMU ARMv7s page allocator), we need to allocate
> >> >data structures smaller than a page with GFP_DMA32 flag.
> >> >
> >> >This change makes it possible to create a custom cache in DMA32 zone
> >> >using kmem_cache_create, then allocate memory using kmem_cache_alloc.
> >> >
> >> >We do not create a DMA32 kmalloc cache array, as there are currently
> >> >no users of kmalloc(..., GFP_DMA32). The new test in check_slab_flags
> >> >ensures that such calls still fail (as they do before this change).
> >> >
> >> >Fixes: ad67f5a6545f ("arm64: replace ZONE_DMA with ZONE_DMA32")
> >> >Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
> >> >---
> >> >
> >> >Changes since v2:
> >> > - Clarified commit message
> >> > - Add entry in sysfs-kernel-slab to document the new sysfs file
> >> >
> >> >(v3 used the page_frag approach)
> >> >
> >> >Documentation/ABI/testing/sysfs-kernel-slab |  9 +++++++++
> >> > include/linux/slab.h                        |  2 ++
> >> > mm/internal.h                               |  8 ++++++--
> >> > mm/slab.c                                   |  4 +++-
> >> > mm/slab.h                                   |  3 ++-
> >> > mm/slab_common.c                            |  2 +-
> >> > mm/slub.c                                   | 18 +++++++++++++++++-
> >> > 7 files changed, 40 insertions(+), 6 deletions(-)
> >> >
> >> >diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
> >> >index 29601d93a1c2ea..d742c6cfdffbe9 100644
> >> >--- a/Documentation/ABI/testing/sysfs-kernel-slab
> >> >+++ b/Documentation/ABI/testing/sysfs-kernel-slab
> >> >@@ -106,6 +106,15 @@ Description:
> >> >               are from ZONE_DMA.
> >> >               Available when CONFIG_ZONE_DMA is enabled.
> >> >
> >> >+What:         /sys/kernel/slab/cache/cache_dma32
> >> >+Date:         December 2018
> >> >+KernelVersion:        4.21
> >> >+Contact:      Nicolas Boichat <drinkcat@chromium.org>
> >> >+Description:
> >> >+              The cache_dma32 file is read-only and specifies whether objects
> >> >+              are from ZONE_DMA32.
> >> >+              Available when CONFIG_ZONE_DMA32 is enabled.
> >> >+
> >> > What:         /sys/kernel/slab/cache/cpu_slabs
> >> > Date:         May 2007
> >> > KernelVersion:        2.6.22
> >> >diff --git a/include/linux/slab.h b/include/linux/slab.h
> >> >index 11b45f7ae4057c..9449b19c5f107a 100644
> >> >--- a/include/linux/slab.h
> >> >+++ b/include/linux/slab.h
> >> >@@ -32,6 +32,8 @@
> >> > #define SLAB_HWCACHE_ALIGN    ((slab_flags_t __force)0x00002000U)
> >> > /* Use GFP_DMA memory */
> >> > #define SLAB_CACHE_DMA                ((slab_flags_t __force)0x00004000U)
> >> >+/* Use GFP_DMA32 memory */
> >> >+#define SLAB_CACHE_DMA32      ((slab_flags_t __force)0x00008000U)
> >> > /* DEBUG: Store the last owner for bug hunting */
> >> > #define SLAB_STORE_USER               ((slab_flags_t __force)0x00010000U)
> >> > /* Panic if kmem_cache_create() fails */
> >> >diff --git a/mm/internal.h b/mm/internal.h
> >> >index a2ee82a0cd44ae..fd244ad716eaf8 100644
> >> >--- a/mm/internal.h
> >> >+++ b/mm/internal.h
> >> >@@ -14,6 +14,7 @@
> >> > #include <linux/fs.h>
> >> > #include <linux/mm.h>
> >> > #include <linux/pagemap.h>
> >> >+#include <linux/slab.h>
> >> > #include <linux/tracepoint-defs.h>
> >> >
> >> > /*
> >> >@@ -34,9 +35,12 @@
> >> > #define GFP_CONSTRAINT_MASK (__GFP_HARDWALL|__GFP_THISNODE)
> >> >
> >> > /* Check for flags that must not be used with a slab allocator */
> >> >-static inline gfp_t check_slab_flags(gfp_t flags)
> >> >+static inline gfp_t check_slab_flags(gfp_t flags, slab_flags_t slab_flags)
> >> > {
> >> >-      gfp_t bug_mask = __GFP_DMA32 | __GFP_HIGHMEM | ~__GFP_BITS_MASK;
> >> >+      gfp_t bug_mask = __GFP_HIGHMEM | ~__GFP_BITS_MASK;
> >> >+
> >> >+      if (!IS_ENABLED(CONFIG_ZONE_DMA32) || !(slab_flags & SLAB_CACHE_DMA32))
> >> >+              bug_mask |= __GFP_DMA32;
> >>
> >> The original version doesn't check CONFIG_ZONE_DMA32.
> >>
> >> Do we need to add this condition here?
> >> Could we just decide the bug_mask based on slab_flags?
> >
> >We can. The reason I did it this way is that when we don't have
> >CONFIG_ZONE_DMA32, the compiler should be able to simplify to:
> >
> >bug_mask = __GFP_HIGHMEM | ~__GFP_BITS_MASK;
> >if (true || ..) => if (true)
> >   bug_mask |= __GFP_DMA32;
> >
> >Then just
> >bug_mask = __GFP_HIGHMEM | ~__GFP_BITS_MASK | __GFP_DMA32;
> >
> >And since the function is inline, slab_flags would not even need to be
> >accessed at all.
> >
>
> Hmm, I get one confusion.
>
> This means if CONFIG_ZONE_DMA32 is not enabled, bug_mask will always
> contains __GFP_DMA32. This will check with cachep->flags.
>
> If cachep->flags has GFP_DMA32, this always fail?
>
> Is this possible?

Not fully sure to understand the question, but the code is:
if (!IS_ENABLED(CONFIG_ZONE_DMA32) || !(slab_flags & SLAB_CACHE_DMA32))
       bug_mask |= __GFP_DMA32;

IS_ENABLED(CONFIG_ZONE_DMA32) == true:
 - (slab_flags & SLAB_CACHE_DMA32) => bug_mask untouched, __GFP_DMA32
is allowed.
 - !(slab_flags & SLAB_CACHE_DMA32) => bug_mask |= __GFP_DMA32;,
__GFP_DMA32 triggers warning
IS_ENABLED(CONFIG_ZONE_DMA32) == false:
  => bug_mask |= __GFP_DMA32;, __GFP_DMA32 triggers warning (as
expected, GFP_DMA32 does not make sense if there is no DMA32 zone).

Does that clarify?

>
> --
> Wei Yang
> Help you, Help me
