Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1147F800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 09:36:29 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v10so2480239wrv.22
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 06:36:29 -0800 (PST)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id x5si266226wmx.84.2018.01.24.06.36.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 06:36:26 -0800 (PST)
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: [PATCH v3 0/1] Skip over regions of invalid pfns with NUMA=n && HAVE_MEMBLOCK=y
Date: Wed, 24 Jan 2018 15:35:44 +0100
Message-ID: <20180124143545.31963-1-erosca@de.adit-jv.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>
Cc: Eugeniu Rosca <erosca@de.adit-jv.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello MM/kernel experts,

I include this cover letter to present some background and motivation
behind the patch, although the description included in the patch itself
should be rich enough already.

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
the v4.15-rc9 arm64 kernel decreases the binary Image by 64kB, but,
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

If this doesn't sound or feel right, I would appreciate your feedback.
I will definitely participate in testing any alternative proposals
that may arise in your mind. TIA!

Best regards,
Eugeniu.

Changes v2->v3:
- Fix review comments from Matthew Wilcox (get rid of compile-time
  guards in mm/page_alloc.c).
- Rebase and re-measure the boot time improvement on v4.15-rc9

Changes v1->v2:
- Fix ARCH=tile build error, signalled by kbuild test robot
- Rebase and re-measure the boot time improvement on v4.15-rc8

Eugeniu Rosca (1):
  mm: page_alloc: skip over regions of invalid pfns on UMA

 include/linux/memblock.h | 1 -
 include/linux/mm.h       | 6 ++++++
 mm/memblock.c            | 2 ++
 mm/page_alloc.c          | 2 --
 4 files changed, 8 insertions(+), 3 deletions(-)

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
