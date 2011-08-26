Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CF0F56B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 04:18:09 -0400 (EDT)
Subject: [PATCH 1/2] mm: convert k{un}map_atomic(p, KM_type) to
 k{un}map_atomic(p)
From: Lin Ming <ming.m.lin@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 26 Aug 2011 16:17:56 +0800
Message-ID: <1314346676.6486.25.camel@minggr.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, peterz@infradead.org

The KM_type parameter for kmap_atomic/kunmap_atomic is not used anymore
since commit 3e4d3af(mm: stack based kmap_atomic()).

So convert k{un}map_atomic(p, KM_type) to k{un}map_atomic(p).
Most conversion are done by below commands. Some are done by hand.

find . -type f | xargs sed -i 's/\(kmap_atomic(.*\),\ .*)/\1)/'
find . -type f | xargs sed -i 's/\(kunmap_atomic(.*\),\ .*)/\1)/'

Build and tested on 32/64bit x86 kernel(allyesconfig) with 3G memory.

ARM, MIPS, PowerPc and Sparc are build tested only with
CONFIG_HIGHMEM=y and CONFIG_HIGHMEM=n.
I don't have cross-compiler for other arches.

Signed-off-by: Lin Ming <ming.m.lin@intel.com>
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
 arch/mips/mm/c-r4k.c                          |    4 +-
 arch/mips/mm/init.c                           |    8 +-
 arch/powerpc/kvm/book3s_pr.c                  |    4 +-
 arch/powerpc/mm/dma-noncoherent.c             |    5 +-
 arch/powerpc/mm/mem.c                         |    4 +-
 arch/sh/mm/cache-sh4.c                        |    4 +-
 arch/sh/mm/cache.c                            |   12 ++--
 arch/um/kernel/skas/uaccess.c                 |    4 +-
 arch/x86/kernel/crash_dump_32.c               |    6 +-
 arch/x86/kvm/lapic.c                          |    8 +-
 arch/x86/kvm/paging_tmpl.h                    |    4 +-
 arch/x86/kvm/x86.c                            |    8 +-
 arch/x86/lib/usercopy_32.c                    |    4 +-
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
 include/linux/highmem.h                       |   30 ++++----
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
 161 files changed, 780 insertions(+), 791 deletions(-)

diff --git a/arch/arm/include/asm/highmem.h b/arch/arm/include/asm/highmem.h
index a4edd19..8c5e828 100644
--- a/arch/arm/include/asm/highmem.h
+++ b/arch/arm/include/asm/highmem.h
@@ -57,7 +57,7 @@ static inline void *kmap_high_get(struct page *page)
 #ifdef CONFIG_HIGHMEM
 extern void *kmap(struct page *page);
 extern void kunmap(struct page *page);
-extern void *__kmap_atomic(struct page *page);
+extern void *kmap_atomic(struct page *page);
 extern void __kunmap_atomic(void *kvaddr);
 extern void *kmap_atomic_pfn(unsigned long pfn);
 extern struct page *kmap_atomic_to_page(const void *ptr);
diff --git a/arch/arm/mm/copypage-fa.c b/arch/arm/mm/copypage-fa.c
index d2852e1..d130a5e 100644
--- a/arch/arm/mm/copypage-fa.c
+++ b/arch/arm/mm/copypage-fa.c
@@ -44,11 +44,11 @@ void fa_copy_user_highpage(struct page *to, struct page *from,
 {
 	void *kto, *kfrom;
 
-	kto = kmap_atomic(to, KM_USER0);
-	kfrom = kmap_atomic(from, KM_USER1);
+	kto = kmap_atomic(to);
+	kfrom = kmap_atomic(from);
 	fa_copy_user_page(kto, kfrom);
-	kunmap_atomic(kfrom, KM_USER1);
-	kunmap_atomic(kto, KM_USER0);
+	kunmap_atomic(kfrom);
+	kunmap_atomic(kto);
 }
 
 /*
@@ -58,7 +58,7 @@ void fa_copy_user_highpage(struct page *to, struct page *from,
  */
 void fa_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile("\
 	mov	r1, %2				@ 1\n\
 	mov	r2, #0				@ 1\n\
@@ -77,7 +77,7 @@ void fa_clear_user_highpage(struct page *page, unsigned long vaddr)
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 32)
 	: "r1", "r2", "r3", "ip", "lr");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns fa_user_fns __initdata = {
diff --git a/arch/arm/mm/copypage-feroceon.c b/arch/arm/mm/copypage-feroceon.c
index ac163de..49ee0c1 100644
--- a/arch/arm/mm/copypage-feroceon.c
+++ b/arch/arm/mm/copypage-feroceon.c
@@ -72,17 +72,17 @@ void feroceon_copy_user_highpage(struct page *to, struct page *from,
 {
 	void *kto, *kfrom;
 
-	kto = kmap_atomic(to, KM_USER0);
-	kfrom = kmap_atomic(from, KM_USER1);
+	kto = kmap_atomic(to);
+	kfrom = kmap_atomic(from);
 	flush_cache_page(vma, vaddr, page_to_pfn(from));
 	feroceon_copy_user_page(kto, kfrom);
-	kunmap_atomic(kfrom, KM_USER1);
-	kunmap_atomic(kto, KM_USER0);
+	kunmap_atomic(kfrom);
+	kunmap_atomic(kto);
 }
 
 void feroceon_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile ("\
 	mov	r1, %2				\n\
 	mov	r2, #0				\n\
@@ -102,7 +102,7 @@ void feroceon_clear_user_highpage(struct page *page, unsigned long vaddr)
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 32)
 	: "r1", "r2", "r3", "r4", "r5", "r6", "r7", "ip", "lr");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns feroceon_user_fns __initdata = {
diff --git a/arch/arm/mm/copypage-v3.c b/arch/arm/mm/copypage-v3.c
index f72303e..3935bdd 100644
--- a/arch/arm/mm/copypage-v3.c
+++ b/arch/arm/mm/copypage-v3.c
@@ -42,11 +42,11 @@ void v3_copy_user_highpage(struct page *to, struct page *from,
 {
 	void *kto, *kfrom;
 
-	kto = kmap_atomic(to, KM_USER0);
-	kfrom = kmap_atomic(from, KM_USER1);
+	kto = kmap_atomic(to);
+	kfrom = kmap_atomic(from);
 	v3_copy_user_page(kto, kfrom);
-	kunmap_atomic(kfrom, KM_USER1);
-	kunmap_atomic(kto, KM_USER0);
+	kunmap_atomic(kfrom);
+	kunmap_atomic(kto);
 }
 
 /*
@@ -56,7 +56,7 @@ void v3_copy_user_highpage(struct page *to, struct page *from,
  */
 void v3_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile("\n\
 	mov	r1, %2				@ 1\n\
 	mov	r2, #0				@ 1\n\
@@ -72,7 +72,7 @@ void v3_clear_user_highpage(struct page *page, unsigned long vaddr)
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 64)
 	: "r1", "r2", "r3", "ip", "lr");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns v3_user_fns __initdata = {
diff --git a/arch/arm/mm/copypage-v4mc.c b/arch/arm/mm/copypage-v4mc.c
index b806151..5e5000f 100644
--- a/arch/arm/mm/copypage-v4mc.c
+++ b/arch/arm/mm/copypage-v4mc.c
@@ -71,7 +71,7 @@ mc_copy_user_page(void *from, void *to)
 void v4_mc_copy_user_highpage(struct page *to, struct page *from,
 	unsigned long vaddr, struct vm_area_struct *vma)
 {
-	void *kto = kmap_atomic(to, KM_USER1);
+	void *kto = kmap_atomic(to);
 
 	if (!test_and_set_bit(PG_dcache_clean, &from->flags))
 		__flush_dcache_page(page_mapping(from), from);
@@ -85,7 +85,7 @@ void v4_mc_copy_user_highpage(struct page *to, struct page *from,
 
 	spin_unlock(&minicache_lock);
 
-	kunmap_atomic(kto, KM_USER1);
+	kunmap_atomic(kto);
 }
 
 /*
@@ -93,7 +93,7 @@ void v4_mc_copy_user_highpage(struct page *to, struct page *from,
  */
 void v4_mc_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile("\
 	mov	r1, %2				@ 1\n\
 	mov	r2, #0				@ 1\n\
@@ -111,7 +111,7 @@ void v4_mc_clear_user_highpage(struct page *page, unsigned long vaddr)
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 64)
 	: "r1", "r2", "r3", "ip", "lr");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns v4_mc_user_fns __initdata = {
diff --git a/arch/arm/mm/copypage-v4wb.c b/arch/arm/mm/copypage-v4wb.c
index cb589cb..067d0fd 100644
--- a/arch/arm/mm/copypage-v4wb.c
+++ b/arch/arm/mm/copypage-v4wb.c
@@ -52,12 +52,12 @@ void v4wb_copy_user_highpage(struct page *to, struct page *from,
 {
 	void *kto, *kfrom;
 
-	kto = kmap_atomic(to, KM_USER0);
-	kfrom = kmap_atomic(from, KM_USER1);
+	kto = kmap_atomic(to);
+	kfrom = kmap_atomic(from);
 	flush_cache_page(vma, vaddr, page_to_pfn(from));
 	v4wb_copy_user_page(kto, kfrom);
-	kunmap_atomic(kfrom, KM_USER1);
-	kunmap_atomic(kto, KM_USER0);
+	kunmap_atomic(kfrom);
+	kunmap_atomic(kto);
 }
 
 /*
@@ -67,7 +67,7 @@ void v4wb_copy_user_highpage(struct page *to, struct page *from,
  */
 void v4wb_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile("\
 	mov	r1, %2				@ 1\n\
 	mov	r2, #0				@ 1\n\
@@ -86,7 +86,7 @@ void v4wb_clear_user_highpage(struct page *page, unsigned long vaddr)
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 64)
 	: "r1", "r2", "r3", "ip", "lr");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns v4wb_user_fns __initdata = {
diff --git a/arch/arm/mm/copypage-v4wt.c b/arch/arm/mm/copypage-v4wt.c
index 30c7d04..b85c5da 100644
--- a/arch/arm/mm/copypage-v4wt.c
+++ b/arch/arm/mm/copypage-v4wt.c
@@ -48,11 +48,11 @@ void v4wt_copy_user_highpage(struct page *to, struct page *from,
 {
 	void *kto, *kfrom;
 
-	kto = kmap_atomic(to, KM_USER0);
-	kfrom = kmap_atomic(from, KM_USER1);
+	kto = kmap_atomic(to);
+	kfrom = kmap_atomic(from);
 	v4wt_copy_user_page(kto, kfrom);
-	kunmap_atomic(kfrom, KM_USER1);
-	kunmap_atomic(kto, KM_USER0);
+	kunmap_atomic(kfrom);
+	kunmap_atomic(kto);
 }
 
 /*
@@ -62,7 +62,7 @@ void v4wt_copy_user_highpage(struct page *to, struct page *from,
  */
 void v4wt_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile("\
 	mov	r1, %2				@ 1\n\
 	mov	r2, #0				@ 1\n\
@@ -79,7 +79,7 @@ void v4wt_clear_user_highpage(struct page *page, unsigned long vaddr)
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 64)
 	: "r1", "r2", "r3", "ip", "lr");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns v4wt_user_fns __initdata = {
diff --git a/arch/arm/mm/copypage-v6.c b/arch/arm/mm/copypage-v6.c
index 63cca00..e49a497 100644
--- a/arch/arm/mm/copypage-v6.c
+++ b/arch/arm/mm/copypage-v6.c
@@ -38,11 +38,11 @@ static void v6_copy_user_highpage_nonaliasing(struct page *to,
 {
 	void *kto, *kfrom;
 
-	kfrom = kmap_atomic(from, KM_USER0);
-	kto = kmap_atomic(to, KM_USER1);
+	kfrom = kmap_atomic(from);
+	kto = kmap_atomic(to);
 	copy_page(kto, kfrom);
-	kunmap_atomic(kto, KM_USER1);
-	kunmap_atomic(kfrom, KM_USER0);
+	kunmap_atomic(kto);
+	kunmap_atomic(kfrom);
 }
 
 /*
@@ -51,9 +51,9 @@ static void v6_copy_user_highpage_nonaliasing(struct page *to,
  */
 static void v6_clear_user_highpage_nonaliasing(struct page *page, unsigned long vaddr)
 {
-	void *kaddr = kmap_atomic(page, KM_USER0);
+	void *kaddr = kmap_atomic(page);
 	clear_page(kaddr);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 /*
diff --git a/arch/arm/mm/copypage-xsc3.c b/arch/arm/mm/copypage-xsc3.c
index f9cde07..03a2042 100644
--- a/arch/arm/mm/copypage-xsc3.c
+++ b/arch/arm/mm/copypage-xsc3.c
@@ -75,12 +75,12 @@ void xsc3_mc_copy_user_highpage(struct page *to, struct page *from,
 {
 	void *kto, *kfrom;
 
-	kto = kmap_atomic(to, KM_USER0);
-	kfrom = kmap_atomic(from, KM_USER1);
+	kto = kmap_atomic(to);
+	kfrom = kmap_atomic(from);
 	flush_cache_page(vma, vaddr, page_to_pfn(from));
 	xsc3_mc_copy_user_page(kto, kfrom);
-	kunmap_atomic(kfrom, KM_USER1);
-	kunmap_atomic(kto, KM_USER0);
+	kunmap_atomic(kfrom);
+	kunmap_atomic(kto);
 }
 
 /*
@@ -90,7 +90,7 @@ void xsc3_mc_copy_user_highpage(struct page *to, struct page *from,
  */
 void xsc3_mc_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile ("\
 	mov	r1, %2				\n\
 	mov	r2, #0				\n\
@@ -105,7 +105,7 @@ void xsc3_mc_clear_user_highpage(struct page *page, unsigned long vaddr)
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 32)
 	: "r1", "r2", "r3");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns xsc3_mc_user_fns __initdata = {
diff --git a/arch/arm/mm/copypage-xscale.c b/arch/arm/mm/copypage-xscale.c
index 649bbcd..6ad51dc 100644
--- a/arch/arm/mm/copypage-xscale.c
+++ b/arch/arm/mm/copypage-xscale.c
@@ -93,7 +93,7 @@ mc_copy_user_page(void *from, void *to)
 void xscale_mc_copy_user_highpage(struct page *to, struct page *from,
 	unsigned long vaddr, struct vm_area_struct *vma)
 {
-	void *kto = kmap_atomic(to, KM_USER1);
+	void *kto = kmap_atomic(to);
 
 	if (!test_and_set_bit(PG_dcache_clean, &from->flags))
 		__flush_dcache_page(page_mapping(from), from);
@@ -107,7 +107,7 @@ void xscale_mc_copy_user_highpage(struct page *to, struct page *from,
 
 	spin_unlock(&minicache_lock);
 
-	kunmap_atomic(kto, KM_USER1);
+	kunmap_atomic(kto);
 }
 
 /*
@@ -116,7 +116,7 @@ void xscale_mc_copy_user_highpage(struct page *to, struct page *from,
 void
 xscale_mc_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile(
 	"mov	r1, %2				\n\
 	mov	r2, #0				\n\
@@ -133,7 +133,7 @@ xscale_mc_clear_user_highpage(struct page *page, unsigned long vaddr)
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 32)
 	: "r1", "r2", "r3", "ip");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns xscale_mc_user_fns __initdata = {
diff --git a/arch/mips/mm/c-r4k.c b/arch/mips/mm/c-r4k.c
index b9aabb9..68aadcf 100644
--- a/arch/mips/mm/c-r4k.c
+++ b/arch/mips/mm/c-r4k.c
@@ -498,7 +498,7 @@ static inline void local_r4k_flush_cache_page(void *args)
 		if (map_coherent)
 			vaddr = kmap_coherent(page, addr);
 		else
-			vaddr = kmap_atomic(page, KM_USER0);
+			vaddr = kmap_atomic(page);
 		addr = (unsigned long)vaddr;
 	}
 
@@ -521,7 +521,7 @@ static inline void local_r4k_flush_cache_page(void *args)
 		if (map_coherent)
 			kunmap_coherent();
 		else
-			kunmap_atomic(vaddr, KM_USER0);
+			kunmap_atomic(vaddr);
 	}
 }
 
diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index b7ebc4f..fbc70f3 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -207,21 +207,21 @@ void copy_user_highpage(struct page *to, struct page *from,
 {
 	void *vfrom, *vto;
 
-	vto = kmap_atomic(to, KM_USER1);
+	vto = kmap_atomic(to);
 	if (cpu_has_dc_aliases &&
 	    page_mapped(from) && !Page_dcache_dirty(from)) {
 		vfrom = kmap_coherent(from, vaddr);
 		copy_page(vto, vfrom);
 		kunmap_coherent();
 	} else {
-		vfrom = kmap_atomic(from, KM_USER0);
+		vfrom = kmap_atomic(from);
 		copy_page(vto, vfrom);
-		kunmap_atomic(vfrom, KM_USER0);
+		kunmap_atomic(vfrom);
 	}
 	if ((!cpu_has_ic_fills_f_dc) ||
 	    pages_do_alias((unsigned long)vto, vaddr & PAGE_MASK))
 		flush_data_cache_page((unsigned long)vto);
-	kunmap_atomic(vto, KM_USER1);
+	kunmap_atomic(vto);
 	/* Make sure this page is cleared on other CPU's too before using it */
 	smp_wmb();
 }
diff --git a/arch/powerpc/kvm/book3s_pr.c b/arch/powerpc/kvm/book3s_pr.c
index 0c0d3f2..2987939 100644
--- a/arch/powerpc/kvm/book3s_pr.c
+++ b/arch/powerpc/kvm/book3s_pr.c
@@ -222,14 +222,14 @@ static void kvmppc_patch_dcbz(struct kvm_vcpu *vcpu, struct kvmppc_pte *pte)
 	hpage_offset /= 4;
 
 	get_page(hpage);
-	page = kmap_atomic(hpage, KM_USER0);
+	page = kmap_atomic(hpage);
 
 	/* patch dcbz into reserved instruction, so we trap */
 	for (i=hpage_offset; i < hpage_offset + (HW_PAGE_SIZE / 4); i++)
 		if ((page[i] & 0xff0007ff) == INS_DCBZ)
 			page[i] &= 0xfffffff7;
 
-	kunmap_atomic(page, KM_USER0);
+	kunmap_atomic(page);
 	put_page(hpage);
 }
 
diff --git a/arch/powerpc/mm/dma-noncoherent.c b/arch/powerpc/mm/dma-noncoherent.c
index b42f76c..3147da3 100644
--- a/arch/powerpc/mm/dma-noncoherent.c
+++ b/arch/powerpc/mm/dma-noncoherent.c
@@ -364,12 +364,11 @@ static inline void __dma_sync_page_highmem(struct page *page,
 	local_irq_save(flags);
 
 	do {
-		start = (unsigned long)kmap_atomic(page + seg_nr,
-				KM_PPC_SYNC_PAGE) + seg_offset;
+		start = (unsigned long)kmap_atomic(page + seg_nr) + seg_offset;
 
 		/* Sync this buffer segment */
 		__dma_sync((void *)start, seg_size, direction);
-		kunmap_atomic((void *)start, KM_PPC_SYNC_PAGE);
+		kunmap_atomic((void *)start);
 		seg_nr++;
 
 		/* Calculate next buffer segment size */
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index c781bbc..ac1910b 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -455,9 +455,9 @@ void flush_dcache_icache_page(struct page *page)
 #endif
 #ifdef CONFIG_BOOKE
 	{
-		void *start = kmap_atomic(page, KM_PPC_SYNC_ICACHE);
+		void *start = kmap_atomic(page);
 		__flush_dcache_icache(start);
-		kunmap_atomic(start, KM_PPC_SYNC_ICACHE);
+		kunmap_atomic(start);
 	}
 #elif defined(CONFIG_8xx) || defined(CONFIG_PPC64)
 	/* On 8xx there is no need to kmap since highmem is not supported */
diff --git a/arch/sh/mm/cache-sh4.c b/arch/sh/mm/cache-sh4.c
index 92eb986..112fea1 100644
--- a/arch/sh/mm/cache-sh4.c
+++ b/arch/sh/mm/cache-sh4.c
@@ -244,7 +244,7 @@ static void sh4_flush_cache_page(void *args)
 		if (map_coherent)
 			vaddr = kmap_coherent(page, address);
 		else
-			vaddr = kmap_atomic(page, KM_USER0);
+			vaddr = kmap_atomic(page);
 
 		address = (unsigned long)vaddr;
 	}
@@ -259,7 +259,7 @@ static void sh4_flush_cache_page(void *args)
 		if (map_coherent)
 			kunmap_coherent(vaddr);
 		else
-			kunmap_atomic(vaddr, KM_USER0);
+			kunmap_atomic(vaddr);
 	}
 }
 
diff --git a/arch/sh/mm/cache.c b/arch/sh/mm/cache.c
index 5a580ea..616966a 100644
--- a/arch/sh/mm/cache.c
+++ b/arch/sh/mm/cache.c
@@ -95,7 +95,7 @@ void copy_user_highpage(struct page *to, struct page *from,
 {
 	void *vfrom, *vto;
 
-	vto = kmap_atomic(to, KM_USER1);
+	vto = kmap_atomic(to);
 
 	if (boot_cpu_data.dcache.n_aliases && page_mapped(from) &&
 	    test_bit(PG_dcache_clean, &from->flags)) {
@@ -103,16 +103,16 @@ void copy_user_highpage(struct page *to, struct page *from,
 		copy_page(vto, vfrom);
 		kunmap_coherent(vfrom);
 	} else {
-		vfrom = kmap_atomic(from, KM_USER0);
+		vfrom = kmap_atomic(from);
 		copy_page(vto, vfrom);
-		kunmap_atomic(vfrom, KM_USER0);
+		kunmap_atomic(vfrom);
 	}
 
 	if (pages_do_alias((unsigned long)vto, vaddr & PAGE_MASK) ||
 	    (vma->vm_flags & VM_EXEC))
 		__flush_purge_region(vto, PAGE_SIZE);
 
-	kunmap_atomic(vto, KM_USER1);
+	kunmap_atomic(vto);
 	/* Make sure this page is cleared on other CPU's too before using it */
 	smp_wmb();
 }
@@ -120,14 +120,14 @@ EXPORT_SYMBOL(copy_user_highpage);
 
 void clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *kaddr = kmap_atomic(page, KM_USER0);
+	void *kaddr = kmap_atomic(page);
 
 	clear_page(kaddr);
 
 	if (pages_do_alias((unsigned long)kaddr, vaddr & PAGE_MASK))
 		__flush_purge_region(kaddr, PAGE_SIZE);
 
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 EXPORT_SYMBOL(clear_user_highpage);
 
diff --git a/arch/um/kernel/skas/uaccess.c b/arch/um/kernel/skas/uaccess.c
index 6966342..92b8b81 100644
--- a/arch/um/kernel/skas/uaccess.c
+++ b/arch/um/kernel/skas/uaccess.c
@@ -68,7 +68,7 @@ static int do_op_one_page(unsigned long addr, int len, int is_write,
 		return -1;
 
 	page = pte_page(*pte);
-	addr = (unsigned long) kmap_atomic(page, KM_UML_USERCOPY) +
+	addr = (unsigned long) kmap_atomic(page) +
 		(addr & ~PAGE_MASK);
 
 	current->thread.fault_catcher = &buf;
@@ -81,7 +81,7 @@ static int do_op_one_page(unsigned long addr, int len, int is_write,
 
 	current->thread.fault_catcher = NULL;
 
-	kunmap_atomic((void *)addr, KM_UML_USERCOPY);
+	kunmap_atomic((void *)addr);
 
 	return n;
 }
diff --git a/arch/x86/kernel/crash_dump_32.c b/arch/x86/kernel/crash_dump_32.c
index 642f75a..11891ca 100644
--- a/arch/x86/kernel/crash_dump_32.c
+++ b/arch/x86/kernel/crash_dump_32.c
@@ -62,16 +62,16 @@ ssize_t copy_oldmem_page(unsigned long pfn, char *buf,
 
 	if (!userbuf) {
 		memcpy(buf, (vaddr + offset), csize);
-		kunmap_atomic(vaddr, KM_PTE0);
+		kunmap_atomic(vaddr);
 	} else {
 		if (!kdump_buf_page) {
 			printk(KERN_WARNING "Kdump: Kdump buffer page not"
 				" allocated\n");
-			kunmap_atomic(vaddr, KM_PTE0);
+			kunmap_atomic(vaddr);
 			return -EFAULT;
 		}
 		copy_page(kdump_buf_page, vaddr);
-		kunmap_atomic(vaddr, KM_PTE0);
+		kunmap_atomic(vaddr);
 		if (copy_to_user(buf, (kdump_buf_page + offset), csize))
 			return -EFAULT;
 	}
diff --git a/arch/x86/kvm/lapic.c b/arch/x86/kvm/lapic.c
index 57dcbd4..0d6a6e2 100644
--- a/arch/x86/kvm/lapic.c
+++ b/arch/x86/kvm/lapic.c
@@ -1179,9 +1179,9 @@ void kvm_lapic_sync_from_vapic(struct kvm_vcpu *vcpu)
 	if (!irqchip_in_kernel(vcpu->kvm) || !vcpu->arch.apic->vapic_addr)
 		return;
 
-	vapic = kmap_atomic(vcpu->arch.apic->vapic_page, KM_USER0);
+	vapic = kmap_atomic(vcpu->arch.apic->vapic_page);
 	data = *(u32 *)(vapic + offset_in_page(vcpu->arch.apic->vapic_addr));
-	kunmap_atomic(vapic, KM_USER0);
+	kunmap_atomic(vapic);
 
 	apic_set_tpr(vcpu->arch.apic, data & 0xff);
 }
@@ -1206,9 +1206,9 @@ void kvm_lapic_sync_to_vapic(struct kvm_vcpu *vcpu)
 		max_isr = 0;
 	data = (tpr & 0xff) | ((max_isr & 0xf0) << 8) | (max_irr << 24);
 
-	vapic = kmap_atomic(vcpu->arch.apic->vapic_page, KM_USER0);
+	vapic = kmap_atomic(vcpu->arch.apic->vapic_page);
 	*(u32 *)(vapic + offset_in_page(vcpu->arch.apic->vapic_addr)) = data;
-	kunmap_atomic(vapic, KM_USER0);
+	kunmap_atomic(vapic);
 }
 
 void kvm_lapic_set_vapic_addr(struct kvm_vcpu *vcpu, gpa_t vapic_addr)
diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
index 507e2b8..66a718b 100644
--- a/arch/x86/kvm/paging_tmpl.h
+++ b/arch/x86/kvm/paging_tmpl.h
@@ -92,9 +92,9 @@ static int FNAME(cmpxchg_gpte)(struct kvm_vcpu *vcpu, struct kvm_mmu *mmu,
 	if (unlikely(npages != 1))
 		return -EFAULT;
 
-	table = kmap_atomic(page, KM_USER0);
+	table = kmap_atomic(page);
 	ret = CMPXCHG(&table[index], orig_pte, new_pte);
-	kunmap_atomic(table, KM_USER0);
+	kunmap_atomic(table);
 
 	kvm_release_page_dirty(page);
 
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 84a28ea..8aec349 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -1185,12 +1185,12 @@ static int kvm_guest_time_update(struct kvm_vcpu *v)
 	 */
 	vcpu->hv_clock.version += 2;
 
-	shared_kaddr = kmap_atomic(vcpu->time_page, KM_USER0);
+	shared_kaddr = kmap_atomic(vcpu->time_page);
 
 	memcpy(shared_kaddr + vcpu->time_offset, &vcpu->hv_clock,
 	       sizeof(vcpu->hv_clock));
 
-	kunmap_atomic(shared_kaddr, KM_USER0);
+	kunmap_atomic(shared_kaddr);
 
 	mark_page_dirty(v->kvm, vcpu->time >> PAGE_SHIFT);
 	return 0;
@@ -4227,7 +4227,7 @@ static int emulator_cmpxchg_emulated(struct x86_emulate_ctxt *ctxt,
 		goto emul_write;
 	}
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	kaddr += offset_in_page(gpa);
 	switch (bytes) {
 	case 1:
@@ -4245,7 +4245,7 @@ static int emulator_cmpxchg_emulated(struct x86_emulate_ctxt *ctxt,
 	default:
 		BUG();
 	}
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	kvm_release_page_dirty(page);
 
 	if (!exchanged)
diff --git a/arch/x86/lib/usercopy_32.c b/arch/x86/lib/usercopy_32.c
index e218d5d..d9b094c 100644
--- a/arch/x86/lib/usercopy_32.c
+++ b/arch/x86/lib/usercopy_32.c
@@ -760,9 +760,9 @@ survive:
 				break;
 			}
 
-			maddr = kmap_atomic(pg, KM_USER0);
+			maddr = kmap_atomic(pg);
 			memcpy(maddr + offset, from, len);
-			kunmap_atomic(maddr, KM_USER0);
+			kunmap_atomic(maddr);
 			set_page_dirty_lock(pg);
 			put_page(pg);
 			up_read(&current->mm->mmap_sem);
diff --git a/crypto/async_tx/async_memcpy.c b/crypto/async_tx/async_memcpy.c
index 518c22b..e7820fc 100644
--- a/crypto/async_tx/async_memcpy.c
+++ b/crypto/async_tx/async_memcpy.c
@@ -78,13 +78,13 @@ async_memcpy(struct page *dest, struct page *src, unsigned int dest_offset,
 		/* wait for any prerequisite operations */
 		async_tx_quiesce(&submit->depend_tx);
 
-		dest_buf = kmap_atomic(dest, KM_USER0) + dest_offset;
-		src_buf = kmap_atomic(src, KM_USER1) + src_offset;
+		dest_buf = kmap_atomic(dest) + dest_offset;
+		src_buf = kmap_atomic(src) + src_offset;
 
 		memcpy(dest_buf, src_buf, len);
 
-		kunmap_atomic(src_buf, KM_USER1);
-		kunmap_atomic(dest_buf, KM_USER0);
+		kunmap_atomic(src_buf);
+		kunmap_atomic(dest_buf);
 
 		async_tx_sync_epilog(submit);
 	}
diff --git a/drivers/ata/libata-sff.c b/drivers/ata/libata-sff.c
index c24127d..64625ba 100644
--- a/drivers/ata/libata-sff.c
+++ b/drivers/ata/libata-sff.c
@@ -719,13 +719,13 @@ static void ata_pio_sector(struct ata_queued_cmd *qc)
 
 		/* FIXME: use a bounce buffer */
 		local_irq_save(flags);
-		buf = kmap_atomic(page, KM_IRQ0);
+		buf = kmap_atomic(page);
 
 		/* do the actual data transfer */
 		ap->ops->sff_data_xfer(qc->dev, buf + offset, qc->sect_size,
 				       do_write);
 
-		kunmap_atomic(buf, KM_IRQ0);
+		kunmap_atomic(buf);
 		local_irq_restore(flags);
 	} else {
 		buf = page_address(page);
@@ -864,13 +864,13 @@ next_sg:
 
 		/* FIXME: use bounce buffer */
 		local_irq_save(flags);
-		buf = kmap_atomic(page, KM_IRQ0);
+		buf = kmap_atomic(page);
 
 		/* do the actual data transfer */
 		consumed = ap->ops->sff_data_xfer(dev,  buf + offset,
 								count, rw);
 
-		kunmap_atomic(buf, KM_IRQ0);
+		kunmap_atomic(buf);
 		local_irq_restore(flags);
 	} else {
 		buf = page_address(page);
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index dba1c32..9ac4cb1 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -242,9 +242,9 @@ static void copy_to_brd(struct brd_device *brd, const void *src,
 	page = brd_lookup_page(brd, sector);
 	BUG_ON(!page);
 
-	dst = kmap_atomic(page, KM_USER1);
+	dst = kmap_atomic(page);
 	memcpy(dst + offset, src, copy);
-	kunmap_atomic(dst, KM_USER1);
+	kunmap_atomic(dst);
 
 	if (copy < n) {
 		src += copy;
@@ -253,9 +253,9 @@ static void copy_to_brd(struct brd_device *brd, const void *src,
 		page = brd_lookup_page(brd, sector);
 		BUG_ON(!page);
 
-		dst = kmap_atomic(page, KM_USER1);
+		dst = kmap_atomic(page);
 		memcpy(dst, src, copy);
-		kunmap_atomic(dst, KM_USER1);
+		kunmap_atomic(dst);
 	}
 }
 
@@ -273,9 +273,9 @@ static void copy_from_brd(void *dst, struct brd_device *brd,
 	copy = min_t(size_t, n, PAGE_SIZE - offset);
 	page = brd_lookup_page(brd, sector);
 	if (page) {
-		src = kmap_atomic(page, KM_USER1);
+		src = kmap_atomic(page);
 		memcpy(dst, src + offset, copy);
-		kunmap_atomic(src, KM_USER1);
+		kunmap_atomic(src);
 	} else
 		memset(dst, 0, copy);
 
@@ -285,9 +285,9 @@ static void copy_from_brd(void *dst, struct brd_device *brd,
 		copy = n - copy;
 		page = brd_lookup_page(brd, sector);
 		if (page) {
-			src = kmap_atomic(page, KM_USER1);
+			src = kmap_atomic(page);
 			memcpy(dst, src, copy);
-			kunmap_atomic(src, KM_USER1);
+			kunmap_atomic(src);
 		} else
 			memset(dst, 0, copy);
 	}
@@ -309,7 +309,7 @@ static int brd_do_bvec(struct brd_device *brd, struct page *page,
 			goto out;
 	}
 
-	mem = kmap_atomic(page, KM_USER0);
+	mem = kmap_atomic(page);
 	if (rw == READ) {
 		copy_from_brd(mem + off, brd, sector, len);
 		flush_dcache_page(page);
@@ -317,7 +317,7 @@ static int brd_do_bvec(struct brd_device *brd, struct page *page,
 		flush_dcache_page(page);
 		copy_to_brd(brd, mem + off, sector, len);
 	}
-	kunmap_atomic(mem, KM_USER0);
+	kunmap_atomic(mem);
 
 out:
 	return err;
diff --git a/drivers/block/drbd/drbd_bitmap.c b/drivers/block/drbd/drbd_bitmap.c
index 7b97629..486f7b4 100644
--- a/drivers/block/drbd/drbd_bitmap.c
+++ b/drivers/block/drbd/drbd_bitmap.c
@@ -292,7 +292,7 @@ static unsigned int bm_bit_to_page_idx(struct drbd_bitmap *b, u64 bitnr)
 static unsigned long *__bm_map_pidx(struct drbd_bitmap *b, unsigned int idx, const enum km_type km)
 {
 	struct page *page = b->bm_pages[idx];
-	return (unsigned long *) kmap_atomic(page, km);
+	return (unsigned long *) kmap_atomic(page);
 }
 
 static unsigned long *bm_map_pidx(struct drbd_bitmap *b, unsigned int idx)
@@ -302,7 +302,7 @@ static unsigned long *bm_map_pidx(struct drbd_bitmap *b, unsigned int idx)
 
 static void __bm_unmap(unsigned long *p_addr, const enum km_type km)
 {
-	kunmap_atomic(p_addr, km);
+	kunmap_atomic(p_addr);
 };
 
 static void bm_unmap(unsigned long *p_addr)
@@ -971,11 +971,11 @@ static void bm_page_io_async(struct bm_aio_ctx *ctx, int page_nr, int rw) __must
 		 * to use pre-allocated page pool */
 		void *src, *dest;
 		page = alloc_page(__GFP_HIGHMEM|__GFP_WAIT);
-		dest = kmap_atomic(page, KM_USER0);
-		src = kmap_atomic(b->bm_pages[page_nr], KM_USER1);
+		dest = kmap_atomic(page);
+		src = kmap_atomic(b->bm_pages[page_nr]);
 		memcpy(dest, src, PAGE_SIZE);
-		kunmap_atomic(src, KM_USER1);
-		kunmap_atomic(dest, KM_USER0);
+		kunmap_atomic(src);
+		kunmap_atomic(dest);
 		bm_store_page_idx(page, page_nr);
 	} else
 		page = b->bm_pages[page_nr];
@@ -1343,13 +1343,13 @@ static inline void bm_set_full_words_within_one_page(struct drbd_bitmap *b,
 {
 	int i;
 	int bits;
-	unsigned long *paddr = kmap_atomic(b->bm_pages[page_nr], KM_IRQ1);
+	unsigned long *paddr = kmap_atomic(b->bm_pages[page_nr]);
 	for (i = first_word; i < last_word; i++) {
 		bits = hweight_long(paddr[i]);
 		paddr[i] = ~0UL;
 		b->bm_set += BITS_PER_LONG - bits;
 	}
-	kunmap_atomic(paddr, KM_IRQ1);
+	kunmap_atomic(paddr);
 }
 
 /* Same thing as drbd_bm_set_bits,
diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
index 0feab26..1735ad9 100644
--- a/drivers/block/drbd/drbd_nl.c
+++ b/drivers/block/drbd/drbd_nl.c
@@ -2526,10 +2526,10 @@ void drbd_bcast_ee(struct drbd_conf *mdev,
 
 	page = e->pages;
 	page_chain_for_each(page) {
-		void *d = kmap_atomic(page, KM_USER0);
+		void *d = kmap_atomic(page);
 		unsigned l = min_t(unsigned, len, PAGE_SIZE);
 		memcpy(tl, d, l);
-		kunmap_atomic(d, KM_USER0);
+		kunmap_atomic(d);
 		tl = (unsigned short*)((char*)tl + l);
 		len -= l;
 		if (len == 0)
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 4720c7a..38dbc6a 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -92,16 +92,16 @@ static int transfer_none(struct loop_device *lo, int cmd,
 			 struct page *loop_page, unsigned loop_off,
 			 int size, sector_t real_block)
 {
-	char *raw_buf = kmap_atomic(raw_page, KM_USER0) + raw_off;
-	char *loop_buf = kmap_atomic(loop_page, KM_USER1) + loop_off;
+	char *raw_buf = kmap_atomic(raw_page) + raw_off;
+	char *loop_buf = kmap_atomic(loop_page) + loop_off;
 
 	if (cmd == READ)
 		memcpy(loop_buf, raw_buf, size);
 	else
 		memcpy(raw_buf, loop_buf, size);
 
-	kunmap_atomic(loop_buf, KM_USER1);
-	kunmap_atomic(raw_buf, KM_USER0);
+	kunmap_atomic(loop_buf);
+	kunmap_atomic(raw_buf);
 	cond_resched();
 	return 0;
 }
@@ -111,8 +111,8 @@ static int transfer_xor(struct loop_device *lo, int cmd,
 			struct page *loop_page, unsigned loop_off,
 			int size, sector_t real_block)
 {
-	char *raw_buf = kmap_atomic(raw_page, KM_USER0) + raw_off;
-	char *loop_buf = kmap_atomic(loop_page, KM_USER1) + loop_off;
+	char *raw_buf = kmap_atomic(raw_page) + raw_off;
+	char *loop_buf = kmap_atomic(loop_page) + loop_off;
 	char *in, *out, *key;
 	int i, keysize;
 
@@ -129,8 +129,8 @@ static int transfer_xor(struct loop_device *lo, int cmd,
 	for (i = 0; i < size; i++)
 		*out++ = *in++ ^ key[(i & 511) % keysize];
 
-	kunmap_atomic(loop_buf, KM_USER1);
-	kunmap_atomic(raw_buf, KM_USER0);
+	kunmap_atomic(loop_buf);
+	kunmap_atomic(raw_buf);
 	cond_resched();
 	return 0;
 }
diff --git a/drivers/block/pktcdvd.c b/drivers/block/pktcdvd.c
index e133f09..574d6e0 100644
--- a/drivers/block/pktcdvd.c
+++ b/drivers/block/pktcdvd.c
@@ -987,14 +987,14 @@ static void pkt_copy_bio_data(struct bio *src_bio, int seg, int offs, struct pag
 
 	while (copy_size > 0) {
 		struct bio_vec *src_bvl = bio_iovec_idx(src_bio, seg);
-		void *vfrom = kmap_atomic(src_bvl->bv_page, KM_USER0) +
+		void *vfrom = kmap_atomic(src_bvl->bv_page) +
 			src_bvl->bv_offset + offs;
 		void *vto = page_address(dst_page) + dst_offs;
 		int len = min_t(int, copy_size, src_bvl->bv_len - offs);
 
 		BUG_ON(len < 0);
 		memcpy(vto, vfrom, len);
-		kunmap_atomic(vfrom, KM_USER0);
+		kunmap_atomic(vfrom);
 
 		seg++;
 		offs = 0;
@@ -1019,10 +1019,10 @@ static void pkt_make_local_copy(struct packet_data *pkt, struct bio_vec *bvec)
 	offs = 0;
 	for (f = 0; f < pkt->frames; f++) {
 		if (bvec[f].bv_page != pkt->pages[p]) {
-			void *vfrom = kmap_atomic(bvec[f].bv_page, KM_USER0) + bvec[f].bv_offset;
+			void *vfrom = kmap_atomic(bvec[f].bv_page) + bvec[f].bv_offset;
 			void *vto = page_address(pkt->pages[p]) + offs;
 			memcpy(vto, vfrom, CD_FRAMESIZE);
-			kunmap_atomic(vfrom, KM_USER0);
+			kunmap_atomic(vfrom);
 			bvec[f].bv_page = pkt->pages[p];
 			bvec[f].bv_offset = offs;
 		} else {
diff --git a/drivers/crypto/hifn_795x.c b/drivers/crypto/hifn_795x.c
index a84250a..ee96178 100644
--- a/drivers/crypto/hifn_795x.c
+++ b/drivers/crypto/hifn_795x.c
@@ -1731,9 +1731,9 @@ static int ablkcipher_get(void *saddr, unsigned int *srestp, unsigned int offset
 	while (size) {
 		copy = min3(srest, dst->length, size);
 
-		daddr = kmap_atomic(sg_page(dst), KM_IRQ0);
+		daddr = kmap_atomic(sg_page(dst));
 		memcpy(daddr + dst->offset + offset, saddr, copy);
-		kunmap_atomic(daddr, KM_IRQ0);
+		kunmap_atomic(daddr);
 
 		nbytes -= copy;
 		size -= copy;
@@ -1793,17 +1793,17 @@ static void hifn_process_ready(struct ablkcipher_request *req, int error)
 				continue;
 			}
 
-			saddr = kmap_atomic(sg_page(t), KM_SOFTIRQ0);
+			saddr = kmap_atomic(sg_page(t));
 
 			err = ablkcipher_get(saddr, &t->length, t->offset,
 					dst, nbytes, &nbytes);
 			if (err < 0) {
-				kunmap_atomic(saddr, KM_SOFTIRQ0);
+				kunmap_atomic(saddr);
 				break;
 			}
 
 			idx += err;
-			kunmap_atomic(saddr, KM_SOFTIRQ0);
+			kunmap_atomic(saddr);
 		}
 
 		hifn_cipher_walk_exit(&rctx->walk);
diff --git a/drivers/edac/edac_mc.c b/drivers/edac/edac_mc.c
index d69144a..08dff48 100644
--- a/drivers/edac/edac_mc.c
+++ b/drivers/edac/edac_mc.c
@@ -621,13 +621,13 @@ static void edac_mc_scrub_block(unsigned long page, unsigned long offset,
 	if (PageHighMem(pg))
 		local_irq_save(flags);
 
-	virt_addr = kmap_atomic(pg, KM_BOUNCE_READ);
+	virt_addr = kmap_atomic(pg);
 
 	/* Perform architecture specific atomic scrub operation */
 	atomic_scrub(virt_addr + offset, size);
 
 	/* Unmap and complete */
-	kunmap_atomic(virt_addr, KM_BOUNCE_READ);
+	kunmap_atomic(virt_addr);
 
 	if (PageHighMem(pg))
 		local_irq_restore(flags);
diff --git a/drivers/gpu/drm/drm_cache.c b/drivers/gpu/drm/drm_cache.c
index 0e3bd5b..c362e4e 100644
--- a/drivers/gpu/drm/drm_cache.c
+++ b/drivers/gpu/drm/drm_cache.c
@@ -40,10 +40,10 @@ drm_clflush_page(struct page *page)
 	if (unlikely(page == NULL))
 		return;
 
-	page_virtual = kmap_atomic(page, KM_USER0);
+	page_virtual = kmap_atomic(page);
 	for (i = 0; i < PAGE_SIZE; i += boot_cpu_data.x86_clflush_size)
 		clflush(page_virtual + i);
-	kunmap_atomic(page_virtual, KM_USER0);
+	kunmap_atomic(page_virtual);
 }
 
 static void drm_cache_flush_clflush(struct page *pages[],
@@ -86,10 +86,10 @@ drm_clflush_pages(struct page *pages[], unsigned long num_pages)
 		if (unlikely(page == NULL))
 			continue;
 
-		page_virtual = kmap_atomic(page, KM_USER0);
+		page_virtual = kmap_atomic(page);
 		flush_dcache_range((unsigned long)page_virtual,
 				   (unsigned long)page_virtual + PAGE_SIZE);
-		kunmap_atomic(page_virtual, KM_USER0);
+		kunmap_atomic(page_virtual);
 	}
 #else
 	printk(KERN_ERR "Architecture has no drm_cache.c support\n");
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index a546a71..eaa0b04 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -800,11 +800,11 @@ i915_gem_shmem_pwrite_fast(struct drm_device *dev,
 		if (IS_ERR(page))
 			return PTR_ERR(page);
 
-		vaddr = kmap_atomic(page, KM_USER0);
+		vaddr = kmap_atomic(page);
 		ret = __copy_from_user_inatomic(vaddr + page_offset,
 						user_data,
 						page_length);
-		kunmap_atomic(vaddr, KM_USER0);
+		kunmap_atomic(vaddr);
 
 		set_page_dirty(page);
 		mark_page_accessed(page);
diff --git a/drivers/gpu/drm/i915/i915_gem_debug.c b/drivers/gpu/drm/i915/i915_gem_debug.c
index 8da1899..131c6a5 100644
--- a/drivers/gpu/drm/i915/i915_gem_debug.c
+++ b/drivers/gpu/drm/i915/i915_gem_debug.c
@@ -157,7 +157,7 @@ i915_gem_object_check_coherency(struct drm_i915_gem_object *obj, int handle)
 	for (page = 0; page < obj->size / PAGE_SIZE; page++) {
 		int i;
 
-		backing_map = kmap_atomic(obj->pages[page], KM_USER0);
+		backing_map = kmap_atomic(obj->pages[page]);
 
 		if (backing_map == NULL) {
 			DRM_ERROR("failed to map backing page\n");
@@ -181,13 +181,13 @@ i915_gem_object_check_coherency(struct drm_i915_gem_object *obj, int handle)
 				}
 			}
 		}
-		kunmap_atomic(backing_map, KM_USER0);
+		kunmap_atomic(backing_map);
 		backing_map = NULL;
 	}
 
  out:
 	if (backing_map != NULL)
-		kunmap_atomic(backing_map, KM_USER0);
+		kunmap_atomic(backing_map);
 	iounmap(gtt_mapping);
 
 	/* give syslog time to catch up */
diff --git a/drivers/gpu/drm/ttm/ttm_tt.c b/drivers/gpu/drm/ttm/ttm_tt.c
index 58c271e..46cef7a 100644
--- a/drivers/gpu/drm/ttm/ttm_tt.c
+++ b/drivers/gpu/drm/ttm/ttm_tt.c
@@ -495,11 +495,11 @@ static int ttm_tt_swapin(struct ttm_tt *ttm)
 			goto out_err;
 
 		preempt_disable();
-		from_virtual = kmap_atomic(from_page, KM_USER0);
-		to_virtual = kmap_atomic(to_page, KM_USER1);
+		from_virtual = kmap_atomic(from_page);
+		to_virtual = kmap_atomic(to_page);
 		memcpy(to_virtual, from_virtual, PAGE_SIZE);
-		kunmap_atomic(to_virtual, KM_USER1);
-		kunmap_atomic(from_virtual, KM_USER0);
+		kunmap_atomic(to_virtual);
+		kunmap_atomic(from_virtual);
 		preempt_enable();
 		page_cache_release(from_page);
 	}
@@ -564,11 +564,11 @@ int ttm_tt_swapout(struct ttm_tt *ttm, struct file *persistent_swap_storage)
 			goto out_err;
 		}
 		preempt_disable();
-		from_virtual = kmap_atomic(from_page, KM_USER0);
-		to_virtual = kmap_atomic(to_page, KM_USER1);
+		from_virtual = kmap_atomic(from_page);
+		to_virtual = kmap_atomic(to_page);
 		memcpy(to_virtual, from_virtual, PAGE_SIZE);
-		kunmap_atomic(to_virtual, KM_USER1);
-		kunmap_atomic(from_virtual, KM_USER0);
+		kunmap_atomic(to_virtual);
+		kunmap_atomic(from_virtual);
 		preempt_enable();
 		set_page_dirty(to_page);
 		mark_page_accessed(to_page);
diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_gmr.c b/drivers/gpu/drm/vmwgfx/vmwgfx_gmr.c
index de0c594..bd26029 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_gmr.c
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_gmr.c
@@ -65,10 +65,10 @@ static int vmw_gmr_build_descriptors(struct list_head *desc_pages,
 
 		if (likely(page_virtual != NULL)) {
 			desc_virtual->ppn = page_to_pfn(page);
-			kunmap_atomic(page_virtual, KM_USER0);
+			kunmap_atomic(page_virtual);
 		}
 
-		page_virtual = kmap_atomic(page, KM_USER0);
+		page_virtual = kmap_atomic(page);
 		desc_virtual = page_virtual - 1;
 		prev_pfn = ~(0UL);
 
@@ -98,7 +98,7 @@ static int vmw_gmr_build_descriptors(struct list_head *desc_pages,
 	}
 
 	if (likely(page_virtual != NULL))
-		kunmap_atomic(page_virtual, KM_USER0);
+		kunmap_atomic(page_virtual);
 
 	return 0;
 out_err:
diff --git a/drivers/ide/ide-taskfile.c b/drivers/ide/ide-taskfile.c
index 600c89a..8b7490f 100644
--- a/drivers/ide/ide-taskfile.c
+++ b/drivers/ide/ide-taskfile.c
@@ -252,7 +252,7 @@ void ide_pio_bytes(ide_drive_t *drive, struct ide_cmd *cmd,
 		if (page_is_high)
 			local_irq_save(flags);
 
-		buf = kmap_atomic(page, KM_BIO_SRC_IRQ) + offset;
+		buf = kmap_atomic(page) + offset;
 
 		cmd->nleft -= nr_bytes;
 		cmd->cursg_ofs += nr_bytes;
@@ -268,7 +268,7 @@ void ide_pio_bytes(ide_drive_t *drive, struct ide_cmd *cmd,
 		else
 			hwif->tp_ops->input_data(drive, cmd, buf, nr_bytes);
 
-		kunmap_atomic(buf, KM_BIO_SRC_IRQ);
+		kunmap_atomic(buf);
 
 		if (page_is_high)
 			local_irq_restore(flags);
diff --git a/drivers/infiniband/ulp/iser/iser_memory.c b/drivers/infiniband/ulp/iser/iser_memory.c
index fb88d68..2033a92 100644
--- a/drivers/infiniband/ulp/iser/iser_memory.c
+++ b/drivers/infiniband/ulp/iser/iser_memory.c
@@ -73,11 +73,11 @@ static int iser_start_rdma_unaligned_sg(struct iscsi_iser_task *iser_task,
 
 		p = mem;
 		for_each_sg(sgl, sg, data->size, i) {
-			from = kmap_atomic(sg_page(sg), KM_USER0);
+			from = kmap_atomic(sg_page(sg));
 			memcpy(p,
 			       from + sg->offset,
 			       sg->length);
-			kunmap_atomic(from, KM_USER0);
+			kunmap_atomic(from);
 			p += sg->length;
 		}
 	}
@@ -133,11 +133,11 @@ void iser_finalize_rdma_unaligned_sg(struct iscsi_iser_task *iser_task,
 
 		p = mem;
 		for_each_sg(sgl, sg, sg_size, i) {
-			to = kmap_atomic(sg_page(sg), KM_SOFTIRQ0);
+			to = kmap_atomic(sg_page(sg));
 			memcpy(to + sg->offset,
 			       p,
 			       sg->length);
-			kunmap_atomic(to, KM_SOFTIRQ0);
+			kunmap_atomic(to);
 			p += sg->length;
 		}
 	}
diff --git a/drivers/md/bitmap.c b/drivers/md/bitmap.c
index 0dc6546..da7cea9 100644
--- a/drivers/md/bitmap.c
+++ b/drivers/md/bitmap.c
@@ -490,7 +490,7 @@ void bitmap_update_sb(struct bitmap *bitmap)
 		return;
 	}
 	spin_unlock_irqrestore(&bitmap->lock, flags);
-	sb = kmap_atomic(bitmap->sb_page, KM_USER0);
+	sb = kmap_atomic(bitmap->sb_page);
 	sb->events = cpu_to_le64(bitmap->mddev->events);
 	if (bitmap->mddev->events < bitmap->events_cleared)
 		/* rocking back to read-only */
@@ -500,7 +500,7 @@ void bitmap_update_sb(struct bitmap *bitmap)
 	/* Just in case these have been changed via sysfs: */
 	sb->daemon_sleep = cpu_to_le32(bitmap->mddev->bitmap_info.daemon_sleep/HZ);
 	sb->write_behind = cpu_to_le32(bitmap->mddev->bitmap_info.max_write_behind);
-	kunmap_atomic(sb, KM_USER0);
+	kunmap_atomic(sb);
 	write_page(bitmap, bitmap->sb_page, 1);
 }
 
@@ -511,7 +511,7 @@ void bitmap_print_sb(struct bitmap *bitmap)
 
 	if (!bitmap || !bitmap->sb_page)
 		return;
-	sb = kmap_atomic(bitmap->sb_page, KM_USER0);
+	sb = kmap_atomic(bitmap->sb_page);
 	printk(KERN_DEBUG "%s: bitmap file superblock:\n", bmname(bitmap));
 	printk(KERN_DEBUG "         magic: %08x\n", le32_to_cpu(sb->magic));
 	printk(KERN_DEBUG "       version: %d\n", le32_to_cpu(sb->version));
@@ -530,7 +530,7 @@ void bitmap_print_sb(struct bitmap *bitmap)
 	printk(KERN_DEBUG "     sync size: %llu KB\n",
 			(unsigned long long)le64_to_cpu(sb->sync_size)/2);
 	printk(KERN_DEBUG "max write behind: %d\n", le32_to_cpu(sb->write_behind));
-	kunmap_atomic(sb, KM_USER0);
+	kunmap_atomic(sb);
 }
 
 /*
@@ -558,7 +558,7 @@ static int bitmap_new_disk_sb(struct bitmap *bitmap)
 	}
 	bitmap->sb_page->index = 0;
 
-	sb = kmap_atomic(bitmap->sb_page, KM_USER0);
+	sb = kmap_atomic(bitmap->sb_page);
 
 	sb->magic = cpu_to_le32(BITMAP_MAGIC);
 	sb->version = cpu_to_le32(BITMAP_MAJOR_HI);
@@ -566,7 +566,7 @@ static int bitmap_new_disk_sb(struct bitmap *bitmap)
 	chunksize = bitmap->mddev->bitmap_info.chunksize;
 	BUG_ON(!chunksize);
 	if (!is_power_of_2(chunksize)) {
-		kunmap_atomic(sb, KM_USER0);
+		kunmap_atomic(sb);
 		printk(KERN_ERR "bitmap chunksize not a power of 2\n");
 		return -EINVAL;
 	}
@@ -604,7 +604,7 @@ static int bitmap_new_disk_sb(struct bitmap *bitmap)
 	bitmap->flags |= BITMAP_HOSTENDIAN;
 	sb->version = cpu_to_le32(BITMAP_MAJOR_HOSTENDIAN);
 
-	kunmap_atomic(sb, KM_USER0);
+	kunmap_atomic(sb);
 
 	return 0;
 }
@@ -636,7 +636,7 @@ static int bitmap_read_sb(struct bitmap *bitmap)
 		return err;
 	}
 
-	sb = kmap_atomic(bitmap->sb_page, KM_USER0);
+	sb = kmap_atomic(bitmap->sb_page);
 
 	chunksize = le32_to_cpu(sb->chunksize);
 	daemon_sleep = le32_to_cpu(sb->daemon_sleep) * HZ;
@@ -697,7 +697,7 @@ success:
 		bitmap->events_cleared = bitmap->mddev->events;
 	err = 0;
 out:
-	kunmap_atomic(sb, KM_USER0);
+	kunmap_atomic(sb);
 	if (err)
 		bitmap_print_sb(bitmap);
 	return err;
@@ -722,7 +722,7 @@ static int bitmap_mask_state(struct bitmap *bitmap, enum bitmap_state bits,
 		return 0;
 	}
 	spin_unlock_irqrestore(&bitmap->lock, flags);
-	sb = kmap_atomic(bitmap->sb_page, KM_USER0);
+	sb = kmap_atomic(bitmap->sb_page);
 	old = le32_to_cpu(sb->state) & bits;
 	switch (op) {
 	case MASK_SET:
@@ -736,7 +736,7 @@ static int bitmap_mask_state(struct bitmap *bitmap, enum bitmap_state bits,
 	default:
 		BUG();
 	}
-	kunmap_atomic(sb, KM_USER0);
+	kunmap_atomic(sb);
 	return old;
 }
 
@@ -913,12 +913,12 @@ static void bitmap_file_set_bit(struct bitmap *bitmap, sector_t block)
 	bit = file_page_offset(bitmap, chunk);
 
 	/* set the bit */
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	if (bitmap->flags & BITMAP_HOSTENDIAN)
 		set_bit(bit, kaddr);
 	else
 		__set_bit_le(bit, kaddr);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	PRINTK("set file bit %lu page %lu\n", bit, page->index);
 	/* record page number so it gets flushed to disk when unplug occurs */
 	set_page_attr(bitmap, page, BITMAP_PAGE_DIRTY);
@@ -1086,10 +1086,10 @@ static int bitmap_init_from_disk(struct bitmap *bitmap, sector_t start)
 				 * if bitmap is out of date, dirty the
 				 * whole page and write it out
 				 */
-				paddr = kmap_atomic(page, KM_USER0);
+				paddr = kmap_atomic(page);
 				memset(paddr + offset, 0xff,
 				       PAGE_SIZE - offset);
-				kunmap_atomic(paddr, KM_USER0);
+				kunmap_atomic(paddr);
 				write_page(bitmap, page, 1);
 
 				ret = -EIO;
@@ -1097,12 +1097,12 @@ static int bitmap_init_from_disk(struct bitmap *bitmap, sector_t start)
 					goto err;
 			}
 		}
-		paddr = kmap_atomic(page, KM_USER0);
+		paddr = kmap_atomic(page);
 		if (bitmap->flags & BITMAP_HOSTENDIAN)
 			b = test_bit(bit, paddr);
 		else
 			b = test_bit_le(bit, paddr);
-		kunmap_atomic(paddr, KM_USER0);
+		kunmap_atomic(paddr);
 		if (b) {
 			/* if the disk bit is set, set the memory bit */
 			int needed = ((sector_t)(i+1) << (CHUNK_BLOCK_SHIFT(bitmap))
@@ -1241,10 +1241,10 @@ void bitmap_daemon_work(mddev_t *mddev)
 			    bitmap->mddev->bitmap_info.external == 0) {
 				bitmap_super_t *sb;
 				bitmap->need_sync = 0;
-				sb = kmap_atomic(bitmap->sb_page, KM_USER0);
+				sb = kmap_atomic(bitmap->sb_page);
 				sb->events_cleared =
 					cpu_to_le64(bitmap->events_cleared);
-				kunmap_atomic(sb, KM_USER0);
+				kunmap_atomic(sb);
 				write_page(bitmap, bitmap->sb_page, 1);
 			}
 			spin_lock_irqsave(&bitmap->lock, flags);
@@ -1269,7 +1269,7 @@ void bitmap_daemon_work(mddev_t *mddev)
 						  -1);
 
 				/* clear the bit */
-				paddr = kmap_atomic(page, KM_USER0);
+				paddr = kmap_atomic(page);
 				if (bitmap->flags & BITMAP_HOSTENDIAN)
 					clear_bit(file_page_offset(bitmap, j),
 						  paddr);
@@ -1278,7 +1278,7 @@ void bitmap_daemon_work(mddev_t *mddev)
 							file_page_offset(bitmap,
 									 j),
 							paddr);
-				kunmap_atomic(paddr, KM_USER0);
+				kunmap_atomic(paddr);
 			}
 		} else
 			j |= PAGE_COUNTER_MASK;
diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index 49da55c..4b7df00 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -590,9 +590,9 @@ static int crypt_iv_lmk_gen(struct crypt_config *cc, u8 *iv,
 	int r = 0;
 
 	if (bio_data_dir(dmreq->ctx->bio_in) == WRITE) {
-		src = kmap_atomic(sg_page(&dmreq->sg_in), KM_USER0);
+		src = kmap_atomic(sg_page(&dmreq->sg_in));
 		r = crypt_iv_lmk_one(cc, iv, dmreq, src + dmreq->sg_in.offset);
-		kunmap_atomic(src, KM_USER0);
+		kunmap_atomic(src);
 	} else
 		memset(iv, 0, cc->iv_size);
 
@@ -608,14 +608,14 @@ static int crypt_iv_lmk_post(struct crypt_config *cc, u8 *iv,
 	if (bio_data_dir(dmreq->ctx->bio_in) == WRITE)
 		return 0;
 
-	dst = kmap_atomic(sg_page(&dmreq->sg_out), KM_USER0);
+	dst = kmap_atomic(sg_page(&dmreq->sg_out));
 	r = crypt_iv_lmk_one(cc, iv, dmreq, dst + dmreq->sg_out.offset);
 
 	/* Tweak the first block of plaintext sector */
 	if (!r)
 		crypto_xor(dst + dmreq->sg_out.offset, iv, cc->iv_size);
 
-	kunmap_atomic(dst, KM_USER0);
+	kunmap_atomic(dst);
 	return r;
 }
 
diff --git a/drivers/media/video/ivtv/ivtv-udma.c b/drivers/media/video/ivtv/ivtv-udma.c
index 69cc816..7338cb2 100644
--- a/drivers/media/video/ivtv/ivtv-udma.c
+++ b/drivers/media/video/ivtv/ivtv-udma.c
@@ -57,9 +57,9 @@ int ivtv_udma_fill_sg_list (struct ivtv_user_dma *dma, struct ivtv_dma_page_info
 			if (dma->bouncemap[map_offset] == NULL)
 				return -1;
 			local_irq_save(flags);
-			src = kmap_atomic(dma->map[map_offset], KM_BOUNCE_READ) + offset;
+			src = kmap_atomic(dma->map[map_offset]) + offset;
 			memcpy(page_address(dma->bouncemap[map_offset]) + offset, src, len);
-			kunmap_atomic(src, KM_BOUNCE_READ);
+			kunmap_atomic(src);
 			local_irq_restore(flags);
 			sg_set_page(&dma->SGlist[map_offset], dma->bouncemap[map_offset], len, offset);
 		}
diff --git a/drivers/memstick/host/jmb38x_ms.c b/drivers/memstick/host/jmb38x_ms.c
index d89d925..b7065b4 100644
--- a/drivers/memstick/host/jmb38x_ms.c
+++ b/drivers/memstick/host/jmb38x_ms.c
@@ -324,7 +324,7 @@ static int jmb38x_ms_transfer_data(struct jmb38x_ms_host *host)
 			p_cnt = min(p_cnt, length);
 
 			local_irq_save(flags);
-			buf = kmap_atomic(pg, KM_BIO_SRC_IRQ) + p_off;
+			buf = kmap_atomic(pg) + p_off;
 		} else {
 			buf = host->req->data + host->block_pos;
 			p_cnt = host->req->data_len - host->block_pos;
@@ -340,7 +340,7 @@ static int jmb38x_ms_transfer_data(struct jmb38x_ms_host *host)
 				 : jmb38x_ms_read_reg_data(host, buf, p_cnt);
 
 		if (host->req->long_data) {
-			kunmap_atomic(buf - p_off, KM_BIO_SRC_IRQ);
+			kunmap_atomic(buf - p_off);
 			local_irq_restore(flags);
 		}
 
diff --git a/drivers/memstick/host/tifm_ms.c b/drivers/memstick/host/tifm_ms.c
index 03f71a4..6c43db6 100644
--- a/drivers/memstick/host/tifm_ms.c
+++ b/drivers/memstick/host/tifm_ms.c
@@ -209,7 +209,7 @@ static unsigned int tifm_ms_transfer_data(struct tifm_ms *host)
 			p_cnt = min(p_cnt, length);
 
 			local_irq_save(flags);
-			buf = kmap_atomic(pg, KM_BIO_SRC_IRQ) + p_off;
+			buf = kmap_atomic(pg) + p_off;
 		} else {
 			buf = host->req->data + host->block_pos;
 			p_cnt = host->req->data_len - host->block_pos;
@@ -220,7 +220,7 @@ static unsigned int tifm_ms_transfer_data(struct tifm_ms *host)
 			 : tifm_ms_read_data(host, buf, p_cnt);
 
 		if (host->req->long_data) {
-			kunmap_atomic(buf - p_off, KM_BIO_SRC_IRQ);
+			kunmap_atomic(buf - p_off);
 			local_irq_restore(flags);
 		}
 
diff --git a/drivers/mmc/host/at91_mci.c b/drivers/mmc/host/at91_mci.c
index a4aa3af..d25abf3 100644
--- a/drivers/mmc/host/at91_mci.c
+++ b/drivers/mmc/host/at91_mci.c
@@ -236,7 +236,7 @@ static inline void at91_mci_sg_to_dma(struct at91mci_host *host, struct mmc_data
 
 		sg = &data->sg[i];
 
-		sgbuffer = kmap_atomic(sg_page(sg), KM_BIO_SRC_IRQ) + sg->offset;
+		sgbuffer = kmap_atomic(sg_page(sg)) + sg->offset;
 		amount = min(size, sg->length);
 		size -= amount;
 
@@ -252,7 +252,7 @@ static inline void at91_mci_sg_to_dma(struct at91mci_host *host, struct mmc_data
 			dmabuf = (unsigned *)tmpv;
 		}
 
-		kunmap_atomic(sgbuffer, KM_BIO_SRC_IRQ);
+		kunmap_atomic(sgbuffer);
 
 		if (size == 0)
 			break;
@@ -302,7 +302,7 @@ static void at91_mci_post_dma_read(struct at91mci_host *host)
 
 		sg = &data->sg[i];
 
-		sgbuffer = kmap_atomic(sg_page(sg), KM_BIO_SRC_IRQ) + sg->offset;
+		sgbuffer = kmap_atomic(sg_page(sg)) + sg->offset;
 		amount = min(size, sg->length);
 		size -= amount;
 
@@ -318,7 +318,7 @@ static void at91_mci_post_dma_read(struct at91mci_host *host)
 		}
 
 		flush_kernel_dcache_page(sg_page(sg));
-		kunmap_atomic(sgbuffer, KM_BIO_SRC_IRQ);
+		kunmap_atomic(sgbuffer);
 		data->bytes_xfered += amount;
 		if (size == 0)
 			break;
diff --git a/drivers/mmc/host/msm_sdcc.c b/drivers/mmc/host/msm_sdcc.c
index a4c865a..2286716 100644
--- a/drivers/mmc/host/msm_sdcc.c
+++ b/drivers/mmc/host/msm_sdcc.c
@@ -692,7 +692,7 @@ msmsdcc_pio_irq(int irq, void *dev_id)
 			len = msmsdcc_pio_write(host, buffer, remain, status);
 
 		/* Unmap the buffer */
-		kunmap_atomic(buffer, KM_BIO_SRC_IRQ);
+		kunmap_atomic(buffer);
 		local_irq_restore(flags);
 
 		host->pio.sg_off += len;
diff --git a/drivers/mmc/host/sdhci.c b/drivers/mmc/host/sdhci.c
index 0e02cc1..2b5a215 100644
--- a/drivers/mmc/host/sdhci.c
+++ b/drivers/mmc/host/sdhci.c
@@ -400,12 +400,12 @@ static void sdhci_transfer_pio(struct sdhci_host *host)
 static char *sdhci_kmap_atomic(struct scatterlist *sg, unsigned long *flags)
 {
 	local_irq_save(*flags);
-	return kmap_atomic(sg_page(sg), KM_BIO_SRC_IRQ) + sg->offset;
+	return kmap_atomic(sg_page(sg)) + sg->offset;
 }
 
 static void sdhci_kunmap_atomic(void *buffer, unsigned long *flags)
 {
-	kunmap_atomic(buffer, KM_BIO_SRC_IRQ);
+	kunmap_atomic(buffer);
 	local_irq_restore(*flags);
 }
 
diff --git a/drivers/mmc/host/tifm_sd.c b/drivers/mmc/host/tifm_sd.c
index 457c26e..101ec07 100644
--- a/drivers/mmc/host/tifm_sd.c
+++ b/drivers/mmc/host/tifm_sd.c
@@ -117,7 +117,7 @@ static void tifm_sd_read_fifo(struct tifm_sd *host, struct page *pg,
 	unsigned char *buf;
 	unsigned int pos = 0, val;
 
-	buf = kmap_atomic(pg, KM_BIO_DST_IRQ) + off;
+	buf = kmap_atomic(pg) + off;
 	if (host->cmd_flags & DATA_CARRY) {
 		buf[pos++] = host->bounce_buf_data[0];
 		host->cmd_flags &= ~DATA_CARRY;
@@ -133,7 +133,7 @@ static void tifm_sd_read_fifo(struct tifm_sd *host, struct page *pg,
 		}
 		buf[pos++] = (val >> 8) & 0xff;
 	}
-	kunmap_atomic(buf - off, KM_BIO_DST_IRQ);
+	kunmap_atomic(buf - off);
 }
 
 static void tifm_sd_write_fifo(struct tifm_sd *host, struct page *pg,
@@ -143,7 +143,7 @@ static void tifm_sd_write_fifo(struct tifm_sd *host, struct page *pg,
 	unsigned char *buf;
 	unsigned int pos = 0, val;
 
-	buf = kmap_atomic(pg, KM_BIO_SRC_IRQ) + off;
+	buf = kmap_atomic(pg) + off;
 	if (host->cmd_flags & DATA_CARRY) {
 		val = host->bounce_buf_data[0] | ((buf[pos++] << 8) & 0xff00);
 		writel(val, sock->addr + SOCK_MMCSD_DATA);
@@ -160,7 +160,7 @@ static void tifm_sd_write_fifo(struct tifm_sd *host, struct page *pg,
 		val |= (buf[pos++] << 8) & 0xff00;
 		writel(val, sock->addr + SOCK_MMCSD_DATA);
 	}
-	kunmap_atomic(buf - off, KM_BIO_SRC_IRQ);
+	kunmap_atomic(buf - off);
 }
 
 static void tifm_sd_transfer_data(struct tifm_sd *host)
@@ -211,13 +211,13 @@ static void tifm_sd_copy_page(struct page *dst, unsigned int dst_off,
 			      struct page *src, unsigned int src_off,
 			      unsigned int count)
 {
-	unsigned char *src_buf = kmap_atomic(src, KM_BIO_SRC_IRQ) + src_off;
-	unsigned char *dst_buf = kmap_atomic(dst, KM_BIO_DST_IRQ) + dst_off;
+	unsigned char *src_buf = kmap_atomic(src) + src_off;
+	unsigned char *dst_buf = kmap_atomic(dst) + dst_off;
 
 	memcpy(dst_buf, src_buf, count);
 
-	kunmap_atomic(dst_buf - dst_off, KM_BIO_DST_IRQ);
-	kunmap_atomic(src_buf - src_off, KM_BIO_SRC_IRQ);
+	kunmap_atomic(dst_buf - dst_off);
+	kunmap_atomic(src_buf - src_off);
 }
 
 static void tifm_sd_bounce_block(struct tifm_sd *host, struct mmc_data *r_data)
diff --git a/drivers/mmc/host/tmio_mmc.h b/drivers/mmc/host/tmio_mmc.h
index eeaf643..17256ab 100644
--- a/drivers/mmc/host/tmio_mmc.h
+++ b/drivers/mmc/host/tmio_mmc.h
@@ -98,13 +98,13 @@ static inline char *tmio_mmc_kmap_atomic(struct scatterlist *sg,
 					 unsigned long *flags)
 {
 	local_irq_save(*flags);
-	return kmap_atomic(sg_page(sg), KM_BIO_SRC_IRQ) + sg->offset;
+	return kmap_atomic(sg_page(sg)) + sg->offset;
 }
 
 static inline void tmio_mmc_kunmap_atomic(struct scatterlist *sg,
 					  unsigned long *flags, void *virt)
 {
-	kunmap_atomic(virt - sg->offset, KM_BIO_SRC_IRQ);
+	kunmap_atomic(virt - sg->offset);
 	local_irq_restore(*flags);
 }
 
diff --git a/drivers/mmc/host/tmio_mmc_dma.c b/drivers/mmc/host/tmio_mmc_dma.c
index 86f259c..e7a4678 100644
--- a/drivers/mmc/host/tmio_mmc_dma.c
+++ b/drivers/mmc/host/tmio_mmc_dma.c
@@ -147,10 +147,10 @@ static void tmio_mmc_start_dma_tx(struct tmio_mmc_host *host)
 	/* The only sg element can be unaligned, use our bounce buffer then */
 	if (!aligned) {
 		unsigned long flags;
-		void *sg_vaddr = tmio_mmc_kmap_atomic(sg, &flags);
+		void *sg_vaddr = tmio_mmc_kmap_atomic(sg);
 		sg_init_one(&host->bounce_sg, host->bounce_buf, sg->length);
 		memcpy(host->bounce_buf, sg_vaddr, host->bounce_sg.length);
-		tmio_mmc_kunmap_atomic(sg, &flags, sg_vaddr);
+		tmio_mmc_kunmap_atomic(sg, &flags);
 		host->sg_ptr = &host->bounce_sg;
 		sg = host->sg_ptr;
 	}
diff --git a/drivers/mmc/host/tmio_mmc_pio.c b/drivers/mmc/host/tmio_mmc_pio.c
index 1f16357..9461f82 100644
--- a/drivers/mmc/host/tmio_mmc_pio.c
+++ b/drivers/mmc/host/tmio_mmc_pio.c
@@ -362,7 +362,7 @@ static void tmio_mmc_pio_irq(struct tmio_mmc_host *host)
 		return;
 	}
 
-	sg_virt = tmio_mmc_kmap_atomic(host->sg_ptr, &flags);
+	sg_virt = tmio_mmc_kmap_atomic(host->sg_ptr);
 	buf = (unsigned short *)(sg_virt + host->sg_off);
 
 	count = host->sg_ptr->length - host->sg_off;
@@ -380,7 +380,7 @@ static void tmio_mmc_pio_irq(struct tmio_mmc_host *host)
 
 	host->sg_off += count;
 
-	tmio_mmc_kunmap_atomic(host->sg_ptr, &flags, sg_virt);
+	tmio_mmc_kunmap_atomic(host->sg_ptr, &flags);
 
 	if (host->sg_off == host->sg_ptr->length)
 		tmio_mmc_next_sg(host);
@@ -392,9 +392,9 @@ static void tmio_mmc_check_bounce_buffer(struct tmio_mmc_host *host)
 {
 	if (host->sg_ptr == &host->bounce_sg) {
 		unsigned long flags;
-		void *sg_vaddr = tmio_mmc_kmap_atomic(host->sg_orig, &flags);
+		void *sg_vaddr = tmio_mmc_kmap_atomic(host->sg_orig);
 		memcpy(sg_vaddr, host->bounce_buf, host->bounce_sg.length);
-		tmio_mmc_kunmap_atomic(host->sg_orig, &flags, sg_vaddr);
+		tmio_mmc_kunmap_atomic(host->sg_orig, &flags);
 	}
 }
 
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 646c86b..a16c0d2 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -104,8 +104,8 @@
 #include <asm/byteorder.h>
 #include <asm/uaccess.h>
 
-#define cas_page_map(x)      kmap_atomic((x), KM_SKB_DATA_SOFTIRQ)
-#define cas_page_unmap(x)    kunmap_atomic((x), KM_SKB_DATA_SOFTIRQ)
+#define cas_page_map(x)      kmap_atomic((x))
+#define cas_page_unmap(x)    kunmap_atomic((x))
 #define CAS_NCPUS            num_online_cpus()
 
 #define cas_skb_release(x)  netif_rx(x)
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f97afda..0d4458e 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3887,11 +3887,9 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				if (length <= copybreak &&
 				    skb_tailroom(skb) >= length) {
 					u8 *vaddr;
-					vaddr = kmap_atomic(buffer_info->page,
-					                    KM_SKB_DATA_SOFTIRQ);
+					vaddr = kmap_atomic(buffer_info->page);
 					memcpy(skb_tail_pointer(skb), vaddr, length);
-					kunmap_atomic(vaddr,
-					              KM_SKB_DATA_SOFTIRQ);
+					kunmap_atomic(vaddr);
 					/* re-use the page, so don't erase
 					 * buffer_info->page */
 					skb_put(skb, length);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 362f703..01c0f6c 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1175,9 +1175,9 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			 */
 			dma_sync_single_for_cpu(&pdev->dev, ps_page->dma,
 						PAGE_SIZE, DMA_FROM_DEVICE);
-			vaddr = kmap_atomic(ps_page->page, KM_SKB_DATA_SOFTIRQ);
+			vaddr = kmap_atomic(ps_page->page);
 			memcpy(skb_tail_pointer(skb), vaddr, l1);
-			kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
+			kunmap_atomic(vaddr);
 			dma_sync_single_for_device(&pdev->dev, ps_page->dma,
 						   PAGE_SIZE, DMA_FROM_DEVICE);
 
@@ -1370,12 +1370,10 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				if (length <= copybreak &&
 				    skb_tailroom(skb) >= length) {
 					u8 *vaddr;
-					vaddr = kmap_atomic(buffer_info->page,
-					                   KM_SKB_DATA_SOFTIRQ);
+					vaddr = kmap_atomic(buffer_info->page);
 					memcpy(skb_tail_pointer(skb), vaddr,
 					       length);
-					kunmap_atomic(vaddr,
-					              KM_SKB_DATA_SOFTIRQ);
+					kunmap_atomic(vaddr);
 					/* re-use the page, so don't erase
 					 * buffer_info->page */
 					skb_put(skb, length);
diff --git a/drivers/scsi/arcmsr/arcmsr_hba.c b/drivers/scsi/arcmsr/arcmsr_hba.c
index f980600..2fe9e90 100644
--- a/drivers/scsi/arcmsr/arcmsr_hba.c
+++ b/drivers/scsi/arcmsr/arcmsr_hba.c
@@ -1736,7 +1736,7 @@ static int arcmsr_iop_message_xfer(struct AdapterControlBlock *acb,
 						(uint32_t ) cmd->cmnd[8];
 						/* 4 bytes: Areca io control code */
 	sg = scsi_sglist(cmd);
-	buffer = kmap_atomic(sg_page(sg), KM_IRQ0) + sg->offset;
+	buffer = kmap_atomic(sg_page(sg)) + sg->offset;
 	if (scsi_sg_count(cmd) > 1) {
 		retvalue = ARCMSR_MESSAGE_FAIL;
 		goto message_out;
@@ -1985,7 +1985,7 @@ static int arcmsr_iop_message_xfer(struct AdapterControlBlock *acb,
 	}
 	message_out:
 	sg = scsi_sglist(cmd);
-	kunmap_atomic(buffer - sg->offset, KM_IRQ0);
+	kunmap_atomic(buffer - sg->offset);
 	return retvalue;
 }
 
@@ -2035,11 +2035,11 @@ static void arcmsr_handle_virtual_command(struct AdapterControlBlock *acb,
 		strncpy(&inqdata[32], "R001", 4); /* Product Revision */
 
 		sg = scsi_sglist(cmd);
-		buffer = kmap_atomic(sg_page(sg), KM_IRQ0) + sg->offset;
+		buffer = kmap_atomic(sg_page(sg)) + sg->offset;
 
 		memcpy(buffer, inqdata, sizeof(inqdata));
 		sg = scsi_sglist(cmd);
-		kunmap_atomic(buffer - sg->offset, KM_IRQ0);
+		kunmap_atomic(buffer - sg->offset);
 
 		cmd->scsi_done(cmd);
 	}
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index 7cb2cd4..28ea0e0 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -302,7 +302,7 @@ static int bnx2fc_xmit(struct fc_lport *lport, struct fc_frame *fp)
 			return -ENOMEM;
 		}
 		frag = &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
-		cp = kmap_atomic(frag->page, KM_SKB_DATA_SOFTIRQ)
+		cp = kmap_atomic(frag->page)
 				+ frag->page_offset;
 	} else {
 		cp = (struct fcoe_crc_eof *)skb_put(skb, tlen);
@@ -312,7 +312,7 @@ static int bnx2fc_xmit(struct fc_lport *lport, struct fc_frame *fp)
 	cp->fcoe_eof = eof;
 	cp->fcoe_crc32 = cpu_to_le32(~crc);
 	if (skb_is_nonlinear(skb)) {
-		kunmap_atomic(cp, KM_SKB_DATA_SOFTIRQ);
+		kunmap_atomic(cp);
 		cp = NULL;
 	}
 
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 77ac217..7e329a9 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -1948,12 +1948,11 @@ int cxgbi_conn_init_pdu(struct iscsi_task *task, unsigned int offset,
 
 			/* data fits in the skb's headroom */
 			for (i = 0; i < tdata->nr_frags; i++, frag++) {
-				char *src = kmap_atomic(frag->page,
-							KM_SOFTIRQ0);
+				char *src = kmap_atomic(frag->page);
 
 				memcpy(dst, src+frag->page_offset, frag->size);
 				dst += frag->size;
-				kunmap_atomic(src, KM_SOFTIRQ0);
+				kunmap_atomic(src);
 			}
 			if (padlen) {
 				memset(dst, 0, padlen);
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index ba710e3..7cda24d 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1514,7 +1514,7 @@ int fcoe_xmit(struct fc_lport *lport, struct fc_frame *fp)
 			return -ENOMEM;
 		}
 		frag = &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
-		cp = kmap_atomic(frag->page, KM_SKB_DATA_SOFTIRQ)
+		cp = kmap_atomic(frag->page)
 			+ frag->page_offset;
 	} else {
 		cp = (struct fcoe_crc_eof *)skb_put(skb, tlen);
@@ -1525,7 +1525,7 @@ int fcoe_xmit(struct fc_lport *lport, struct fc_frame *fp)
 	cp->fcoe_crc32 = cpu_to_le32(~crc);
 
 	if (skb_is_nonlinear(skb)) {
-		kunmap_atomic(cp, KM_SKB_DATA_SOFTIRQ);
+		kunmap_atomic(cp);
 		cp = NULL;
 	}
 
diff --git a/drivers/scsi/fcoe/fcoe_transport.c b/drivers/scsi/fcoe/fcoe_transport.c
index 41068e8..51e85fa 100644
--- a/drivers/scsi/fcoe/fcoe_transport.c
+++ b/drivers/scsi/fcoe/fcoe_transport.c
@@ -108,10 +108,9 @@ u32 fcoe_fc_crc(struct fc_frame *fp)
 		len = frag->size;
 		while (len > 0) {
 			clen = min(len, PAGE_SIZE - (off & ~PAGE_MASK));
-			data = kmap_atomic(frag->page + (off >> PAGE_SHIFT),
-					   KM_SKB_DATA_SOFTIRQ);
+			data = kmap_atomic(frag->page + (off >> PAGE_SHIFT));
 			crc = crc32(crc, data + (off & ~PAGE_MASK), clen);
-			kunmap_atomic(data, KM_SKB_DATA_SOFTIRQ);
+			kunmap_atomic(data);
 			off += clen;
 			len -= clen;
 		}
diff --git a/drivers/scsi/gdth.c b/drivers/scsi/gdth.c
index 3242bca..d42ec92 100644
--- a/drivers/scsi/gdth.c
+++ b/drivers/scsi/gdth.c
@@ -2310,10 +2310,10 @@ static void gdth_copy_internal_data(gdth_ha_str *ha, Scsi_Cmnd *scp,
                 return;
             }
             local_irq_save(flags);
-            address = kmap_atomic(sg_page(sl), KM_BIO_SRC_IRQ) + sl->offset;
+            address = kmap_atomic(sg_page(sl)) + sl->offset;
             memcpy(address, buffer, cpnow);
             flush_dcache_page(sg_page(sl));
-            kunmap_atomic(address, KM_BIO_SRC_IRQ);
+            kunmap_atomic(address);
             local_irq_restore(flags);
             if (cpsum == cpcount)
                 break;
diff --git a/drivers/scsi/ips.c b/drivers/scsi/ips.c
index 218f71a..4a11a9b 100644
--- a/drivers/scsi/ips.c
+++ b/drivers/scsi/ips.c
@@ -1511,14 +1511,14 @@ static int ips_is_passthru(struct scsi_cmnd *SC)
                 /* kmap_atomic() ensures addressability of the user buffer.*/
                 /* local_irq_save() protects the KM_IRQ0 address slot.     */
                 local_irq_save(flags);
-                buffer = kmap_atomic(sg_page(sg), KM_IRQ0) + sg->offset;
+                buffer = kmap_atomic(sg_page(sg)) + sg->offset;
                 if (buffer && buffer[0] == 'C' && buffer[1] == 'O' &&
                     buffer[2] == 'P' && buffer[3] == 'P') {
-                        kunmap_atomic(buffer - sg->offset, KM_IRQ0);
+                        kunmap_atomic(buffer - sg->offset);
                         local_irq_restore(flags);
                         return 1;
                 }
-                kunmap_atomic(buffer - sg->offset, KM_IRQ0);
+                kunmap_atomic(buffer - sg->offset);
                 local_irq_restore(flags);
 	}
 	return 0;
diff --git a/drivers/scsi/isci/request.c b/drivers/scsi/isci/request.c
index a46e07a..a6c9822 100644
--- a/drivers/scsi/isci/request.c
+++ b/drivers/scsi/isci/request.c
@@ -1262,9 +1262,9 @@ sci_stp_request_pio_data_in_copy_data_buffer(struct isci_stp_request *stp_req,
 			struct page *page = sg_page(sg);
 
 			copy_len = min_t(int, total_len, sg_dma_len(sg));
-			kaddr = kmap_atomic(page, KM_IRQ0);
+			kaddr = kmap_atomic(page);
 			memcpy(kaddr + sg->offset, src_addr, copy_len);
-			kunmap_atomic(kaddr, KM_IRQ0);
+			kunmap_atomic(kaddr);
 			total_len -= copy_len;
 			src_addr += copy_len;
 			sg = sg_next(sg);
@@ -2759,10 +2759,10 @@ static void isci_request_io_request_complete(struct isci_host *ihost,
 		dma_unmap_sg(&ihost->pdev->dev, sg, 1, DMA_TO_DEVICE);
 
 		/* need to swab it back in case the command buffer is re-used */
-		kaddr = kmap_atomic(sg_page(sg), KM_IRQ0);
+		kaddr = kmap_atomic(sg_page(sg));
 		smp_req = kaddr + sg->offset;
 		sci_swab32_cpy(smp_req, smp_req, sg->length / sizeof(u32));
-		kunmap_atomic(kaddr, KM_IRQ0);
+		kunmap_atomic(kaddr);
 		break;
 	}
 	default:
@@ -3039,7 +3039,7 @@ sci_io_request_construct_smp(struct device *dev,
 	u8 req_len;
 	u32 cmd;
 
-	kaddr = kmap_atomic(sg_page(sg), KM_IRQ0);
+	kaddr = kmap_atomic(sg_page(sg));
 	smp_req = kaddr + sg->offset;
 	/*
 	 * Look at the SMP requests' header fields; for certain SAS 1.x SMP
@@ -3065,7 +3065,7 @@ sci_io_request_construct_smp(struct device *dev,
 	req_len = smp_req->req_len;
 	sci_swab32_cpy(smp_req, smp_req, sg->length / sizeof(u32));
 	cmd = *(u32 *) smp_req;
-	kunmap_atomic(kaddr, KM_IRQ0);
+	kunmap_atomic(kaddr);
 
 	if (!dma_map_sg(dev, sg, 1, DMA_TO_DEVICE))
 		return SCI_FAILURE;
diff --git a/drivers/scsi/libfc/fc_fcp.c b/drivers/scsi/libfc/fc_fcp.c
index afb63c8..145f3d9 100644
--- a/drivers/scsi/libfc/fc_fcp.c
+++ b/drivers/scsi/libfc/fc_fcp.c
@@ -649,10 +649,10 @@ static int fc_fcp_send_data(struct fc_fcp_pkt *fsp, struct fc_seq *seq,
 			 * The scatterlist item may be bigger than PAGE_SIZE,
 			 * but we must not cross pages inside the kmap.
 			 */
-			page_addr = kmap_atomic(page, KM_SOFTIRQ0);
+			page_addr = kmap_atomic(page);
 			memcpy(data, (char *)page_addr + (off & ~PAGE_MASK),
 			       sg_bytes);
-			kunmap_atomic(page_addr, KM_SOFTIRQ0);
+			kunmap_atomic(page_addr);
 			data += sg_bytes;
 		}
 		offset += sg_bytes;
diff --git a/drivers/scsi/libfc/fc_libfc.c b/drivers/scsi/libfc/fc_libfc.c
index b7735129..3958cba 100644
--- a/drivers/scsi/libfc/fc_libfc.c
+++ b/drivers/scsi/libfc/fc_libfc.c
@@ -141,12 +141,11 @@ u32 fc_copy_buffer_to_sglist(void *buf, size_t len,
 		off = *offset + sg->offset;
 		sg_bytes = min(sg_bytes,
 			       (size_t)(PAGE_SIZE - (off & ~PAGE_MASK)));
-		page_addr = kmap_atomic(sg_page(sg) + (off >> PAGE_SHIFT),
-					km_type);
+		page_addr = kmap_atomic(sg_page(sg) + (off >> PAGE_SHIFT));
 		if (crc)
 			*crc = crc32(*crc, buf, sg_bytes);
 		memcpy((char *)page_addr + (off & ~PAGE_MASK), buf, sg_bytes);
-		kunmap_atomic(page_addr, km_type);
+		kunmap_atomic(page_addr);
 		buf += sg_bytes;
 		*offset += sg_bytes;
 		remaining -= sg_bytes;
diff --git a/drivers/scsi/libiscsi_tcp.c b/drivers/scsi/libiscsi_tcp.c
index 09b232f..ecf7b99 100644
--- a/drivers/scsi/libiscsi_tcp.c
+++ b/drivers/scsi/libiscsi_tcp.c
@@ -134,7 +134,7 @@ static void iscsi_tcp_segment_map(struct iscsi_segment *segment, int recv)
 
 	if (recv) {
 		segment->atomic_mapped = true;
-		segment->sg_mapped = kmap_atomic(sg_page(sg), KM_SOFTIRQ0);
+		segment->sg_mapped = kmap_atomic(sg_page(sg));
 	} else {
 		segment->atomic_mapped = false;
 		/* the xmit path can sleep with the page mapped so use kmap */
@@ -148,7 +148,7 @@ void iscsi_tcp_segment_unmap(struct iscsi_segment *segment)
 {
 	if (segment->sg_mapped) {
 		if (segment->atomic_mapped)
-			kunmap_atomic(segment->sg_mapped, KM_SOFTIRQ0);
+			kunmap_atomic(segment->sg_mapped);
 		else
 			kunmap(sg_page(segment->sg));
 		segment->sg_mapped = NULL;
diff --git a/drivers/scsi/libsas/sas_host_smp.c b/drivers/scsi/libsas/sas_host_smp.c
index 04ad8dd..dc6dd41 100644
--- a/drivers/scsi/libsas/sas_host_smp.c
+++ b/drivers/scsi/libsas/sas_host_smp.c
@@ -160,9 +160,9 @@ int sas_smp_host_handler(struct Scsi_Host *shost, struct request *req,
 	}
 
 	local_irq_disable();
-	buf = kmap_atomic(bio_page(req->bio), KM_USER0) + bio_offset(req->bio);
+	buf = kmap_atomic(bio_page(req->bio));
 	memcpy(req_data, buf, blk_rq_bytes(req));
-	kunmap_atomic(buf - bio_offset(req->bio), KM_USER0);
+	kunmap_atomic(buf - bio_offset(req->bio));
 	local_irq_enable();
 
 	if (req_data[0] != SMP_REQUEST)
@@ -261,10 +261,10 @@ int sas_smp_host_handler(struct Scsi_Host *shost, struct request *req,
 	}
 
 	local_irq_disable();
-	buf = kmap_atomic(bio_page(rsp->bio), KM_USER0) + bio_offset(rsp->bio);
+	buf = kmap_atomic(bio_page(rsp->bio));
 	memcpy(buf, resp_data, blk_rq_bytes(rsp));
 	flush_kernel_dcache_page(bio_page(rsp->bio));
-	kunmap_atomic(buf - bio_offset(rsp->bio), KM_USER0);
+	kunmap_atomic(buf - bio_offset(rsp->bio));
 	local_irq_enable();
 
  out:
diff --git a/drivers/scsi/megaraid.c b/drivers/scsi/megaraid.c
index 5c17764..d3b1ddd 100644
--- a/drivers/scsi/megaraid.c
+++ b/drivers/scsi/megaraid.c
@@ -667,10 +667,10 @@ mega_build_cmd(adapter_t *adapter, Scsi_Cmnd *cmd, int *busy)
 			struct scatterlist *sg;
 
 			sg = scsi_sglist(cmd);
-			buf = kmap_atomic(sg_page(sg), KM_IRQ0) + sg->offset;
+			buf = kmap_atomic(sg_page(sg)) + sg->offset;
 
 			memset(buf, 0, cmd->cmnd[4]);
-			kunmap_atomic(buf - sg->offset, KM_IRQ0);
+			kunmap_atomic(buf - sg->offset);
 
 			cmd->result = (DID_OK << 16);
 			cmd->scsi_done(cmd);
diff --git a/drivers/scsi/mvsas/mv_sas.c b/drivers/scsi/mvsas/mv_sas.c
index 4958fef..3f6d523 100644
--- a/drivers/scsi/mvsas/mv_sas.c
+++ b/drivers/scsi/mvsas/mv_sas.c
@@ -1926,11 +1926,11 @@ int mvs_slot_complete(struct mvs_info *mvi, u32 rx_desc, u32 flags)
 	case SAS_PROTOCOL_SMP: {
 			struct scatterlist *sg_resp = &task->smp_task.smp_resp;
 			tstat->stat = SAM_STAT_GOOD;
-			to = kmap_atomic(sg_page(sg_resp), KM_IRQ0);
+			to = kmap_atomic(sg_page(sg_resp));
 			memcpy(to + sg_resp->offset,
 				slot->response + sizeof(struct mvs_err_info),
 				sg_dma_len(sg_resp));
-			kunmap_atomic(to, KM_IRQ0);
+			kunmap_atomic(to);
 			break;
 		}
 
diff --git a/drivers/scsi/scsi_debug.c b/drivers/scsi/scsi_debug.c
index 6888b2c..68da6c0 100644
--- a/drivers/scsi/scsi_debug.c
+++ b/drivers/scsi/scsi_debug.c
@@ -1778,7 +1778,7 @@ static int prot_verify_read(struct scsi_cmnd *SCpnt, sector_t start_sec,
 	scsi_for_each_prot_sg(SCpnt, psgl, scsi_prot_sg_count(SCpnt), i) {
 		int len = min(psgl->length, resid);
 
-		paddr = kmap_atomic(sg_page(psgl), KM_IRQ0) + psgl->offset;
+		paddr = kmap_atomic(sg_page(psgl)) + psgl->offset;
 		memcpy(paddr, dif_storep + dif_offset(sector), len);
 
 		sector += len >> 3;
@@ -1788,7 +1788,7 @@ static int prot_verify_read(struct scsi_cmnd *SCpnt, sector_t start_sec,
 			sector = do_div(tmp_sec, sdebug_store_sectors);
 		}
 		resid -= len;
-		kunmap_atomic(paddr, KM_IRQ0);
+		kunmap_atomic(paddr);
 	}
 
 	dix_reads++;
@@ -1881,12 +1881,12 @@ static int prot_verify_write(struct scsi_cmnd *SCpnt, sector_t start_sec,
 	BUG_ON(scsi_sg_count(SCpnt) == 0);
 	BUG_ON(scsi_prot_sg_count(SCpnt) == 0);
 
-	paddr = kmap_atomic(sg_page(psgl), KM_IRQ1) + psgl->offset;
+	paddr = kmap_atomic(sg_page(psgl)) + psgl->offset;
 	ppage_offset = 0;
 
 	/* For each data page */
 	scsi_for_each_sg(SCpnt, dsgl, scsi_sg_count(SCpnt), i) {
-		daddr = kmap_atomic(sg_page(dsgl), KM_IRQ0) + dsgl->offset;
+		daddr = kmap_atomic(sg_page(dsgl)) + dsgl->offset;
 
 		/* For each sector-sized chunk in data page */
 		for (j = 0 ; j < dsgl->length ; j += scsi_debug_sector_size) {
@@ -1895,10 +1895,10 @@ static int prot_verify_write(struct scsi_cmnd *SCpnt, sector_t start_sec,
 			 * protection page advance to the next one
 			 */
 			if (ppage_offset >= psgl->length) {
-				kunmap_atomic(paddr, KM_IRQ1);
+				kunmap_atomic(paddr);
 				psgl = sg_next(psgl);
 				BUG_ON(psgl == NULL);
-				paddr = kmap_atomic(sg_page(psgl), KM_IRQ1)
+				paddr = kmap_atomic(sg_page(psgl))
 					+ psgl->offset;
 				ppage_offset = 0;
 			}
@@ -1971,10 +1971,10 @@ static int prot_verify_write(struct scsi_cmnd *SCpnt, sector_t start_sec,
 			ppage_offset += sizeof(struct sd_dif_tuple);
 		}
 
-		kunmap_atomic(daddr, KM_IRQ0);
+		kunmap_atomic(daddr);
 	}
 
-	kunmap_atomic(paddr, KM_IRQ1);
+	kunmap_atomic(paddr);
 
 	dix_writes++;
 
@@ -1982,8 +1982,8 @@ static int prot_verify_write(struct scsi_cmnd *SCpnt, sector_t start_sec,
 
 out:
 	dif_errors++;
-	kunmap_atomic(daddr, KM_IRQ0);
-	kunmap_atomic(paddr, KM_IRQ1);
+	kunmap_atomic(daddr);
+	kunmap_atomic(paddr);
 	return ret;
 }
 
@@ -2303,7 +2303,7 @@ static int resp_xdwriteread(struct scsi_cmnd *scp, unsigned long long lba,
 
 	offset = 0;
 	for_each_sg(sdb->table.sgl, sg, sdb->table.nents, i) {
-		kaddr = (unsigned char *)kmap_atomic(sg_page(sg), KM_USER0);
+		kaddr = (unsigned char *)kmap_atomic(sg_page(sg));
 		if (!kaddr)
 			goto out;
 
@@ -2311,7 +2311,7 @@ static int resp_xdwriteread(struct scsi_cmnd *scp, unsigned long long lba,
 			*(kaddr + sg->offset + j) ^= *(buf + offset + j);
 
 		offset += sg->length;
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 	ret = 0;
 out:
diff --git a/drivers/scsi/scsi_lib.c b/drivers/scsi/scsi_lib.c
index fc3f168..b7ba977 100644
--- a/drivers/scsi/scsi_lib.c
+++ b/drivers/scsi/scsi_lib.c
@@ -2561,7 +2561,7 @@ void *scsi_kmap_atomic_sg(struct scatterlist *sgl, int sg_count,
 	if (*len > sg_len)
 		*len = sg_len;
 
-	return kmap_atomic(page, KM_BIO_SRC_IRQ);
+	return kmap_atomic(page);
 }
 EXPORT_SYMBOL(scsi_kmap_atomic_sg);
 
@@ -2571,6 +2571,6 @@ EXPORT_SYMBOL(scsi_kmap_atomic_sg);
  */
 void scsi_kunmap_atomic_sg(void *virt)
 {
-	kunmap_atomic(virt, KM_BIO_SRC_IRQ);
+	kunmap_atomic(virt);
 }
 EXPORT_SYMBOL(scsi_kunmap_atomic_sg);
diff --git a/drivers/scsi/sd_dif.c b/drivers/scsi/sd_dif.c
index 0cb39ff..e981d97 100644
--- a/drivers/scsi/sd_dif.c
+++ b/drivers/scsi/sd_dif.c
@@ -392,7 +392,7 @@ int sd_dif_prepare(struct request *rq, sector_t hw_sector, unsigned int sector_s
 		virt = bio->bi_integrity->bip_sector & 0xffffffff;
 
 		bip_for_each_vec(iv, bio->bi_integrity, i) {
-			sdt = kmap_atomic(iv->bv_page, KM_USER0)
+			sdt = kmap_atomic(iv->bv_page)
 				+ iv->bv_offset;
 
 			for (j = 0 ; j < iv->bv_len ; j += tuple_sz, sdt++) {
@@ -405,7 +405,7 @@ int sd_dif_prepare(struct request *rq, sector_t hw_sector, unsigned int sector_s
 				phys++;
 			}
 
-			kunmap_atomic(sdt, KM_USER0);
+			kunmap_atomic(sdt);
 		}
 
 		bio->bi_flags |= BIO_MAPPED_INTEGRITY;
@@ -414,7 +414,7 @@ int sd_dif_prepare(struct request *rq, sector_t hw_sector, unsigned int sector_s
 	return 0;
 
 error:
-	kunmap_atomic(sdt, KM_USER0);
+	kunmap_atomic(sdt);
 	sd_printk(KERN_ERR, sdkp, "%s: virt %u, phys %u, ref %u, app %4x\n",
 		  __func__, virt, phys, be32_to_cpu(sdt->ref_tag),
 		  be16_to_cpu(sdt->app_tag));
@@ -453,13 +453,13 @@ void sd_dif_complete(struct scsi_cmnd *scmd, unsigned int good_bytes)
 		virt = bio->bi_integrity->bip_sector & 0xffffffff;
 
 		bip_for_each_vec(iv, bio->bi_integrity, i) {
-			sdt = kmap_atomic(iv->bv_page, KM_USER0)
+			sdt = kmap_atomic(iv->bv_page)
 				+ iv->bv_offset;
 
 			for (j = 0 ; j < iv->bv_len ; j += tuple_sz, sdt++) {
 
 				if (sectors == 0) {
-					kunmap_atomic(sdt, KM_USER0);
+					kunmap_atomic(sdt);
 					return;
 				}
 
@@ -474,7 +474,7 @@ void sd_dif_complete(struct scsi_cmnd *scmd, unsigned int good_bytes)
 				sectors--;
 			}
 
-			kunmap_atomic(sdt, KM_USER0);
+			kunmap_atomic(sdt);
 		}
 	}
 }
diff --git a/drivers/staging/gma500/mmu.c b/drivers/staging/gma500/mmu.c
index c904d73..e80ee82 100644
--- a/drivers/staging/gma500/mmu.c
+++ b/drivers/staging/gma500/mmu.c
@@ -125,14 +125,14 @@ static void psb_page_clflush(struct psb_mmu_driver *driver, struct page* page)
 	int i;
 	uint8_t *clf;
 
-	clf = kmap_atomic(page, KM_USER0);
+	clf = kmap_atomic(page);
 	mb();
 	for (i = 0; i < clflush_count; ++i) {
 		psb_clflush(clf);
 		clf += clflush_add;
 	}
 	mb();
-	kunmap_atomic(clf, KM_USER0);
+	kunmap_atomic(clf);
 }
 
 static void psb_pages_clflush(struct psb_mmu_driver *driver,
@@ -325,7 +325,7 @@ static struct psb_mmu_pt *psb_mmu_alloc_pt(struct psb_mmu_pd *pd)
 
 	spin_lock(lock);
 
-	v = kmap_atomic(pt->p, KM_USER0);
+	v = kmap_atomic(pt->p);
 	clf = (uint8_t *) v;
 	ptes = (uint32_t *) v;
 	for (i = 0; i < (PAGE_SIZE / sizeof(uint32_t)); ++i)
@@ -341,7 +341,7 @@ static struct psb_mmu_pt *psb_mmu_alloc_pt(struct psb_mmu_pd *pd)
 		mb();
 	}
 
-	kunmap_atomic(v, KM_USER0);
+	kunmap_atomic(v);
 	spin_unlock(lock);
 
 	pt->count = 0;
@@ -376,18 +376,18 @@ struct psb_mmu_pt *psb_mmu_pt_alloc_map_lock(struct psb_mmu_pd *pd,
 			continue;
 		}
 
-		v = kmap_atomic(pd->p, KM_USER0);
+		v = kmap_atomic(pd->p);
 		pd->tables[index] = pt;
 		v[index] = (page_to_pfn(pt->p) << 12) | pd->pd_mask;
 		pt->index = index;
-		kunmap_atomic((void *) v, KM_USER0);
+		kunmap_atomic((void *) v);
 
 		if (pd->hw_context != -1) {
 			psb_mmu_clflush(pd->driver, (void *) &v[index]);
 			atomic_set(&pd->driver->needs_tlbflush, 1);
 		}
 	}
-	pt->v = kmap_atomic(pt->p, KM_USER0);
+	pt->v = kmap_atomic(pt->p);
 	return pt;
 }
 
@@ -404,7 +404,7 @@ static struct psb_mmu_pt *psb_mmu_pt_map_lock(struct psb_mmu_pd *pd,
 		spin_unlock(lock);
 		return NULL;
 	}
-	pt->v = kmap_atomic(pt->p, KM_USER0);
+	pt->v = kmap_atomic(pt->p);
 	return pt;
 }
 
@@ -413,9 +413,9 @@ static void psb_mmu_pt_unmap_unlock(struct psb_mmu_pt *pt)
 	struct psb_mmu_pd *pd = pt->pd;
 	uint32_t *v;
 
-	kunmap_atomic(pt->v, KM_USER0);
+	kunmap_atomic(pt->v);
 	if (pt->count == 0) {
-		v = kmap_atomic(pd->p, KM_USER0);
+		v = kmap_atomic(pd->p);
 		v[pt->index] = pd->invalid_pde;
 		pd->tables[pt->index] = NULL;
 
@@ -424,7 +424,7 @@ static void psb_mmu_pt_unmap_unlock(struct psb_mmu_pt *pt)
 					(void *) &v[pt->index]);
 			atomic_set(&pd->driver->needs_tlbflush, 1);
 		}
-		kunmap_atomic(pt->v, KM_USER0);
+		kunmap_atomic(pt->v);
 		spin_unlock(&pd->driver->lock);
 		psb_mmu_free_pt(pt);
 		return;
@@ -457,7 +457,7 @@ void psb_mmu_mirror_gtt(struct psb_mmu_pd *pd,
 	down_read(&driver->sem);
 	spin_lock(&driver->lock);
 
-	v = kmap_atomic(pd->p, KM_USER0);
+	v = kmap_atomic(pd->p);
 	v += start;
 
 	while (gtt_pages--) {
@@ -467,7 +467,7 @@ void psb_mmu_mirror_gtt(struct psb_mmu_pd *pd,
 
 	/*ttm_tt_cache_flush(&pd->p, num_pages);*/
 	psb_pages_clflush(pd->driver, &pd->p, num_pages);
-	kunmap_atomic(v, KM_USER0);
+	kunmap_atomic(v);
 	spin_unlock(&driver->lock);
 
 	if (pd->hw_context != -1)
@@ -830,9 +830,9 @@ int psb_mmu_virtual_to_pfn(struct psb_mmu_pd *pd, uint32_t virtual,
 		uint32_t *v;
 
 		spin_lock(lock);
-		v = kmap_atomic(pd->p, KM_USER0);
+		v = kmap_atomic(pd->p);
 		tmp = v[psb_mmu_pd_index(virtual)];
-		kunmap_atomic(v, KM_USER0);
+		kunmap_atomic(v);
 		spin_unlock(lock);
 
 		if (tmp != pd->invalid_pde || !(tmp & PSB_PTE_VALID) ||
diff --git a/drivers/staging/hv/rndis_filter.c b/drivers/staging/hv/rndis_filter.c
index dbb5201..21fb41c 100644
--- a/drivers/staging/hv/rndis_filter.c
+++ b/drivers/staging/hv/rndis_filter.c
@@ -388,7 +388,7 @@ int rndis_filter_receive(struct hv_device *dev,
 			sizeof(struct rndis_message) :
 			rndis_hdr->msg_len);
 
-	kunmap_atomic(rndis_hdr - pkt->page_buf[0].offset, KM_IRQ0);
+	kunmap_atomic(rndis_hdr - pkt->page_buf[0].offset);
 
 	dump_rndis_message(dev, &rndis_msg);
 
diff --git a/drivers/staging/hv/storvsc_drv.c b/drivers/staging/hv/storvsc_drv.c
index 7effaf3..ff00e86f 100644
--- a/drivers/staging/hv/storvsc_drv.c
+++ b/drivers/staging/hv/storvsc_drv.c
@@ -215,7 +215,7 @@ static unsigned int copy_from_bounce_buffer(struct scatterlist *orig_sgl,
 
 			if (bounce_sgl[j].offset == bounce_sgl[j].length) {
 				/* full */
-				kunmap_atomic((void *)bounce_addr, KM_IRQ0);
+				kunmap_atomic((void *)bounce_addr);
 				j++;
 
 				/* if we need to use another bounce buffer */
@@ -225,7 +225,7 @@ static unsigned int copy_from_bounce_buffer(struct scatterlist *orig_sgl,
 					sg_page((&bounce_sgl[j])), KM_IRQ0);
 			} else if (destlen == 0 && i == orig_sgl_count - 1) {
 				/* unmap the last bounce that is < PAGE_SIZE */
-				kunmap_atomic((void *)bounce_addr, KM_IRQ0);
+				kunmap_atomic((void *)bounce_addr);
 			}
 		}
 
@@ -281,7 +281,7 @@ static unsigned int copy_to_bounce_buffer(struct scatterlist *orig_sgl,
 
 			if (bounce_sgl[j].length == PAGE_SIZE) {
 				/* full..move to next entry */
-				kunmap_atomic((void *)bounce_addr, KM_IRQ0);
+				kunmap_atomic((void *)bounce_addr);
 				j++;
 
 				/* if we need to use another bounce buffer */
@@ -292,11 +292,11 @@ static unsigned int copy_to_bounce_buffer(struct scatterlist *orig_sgl,
 
 			} else if (srclen == 0 && i == orig_sgl_count - 1) {
 				/* unmap the last bounce that is < PAGE_SIZE */
-				kunmap_atomic((void *)bounce_addr, KM_IRQ0);
+				kunmap_atomic((void *)bounce_addr);
 			}
 		}
 
-		kunmap_atomic((void *)(src_addr - orig_sgl[i].offset), KM_IRQ0);
+		kunmap_atomic((void *)(src_addr - orig_sgl[i].offset));
 	}
 
 	local_irq_restore(flags);
diff --git a/drivers/staging/pohmelfs/inode.c b/drivers/staging/pohmelfs/inode.c
index f3c6060..5639caa 100644
--- a/drivers/staging/pohmelfs/inode.c
+++ b/drivers/staging/pohmelfs/inode.c
@@ -606,11 +606,11 @@ static int pohmelfs_write_begin(struct file *file, struct address_space *mapping
 		}
 
 		if (len != PAGE_CACHE_SIZE) {
-			void *kaddr = kmap_atomic(page, KM_USER0);
+			void *kaddr = kmap_atomic(page);
 
 			memset(kaddr + start, 0, PAGE_CACHE_SIZE - start);
 			flush_dcache_page(page);
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 		}
 		SetPageUptodate(page);
 	}
@@ -636,11 +636,11 @@ static int pohmelfs_write_end(struct file *file, struct address_space *mapping,
 
 	if (copied != len) {
 		unsigned from = pos & (PAGE_CACHE_SIZE - 1);
-		void *kaddr = kmap_atomic(page, KM_USER0);
+		void *kaddr = kmap_atomic(page);
 
 		memset(kaddr + from + copied, 0, len - copied);
 		flush_dcache_page(page);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 
 	SetPageUptodate(page);
diff --git a/drivers/staging/rtl8192u/ieee80211/internal.h b/drivers/staging/rtl8192u/ieee80211/internal.h
index a7c096e..85571d4 100644
--- a/drivers/staging/rtl8192u/ieee80211/internal.h
+++ b/drivers/staging/rtl8192u/ieee80211/internal.h
@@ -32,12 +32,12 @@ static inline enum km_type crypto_kmap_type(int out)
 
 static inline void *crypto_kmap(struct page *page, int out)
 {
-	return kmap_atomic(page, crypto_kmap_type(out));
+	return kmap_atomic(page);
 }
 
 static inline void crypto_kunmap(void *vaddr, int out)
 {
-	kunmap_atomic(vaddr, crypto_kmap_type(out));
+	kunmap_atomic(vaddr);
 }
 
 static inline void crypto_yield(struct crypto_tfm *tfm)
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 855a5bb..f05c526 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -422,13 +422,13 @@ static int zbud_decompress(struct page *page, struct zbud_hdr *zh)
 	}
 	ASSERT_SENTINEL(zh, ZBH);
 	BUG_ON(zh->size == 0 || zh->size > zbud_max_buddy_size());
-	to_va = kmap_atomic(page, KM_USER0);
+	to_va = kmap_atomic(page);
 	size = zh->size;
 	from_va = zbud_data(zh, size);
 	ret = lzo1x_decompress_safe(from_va, size, to_va, &out_len);
 	BUG_ON(ret != LZO_E_OK);
 	BUG_ON(out_len != PAGE_SIZE);
-	kunmap_atomic(to_va, KM_USER0);
+	kunmap_atomic(to_va);
 out:
 	spin_unlock(&zbpg->lock);
 	return ret;
@@ -677,13 +677,13 @@ static struct zv_hdr *zv_create(struct xv_pool *xvpool, uint32_t pool_id,
 		goto out;
 	zv_curr_dist_counts[chunks]++;
 	zv_cumul_dist_counts[chunks]++;
-	zv = kmap_atomic(page, KM_USER0) + offset;
+	zv = kmap_atomic(page) + offset;
 	zv->index = index;
 	zv->oid = *oid;
 	zv->pool_id = pool_id;
 	SET_SENTINEL(zv, ZVH);
 	memcpy((char *)zv + sizeof(struct zv_hdr), cdata, clen);
-	kunmap_atomic(zv, KM_USER0);
+	kunmap_atomic(zv);
 out:
 	return zv;
 }
@@ -719,10 +719,10 @@ static void zv_decompress(struct page *page, struct zv_hdr *zv)
 	ASSERT_SENTINEL(zv, ZVH);
 	size = xv_get_object_size(zv) - sizeof(*zv);
 	BUG_ON(size == 0);
-	to_va = kmap_atomic(page, KM_USER0);
+	to_va = kmap_atomic(page);
 	ret = lzo1x_decompress_safe((char *)zv + sizeof(*zv),
 					size, to_va, &clen);
-	kunmap_atomic(to_va, KM_USER0);
+	kunmap_atomic(to_va);
 	BUG_ON(ret != LZO_E_OK);
 	BUG_ON(clen != PAGE_SIZE);
 }
@@ -1316,12 +1316,12 @@ static int zcache_compress(struct page *from, void **out_va, size_t *out_len)
 	BUG_ON(!irqs_disabled());
 	if (unlikely(dmem == NULL || wmem == NULL))
 		goto out;  /* no buffer, so can't compress */
-	from_va = kmap_atomic(from, KM_USER0);
+	from_va = kmap_atomic(from);
 	mb();
 	ret = lzo1x_1_compress(from_va, PAGE_SIZE, dmem, out_len, wmem);
 	BUG_ON(ret != LZO_E_OK);
 	*out_va = dmem;
-	kunmap_atomic(from_va, KM_USER0);
+	kunmap_atomic(from_va);
 	ret = 1;
 out:
 	return ret;
diff --git a/drivers/staging/zram/xvmalloc.c b/drivers/staging/zram/xvmalloc.c
index 1f9c508..3b03358 100644
--- a/drivers/staging/zram/xvmalloc.c
+++ b/drivers/staging/zram/xvmalloc.c
@@ -60,13 +60,13 @@ static void *get_ptr_atomic(struct page *page, u16 offset, enum km_type type)
 {
 	unsigned char *base;
 
-	base = kmap_atomic(page, type);
+	base = kmap_atomic(page);
 	return base + offset;
 }
 
 static void put_ptr_atomic(void *ptr, enum km_type type)
 {
-	kunmap_atomic(ptr, type);
+	kunmap_atomic(ptr);
 }
 
 static u32 get_blockprev(struct block_header *block)
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index d70ec1a..abe37e8 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -161,9 +161,9 @@ static void zram_free_page(struct zram *zram, size_t index)
 		goto out;
 	}
 
-	obj = kmap_atomic(page, KM_USER0) + offset;
+	obj = kmap_atomic(page) + offset;
 	clen = xv_get_object_size(obj) - sizeof(struct zobj_header);
-	kunmap_atomic(obj, KM_USER0);
+	kunmap_atomic(obj);
 
 	xv_free(zram->mem_pool, page, offset);
 	if (clen <= PAGE_SIZE / 2)
@@ -182,9 +182,9 @@ static void handle_zero_page(struct bio_vec *bvec)
 	struct page *page = bvec->bv_page;
 	void *user_mem;
 
-	user_mem = kmap_atomic(page, KM_USER0);
+	user_mem = kmap_atomic(page);
 	memset(user_mem + bvec->bv_offset, 0, bvec->bv_len);
-	kunmap_atomic(user_mem, KM_USER0);
+	kunmap_atomic(user_mem);
 
 	flush_dcache_page(page);
 }
@@ -195,12 +195,12 @@ static void handle_uncompressed_page(struct zram *zram, struct bio_vec *bvec,
 	struct page *page = bvec->bv_page;
 	unsigned char *user_mem, *cmem;
 
-	user_mem = kmap_atomic(page, KM_USER0);
-	cmem = kmap_atomic(zram->table[index].page, KM_USER1);
+	user_mem = kmap_atomic(page);
+	cmem = kmap_atomic(zram->table[index].page);
 
 	memcpy(user_mem + bvec->bv_offset, cmem + offset, bvec->bv_len);
-	kunmap_atomic(cmem, KM_USER1);
-	kunmap_atomic(user_mem, KM_USER0);
+	kunmap_atomic(cmem);
+	kunmap_atomic(user_mem);
 
 	flush_dcache_page(page);
 }
@@ -249,12 +249,12 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 		}
 	}
 
-	user_mem = kmap_atomic(page, KM_USER0);
+	user_mem = kmap_atomic(page);
 	if (!is_partial_io(bvec))
 		uncmem = user_mem;
 	clen = PAGE_SIZE;
 
-	cmem = kmap_atomic(zram->table[index].page, KM_USER1) +
+	cmem = kmap_atomic(zram->table[index].page) +
 		zram->table[index].offset;
 
 	ret = lzo1x_decompress_safe(cmem + sizeof(*zheader),
@@ -267,8 +267,8 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 		kfree(uncmem);
 	}
 
-	kunmap_atomic(cmem, KM_USER1);
-	kunmap_atomic(user_mem, KM_USER0);
+	kunmap_atomic(cmem);
+	kunmap_atomic(user_mem);
 
 	/* Should NEVER happen. Return bio error if it does. */
 	if (unlikely(ret != LZO_E_OK)) {
@@ -295,20 +295,20 @@ static int zram_read_before_write(struct zram *zram, char *mem, u32 index)
 		return 0;
 	}
 
-	cmem = kmap_atomic(zram->table[index].page, KM_USER0) +
+	cmem = kmap_atomic(zram->table[index].page) +
 		zram->table[index].offset;
 
 	/* Page is stored uncompressed since it's incompressible */
 	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
 		memcpy(mem, cmem, PAGE_SIZE);
-		kunmap_atomic(cmem, KM_USER0);
+		kunmap_atomic(cmem);
 		return 0;
 	}
 
 	ret = lzo1x_decompress_safe(cmem + sizeof(*zheader),
 				    xv_get_object_size(cmem) - sizeof(*zheader),
 				    mem, &clen);
-	kunmap_atomic(cmem, KM_USER0);
+	kunmap_atomic(cmem);
 
 	/* Should NEVER happen. Return bio error if it does. */
 	if (unlikely(ret != LZO_E_OK)) {
@@ -359,7 +359,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	    zram_test_flag(zram, index, ZRAM_ZERO))
 		zram_free_page(zram, index);
 
-	user_mem = kmap_atomic(page, KM_USER0);
+	user_mem = kmap_atomic(page);
 
 	if (is_partial_io(bvec))
 		memcpy(uncmem + offset, user_mem + bvec->bv_offset,
@@ -368,7 +368,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		uncmem = user_mem;
 
 	if (page_zero_filled(uncmem)) {
-		kunmap_atomic(user_mem, KM_USER0);
+		kunmap_atomic(user_mem);
 		if (is_partial_io(bvec))
 			kfree(uncmem);
 		zram_stat_inc(&zram->stats.pages_zero);
@@ -380,7 +380,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	ret = lzo1x_1_compress(uncmem, PAGE_SIZE, src, &clen,
 			       zram->compress_workmem);
 
-	kunmap_atomic(user_mem, KM_USER0);
+	kunmap_atomic(user_mem);
 	if (is_partial_io(bvec))
 			kfree(uncmem);
 
@@ -408,7 +408,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		zram_set_flag(zram, index, ZRAM_UNCOMPRESSED);
 		zram_stat_inc(&zram->stats.pages_expand);
 		zram->table[index].page = page_store;
-		src = kmap_atomic(page, KM_USER0);
+		src = kmap_atomic(page);
 		goto memstore;
 	}
 
@@ -424,7 +424,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 memstore:
 	zram->table[index].offset = store_offset;
 
-	cmem = kmap_atomic(zram->table[index].page, KM_USER1) +
+	cmem = kmap_atomic(zram->table[index].page) +
 		zram->table[index].offset;
 
 #if 0
@@ -438,9 +438,9 @@ memstore:
 
 	memcpy(cmem, src, clen);
 
-	kunmap_atomic(cmem, KM_USER1);
+	kunmap_atomic(cmem);
 	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED)))
-		kunmap_atomic(src, KM_USER0);
+		kunmap_atomic(src);
 
 	/* Update stats */
 	zram_stat64_add(zram, &zram->stats.compr_size, clen);
diff --git a/drivers/target/target_core_transport.c b/drivers/target/target_core_transport.c
index 8976032..f1539b7 100644
--- a/drivers/target/target_core_transport.c
+++ b/drivers/target/target_core_transport.c
@@ -2725,7 +2725,7 @@ static void transport_xor_callback(struct se_cmd *cmd)
 
 	offset = 0;
 	for_each_sg(cmd->t_bidi_data_sg, sg, cmd->t_bidi_data_nents, count) {
-		addr = kmap_atomic(sg_page(sg), KM_USER0);
+		addr = kmap_atomic(sg_page(sg));
 		if (!addr)
 			goto out;
 
@@ -2733,7 +2733,7 @@ static void transport_xor_callback(struct se_cmd *cmd)
 			*(addr + sg->offset + i) ^= *(buf + offset + i);
 
 		offset += sg->length;
-		kunmap_atomic(addr, KM_USER0);
+		kunmap_atomic(addr);
 	}
 
 out:
diff --git a/drivers/target/tcm_fc/tfc_io.c b/drivers/target/tcm_fc/tfc_io.c
index c37f4cd..5794247 100644
--- a/drivers/target/tcm_fc/tfc_io.c
+++ b/drivers/target/tcm_fc/tfc_io.c
@@ -150,14 +150,13 @@ int ft_queue_data_in(struct se_cmd *se_cmd)
 					PAGE_SIZE << compound_order(page);
 		} else {
 			BUG_ON(!page);
-			from = kmap_atomic(page + (mem_off >> PAGE_SHIFT),
-					   KM_SOFTIRQ0);
+			from = kmap_atomic(page + (mem_off >> PAGE_SHIFT));
 			page_addr = from;
 			from += mem_off & ~PAGE_MASK;
 			tlen = min(tlen, (size_t)(PAGE_SIZE -
 						(mem_off & ~PAGE_MASK)));
 			memcpy(to, from, tlen);
-			kunmap_atomic(page_addr, KM_SOFTIRQ0);
+			kunmap_atomic(page_addr);
 			to += tlen;
 		}
 
@@ -297,14 +296,13 @@ void ft_recv_write_data(struct ft_cmd *cmd, struct fc_frame *fp)
 
 		tlen = min(mem_len, frame_len);
 
-		to = kmap_atomic(page + (mem_off >> PAGE_SHIFT),
-				 KM_SOFTIRQ0);
+		to = kmap_atomic(page + (mem_off >> PAGE_SHIFT));
 		page_addr = to;
 		to += mem_off & ~PAGE_MASK;
 		tlen = min(tlen, (size_t)(PAGE_SIZE -
 					  (mem_off & ~PAGE_MASK)));
 		memcpy(to, from, tlen);
-		kunmap_atomic(page_addr, KM_SOFTIRQ0);
+		kunmap_atomic(page_addr);
 
 		from += tlen;
 		frame_len -= tlen;
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c14c42b..bdb2d64 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -937,9 +937,9 @@ static int set_bit_to_user(int nr, void __user *addr)
 	if (r < 0)
 		return r;
 	BUG_ON(r != 1);
-	base = kmap_atomic(page, KM_USER0);
+	base = kmap_atomic(page);
 	set_bit(bit, base);
-	kunmap_atomic(base, KM_USER0);
+	kunmap_atomic(base);
 	set_page_dirty_lock(page);
 	put_page(page);
 	return 0;
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index 346e328..ba93e59 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -365,10 +365,10 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 		_debug("extract data");
 		if (call->count > 0) {
 			page = call->reply3;
-			buffer = kmap_atomic(page, KM_USER0);
+			buffer = kmap_atomic(page);
 			ret = afs_extract_data(call, skb, last, buffer,
 					       call->count);
-			kunmap_atomic(buffer, KM_USER0);
+			kunmap_atomic(buffer);
 			switch (ret) {
 			case 0:		break;
 			case -EAGAIN:	return 0;
@@ -411,9 +411,9 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 	if (call->count < PAGE_SIZE) {
 		_debug("clear");
 		page = call->reply3;
-		buffer = kmap_atomic(page, KM_USER0);
+		buffer = kmap_atomic(page);
 		memset(buffer + call->count, 0, PAGE_SIZE - call->count);
-		kunmap_atomic(buffer, KM_USER0);
+		kunmap_atomic(buffer);
 	}
 
 	_leave(" = 0 [done]");
diff --git a/fs/afs/mntpt.c b/fs/afs/mntpt.c
index aa59184..4405561 100644
--- a/fs/afs/mntpt.c
+++ b/fs/afs/mntpt.c
@@ -200,9 +200,9 @@ static struct vfsmount *afs_mntpt_do_automount(struct dentry *mntpt)
 		if (PageError(page))
 			goto error;
 
-		buf = kmap_atomic(page, KM_USER0);
+		buf = kmap_atomic(page);
 		memcpy(devname, buf, size);
-		kunmap_atomic(buf, KM_USER0);
+		kunmap_atomic(buf);
 		page_cache_release(page);
 		page = NULL;
 	}
diff --git a/fs/aio.c b/fs/aio.c
index e29ec48..13b84de 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -160,7 +160,7 @@ static int aio_setup_ring(struct kioctx *ctx)
 
 	info->nr = nr_events;		/* trusted copy */
 
-	ring = kmap_atomic(info->ring_pages[0], KM_USER0);
+	ring = kmap_atomic(info->ring_pages[0]);
 	ring->nr = nr_events;	/* user copy */
 	ring->id = ctx->user_id;
 	ring->head = ring->tail = 0;
@@ -168,32 +168,32 @@ static int aio_setup_ring(struct kioctx *ctx)
 	ring->compat_features = AIO_RING_COMPAT_FEATURES;
 	ring->incompat_features = AIO_RING_INCOMPAT_FEATURES;
 	ring->header_length = sizeof(struct aio_ring);
-	kunmap_atomic(ring, KM_USER0);
+	kunmap_atomic(ring);
 
 	return 0;
 }
 
 
 /* aio_ring_event: returns a pointer to the event at the given index from
- * kmap_atomic(, km).  Release the pointer with put_aio_ring_event();
+ * kmap_atomic().  Release the pointer with put_aio_ring_event();
  */
 #define AIO_EVENTS_PER_PAGE	(PAGE_SIZE / sizeof(struct io_event))
 #define AIO_EVENTS_FIRST_PAGE	((PAGE_SIZE - sizeof(struct aio_ring)) / sizeof(struct io_event))
 #define AIO_EVENTS_OFFSET	(AIO_EVENTS_PER_PAGE - AIO_EVENTS_FIRST_PAGE)
 
-#define aio_ring_event(info, nr, km) ({					\
+#define aio_ring_event(info, nr) ({					\
 	unsigned pos = (nr) + AIO_EVENTS_OFFSET;			\
 	struct io_event *__event;					\
 	__event = kmap_atomic(						\
-			(info)->ring_pages[pos / AIO_EVENTS_PER_PAGE], km); \
+			(info)->ring_pages[pos / AIO_EVENTS_PER_PAGE]); \
 	__event += pos % AIO_EVENTS_PER_PAGE;				\
 	__event;							\
 })
 
-#define put_aio_ring_event(event, km) do {	\
+#define put_aio_ring_event(event) do {	\
 	struct io_event *__event = (event);	\
 	(void)__event;				\
-	kunmap_atomic((void *)((unsigned long)__event & PAGE_MASK), km); \
+	kunmap_atomic((void *)((unsigned long)__event & PAGE_MASK)); \
 } while(0)
 
 static void ctx_rcu_free(struct rcu_head *head)
@@ -463,13 +463,13 @@ static struct kiocb *__aio_get_req(struct kioctx *ctx)
 	 * accept an event from this io.
 	 */
 	spin_lock_irq(&ctx->ctx_lock);
-	ring = kmap_atomic(ctx->ring_info.ring_pages[0], KM_USER0);
+	ring = kmap_atomic(ctx->ring_info.ring_pages[0]);
 	if (ctx->reqs_active < aio_ring_avail(&ctx->ring_info, ring)) {
 		list_add(&req->ki_list, &ctx->active_reqs);
 		ctx->reqs_active++;
 		okay = 1;
 	}
-	kunmap_atomic(ring, KM_USER0);
+	kunmap_atomic(ring);
 	spin_unlock_irq(&ctx->ctx_lock);
 
 	if (!okay) {
@@ -939,10 +939,10 @@ int aio_complete(struct kiocb *iocb, long res, long res2)
 	if (kiocbIsCancelled(iocb))
 		goto put_rq;
 
-	ring = kmap_atomic(info->ring_pages[0], KM_IRQ1);
+	ring = kmap_atomic(info->ring_pages[0]);
 
 	tail = info->tail;
-	event = aio_ring_event(info, tail, KM_IRQ0);
+	event = aio_ring_event(info, tail);
 	if (++tail >= info->nr)
 		tail = 0;
 
@@ -963,8 +963,8 @@ int aio_complete(struct kiocb *iocb, long res, long res2)
 	info->tail = tail;
 	ring->tail = tail;
 
-	put_aio_ring_event(event, KM_IRQ0);
-	kunmap_atomic(ring, KM_IRQ1);
+	put_aio_ring_event(event);
+	kunmap_atomic(ring);
 
 	pr_debug("added to ring %p at [%lu]\n", iocb, tail);
 
@@ -1009,7 +1009,7 @@ static int aio_read_evt(struct kioctx *ioctx, struct io_event *ent)
 	unsigned long head;
 	int ret = 0;
 
-	ring = kmap_atomic(info->ring_pages[0], KM_USER0);
+	ring = kmap_atomic(info->ring_pages[0]);
 	dprintk("in aio_read_evt h%lu t%lu m%lu\n",
 		 (unsigned long)ring->head, (unsigned long)ring->tail,
 		 (unsigned long)ring->nr);
@@ -1021,18 +1021,18 @@ static int aio_read_evt(struct kioctx *ioctx, struct io_event *ent)
 
 	head = ring->head % info->nr;
 	if (head != ring->tail) {
-		struct io_event *evp = aio_ring_event(info, head, KM_USER1);
+		struct io_event *evp = aio_ring_event(info, head);
 		*ent = *evp;
 		head = (head + 1) % info->nr;
 		smp_mb(); /* finish reading the event before updatng the head */
 		ring->head = head;
 		ret = 1;
-		put_aio_ring_event(evp, KM_USER1);
+		put_aio_ring_event(evp);
 	}
 	spin_unlock(&info->ring_lock);
 
 out:
-	kunmap_atomic(ring, KM_USER0);
+	kunmap_atomic(ring);
 	dprintk("leaving aio_read_evt: %d  h%lu t%lu\n", ret,
 		 (unsigned long)ring->head, (unsigned long)ring->tail);
 	return ret;
diff --git a/fs/bio-integrity.c b/fs/bio-integrity.c
index 9c5e6b2..26ca996 100644
--- a/fs/bio-integrity.c
+++ b/fs/bio-integrity.c
@@ -356,7 +356,7 @@ static void bio_integrity_generate(struct bio *bio)
 	bix.sector_size = bi->sector_size;
 
 	bio_for_each_segment(bv, bio, i) {
-		void *kaddr = kmap_atomic(bv->bv_page, KM_USER0);
+		void *kaddr = kmap_atomic(bv->bv_page);
 		bix.data_buf = kaddr + bv->bv_offset;
 		bix.data_size = bv->bv_len;
 		bix.prot_buf = prot_buf;
@@ -370,7 +370,7 @@ static void bio_integrity_generate(struct bio *bio)
 		total += sectors * bi->tuple_size;
 		BUG_ON(total > bio->bi_integrity->bip_size);
 
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 }
 
@@ -497,7 +497,7 @@ static int bio_integrity_verify(struct bio *bio)
 	bix.sector_size = bi->sector_size;
 
 	bio_for_each_segment(bv, bio, i) {
-		void *kaddr = kmap_atomic(bv->bv_page, KM_USER0);
+		void *kaddr = kmap_atomic(bv->bv_page);
 		bix.data_buf = kaddr + bv->bv_offset;
 		bix.data_size = bv->bv_len;
 		bix.prot_buf = prot_buf;
@@ -506,7 +506,7 @@ static int bio_integrity_verify(struct bio *bio)
 		ret = bi->verify_fn(&bix);
 
 		if (ret) {
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 			return ret;
 		}
 
@@ -516,7 +516,7 @@ static int bio_integrity_verify(struct bio *bio)
 		total += sectors * bi->tuple_size;
 		BUG_ON(total > bio->bi_integrity->bip_size);
 
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 
 	return ret;
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 8ec5d86..d93aefb 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -119,10 +119,10 @@ static int check_compressed_csum(struct inode *inode,
 		page = cb->compressed_pages[i];
 		csum = ~(u32)0;
 
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		csum = btrfs_csum_data(root, kaddr, csum, PAGE_CACHE_SIZE);
 		btrfs_csum_final(csum, (char *)&csum);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 
 		if (csum != *cb_sum) {
 			printk(KERN_INFO "btrfs csum failed ino %llu "
@@ -520,10 +520,10 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 			if (zero_offset) {
 				int zeros;
 				zeros = PAGE_CACHE_SIZE - zero_offset;
-				userpage = kmap_atomic(page, KM_USER0);
+				userpage = kmap_atomic(page);
 				memset(userpage + zero_offset, 0, zeros);
 				flush_dcache_page(page);
-				kunmap_atomic(userpage, KM_USER0);
+				kunmap_atomic(userpage);
 			}
 		}
 
@@ -990,9 +990,9 @@ int btrfs_decompress_buf2page(char *buf, unsigned long buf_start,
 		bytes = min(PAGE_CACHE_SIZE - *pg_offset,
 			    PAGE_CACHE_SIZE - buf_offset);
 		bytes = min(bytes, working_bytes);
-		kaddr = kmap_atomic(page_out, KM_USER0);
+		kaddr = kmap_atomic(page_out);
 		memcpy(kaddr + *pg_offset, buf + buf_offset, bytes);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		flush_dcache_page(page_out);
 
 		*pg_offset += bytes;
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index d418164..77842be 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -1950,10 +1950,10 @@ static int __extent_read_full_page(struct extent_io_tree *tree,
 
 		if (zero_offset) {
 			iosize = PAGE_CACHE_SIZE - zero_offset;
-			userpage = kmap_atomic(page, KM_USER0);
+			userpage = kmap_atomic(page);
 			memset(userpage + zero_offset, 0, iosize);
 			flush_dcache_page(page);
-			kunmap_atomic(userpage, KM_USER0);
+			kunmap_atomic(userpage);
 		}
 	}
 	while (cur <= end) {
@@ -1962,10 +1962,10 @@ static int __extent_read_full_page(struct extent_io_tree *tree,
 			struct extent_state *cached = NULL;
 
 			iosize = PAGE_CACHE_SIZE - pg_offset;
-			userpage = kmap_atomic(page, KM_USER0);
+			userpage = kmap_atomic(page);
 			memset(userpage + pg_offset, 0, iosize);
 			flush_dcache_page(page);
-			kunmap_atomic(userpage, KM_USER0);
+			kunmap_atomic(userpage);
 			set_extent_uptodate(tree, cur, cur + iosize - 1,
 					    &cached, GFP_NOFS);
 			unlock_extent_cached(tree, cur, cur + iosize - 1,
@@ -2011,10 +2011,10 @@ static int __extent_read_full_page(struct extent_io_tree *tree,
 			char *userpage;
 			struct extent_state *cached = NULL;
 
-			userpage = kmap_atomic(page, KM_USER0);
+			userpage = kmap_atomic(page);
 			memset(userpage + pg_offset, 0, iosize);
 			flush_dcache_page(page);
-			kunmap_atomic(userpage, KM_USER0);
+			kunmap_atomic(userpage);
 
 			set_extent_uptodate(tree, cur, cur + iosize - 1,
 					    &cached, GFP_NOFS);
@@ -2156,10 +2156,10 @@ static int __extent_writepage(struct page *page, struct writeback_control *wbc,
 	if (page->index == end_index) {
 		char *userpage;
 
-		userpage = kmap_atomic(page, KM_USER0);
+		userpage = kmap_atomic(page);
 		memset(userpage + pg_offset, 0,
 		       PAGE_CACHE_SIZE - pg_offset);
-		kunmap_atomic(userpage, KM_USER0);
+		kunmap_atomic(userpage);
 		flush_dcache_page(page);
 	}
 	pg_offset = 0;
diff --git a/fs/btrfs/file-item.c b/fs/btrfs/file-item.c
index b910694..084137c 100644
--- a/fs/btrfs/file-item.c
+++ b/fs/btrfs/file-item.c
@@ -447,13 +447,13 @@ int btrfs_csum_one_bio(struct btrfs_root *root, struct inode *inode,
 			sums->bytenr = ordered->start;
 		}
 
-		data = kmap_atomic(bvec->bv_page, KM_USER0);
+		data = kmap_atomic(bvec->bv_page);
 		sector_sum->sum = ~(u32)0;
 		sector_sum->sum = btrfs_csum_data(root,
 						  data + bvec->bv_offset,
 						  sector_sum->sum,
 						  bvec->bv_len);
-		kunmap_atomic(data, KM_USER0);
+		kunmap_atomic(data);
 		btrfs_csum_final(sector_sum->sum,
 				 (char *)&sector_sum->sum);
 		sector_sum->bytenr = disk_bytenr;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 0ccc743..8c6c64f 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -170,9 +170,9 @@ static noinline int insert_inline_extent(struct btrfs_trans_handle *trans,
 			cur_size = min_t(unsigned long, compressed_size,
 				       PAGE_CACHE_SIZE);
 
-			kaddr = kmap_atomic(cpage, KM_USER0);
+			kaddr = kmap_atomic(cpage);
 			write_extent_buffer(leaf, kaddr, ptr, cur_size);
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 
 			i++;
 			ptr += cur_size;
@@ -184,10 +184,10 @@ static noinline int insert_inline_extent(struct btrfs_trans_handle *trans,
 		page = find_get_page(inode->i_mapping,
 				     start >> PAGE_CACHE_SHIFT);
 		btrfs_set_file_extent_compression(leaf, ei, 0);
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		offset = start & (PAGE_CACHE_SIZE - 1);
 		write_extent_buffer(leaf, kaddr + offset, ptr, size);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		page_cache_release(page);
 	}
 	btrfs_mark_buffer_dirty(leaf);
@@ -416,10 +416,10 @@ again:
 			 * sending it down to disk
 			 */
 			if (offset) {
-				kaddr = kmap_atomic(page, KM_USER0);
+				kaddr = kmap_atomic(page);
 				memset(kaddr + offset, 0,
 				       PAGE_CACHE_SIZE - offset);
-				kunmap_atomic(kaddr, KM_USER0);
+				kunmap_atomic(kaddr);
 			}
 			will_compress = 1;
 		}
@@ -2000,7 +2000,7 @@ static int btrfs_readpage_end_io_hook(struct page *page, u64 start, u64 end,
 	} else {
 		ret = get_state_private(io_tree, start, &private);
 	}
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	if (ret)
 		goto zeroit;
 
@@ -2009,7 +2009,7 @@ static int btrfs_readpage_end_io_hook(struct page *page, u64 start, u64 end,
 	if (csum != private)
 		goto zeroit;
 
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 good:
 	/* if the io failure tree for this inode is non-empty,
 	 * check to see if we've recovered from a failed IO
@@ -2025,7 +2025,7 @@ zeroit:
 		       (unsigned long long)private);
 	memset(kaddr + offset, 1, end - start + 1);
 	flush_dcache_page(page);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	if (private == 0)
 		return 0;
 	return -EIO;
@@ -4934,12 +4934,12 @@ static noinline int uncompress_inline(struct btrfs_path *path,
 	ret = btrfs_decompress(compress_type, tmp, page,
 			       extent_offset, inline_size, max_size);
 	if (ret) {
-		char *kaddr = kmap_atomic(page, KM_USER0);
+		char *kaddr = kmap_atomic(page);
 		unsigned long copy_size = min_t(u64,
 				  PAGE_CACHE_SIZE - pg_offset,
 				  max_size - extent_offset);
 		memset(kaddr + pg_offset, 0, copy_size);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 	kfree(tmp);
 	return 0;
@@ -5716,11 +5716,11 @@ static void btrfs_endio_direct_read(struct bio *bio, int err)
 			unsigned long flags;
 
 			local_irq_save(flags);
-			kaddr = kmap_atomic(page, KM_IRQ0);
+			kaddr = kmap_atomic(page);
 			csum = btrfs_csum_data(root, kaddr + bvec->bv_offset,
 					       csum, bvec->bv_len);
 			btrfs_csum_final(csum, (char *)&csum);
-			kunmap_atomic(kaddr, KM_IRQ0);
+			kunmap_atomic(kaddr);
 			local_irq_restore(flags);
 
 			flush_dcache_page(bvec->bv_page);
diff --git a/fs/btrfs/lzo.c b/fs/btrfs/lzo.c
index a178f5e..743b86f 100644
--- a/fs/btrfs/lzo.c
+++ b/fs/btrfs/lzo.c
@@ -411,9 +411,9 @@ static int lzo_decompress(struct list_head *ws, unsigned char *data_in,
 
 	bytes = min_t(unsigned long, destlen, out_len - start_byte);
 
-	kaddr = kmap_atomic(dest_page, KM_USER0);
+	kaddr = kmap_atomic(dest_page);
 	memcpy(kaddr, workspace->buf + start_byte, bytes);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 out:
 	return ret;
 }
diff --git a/fs/btrfs/scrub.c b/fs/btrfs/scrub.c
index a8d03d5..a6be823 100644
--- a/fs/btrfs/scrub.c
+++ b/fs/btrfs/scrub.c
@@ -223,7 +223,7 @@ static int scrub_fixup_check(struct scrub_bio *sbio, int ix)
 	u64 flags = sbio->spag[ix].flags;
 
 	page = sbio->bio->bi_io_vec[ix].bv_page;
-	buffer = kmap_atomic(page, KM_USER0);
+	buffer = kmap_atomic(page);
 	if (flags & BTRFS_EXTENT_FLAG_DATA) {
 		ret = scrub_checksum_data(sbio->sdev,
 					  sbio->spag + ix, buffer);
@@ -235,7 +235,7 @@ static int scrub_fixup_check(struct scrub_bio *sbio, int ix)
 	} else {
 		WARN_ON(1);
 	}
-	kunmap_atomic(buffer, KM_USER0);
+	kunmap_atomic(buffer);
 
 	return ret;
 }
@@ -404,7 +404,7 @@ static void scrub_checksum(struct btrfs_work *work)
 	}
 	for (i = 0; i < sbio->count; ++i) {
 		page = sbio->bio->bi_io_vec[i].bv_page;
-		buffer = kmap_atomic(page, KM_USER0);
+		buffer = kmap_atomic(page);
 		flags = sbio->spag[i].flags;
 		logical = sbio->logical + i * PAGE_SIZE;
 		ret = 0;
@@ -419,7 +419,7 @@ static void scrub_checksum(struct btrfs_work *work)
 		} else {
 			WARN_ON(1);
 		}
-		kunmap_atomic(buffer, KM_USER0);
+		kunmap_atomic(buffer);
 		if (ret)
 			scrub_recheck_error(sbio, i);
 	}
diff --git a/fs/btrfs/zlib.c b/fs/btrfs/zlib.c
index faccd47..92c2065 100644
--- a/fs/btrfs/zlib.c
+++ b/fs/btrfs/zlib.c
@@ -370,9 +370,9 @@ static int zlib_decompress(struct list_head *ws, unsigned char *data_in,
 			    PAGE_CACHE_SIZE - buf_offset);
 		bytes = min(bytes, bytes_left);
 
-		kaddr = kmap_atomic(dest_page, KM_USER0);
+		kaddr = kmap_atomic(dest_page);
 		memcpy(kaddr + pg_offset, workspace->buf + buf_offset, bytes);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 
 		pg_offset += bytes;
 		bytes_left -= bytes;
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 9f41a10..f6d8da0 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1981,7 +1981,7 @@ static void cifs_copy_cache_pages(struct address_space *mapping,
 		}
 		page_cache_release(page);
 
-		target = kmap_atomic(page, KM_USER0);
+		target = kmap_atomic(page);
 
 		if (PAGE_CACHE_SIZE > bytes_read) {
 			memcpy(target, data, bytes_read);
@@ -1993,7 +1993,7 @@ static void cifs_copy_cache_pages(struct address_space *mapping,
 			memcpy(target, data, PAGE_CACHE_SIZE);
 			bytes_read -= PAGE_CACHE_SIZE;
 		}
-		kunmap_atomic(target, KM_USER0);
+		kunmap_atomic(target);
 
 		flush_dcache_page(page);
 		SetPageUptodate(page);
diff --git a/fs/ecryptfs/mmap.c b/fs/ecryptfs/mmap.c
index 6a44148..5e29bf4 100644
--- a/fs/ecryptfs/mmap.c
+++ b/fs/ecryptfs/mmap.c
@@ -146,7 +146,7 @@ ecryptfs_copy_up_encrypted_with_header(struct page *page,
 			/* This is a header extent */
 			char *page_virt;
 
-			page_virt = kmap_atomic(page, KM_USER0);
+			page_virt = kmap_atomic(page);
 			memset(page_virt, 0, PAGE_CACHE_SIZE);
 			/* TODO: Support more than one header extent */
 			if (view_extent_num == 0) {
@@ -159,7 +159,7 @@ ecryptfs_copy_up_encrypted_with_header(struct page *page,
 							       crypt_stat,
 							       &written);
 			}
-			kunmap_atomic(page_virt, KM_USER0);
+			kunmap_atomic(page_virt);
 			flush_dcache_page(page);
 			if (rc) {
 				printk(KERN_ERR "%s: Error reading xattr "
diff --git a/fs/ecryptfs/read_write.c b/fs/ecryptfs/read_write.c
index 3745f7c..102719c8 100644
--- a/fs/ecryptfs/read_write.c
+++ b/fs/ecryptfs/read_write.c
@@ -151,7 +151,7 @@ int ecryptfs_write(struct inode *ecryptfs_inode, char *data, loff_t offset,
 			       ecryptfs_page_idx, rc);
 			goto out;
 		}
-		ecryptfs_page_virt = kmap_atomic(ecryptfs_page, KM_USER0);
+		ecryptfs_page_virt = kmap_atomic(ecryptfs_page);
 
 		/*
 		 * pos: where we're now writing, offset: where the request was
@@ -174,7 +174,7 @@ int ecryptfs_write(struct inode *ecryptfs_inode, char *data, loff_t offset,
 			       (data + data_offset), num_bytes);
 			data_offset += num_bytes;
 		}
-		kunmap_atomic(ecryptfs_page_virt, KM_USER0);
+		kunmap_atomic(ecryptfs_page_virt);
 		flush_dcache_page(ecryptfs_page);
 		SetPageUptodate(ecryptfs_page);
 		unlock_page(ecryptfs_page);
@@ -330,11 +330,11 @@ int ecryptfs_read(char *data, loff_t offset, size_t size,
 			       ecryptfs_page_idx, rc);
 			goto out;
 		}
-		ecryptfs_page_virt = kmap_atomic(ecryptfs_page, KM_USER0);
+		ecryptfs_page_virt = kmap_atomic(ecryptfs_page);
 		memcpy((data + data_offset),
 		       ((char *)ecryptfs_page_virt + start_offset_in_page),
 		       num_bytes);
-		kunmap_atomic(ecryptfs_page_virt, KM_USER0);
+		kunmap_atomic(ecryptfs_page_virt);
 		flush_dcache_page(ecryptfs_page);
 		SetPageUptodate(ecryptfs_page);
 		unlock_page(ecryptfs_page);
diff --git a/fs/exec.c b/fs/exec.c
index 25dcbe5..0bdb144 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1338,13 +1338,13 @@ int remove_arg_zero(struct linux_binprm *bprm)
 			ret = -EFAULT;
 			goto out;
 		}
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 
 		for (; offset < PAGE_SIZE && kaddr[offset];
 				offset++, bprm->p++)
 			;
 
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		put_arg_page(page);
 
 		if (offset == PAGE_SIZE)
diff --git a/fs/exofs/dir.c b/fs/exofs/dir.c
index d0941c6..b757a6e 100644
--- a/fs/exofs/dir.c
+++ b/fs/exofs/dir.c
@@ -597,7 +597,7 @@ int exofs_make_empty(struct inode *inode, struct inode *parent)
 		goto fail;
 	}
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	de = (struct exofs_dir_entry *)kaddr;
 	de->name_len = 1;
 	de->rec_len = cpu_to_le16(EXOFS_DIR_REC_LEN(1));
@@ -611,7 +611,7 @@ int exofs_make_empty(struct inode *inode, struct inode *parent)
 	de->inode_no = cpu_to_le64(parent->i_ino);
 	memcpy(de->name, PARENT_DIR, sizeof(PARENT_DIR));
 	exofs_set_de_type(de, inode);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	err = exofs_commit_chunk(page, 0, chunk_size);
 fail:
 	page_cache_release(page);
diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
index 47cda41..378bf28 100644
--- a/fs/ext2/dir.c
+++ b/fs/ext2/dir.c
@@ -645,7 +645,7 @@ int ext2_make_empty(struct inode *inode, struct inode *parent)
 		unlock_page(page);
 		goto fail;
 	}
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memset(kaddr, 0, chunk_size);
 	de = (struct ext2_dir_entry_2 *)kaddr;
 	de->name_len = 1;
@@ -660,7 +660,7 @@ int ext2_make_empty(struct inode *inode, struct inode *parent)
 	de->inode = cpu_to_le32(parent->i_ino);
 	memcpy (de->name, "..\0", 4);
 	ext2_set_de_type (de, inode);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	err = ext2_commit_chunk(page, 0, chunk_size);
 fail:
 	page_cache_release(page);
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index 640fc22..09c289c 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -834,10 +834,10 @@ static int fuse_copy_page(struct fuse_copy_state *cs, struct page **pagep,
 			}
 		}
 		if (page) {
-			void *mapaddr = kmap_atomic(page, KM_USER0);
+			void *mapaddr = kmap_atomic(page);
 			void *buf = mapaddr + offset;
 			offset += fuse_copy_do(cs, &buf, &count);
-			kunmap_atomic(mapaddr, KM_USER0);
+			kunmap_atomic(mapaddr);
 		} else
 			offset += fuse_copy_do(cs, NULL, &count);
 	}
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index d480d9a..b9510e6 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1971,11 +1971,11 @@ long fuse_do_ioctl(struct file *file, unsigned int cmd, unsigned long arg,
 		    in_iovs + out_iovs > FUSE_IOCTL_MAX_IOV)
 			goto out;
 
-		vaddr = kmap_atomic(pages[0], KM_USER0);
+		vaddr = kmap_atomic(pages[0]);
 		err = fuse_copy_ioctl_iovec(fc, iov_page, vaddr,
 					    transferred, in_iovs + out_iovs,
 					    (flags & FUSE_IOCTL_COMPAT) != 0);
-		kunmap_atomic(vaddr, KM_USER0);
+		kunmap_atomic(vaddr);
 		if (err)
 			goto out;
 
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index f9fbbe9..5775de4 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -434,12 +434,12 @@ static int stuffed_readpage(struct gfs2_inode *ip, struct page *page)
 	if (error)
 		return error;
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	if (dsize > (dibh->b_size - sizeof(struct gfs2_dinode)))
 		dsize = (dibh->b_size - sizeof(struct gfs2_dinode));
 	memcpy(kaddr, dibh->b_data + sizeof(struct gfs2_dinode), dsize);
 	memset(kaddr + dsize, 0, PAGE_CACHE_SIZE - dsize);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	flush_dcache_page(page);
 	brelse(dibh);
 	SetPageUptodate(page);
@@ -542,9 +542,9 @@ int gfs2_internal_read(struct gfs2_inode *ip, struct file_ra_state *ra_state,
 		page = read_cache_page(mapping, index, __gfs2_readpage, NULL);
 		if (IS_ERR(page))
 			return PTR_ERR(page);
-		p = kmap_atomic(page, KM_USER0);
+		p = kmap_atomic(page);
 		memcpy(buf + copied, p + offset, amt);
-		kunmap_atomic(p, KM_USER0);
+		kunmap_atomic(p);
 		mark_page_accessed(page);
 		page_cache_release(page);
 		copied += amt;
@@ -790,11 +790,11 @@ static int gfs2_stuffed_write_end(struct inode *inode, struct buffer_head *dibh,
 	struct gfs2_dinode *di = (struct gfs2_dinode *)dibh->b_data;
 
 	BUG_ON((pos + len) > (dibh->b_size - sizeof(struct gfs2_dinode)));
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memcpy(buf + pos, kaddr + pos, copied);
 	memset(kaddr + pos + copied, 0, len - copied);
 	flush_dcache_page(page);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	if (!PageUptodate(page))
 		SetPageUptodate(page);
diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
index 05bbb12..fa4afb1 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -563,11 +563,11 @@ static void gfs2_check_magic(struct buffer_head *bh)
 	__be32 *ptr;
 
 	clear_buffer_escaped(bh);
-	kaddr = kmap_atomic(bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(bh->b_page);
 	ptr = kaddr + bh_offset(bh);
 	if (*ptr == cpu_to_be32(GFS2_MAGIC))
 		set_buffer_escaped(bh);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 static void gfs2_write_blocks(struct gfs2_sbd *sdp, struct buffer_head *bh,
@@ -604,10 +604,10 @@ static void gfs2_write_blocks(struct gfs2_sbd *sdp, struct buffer_head *bh,
 		if (buffer_escaped(bd->bd_bh)) {
 			void *kaddr;
 			bh1 = gfs2_log_get_buf(sdp);
-			kaddr = kmap_atomic(bd->bd_bh->b_page, KM_USER0);
+			kaddr = kmap_atomic(bd->bd_bh->b_page);
 			memcpy(bh1->b_data, kaddr + bh_offset(bd->bd_bh),
 			       bh1->b_size);
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 			*(__be32 *)bh1->b_data = 0;
 			clear_buffer_escaped(bd->bd_bh);
 			unlock_buffer(bd->bd_bh);
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 42e8d23..70a6a89 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -717,12 +717,12 @@ get_a_page:
 
 	gfs2_trans_add_bh(ip->i_gl, bh, 0);
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	if (offset + sizeof(struct gfs2_quota) > PAGE_CACHE_SIZE)
 		nbytes = PAGE_CACHE_SIZE - offset;
 	memcpy(kaddr + offset, ptr, nbytes);
 	flush_dcache_page(page);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	unlock_page(page);
 	page_cache_release(page);
 
diff --git a/fs/jbd/journal.c b/fs/jbd/journal.c
index 9fe061f..5c981cb 100644
--- a/fs/jbd/journal.c
+++ b/fs/jbd/journal.c
@@ -328,7 +328,7 @@ repeat:
 		new_offset = offset_in_page(jh2bh(jh_in)->b_data);
 	}
 
-	mapped_data = kmap_atomic(new_page, KM_USER0);
+	mapped_data = kmap_atomic(new_page);
 	/*
 	 * Check for escaping
 	 */
@@ -337,7 +337,7 @@ repeat:
 		need_copy_out = 1;
 		do_escape = 1;
 	}
-	kunmap_atomic(mapped_data, KM_USER0);
+	kunmap_atomic(mapped_data);
 
 	/*
 	 * Do we need to do a data copy?
@@ -354,9 +354,9 @@ repeat:
 		}
 
 		jh_in->b_frozen_data = tmp;
-		mapped_data = kmap_atomic(new_page, KM_USER0);
+		mapped_data = kmap_atomic(new_page);
 		memcpy(tmp, mapped_data + new_offset, jh2bh(jh_in)->b_size);
-		kunmap_atomic(mapped_data, KM_USER0);
+		kunmap_atomic(mapped_data);
 
 		new_page = virt_to_page(tmp);
 		new_offset = offset_in_page(tmp);
@@ -368,9 +368,9 @@ repeat:
 	 * copying, we can finally do so.
 	 */
 	if (do_escape) {
-		mapped_data = kmap_atomic(new_page, KM_USER0);
+		mapped_data = kmap_atomic(new_page);
 		*((unsigned int *)(mapped_data + new_offset)) = 0;
-		kunmap_atomic(mapped_data, KM_USER0);
+		kunmap_atomic(mapped_data);
 	}
 
 	set_bh_page(new_bh, new_page, new_offset);
diff --git a/fs/jbd/transaction.c b/fs/jbd/transaction.c
index 7e59c6e..e59a112 100644
--- a/fs/jbd/transaction.c
+++ b/fs/jbd/transaction.c
@@ -712,9 +712,9 @@ done:
 			    "Possible IO failure.\n");
 		page = jh2bh(jh)->b_page;
 		offset = offset_in_page(jh2bh(jh)->b_data);
-		source = kmap_atomic(page, KM_USER0);
+		source = kmap_atomic(page);
 		memcpy(jh->b_frozen_data, source+offset, jh2bh(jh)->b_size);
-		kunmap_atomic(source, KM_USER0);
+		kunmap_atomic(source);
 	}
 	jbd_unlock_bh_state(bh);
 
diff --git a/fs/jbd2/commit.c b/fs/jbd2/commit.c
index eef6979..d2cd338 100644
--- a/fs/jbd2/commit.c
+++ b/fs/jbd2/commit.c
@@ -286,10 +286,10 @@ static __u32 jbd2_checksum_data(__u32 crc32_sum, struct buffer_head *bh)
 	char *addr;
 	__u32 checksum;
 
-	addr = kmap_atomic(page, KM_USER0);
+	addr = kmap_atomic(page);
 	checksum = crc32_be(crc32_sum,
 		(void *)(addr + offset_in_page(bh->b_data)), bh->b_size);
-	kunmap_atomic(addr, KM_USER0);
+	kunmap_atomic(addr);
 
 	return checksum;
 }
diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
index f24df13..74a45b3 100644
--- a/fs/jbd2/journal.c
+++ b/fs/jbd2/journal.c
@@ -345,7 +345,7 @@ repeat:
 		new_offset = offset_in_page(jh2bh(jh_in)->b_data);
 	}
 
-	mapped_data = kmap_atomic(new_page, KM_USER0);
+	mapped_data = kmap_atomic(new_page);
 	/*
 	 * Fire data frozen trigger if data already wasn't frozen.  Do this
 	 * before checking for escaping, as the trigger may modify the magic
@@ -364,7 +364,7 @@ repeat:
 		need_copy_out = 1;
 		do_escape = 1;
 	}
-	kunmap_atomic(mapped_data, KM_USER0);
+	kunmap_atomic(mapped_data);
 
 	/*
 	 * Do we need to do a data copy?
@@ -385,9 +385,9 @@ repeat:
 		}
 
 		jh_in->b_frozen_data = tmp;
-		mapped_data = kmap_atomic(new_page, KM_USER0);
+		mapped_data = kmap_atomic(new_page);
 		memcpy(tmp, mapped_data + new_offset, jh2bh(jh_in)->b_size);
-		kunmap_atomic(mapped_data, KM_USER0);
+		kunmap_atomic(mapped_data);
 
 		new_page = virt_to_page(tmp);
 		new_offset = offset_in_page(tmp);
@@ -406,9 +406,9 @@ repeat:
 	 * copying, we can finally do so.
 	 */
 	if (do_escape) {
-		mapped_data = kmap_atomic(new_page, KM_USER0);
+		mapped_data = kmap_atomic(new_page);
 		*((unsigned int *)(mapped_data + new_offset)) = 0;
-		kunmap_atomic(mapped_data, KM_USER0);
+		kunmap_atomic(mapped_data);
 	}
 
 	set_bh_page(new_bh, new_page, new_offset);
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index 2d71094..eda00d4 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -781,12 +781,12 @@ done:
 			    "Possible IO failure.\n");
 		page = jh2bh(jh)->b_page;
 		offset = offset_in_page(jh2bh(jh)->b_data);
-		source = kmap_atomic(page, KM_USER0);
+		source = kmap_atomic(page);
 		/* Fire data frozen trigger just before we copy the data */
 		jbd2_buffer_frozen_trigger(jh, source + offset,
 					   jh->b_triggers);
 		memcpy(jh->b_frozen_data, source+offset, jh2bh(jh)->b_size);
-		kunmap_atomic(source, KM_USER0);
+		kunmap_atomic(source);
 
 		/*
 		 * Now that the frozen data is saved off, we need to store
diff --git a/fs/logfs/dir.c b/fs/logfs/dir.c
index b3ff3d8..3d48969 100644
--- a/fs/logfs/dir.c
+++ b/fs/logfs/dir.c
@@ -177,17 +177,17 @@ static struct page *logfs_get_dd_page(struct inode *dir, struct dentry *dentry)
 				(filler_t *)logfs_readpage, NULL);
 		if (IS_ERR(page))
 			return page;
-		dd = kmap_atomic(page, KM_USER0);
+		dd = kmap_atomic(page);
 		BUG_ON(dd->namelen == 0);
 
 		if (name->len != be16_to_cpu(dd->namelen) ||
 				memcmp(name->name, dd->name, name->len)) {
-			kunmap_atomic(dd, KM_USER0);
+			kunmap_atomic(dd);
 			page_cache_release(page);
 			continue;
 		}
 
-		kunmap_atomic(dd, KM_USER0);
+		kunmap_atomic(dd);
 		return page;
 	}
 	return NULL;
@@ -365,9 +365,9 @@ static struct dentry *logfs_lookup(struct inode *dir, struct dentry *dentry,
 		return NULL;
 	}
 	index = page->index;
-	dd = kmap_atomic(page, KM_USER0);
+	dd = kmap_atomic(page);
 	ino = be64_to_cpu(dd->ino);
-	kunmap_atomic(dd, KM_USER0);
+	kunmap_atomic(dd);
 	page_cache_release(page);
 
 	inode = logfs_iget(dir->i_sb, ino);
@@ -402,12 +402,12 @@ static int logfs_write_dir(struct inode *dir, struct dentry *dentry,
 		if (!page)
 			return -ENOMEM;
 
-		dd = kmap_atomic(page, KM_USER0);
+		dd = kmap_atomic(page);
 		memset(dd, 0, sizeof(*dd));
 		dd->ino = cpu_to_be64(inode->i_ino);
 		dd->type = logfs_type(inode);
 		logfs_set_name(dd, &dentry->d_name);
-		kunmap_atomic(dd, KM_USER0);
+		kunmap_atomic(dd);
 
 		err = logfs_write_buf(dir, page, WF_LOCK);
 		unlock_page(page);
@@ -579,9 +579,9 @@ static int logfs_get_dd(struct inode *dir, struct dentry *dentry,
 	if (IS_ERR(page))
 		return PTR_ERR(page);
 	*pos = page->index;
-	map = kmap_atomic(page, KM_USER0);
+	map = kmap_atomic(page);
 	memcpy(dd, map, sizeof(*dd));
-	kunmap_atomic(map, KM_USER0);
+	kunmap_atomic(map);
 	page_cache_release(page);
 	return 0;
 }
diff --git a/fs/logfs/readwrite.c b/fs/logfs/readwrite.c
index d8d0938..e4155fa 100644
--- a/fs/logfs/readwrite.c
+++ b/fs/logfs/readwrite.c
@@ -519,9 +519,9 @@ static int indirect_write_alias(struct super_block *sb,
 
 		ino = page->mapping->host->i_ino;
 		logfs_unpack_index(page->index, &bix, &level);
-		child = kmap_atomic(page, KM_USER0);
+		child = kmap_atomic(page);
 		val = child[pos];
-		kunmap_atomic(child, KM_USER0);
+		kunmap_atomic(child);
 		err = write_one_alias(sb, ino, bix, level, pos, val);
 		if (err)
 			return err;
@@ -667,9 +667,9 @@ static void alloc_indirect_block(struct inode *inode, struct page *page,
 	alloc_data_block(inode, page);
 
 	block = logfs_block(page);
-	array = kmap_atomic(page, KM_USER0);
+	array = kmap_atomic(page);
 	initialize_block_counters(page, block, array, page_is_empty);
-	kunmap_atomic(array, KM_USER0);
+	kunmap_atomic(array);
 }
 
 static void block_set_pointer(struct page *page, int index, u64 ptr)
@@ -679,10 +679,10 @@ static void block_set_pointer(struct page *page, int index, u64 ptr)
 	u64 oldptr;
 
 	BUG_ON(!block);
-	array = kmap_atomic(page, KM_USER0);
+	array = kmap_atomic(page);
 	oldptr = be64_to_cpu(array[index]);
 	array[index] = cpu_to_be64(ptr);
-	kunmap_atomic(array, KM_USER0);
+	kunmap_atomic(array);
 	SetPageUptodate(page);
 
 	block->full += !!(ptr & LOGFS_FULLY_POPULATED)
@@ -695,9 +695,9 @@ static u64 block_get_pointer(struct page *page, int index)
 	__be64 *block;
 	u64 ptr;
 
-	block = kmap_atomic(page, KM_USER0);
+	block = kmap_atomic(page);
 	ptr = be64_to_cpu(block[index]);
-	kunmap_atomic(block, KM_USER0);
+	kunmap_atomic(block);
 	return ptr;
 }
 
@@ -844,7 +844,7 @@ static u64 seek_holedata_loop(struct inode *inode, u64 bix, int data)
 		}
 
 		slot = get_bits(bix, SUBLEVEL(level));
-		rblock = kmap_atomic(page, KM_USER0);
+		rblock = kmap_atomic(page);
 		while (slot < LOGFS_BLOCK_FACTOR) {
 			if (data && (rblock[slot] != 0))
 				break;
@@ -855,12 +855,12 @@ static u64 seek_holedata_loop(struct inode *inode, u64 bix, int data)
 			bix &= ~(increment - 1);
 		}
 		if (slot >= LOGFS_BLOCK_FACTOR) {
-			kunmap_atomic(rblock, KM_USER0);
+			kunmap_atomic(rblock);
 			logfs_put_read_page(page);
 			return bix;
 		}
 		bofs = be64_to_cpu(rblock[slot]);
-		kunmap_atomic(rblock, KM_USER0);
+		kunmap_atomic(rblock);
 		logfs_put_read_page(page);
 		if (!bofs) {
 			BUG_ON(data);
@@ -1944,9 +1944,9 @@ int logfs_read_inode(struct inode *inode)
 	if (IS_ERR(page))
 		return PTR_ERR(page);
 
-	di = kmap_atomic(page, KM_USER0);
+	di = kmap_atomic(page);
 	logfs_disk_to_inode(di, inode);
-	kunmap_atomic(di, KM_USER0);
+	kunmap_atomic(di);
 	move_page_to_inode(inode, page);
 	page_cache_release(page);
 	return 0;
@@ -1965,9 +1965,9 @@ static struct page *inode_to_page(struct inode *inode)
 	if (!page)
 		return NULL;
 
-	di = kmap_atomic(page, KM_USER0);
+	di = kmap_atomic(page);
 	logfs_inode_to_disk(inode, di);
-	kunmap_atomic(di, KM_USER0);
+	kunmap_atomic(di);
 	move_inode_to_page(page, inode);
 	return page;
 }
@@ -2024,13 +2024,13 @@ static void logfs_mod_segment_entry(struct super_block *sb, u32 segno,
 
 	if (write)
 		alloc_indirect_block(inode, page, 0);
-	se = kmap_atomic(page, KM_USER0);
+	se = kmap_atomic(page);
 	change_se(se + child_no, arg);
 	if (write) {
 		logfs_set_alias(sb, logfs_block(page), child_no);
 		BUG_ON((int)be32_to_cpu(se[child_no].valid) > super->s_segsize);
 	}
-	kunmap_atomic(se, KM_USER0);
+	kunmap_atomic(se);
 
 	logfs_put_write_page(page);
 }
@@ -2228,10 +2228,10 @@ int logfs_inode_write(struct inode *inode, const void *buf, size_t count,
 	if (!page)
 		return -ENOMEM;
 
-	pagebuf = kmap_atomic(page, KM_USER0);
+	pagebuf = kmap_atomic(page);
 	memcpy(pagebuf, buf, count);
 	flush_dcache_page(page);
-	kunmap_atomic(pagebuf, KM_USER0);
+	kunmap_atomic(pagebuf);
 
 	if (i_size_read(inode) < pos + LOGFS_BLOCKSIZE)
 		i_size_write(inode, pos + LOGFS_BLOCKSIZE);
diff --git a/fs/logfs/segment.c b/fs/logfs/segment.c
index 9d51873..e4bc46c 100644
--- a/fs/logfs/segment.c
+++ b/fs/logfs/segment.c
@@ -529,9 +529,9 @@ void move_page_to_btree(struct page *page)
 		BUG_ON(!item); /* mempool empty */
 		memset(item, 0, sizeof(*item));
 
-		child = kmap_atomic(page, KM_USER0);
+		child = kmap_atomic(page);
 		item->val = child[pos];
-		kunmap_atomic(child, KM_USER0);
+		kunmap_atomic(child);
 		item->child_no = pos;
 		list_add(&item->list, &block->item_list);
 	}
diff --git a/fs/minix/dir.c b/fs/minix/dir.c
index 085a926..685b2d9 100644
--- a/fs/minix/dir.c
+++ b/fs/minix/dir.c
@@ -335,7 +335,7 @@ int minix_make_empty(struct inode *inode, struct inode *dir)
 		goto fail;
 	}
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memset(kaddr, 0, PAGE_CACHE_SIZE);
 
 	if (sbi->s_version == MINIX_V3) {
@@ -355,7 +355,7 @@ int minix_make_empty(struct inode *inode, struct inode *dir)
 		de->inode = dir->i_ino;
 		strcpy(de->name, "..");
 	}
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	err = dir_commit_chunk(page, 0, 2 * sbi->s_dirsize);
 fail:
diff --git a/fs/namei.c b/fs/namei.c
index 2826db3..8ac3635 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3332,9 +3332,9 @@ retry:
 	if (err)
 		goto fail;
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memcpy(kaddr, symname, len-1);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	err = pagecache_write_end(NULL, mapping, 0, len-1, len-1,
 							page, fsdata);
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index b238d95..a11600d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -260,10 +260,10 @@ void nfs_readdir_clear_array(struct page *page)
 	struct nfs_cache_array *array;
 	int i;
 
-	array = kmap_atomic(page, KM_USER0);
+	array = kmap_atomic(page);
 	for (i = 0; i < array->size; i++)
 		kfree(array->array[i].string.name);
-	kunmap_atomic(array, KM_USER0);
+	kunmap_atomic(array);
 }
 
 /*
@@ -1881,11 +1881,11 @@ static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *sym
 	if (!page)
 		return -ENOMEM;
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memcpy(kaddr, symname, pathlen);
 	if (pathlen < PAGE_SIZE)
 		memset(kaddr + pathlen, 0, PAGE_SIZE - pathlen);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	error = NFS_PROTO(dir)->symlink(dir, dentry, page, pathlen, &attr);
 	if (error != 0) {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8c77039..b4f3866 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -192,7 +192,7 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 	 * when talking to the server, we always send cookie 0
 	 * instead of 1 or 2.
 	 */
-	start = p = kmap_atomic(*readdir->pages, KM_USER0);
+	start = p = kmap_atomic(*readdir->pages);
 	
 	if (cookie == 0) {
 		*p++ = xdr_one;                                  /* next */
@@ -220,7 +220,7 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 
 	readdir->pgbase = (char *)p - (char *)start;
 	readdir->count -= readdir->pgbase;
-	kunmap_atomic(start, KM_USER0);
+	kunmap_atomic(start);
 }
 
 static int nfs4_wait_clnt_recover(struct nfs_client *clp)
diff --git a/fs/nilfs2/cpfile.c b/fs/nilfs2/cpfile.c
index c9b342c..dab5c4c 100644
--- a/fs/nilfs2/cpfile.c
+++ b/fs/nilfs2/cpfile.c
@@ -218,11 +218,11 @@ int nilfs_cpfile_get_checkpoint(struct inode *cpfile,
 								 kaddr, 1);
 		mark_buffer_dirty(cp_bh);
 
-		kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(header_bh->b_page);
 		header = nilfs_cpfile_block_get_header(cpfile, header_bh,
 						       kaddr);
 		le64_add_cpu(&header->ch_ncheckpoints, 1);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		mark_buffer_dirty(header_bh);
 		nilfs_mdt_mark_dirty(cpfile);
 	}
@@ -313,7 +313,7 @@ int nilfs_cpfile_delete_checkpoints(struct inode *cpfile,
 			continue;
 		}
 
-		kaddr = kmap_atomic(cp_bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(cp_bh->b_page);
 		cp = nilfs_cpfile_block_get_checkpoint(
 			cpfile, cno, cp_bh, kaddr);
 		nicps = 0;
@@ -334,7 +334,7 @@ int nilfs_cpfile_delete_checkpoints(struct inode *cpfile,
 						cpfile, cp_bh, kaddr, nicps);
 				if (count == 0) {
 					/* make hole */
-					kunmap_atomic(kaddr, KM_USER0);
+					kunmap_atomic(kaddr);
 					brelse(cp_bh);
 					ret =
 					  nilfs_cpfile_delete_checkpoint_block(
@@ -349,18 +349,18 @@ int nilfs_cpfile_delete_checkpoints(struct inode *cpfile,
 			}
 		}
 
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		brelse(cp_bh);
 	}
 
 	if (tnicps > 0) {
-		kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(header_bh->b_page);
 		header = nilfs_cpfile_block_get_header(cpfile, header_bh,
 						       kaddr);
 		le64_add_cpu(&header->ch_ncheckpoints, -(u64)tnicps);
 		mark_buffer_dirty(header_bh);
 		nilfs_mdt_mark_dirty(cpfile);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 
 	brelse(header_bh);
@@ -408,7 +408,7 @@ static ssize_t nilfs_cpfile_do_get_cpinfo(struct inode *cpfile, __u64 *cnop,
 			continue; /* skip hole */
 		}
 
-		kaddr = kmap_atomic(bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(bh->b_page);
 		cp = nilfs_cpfile_block_get_checkpoint(cpfile, cno, bh, kaddr);
 		for (i = 0; i < ncps && n < nci; i++, cp = (void *)cp + cpsz) {
 			if (!nilfs_checkpoint_invalid(cp)) {
@@ -418,7 +418,7 @@ static ssize_t nilfs_cpfile_do_get_cpinfo(struct inode *cpfile, __u64 *cnop,
 				n++;
 			}
 		}
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		brelse(bh);
 	}
 
@@ -451,10 +451,10 @@ static ssize_t nilfs_cpfile_do_get_ssinfo(struct inode *cpfile, __u64 *cnop,
 		ret = nilfs_cpfile_get_header_block(cpfile, &bh);
 		if (ret < 0)
 			goto out;
-		kaddr = kmap_atomic(bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(bh->b_page);
 		header = nilfs_cpfile_block_get_header(cpfile, bh, kaddr);
 		curr = le64_to_cpu(header->ch_snapshot_list.ssl_next);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		brelse(bh);
 		if (curr == 0) {
 			ret = 0;
@@ -472,7 +472,7 @@ static ssize_t nilfs_cpfile_do_get_ssinfo(struct inode *cpfile, __u64 *cnop,
 			ret = 0; /* No snapshots (started from a hole block) */
 		goto out;
 	}
-	kaddr = kmap_atomic(bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(bh->b_page);
 	while (n < nci) {
 		cp = nilfs_cpfile_block_get_checkpoint(cpfile, curr, bh, kaddr);
 		curr = ~(__u64)0; /* Terminator */
@@ -488,7 +488,7 @@ static ssize_t nilfs_cpfile_do_get_ssinfo(struct inode *cpfile, __u64 *cnop,
 
 		next_blkoff = nilfs_cpfile_get_blkoff(cpfile, next);
 		if (curr_blkoff != next_blkoff) {
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 			brelse(bh);
 			ret = nilfs_cpfile_get_checkpoint_block(cpfile, next,
 								0, &bh);
@@ -496,12 +496,12 @@ static ssize_t nilfs_cpfile_do_get_ssinfo(struct inode *cpfile, __u64 *cnop,
 				WARN_ON(ret == -ENOENT);
 				goto out;
 			}
-			kaddr = kmap_atomic(bh->b_page, KM_USER0);
+			kaddr = kmap_atomic(bh->b_page);
 		}
 		curr = next;
 		curr_blkoff = next_blkoff;
 	}
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	brelse(bh);
 	*cnop = curr;
 	ret = n;
@@ -592,24 +592,24 @@ static int nilfs_cpfile_set_snapshot(struct inode *cpfile, __u64 cno)
 	ret = nilfs_cpfile_get_checkpoint_block(cpfile, cno, 0, &cp_bh);
 	if (ret < 0)
 		goto out_sem;
-	kaddr = kmap_atomic(cp_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(cp_bh->b_page);
 	cp = nilfs_cpfile_block_get_checkpoint(cpfile, cno, cp_bh, kaddr);
 	if (nilfs_checkpoint_invalid(cp)) {
 		ret = -ENOENT;
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		goto out_cp;
 	}
 	if (nilfs_checkpoint_snapshot(cp)) {
 		ret = 0;
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		goto out_cp;
 	}
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	ret = nilfs_cpfile_get_header_block(cpfile, &header_bh);
 	if (ret < 0)
 		goto out_cp;
-	kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(header_bh->b_page);
 	header = nilfs_cpfile_block_get_header(cpfile, header_bh, kaddr);
 	list = &header->ch_snapshot_list;
 	curr_bh = header_bh;
@@ -621,13 +621,13 @@ static int nilfs_cpfile_set_snapshot(struct inode *cpfile, __u64 cno)
 		prev_blkoff = nilfs_cpfile_get_blkoff(cpfile, prev);
 		curr = prev;
 		if (curr_blkoff != prev_blkoff) {
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 			brelse(curr_bh);
 			ret = nilfs_cpfile_get_checkpoint_block(cpfile, curr,
 								0, &curr_bh);
 			if (ret < 0)
 				goto out_header;
-			kaddr = kmap_atomic(curr_bh->b_page, KM_USER0);
+			kaddr = kmap_atomic(curr_bh->b_page);
 		}
 		curr_blkoff = prev_blkoff;
 		cp = nilfs_cpfile_block_get_checkpoint(
@@ -635,7 +635,7 @@ static int nilfs_cpfile_set_snapshot(struct inode *cpfile, __u64 cno)
 		list = &cp->cp_snapshot_list;
 		prev = le64_to_cpu(list->ssl_prev);
 	}
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	if (prev != 0) {
 		ret = nilfs_cpfile_get_checkpoint_block(cpfile, prev, 0,
@@ -647,29 +647,29 @@ static int nilfs_cpfile_set_snapshot(struct inode *cpfile, __u64 cno)
 		get_bh(prev_bh);
 	}
 
-	kaddr = kmap_atomic(curr_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(curr_bh->b_page);
 	list = nilfs_cpfile_block_get_snapshot_list(
 		cpfile, curr, curr_bh, kaddr);
 	list->ssl_prev = cpu_to_le64(cno);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
-	kaddr = kmap_atomic(cp_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(cp_bh->b_page);
 	cp = nilfs_cpfile_block_get_checkpoint(cpfile, cno, cp_bh, kaddr);
 	cp->cp_snapshot_list.ssl_next = cpu_to_le64(curr);
 	cp->cp_snapshot_list.ssl_prev = cpu_to_le64(prev);
 	nilfs_checkpoint_set_snapshot(cp);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
-	kaddr = kmap_atomic(prev_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(prev_bh->b_page);
 	list = nilfs_cpfile_block_get_snapshot_list(
 		cpfile, prev, prev_bh, kaddr);
 	list->ssl_next = cpu_to_le64(cno);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
-	kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(header_bh->b_page);
 	header = nilfs_cpfile_block_get_header(cpfile, header_bh, kaddr);
 	le64_add_cpu(&header->ch_nsnapshots, 1);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	mark_buffer_dirty(prev_bh);
 	mark_buffer_dirty(curr_bh);
@@ -710,23 +710,23 @@ static int nilfs_cpfile_clear_snapshot(struct inode *cpfile, __u64 cno)
 	ret = nilfs_cpfile_get_checkpoint_block(cpfile, cno, 0, &cp_bh);
 	if (ret < 0)
 		goto out_sem;
-	kaddr = kmap_atomic(cp_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(cp_bh->b_page);
 	cp = nilfs_cpfile_block_get_checkpoint(cpfile, cno, cp_bh, kaddr);
 	if (nilfs_checkpoint_invalid(cp)) {
 		ret = -ENOENT;
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		goto out_cp;
 	}
 	if (!nilfs_checkpoint_snapshot(cp)) {
 		ret = 0;
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		goto out_cp;
 	}
 
 	list = &cp->cp_snapshot_list;
 	next = le64_to_cpu(list->ssl_next);
 	prev = le64_to_cpu(list->ssl_prev);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	ret = nilfs_cpfile_get_header_block(cpfile, &header_bh);
 	if (ret < 0)
@@ -750,29 +750,29 @@ static int nilfs_cpfile_clear_snapshot(struct inode *cpfile, __u64 cno)
 		get_bh(prev_bh);
 	}
 
-	kaddr = kmap_atomic(next_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(next_bh->b_page);
 	list = nilfs_cpfile_block_get_snapshot_list(
 		cpfile, next, next_bh, kaddr);
 	list->ssl_prev = cpu_to_le64(prev);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
-	kaddr = kmap_atomic(prev_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(prev_bh->b_page);
 	list = nilfs_cpfile_block_get_snapshot_list(
 		cpfile, prev, prev_bh, kaddr);
 	list->ssl_next = cpu_to_le64(next);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
-	kaddr = kmap_atomic(cp_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(cp_bh->b_page);
 	cp = nilfs_cpfile_block_get_checkpoint(cpfile, cno, cp_bh, kaddr);
 	cp->cp_snapshot_list.ssl_next = cpu_to_le64(0);
 	cp->cp_snapshot_list.ssl_prev = cpu_to_le64(0);
 	nilfs_checkpoint_clear_snapshot(cp);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
-	kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(header_bh->b_page);
 	header = nilfs_cpfile_block_get_header(cpfile, header_bh, kaddr);
 	le64_add_cpu(&header->ch_nsnapshots, -1);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	mark_buffer_dirty(next_bh);
 	mark_buffer_dirty(prev_bh);
@@ -829,13 +829,13 @@ int nilfs_cpfile_is_snapshot(struct inode *cpfile, __u64 cno)
 	ret = nilfs_cpfile_get_checkpoint_block(cpfile, cno, 0, &bh);
 	if (ret < 0)
 		goto out;
-	kaddr = kmap_atomic(bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(bh->b_page);
 	cp = nilfs_cpfile_block_get_checkpoint(cpfile, cno, bh, kaddr);
 	if (nilfs_checkpoint_invalid(cp))
 		ret = -ENOENT;
 	else
 		ret = nilfs_checkpoint_snapshot(cp);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	brelse(bh);
 
  out:
@@ -912,12 +912,12 @@ int nilfs_cpfile_get_stat(struct inode *cpfile, struct nilfs_cpstat *cpstat)
 	ret = nilfs_cpfile_get_header_block(cpfile, &bh);
 	if (ret < 0)
 		goto out_sem;
-	kaddr = kmap_atomic(bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(bh->b_page);
 	header = nilfs_cpfile_block_get_header(cpfile, bh, kaddr);
 	cpstat->cs_cno = nilfs_mdt_cno(cpfile);
 	cpstat->cs_ncps = le64_to_cpu(header->ch_ncheckpoints);
 	cpstat->cs_nsss = le64_to_cpu(header->ch_nsnapshots);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	brelse(bh);
 
  out_sem:
diff --git a/fs/nilfs2/dat.c b/fs/nilfs2/dat.c
index fcc2f86..b5c13f3 100644
--- a/fs/nilfs2/dat.c
+++ b/fs/nilfs2/dat.c
@@ -85,13 +85,13 @@ void nilfs_dat_commit_alloc(struct inode *dat, struct nilfs_palloc_req *req)
 	struct nilfs_dat_entry *entry;
 	void *kaddr;
 
-	kaddr = kmap_atomic(req->pr_entry_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(req->pr_entry_bh->b_page);
 	entry = nilfs_palloc_block_get_entry(dat, req->pr_entry_nr,
 					     req->pr_entry_bh, kaddr);
 	entry->de_start = cpu_to_le64(NILFS_CNO_MIN);
 	entry->de_end = cpu_to_le64(NILFS_CNO_MAX);
 	entry->de_blocknr = cpu_to_le64(0);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	nilfs_palloc_commit_alloc_entry(dat, req);
 	nilfs_dat_commit_entry(dat, req);
@@ -109,13 +109,13 @@ static void nilfs_dat_commit_free(struct inode *dat,
 	struct nilfs_dat_entry *entry;
 	void *kaddr;
 
-	kaddr = kmap_atomic(req->pr_entry_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(req->pr_entry_bh->b_page);
 	entry = nilfs_palloc_block_get_entry(dat, req->pr_entry_nr,
 					     req->pr_entry_bh, kaddr);
 	entry->de_start = cpu_to_le64(NILFS_CNO_MIN);
 	entry->de_end = cpu_to_le64(NILFS_CNO_MIN);
 	entry->de_blocknr = cpu_to_le64(0);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	nilfs_dat_commit_entry(dat, req);
 	nilfs_palloc_commit_free_entry(dat, req);
@@ -136,12 +136,12 @@ void nilfs_dat_commit_start(struct inode *dat, struct nilfs_palloc_req *req,
 	struct nilfs_dat_entry *entry;
 	void *kaddr;
 
-	kaddr = kmap_atomic(req->pr_entry_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(req->pr_entry_bh->b_page);
 	entry = nilfs_palloc_block_get_entry(dat, req->pr_entry_nr,
 					     req->pr_entry_bh, kaddr);
 	entry->de_start = cpu_to_le64(nilfs_mdt_cno(dat));
 	entry->de_blocknr = cpu_to_le64(blocknr);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	nilfs_dat_commit_entry(dat, req);
 }
@@ -160,12 +160,12 @@ int nilfs_dat_prepare_end(struct inode *dat, struct nilfs_palloc_req *req)
 		return ret;
 	}
 
-	kaddr = kmap_atomic(req->pr_entry_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(req->pr_entry_bh->b_page);
 	entry = nilfs_palloc_block_get_entry(dat, req->pr_entry_nr,
 					     req->pr_entry_bh, kaddr);
 	start = le64_to_cpu(entry->de_start);
 	blocknr = le64_to_cpu(entry->de_blocknr);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	if (blocknr == 0) {
 		ret = nilfs_palloc_prepare_free_entry(dat, req);
@@ -186,7 +186,7 @@ void nilfs_dat_commit_end(struct inode *dat, struct nilfs_palloc_req *req,
 	sector_t blocknr;
 	void *kaddr;
 
-	kaddr = kmap_atomic(req->pr_entry_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(req->pr_entry_bh->b_page);
 	entry = nilfs_palloc_block_get_entry(dat, req->pr_entry_nr,
 					     req->pr_entry_bh, kaddr);
 	end = start = le64_to_cpu(entry->de_start);
@@ -196,7 +196,7 @@ void nilfs_dat_commit_end(struct inode *dat, struct nilfs_palloc_req *req,
 	}
 	entry->de_end = cpu_to_le64(end);
 	blocknr = le64_to_cpu(entry->de_blocknr);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	if (blocknr == 0)
 		nilfs_dat_commit_free(dat, req);
@@ -211,12 +211,12 @@ void nilfs_dat_abort_end(struct inode *dat, struct nilfs_palloc_req *req)
 	sector_t blocknr;
 	void *kaddr;
 
-	kaddr = kmap_atomic(req->pr_entry_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(req->pr_entry_bh->b_page);
 	entry = nilfs_palloc_block_get_entry(dat, req->pr_entry_nr,
 					     req->pr_entry_bh, kaddr);
 	start = le64_to_cpu(entry->de_start);
 	blocknr = le64_to_cpu(entry->de_blocknr);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	if (start == nilfs_mdt_cno(dat) && blocknr == 0)
 		nilfs_palloc_abort_free_entry(dat, req);
@@ -346,20 +346,20 @@ int nilfs_dat_move(struct inode *dat, __u64 vblocknr, sector_t blocknr)
 		}
 	}
 
-	kaddr = kmap_atomic(entry_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(entry_bh->b_page);
 	entry = nilfs_palloc_block_get_entry(dat, vblocknr, entry_bh, kaddr);
 	if (unlikely(entry->de_blocknr == cpu_to_le64(0))) {
 		printk(KERN_CRIT "%s: vbn = %llu, [%llu, %llu)\n", __func__,
 		       (unsigned long long)vblocknr,
 		       (unsigned long long)le64_to_cpu(entry->de_start),
 		       (unsigned long long)le64_to_cpu(entry->de_end));
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		brelse(entry_bh);
 		return -EINVAL;
 	}
 	WARN_ON(blocknr == 0);
 	entry->de_blocknr = cpu_to_le64(blocknr);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	mark_buffer_dirty(entry_bh);
 	nilfs_mdt_mark_dirty(dat);
@@ -409,7 +409,7 @@ int nilfs_dat_translate(struct inode *dat, __u64 vblocknr, sector_t *blocknrp)
 		}
 	}
 
-	kaddr = kmap_atomic(entry_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(entry_bh->b_page);
 	entry = nilfs_palloc_block_get_entry(dat, vblocknr, entry_bh, kaddr);
 	blocknr = le64_to_cpu(entry->de_blocknr);
 	if (blocknr == 0) {
@@ -419,7 +419,7 @@ int nilfs_dat_translate(struct inode *dat, __u64 vblocknr, sector_t *blocknrp)
 	*blocknrp = blocknr;
 
  out:
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	brelse(entry_bh);
 	return ret;
 }
@@ -440,7 +440,7 @@ ssize_t nilfs_dat_get_vinfo(struct inode *dat, void *buf, unsigned visz,
 						   0, &entry_bh);
 		if (ret < 0)
 			return ret;
-		kaddr = kmap_atomic(entry_bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(entry_bh->b_page);
 		/* last virtual block number in this block */
 		first = vinfo->vi_vblocknr;
 		do_div(first, entries_per_block);
@@ -456,7 +456,7 @@ ssize_t nilfs_dat_get_vinfo(struct inode *dat, void *buf, unsigned visz,
 			vinfo->vi_end = le64_to_cpu(entry->de_end);
 			vinfo->vi_blocknr = le64_to_cpu(entry->de_blocknr);
 		}
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		brelse(entry_bh);
 	}
 
diff --git a/fs/nilfs2/dir.c b/fs/nilfs2/dir.c
index 3a19239..53ed93a 100644
--- a/fs/nilfs2/dir.c
+++ b/fs/nilfs2/dir.c
@@ -602,7 +602,7 @@ int nilfs_make_empty(struct inode *inode, struct inode *parent)
 		unlock_page(page);
 		goto fail;
 	}
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memset(kaddr, 0, chunk_size);
 	de = (struct nilfs_dir_entry *)kaddr;
 	de->name_len = 1;
@@ -617,7 +617,7 @@ int nilfs_make_empty(struct inode *inode, struct inode *parent)
 	de->inode = cpu_to_le64(parent->i_ino);
 	memcpy(de->name, "..\0", 4);
 	nilfs_set_de_type(de, inode);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	nilfs_commit_chunk(page, mapping, 0, chunk_size);
 fail:
 	page_cache_release(page);
diff --git a/fs/nilfs2/ifile.c b/fs/nilfs2/ifile.c
index 684d763..5a48df7 100644
--- a/fs/nilfs2/ifile.c
+++ b/fs/nilfs2/ifile.c
@@ -122,11 +122,11 @@ int nilfs_ifile_delete_inode(struct inode *ifile, ino_t ino)
 		return ret;
 	}
 
-	kaddr = kmap_atomic(req.pr_entry_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(req.pr_entry_bh->b_page);
 	raw_inode = nilfs_palloc_block_get_entry(ifile, req.pr_entry_nr,
 						 req.pr_entry_bh, kaddr);
 	raw_inode->i_flags = 0;
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	mark_buffer_dirty(req.pr_entry_bh);
 	brelse(req.pr_entry_bh);
diff --git a/fs/nilfs2/mdt.c b/fs/nilfs2/mdt.c
index 800e8d7..f9897d0 100644
--- a/fs/nilfs2/mdt.c
+++ b/fs/nilfs2/mdt.c
@@ -58,12 +58,12 @@ nilfs_mdt_insert_new_block(struct inode *inode, unsigned long block,
 
 	set_buffer_mapped(bh);
 
-	kaddr = kmap_atomic(bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(bh->b_page);
 	memset(kaddr + bh_offset(bh), 0, 1 << inode->i_blkbits);
 	if (init_block)
 		init_block(inode, bh, kaddr);
 	flush_dcache_page(bh->b_page);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	set_buffer_uptodate(bh);
 	mark_buffer_dirty(bh);
diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
index 65221a0..3e7b2a0 100644
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -119,11 +119,11 @@ void nilfs_copy_buffer(struct buffer_head *dbh, struct buffer_head *sbh)
 	struct page *spage = sbh->b_page, *dpage = dbh->b_page;
 	struct buffer_head *bh;
 
-	kaddr0 = kmap_atomic(spage, KM_USER0);
-	kaddr1 = kmap_atomic(dpage, KM_USER1);
+	kaddr0 = kmap_atomic(spage);
+	kaddr1 = kmap_atomic(dpage);
 	memcpy(kaddr1 + bh_offset(dbh), kaddr0 + bh_offset(sbh), sbh->b_size);
-	kunmap_atomic(kaddr1, KM_USER1);
-	kunmap_atomic(kaddr0, KM_USER0);
+	kunmap_atomic(kaddr1);
+	kunmap_atomic(kaddr0);
 
 	dbh->b_state = sbh->b_state & NILFS_BUFFER_INHERENT_BITS;
 	dbh->b_blocknr = sbh->b_blocknr;
diff --git a/fs/nilfs2/recovery.c b/fs/nilfs2/recovery.c
index a604ac0..f1626f5 100644
--- a/fs/nilfs2/recovery.c
+++ b/fs/nilfs2/recovery.c
@@ -493,9 +493,9 @@ static int nilfs_recovery_copy_block(struct the_nilfs *nilfs,
 	if (unlikely(!bh_org))
 		return -EIO;
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memcpy(kaddr + bh_offset(bh_org), bh_org->b_data, bh_org->b_size);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	brelse(bh_org);
 	return 0;
 }
diff --git a/fs/nilfs2/segbuf.c b/fs/nilfs2/segbuf.c
index 850a7c0..dc9a913 100644
--- a/fs/nilfs2/segbuf.c
+++ b/fs/nilfs2/segbuf.c
@@ -227,9 +227,9 @@ static void nilfs_segbuf_fill_in_data_crc(struct nilfs_segment_buffer *segbuf,
 		crc = crc32_le(crc, bh->b_data, bh->b_size);
 	}
 	list_for_each_entry(bh, &segbuf->sb_payload_buffers, b_assoc_buffers) {
-		kaddr = kmap_atomic(bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(bh->b_page);
 		crc = crc32_le(crc, kaddr + bh_offset(bh), bh->b_size);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 	raw_sum->ss_datasum = cpu_to_le32(crc);
 }
diff --git a/fs/nilfs2/sufile.c b/fs/nilfs2/sufile.c
index 0a0aba6..c5b7653 100644
--- a/fs/nilfs2/sufile.c
+++ b/fs/nilfs2/sufile.c
@@ -111,11 +111,11 @@ static void nilfs_sufile_mod_counter(struct buffer_head *header_bh,
 	struct nilfs_sufile_header *header;
 	void *kaddr;
 
-	kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(header_bh->b_page);
 	header = kaddr + bh_offset(header_bh);
 	le64_add_cpu(&header->sh_ncleansegs, ncleanadd);
 	le64_add_cpu(&header->sh_ndirtysegs, ndirtyadd);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	mark_buffer_dirty(header_bh);
 }
@@ -319,11 +319,11 @@ int nilfs_sufile_alloc(struct inode *sufile, __u64 *segnump)
 	ret = nilfs_sufile_get_header_block(sufile, &header_bh);
 	if (ret < 0)
 		goto out_sem;
-	kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(header_bh->b_page);
 	header = kaddr + bh_offset(header_bh);
 	ncleansegs = le64_to_cpu(header->sh_ncleansegs);
 	last_alloc = le64_to_cpu(header->sh_last_alloc);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	nsegments = nilfs_sufile_get_nsegments(sufile);
 	maxsegnum = sui->allocmax;
@@ -356,7 +356,7 @@ int nilfs_sufile_alloc(struct inode *sufile, __u64 *segnump)
 							   &su_bh);
 		if (ret < 0)
 			goto out_header;
-		kaddr = kmap_atomic(su_bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(su_bh->b_page);
 		su = nilfs_sufile_block_get_segment_usage(
 			sufile, segnum, su_bh, kaddr);
 
@@ -367,14 +367,14 @@ int nilfs_sufile_alloc(struct inode *sufile, __u64 *segnump)
 				continue;
 			/* found a clean segment */
 			nilfs_segment_usage_set_dirty(su);
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 
-			kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+			kaddr = kmap_atomic(header_bh->b_page);
 			header = kaddr + bh_offset(header_bh);
 			le64_add_cpu(&header->sh_ncleansegs, -1);
 			le64_add_cpu(&header->sh_ndirtysegs, 1);
 			header->sh_last_alloc = cpu_to_le64(segnum);
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 
 			sui->ncleansegs--;
 			mark_buffer_dirty(header_bh);
@@ -385,7 +385,7 @@ int nilfs_sufile_alloc(struct inode *sufile, __u64 *segnump)
 			goto out_header;
 		}
 
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		brelse(su_bh);
 	}
 
@@ -407,16 +407,16 @@ void nilfs_sufile_do_cancel_free(struct inode *sufile, __u64 segnum,
 	struct nilfs_segment_usage *su;
 	void *kaddr;
 
-	kaddr = kmap_atomic(su_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(su_bh->b_page);
 	su = nilfs_sufile_block_get_segment_usage(sufile, segnum, su_bh, kaddr);
 	if (unlikely(!nilfs_segment_usage_clean(su))) {
 		printk(KERN_WARNING "%s: segment %llu must be clean\n",
 		       __func__, (unsigned long long)segnum);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		return;
 	}
 	nilfs_segment_usage_set_dirty(su);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	nilfs_sufile_mod_counter(header_bh, -1, 1);
 	NILFS_SUI(sufile)->ncleansegs--;
@@ -433,11 +433,11 @@ void nilfs_sufile_do_scrap(struct inode *sufile, __u64 segnum,
 	void *kaddr;
 	int clean, dirty;
 
-	kaddr = kmap_atomic(su_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(su_bh->b_page);
 	su = nilfs_sufile_block_get_segment_usage(sufile, segnum, su_bh, kaddr);
 	if (su->su_flags == cpu_to_le32(1UL << NILFS_SEGMENT_USAGE_DIRTY) &&
 	    su->su_nblocks == cpu_to_le32(0)) {
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		return;
 	}
 	clean = nilfs_segment_usage_clean(su);
@@ -447,7 +447,7 @@ void nilfs_sufile_do_scrap(struct inode *sufile, __u64 segnum,
 	su->su_lastmod = cpu_to_le64(0);
 	su->su_nblocks = cpu_to_le32(0);
 	su->su_flags = cpu_to_le32(1UL << NILFS_SEGMENT_USAGE_DIRTY);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	nilfs_sufile_mod_counter(header_bh, clean ? (u64)-1 : 0, dirty ? 0 : 1);
 	NILFS_SUI(sufile)->ncleansegs -= clean;
@@ -464,12 +464,12 @@ void nilfs_sufile_do_free(struct inode *sufile, __u64 segnum,
 	void *kaddr;
 	int sudirty;
 
-	kaddr = kmap_atomic(su_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(su_bh->b_page);
 	su = nilfs_sufile_block_get_segment_usage(sufile, segnum, su_bh, kaddr);
 	if (nilfs_segment_usage_clean(su)) {
 		printk(KERN_WARNING "%s: segment %llu is already clean\n",
 		       __func__, (unsigned long long)segnum);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		return;
 	}
 	WARN_ON(nilfs_segment_usage_error(su));
@@ -477,7 +477,7 @@ void nilfs_sufile_do_free(struct inode *sufile, __u64 segnum,
 
 	sudirty = nilfs_segment_usage_dirty(su);
 	nilfs_segment_usage_set_clean(su);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	mark_buffer_dirty(su_bh);
 
 	nilfs_sufile_mod_counter(header_bh, 1, sudirty ? (u64)-1 : 0);
@@ -525,13 +525,13 @@ int nilfs_sufile_set_segment_usage(struct inode *sufile, __u64 segnum,
 	if (ret < 0)
 		goto out_sem;
 
-	kaddr = kmap_atomic(bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(bh->b_page);
 	su = nilfs_sufile_block_get_segment_usage(sufile, segnum, bh, kaddr);
 	WARN_ON(nilfs_segment_usage_error(su));
 	if (modtime)
 		su->su_lastmod = cpu_to_le64(modtime);
 	su->su_nblocks = cpu_to_le32(nblocks);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	mark_buffer_dirty(bh);
 	nilfs_mdt_mark_dirty(sufile);
@@ -572,7 +572,7 @@ int nilfs_sufile_get_stat(struct inode *sufile, struct nilfs_sustat *sustat)
 	if (ret < 0)
 		goto out_sem;
 
-	kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(header_bh->b_page);
 	header = kaddr + bh_offset(header_bh);
 	sustat->ss_nsegs = nilfs_sufile_get_nsegments(sufile);
 	sustat->ss_ncleansegs = le64_to_cpu(header->sh_ncleansegs);
@@ -582,7 +582,7 @@ int nilfs_sufile_get_stat(struct inode *sufile, struct nilfs_sustat *sustat)
 	spin_lock(&nilfs->ns_last_segment_lock);
 	sustat->ss_prot_seq = nilfs->ns_prot_seq;
 	spin_unlock(&nilfs->ns_last_segment_lock);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	brelse(header_bh);
 
  out_sem:
@@ -598,15 +598,15 @@ void nilfs_sufile_do_set_error(struct inode *sufile, __u64 segnum,
 	void *kaddr;
 	int suclean;
 
-	kaddr = kmap_atomic(su_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(su_bh->b_page);
 	su = nilfs_sufile_block_get_segment_usage(sufile, segnum, su_bh, kaddr);
 	if (nilfs_segment_usage_error(su)) {
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		return;
 	}
 	suclean = nilfs_segment_usage_clean(su);
 	nilfs_segment_usage_set_error(su);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	if (suclean) {
 		nilfs_sufile_mod_counter(header_bh, -1, 0);
@@ -675,7 +675,7 @@ static int nilfs_sufile_truncate_range(struct inode *sufile,
 			/* hole */
 			continue;
 		}
-		kaddr = kmap_atomic(su_bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(su_bh->b_page);
 		su = nilfs_sufile_block_get_segment_usage(
 			sufile, segnum, su_bh, kaddr);
 		su2 = su;
@@ -684,7 +684,7 @@ static int nilfs_sufile_truncate_range(struct inode *sufile,
 			     ~(1UL << NILFS_SEGMENT_USAGE_ERROR)) ||
 			    nilfs_segment_is_active(nilfs, segnum + j)) {
 				ret = -EBUSY;
-				kunmap_atomic(kaddr, KM_USER0);
+				kunmap_atomic(kaddr);
 				brelse(su_bh);
 				goto out_header;
 			}
@@ -696,7 +696,7 @@ static int nilfs_sufile_truncate_range(struct inode *sufile,
 				nc++;
 			}
 		}
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		if (nc > 0) {
 			mark_buffer_dirty(su_bh);
 			ncleaned += nc;
@@ -772,10 +772,10 @@ int nilfs_sufile_resize(struct inode *sufile, __u64 newnsegs)
 		sui->ncleansegs -= nsegs - newnsegs;
 	}
 
-	kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(header_bh->b_page);
 	header = kaddr + bh_offset(header_bh);
 	header->sh_ncleansegs = cpu_to_le64(sui->ncleansegs);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	mark_buffer_dirty(header_bh);
 	nilfs_mdt_mark_dirty(sufile);
@@ -840,7 +840,7 @@ ssize_t nilfs_sufile_get_suinfo(struct inode *sufile, __u64 segnum, void *buf,
 			continue;
 		}
 
-		kaddr = kmap_atomic(su_bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(su_bh->b_page);
 		su = nilfs_sufile_block_get_segment_usage(
 			sufile, segnum, su_bh, kaddr);
 		for (j = 0; j < n;
@@ -853,7 +853,7 @@ ssize_t nilfs_sufile_get_suinfo(struct inode *sufile, __u64 segnum, void *buf,
 				si->sui_flags |=
 					(1UL << NILFS_SEGMENT_USAGE_ACTIVE);
 		}
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		brelse(su_bh);
 	}
 	ret = nsegs;
@@ -902,10 +902,10 @@ int nilfs_sufile_read(struct super_block *sb, size_t susize,
 		goto failed;
 
 	sui = NILFS_SUI(sufile);
-	kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(header_bh->b_page);
 	header = kaddr + bh_offset(header_bh);
 	sui->ncleansegs = le64_to_cpu(header->sh_ncleansegs);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	brelse(header_bh);
 
 	sui->allocmax = nilfs_sufile_get_nsegments(sufile) - 1;
diff --git a/fs/ntfs/aops.c b/fs/ntfs/aops.c
index 0b1e885b..fa9c05f 100644
--- a/fs/ntfs/aops.c
+++ b/fs/ntfs/aops.c
@@ -94,11 +94,11 @@ static void ntfs_end_buffer_async_read(struct buffer_head *bh, int uptodate)
 			if (file_ofs < init_size)
 				ofs = init_size - file_ofs;
 			local_irq_save(flags);
-			kaddr = kmap_atomic(page, KM_BIO_SRC_IRQ);
+			kaddr = kmap_atomic(page);
 			memset(kaddr + bh_offset(bh) + ofs, 0,
 					bh->b_size - ofs);
 			flush_dcache_page(page);
-			kunmap_atomic(kaddr, KM_BIO_SRC_IRQ);
+			kunmap_atomic(kaddr);
 			local_irq_restore(flags);
 		}
 	} else {
@@ -147,11 +147,11 @@ static void ntfs_end_buffer_async_read(struct buffer_head *bh, int uptodate)
 		/* Should have been verified before we got here... */
 		BUG_ON(!recs);
 		local_irq_save(flags);
-		kaddr = kmap_atomic(page, KM_BIO_SRC_IRQ);
+		kaddr = kmap_atomic(page);
 		for (i = 0; i < recs; i++)
 			post_read_mst_fixup((NTFS_RECORD*)(kaddr +
 					i * rec_size), rec_size);
-		kunmap_atomic(kaddr, KM_BIO_SRC_IRQ);
+		kunmap_atomic(kaddr);
 		local_irq_restore(flags);
 		flush_dcache_page(page);
 		if (likely(page_uptodate && !PageError(page)))
@@ -504,7 +504,7 @@ retry_readpage:
 		/* Race with shrinking truncate. */
 		attr_len = i_size;
 	}
-	addr = kmap_atomic(page, KM_USER0);
+	addr = kmap_atomic(page);
 	/* Copy the data to the page. */
 	memcpy(addr, (u8*)ctx->attr +
 			le16_to_cpu(ctx->attr->data.resident.value_offset),
@@ -512,7 +512,7 @@ retry_readpage:
 	/* Zero the remainder of the page. */
 	memset(addr + attr_len, 0, PAGE_CACHE_SIZE - attr_len);
 	flush_dcache_page(page);
-	kunmap_atomic(addr, KM_USER0);
+	kunmap_atomic(addr);
 put_unm_err_out:
 	ntfs_attr_put_search_ctx(ctx);
 unm_err_out:
@@ -746,14 +746,14 @@ lock_retry_remap:
 			unsigned long *bpos, *bend;
 
 			/* Check if the buffer is zero. */
-			kaddr = kmap_atomic(page, KM_USER0);
+			kaddr = kmap_atomic(page);
 			bpos = (unsigned long *)(kaddr + bh_offset(bh));
 			bend = (unsigned long *)((u8*)bpos + blocksize);
 			do {
 				if (unlikely(*bpos))
 					break;
 			} while (likely(++bpos < bend));
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 			if (bpos == bend) {
 				/*
 				 * Buffer is zero and sparse, no need to write
@@ -1495,14 +1495,14 @@ retry_writepage:
 		/* Shrinking cannot fail. */
 		BUG_ON(err);
 	}
-	addr = kmap_atomic(page, KM_USER0);
+	addr = kmap_atomic(page);
 	/* Copy the data from the page to the mft record. */
 	memcpy((u8*)ctx->attr +
 			le16_to_cpu(ctx->attr->data.resident.value_offset),
 			addr, attr_len);
 	/* Zero out of bounds area in the page cache page. */
 	memset(addr + attr_len, 0, PAGE_CACHE_SIZE - attr_len);
-	kunmap_atomic(addr, KM_USER0);
+	kunmap_atomic(addr);
 	flush_dcache_page(page);
 	flush_dcache_mft_record_page(ctx->ntfs_ino);
 	/* We are done with the page. */
diff --git a/fs/ntfs/attrib.c b/fs/ntfs/attrib.c
index f14fde2..08c9bcd 100644
--- a/fs/ntfs/attrib.c
+++ b/fs/ntfs/attrib.c
@@ -1656,12 +1656,12 @@ int ntfs_attr_make_non_resident(ntfs_inode *ni, const u32 data_size)
 	attr_size = le32_to_cpu(a->data.resident.value_length);
 	BUG_ON(attr_size != data_size);
 	if (page && !PageUptodate(page)) {
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		memcpy(kaddr, (u8*)a +
 				le16_to_cpu(a->data.resident.value_offset),
 				attr_size);
 		memset(kaddr + attr_size, 0, PAGE_CACHE_SIZE - attr_size);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		flush_dcache_page(page);
 		SetPageUptodate(page);
 	}
@@ -1806,9 +1806,9 @@ undo_err_out:
 			sizeof(a->data.resident.reserved));
 	/* Copy the data from the page back to the attribute value. */
 	if (page) {
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		memcpy((u8*)a + mp_ofs, kaddr, attr_size);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 	/* Setup the allocated size in the ntfs inode in case it changed. */
 	write_lock_irqsave(&ni->size_lock, flags);
@@ -2540,10 +2540,10 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		size = PAGE_CACHE_SIZE;
 		if (idx == end)
 			size = end_ofs;
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		memset(kaddr + start_ofs, val, size - start_ofs);
 		flush_dcache_page(page);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		set_page_dirty(page);
 		page_cache_release(page);
 		balance_dirty_pages_ratelimited(mapping);
@@ -2561,10 +2561,10 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 					"page (index 0x%lx).", idx);
 			return -ENOMEM;
 		}
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		memset(kaddr, val, PAGE_CACHE_SIZE);
 		flush_dcache_page(page);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		/*
 		 * If the page has buffers, mark them uptodate since buffer
 		 * state and not page state is definitive in 2.6 kernels.
@@ -2598,10 +2598,10 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 					"(error, index 0x%lx).", idx);
 			return PTR_ERR(page);
 		}
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		memset(kaddr, val, end_ofs);
 		flush_dcache_page(page);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		set_page_dirty(page);
 		page_cache_release(page);
 		balance_dirty_pages_ratelimited(mapping);
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index c587e2d..8639169 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -704,7 +704,7 @@ map_buffer_cached:
 				u8 *kaddr;
 				unsigned pofs;
 					
-				kaddr = kmap_atomic(page, KM_USER0);
+				kaddr = kmap_atomic(page);
 				if (bh_pos < pos) {
 					pofs = bh_pos & ~PAGE_CACHE_MASK;
 					memset(kaddr + pofs, 0, pos - bh_pos);
@@ -713,7 +713,7 @@ map_buffer_cached:
 					pofs = end & ~PAGE_CACHE_MASK;
 					memset(kaddr + pofs, 0, bh_end - end);
 				}
-				kunmap_atomic(kaddr, KM_USER0);
+				kunmap_atomic(kaddr);
 				flush_dcache_page(page);
 			}
 			continue;
@@ -1287,9 +1287,9 @@ static inline size_t ntfs_copy_from_user(struct page **pages,
 		len = PAGE_CACHE_SIZE - ofs;
 		if (len > bytes)
 			len = bytes;
-		addr = kmap_atomic(*pages, KM_USER0);
+		addr = kmap_atomic(*pages);
 		left = __copy_from_user_inatomic(addr + ofs, buf, len);
-		kunmap_atomic(addr, KM_USER0);
+		kunmap_atomic(addr);
 		if (unlikely(left)) {
 			/* Do it the slow way. */
 			addr = kmap(*pages);
@@ -1401,10 +1401,10 @@ static inline size_t ntfs_copy_from_user_iovec(struct page **pages,
 		len = PAGE_CACHE_SIZE - ofs;
 		if (len > bytes)
 			len = bytes;
-		addr = kmap_atomic(*pages, KM_USER0);
+		addr = kmap_atomic(*pages);
 		copied = __ntfs_copy_from_user_iovec_inatomic(addr + ofs,
 				*iov, *iov_ofs, len);
-		kunmap_atomic(addr, KM_USER0);
+		kunmap_atomic(addr);
 		if (unlikely(copied != len)) {
 			/* Do it the slow way. */
 			addr = kmap(*pages);
@@ -1691,7 +1691,7 @@ static int ntfs_commit_pages_after_write(struct page **pages,
 	BUG_ON(end > le32_to_cpu(a->length) -
 			le16_to_cpu(a->data.resident.value_offset));
 	kattr = (u8*)a + le16_to_cpu(a->data.resident.value_offset);
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	/* Copy the received data from the page to the mft record. */
 	memcpy(kattr + pos, kaddr + pos, bytes);
 	/* Update the attribute length if necessary. */
@@ -1713,7 +1713,7 @@ static int ntfs_commit_pages_after_write(struct page **pages,
 		flush_dcache_page(page);
 		SetPageUptodate(page);
 	}
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	/* Update initialized_size/i_size if necessary. */
 	read_lock_irqsave(&ni->size_lock, flags);
 	initialized_size = ni->initialized_size;
diff --git a/fs/ntfs/super.c b/fs/ntfs/super.c
index b52706d..2978cd3 100644
--- a/fs/ntfs/super.c
+++ b/fs/ntfs/super.c
@@ -2475,7 +2475,7 @@ static s64 get_nr_free_clusters(ntfs_volume *vol)
 			nr_free -= PAGE_CACHE_SIZE * 8;
 			continue;
 		}
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		/*
 		 * Subtract the number of set bits. If this
 		 * is the last page and it is partial we don't really care as
@@ -2485,7 +2485,7 @@ static s64 get_nr_free_clusters(ntfs_volume *vol)
 		 */
 		nr_free -= bitmap_weight(kaddr,
 					PAGE_CACHE_SIZE * BITS_PER_BYTE);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		page_cache_release(page);
 	}
 	ntfs_debug("Finished reading $Bitmap, last index = 0x%lx.", index - 1);
@@ -2546,7 +2546,7 @@ static unsigned long __get_nr_free_mft_records(ntfs_volume *vol,
 			nr_free -= PAGE_CACHE_SIZE * 8;
 			continue;
 		}
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		/*
 		 * Subtract the number of set bits. If this
 		 * is the last page and it is partial we don't really care as
@@ -2556,7 +2556,7 @@ static unsigned long __get_nr_free_mft_records(ntfs_volume *vol,
 		 */
 		nr_free -= bitmap_weight(kaddr,
 					PAGE_CACHE_SIZE * BITS_PER_BYTE);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		page_cache_release(page);
 	}
 	ntfs_debug("Finished reading $MFT/$BITMAP, last index = 0x%lx.",
diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
index c1efe93..61f93a5 100644
--- a/fs/ocfs2/aops.c
+++ b/fs/ocfs2/aops.c
@@ -102,7 +102,7 @@ static int ocfs2_symlink_get_block(struct inode *inode, sector_t iblock,
 		 * copy, the data is still good. */
 		if (buffer_jbd(buffer_cache_bh)
 		    && ocfs2_inode_is_new(inode)) {
-			kaddr = kmap_atomic(bh_result->b_page, KM_USER0);
+			kaddr = kmap_atomic(bh_result->b_page);
 			if (!kaddr) {
 				mlog(ML_ERROR, "couldn't kmap!\n");
 				goto bail;
@@ -110,7 +110,7 @@ static int ocfs2_symlink_get_block(struct inode *inode, sector_t iblock,
 			memcpy(kaddr + (bh_result->b_size * iblock),
 			       buffer_cache_bh->b_data,
 			       bh_result->b_size);
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 			set_buffer_uptodate(bh_result);
 		}
 		brelse(buffer_cache_bh);
@@ -236,13 +236,13 @@ int ocfs2_read_inline_data(struct inode *inode, struct page *page,
 		return -EROFS;
 	}
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	if (size)
 		memcpy(kaddr, di->id2.i_data.id_data, size);
 	/* Clear the remaining part of the page */
 	memset(kaddr + size, 0, PAGE_CACHE_SIZE - size);
 	flush_dcache_page(page);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	SetPageUptodate(page);
 
@@ -671,7 +671,7 @@ static void ocfs2_clear_page_regions(struct page *page,
 
 	ocfs2_figure_cluster_boundaries(osb, cpos, &cluster_start, &cluster_end);
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 
 	if (from || to) {
 		if (from > cluster_start)
@@ -682,7 +682,7 @@ static void ocfs2_clear_page_regions(struct page *page,
 		memset(kaddr + cluster_start, 0, cluster_end - cluster_start);
 	}
 
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 /*
@@ -1928,9 +1928,9 @@ static void ocfs2_write_end_inline(struct inode *inode, loff_t pos,
 		}
 	}
 
-	kaddr = kmap_atomic(wc->w_target_page, KM_USER0);
+	kaddr = kmap_atomic(wc->w_target_page);
 	memcpy(di->id2.i_data.id_data + pos, kaddr + pos, *copied);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	trace_ocfs2_write_end_inline(
 	     (unsigned long long)OCFS2_I(inode)->ip_blkno,
diff --git a/fs/pipe.c b/fs/pipe.c
index 0e0be1d..1a2ff81 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -230,7 +230,7 @@ void *generic_pipe_buf_map(struct pipe_inode_info *pipe,
 {
 	if (atomic) {
 		buf->flags |= PIPE_BUF_FLAG_ATOMIC;
-		return kmap_atomic(buf->page, KM_USER0);
+		return kmap_atomic(buf->page);
 	}
 
 	return kmap(buf->page);
@@ -251,7 +251,7 @@ void generic_pipe_buf_unmap(struct pipe_inode_info *pipe,
 {
 	if (buf->flags & PIPE_BUF_FLAG_ATOMIC) {
 		buf->flags &= ~PIPE_BUF_FLAG_ATOMIC;
-		kunmap_atomic(map_data, KM_USER0);
+		kunmap_atomic(map_data);
 	} else
 		kunmap(buf->page);
 }
@@ -565,14 +565,14 @@ redo1:
 			iov_fault_in_pages_read(iov, chars);
 redo2:
 			if (atomic)
-				src = kmap_atomic(page, KM_USER0);
+				src = kmap_atomic(page);
 			else
 				src = kmap(page);
 
 			error = pipe_iov_copy_from_user(src, iov, chars,
 							atomic);
 			if (atomic)
-				kunmap_atomic(src, KM_USER0);
+				kunmap_atomic(src);
 			else
 				kunmap(page);
 
diff --git a/fs/reiserfs/stree.c b/fs/reiserfs/stree.c
index 313d39d..77df82f 100644
--- a/fs/reiserfs/stree.c
+++ b/fs/reiserfs/stree.c
@@ -1284,12 +1284,12 @@ int reiserfs_delete_item(struct reiserfs_transaction_handle *th,
 		 ** -clm
 		 */
 
-		data = kmap_atomic(un_bh->b_page, KM_USER0);
+		data = kmap_atomic(un_bh->b_page);
 		off = ((le_ih_k_offset(&s_ih) - 1) & (PAGE_CACHE_SIZE - 1));
 		memcpy(data + off,
 		       B_I_PITEM(PATH_PLAST_BUFFER(path), &s_ih),
 		       ret_value);
-		kunmap_atomic(data, KM_USER0);
+		kunmap_atomic(data);
 	}
 	/* Perform balancing after all resources have been collected at once. */
 	do_balance(&s_del_balance, NULL, NULL, M_DELETE);
diff --git a/fs/reiserfs/tail_conversion.c b/fs/reiserfs/tail_conversion.c
index d7f6e51..8f546bd 100644
--- a/fs/reiserfs/tail_conversion.c
+++ b/fs/reiserfs/tail_conversion.c
@@ -128,9 +128,9 @@ int direct2indirect(struct reiserfs_transaction_handle *th, struct inode *inode,
 	if (up_to_date_bh) {
 		unsigned pgoff =
 		    (tail_offset + total_tail - 1) & (PAGE_CACHE_SIZE - 1);
-		char *kaddr = kmap_atomic(up_to_date_bh->b_page, KM_USER0);
+		char *kaddr = kmap_atomic(up_to_date_bh->b_page);
 		memset(kaddr + pgoff, 0, blk_size - total_tail);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 
 	REISERFS_I(inode)->i_first_direct_byte = U32_MAX;
diff --git a/fs/splice.c b/fs/splice.c
index fa2defa..579381b 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -742,11 +742,11 @@ int pipe_to_file(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
 		 * Careful, ->map() uses KM_USER0!
 		 */
 		char *src = buf->ops->map(pipe, buf, 1);
-		char *dst = kmap_atomic(page, KM_USER1);
+		char *dst = kmap_atomic(page);
 
 		memcpy(dst + offset, src + buf->offset, this_len);
 		flush_dcache_page(page);
-		kunmap_atomic(dst, KM_USER1);
+		kunmap_atomic(dst);
 		buf->ops->unmap(pipe, buf, src);
 	}
 	ret = pagecache_write_end(file, mapping, sd->pos, this_len, this_len,
diff --git a/fs/squashfs/file.c b/fs/squashfs/file.c
index 38bb1c6..8ca62c2 100644
--- a/fs/squashfs/file.c
+++ b/fs/squashfs/file.c
@@ -464,10 +464,10 @@ static int squashfs_readpage(struct file *file, struct page *page)
 		if (PageUptodate(push_page))
 			goto skip_page;
 
-		pageaddr = kmap_atomic(push_page, KM_USER0);
+		pageaddr = kmap_atomic(push_page);
 		squashfs_copy_data(pageaddr, buffer, offset, avail);
 		memset(pageaddr + avail, 0, PAGE_CACHE_SIZE - avail);
-		kunmap_atomic(pageaddr, KM_USER0);
+		kunmap_atomic(pageaddr);
 		flush_dcache_page(push_page);
 		SetPageUptodate(push_page);
 skip_page:
@@ -484,9 +484,9 @@ skip_page:
 error_out:
 	SetPageError(page);
 out:
-	pageaddr = kmap_atomic(page, KM_USER0);
+	pageaddr = kmap_atomic(page);
 	memset(pageaddr, 0, PAGE_CACHE_SIZE);
-	kunmap_atomic(pageaddr, KM_USER0);
+	kunmap_atomic(pageaddr);
 	flush_dcache_page(page);
 	if (!PageError(page))
 		SetPageUptodate(page);
diff --git a/fs/squashfs/symlink.c b/fs/squashfs/symlink.c
index 1191817..12806df 100644
--- a/fs/squashfs/symlink.c
+++ b/fs/squashfs/symlink.c
@@ -90,14 +90,14 @@ static int squashfs_symlink_readpage(struct file *file, struct page *page)
 			goto error_out;
 		}
 
-		pageaddr = kmap_atomic(page, KM_USER0);
+		pageaddr = kmap_atomic(page);
 		copied = squashfs_copy_data(pageaddr + bytes, entry, offset,
 								length - bytes);
 		if (copied == length - bytes)
 			memset(pageaddr + length, 0, PAGE_CACHE_SIZE - length);
 		else
 			block = entry->next_index;
-		kunmap_atomic(pageaddr, KM_USER0);
+		kunmap_atomic(pageaddr);
 		squashfs_cache_put(entry);
 	}
 
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index f9c234b..5c8f6dc 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1042,10 +1042,10 @@ static int ubifs_writepage(struct page *page, struct writeback_control *wbc)
 	 * the page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memset(kaddr + len, 0, PAGE_CACHE_SIZE - len);
 	flush_dcache_page(page);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	if (i_size > synced_i_size) {
 		err = inode->i_sb->s_op->write_inode(inode, NULL);
diff --git a/fs/udf/file.c b/fs/udf/file.c
index d8ffa7c..95b8d91 100644
--- a/fs/udf/file.c
+++ b/fs/udf/file.c
@@ -87,10 +87,10 @@ static int udf_adinicb_write_end(struct file *file,
 	char *kaddr;
 	struct udf_inode_info *iinfo = UDF_I(inode);
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memcpy(iinfo->i_ext.i_data + iinfo->i_lenEAttr + offset,
 		kaddr + offset, copied);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	return simple_write_end(file, mapping, pos, len, copied, page, fsdata);
 }
diff --git a/include/crypto/scatterwalk.h b/include/crypto/scatterwalk.h
index 4fd95a3..7788883 100644
--- a/include/crypto/scatterwalk.h
+++ b/include/crypto/scatterwalk.h
@@ -39,12 +39,12 @@ static inline enum km_type crypto_kmap_type(int out)
 
 static inline void *crypto_kmap(struct page *page, int out)
 {
-	return kmap_atomic(page, crypto_kmap_type(out));
+	return kmap_atomic(page);
 }
 
 static inline void crypto_kunmap(void *vaddr, int out)
 {
-	kunmap_atomic(vaddr, crypto_kmap_type(out));
+	kunmap_atomic(vaddr);
 }
 
 static inline void crypto_yield(u32 flags)
diff --git a/include/linux/bio.h b/include/linux/bio.h
index ce33e68..9ba4f3b 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -100,11 +100,11 @@ static inline int bio_has_allocated_vec(struct bio *bio)
  * permanent PIO fall back, user is probably better off disabling highmem
  * I/O completely on that queue (see ide-dma for example)
  */
-#define __bio_kmap_atomic(bio, idx, kmtype)				\
-	(kmap_atomic(bio_iovec_idx((bio), (idx))->bv_page, kmtype) +	\
+#define __bio_kmap_atomic(bio, idx)				\
+	(kmap_atomic(bio_iovec_idx((bio), (idx))->bv_page) +	\
 		bio_iovec_idx((bio), (idx))->bv_offset)
 
-#define __bio_kunmap_atomic(addr, kmtype) kunmap_atomic(addr, kmtype)
+#define __bio_kunmap_atomic(addr, kmtype) kunmap_atomic(addr)
 
 /*
  * merge helpers etc
@@ -325,7 +325,7 @@ static inline char *bvec_kmap_irq(struct bio_vec *bvec, unsigned long *flags)
 	 * balancing is a lot nicer this way
 	 */
 	local_irq_save(*flags);
-	addr = (unsigned long) kmap_atomic(bvec->bv_page, KM_BIO_SRC_IRQ);
+	addr = (unsigned long) kmap_atomic(bvec->bv_page);
 
 	BUG_ON(addr & ~PAGE_MASK);
 
@@ -336,7 +336,7 @@ static inline void bvec_kunmap_irq(char *buffer, unsigned long *flags)
 {
 	unsigned long ptr = (unsigned long) buffer & PAGE_MASK;
 
-	kunmap_atomic((void *) ptr, KM_BIO_SRC_IRQ);
+	kunmap_atomic((void *) ptr);
 	local_irq_restore(*flags);
 }
 
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 3a93f73..8f129a6 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -117,7 +117,7 @@ static inline void kmap_atomic_idx_pop(void)
  * Prevent people trying to call kunmap_atomic() as if it were kunmap()
  * kunmap_atomic() should get the return value of kmap_atomic, not the page.
  */
-#define kunmap_atomic(addr, args...)				\
+#define kunmap_atomic(addr)					\
 do {								\
 	BUILD_BUG_ON(__same_type((addr), struct page *));	\
 	__kunmap_atomic(addr);					\
@@ -127,9 +127,9 @@ do {								\
 #ifndef clear_user_highpage
 static inline void clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *addr = kmap_atomic(page, KM_USER0);
+	void *addr = kmap_atomic(page);
 	clear_user_page(addr, vaddr, page);
-	kunmap_atomic(addr, KM_USER0);
+	kunmap_atomic(addr);
 }
 #endif
 
@@ -180,16 +180,16 @@ alloc_zeroed_user_highpage_movable(struct vm_area_struct *vma,
 
 static inline void clear_highpage(struct page *page)
 {
-	void *kaddr = kmap_atomic(page, KM_USER0);
+	void *kaddr = kmap_atomic(page);
 	clear_page(kaddr);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 static inline void zero_user_segments(struct page *page,
 	unsigned start1, unsigned end1,
 	unsigned start2, unsigned end2)
 {
-	void *kaddr = kmap_atomic(page, KM_USER0);
+	void *kaddr = kmap_atomic(page);
 
 	BUG_ON(end1 > PAGE_SIZE || end2 > PAGE_SIZE);
 
@@ -199,7 +199,7 @@ static inline void zero_user_segments(struct page *page,
 	if (end2 > start2)
 		memset(kaddr + start2, 0, end2 - start2);
 
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	flush_dcache_page(page);
 }
 
@@ -228,11 +228,11 @@ static inline void copy_user_highpage(struct page *to, struct page *from,
 {
 	char *vfrom, *vto;
 
-	vfrom = kmap_atomic(from, KM_USER0);
-	vto = kmap_atomic(to, KM_USER1);
+	vfrom = kmap_atomic(from);
+	vto = kmap_atomic(to);
 	copy_user_page(vto, vfrom, vaddr, to);
-	kunmap_atomic(vto, KM_USER1);
-	kunmap_atomic(vfrom, KM_USER0);
+	kunmap_atomic(vto);
+	kunmap_atomic(vfrom);
 }
 
 #endif
@@ -241,11 +241,11 @@ static inline void copy_highpage(struct page *to, struct page *from)
 {
 	char *vfrom, *vto;
 
-	vfrom = kmap_atomic(from, KM_USER0);
-	vto = kmap_atomic(to, KM_USER1);
+	vfrom = kmap_atomic(from);
+	vto = kmap_atomic(to);
 	copy_page(vto, vfrom);
-	kunmap_atomic(vto, KM_USER1);
-	kunmap_atomic(vfrom, KM_USER0);
+	kunmap_atomic(vto);
+	kunmap_atomic(vfrom);
 }
 
 #endif /* _LINUX_HIGHMEM_H */
diff --git a/kernel/debug/kdb/kdb_support.c b/kernel/debug/kdb/kdb_support.c
index 5532dd3..e593fd7 100644
--- a/kernel/debug/kdb/kdb_support.c
+++ b/kernel/debug/kdb/kdb_support.c
@@ -384,9 +384,9 @@ static int kdb_getphys(void *res, unsigned long addr, size_t size)
 	if (!pfn_valid(pfn))
 		return 1;
 	page = pfn_to_page(pfn);
-	vaddr = kmap_atomic(page, KM_KDB);
+	vaddr = kmap_atomic(page);
 	memcpy(res, vaddr + (addr & (PAGE_SIZE - 1)), size);
-	kunmap_atomic(vaddr, KM_KDB);
+	kunmap_atomic(vaddr);
 
 	return 0;
 }
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 06efa54..ab84318 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -993,20 +993,20 @@ static void copy_data_page(unsigned long dst_pfn, unsigned long src_pfn)
 	s_page = pfn_to_page(src_pfn);
 	d_page = pfn_to_page(dst_pfn);
 	if (PageHighMem(s_page)) {
-		src = kmap_atomic(s_page, KM_USER0);
-		dst = kmap_atomic(d_page, KM_USER1);
+		src = kmap_atomic(s_page);
+		dst = kmap_atomic(d_page);
 		do_copy_page(dst, src);
-		kunmap_atomic(dst, KM_USER1);
-		kunmap_atomic(src, KM_USER0);
+		kunmap_atomic(dst);
+		kunmap_atomic(src);
 	} else {
 		if (PageHighMem(d_page)) {
 			/* Page pointed to by src may contain some kernel
 			 * data modified by kmap_atomic()
 			 */
 			safe_copy_page(buffer, s_page);
-			dst = kmap_atomic(d_page, KM_USER0);
+			dst = kmap_atomic(d_page);
 			copy_page(dst, buffer);
-			kunmap_atomic(dst, KM_USER0);
+			kunmap_atomic(dst);
 		} else {
 			safe_copy_page(page_address(d_page), s_page);
 		}
@@ -1716,9 +1716,9 @@ int snapshot_read_next(struct snapshot_handle *handle)
 			 */
 			void *kaddr;
 
-			kaddr = kmap_atomic(page, KM_USER0);
+			kaddr = kmap_atomic(page);
 			copy_page(buffer, kaddr);
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 			handle->buffer = buffer;
 		} else {
 			handle->buffer = page_address(page);
@@ -1999,9 +1999,9 @@ static void copy_last_highmem_page(void)
 	if (last_highmem_page) {
 		void *dst;
 
-		dst = kmap_atomic(last_highmem_page, KM_USER0);
+		dst = kmap_atomic(last_highmem_page);
 		copy_page(dst, buffer);
-		kunmap_atomic(dst, KM_USER0);
+		kunmap_atomic(dst);
 		last_highmem_page = NULL;
 	}
 }
@@ -2284,13 +2284,13 @@ swap_two_pages_data(struct page *p1, struct page *p2, void *buf)
 {
 	void *kaddr1, *kaddr2;
 
-	kaddr1 = kmap_atomic(p1, KM_USER0);
-	kaddr2 = kmap_atomic(p2, KM_USER1);
+	kaddr1 = kmap_atomic(p1);
+	kaddr2 = kmap_atomic(p2);
 	copy_page(buf, kaddr1);
 	copy_page(kaddr1, kaddr2);
 	copy_page(kaddr2, buf);
-	kunmap_atomic(kaddr2, KM_USER1);
-	kunmap_atomic(kaddr1, KM_USER0);
+	kunmap_atomic(kaddr2);
+	kunmap_atomic(kaddr1);
 }
 
 /**
diff --git a/lib/scatterlist.c b/lib/scatterlist.c
index 4ceb05d..33b2cbb 100644
--- a/lib/scatterlist.c
+++ b/lib/scatterlist.c
@@ -390,7 +390,7 @@ bool sg_miter_next(struct sg_mapping_iter *miter)
 	miter->consumed = miter->length;
 
 	if (miter->__flags & SG_MITER_ATOMIC)
-		miter->addr = kmap_atomic(miter->page, KM_BIO_SRC_IRQ) + off;
+		miter->addr = kmap_atomic(miter->page) + off;
 	else
 		miter->addr = kmap(miter->page) + off;
 
@@ -424,7 +424,7 @@ void sg_miter_stop(struct sg_mapping_iter *miter)
 
 		if (miter->__flags & SG_MITER_ATOMIC) {
 			WARN_ON(!irqs_disabled());
-			kunmap_atomic(miter->addr, KM_BIO_SRC_IRQ);
+			kunmap_atomic(miter->addr);
 		} else
 			kunmap(miter->page);
 
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 99093b3..78361bc 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -348,13 +348,12 @@ void swiotlb_bounce(phys_addr_t phys, char *dma_addr, size_t size,
 			sz = min_t(size_t, PAGE_SIZE - offset, size);
 
 			local_irq_save(flags);
-			buffer = kmap_atomic(pfn_to_page(pfn),
-					     KM_BOUNCE_READ);
+			buffer = kmap_atomic(pfn_to_page(pfn));
 			if (dir == DMA_TO_DEVICE)
 				memcpy(dma_addr, buffer + offset, sz);
 			else
 				memcpy(buffer + offset, dma_addr, sz);
-			kunmap_atomic(buffer, KM_BOUNCE_READ);
+			kunmap_atomic(buffer);
 			local_irq_restore(flags);
 
 			size -= sz;
diff --git a/mm/bounce.c b/mm/bounce.c
index 1481de6..cfe8a5d 100644
--- a/mm/bounce.c
+++ b/mm/bounce.c
@@ -51,9 +51,9 @@ static void bounce_copy_vec(struct bio_vec *to, unsigned char *vfrom)
 	unsigned char *vto;
 
 	local_irq_save(flags);
-	vto = kmap_atomic(to->bv_page, KM_BOUNCE_READ);
+	vto = kmap_atomic(to->bv_page);
 	memcpy(vto + to->bv_offset, vfrom, to->bv_len);
-	kunmap_atomic(vto, KM_BOUNCE_READ);
+	kunmap_atomic(vto);
 	local_irq_restore(flags);
 }
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 645a080..b1b5ed4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1330,10 +1330,10 @@ int file_read_actor(read_descriptor_t *desc, struct page *page,
 	 * taking the kmap.
 	 */
 	if (!fault_in_pages_writeable(desc->arg.buf, size)) {
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		left = __copy_to_user_inatomic(desc->arg.buf,
 						kaddr + offset, size);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		if (left == 0)
 			goto success;
 	}
@@ -2060,7 +2060,7 @@ size_t iov_iter_copy_from_user_atomic(struct page *page,
 	size_t copied;
 
 	BUG_ON(!in_atomic());
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	if (likely(i->nr_segs == 1)) {
 		int left;
 		char __user *buf = i->iov->iov_base + i->iov_offset;
@@ -2070,7 +2070,7 @@ size_t iov_iter_copy_from_user_atomic(struct page *page,
 		copied = __iovec_copy_from_user_inatomic(kaddr + offset,
 						i->iov, i->iov_offset, bytes);
 	}
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	return copied;
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index 9a68b0c..b21de07 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -672,9 +672,9 @@ error:
 static u32 calc_checksum(struct page *page)
 {
 	u32 checksum;
-	void *addr = kmap_atomic(page, KM_USER0);
+	void *addr = kmap_atomic(page);
 	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
-	kunmap_atomic(addr, KM_USER0);
+	kunmap_atomic(addr);
 	return checksum;
 }
 
@@ -683,11 +683,11 @@ static int memcmp_pages(struct page *page1, struct page *page2)
 	char *addr1, *addr2;
 	int ret;
 
-	addr1 = kmap_atomic(page1, KM_USER0);
-	addr2 = kmap_atomic(page2, KM_USER1);
+	addr1 = kmap_atomic(page1);
+	addr2 = kmap_atomic(page2);
 	ret = memcmp(addr1, addr2, PAGE_SIZE);
-	kunmap_atomic(addr2, KM_USER1);
-	kunmap_atomic(addr1, KM_USER0);
+	kunmap_atomic(addr2);
+	kunmap_atomic(addr1);
 	return ret;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index a56e3ba..c3e0ed1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2428,7 +2428,7 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
 	 * fails, we just zero-fill it. Live with it.
 	 */
 	if (unlikely(!src)) {
-		void *kaddr = kmap_atomic(dst, KM_USER0);
+		void *kaddr = kmap_atomic(dst);
 		void __user *uaddr = (void __user *)(va & PAGE_MASK);
 
 		/*
@@ -2439,7 +2439,7 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
 		 */
 		if (__copy_from_user_inatomic(kaddr, uaddr, PAGE_SIZE))
 			clear_page(kaddr);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		flush_dcache_page(dst);
 	} else
 		copy_user_highpage(dst, src, va, vma);
diff --git a/mm/shmem.c b/mm/shmem.c
index 32f6763..d4b82c8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1625,9 +1625,9 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		}
 		inode->i_mapping->a_ops = &shmem_aops;
 		inode->i_op = &shmem_symlink_inode_operations;
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		memcpy(kaddr, symname, len);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		set_page_dirty(page);
 		unlock_page(page);
 		page_cache_release(page);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 17bc224..478616b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2427,9 +2427,9 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 		if (!(count & COUNT_CONTINUED))
 			goto out;
 
-		map = kmap_atomic(list_page, KM_USER0) + offset;
+		map = kmap_atomic(list_page) + offset;
 		count = *map;
-		kunmap_atomic(map, KM_USER0);
+		kunmap_atomic(map);
 
 		/*
 		 * If this continuation count now has some space in it,
@@ -2472,7 +2472,7 @@ static bool swap_count_continued(struct swap_info_struct *si,
 
 	offset &= ~PAGE_MASK;
 	page = list_entry(head->lru.next, struct page, lru);
-	map = kmap_atomic(page, KM_USER0) + offset;
+	map = kmap_atomic(page) + offset;
 
 	if (count == SWAP_MAP_MAX)	/* initial increment from swap_map */
 		goto init_map;		/* jump over SWAP_CONT_MAX checks */
@@ -2482,26 +2482,26 @@ static bool swap_count_continued(struct swap_info_struct *si,
 		 * Think of how you add 1 to 999
 		 */
 		while (*map == (SWAP_CONT_MAX | COUNT_CONTINUED)) {
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 			page = list_entry(page->lru.next, struct page, lru);
 			BUG_ON(page == head);
-			map = kmap_atomic(page, KM_USER0) + offset;
+			map = kmap_atomic(page) + offset;
 		}
 		if (*map == SWAP_CONT_MAX) {
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 			page = list_entry(page->lru.next, struct page, lru);
 			if (page == head)
 				return false;	/* add count continuation */
-			map = kmap_atomic(page, KM_USER0) + offset;
+			map = kmap_atomic(page) + offset;
 init_map:		*map = 0;		/* we didn't zero the page */
 		}
 		*map += 1;
-		kunmap_atomic(map, KM_USER0);
+		kunmap_atomic(map);
 		page = list_entry(page->lru.prev, struct page, lru);
 		while (page != head) {
-			map = kmap_atomic(page, KM_USER0) + offset;
+			map = kmap_atomic(page) + offset;
 			*map = COUNT_CONTINUED;
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 			page = list_entry(page->lru.prev, struct page, lru);
 		}
 		return true;			/* incremented */
@@ -2512,22 +2512,22 @@ init_map:		*map = 0;		/* we didn't zero the page */
 		 */
 		BUG_ON(count != COUNT_CONTINUED);
 		while (*map == COUNT_CONTINUED) {
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 			page = list_entry(page->lru.next, struct page, lru);
 			BUG_ON(page == head);
-			map = kmap_atomic(page, KM_USER0) + offset;
+			map = kmap_atomic(page) + offset;
 		}
 		BUG_ON(*map == 0);
 		*map -= 1;
 		if (*map == 0)
 			count = 0;
-		kunmap_atomic(map, KM_USER0);
+		kunmap_atomic(map);
 		page = list_entry(page->lru.prev, struct page, lru);
 		while (page != head) {
-			map = kmap_atomic(page, KM_USER0) + offset;
+			map = kmap_atomic(page) + offset;
 			*map = SWAP_CONT_MAX | count;
 			count = COUNT_CONTINUED;
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 			page = list_entry(page->lru.prev, struct page, lru);
 		}
 		return count == COUNT_CONTINUED;
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 7ef0903..5523b87 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1843,9 +1843,9 @@ static int aligned_vread(char *buf, char *addr, unsigned long count)
 			 * we can expect USER0 is not used (see vread/vwrite's
 			 * function description)
 			 */
-			void *map = kmap_atomic(p, KM_USER0);
+			void *map = kmap_atomic(p);
 			memcpy(buf, map + offset, length);
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 		} else
 			memset(buf, 0, length);
 
@@ -1882,9 +1882,9 @@ static int aligned_vwrite(char *buf, char *addr, unsigned long count)
 			 * we can expect USER0 is not used (see vread/vwrite's
 			 * function description)
 			 */
-			void *map = kmap_atomic(p, KM_USER0);
+			void *map = kmap_atomic(p);
 			memcpy(map + offset, buf, length);
-			kunmap_atomic(map, KM_USER0);
+			kunmap_atomic(map);
 		}
 		addr += length;
 		buf += length;
diff --git a/net/core/kmap_skb.h b/net/core/kmap_skb.h
index 283c2b9..daeb222 100644
--- a/net/core/kmap_skb.h
+++ b/net/core/kmap_skb.h
@@ -7,12 +7,12 @@ static inline void *kmap_skb_frag(const skb_frag_t *frag)
 
 	local_bh_disable();
 #endif
-	return kmap_atomic(frag->page, KM_SKB_DATA_SOFTIRQ);
+	return kmap_atomic(frag->page);
 }
 
 static inline void kunmap_skb_frag(void *vaddr)
 {
-	kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
+	kunmap_atomic(vaddr);
 #ifdef CONFIG_HIGHMEM
 	local_bh_enable();
 #endif
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index e29e0ca..8981665 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -763,7 +763,7 @@ static void rds_ib_cong_recv(struct rds_connection *conn,
 		to_copy = min(RDS_FRAG_SIZE - frag_off, PAGE_SIZE - map_off);
 		BUG_ON(to_copy & 7); /* Must be 64bit aligned. */
 
-		addr = kmap_atomic(sg_page(&frag->f_sg), KM_SOFTIRQ0);
+		addr = kmap_atomic(sg_page(&frag->f_sg));
 
 		src = addr + frag_off;
 		dst = (void *)map->m_page_addrs[map_page] + map_off;
@@ -773,7 +773,7 @@ static void rds_ib_cong_recv(struct rds_connection *conn,
 			uncongested |= ~(*src) & *dst;
 			*dst++ = *src++;
 		}
-		kunmap_atomic(addr, KM_SOFTIRQ0);
+		kunmap_atomic(addr);
 
 		copied += to_copy;
 
diff --git a/net/rds/info.c b/net/rds/info.c
index 4fdf1b6..6beb4f8 100644
--- a/net/rds/info.c
+++ b/net/rds/info.c
@@ -103,7 +103,7 @@ EXPORT_SYMBOL_GPL(rds_info_deregister_func);
 void rds_info_iter_unmap(struct rds_info_iterator *iter)
 {
 	if (iter->addr) {
-		kunmap_atomic(iter->addr, KM_USER0);
+		kunmap_atomic(iter->addr);
 		iter->addr = NULL;
 	}
 }
@@ -118,7 +118,7 @@ void rds_info_copy(struct rds_info_iterator *iter, void *data,
 
 	while (bytes) {
 		if (!iter->addr)
-			iter->addr = kmap_atomic(*iter->pages, KM_USER0);
+			iter->addr = kmap_atomic(*iter->pages);
 
 		this = min(bytes, PAGE_SIZE - iter->offset);
 
@@ -133,7 +133,7 @@ void rds_info_copy(struct rds_info_iterator *iter, void *data,
 		iter->offset += this;
 
 		if (iter->offset == PAGE_SIZE) {
-			kunmap_atomic(iter->addr, KM_USER0);
+			kunmap_atomic(iter->addr);
 			iter->addr = NULL;
 			iter->offset = 0;
 			iter->pages++;
diff --git a/net/rds/iw_recv.c b/net/rds/iw_recv.c
index 5e57347..3b53f34 100644
--- a/net/rds/iw_recv.c
+++ b/net/rds/iw_recv.c
@@ -598,7 +598,7 @@ static void rds_iw_cong_recv(struct rds_connection *conn,
 		to_copy = min(RDS_FRAG_SIZE - frag_off, PAGE_SIZE - map_off);
 		BUG_ON(to_copy & 7); /* Must be 64bit aligned. */
 
-		addr = kmap_atomic(frag->f_page, KM_SOFTIRQ0);
+		addr = kmap_atomic(frag->f_page);
 
 		src = addr + frag_off;
 		dst = (void *)map->m_page_addrs[map_page] + map_off;
@@ -608,7 +608,7 @@ static void rds_iw_cong_recv(struct rds_connection *conn,
 			uncongested |= ~(*src) & *dst;
 			*dst++ = *src++;
 		}
-		kunmap_atomic(addr, KM_SOFTIRQ0);
+		kunmap_atomic(addr);
 
 		copied += to_copy;
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 2763e3e..38f388c 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -82,9 +82,9 @@ gss_krb5_remove_padding(struct xdr_buf *buf, int blocksize)
 					>>PAGE_CACHE_SHIFT;
 		unsigned int offset = (buf->page_base + len - 1)
 					& (PAGE_CACHE_SIZE - 1);
-		ptr = kmap_atomic(buf->pages[last], KM_USER0);
+		ptr = kmap_atomic(buf->pages[last]);
 		pad = *(ptr + offset);
-		kunmap_atomic(ptr, KM_USER0);
+		kunmap_atomic(ptr);
 		goto out;
 	} else
 		len -= buf->page_len;
diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index 10b4319..fabc22d 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -113,7 +113,7 @@ ssize_t xdr_partial_copy_from_skb(struct xdr_buf *xdr, unsigned int base, struct
 		}
 
 		len = PAGE_CACHE_SIZE;
-		kaddr = kmap_atomic(*ppage, KM_SKB_SUNRPC_DATA);
+		kaddr = kmap_atomic(*ppage);
 		if (base) {
 			len -= base;
 			if (pglen < len)
@@ -126,7 +126,7 @@ ssize_t xdr_partial_copy_from_skb(struct xdr_buf *xdr, unsigned int base, struct
 			ret = copy_actor(desc, kaddr, len);
 		}
 		flush_dcache_page(*ppage);
-		kunmap_atomic(kaddr, KM_SKB_SUNRPC_DATA);
+		kunmap_atomic(kaddr);
 		copied += ret;
 		if (ret != len || !desc->count)
 			goto out;
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 277ebd4..c04aff8 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -122,9 +122,9 @@ xdr_terminate_string(struct xdr_buf *buf, const u32 len)
 {
 	char *kaddr;
 
-	kaddr = kmap_atomic(buf->pages[0], KM_USER0);
+	kaddr = kmap_atomic(buf->pages[0]);
 	kaddr[buf->page_base + len] = '\0';
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 EXPORT_SYMBOL_GPL(xdr_terminate_string);
 
@@ -232,12 +232,12 @@ _shift_data_right_pages(struct page **pages, size_t pgto_base,
 		pgto_base -= copy;
 		pgfrom_base -= copy;
 
-		vto = kmap_atomic(*pgto, KM_USER0);
-		vfrom = kmap_atomic(*pgfrom, KM_USER1);
+		vto = kmap_atomic(*pgto);
+		vfrom = kmap_atomic(*pgfrom);
 		memmove(vto + pgto_base, vfrom + pgfrom_base, copy);
 		flush_dcache_page(*pgto);
-		kunmap_atomic(vfrom, KM_USER1);
-		kunmap_atomic(vto, KM_USER0);
+		kunmap_atomic(vfrom);
+		kunmap_atomic(vto);
 
 	} while ((len -= copy) != 0);
 }
@@ -267,9 +267,9 @@ _copy_to_pages(struct page **pages, size_t pgbase, const char *p, size_t len)
 		if (copy > len)
 			copy = len;
 
-		vto = kmap_atomic(*pgto, KM_USER0);
+		vto = kmap_atomic(*pgto);
 		memcpy(vto + pgbase, p, copy);
-		kunmap_atomic(vto, KM_USER0);
+		kunmap_atomic(vto);
 
 		len -= copy;
 		if (len == 0)
@@ -311,9 +311,9 @@ _copy_from_pages(char *p, struct page **pages, size_t pgbase, size_t len)
 		if (copy > len)
 			copy = len;
 
-		vfrom = kmap_atomic(*pgfrom, KM_USER0);
+		vfrom = kmap_atomic(*pgfrom);
 		memcpy(p, vfrom + pgbase, copy);
-		kunmap_atomic(vfrom, KM_USER0);
+		kunmap_atomic(vfrom);
 
 		pgbase += copy;
 		if (pgbase == PAGE_CACHE_SIZE) {
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 554d081..1776e57 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -338,9 +338,9 @@ rpcrdma_inline_pullup(struct rpc_rqst *rqst, int pad)
 			curlen = copy_len;
 		dprintk("RPC:       %s: page %d destp 0x%p len %d curlen %d\n",
 			__func__, i, destp, copy_len, curlen);
-		srcp = kmap_atomic(ppages[i], KM_SKB_SUNRPC_DATA);
+		srcp = kmap_atomic(ppages[i]);
 		memcpy(destp, srcp+page_base, curlen);
-		kunmap_atomic(srcp, KM_SKB_SUNRPC_DATA);
+		kunmap_atomic(srcp);
 		rqst->rq_svec[0].iov_len += curlen;
 		destp += curlen;
 		copy_len -= curlen;
@@ -639,10 +639,10 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 			dprintk("RPC:       %s: page %d"
 				" srcp 0x%p len %d curlen %d\n",
 				__func__, i, srcp, copy_len, curlen);
-			destp = kmap_atomic(ppages[i], KM_SKB_SUNRPC_DATA);
+			destp = kmap_atomic(ppages[i]);
 			memcpy(destp + page_base, srcp, curlen);
 			flush_dcache_page(ppages[i]);
-			kunmap_atomic(destp, KM_SKB_SUNRPC_DATA);
+			kunmap_atomic(destp);
 			srcp += curlen;
 			copy_len -= curlen;
 			if (copy_len == 0)
diff --git a/security/tomoyo/domain.c b/security/tomoyo/domain.c
index cd0f92d..3543614 100644
--- a/security/tomoyo/domain.c
+++ b/security/tomoyo/domain.c
@@ -752,11 +752,11 @@ bool tomoyo_dump_page(struct linux_binprm *bprm, unsigned long pos,
 		 * But remove_arg_zero() uses kmap_atomic()/kunmap_atomic().
 		 * So do I.
 		 */
-		char *kaddr = kmap_atomic(page, KM_USER0);
+		char *kaddr = kmap_atomic(page);
 		dump->page = page;
 		memcpy(dump->data + offset, kaddr + offset,
 		       PAGE_SIZE - offset);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 	/* Same with put_arg_page(page) in fs/exec.c */
 #ifdef CONFIG_MMU
-- 
1.7.2.3



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
