Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C9F8B6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 04:16:03 -0400 (EDT)
Subject: [PATCH 0/2] mm: convert and remove kmap_atomic back-compatibility
 macro
From: Lin Ming <ming.m.lin@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 26 Aug 2011 16:15:59 +0800
Message-ID: <1314346559.6486.20.camel@minggr.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@vger.kernel.org, peterz@infradead.org

On Tue, Aug 23, 2011 at 4:43 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> That reminds me - we need to convert every "kmap_atomic(p, foo)" to
> "kmap_atomic(p)" then remove the kmap_atomic back-compatibility macro.

This 2 patches does what Andrew Morton suggested.

Build and tested on 32/64bit x86 kernel(allyesconfig) with 3G memory.

ARM, MIPS, PowerPc and Sparc are build tested only with
CONFIG_HIGHMEM=y and CONFIG_HIGHMEM=n.

I don't have cross-compiler for other arches.

[PATCH 1/2] mm: convert k{un}map_atomic(p, KM_type) to k{un}map_atomic(p)
[PATCH 2/2] mm: remove kmap_atomic back-compatibility macro

Lin Ming

---
 arch/arm/include/asm/highmem.h                |    2 +-
 arch/arm/mm/copypage-fa.c                     |   12 ++--
 arch/arm/mm/copypage-feroceon.c               |   12 ++--
 arch/arm/mm/copypage-v3.c                     |   12 ++--
 arch/arm/mm/copypage-v4mc.c                   |    8 +-
 arch/arm/mm/copypage-v4wb.c                   |   12 ++--
 arch/arm/mm/copypage-v4wt.c                   |   12 ++--
 arch/arm/mm/copypage-v6.c                     |   12 ++--
 arch/arm/mm/copypage-xsc3.c                   |   12 ++--
 arch/arm/mm/copypage-xscale.c                 |    8 +-
 arch/arm/mm/highmem.c                         |    4 +-
 arch/frv/include/asm/highmem.h                |    2 +-
 arch/frv/mm/highmem.c                         |    4 +-
 arch/mips/include/asm/highmem.h               |    2 +-
 arch/mips/mm/c-r4k.c                          |    4 +-
 arch/mips/mm/highmem.c                        |    4 +-
 arch/mips/mm/init.c                           |    8 +-
 arch/mn10300/include/asm/highmem.h            |    2 +-
 arch/parisc/include/asm/cacheflush.h          |    2 +-
 arch/powerpc/include/asm/highmem.h            |    2 +-
 arch/powerpc/kvm/book3s_pr.c                  |    4 +-
 arch/powerpc/mm/dma-noncoherent.c             |    5 +-
 arch/powerpc/mm/mem.c                         |    4 +-
 arch/sh/mm/cache-sh4.c                        |    4 +-
 arch/sh/mm/cache.c                            |   12 ++--
 arch/sparc/include/asm/highmem.h              |    2 +-
 arch/sparc/mm/highmem.c                       |    4 +-
 arch/tile/include/asm/highmem.h               |    2 +-
 arch/tile/mm/highmem.c                        |    4 +-
 arch/um/kernel/skas/uaccess.c                 |    4 +-
 arch/x86/include/asm/highmem.h                |    2 +-
 arch/x86/kernel/crash_dump_32.c               |    6 +-
 arch/x86/kvm/lapic.c                          |    8 +-
 arch/x86/kvm/paging_tmpl.h                    |    4 +-
 arch/x86/kvm/x86.c                            |    8 +-
 arch/x86/lib/usercopy_32.c                    |    4 +-
 arch/x86/mm/highmem_32.c                      |    4 +-
 crypto/async_tx/async_memcpy.c                |    8 +-
 drivers/ata/libata-sff.c                      |    8 +-
 drivers/block/brd.c                           |   20 +++---
 drivers/block/drbd/drbd_bitmap.c              |   16 ++--
 drivers/block/drbd/drbd_nl.c                  |    4 +-
 drivers/block/loop.c                          |   16 ++--
 drivers/block/pktcdvd.c                       |    8 +-
 drivers/crypto/hifn_795x.c                    |   10 ++--
 drivers/edac/edac_mc.c                        |    4 +-
 drivers/gpu/drm/drm_cache.c                   |    8 +-
 drivers/gpu/drm/i915/i915_gem.c               |    4 +-
 drivers/gpu/drm/i915/i915_gem_debug.c         |    6 +-
 drivers/gpu/drm/ttm/ttm_tt.c                  |   16 ++--
 drivers/gpu/drm/vmwgfx/vmwgfx_gmr.c           |    6 +-
 drivers/ide/ide-taskfile.c                    |    4 +-
 drivers/infiniband/ulp/iser/iser_memory.c     |    8 +-
 drivers/md/bitmap.c                           |   42 ++++++------
 drivers/md/dm-crypt.c                         |    8 +-
 drivers/media/video/ivtv/ivtv-udma.c          |    4 +-
 drivers/memstick/host/jmb38x_ms.c             |    4 +-
 drivers/memstick/host/tifm_ms.c               |    4 +-
 drivers/mmc/host/at91_mci.c                   |    8 +-
 drivers/mmc/host/msm_sdcc.c                   |    2 +-
 drivers/mmc/host/sdhci.c                      |    4 +-
 drivers/mmc/host/tifm_sd.c                    |   16 ++--
 drivers/mmc/host/tmio_mmc.h                   |    4 +-
 drivers/mmc/host/tmio_mmc_dma.c               |    4 +-
 drivers/mmc/host/tmio_mmc_pio.c               |    8 +-
 drivers/net/cassini.c                         |    4 +-
 drivers/net/e1000/e1000_main.c                |    6 +-
 drivers/net/e1000e/netdev.c                   |   10 +--
 drivers/scsi/arcmsr/arcmsr_hba.c              |    8 +-
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c             |    4 +-
 drivers/scsi/cxgbi/libcxgbi.c                 |    5 +-
 drivers/scsi/fcoe/fcoe.c                      |    4 +-
 drivers/scsi/fcoe/fcoe_transport.c            |    5 +-
 drivers/scsi/gdth.c                           |    4 +-
 drivers/scsi/ips.c                            |    6 +-
 drivers/scsi/isci/request.c                   |   12 ++--
 drivers/scsi/libfc/fc_fcp.c                   |    4 +-
 drivers/scsi/libfc/fc_libfc.c                 |    5 +-
 drivers/scsi/libiscsi_tcp.c                   |    4 +-
 drivers/scsi/libsas/sas_host_smp.c            |    8 +-
 drivers/scsi/megaraid.c                       |    4 +-
 drivers/scsi/mvsas/mv_sas.c                   |    4 +-
 drivers/scsi/scsi_debug.c                     |   24 +++---
 drivers/scsi/scsi_lib.c                       |    4 +-
 drivers/scsi/sd_dif.c                         |   12 ++--
 drivers/staging/gma500/mmu.c                  |   30 ++++----
 drivers/staging/hv/rndis_filter.c             |    2 +-
 drivers/staging/hv/storvsc_drv.c              |   10 ++--
 drivers/staging/pohmelfs/inode.c              |    8 +-
 drivers/staging/rtl8192u/ieee80211/internal.h |    4 +-
 drivers/staging/zcache/zcache-main.c          |   16 ++--
 drivers/staging/zram/xvmalloc.c               |    4 +-
 drivers/staging/zram/zram_drv.c               |   44 ++++++------
 drivers/target/target_core_transport.c        |    4 +-
 drivers/target/tcm_fc/tfc_io.c                |   10 +--
 drivers/vhost/vhost.c                         |    4 +-
 fs/afs/fsclient.c                             |    8 +-
 fs/afs/mntpt.c                                |    4 +-
 fs/aio.c                                      |   34 +++++-----
 fs/bio-integrity.c                            |   10 ++--
 fs/btrfs/compression.c                        |   12 ++--
 fs/btrfs/extent_io.c                          |   16 ++--
 fs/btrfs/file-item.c                          |    4 +-
 fs/btrfs/inode.c                              |   26 ++++----
 fs/btrfs/lzo.c                                |    4 +-
 fs/btrfs/scrub.c                              |    8 +-
 fs/btrfs/zlib.c                               |    4 +-
 fs/cifs/file.c                                |    4 +-
 fs/ecryptfs/mmap.c                            |    4 +-
 fs/ecryptfs/read_write.c                      |    8 +-
 fs/exec.c                                     |    4 +-
 fs/exofs/dir.c                                |    4 +-
 fs/ext2/dir.c                                 |    4 +-
 fs/fuse/dev.c                                 |    4 +-
 fs/fuse/file.c                                |    4 +-
 fs/gfs2/aops.c                                |   12 ++--
 fs/gfs2/lops.c                                |    8 +-
 fs/gfs2/quota.c                               |    4 +-
 fs/jbd/journal.c                              |   12 ++--
 fs/jbd/transaction.c                          |    4 +-
 fs/jbd2/commit.c                              |    4 +-
 fs/jbd2/journal.c                             |   12 ++--
 fs/jbd2/transaction.c                         |    4 +-
 fs/logfs/dir.c                                |   18 +++---
 fs/logfs/readwrite.c                          |   38 +++++-----
 fs/logfs/segment.c                            |    4 +-
 fs/minix/dir.c                                |    4 +-
 fs/namei.c                                    |    4 +-
 fs/nfs/dir.c                                  |    8 +-
 fs/nfs/nfs4proc.c                             |    4 +-
 fs/nilfs2/cpfile.c                            |   94 ++++++++++++------------
 fs/nilfs2/dat.c                               |   38 +++++-----
 fs/nilfs2/dir.c                               |    4 +-
 fs/nilfs2/ifile.c                             |    4 +-
 fs/nilfs2/mdt.c                               |    4 +-
 fs/nilfs2/page.c                              |    8 +-
 fs/nilfs2/recovery.c                          |    4 +-
 fs/nilfs2/segbuf.c                            |    4 +-
 fs/nilfs2/sufile.c                            |   68 +++++++++---------
 fs/ntfs/aops.c                                |   20 +++---
 fs/ntfs/attrib.c                              |   20 +++---
 fs/ntfs/file.c                                |   16 ++--
 fs/ntfs/super.c                               |    8 +-
 fs/ocfs2/aops.c                               |   16 ++--
 fs/pipe.c                                     |    8 +-
 fs/reiserfs/stree.c                           |    4 +-
 fs/reiserfs/tail_conversion.c                 |    4 +-
 fs/splice.c                                   |    4 +-
 fs/squashfs/file.c                            |    8 +-
 fs/squashfs/symlink.c                         |    4 +-
 fs/ubifs/file.c                               |    4 +-
 fs/udf/file.c                                 |    4 +-
 include/crypto/scatterwalk.h                  |    4 +-
 include/linux/bio.h                           |   10 ++--
 include/linux/highmem.h                       |   39 +++++------
 kernel/debug/kdb/kdb_support.c                |    4 +-
 kernel/power/snapshot.c                       |   28 ++++----
 lib/scatterlist.c                             |    4 +-
 lib/swiotlb.c                                 |    5 +-
 mm/bounce.c                                   |    4 +-
 mm/filemap.c                                  |    8 +-
 mm/ksm.c                                      |   12 ++--
 mm/memory.c                                   |    4 +-
 mm/shmem.c                                    |    4 +-
 mm/swapfile.c                                 |   30 ++++----
 mm/vmalloc.c                                  |    8 +-
 net/core/kmap_skb.h                           |    4 +-
 net/rds/ib_recv.c                             |    4 +-
 net/rds/info.c                                |    6 +-
 net/rds/iw_recv.c                             |    4 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c           |    4 +-
 net/sunrpc/socklib.c                          |    4 +-
 net/sunrpc/xdr.c                              |   20 +++---
 net/sunrpc/xprtrdma/rpc_rdma.c                |    8 +-
 security/tomoyo/domain.c                      |    4 +-
 175 files changed, 802 insertions(+), 818 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
