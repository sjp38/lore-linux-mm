Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 223136B0033
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 09:49:15 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 62so4791098wrf.8
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 06:49:15 -0800 (PST)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id f2si11610427wrg.343.2018.01.21.06.49.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jan 2018 06:49:12 -0800 (PST)
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: [PATCH v2 0/1] Skip over regions of invalid pfns with NUMA=n && HAVE_MEMBLOCK=y
Date: Sun, 21 Jan 2018 15:47:52 +0100
Message-ID: <20180121144753.3109-1-erosca@de.adit-jv.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>
Cc: Eugeniu Rosca <erosca@de.adit-jv.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello MM/kernel experts,

I include this cover letter to present some background and motivation
behind the patch, although the description included in the patch itself
should be reach enough already.

The context of this change is some effort to optimize the boot time of
Rcar Gen3 SoC family, which at its roots is driven by automotive
requirements like (well-known?) "2-seconds-to-rear-view-camera".

To fulfill those, we create a defconfig based on vanilla arm64
defconfig, which is then tailored to Rcar Gen3 SoC needs. This allows
us to reduce the kernel binary image size by almost 50%. We are very
picky during this cleanup process, to the point that, as showcased
with this patch, we start to submit changes in MM core part, where
(to be honest) we don't have much expertise.

As mentioned in the description of attached patch, disabling NUMA in
the v4.15-rc8 arm64 kernel decreases the binary Image by 64kB, but,
at the same time, increases the H3ULCB boot time by ~140ms, which is
counterintuitive, since by disabling NUMA we expect to get rid of
unused NUMA infrastructure and skip unneeded NUMA init.

As already mentioned in the attached patch, the slowdown happens because
v4.11-rc1 commit b92df1de5d28 ("mm: page_alloc: skip over regions of
invalid pfns where possible") conditions itself on
CONFIG_HAVE_MEMBLOCK_NODE_MAP, which on arm64 depends on NUMA:
$> git grep HAVE_MEMBLOCK_NODE_MAP | grep arm64
arch/arm64/Kconfig:     select HAVE_MEMBLOCK_NODE_MAP if NUMA

The attached patch attempts to present some evidence that the
aforementioned commit can speed up the execution of memmap_init_zone()
not only on arm64 NUMA, but also on arm64 non-NUMA machines. This is
achieved by "relaxing" the dependency of memblock_next_valid_pfn()
from being guarded by CONFIG_HAVE_MEMBLOCK_NODE_MAP to being
guarded by the more generic CONFIG_HAVE_MEMBLOCK.

If this doesn't sound of feel right, I would appreciate your feedback.
I will definitely participate in testing any alternative proposals
that may arise in your mind. TIA!

Best regards,
Eugeniu.

Changes v1->v2:
- Fix ARCH=tile build error [1], signalled by kbuild test robot
- Re-measure Rcar H3ULCB boot time improvement on v4.15-rc8

Eugeniu Rosca (1):
  mm: page_alloc: skip over regions of invalid pfns on UMA

 include/linux/memblock.h | 3 ++-
 mm/memblock.c            | 2 ++
 mm/page_alloc.c          | 2 +-
 3 files changed, 5 insertions(+), 2 deletions(-)

[1] kbuild test robot reported for ARCH=tile with [PATCH v1]:

    mm/page_alloc.c: In function 'memmap_init_zone':
 >> mm/page_alloc.c:5359:10: error: implicit declaration of function 
 >> 'memblock_next_valid_pfn'; did you mean 'memblock_virt_alloc_low'? 
 >> [-Werror=implicit-function-declaration]
        pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
              ^~~~~~~~~~~~~~~~~~~~~~~
              memblock_virt_alloc_low
    cc1: some warnings being treated as errors

-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
