Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 615A06B0286
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 05:31:06 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y10so2653131wmd.4
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 02:31:06 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id o91si2723931eda.419.2017.10.12.02.31.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 02:31:04 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 79FA21C1C25
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:31:04 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/8] Follow-up for speed up page cache truncation
Date: Thu, 12 Oct 2017 10:30:55 +0100
Message-Id: <20171012093103.13412-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@techsingularity.net>

(cc'ing those that reviewed Jan's series as this series is on top)

This series is a follow-on for Jan Kara's series "Speed up page cache
truncation" series. We both ended up looking at the same problem but saw
different problems based on the same data. This series builds upon his
work. The performance comparisons use 4.14-rc4 + Jan's series as a baseline.

A variety of workloads were compared on four separate machines but each
machine showed gains albeit at different levels. Minimally, some of the
differences are due to NUMA where truncating data from a remote node is
slower than a local node. The workloads checked were

o sparse truncate microbenchmark, tiny
o sparse truncate microbenchmark, large
o reaim-io disk workfile
o dbench4 (modified by mmtests to produce more stable results)
o filebench varmail configuration for small memory size
o bonnie, directory operations, working set size 2*RAM

reaim-io, dbench and filebench all showed minor gains.  Truncation does not
dominate those workloads but were tested to ensure no other regressions.
They will not be reported further.

The sparse truncate microbench was written by Jan. It creates a number of
files and then times how long it takes to truncate each one. The "tiny"
configuraiton creates a number of files that easily fits in memory and
times how long it takes to truncate files with page cache. The large
configuration uses enough files to have data that is twice the size of
memory and so timings there include truncating page cache and working set
shadow entries in the radix tree.

Patches 1-4 are the most relevant parts of this series. Patches 5-8 are
optional as they are deleting code that is essentially useless but has a
negligible performance impact.

The changelogs have more information on performance but just for bonnie
delete options, the main comparison is

bonnie
                                      4.14.0-rc4             4.14.0-rc4             4.14.0-rc4
                                   janbatch-v1r1                vanilla            nocold-v1r1
Hmean     SeqCreate del      24963.95 (   0.00%)    21313.45 ( -14.62%)    26842.24 (   7.52%)
Hmean     RandCreate del     23377.66 (   0.00%)    19974.03 ( -14.56%)    25262.42 (   8.06%)

Jan's series is the baseline and the vanilla kernel is 14% slower where
as this series on top gains another 7-8%.

 arch/powerpc/mm/mmu_context_book3s64.c             |  2 +-
 arch/powerpc/mm/pgtable_64.c                       |  2 +-
 arch/sparc/mm/init_64.c                            |  2 +-
 arch/tile/mm/homecache.c                           |  2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c             |  6 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c            |  2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |  2 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c              |  6 +-
 drivers/gpu/drm/i915/i915_gem_gtt.c                |  2 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c            |  4 +-
 drivers/gpu/drm/radeon/radeon_ttm.c                |  2 +-
 drivers/net/ethernet/amazon/ena/ena_netdev.c       |  2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c          |  2 +-
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c   |  3 +-
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |  5 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  4 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |  3 +-
 drivers/net/ethernet/sfc/falcon/rx.c               |  2 +-
 drivers/net/ethernet/sfc/rx.c                      |  2 +-
 drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c    |  2 +-
 drivers/net/ethernet/ti/netcp_core.c               |  2 +-
 drivers/net/virtio_net.c                           |  1 -
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  2 +-
 fs/afs/write.c                                     |  4 +-
 fs/btrfs/extent_io.c                               |  4 +-
 fs/buffer.c                                        |  4 +-
 fs/cachefiles/rdwr.c                               | 10 +--
 fs/ceph/addr.c                                     |  4 +-
 fs/dax.c                                           |  2 +-
 fs/ext4/file.c                                     |  2 +-
 fs/ext4/inode.c                                    |  6 +-
 fs/f2fs/checkpoint.c                               |  2 +-
 fs/f2fs/data.c                                     |  2 +-
 fs/f2fs/file.c                                     |  2 +-
 fs/f2fs/node.c                                     |  8 +-
 fs/fscache/page.c                                  |  2 +-
 fs/fuse/dev.c                                      |  2 +-
 fs/gfs2/aops.c                                     |  2 +-
 fs/hugetlbfs/inode.c                               |  2 +-
 fs/nilfs2/btree.c                                  |  2 +-
 fs/nilfs2/page.c                                   |  8 +-
 fs/nilfs2/segment.c                                |  4 +-
 include/linux/gfp.h                                |  9 +--
 include/linux/pagemap.h                            | 10 +--
 include/linux/pagevec.h                            |  6 +-
 include/linux/skbuff.h                             |  2 +-
 include/linux/slab.h                               |  3 -
 include/linux/swap.h                               | 13 ++-
 include/trace/events/kmem.h                        | 11 +--
 include/trace/events/mmflags.h                     |  1 -
 kernel/power/snapshot.c                            |  4 +-
 mm/filemap.c                                       | 15 ++--
 mm/mlock.c                                         |  4 +-
 mm/page-writeback.c                                |  2 +-
 mm/page_alloc.c                                    | 89 ++++++++++++---------
 mm/percpu-vm.c                                     |  2 +-
 mm/rmap.c                                          |  2 +-
 mm/shmem.c                                         |  6 +-
 mm/swap.c                                          | 15 ++--
 mm/swap_state.c                                    |  2 +-
 mm/truncate.c                                      | 92 +++++++++++++++-------
 mm/vmscan.c                                        |  6 +-
 mm/workingset.c                                    |  8 +-
 net/core/skbuff.c                                  |  4 +-
 tools/perf/builtin-kmem.c                          |  1 -
 66 files changed, 239 insertions(+), 204 deletions(-)

-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
