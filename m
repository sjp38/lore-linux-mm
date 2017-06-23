Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B60E6B03B0
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:53:59 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 23so4737174wry.4
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:53:58 -0700 (PDT)
Received: from mail-wr0-f193.google.com (mail-wr0-f193.google.com. [209.85.128.193])
        by mx.google.com with ESMTPS id w145si3377524wmw.126.2017.06.23.01.53.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 01:53:57 -0700 (PDT)
Received: by mail-wr0-f193.google.com with SMTP id x23so10900374wrb.0
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:53:57 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/6] mm: give __GFP_REPEAT a better semantic
Date: Fri, 23 Jun 2017 10:53:39 +0200
Message-Id: <20170623085345.11304-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Alex Belits <alex.belits@cavium.com>, Christoph Hellwig <hch@infradead.org>, Chris Wilson <chris@chris-wilson.co.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, David Daney <david.daney@cavium.com>, Michal Hocko <mhocko@suse.com>, Ralf Baechle <ralf@linux-mips.org>

Hi,
this is a follow up for __GFP_REPEAT clean up merged in 4.7. The previous
version of this patch series was posted as an RFC
http://lkml.kernel.org/r/20170307154843.32516-1-mhocko@kernel.org
Since then I have updated the documentation based on feedback from Neil
Brown. It also seems that drm/i915 guys would like to use the flag as
well.  A new __GFP_REPEAT user in MIPS code has emerged so this is fixed
as well.  I have also added some more users into the core VM. We can
discuss them separately but I guess we have grown to the state where no
other alternative has been proposed while there is a demand for the new
semantic. We should simply merge the new flag and new users will emerge
over time. There is no need for a flag day to convert all of them at once.

This is based on the current linux-next (next-20170623)

The main motivation for the change is that the current implementation of
__GFP_REPEAT is not very much useful. 

The documentation says:
 * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
 *   _might_ fail.  This depends upon the particular VM implementation.

It just fails to mention that this is true only for large (costly) high
order which has been the case since the flag was introduced. A similar
semantic would be really helpful for smal orders as well, though,
because we have places where a failure with a specific fallback error
handling is preferred to a potential endless loop inside the page
allocator.

The earlier cleanup dropped __GFP_REPEAT usage for low (!costly) order
users so only those which might use larger orders have stayed. One new user
added in the meantime is addressed in patch 1.

Let's rename the flag to something more verbose and use it for existing
users. Semantic for those will not change. Then implement low (!costly)
orders failure path which is hit after the page allocator is about
to invoke the oom killer. With that we have a good counterpart for
__GFP_NORETRY and finally can tell try as hard as possible without the
OOM killer.

Xfs code already has an existing annotation for allocations which are
allowed to fail and we can trivially map them to the new gfp flag
because it will provide the semantic KM_MAYFAIL wants. Christoph didn't
consider the new flag really necessary but didn't respond to the OOM
killer aspect of the change so I have kept the patch. If this is still
seen as not really needed I can drop the patch.

kvmalloc will allow also !costly high order allocations to retry hard
before falling back to the vmalloc.

drm/i915 asked for the new semantic explicitly.

Memory migration code, especially for the memory hotplug, should back off
rather than invoking the OOM killer as well.

Diffstat (the biggest addition is the documentation)
 Documentation/DMA-ISA-LPC.txt                |  2 +-
 arch/mips/include/asm/pgalloc.h              |  2 +-
 arch/powerpc/include/asm/book3s/64/pgalloc.h |  2 +-
 arch/powerpc/kvm/book3s_64_mmu_hv.c          |  2 +-
 drivers/gpu/drm/i915/i915_gem.c              |  3 +-
 drivers/mmc/host/wbsd.c                      |  2 +-
 drivers/s390/char/vmcp.c                     |  2 +-
 drivers/target/target_core_transport.c       |  2 +-
 drivers/vhost/net.c                          |  2 +-
 drivers/vhost/scsi.c                         |  2 +-
 drivers/vhost/vsock.c                        |  2 +-
 fs/xfs/kmem.h                                | 10 +++++
 include/linux/gfp.h                          | 55 +++++++++++++++++++++-------
 include/linux/migrate.h                      |  2 +-
 include/linux/slab.h                         |  3 +-
 include/trace/events/mmflags.h               |  2 +-
 mm/hugetlb.c                                 |  4 +-
 mm/internal.h                                |  2 +-
 mm/memory-failure.c                          |  3 +-
 mm/mempolicy.c                               |  3 +-
 mm/page_alloc.c                              | 14 +++++--
 mm/sparse-vmemmap.c                          |  4 +-
 mm/util.c                                    | 14 ++-----
 mm/vmalloc.c                                 |  2 +-
 mm/vmscan.c                                  |  8 ++--
 net/core/dev.c                               |  6 +--
 net/core/skbuff.c                            |  2 +-
 net/sched/sch_fq.c                           |  2 +-
 tools/perf/builtin-kmem.c                    |  2 +-
 29 files changed, 103 insertions(+), 58 deletions(-)

Shortlog
Michal Hocko (6):
      MIPS: do not use __GFP_REPEAT for order-0 request
      mm, tree wide: replace __GFP_REPEAT by __GFP_RETRY_MAYFAIL with more useful semantic
      xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
      mm: kvmalloc support __GFP_RETRY_MAYFAIL for all sizes
      drm/i915: use __GFP_RETRY_MAYFAIL
      mm, migration: do not trigger OOM killer when migrating memory

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
