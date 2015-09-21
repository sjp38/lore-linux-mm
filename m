Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 50EC06B0255
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:52:45 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so109979446wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 03:52:44 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id m11si161695wij.112.2015.09.21.03.52.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 03:52:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 8606899010
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:52:43 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 00/10] Remove zonelist cache and high-order watermark checking v4
Date: Mon, 21 Sep 2015 11:52:32 +0100
Message-Id: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Changelog since V3
o Rebase to 4.3-rc1
o Consistent style for __GFP_WAIT				(joonsoo)
o Restored cpuset static checking behaviour			(vbabka)
o Fix cpusets check in allocator fastpath			(vbabka)
o Applied acks

Changelog since V2
o Covered cases where __GFP_KSWAPD_RECLAIM is needed		(vbabka)
o Cleaned up trailing references to zlc				(vbabka)
o Fixed a subtle problem with GFP_TRANSHUGE checks		(vbabka)
o Split out an unrelated change to its own patch		(vbabka)
o Reordered series to put GFP flag modifications at start	(mhocko)
o Added a number of clarifications on reclaim modifications	(mhocko)
o Only check cpusets when one exists that can limit memory	(rientjes)
o Applied acks

Changelog since V1
o Improve cpusets checks as suggested				(rientjes)
o Add various acks and reviewed-bys
o Rebase to 4.2-rc6

Changelog since RFC
o Rebase to 4.2-rc5
o Distinguish between high priority callers and callers that avoid sleep
o Remove jump label related damage patches

Overall, the intent of this series is to remove the zonelist cache which
was introduced to avoid high overhead in the page allocator. Once this is
done, it is necessary to reduce the cost of watermark checks.

The series starts with minor micro-optimisations.

Next it notes that GFP flags that affect watermark checks are
bused. __GFP_WAIT historically identified callers that could not sleep and
could access reserves. This was later abused to identify callers that simply
prefer to avoid sleeping and have other options. A patch distinguishes
between atomic callers, high-priority callers and those that simply wish
to avoid sleep.

The zonelist cache has been around for a long time but it is of dubious
merit with a lot of complexity and some issues that are explained.
The most important issue is that a failed THP allocation can cause a
zone to be treated as "full". This potentially causes unnecessary stalls,
reclaim activity or remote fallbacks. The issues could be fixed but it's
not worth it. The series places a small number of other micro-optimisations
on top before examining GFP flags watermarks.

High-order watermarks enforcement can cause high-order allocations to fail
even though pages are free. The watermark checks both protect high-order
atomic allocations and make kswapd aware of high-order pages but there is
a much better way that can be handled using migrate types. This series uses
page grouping by mobility to reserve pageblocks for high-order allocations
with the size of the reservation depending on demand. kswapd awareness
is maintained by examining the free lists. By patch 12 in this series,
there are no high-order watermark checks while preserving the properties
that motivated the introduction of the watermark checks.

 Documentation/vm/balance                           |  14 +-
 arch/arm/mm/dma-mapping.c                          |   6 +-
 arch/arm/xen/mm.c                                  |   2 +-
 arch/arm64/mm/dma-mapping.c                        |   4 +-
 arch/x86/kernel/pci-dma.c                          |   2 +-
 block/bio.c                                        |  26 +-
 block/blk-core.c                                   |  16 +-
 block/blk-ioc.c                                    |   2 +-
 block/blk-mq-tag.c                                 |   2 +-
 block/blk-mq.c                                     |   8 +-
 block/scsi_ioctl.c                                 |   6 +-
 drivers/block/drbd/drbd_bitmap.c                   |   2 +-
 drivers/block/drbd/drbd_receiver.c                 |   3 +-
 drivers/block/mtip32xx/mtip32xx.c                  |   2 +-
 drivers/block/nvme-core.c                          |   4 +-
 drivers/block/osdblk.c                             |   2 +-
 drivers/block/paride/pd.c                          |   2 +-
 drivers/block/pktcdvd.c                            |   4 +-
 drivers/connector/connector.c                      |   3 +-
 drivers/firewire/core-cdev.c                       |   2 +-
 drivers/gpu/drm/i915/i915_gem.c                    |   4 +-
 drivers/ide/ide-atapi.c                            |   2 +-
 drivers/ide/ide-cd.c                               |   2 +-
 drivers/ide/ide-cd_ioctl.c                         |   2 +-
 drivers/ide/ide-devsets.c                          |   2 +-
 drivers/ide/ide-disk.c                             |   2 +-
 drivers/ide/ide-ioctls.c                           |   4 +-
 drivers/ide/ide-park.c                             |   2 +-
 drivers/ide/ide-pm.c                               |   4 +-
 drivers/ide/ide-tape.c                             |   4 +-
 drivers/ide/ide-taskfile.c                         |   4 +-
 drivers/infiniband/core/sa_query.c                 |   2 +-
 drivers/infiniband/hw/qib/qib_init.c               |   2 +-
 drivers/iommu/amd_iommu.c                          |   2 +-
 drivers/iommu/intel-iommu.c                        |   2 +-
 drivers/md/dm-crypt.c                              |   6 +-
 drivers/md/dm-kcopyd.c                             |   2 +-
 drivers/media/pci/solo6x10/solo6x10-v4l2-enc.c     |   2 +-
 drivers/media/pci/solo6x10/solo6x10-v4l2.c         |   2 +-
 drivers/media/pci/tw68/tw68-video.c                |   2 +-
 drivers/misc/vmw_balloon.c                         |   2 +-
 drivers/mtd/mtdcore.c                              |   3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   2 +-
 drivers/scsi/scsi_error.c                          |   2 +-
 drivers/scsi/scsi_lib.c                            |   4 +-
 drivers/staging/android/ion/ion_system_heap.c      |   2 +-
 .../lustre/include/linux/libcfs/libcfs_private.h   |   2 +-
 drivers/staging/rdma/hfi1/init.c                   |   2 +-
 drivers/staging/rdma/ipath/ipath_file_ops.c        |   2 +-
 drivers/usb/host/u132-hcd.c                        |   2 +-
 drivers/video/fbdev/vermilion/vermilion.c          |   2 +-
 fs/btrfs/disk-io.c                                 |   2 +-
 fs/btrfs/extent_io.c                               |  14 +-
 fs/btrfs/volumes.c                                 |   4 +-
 fs/cachefiles/internal.h                           |   2 +-
 fs/direct-io.c                                     |   2 +-
 fs/ext4/super.c                                    |   2 +-
 fs/fscache/cookie.c                                |   2 +-
 fs/fscache/page.c                                  |   6 +-
 fs/jbd2/transaction.c                              |   4 +-
 fs/nfs/file.c                                      |   6 +-
 fs/nilfs2/mdt.h                                    |   2 +-
 fs/xfs/xfs_qm.c                                    |   2 +-
 include/linux/cpuset.h                             |   6 +
 include/linux/gfp.h                                |  70 ++-
 include/linux/mmzone.h                             |  88 +--
 include/linux/skbuff.h                             |   6 +-
 include/net/sock.h                                 |   2 +-
 include/trace/events/gfpflags.h                    |   5 +-
 kernel/audit.c                                     |   6 +-
 kernel/cgroup.c                                    |   2 +-
 kernel/locking/lockdep.c                           |   2 +-
 kernel/power/snapshot.c                            |   2 +-
 kernel/power/swap.c                                |  14 +-
 kernel/smp.c                                       |   2 +-
 lib/idr.c                                          |   4 +-
 lib/percpu_ida.c                                   |   2 +-
 lib/radix-tree.c                                   |  10 +-
 mm/backing-dev.c                                   |   2 +-
 mm/dmapool.c                                       |   2 +-
 mm/failslab.c                                      |   8 +-
 mm/filemap.c                                       |   2 +-
 mm/huge_memory.c                                   |   4 +-
 mm/internal.h                                      |   1 +
 mm/memcontrol.c                                    |   8 +-
 mm/mempool.c                                       |  10 +-
 mm/migrate.c                                       |   4 +-
 mm/page_alloc.c                                    | 599 +++++++--------------
 mm/slab.c                                          |  18 +-
 mm/slub.c                                          |  10 +-
 mm/vmalloc.c                                       |   2 +-
 mm/vmscan.c                                        |   8 +-
 mm/vmstat.c                                        |   2 +-
 mm/zswap.c                                         |   5 +-
 net/core/skbuff.c                                  |   8 +-
 net/core/sock.c                                    |   6 +-
 net/netlink/af_netlink.c                           |   2 +-
 net/rds/ib_recv.c                                  |   4 +-
 net/rxrpc/ar-connection.c                          |   2 +-
 net/sctp/associola.c                               |   2 +-
 security/integrity/ima/ima_crypto.c                |   2 +-
 101 files changed, 466 insertions(+), 705 deletions(-)

-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
