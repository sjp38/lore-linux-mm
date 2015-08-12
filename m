Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id F3CD26B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 06:45:38 -0400 (EDT)
Received: by wijp15 with SMTP id p15so212085098wij.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 03:45:38 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id o4si9844495wjx.75.2015.08.12.03.45.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Aug 2015 03:45:37 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id F27F598FCC
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 10:45:35 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 00/10] Remove zonelist cache and high-order watermark checking v2
Date: Wed, 12 Aug 2015 11:45:25 +0100
Message-Id: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Changelog since V1
o Rebase to 4.2-rc5
o Distinguish between high priority callers and callers that avoid sleep
o Remove jump label related damage patches

Overall, the intent of this series is to remove the zonelist cache which
was introduced to avoid high overhead in the page allocator. Once this is
done, it is necessary to reduce the cost of watermark checks.

The zonelist cache has been around for a long time but it is of dubious
merit with a lot of complexity. Some issues are explained in the first
patch but the most important is that a failed THP allocation can cause a
zone to be treated as "full". This potentially causes unnecessary stalls,
reclaim activity or remote fallbacks. The issues could be fixed but it's
not worth it. The series places a small number of other micro-optimisations
on top before examining GFP flags watermarks.

GFP flags specify the requirements of the caller. __GFP_WAIT historically
identified callers that could not sleep and could access reserves. This was
later abused to identify callers that simply prefer to avoid sleeping and
have other options. A patch is added to distinguish between atomic callers,
high-priority callers and those that simply wish to avoid sleep.

High-order watermarks enforcement can cause high-order allocations to fail
even though pages are free. The watermark checks both protect high-order
atomic allocations and make kswapd aware of high-order pages but there is
a much better way that can be handled using migrate types. This series uses
page grouping by mobility to reserve pageblocks for high-order allocations
with the size of the reservation depending on demand. kswapd awareness
is maintained by examining the free lists. By patch 10 in this series,
there are no high-order watermark checks while preserving the properties
that motivated the introduction of the watermark checks.

 Documentation/vm/balance                           |  14 +-
 arch/arm/mm/dma-mapping.c                          |   4 +-
 arch/arm64/mm/dma-mapping.c                        |   4 +-
 arch/x86/kernel/pci-dma.c                          |   2 +-
 block/bio.c                                        |  26 +-
 block/blk-core.c                                   |  16 +-
 block/blk-ioc.c                                    |   2 +-
 block/blk-mq-tag.c                                 |   2 +-
 block/blk-mq.c                                     |   8 +-
 block/cfq-iosched.c                                |   4 +-
 block/scsi_ioctl.c                                 |   6 +-
 drivers/block/drbd/drbd_bitmap.c                   |   2 +-
 drivers/block/drbd/drbd_receiver.c                 |   2 +-
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
 drivers/infiniband/hw/ipath/ipath_file_ops.c       |   2 +-
 drivers/infiniband/hw/qib/qib_init.c               |   2 +-
 drivers/iommu/amd_iommu.c                          |   2 +-
 drivers/iommu/intel-iommu.c                        |   2 +-
 drivers/md/dm-crypt.c                              |   6 +-
 drivers/misc/vmw_balloon.c                         |   2 +-
 drivers/mtd/mtdcore.c                              |   3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   2 +-
 drivers/scsi/scsi_error.c                          |   2 +-
 drivers/scsi/scsi_lib.c                            |   4 +-
 drivers/staging/android/ion/ion_system_heap.c      |   2 +-
 .../lustre/include/linux/libcfs/libcfs_private.h   |   2 +-
 drivers/usb/host/u132-hcd.c                        |   2 +-
 fs/btrfs/disk-io.c                                 |   2 +-
 fs/btrfs/extent_io.c                               |  14 +-
 fs/btrfs/volumes.c                                 |   4 +-
 fs/cachefiles/internal.h                           |   2 +-
 fs/direct-io.c                                     |   2 +-
 fs/ext3/super.c                                    |   2 +-
 fs/ext4/super.c                                    |   2 +-
 fs/fscache/cookie.c                                |   2 +-
 fs/fscache/page.c                                  |   6 +-
 fs/jbd/transaction.c                               |   4 +-
 fs/jbd2/transaction.c                              |   4 +-
 fs/nfs/file.c                                      |   6 +-
 fs/nilfs2/mdt.h                                    |   2 +-
 fs/xfs/xfs_qm.c                                    |   2 +-
 include/linux/cpuset.h                             |   6 +
 include/linux/gfp.h                                |  68 ++-
 include/linux/mmzone.h                             |  85 +--
 include/linux/skbuff.h                             |   6 +-
 include/net/sock.h                                 |   2 +-
 include/trace/events/gfpflags.h                    |   5 +-
 kernel/audit.c                                     |   6 +-
 kernel/locking/lockdep.c                           |   2 +-
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
 mm/migrate.c                                       |   2 +-
 mm/page_alloc.c                                    | 569 +++++++--------------
 mm/slab.c                                          |  18 +-
 mm/slub.c                                          |   6 +-
 mm/vmalloc.c                                       |   2 +-
 mm/vmscan.c                                        |   6 +-
 mm/vmstat.c                                        |   2 +-
 net/core/skbuff.c                                  |   8 +-
 net/core/sock.c                                    |   6 +-
 net/netlink/af_netlink.c                           |   2 +-
 net/rxrpc/ar-connection.c                          |   2 +-
 net/sctp/associola.c                               |   2 +-
 security/integrity/ima/ima_crypto.c                |   2 +-
 93 files changed, 424 insertions(+), 684 deletions(-)

-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
