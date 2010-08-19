Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BA1946B01FF
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:30:30 -0400 (EDT)
Message-Id: <20100819202753.773618082@chello.nl>
Date: Thu, 19 Aug 2010 22:13:21 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 4/6] mm: Remove all KM_type arguments
References: <20100819201317.673172547@chello.nl>
Content-Disposition: inline; filename=kmap-auto.patch
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <rmk@arm.linux.org.uk>, David Howells <dhowells@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, David Miller <davem@davemloft.net>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Do the bulk of the km_type and KM_type removement by script.

git grep -l -e km_type -e KM_ | grep -v xfs | while read file; 
do
	quilt add $file;
        sed -i -e 's/,[[:space:]]*enum km_type type[[:space:]]*//g'         \
               -e 's/,[[:space:]]*KM_[[:digit:][:upper:]_]*[[:space:]]*//g' \
            $file;
done

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/arm/include/asm/highmem.h            |    6 -
 arch/arm/include/asm/pgtable.h            |    8 +-
 arch/arm/mm/copypage-fa.c                 |   12 +--
 arch/arm/mm/copypage-feroceon.c           |   12 +--
 arch/arm/mm/copypage-v3.c                 |   12 +--
 arch/arm/mm/copypage-v4mc.c               |    8 +-
 arch/arm/mm/copypage-v4wb.c               |   12 +--
 arch/arm/mm/copypage-v4wt.c               |   12 +--
 arch/arm/mm/copypage-v6.c                 |   12 +--
 arch/arm/mm/copypage-xsc3.c               |   12 +--
 arch/arm/mm/copypage-xscale.c             |    8 +-
 arch/arm/mm/highmem.c                     |    6 -
 arch/frv/include/asm/highmem.h            |    4 -
 arch/frv/include/asm/pgtable.h            |    8 +-
 arch/frv/mm/highmem.c                     |    4 -
 arch/microblaze/include/asm/pgtable.h     |    8 +-
 arch/mips/include/asm/highmem.h           |    6 -
 arch/mips/mm/c-r4k.c                      |    4 -
 arch/mips/mm/highmem.c                    |    6 -
 arch/mips/mm/init.c                       |    8 +-
 arch/mn10300/include/asm/highmem.h        |    4 -
 arch/powerpc/include/asm/highmem.h        |    6 -
 arch/powerpc/include/asm/pgtable-ppc32.h  |    8 +-
 arch/powerpc/kvm/book3s.c                 |    4 -
 arch/powerpc/mm/dma-noncoherent.c         |    2 
 arch/powerpc/mm/highmem.c                 |    4 -
 arch/powerpc/mm/mem.c                     |    4 -
 arch/s390/crypto/des_s390.c               |    8 +-
 arch/sh/mm/cache-sh4.c                    |    4 -
 arch/sh/mm/cache.c                        |   12 +--
 arch/sparc/include/asm/highmem.h          |    4 -
 arch/sparc/mm/highmem.c                   |    4 -
 arch/tile/include/asm/highmem.h           |   10 +--
 arch/tile/include/asm/pgtable.h           |    8 +-
 arch/tile/kernel/machine_kexec.c          |    6 -
 arch/tile/mm/highmem.c                    |   12 +--
 arch/tile/mm/pgtable.c                    |    2 
 arch/um/kernel/skas/uaccess.c             |    4 -
 arch/x86/include/asm/highmem.h            |   10 +--
 arch/x86/include/asm/iomap.h              |    4 -
 arch/x86/include/asm/pgtable_32.h         |    4 -
 arch/x86/kernel/crash_dump_32.c           |    8 +-
 arch/x86/kvm/lapic.c                      |    8 +-
 arch/x86/kvm/paging_tmpl.h                |    4 -
 arch/x86/kvm/x86.c                        |    8 +-
 arch/x86/lib/usercopy_32.c                |    4 -
 arch/x86/mm/highmem_32.c                  |    8 +-
 arch/x86/mm/iomap_32.c                    |    6 -
 crypto/async_tx/async_memcpy.c            |    8 +-
 drivers/ata/libata-sff.c                  |    8 +-
 drivers/block/brd.c                       |   20 +++---
 drivers/block/drbd/drbd_bitmap.c          |   30 ++++-----
 drivers/block/drbd/drbd_nl.c              |    4 -
 drivers/block/loop.c                      |   16 ++---
 drivers/block/pktcdvd.c                   |    8 +-
 drivers/crypto/hifn_795x.c                |   10 +--
 drivers/edac/edac_mc.c                    |    4 -
 drivers/gpu/drm/drm_cache.c               |    8 +-
 drivers/gpu/drm/i915/i915_debugfs.c       |    4 -
 drivers/gpu/drm/i915/i915_gem.c           |   22 +++----
 drivers/gpu/drm/i915/i915_gem_debug.c     |   10 +--
 drivers/gpu/drm/i915/i915_irq.c           |    4 -
 drivers/gpu/drm/i915/intel_overlay.c      |    2 
 drivers/gpu/drm/nouveau/nouveau_bios.c    |    8 +-
 drivers/gpu/drm/ttm/ttm_bo_util.c         |    8 +-
 drivers/gpu/drm/ttm/ttm_tt.c              |   16 ++---
 drivers/gpu/drm/vmwgfx/vmwgfx_gmr.c       |    6 -
 drivers/ide/ide-taskfile.c                |    4 -
 drivers/infiniband/ulp/iser/iser_memory.c |    8 +-
 drivers/md/bitmap.c                       |   36 +++++------
 drivers/media/video/ivtv/ivtv-udma.c      |    4 -
 drivers/memstick/host/jmb38x_ms.c         |    4 -
 drivers/memstick/host/tifm_ms.c           |    4 -
 drivers/mmc/host/at91_mci.c               |    8 +-
 drivers/mmc/host/msm_sdcc.c               |    2 
 drivers/mmc/host/sdhci.c                  |    4 -
 drivers/mmc/host/tifm_sd.c                |   16 ++---
 drivers/mmc/host/tmio_mmc.h               |    4 -
 drivers/net/cassini.c                     |    4 -
 drivers/net/e1000e/netdev.c               |    4 -
 drivers/scsi/arcmsr/arcmsr_hba.c          |    8 +-
 drivers/scsi/cxgb3i/cxgb3i_pdu.c          |    2 
 drivers/scsi/fcoe/fcoe.c                  |    6 -
 drivers/scsi/gdth.c                       |    4 -
 drivers/scsi/ips.c                        |    6 -
 drivers/scsi/libfc/fc_fcp.c               |    8 +-
 drivers/scsi/libfc/fc_lport.c             |    2 
 drivers/scsi/libiscsi_tcp.c               |    4 -
 drivers/scsi/libsas/sas_host_smp.c        |    8 +-
 drivers/scsi/megaraid.c                   |    4 -
 drivers/scsi/mvsas/mv_sas.c               |    8 +-
 drivers/scsi/scsi_debug.c                 |   24 +++----
 drivers/scsi/scsi_lib.c                   |    4 -
 drivers/scsi/sd_dif.c                     |   12 +--
 drivers/staging/hv/netvsc_drv.c           |    2 
 drivers/staging/hv/rndis_filter.c         |    4 -
 drivers/staging/hv/storvsc_drv.c          |   18 ++---
 drivers/staging/pohmelfs/inode.c          |    8 +-
 drivers/staging/zram/xvmalloc.c           |   34 +++++-----
 drivers/staging/zram/zram_drv.c           |   38 ++++++------
 drivers/vhost/vhost.c                     |    4 -
 fs/afs/fsclient.c                         |    8 +-
 fs/afs/mntpt.c                            |    4 -
 fs/aio.c                                  |   24 +++----
 fs/bio-integrity.c                        |   10 +--
 fs/btrfs/compression.c                    |    8 +-
 fs/btrfs/ctree.c                          |   30 ++++-----
 fs/btrfs/ctree.h                          |    8 +-
 fs/btrfs/disk-io.c                        |    4 -
 fs/btrfs/extent_io.c                      |   56 ++++++++---------
 fs/btrfs/file-item.c                      |   10 +--
 fs/btrfs/inode.c                          |   26 ++++----
 fs/btrfs/struct-funcs.c                   |   10 +--
 fs/btrfs/zlib.c                           |    8 +-
 fs/cifs/file.c                            |    4 -
 fs/ecryptfs/mmap.c                        |    4 -
 fs/ecryptfs/read_write.c                  |    8 +-
 fs/exec.c                                 |    4 -
 fs/exofs/dir.c                            |    4 -
 fs/ext2/dir.c                             |    4 -
 fs/fuse/dev.c                             |    8 +-
 fs/fuse/file.c                            |    4 -
 fs/gfs2/aops.c                            |   12 +--
 fs/gfs2/lops.c                            |    8 +-
 fs/gfs2/quota.c                           |    4 -
 fs/jbd/journal.c                          |   12 +--
 fs/jbd/transaction.c                      |    4 -
 fs/jbd2/commit.c                          |    4 -
 fs/jbd2/journal.c                         |   12 +--
 fs/jbd2/transaction.c                     |    4 -
 fs/logfs/dir.c                            |   18 ++---
 fs/logfs/readwrite.c                      |   38 ++++++------
 fs/logfs/segment.c                        |    4 -
 fs/minix/dir.c                            |    4 -
 fs/namei.c                                |    4 -
 fs/nfs/dir.c                              |    4 -
 fs/nfs/nfs2xdr.c                          |    8 +-
 fs/nfs/nfs3xdr.c                          |    8 +-
 fs/nfs/nfs4proc.c                         |    4 -
 fs/nfs/nfs4xdr.c                          |   10 +--
 fs/nilfs2/cpfile.c                        |   94 +++++++++++++++---------------
 fs/nilfs2/dat.c                           |   38 ++++++------
 fs/nilfs2/dir.c                           |    4 -
 fs/nilfs2/ifile.c                         |    4 -
 fs/nilfs2/mdt.c                           |    4 -
 fs/nilfs2/page.c                          |    8 +-
 fs/nilfs2/recovery.c                      |    4 -
 fs/nilfs2/segbuf.c                        |    4 -
 fs/nilfs2/segment.c                       |    4 -
 fs/nilfs2/sufile.c                        |   58 +++++++++---------
 fs/ntfs/aops.c                            |   20 +++---
 fs/ntfs/attrib.c                          |   20 +++---
 fs/ntfs/file.c                            |   16 ++---
 fs/ntfs/super.c                           |    8 +-
 fs/ocfs2/aops.c                           |   16 ++---
 fs/pipe.c                                 |    8 +-
 fs/reiserfs/stree.c                       |    4 -
 fs/reiserfs/tail_conversion.c             |    4 -
 fs/splice.c                               |    4 -
 fs/squashfs/file.c                        |    8 +-
 fs/squashfs/symlink.c                     |    4 -
 fs/ubifs/file.c                           |    4 -
 fs/udf/file.c                             |    4 -
 include/linux/bio.h                       |    4 -
 include/linux/highmem.h                   |   28 ++++----
 kernel/debug/kdb/kdb_support.c            |    4 -
 kernel/power/snapshot.c                   |   28 ++++----
 lib/scatterlist.c                         |    4 -
 lib/swiotlb.c                             |    2 
 mm/bounce.c                               |    4 -
 mm/filemap.c                              |    8 +-
 mm/ksm.c                                  |   12 +--
 mm/memory.c                               |    4 -
 mm/shmem.c                                |   14 ++--
 mm/swapfile.c                             |   30 ++++-----
 mm/vmalloc.c                              |    8 +-
 net/core/kmap_skb.h                       |    4 -
 net/rds/ib_recv.c                         |   12 +--
 net/rds/info.c                            |    6 -
 net/rds/iw_recv.c                         |    4 -
 net/rds/loop.c                            |    2 
 net/rds/page.c                            |    4 -
 net/rds/tcp_recv.c                        |    4 -
 net/sunrpc/auth_gss/gss_krb5_wrap.c       |    4 -
 net/sunrpc/socklib.c                      |    4 -
 net/sunrpc/xdr.c                          |   16 ++---
 net/sunrpc/xprtrdma/rpc_rdma.c            |    4 -
 187 files changed, 904 insertions(+), 904 deletions(-)

Index: linux-2.6/arch/arm/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/arm/include/asm/highmem.h
+++ linux-2.6/arch/arm/include/asm/highmem.h
@@ -35,9 +35,9 @@ extern void kunmap_high_l1_vipt(struct p
 #ifdef CONFIG_HIGHMEM
 extern void *kmap(struct page *page);
 extern void kunmap(struct page *page);
-extern void *kmap_atomic(struct page *page, enum km_type type);
-extern void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
-extern void *kmap_atomic_pfn(unsigned long pfn, enum km_type type);
+extern void *kmap_atomic(struct page *page);
+extern void kunmap_atomic_notypecheck(void *kvaddr);
+extern void *kmap_atomic_pfn(unsigned long pfn);
 extern struct page *kmap_atomic_to_page(const void *ptr);
 #endif
 
Index: linux-2.6/arch/arm/include/asm/pgtable.h
===================================================================
--- linux-2.6.orig/arch/arm/include/asm/pgtable.h
+++ linux-2.6/arch/arm/include/asm/pgtable.h
@@ -263,10 +263,10 @@ extern struct page *empty_zero_page;
 #define pte_page(pte)		(pfn_to_page(pte_pfn(pte)))
 #define pte_offset_kernel(dir,addr)	(pmd_page_vaddr(*(dir)) + __pte_index(addr))
 
-#define pte_offset_map(dir,addr)	(__pte_map(dir, KM_PTE0) + __pte_index(addr))
-#define pte_offset_map_nested(dir,addr)	(__pte_map(dir, KM_PTE1) + __pte_index(addr))
-#define pte_unmap(pte)			__pte_unmap(pte, KM_PTE0)
-#define pte_unmap_nested(pte)		__pte_unmap(pte, KM_PTE1)
+#define pte_offset_map(dir,addr)	(__pte_map(dir) + __pte_index(addr))
+#define pte_offset_map_nested(dir,addr)	(__pte_map(dir) + __pte_index(addr))
+#define pte_unmap(pte)			__pte_unmap(pte)
+#define pte_unmap_nested(pte)		__pte_unmap(pte)
 
 #ifndef CONFIG_HIGHPTE
 #define __pte_map(dir,km)	pmd_page_vaddr(*(dir))
Index: linux-2.6/arch/arm/mm/copypage-fa.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/copypage-fa.c
+++ linux-2.6/arch/arm/mm/copypage-fa.c
@@ -44,11 +44,11 @@ void fa_copy_user_highpage(struct page *
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
@@ -58,7 +58,7 @@ void fa_copy_user_highpage(struct page *
  */
 void fa_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile("\
 	mov	r1, %2				@ 1\n\
 	mov	r2, #0				@ 1\n\
@@ -77,7 +77,7 @@ void fa_clear_user_highpage(struct page 
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 32)
 	: "r1", "r2", "r3", "ip", "lr");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns fa_user_fns __initdata = {
Index: linux-2.6/arch/arm/mm/copypage-feroceon.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/copypage-feroceon.c
+++ linux-2.6/arch/arm/mm/copypage-feroceon.c
@@ -72,17 +72,17 @@ void feroceon_copy_user_highpage(struct 
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
@@ -102,7 +102,7 @@ void feroceon_clear_user_highpage(struct
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 32)
 	: "r1", "r2", "r3", "r4", "r5", "r6", "r7", "ip", "lr");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns feroceon_user_fns __initdata = {
Index: linux-2.6/arch/arm/mm/copypage-v3.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/copypage-v3.c
+++ linux-2.6/arch/arm/mm/copypage-v3.c
@@ -42,11 +42,11 @@ void v3_copy_user_highpage(struct page *
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
@@ -56,7 +56,7 @@ void v3_copy_user_highpage(struct page *
  */
 void v3_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile("\n\
 	mov	r1, %2				@ 1\n\
 	mov	r2, #0				@ 1\n\
@@ -72,7 +72,7 @@ void v3_clear_user_highpage(struct page 
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 64)
 	: "r1", "r2", "r3", "ip", "lr");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns v3_user_fns __initdata = {
Index: linux-2.6/arch/arm/mm/copypage-v4mc.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/copypage-v4mc.c
+++ linux-2.6/arch/arm/mm/copypage-v4mc.c
@@ -71,7 +71,7 @@ mc_copy_user_page(void *from, void *to)
 void v4_mc_copy_user_highpage(struct page *to, struct page *from,
 	unsigned long vaddr, struct vm_area_struct *vma)
 {
-	void *kto = kmap_atomic(to, KM_USER1);
+	void *kto = kmap_atomic(to);
 
 	if (test_and_clear_bit(PG_dcache_dirty, &from->flags))
 		__flush_dcache_page(page_mapping(from), from);
@@ -85,7 +85,7 @@ void v4_mc_copy_user_highpage(struct pag
 
 	spin_unlock(&minicache_lock);
 
-	kunmap_atomic(kto, KM_USER1);
+	kunmap_atomic(kto);
 }
 
 /*
@@ -93,7 +93,7 @@ void v4_mc_copy_user_highpage(struct pag
  */
 void v4_mc_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile("\
 	mov	r1, %2				@ 1\n\
 	mov	r2, #0				@ 1\n\
@@ -111,7 +111,7 @@ void v4_mc_clear_user_highpage(struct pa
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 64)
 	: "r1", "r2", "r3", "ip", "lr");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns v4_mc_user_fns __initdata = {
Index: linux-2.6/arch/arm/mm/copypage-v4wb.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/copypage-v4wb.c
+++ linux-2.6/arch/arm/mm/copypage-v4wb.c
@@ -52,12 +52,12 @@ void v4wb_copy_user_highpage(struct page
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
@@ -67,7 +67,7 @@ void v4wb_copy_user_highpage(struct page
  */
 void v4wb_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile("\
 	mov	r1, %2				@ 1\n\
 	mov	r2, #0				@ 1\n\
@@ -86,7 +86,7 @@ void v4wb_clear_user_highpage(struct pag
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 64)
 	: "r1", "r2", "r3", "ip", "lr");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns v4wb_user_fns __initdata = {
Index: linux-2.6/arch/arm/mm/copypage-v4wt.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/copypage-v4wt.c
+++ linux-2.6/arch/arm/mm/copypage-v4wt.c
@@ -48,11 +48,11 @@ void v4wt_copy_user_highpage(struct page
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
@@ -62,7 +62,7 @@ void v4wt_copy_user_highpage(struct page
  */
 void v4wt_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile("\
 	mov	r1, %2				@ 1\n\
 	mov	r2, #0				@ 1\n\
@@ -79,7 +79,7 @@ void v4wt_clear_user_highpage(struct pag
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 64)
 	: "r1", "r2", "r3", "ip", "lr");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns v4wt_user_fns __initdata = {
Index: linux-2.6/arch/arm/mm/copypage-v6.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/copypage-v6.c
+++ linux-2.6/arch/arm/mm/copypage-v6.c
@@ -38,12 +38,12 @@ static void v6_copy_user_highpage_nonali
 {
 	void *kto, *kfrom;
 
-	kfrom = kmap_atomic(from, KM_USER0);
-	kto = kmap_atomic(to, KM_USER1);
+	kfrom = kmap_atomic(from);
+	kto = kmap_atomic(to);
 	copy_page(kto, kfrom);
 	__cpuc_flush_dcache_area(kto, PAGE_SIZE);
-	kunmap_atomic(kto, KM_USER1);
-	kunmap_atomic(kfrom, KM_USER0);
+	kunmap_atomic(kto);
+	kunmap_atomic(kfrom);
 }
 
 /*
@@ -52,9 +52,9 @@ static void v6_copy_user_highpage_nonali
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
Index: linux-2.6/arch/arm/mm/copypage-xsc3.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/copypage-xsc3.c
+++ linux-2.6/arch/arm/mm/copypage-xsc3.c
@@ -75,12 +75,12 @@ void xsc3_mc_copy_user_highpage(struct p
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
@@ -90,7 +90,7 @@ void xsc3_mc_copy_user_highpage(struct p
  */
 void xsc3_mc_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile ("\
 	mov	r1, %2				\n\
 	mov	r2, #0				\n\
@@ -105,7 +105,7 @@ void xsc3_mc_clear_user_highpage(struct 
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 32)
 	: "r1", "r2", "r3");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns xsc3_mc_user_fns __initdata = {
Index: linux-2.6/arch/arm/mm/copypage-xscale.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/copypage-xscale.c
+++ linux-2.6/arch/arm/mm/copypage-xscale.c
@@ -93,7 +93,7 @@ mc_copy_user_page(void *from, void *to)
 void xscale_mc_copy_user_highpage(struct page *to, struct page *from,
 	unsigned long vaddr, struct vm_area_struct *vma)
 {
-	void *kto = kmap_atomic(to, KM_USER1);
+	void *kto = kmap_atomic(to);
 
 	if (test_and_clear_bit(PG_dcache_dirty, &from->flags))
 		__flush_dcache_page(page_mapping(from), from);
@@ -107,7 +107,7 @@ void xscale_mc_copy_user_highpage(struct
 
 	spin_unlock(&minicache_lock);
 
-	kunmap_atomic(kto, KM_USER1);
+	kunmap_atomic(kto);
 }
 
 /*
@@ -116,7 +116,7 @@ void xscale_mc_copy_user_highpage(struct
 void
 xscale_mc_clear_user_highpage(struct page *page, unsigned long vaddr)
 {
-	void *ptr, *kaddr = kmap_atomic(page, KM_USER0);
+	void *ptr, *kaddr = kmap_atomic(page);
 	asm volatile(
 	"mov	r1, %2				\n\
 	mov	r2, #0				\n\
@@ -133,7 +133,7 @@ xscale_mc_clear_user_highpage(struct pag
 	: "=r" (ptr)
 	: "0" (kaddr), "I" (PAGE_SIZE / 32)
 	: "r1", "r2", "r3", "ip");
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 struct cpu_user_fns xscale_mc_user_fns __initdata = {
Index: linux-2.6/arch/arm/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/highmem.c
+++ linux-2.6/arch/arm/mm/highmem.c
@@ -36,7 +36,7 @@ void kunmap(struct page *page)
 }
 EXPORT_SYMBOL(kunmap);
 
-void *kmap_atomic(struct page *page, enum km_type type)
+void *kmap_atomic(struct page *page)
 {
 	unsigned int idx;
 	unsigned long vaddr;
@@ -84,7 +84,7 @@ void *kmap_atomic(struct page *page, enu
 }
 EXPORT_SYMBOL(kmap_atomic);
 
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
+void kunmap_atomic_notypecheck(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
 	unsigned int idx;
@@ -110,7 +110,7 @@ void kunmap_atomic_notypecheck(void *kva
 }
 EXPORT_SYMBOL(kunmap_atomic_notypecheck);
 
-void *kmap_atomic_pfn(unsigned long pfn, enum km_type type)
+void *kmap_atomic_pfn(unsigned long pfn)
 {
 	unsigned int idx;
 	unsigned long vaddr;
Index: linux-2.6/arch/frv/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/frv/include/asm/highmem.h
+++ linux-2.6/arch/frv/include/asm/highmem.h
@@ -124,8 +124,8 @@ do {									\
 	asm volatile("tlbpr %0,gr0,#4,#1" : : "r"(vaddr) : "memory");	\
 } while(0)
 
-void *kmap_atomic(struct page *page, enum km_type type);
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
+void *kmap_atomic(struct page *page);
+void kunmap_atomic_notypecheck(void *kvaddr);
 
 #endif /* !__ASSEMBLY__ */
 
Index: linux-2.6/arch/frv/include/asm/pgtable.h
===================================================================
--- linux-2.6.orig/arch/frv/include/asm/pgtable.h
+++ linux-2.6/arch/frv/include/asm/pgtable.h
@@ -451,11 +451,11 @@ static inline pte_t pte_modify(pte_t pte
 
 #if defined(CONFIG_HIGHPTE)
 #define pte_offset_map(dir, address) \
-	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE0) + pte_index(address))
+	((pte_t *)kmap_atomic(pmd_page(*(dir))) + pte_index(address))
 #define pte_offset_map_nested(dir, address) \
-	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE1) + pte_index(address))
-#define pte_unmap(pte) kunmap_atomic(pte, KM_PTE0)
-#define pte_unmap_nested(pte) kunmap_atomic((pte), KM_PTE1)
+	((pte_t *)kmap_atomic(pmd_page(*(dir))) + pte_index(address))
+#define pte_unmap(pte) kunmap_atomic(pte)
+#define pte_unmap_nested(pte) kunmap_atomic((pte))
 #else
 #define pte_offset_map(dir, address) \
 	((pte_t *)page_address(pmd_page(*(dir))) + pte_index(address))
Index: linux-2.6/arch/frv/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/frv/mm/highmem.c
+++ linux-2.6/arch/frv/mm/highmem.c
@@ -37,7 +37,7 @@ struct page *kmap_atomic_to_page(void *p
 	return virt_to_page(ptr);
 }
 
-void *kmap_atomic(struct page *page, enum km_type type)
+void *kmap_atomic(struct page *page)
 {
 	unsigned long paddr;
 
@@ -65,7 +65,7 @@ void *kmap_atomic(struct page *page, enu
 }
 EXPORT_SYMBOL(kmap_atomic);
 
-void kunmap_atomic(void *kvaddr, enum km_type type)
+void kunmap_atomic(void *kvaddr)
 {
 	type = kmap_atomic_idx_pop();
 	switch (type) {
Index: linux-2.6/arch/microblaze/include/asm/pgtable.h
===================================================================
--- linux-2.6.orig/arch/microblaze/include/asm/pgtable.h
+++ linux-2.6/arch/microblaze/include/asm/pgtable.h
@@ -497,12 +497,12 @@ static inline pmd_t *pmd_offset(pgd_t *d
 #define pte_offset_kernel(dir, addr)	\
 	((pte_t *) pmd_page_kernel(*(dir)) + pte_index(addr))
 #define pte_offset_map(dir, addr)		\
-	((pte_t *) kmap_atomic(pmd_page(*(dir)), KM_PTE0) + pte_index(addr))
+	((pte_t *) kmap_atomic(pmd_page(*(dir))) + pte_index(addr))
 #define pte_offset_map_nested(dir, addr)	\
-	((pte_t *) kmap_atomic(pmd_page(*(dir)), KM_PTE1) + pte_index(addr))
+	((pte_t *) kmap_atomic(pmd_page(*(dir))) + pte_index(addr))
 
-#define pte_unmap(pte)		kunmap_atomic(pte, KM_PTE0)
-#define pte_unmap_nested(pte)	kunmap_atomic(pte, KM_PTE1)
+#define pte_unmap(pte)		kunmap_atomic(pte)
+#define pte_unmap_nested(pte)	kunmap_atomic(pte)
 
 /* Encode and decode a nonlinear file mapping entry */
 #define PTE_FILE_MAX_BITS	29
Index: linux-2.6/arch/mips/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/mips/include/asm/highmem.h
+++ linux-2.6/arch/mips/include/asm/highmem.h
@@ -47,9 +47,9 @@ extern void kunmap_high(struct page *pag
 
 extern void *__kmap(struct page *page);
 extern void __kunmap(struct page *page);
-extern void *__kmap_atomic(struct page *page, enum km_type type);
-extern void __kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
-extern void *kmap_atomic_pfn(unsigned long pfn, enum km_type type);
+extern void *__kmap_atomic(struct page *page);
+extern void __kunmap_atomic_notypecheck(void *kvaddr);
+extern void *kmap_atomic_pfn(unsigned long pfn);
 extern struct page *__kmap_atomic_to_page(void *ptr);
 
 #define kmap			__kmap
Index: linux-2.6/arch/mips/mm/c-r4k.c
===================================================================
--- linux-2.6.orig/arch/mips/mm/c-r4k.c
+++ linux-2.6/arch/mips/mm/c-r4k.c
@@ -498,7 +498,7 @@ static inline void local_r4k_flush_cache
 		if (map_coherent)
 			vaddr = kmap_coherent(page, addr);
 		else
-			vaddr = kmap_atomic(page, KM_USER0);
+			vaddr = kmap_atomic(page);
 		addr = (unsigned long)vaddr;
 	}
 
@@ -521,7 +521,7 @@ static inline void local_r4k_flush_cache
 		if (map_coherent)
 			kunmap_coherent();
 		else
-			kunmap_atomic(vaddr, KM_USER0);
+			kunmap_atomic(vaddr);
 	}
 }
 
Index: linux-2.6/arch/mips/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/mips/mm/highmem.c
+++ linux-2.6/arch/mips/mm/highmem.c
@@ -41,7 +41,7 @@ EXPORT_SYMBOL(__kunmap);
  * kmaps are appropriate for short, tight code paths only.
  */
 
-void *__kmap_atomic(struct page *page, enum km_type type)
+void *__kmap_atomic(struct page *page)
 {
 	enum fixed_addresses idx;
 	unsigned long vaddr;
@@ -64,7 +64,7 @@ void *__kmap_atomic(struct page *page, e
 }
 EXPORT_SYMBOL(__kmap_atomic);
 
-void __kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
+void __kunmap_atomic_notypecheck(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
 	unsigned int idx;
@@ -95,7 +95,7 @@ EXPORT_SYMBOL(__kunmap_atomic);
  * This is the same as kmap_atomic() but can map memory that doesn't
  * have a struct page associated with it.
  */
-void *kmap_atomic_pfn(unsigned long pfn, enum km_type type)
+void *kmap_atomic_pfn(unsigned long pfn)
 {
 	enum fixed_addresses idx;
 	unsigned long vaddr;
Index: linux-2.6/arch/mips/mm/init.c
===================================================================
--- linux-2.6.orig/arch/mips/mm/init.c
+++ linux-2.6/arch/mips/mm/init.c
@@ -209,21 +209,21 @@ void copy_user_highpage(struct page *to,
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
Index: linux-2.6/arch/mn10300/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/mn10300/include/asm/highmem.h
+++ linux-2.6/arch/mn10300/include/asm/highmem.h
@@ -70,7 +70,7 @@ static inline void kunmap(struct page *p
  * be used in IRQ contexts, so in some (very limited) cases we need
  * it.
  */
-static inline unsigned long kmap_atomic(struct page *page, enum km_type type)
+static inline unsigned long kmap_atomic(struct page *page)
 {
 	enum fixed_addresses idx;
 	unsigned long vaddr;
@@ -92,7 +92,7 @@ static inline unsigned long kmap_atomic(
 	return vaddr;
 }
 
-static inline void kunmap_atomic_notypecheck(unsigned long vaddr, enum km_type type)
+static inline void kunmap_atomic_notypecheck(unsigned long vaddr)
 {
 	if (vaddr < FIXADDR_START) { /* FIXME */
 		pagefault_enable();
Index: linux-2.6/arch/powerpc/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/powerpc/include/asm/highmem.h
+++ linux-2.6/arch/powerpc/include/asm/highmem.h
@@ -60,9 +60,9 @@ extern pte_t *pkmap_page_table;
 
 extern void *kmap_high(struct page *page);
 extern void kunmap_high(struct page *page);
-extern void *kmap_atomic_prot(struct page *page, enum km_type type,
+extern void *kmap_atomic_prot(struct page *page,
 			      pgprot_t prot);
-extern void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
+extern void kunmap_atomic_notypecheck(void *kvaddr);
 
 static inline void *kmap(struct page *page)
 {
@@ -80,7 +80,7 @@ static inline void kunmap(struct page *p
 	kunmap_high(page);
 }
 
-static inline void *kmap_atomic(struct page *page, enum km_type type)
+static inline void *kmap_atomic(struct page *page)
 {
 	return kmap_atomic_prot(page, type, kmap_prot);
 }
Index: linux-2.6/arch/powerpc/include/asm/pgtable-ppc32.h
===================================================================
--- linux-2.6.orig/arch/powerpc/include/asm/pgtable-ppc32.h
+++ linux-2.6/arch/powerpc/include/asm/pgtable-ppc32.h
@@ -308,12 +308,12 @@ static inline void __ptep_set_access_fla
 #define pte_offset_kernel(dir, addr)	\
 	((pte_t *) pmd_page_vaddr(*(dir)) + pte_index(addr))
 #define pte_offset_map(dir, addr)		\
-	((pte_t *) kmap_atomic(pmd_page(*(dir)), KM_PTE0) + pte_index(addr))
+	((pte_t *) kmap_atomic(pmd_page(*(dir))) + pte_index(addr))
 #define pte_offset_map_nested(dir, addr)	\
-	((pte_t *) kmap_atomic(pmd_page(*(dir)), KM_PTE1) + pte_index(addr))
+	((pte_t *) kmap_atomic(pmd_page(*(dir))) + pte_index(addr))
 
-#define pte_unmap(pte)		kunmap_atomic(pte, KM_PTE0)
-#define pte_unmap_nested(pte)	kunmap_atomic(pte, KM_PTE1)
+#define pte_unmap(pte)		kunmap_atomic(pte)
+#define pte_unmap_nested(pte)	kunmap_atomic(pte)
 
 /*
  * Encode and decode a swap entry.
Index: linux-2.6/arch/powerpc/kvm/book3s.c
===================================================================
--- linux-2.6.orig/arch/powerpc/kvm/book3s.c
+++ linux-2.6/arch/powerpc/kvm/book3s.c
@@ -423,14 +423,14 @@ static void kvmppc_patch_dcbz(struct kvm
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
 
Index: linux-2.6/arch/powerpc/mm/dma-noncoherent.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/dma-noncoherent.c
+++ linux-2.6/arch/powerpc/mm/dma-noncoherent.c
@@ -369,7 +369,7 @@ static inline void __dma_sync_page_highm
 
 		/* Sync this buffer segment */
 		__dma_sync((void *)start, seg_size, direction);
-		kunmap_atomic((void *)start, KM_PPC_SYNC_PAGE);
+		kunmap_atomic((void *)start);
 		seg_nr++;
 
 		/* Calculate next buffer segment size */
Index: linux-2.6/arch/powerpc/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/highmem.c
+++ linux-2.6/arch/powerpc/mm/highmem.c
@@ -29,7 +29,7 @@
  * be used in IRQ contexts, so in some (very limited) cases we need
  * it.
  */
-void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot)
+void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 {
 	unsigned int idx;
 	unsigned long vaddr;
@@ -52,7 +52,7 @@ void *kmap_atomic_prot(struct page *page
 }
 EXPORT_SYMBOL(kmap_atomic_prot);
 
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
+void kunmap_atomic_notypecheck(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
 
Index: linux-2.6/arch/powerpc/mm/mem.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/mem.c
+++ linux-2.6/arch/powerpc/mm/mem.c
@@ -433,9 +433,9 @@ void flush_dcache_icache_page(struct pag
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
Index: linux-2.6/arch/s390/crypto/des_s390.c
===================================================================
--- linux-2.6.orig/arch/s390/crypto/des_s390.c
+++ linux-2.6/arch/s390/crypto/des_s390.c
@@ -143,7 +143,7 @@ static int ecb_des_encrypt(struct blkcip
 	struct blkcipher_walk walk;
 
 	blkcipher_walk_init(&walk, dst, src, nbytes);
-	return ecb_desall_crypt(desc, KM_DEA_ENCRYPT, sctx->key, &walk);
+	return ecb_desall_crypt(desc, sctx->key, &walk);
 }
 
 static int ecb_des_decrypt(struct blkcipher_desc *desc,
@@ -154,7 +154,7 @@ static int ecb_des_decrypt(struct blkcip
 	struct blkcipher_walk walk;
 
 	blkcipher_walk_init(&walk, dst, src, nbytes);
-	return ecb_desall_crypt(desc, KM_DEA_DECRYPT, sctx->key, &walk);
+	return ecb_desall_crypt(desc, sctx->key, &walk);
 }
 
 static struct crypto_alg ecb_des_alg = {
@@ -296,7 +296,7 @@ static int ecb_des3_192_encrypt(struct b
 	struct blkcipher_walk walk;
 
 	blkcipher_walk_init(&walk, dst, src, nbytes);
-	return ecb_desall_crypt(desc, KM_TDEA_192_ENCRYPT, sctx->key, &walk);
+	return ecb_desall_crypt(desc, sctx->key, &walk);
 }
 
 static int ecb_des3_192_decrypt(struct blkcipher_desc *desc,
@@ -307,7 +307,7 @@ static int ecb_des3_192_decrypt(struct b
 	struct blkcipher_walk walk;
 
 	blkcipher_walk_init(&walk, dst, src, nbytes);
-	return ecb_desall_crypt(desc, KM_TDEA_192_DECRYPT, sctx->key, &walk);
+	return ecb_desall_crypt(desc, sctx->key, &walk);
 }
 
 static struct crypto_alg ecb_des3_192_alg = {
Index: linux-2.6/arch/sh/mm/cache-sh4.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/cache-sh4.c
+++ linux-2.6/arch/sh/mm/cache-sh4.c
@@ -244,7 +244,7 @@ static void sh4_flush_cache_page(void *a
 		if (map_coherent)
 			vaddr = kmap_coherent(page, address);
 		else
-			vaddr = kmap_atomic(page, KM_USER0);
+			vaddr = kmap_atomic(page);
 
 		address = (unsigned long)vaddr;
 	}
@@ -259,7 +259,7 @@ static void sh4_flush_cache_page(void *a
 		if (map_coherent)
 			kunmap_coherent(vaddr);
 		else
-			kunmap_atomic(vaddr, KM_USER0);
+			kunmap_atomic(vaddr);
 	}
 }
 
Index: linux-2.6/arch/sh/mm/cache.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/cache.c
+++ linux-2.6/arch/sh/mm/cache.c
@@ -95,7 +95,7 @@ void copy_user_highpage(struct page *to,
 {
 	void *vfrom, *vto;
 
-	vto = kmap_atomic(to, KM_USER1);
+	vto = kmap_atomic(to);
 
 	if (boot_cpu_data.dcache.n_aliases && page_mapped(from) &&
 	    !test_bit(PG_dcache_dirty, &from->flags)) {
@@ -103,15 +103,15 @@ void copy_user_highpage(struct page *to,
 		copy_page(vto, vfrom);
 		kunmap_coherent(vfrom);
 	} else {
-		vfrom = kmap_atomic(from, KM_USER0);
+		vfrom = kmap_atomic(from);
 		copy_page(vto, vfrom);
-		kunmap_atomic(vfrom, KM_USER0);
+		kunmap_atomic(vfrom);
 	}
 
 	if (pages_do_alias((unsigned long)vto, vaddr & PAGE_MASK))
 		__flush_purge_region(vto, PAGE_SIZE);
 
-	kunmap_atomic(vto, KM_USER1);
+	kunmap_atomic(vto);
 	/* Make sure this page is cleared on other CPU's too before using it */
 	smp_wmb();
 }
@@ -119,14 +119,14 @@ EXPORT_SYMBOL(copy_user_highpage);
 
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
 
Index: linux-2.6/arch/sparc/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/highmem.h
+++ linux-2.6/arch/sparc/include/asm/highmem.h
@@ -70,8 +70,8 @@ static inline void kunmap(struct page *p
 	kunmap_high(page);
 }
 
-extern void *kmap_atomic(struct page *page, enum km_type type);
-extern void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
+extern void *kmap_atomic(struct page *page);
+extern void kunmap_atomic_notypecheck(void *kvaddr);
 extern struct page *kmap_atomic_to_page(void *vaddr);
 
 #define flush_cache_kmaps()	flush_cache_all()
Index: linux-2.6/arch/sparc/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/sparc/mm/highmem.c
+++ linux-2.6/arch/sparc/mm/highmem.c
@@ -29,7 +29,7 @@
 #include <asm/tlbflush.h>
 #include <asm/fixmap.h>
 
-void *kmap_atomic(struct page *page, enum km_type type)
+void *kmap_atomic(struct page *page)
 {
 	unsigned long idx;
 	unsigned long vaddr;
@@ -65,7 +65,7 @@ void *kmap_atomic(struct page *page, enu
 }
 EXPORT_SYMBOL(kmap_atomic);
 
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
+void kunmap_atomic_notypecheck(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
 
Index: linux-2.6/arch/tile/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/tile/include/asm/highmem.h
+++ linux-2.6/arch/tile/include/asm/highmem.h
@@ -60,12 +60,12 @@ void *kmap_fix_kpte(struct page *page, i
 /* This macro is used only in map_new_virtual() to map "page". */
 #define kmap_prot page_to_kpgprot(page)
 
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
-void *kmap_atomic_pfn(unsigned long pfn, enum km_type type);
-void *kmap_atomic_prot_pfn(unsigned long pfn, enum km_type type, pgprot_t prot);
+void kunmap_atomic_notypecheck(void *kvaddr);
+void *kmap_atomic_pfn(unsigned long pfn);
+void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot);
 struct page *kmap_atomic_to_page(void *ptr);
-void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot);
-void *kmap_atomic(struct page *page, enum km_type type);
+void *kmap_atomic_prot(struct page *page, pgprot_t prot);
+void *kmap_atomic(struct page *page);
 void kmap_atomic_fix_kpte(struct page *page, int finished);
 
 #define flush_cache_kmaps()	do { } while (0)
Index: linux-2.6/arch/tile/include/asm/pgtable.h
===================================================================
--- linux-2.6.orig/arch/tile/include/asm/pgtable.h
+++ linux-2.6/arch/tile/include/asm/pgtable.h
@@ -346,11 +346,11 @@ static inline pte_t pte_modify(pte_t pte
 #if defined(CONFIG_HIGHPTE)
 extern pte_t *_pte_offset_map(pmd_t *, unsigned long address, enum km_type);
 #define pte_offset_map(dir, address) \
-	_pte_offset_map(dir, address, KM_PTE0)
+	_pte_offset_map(dir, address)
 #define pte_offset_map_nested(dir, address) \
-	_pte_offset_map(dir, address, KM_PTE1)
-#define pte_unmap(pte) kunmap_atomic(pte, KM_PTE0)
-#define pte_unmap_nested(pte) kunmap_atomic(pte, KM_PTE1)
+	_pte_offset_map(dir, address)
+#define pte_unmap(pte) kunmap_atomic(pte)
+#define pte_unmap_nested(pte) kunmap_atomic(pte)
 #else
 #define pte_offset_map(dir, address) pte_offset_kernel(dir, address)
 #define pte_offset_map_nested(dir, address) pte_offset_map(dir, address)
Index: linux-2.6/arch/tile/kernel/machine_kexec.c
===================================================================
--- linux-2.6.orig/arch/tile/kernel/machine_kexec.c
+++ linux-2.6/arch/tile/kernel/machine_kexec.c
@@ -182,13 +182,13 @@ static void kexec_find_and_set_command_l
 
 		if ((entry & IND_SOURCE)) {
 			void *va =
-				kmap_atomic_pfn(entry >> PAGE_SHIFT, KM_USER0);
+				kmap_atomic_pfn(entry >> PAGE_SHIFT);
 			r = kexec_bn2cl(va);
 			if (r) {
 				command_line = r;
 				break;
 			}
-			kunmap_atomic(va, KM_USER0);
+			kunmap_atomic(va);
 		}
 	}
 
@@ -198,7 +198,7 @@ static void kexec_find_and_set_command_l
 
 		hverr = hv_set_command_line(
 			(HV_VirtAddr) command_line, strlen(command_line));
-		kunmap_atomic(command_line, KM_USER0);
+		kunmap_atomic(command_line);
 	} else {
 		pr_info("%s: no command line found; making empty\n",
 		       __func__);
Index: linux-2.6/arch/tile/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/tile/mm/highmem.c
+++ linux-2.6/arch/tile/mm/highmem.c
@@ -137,7 +137,7 @@ static DEFINE_PER_CPU(struct kmap_amps, 
  * If we examine it earlier we are exposed to a race where it looks
  * writable earlier, but becomes immutable before we write the PTE.
  */
-static void kmap_atomic_register(struct page *page, enum km_type type,
+static void kmap_atomic_register(struct page *page,
 				 unsigned long va, pte_t *ptep, pte_t pteval)
 {
 	unsigned long flags;
@@ -240,7 +240,7 @@ void kmap_atomic_fix_kpte(struct page *p
  * When holding an atomic kmap is is not legal to sleep, so atomic
  * kmaps are appropriate for short, tight code paths only.
  */
-void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot)
+void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 {
 	enum fixed_addresses idx;
 	unsigned long vaddr;
@@ -269,14 +269,14 @@ void *kmap_atomic_prot(struct page *page
 }
 EXPORT_SYMBOL(kmap_atomic_prot);
 
-void *kmap_atomic(struct page *page, enum km_type type)
+void *kmap_atomic(struct page *page)
 {
 	/* PAGE_NONE is a magic value that tells us to check immutability. */
 	return kmap_atomic_prot(page, type, PAGE_NONE);
 }
 EXPORT_SYMBOL(kmap_atomic);
 
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
+void kunmap_atomic_notypecheck(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
 	enum fixed_addresses idx = type + KM_TYPE_NR*smp_processor_id();
@@ -306,11 +306,11 @@ EXPORT_SYMBOL(kunmap_atomic_notypecheck)
  * This API is supposed to allow us to map memory without a "struct page".
  * Currently we don't support this, though this may change in the future.
  */
-void *kmap_atomic_pfn(unsigned long pfn, enum km_type type)
+void *kmap_atomic_pfn(unsigned long pfn)
 {
 	return kmap_atomic(pfn_to_page(pfn), type);
 }
-void *kmap_atomic_prot_pfn(unsigned long pfn, enum km_type type, pgprot_t prot)
+void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
 {
 	return kmap_atomic_prot(pfn_to_page(pfn), type, prot);
 }
Index: linux-2.6/arch/tile/mm/pgtable.c
===================================================================
--- linux-2.6.orig/arch/tile/mm/pgtable.c
+++ linux-2.6/arch/tile/mm/pgtable.c
@@ -134,7 +134,7 @@ void __set_fixmap(enum fixed_addresses i
 }
 
 #if defined(CONFIG_HIGHPTE)
-pte_t *_pte_offset_map(pmd_t *dir, unsigned long address, enum km_type type)
+pte_t *_pte_offset_map(pmd_t *dir, unsigned long address)
 {
 	pte_t *pte = kmap_atomic(pmd_page(*dir), type) +
 		(pmd_ptfn(*dir) << HV_LOG2_PAGE_TABLE_ALIGN) & ~PAGE_MASK;
Index: linux-2.6/arch/um/kernel/skas/uaccess.c
===================================================================
--- linux-2.6.orig/arch/um/kernel/skas/uaccess.c
+++ linux-2.6/arch/um/kernel/skas/uaccess.c
@@ -68,7 +68,7 @@ static int do_op_one_page(unsigned long 
 		return -1;
 
 	page = pte_page(*pte);
-	addr = (unsigned long) kmap_atomic(page, KM_UML_USERCOPY) +
+	addr = (unsigned long) kmap_atomic(page) +
 		(addr & ~PAGE_MASK);
 
 	current->thread.fault_catcher = &buf;
@@ -81,7 +81,7 @@ static int do_op_one_page(unsigned long 
 
 	current->thread.fault_catcher = NULL;
 
-	kunmap_atomic((void *)addr, KM_UML_USERCOPY);
+	kunmap_atomic((void *)addr);
 
 	return n;
 }
Index: linux-2.6/arch/x86/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/highmem.h
+++ linux-2.6/arch/x86/include/asm/highmem.h
@@ -59,11 +59,11 @@ extern void kunmap_high(struct page *pag
 
 void *kmap(struct page *page);
 void kunmap(struct page *page);
-void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot);
-void *kmap_atomic(struct page *page, enum km_type type);
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
-void *kmap_atomic_pfn(unsigned long pfn, enum km_type type);
-void *kmap_atomic_prot_pfn(unsigned long pfn, enum km_type type, pgprot_t prot);
+void *kmap_atomic_prot(struct page *page, pgprot_t prot);
+void *kmap_atomic(struct page *page);
+void kunmap_atomic_notypecheck(void *kvaddr);
+void *kmap_atomic_pfn(unsigned long pfn);
+void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot);
 struct page *kmap_atomic_to_page(void *ptr);
 
 #define flush_cache_kmaps()	do { } while (0)
Index: linux-2.6/arch/x86/include/asm/iomap.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/iomap.h
+++ linux-2.6/arch/x86/include/asm/iomap.h
@@ -27,10 +27,10 @@
 #include <asm/tlbflush.h>
 
 void *
-iomap_atomic_prot_pfn(unsigned long pfn, enum km_type type, pgprot_t prot);
+iomap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot);
 
 void
-iounmap_atomic(void *kvaddr, enum km_type type);
+iounmap_atomic(void *kvaddr);
 
 int
 iomap_create_wc(resource_size_t base, unsigned long size, pgprot_t *prot);
Index: linux-2.6/arch/x86/include/asm/pgtable_32.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/pgtable_32.h
+++ linux-2.6/arch/x86/include/asm/pgtable_32.h
@@ -57,10 +57,10 @@ extern void set_pmd_pfn(unsigned long, u
 	((pte_t *)kmap_atomic(pmd_page(*(dir)), __KM_PTE) +		\
 	 pte_index((address)))
 #define pte_offset_map_nested(dir, address)				\
-	((pte_t *)kmap_atomic(pmd_page(*(dir)), KM_PTE1) +		\
+	((pte_t *)kmap_atomic(pmd_page(*(dir))) +		\
 	 pte_index((address)))
 #define pte_unmap(pte) kunmap_atomic((pte), __KM_PTE)
-#define pte_unmap_nested(pte) kunmap_atomic((pte), KM_PTE1)
+#define pte_unmap_nested(pte) kunmap_atomic((pte))
 #else
 #define pte_offset_map(dir, address)					\
 	((pte_t *)page_address(pmd_page(*(dir))) + pte_index((address)))
Index: linux-2.6/arch/x86/kernel/crash_dump_32.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/crash_dump_32.c
+++ linux-2.6/arch/x86/kernel/crash_dump_32.c
@@ -61,20 +61,20 @@ ssize_t copy_oldmem_page(unsigned long p
 	if (!is_crashed_pfn_valid(pfn))
 		return -EFAULT;
 
-	vaddr = kmap_atomic_pfn(pfn, KM_PTE0);
+	vaddr = kmap_atomic_pfn(pfn);
 
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
Index: linux-2.6/arch/x86/kvm/lapic.c
===================================================================
--- linux-2.6.orig/arch/x86/kvm/lapic.c
+++ linux-2.6/arch/x86/kvm/lapic.c
@@ -1175,9 +1175,9 @@ void kvm_lapic_sync_from_vapic(struct kv
 	if (!irqchip_in_kernel(vcpu->kvm) || !vcpu->arch.apic->vapic_addr)
 		return;
 
-	vapic = kmap_atomic(vcpu->arch.apic->vapic_page, KM_USER0);
+	vapic = kmap_atomic(vcpu->arch.apic->vapic_page);
 	data = *(u32 *)(vapic + offset_in_page(vcpu->arch.apic->vapic_addr));
-	kunmap_atomic(vapic, KM_USER0);
+	kunmap_atomic(vapic);
 
 	apic_set_tpr(vcpu->arch.apic, data & 0xff);
 }
@@ -1202,9 +1202,9 @@ void kvm_lapic_sync_to_vapic(struct kvm_
 		max_isr = 0;
 	data = (tpr & 0xff) | ((max_isr & 0xf0) << 8) | (max_irr << 24);
 
-	vapic = kmap_atomic(vcpu->arch.apic->vapic_page, KM_USER0);
+	vapic = kmap_atomic(vcpu->arch.apic->vapic_page);
 	*(u32 *)(vapic + offset_in_page(vcpu->arch.apic->vapic_addr)) = data;
-	kunmap_atomic(vapic, KM_USER0);
+	kunmap_atomic(vapic);
 }
 
 void kvm_lapic_set_vapic_addr(struct kvm_vcpu *vcpu, gpa_t vapic_addr)
Index: linux-2.6/arch/x86/kvm/paging_tmpl.h
===================================================================
--- linux-2.6.orig/arch/x86/kvm/paging_tmpl.h
+++ linux-2.6/arch/x86/kvm/paging_tmpl.h
@@ -89,9 +89,9 @@ static bool FNAME(cmpxchg_gpte)(struct k
 
 	page = gfn_to_page(kvm, table_gfn);
 
-	table = kmap_atomic(page, KM_USER0);
+	table = kmap_atomic(page);
 	ret = CMPXCHG(&table[index], orig_pte, new_pte);
-	kunmap_atomic(table, KM_USER0);
+	kunmap_atomic(table);
 
 	kvm_release_page_dirty(page);
 
Index: linux-2.6/arch/x86/kvm/x86.c
===================================================================
--- linux-2.6.orig/arch/x86/kvm/x86.c
+++ linux-2.6/arch/x86/kvm/x86.c
@@ -934,12 +934,12 @@ static void kvm_write_guest_time(struct 
 	 */
 	vcpu->hv_clock.version += 2;
 
-	shared_kaddr = kmap_atomic(vcpu->time_page, KM_USER0);
+	shared_kaddr = kmap_atomic(vcpu->time_page);
 
 	memcpy(shared_kaddr + vcpu->time_offset, &vcpu->hv_clock,
 	       sizeof(vcpu->hv_clock));
 
-	kunmap_atomic(shared_kaddr, KM_USER0);
+	kunmap_atomic(shared_kaddr);
 
 	mark_page_dirty(v->kvm, vcpu->time >> PAGE_SHIFT);
 }
@@ -3567,7 +3567,7 @@ static int emulator_cmpxchg_emulated(uns
 		goto emul_write;
 	}
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	kaddr += offset_in_page(gpa);
 	switch (bytes) {
 	case 1:
@@ -3585,7 +3585,7 @@ static int emulator_cmpxchg_emulated(uns
 	default:
 		BUG();
 	}
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	kvm_release_page_dirty(page);
 
 	if (!exchanged)
Index: linux-2.6/arch/x86/lib/usercopy_32.c
===================================================================
--- linux-2.6.orig/arch/x86/lib/usercopy_32.c
+++ linux-2.6/arch/x86/lib/usercopy_32.c
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
Index: linux-2.6/arch/x86/mm/highmem_32.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/highmem_32.c
+++ linux-2.6/arch/x86/mm/highmem_32.c
@@ -27,7 +27,7 @@ void kunmap(struct page *page)
  * However when holding an atomic kmap it is not legal to sleep, so atomic
  * kmaps are appropriate for short, tight code paths only.
  */
-void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot)
+void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 {
 	enum fixed_addresses idx;
 	unsigned long vaddr;
@@ -47,12 +47,12 @@ void *kmap_atomic_prot(struct page *page
 	return (void *)vaddr;
 }
 
-void *kmap_atomic(struct page *page, enum km_type type)
+void *kmap_atomic(struct page *page)
 {
 	return kmap_atomic_prot(page, type, kmap_prot);
 }
 
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
+void kunmap_atomic_notypecheck(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
 	enum fixed_addresses idx;
@@ -89,7 +89,7 @@ void kunmap_atomic_notypecheck(void *kva
  * This is the same as kmap_atomic() but can map memory that doesn't
  * have a struct page associated with it.
  */
-void *kmap_atomic_pfn(unsigned long pfn, enum km_type type)
+void *kmap_atomic_pfn(unsigned long pfn)
 {
 	return kmap_atomic_prot_pfn(pfn, type, kmap_prot);
 }
Index: linux-2.6/arch/x86/mm/iomap_32.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/iomap_32.c
+++ linux-2.6/arch/x86/mm/iomap_32.c
@@ -55,7 +55,7 @@ iomap_free(resource_size_t base, unsigne
 }
 EXPORT_SYMBOL_GPL(iomap_free);
 
-void *kmap_atomic_prot_pfn(unsigned long pfn, enum km_type type, pgprot_t prot)
+void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
 {
 	enum fixed_addresses idx;
 	unsigned long vaddr;
@@ -75,7 +75,7 @@ void *kmap_atomic_prot_pfn(unsigned long
  * Map 'pfn' using fixed map 'type' and protections 'prot'
  */
 void *
-iomap_atomic_prot_pfn(unsigned long pfn, enum km_type type, pgprot_t prot)
+iomap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
 {
 	/*
 	 * For non-PAT systems, promote PAGE_KERNEL_WC to PAGE_KERNEL_UC_MINUS.
@@ -91,7 +91,7 @@ iomap_atomic_prot_pfn(unsigned long pfn,
 EXPORT_SYMBOL_GPL(iomap_atomic_prot_pfn);
 
 void
-iounmap_atomic(void *kvaddr, enum km_type type)
+iounmap_atomic(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
 	enum fixed_addresses idx;
Index: linux-2.6/crypto/async_tx/async_memcpy.c
===================================================================
--- linux-2.6.orig/crypto/async_tx/async_memcpy.c
+++ linux-2.6/crypto/async_tx/async_memcpy.c
@@ -78,13 +78,13 @@ async_memcpy(struct page *dest, struct p
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
Index: linux-2.6/drivers/ata/libata-sff.c
===================================================================
--- linux-2.6.orig/drivers/ata/libata-sff.c
+++ linux-2.6/drivers/ata/libata-sff.c
@@ -716,13 +716,13 @@ static void ata_pio_sector(struct ata_qu
 
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
@@ -861,13 +861,13 @@ next_sg:
 
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
Index: linux-2.6/drivers/block/brd.c
===================================================================
--- linux-2.6.orig/drivers/block/brd.c
+++ linux-2.6/drivers/block/brd.c
@@ -245,9 +245,9 @@ static void copy_to_brd(struct brd_devic
 	page = brd_lookup_page(brd, sector);
 	BUG_ON(!page);
 
-	dst = kmap_atomic(page, KM_USER1);
+	dst = kmap_atomic(page);
 	memcpy(dst + offset, src, copy);
-	kunmap_atomic(dst, KM_USER1);
+	kunmap_atomic(dst);
 
 	if (copy < n) {
 		src += copy;
@@ -256,9 +256,9 @@ static void copy_to_brd(struct brd_devic
 		page = brd_lookup_page(brd, sector);
 		BUG_ON(!page);
 
-		dst = kmap_atomic(page, KM_USER1);
+		dst = kmap_atomic(page);
 		memcpy(dst, src, copy);
-		kunmap_atomic(dst, KM_USER1);
+		kunmap_atomic(dst);
 	}
 }
 
@@ -276,9 +276,9 @@ static void copy_from_brd(void *dst, str
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
 
@@ -288,9 +288,9 @@ static void copy_from_brd(void *dst, str
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
@@ -312,7 +312,7 @@ static int brd_do_bvec(struct brd_device
 			goto out;
 	}
 
-	mem = kmap_atomic(page, KM_USER0);
+	mem = kmap_atomic(page);
 	if (rw == READ) {
 		copy_from_brd(mem + off, brd, sector, len);
 		flush_dcache_page(page);
@@ -320,7 +320,7 @@ static int brd_do_bvec(struct brd_device
 		flush_dcache_page(page);
 		copy_to_brd(brd, mem + off, sector, len);
 	}
-	kunmap_atomic(mem, KM_USER0);
+	kunmap_atomic(mem);
 
 out:
 	return err;
Index: linux-2.6/drivers/block/drbd/drbd_bitmap.c
===================================================================
--- linux-2.6.orig/drivers/block/drbd/drbd_bitmap.c
+++ linux-2.6/drivers/block/drbd/drbd_bitmap.c
@@ -170,7 +170,7 @@ static unsigned long *__bm_map_paddr(str
 
 static unsigned long * bm_map_paddr(struct drbd_bitmap *b, unsigned long offset)
 {
-	return __bm_map_paddr(b, offset, KM_IRQ1);
+	return __bm_map_paddr(b, offset);
 }
 
 static void __bm_unmap(unsigned long *p_addr, const enum km_type km)
@@ -180,7 +180,7 @@ static void __bm_unmap(unsigned long *p_
 
 static void bm_unmap(unsigned long *p_addr)
 {
-	return __bm_unmap(p_addr, KM_IRQ1);
+	return __bm_unmap(p_addr);
 }
 
 /* long word offset of _bitmap_ sector */
@@ -379,7 +379,7 @@ static unsigned long __bm_count_bits(str
 
 	while (offset < b->bm_words) {
 		i = do_now = min_t(size_t, b->bm_words-offset, LWPP);
-		p_addr = __bm_map_paddr(b, offset, KM_USER0);
+		p_addr = __bm_map_paddr(b, offset);
 		bm = p_addr + MLPP(offset);
 		while (i--) {
 #ifndef __LITTLE_ENDIAN
@@ -388,7 +388,7 @@ static unsigned long __bm_count_bits(str
 #endif
 			bits += hweight_long(*bm++);
 		}
-		__bm_unmap(p_addr, KM_USER0);
+		__bm_unmap(p_addr);
 		offset += do_now;
 		cond_resched();
 	}
@@ -799,10 +799,10 @@ static void bm_cpu_to_lel(struct drbd_bi
 		i = 0;
 	}
 	for (; i < b->bm_number_of_pages; i++) {
-		p_addr = kmap_atomic(b->bm_pages[i], KM_USER0);
+		p_addr = kmap_atomic(b->bm_pages[i]);
 		for (bm = p_addr; bm < p_addr + PAGE_SIZE/sizeof(long); bm++)
 			*bm = cpu_to_lel(*bm);
-		kunmap_atomic(p_addr, KM_USER0);
+		kunmap_atomic(p_addr);
 	}
 }
 # endif
@@ -983,7 +983,7 @@ static unsigned long bm_find_next(struct
 	if (bm_is_locked(b))
 		bm_print_lock_info(mdev);
 
-	i = __bm_find_next(mdev, bm_fo, find_zero_bit, KM_IRQ1);
+	i = __bm_find_next(mdev, bm_fo, find_zero_bit);
 
 	spin_unlock_irq(&b->bm_lock);
 	return i;
@@ -1007,13 +1007,13 @@ unsigned long drbd_bm_find_next_zero(str
 unsigned long _drbd_bm_find_next(struct drbd_conf *mdev, unsigned long bm_fo)
 {
 	/* WARN_ON(!bm_is_locked(mdev)); */
-	return __bm_find_next(mdev, bm_fo, 0, KM_USER1);
+	return __bm_find_next(mdev, bm_fo, 0);
 }
 
 unsigned long _drbd_bm_find_next_zero(struct drbd_conf *mdev, unsigned long bm_fo)
 {
 	/* WARN_ON(!bm_is_locked(mdev)); */
-	return __bm_find_next(mdev, bm_fo, 1, KM_USER1);
+	return __bm_find_next(mdev, bm_fo, 1);
 }
 
 /* returns number of bits actually changed.
@@ -1074,7 +1074,7 @@ static int bm_change_bits_to(struct drbd
 	if (bm_is_locked(b))
 		bm_print_lock_info(mdev);
 
-	c = __bm_change_bits_to(mdev, s, e, val, KM_IRQ1);
+	c = __bm_change_bits_to(mdev, s, e, val);
 
 	spin_unlock_irqrestore(&b->bm_lock, flags);
 	return c;
@@ -1099,13 +1099,13 @@ static inline void bm_set_full_words_wit
 {
 	int i;
 	int bits;
-	unsigned long *paddr = kmap_atomic(b->bm_pages[page_nr], KM_USER0);
+	unsigned long *paddr = kmap_atomic(b->bm_pages[page_nr]);
 	for (i = first_word; i < last_word; i++) {
 		bits = hweight_long(paddr[i]);
 		paddr[i] = ~0UL;
 		b->bm_set += BITS_PER_LONG - bits;
 	}
-	kunmap_atomic(paddr, KM_USER0);
+	kunmap_atomic(paddr);
 }
 
 /* Same thing as drbd_bm_set_bits, but without taking the spin_lock_irqsave.
@@ -1132,7 +1132,7 @@ void _drbd_bm_set_bits(struct drbd_conf 
 
 	if (e - s <= 3*BITS_PER_LONG) {
 		/* don't bother; el and sl may even be wrong. */
-		__bm_change_bits_to(mdev, s, e, 1, KM_USER0);
+		__bm_change_bits_to(mdev, s, e, 1);
 		return;
 	}
 
@@ -1140,7 +1140,7 @@ void _drbd_bm_set_bits(struct drbd_conf 
 
 	/* bits filling the current long */
 	if (sl)
-		__bm_change_bits_to(mdev, s, sl-1, 1, KM_USER0);
+		__bm_change_bits_to(mdev, s, sl-1, 1);
 
 	first_page = sl >> (3 + PAGE_SHIFT);
 	last_page = el >> (3 + PAGE_SHIFT);
@@ -1167,7 +1167,7 @@ void _drbd_bm_set_bits(struct drbd_conf 
 	 * it would trigger an assert in __bm_change_bits_to()
 	 */
 	if (el <= e)
-		__bm_change_bits_to(mdev, el, e, 1, KM_USER0);
+		__bm_change_bits_to(mdev, el, e, 1);
 }
 
 /* returns bit state
Index: linux-2.6/drivers/block/drbd/drbd_nl.c
===================================================================
--- linux-2.6.orig/drivers/block/drbd/drbd_nl.c
+++ linux-2.6/drivers/block/drbd/drbd_nl.c
@@ -2256,10 +2256,10 @@ void drbd_bcast_ee(struct drbd_conf *mde
 	len = e->size;
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
 	}
Index: linux-2.6/drivers/block/loop.c
===================================================================
--- linux-2.6.orig/drivers/block/loop.c
+++ linux-2.6/drivers/block/loop.c
@@ -91,16 +91,16 @@ static int transfer_none(struct loop_dev
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
@@ -110,8 +110,8 @@ static int transfer_xor(struct loop_devi
 			struct page *loop_page, unsigned loop_off,
 			int size, sector_t real_block)
 {
-	char *raw_buf = kmap_atomic(raw_page, KM_USER0) + raw_off;
-	char *loop_buf = kmap_atomic(loop_page, KM_USER1) + loop_off;
+	char *raw_buf = kmap_atomic(raw_page) + raw_off;
+	char *loop_buf = kmap_atomic(loop_page) + loop_off;
 	char *in, *out, *key;
 	int i, keysize;
 
@@ -128,8 +128,8 @@ static int transfer_xor(struct loop_devi
 	for (i = 0; i < size; i++)
 		*out++ = *in++ ^ key[(i & 511) % keysize];
 
-	kunmap_atomic(loop_buf, KM_USER1);
-	kunmap_atomic(raw_buf, KM_USER0);
+	kunmap_atomic(loop_buf);
+	kunmap_atomic(raw_buf);
 	cond_resched();
 	return 0;
 }
Index: linux-2.6/drivers/block/pktcdvd.c
===================================================================
--- linux-2.6.orig/drivers/block/pktcdvd.c
+++ linux-2.6/drivers/block/pktcdvd.c
@@ -988,14 +988,14 @@ static void pkt_copy_bio_data(struct bio
 
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
@@ -1020,10 +1020,10 @@ static void pkt_make_local_copy(struct p
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
Index: linux-2.6/drivers/crypto/hifn_795x.c
===================================================================
--- linux-2.6.orig/drivers/crypto/hifn_795x.c
+++ linux-2.6/drivers/crypto/hifn_795x.c
@@ -1731,9 +1731,9 @@ static int ablkcipher_get(void *saddr, u
 	while (size) {
 		copy = min(srest, min(dst->length, size));
 
-		daddr = kmap_atomic(sg_page(dst), KM_IRQ0);
+		daddr = kmap_atomic(sg_page(dst));
 		memcpy(daddr + dst->offset + offset, saddr, copy);
-		kunmap_atomic(daddr, KM_IRQ0);
+		kunmap_atomic(daddr);
 
 		nbytes -= copy;
 		size -= copy;
@@ -1793,17 +1793,17 @@ static void hifn_process_ready(struct ab
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
Index: linux-2.6/drivers/edac/edac_mc.c
===================================================================
--- linux-2.6.orig/drivers/edac/edac_mc.c
+++ linux-2.6/drivers/edac/edac_mc.c
@@ -612,13 +612,13 @@ static void edac_mc_scrub_block(unsigned
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
Index: linux-2.6/drivers/gpu/drm/drm_cache.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/drm_cache.c
+++ linux-2.6/drivers/gpu/drm/drm_cache.c
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
@@ -86,10 +86,10 @@ drm_clflush_pages(struct page *pages[], 
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
Index: linux-2.6/drivers/gpu/drm/i915/i915_debugfs.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/i915/i915_debugfs.c
+++ linux-2.6/drivers/gpu/drm/i915/i915_debugfs.c
@@ -270,10 +270,10 @@ static void i915_dump_pages(struct seq_f
 	uint32_t *mem;
 
 	for (page = 0; page < page_count; page++) {
-		mem = kmap_atomic(pages[page], KM_USER0);
+		mem = kmap_atomic(pages[page]);
 		for (i = 0; i < PAGE_SIZE; i += 4)
 			seq_printf(m, "%08x :  %08x\n", i, mem[i / 4]);
-		kunmap_atomic(mem, KM_USER0);
+		kunmap_atomic(mem);
 	}
 }
 
Index: linux-2.6/drivers/gpu/drm/i915/i915_gem.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/i915/i915_gem.c
+++ linux-2.6/drivers/gpu/drm/i915/i915_gem.c
@@ -146,11 +146,11 @@ fast_shmem_read(struct page **pages,
 	char __iomem *vaddr;
 	int unwritten;
 
-	vaddr = kmap_atomic(pages[page_base >> PAGE_SHIFT], KM_USER0);
+	vaddr = kmap_atomic(pages[page_base >> PAGE_SHIFT]);
 	if (vaddr == NULL)
 		return -ENOMEM;
 	unwritten = __copy_to_user_inatomic(data, vaddr + page_offset, length);
-	kunmap_atomic(vaddr, KM_USER0);
+	kunmap_atomic(vaddr);
 
 	if (unwritten)
 		return -EFAULT;
@@ -496,10 +496,10 @@ fast_user_write(struct io_mapping *mappi
 	char *vaddr_atomic;
 	unsigned long unwritten;
 
-	vaddr_atomic = io_mapping_map_atomic_wc(mapping, page_base, KM_USER0);
+	vaddr_atomic = io_mapping_map_atomic_wc(mapping, page_base);
 	unwritten = __copy_from_user_inatomic_nocache(vaddr_atomic + page_offset,
 						      user_data, length);
-	io_mapping_unmap_atomic(vaddr_atomic, KM_USER0);
+	io_mapping_unmap_atomic(vaddr_atomic);
 	if (unwritten)
 		return -EFAULT;
 	return 0;
@@ -538,11 +538,11 @@ fast_shmem_write(struct page **pages,
 	char __iomem *vaddr;
 	unsigned long unwritten;
 
-	vaddr = kmap_atomic(pages[page_base >> PAGE_SHIFT], KM_USER0);
+	vaddr = kmap_atomic(pages[page_base >> PAGE_SHIFT]);
 	if (vaddr == NULL)
 		return -ENOMEM;
 	unwritten = __copy_from_user_inatomic(vaddr + page_offset, data, length);
-	kunmap_atomic(vaddr, KM_USER0);
+	kunmap_atomic(vaddr);
 
 	if (unwritten)
 		return -EFAULT;
@@ -3499,7 +3499,7 @@ i915_gem_object_pin_and_relocate(struct 
 			  readl(reloc_entry), reloc_val);
 #endif
 		writel(reloc_val, reloc_entry);
-		io_mapping_unmap_atomic(reloc_page, KM_USER0);
+		io_mapping_unmap_atomic(reloc_page);
 
 		/* The updated presumed offset for this entry will be
 		 * copied back out to the user.
@@ -4921,11 +4921,11 @@ void i915_gem_detach_phys_object(struct 
 	page_count = obj->size / PAGE_SIZE;
 
 	for (i = 0; i < page_count; i++) {
-		char *dst = kmap_atomic(obj_priv->pages[i], KM_USER0);
+		char *dst = kmap_atomic(obj_priv->pages[i]);
 		char *src = obj_priv->phys_obj->handle->vaddr + (i * PAGE_SIZE);
 
 		memcpy(dst, src, PAGE_SIZE);
-		kunmap_atomic(dst, KM_USER0);
+		kunmap_atomic(dst);
 	}
 	drm_clflush_pages(obj_priv->pages, page_count);
 	drm_agp_chipset_flush(dev);
@@ -4981,11 +4981,11 @@ i915_gem_attach_phys_object(struct drm_d
 	page_count = obj->size / PAGE_SIZE;
 
 	for (i = 0; i < page_count; i++) {
-		char *src = kmap_atomic(obj_priv->pages[i], KM_USER0);
+		char *src = kmap_atomic(obj_priv->pages[i]);
 		char *dst = obj_priv->phys_obj->handle->vaddr + (i * PAGE_SIZE);
 
 		memcpy(dst, src, PAGE_SIZE);
-		kunmap_atomic(src, KM_USER0);
+		kunmap_atomic(src);
 	}
 
 	i915_gem_object_put_pages(obj);
Index: linux-2.6/drivers/gpu/drm/i915/i915_gem_debug.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/i915/i915_gem_debug.c
+++ linux-2.6/drivers/gpu/drm/i915/i915_gem_debug.c
@@ -57,13 +57,13 @@ static void
 i915_gem_dump_page(struct page *page, uint32_t start, uint32_t end,
 		   uint32_t bias, uint32_t mark)
 {
-	uint32_t *mem = kmap_atomic(page, KM_USER0);
+	uint32_t *mem = kmap_atomic(page);
 	int i;
 	for (i = start; i < end; i += 4)
 		DRM_INFO("%08x: %08x%s\n",
 			  (int) (bias + i), mem[i / 4],
 			  (bias + i == mark) ? " ********" : "");
-	kunmap_atomic(mem, KM_USER0);
+	kunmap_atomic(mem);
 	/* give syslog time to catch up */
 	msleep(1);
 }
@@ -157,7 +157,7 @@ i915_gem_object_check_coherency(struct d
 	for (page = 0; page < obj->size / PAGE_SIZE; page++) {
 		int i;
 
-		backing_map = kmap_atomic(obj_priv->pages[page], KM_USER0);
+		backing_map = kmap_atomic(obj_priv->pages[page]);
 
 		if (backing_map == NULL) {
 			DRM_ERROR("failed to map backing page\n");
@@ -181,13 +181,13 @@ i915_gem_object_check_coherency(struct d
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
Index: linux-2.6/drivers/gpu/drm/i915/i915_irq.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/i915/i915_irq.c
+++ linux-2.6/drivers/gpu/drm/i915/i915_irq.c
@@ -449,9 +449,9 @@ i915_error_object_create(struct drm_devi
 		if (d == NULL)
 			goto unwind;
 		local_irq_save(flags);
-		s = kmap_atomic(src_priv->pages[page], KM_IRQ0);
+		s = kmap_atomic(src_priv->pages[page]);
 		memcpy(d, s, PAGE_SIZE);
-		kunmap_atomic(s, KM_IRQ0);
+		kunmap_atomic(s);
 		local_irq_restore(flags);
 		dst->pages[page] = d;
 	}
Index: linux-2.6/drivers/gpu/drm/i915/intel_overlay.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/i915/intel_overlay.c
+++ linux-2.6/drivers/gpu/drm/i915/intel_overlay.c
@@ -201,7 +201,7 @@ static struct overlay_registers *intel_o
 static void intel_overlay_unmap_regs_atomic(struct intel_overlay *overlay)
 {
 	if (OVERLAY_NONPHYSICAL(overlay->dev))
-		io_mapping_unmap_atomic(overlay->virt_addr, KM_USER0);
+		io_mapping_unmap_atomic(overlay->virt_addr);
 
 	overlay->virt_addr = NULL;
 
Index: linux-2.6/drivers/gpu/drm/nouveau/nouveau_bios.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/nouveau/nouveau_bios.c
+++ linux-2.6/drivers/gpu/drm/nouveau/nouveau_bios.c
@@ -2167,11 +2167,11 @@ peek_fb(struct drm_device *dev, struct i
 
 	if (off < pci_resource_len(dev->pdev, 1)) {
 		uint32_t __iomem *p =
-			io_mapping_map_atomic_wc(fb, off & PAGE_MASK, KM_USER0);
+			io_mapping_map_atomic_wc(fb, off & PAGE_MASK);
 
 		val = ioread32(p + (off & ~PAGE_MASK));
 
-		io_mapping_unmap_atomic(p, KM_USER0);
+		io_mapping_unmap_atomic(p);
 	}
 
 	return val;
@@ -2183,12 +2183,12 @@ poke_fb(struct drm_device *dev, struct i
 {
 	if (off < pci_resource_len(dev->pdev, 1)) {
 		uint32_t __iomem *p =
-			io_mapping_map_atomic_wc(fb, off & PAGE_MASK, KM_USER0);
+			io_mapping_map_atomic_wc(fb, off & PAGE_MASK);
 
 		iowrite32(val, p + (off & ~PAGE_MASK));
 		wmb();
 
-		io_mapping_unmap_atomic(p, KM_USER0);
+		io_mapping_unmap_atomic(p);
 	}
 }
 
Index: linux-2.6/drivers/gpu/drm/ttm/ttm_bo_util.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/ttm/ttm_bo_util.c
+++ linux-2.6/drivers/gpu/drm/ttm/ttm_bo_util.c
@@ -170,7 +170,7 @@ static int ttm_copy_io_ttm_page(struct t
 	src = (void *)((unsigned long)src + (page << PAGE_SHIFT));
 
 #ifdef CONFIG_X86
-	dst = kmap_atomic_prot(d, KM_USER0, prot);
+	dst = kmap_atomic_prot(d, prot);
 #else
 	if (pgprot_val(prot) != pgprot_val(PAGE_KERNEL))
 		dst = vmap(&d, 1, 0, prot);
@@ -183,7 +183,7 @@ static int ttm_copy_io_ttm_page(struct t
 	memcpy_fromio(dst, src, PAGE_SIZE);
 
 #ifdef CONFIG_X86
-	kunmap_atomic(dst, KM_USER0);
+	kunmap_atomic(dst);
 #else
 	if (pgprot_val(prot) != pgprot_val(PAGE_KERNEL))
 		vunmap(dst);
@@ -206,7 +206,7 @@ static int ttm_copy_ttm_io_page(struct t
 
 	dst = (void *)((unsigned long)dst + (page << PAGE_SHIFT));
 #ifdef CONFIG_X86
-	src = kmap_atomic_prot(s, KM_USER0, prot);
+	src = kmap_atomic_prot(s, prot);
 #else
 	if (pgprot_val(prot) != pgprot_val(PAGE_KERNEL))
 		src = vmap(&s, 1, 0, prot);
@@ -219,7 +219,7 @@ static int ttm_copy_ttm_io_page(struct t
 	memcpy_toio(dst, src, PAGE_SIZE);
 
 #ifdef CONFIG_X86
-	kunmap_atomic(src, KM_USER0);
+	kunmap_atomic(src);
 #else
 	if (pgprot_val(prot) != pgprot_val(PAGE_KERNEL))
 		vunmap(src);
Index: linux-2.6/drivers/gpu/drm/ttm/ttm_tt.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/ttm/ttm_tt.c
+++ linux-2.6/drivers/gpu/drm/ttm/ttm_tt.c
@@ -490,11 +490,11 @@ static int ttm_tt_swapin(struct ttm_tt *
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
@@ -559,11 +559,11 @@ int ttm_tt_swapout(struct ttm_tt *ttm, s
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
Index: linux-2.6/drivers/gpu/drm/vmwgfx/vmwgfx_gmr.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/vmwgfx/vmwgfx_gmr.c
+++ linux-2.6/drivers/gpu/drm/vmwgfx/vmwgfx_gmr.c
@@ -65,10 +65,10 @@ static int vmw_gmr_build_descriptors(str
 
 		if (likely(page_virtual != NULL)) {
 			desc_virtual->ppn = page_to_pfn(page);
-			kunmap_atomic(page_virtual, KM_USER0);
+			kunmap_atomic(page_virtual);
 		}
 
-		page_virtual = kmap_atomic(page, KM_USER0);
+		page_virtual = kmap_atomic(page);
 		desc_virtual = page_virtual - 1;
 		prev_pfn = ~(0UL);
 
@@ -98,7 +98,7 @@ static int vmw_gmr_build_descriptors(str
 	}
 
 	if (likely(page_virtual != NULL))
-		kunmap_atomic(page_virtual, KM_USER0);
+		kunmap_atomic(page_virtual);
 
 	return 0;
 out_err:
Index: linux-2.6/drivers/ide/ide-taskfile.c
===================================================================
--- linux-2.6.orig/drivers/ide/ide-taskfile.c
+++ linux-2.6/drivers/ide/ide-taskfile.c
@@ -252,7 +252,7 @@ void ide_pio_bytes(ide_drive_t *drive, s
 		if (page_is_high)
 			local_irq_save(flags);
 
-		buf = kmap_atomic(page, KM_BIO_SRC_IRQ) + offset;
+		buf = kmap_atomic(page) + offset;
 
 		cmd->nleft -= nr_bytes;
 		cmd->cursg_ofs += nr_bytes;
@@ -268,7 +268,7 @@ void ide_pio_bytes(ide_drive_t *drive, s
 		else
 			hwif->tp_ops->input_data(drive, cmd, buf, nr_bytes);
 
-		kunmap_atomic(buf, KM_BIO_SRC_IRQ);
+		kunmap_atomic(buf);
 
 		if (page_is_high)
 			local_irq_restore(flags);
Index: linux-2.6/drivers/infiniband/ulp/iser/iser_memory.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/ulp/iser/iser_memory.c
+++ linux-2.6/drivers/infiniband/ulp/iser/iser_memory.c
@@ -73,11 +73,11 @@ static int iser_start_rdma_unaligned_sg(
 
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
@@ -133,11 +133,11 @@ void iser_finalize_rdma_unaligned_sg(str
 
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
Index: linux-2.6/drivers/md/bitmap.c
===================================================================
--- linux-2.6.orig/drivers/md/bitmap.c
+++ linux-2.6/drivers/md/bitmap.c
@@ -487,7 +487,7 @@ void bitmap_update_sb(struct bitmap *bit
 		return;
 	}
 	spin_unlock_irqrestore(&bitmap->lock, flags);
-	sb = kmap_atomic(bitmap->sb_page, KM_USER0);
+	sb = kmap_atomic(bitmap->sb_page);
 	sb->events = cpu_to_le64(bitmap->mddev->events);
 	if (bitmap->mddev->events < bitmap->events_cleared) {
 		/* rocking back to read-only */
@@ -497,7 +497,7 @@ void bitmap_update_sb(struct bitmap *bit
 	/* Just in case these have been changed via sysfs: */
 	sb->daemon_sleep = cpu_to_le32(bitmap->mddev->bitmap_info.daemon_sleep/HZ);
 	sb->write_behind = cpu_to_le32(bitmap->mddev->bitmap_info.max_write_behind);
-	kunmap_atomic(sb, KM_USER0);
+	kunmap_atomic(sb);
 	write_page(bitmap, bitmap->sb_page, 1);
 }
 
@@ -508,7 +508,7 @@ void bitmap_print_sb(struct bitmap *bitm
 
 	if (!bitmap || !bitmap->sb_page)
 		return;
-	sb = kmap_atomic(bitmap->sb_page, KM_USER0);
+	sb = kmap_atomic(bitmap->sb_page);
 	printk(KERN_DEBUG "%s: bitmap file superblock:\n", bmname(bitmap));
 	printk(KERN_DEBUG "         magic: %08x\n", le32_to_cpu(sb->magic));
 	printk(KERN_DEBUG "       version: %d\n", le32_to_cpu(sb->version));
@@ -527,7 +527,7 @@ void bitmap_print_sb(struct bitmap *bitm
 	printk(KERN_DEBUG "     sync size: %llu KB\n",
 			(unsigned long long)le64_to_cpu(sb->sync_size)/2);
 	printk(KERN_DEBUG "max write behind: %d\n", le32_to_cpu(sb->write_behind));
-	kunmap_atomic(sb, KM_USER0);
+	kunmap_atomic(sb);
 }
 
 /* read the superblock from the bitmap file and initialize some bitmap fields */
@@ -557,7 +557,7 @@ static int bitmap_read_sb(struct bitmap 
 		return err;
 	}
 
-	sb = kmap_atomic(bitmap->sb_page, KM_USER0);
+	sb = kmap_atomic(bitmap->sb_page);
 
 	chunksize = le32_to_cpu(sb->chunksize);
 	daemon_sleep = le32_to_cpu(sb->daemon_sleep) * HZ;
@@ -618,7 +618,7 @@ success:
 		bitmap->events_cleared = bitmap->mddev->events;
 	err = 0;
 out:
-	kunmap_atomic(sb, KM_USER0);
+	kunmap_atomic(sb);
 	if (err)
 		bitmap_print_sb(bitmap);
 	return err;
@@ -643,7 +643,7 @@ static int bitmap_mask_state(struct bitm
 		return 0;
 	}
 	spin_unlock_irqrestore(&bitmap->lock, flags);
-	sb = kmap_atomic(bitmap->sb_page, KM_USER0);
+	sb = kmap_atomic(bitmap->sb_page);
 	old = le32_to_cpu(sb->state) & bits;
 	switch (op) {
 	case MASK_SET:
@@ -655,7 +655,7 @@ static int bitmap_mask_state(struct bitm
 	default:
 		BUG();
 	}
-	kunmap_atomic(sb, KM_USER0);
+	kunmap_atomic(sb);
 	return old;
 }
 
@@ -846,12 +846,12 @@ static void bitmap_file_set_bit(struct b
 		bit = file_page_offset(bitmap, chunk);
 
 		/* set the bit */
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		if (bitmap->flags & BITMAP_HOSTENDIAN)
 			set_bit(bit, kaddr);
 		else
 			ext2_set_bit(bit, kaddr);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		PRINTK("set file bit %lu page %lu\n", bit, page->index);
 	}
 	/* record page number so it gets flushed to disk when unplug occurs */
@@ -1030,10 +1030,10 @@ static int bitmap_init_from_disk(struct 
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
@@ -1041,12 +1041,12 @@ static int bitmap_init_from_disk(struct 
 					goto err;
 			}
 		}
-		paddr = kmap_atomic(page, KM_USER0);
+		paddr = kmap_atomic(page);
 		if (bitmap->flags & BITMAP_HOSTENDIAN)
 			b = test_bit(bit, paddr);
 		else
 			b = ext2_test_bit(bit, paddr);
-		kunmap_atomic(paddr, KM_USER0);
+		kunmap_atomic(paddr);
 		if (b) {
 			/* if the disk bit is set, set the memory bit */
 			int needed = ((sector_t)(i+1) << (CHUNK_BLOCK_SHIFT(bitmap))
@@ -1187,10 +1187,10 @@ void bitmap_daemon_work(mddev_t *mddev)
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
@@ -1216,14 +1216,14 @@ void bitmap_daemon_work(mddev_t *mddev)
 
 				/* clear the bit */
 				if (page) {
-					paddr = kmap_atomic(page, KM_USER0);
+					paddr = kmap_atomic(page);
 					if (bitmap->flags & BITMAP_HOSTENDIAN)
 						clear_bit(file_page_offset(bitmap, j),
 							  paddr);
 					else
 						ext2_clear_bit(file_page_offset(bitmap, j),
 							       paddr);
-					kunmap_atomic(paddr, KM_USER0);
+					kunmap_atomic(paddr);
 				} else
 					log->type->clear_region(log, j);
 			}
Index: linux-2.6/drivers/media/video/ivtv/ivtv-udma.c
===================================================================
--- linux-2.6.orig/drivers/media/video/ivtv/ivtv-udma.c
+++ linux-2.6/drivers/media/video/ivtv/ivtv-udma.c
@@ -57,9 +57,9 @@ int ivtv_udma_fill_sg_list (struct ivtv_
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
Index: linux-2.6/drivers/memstick/host/jmb38x_ms.c
===================================================================
--- linux-2.6.orig/drivers/memstick/host/jmb38x_ms.c
+++ linux-2.6/drivers/memstick/host/jmb38x_ms.c
@@ -324,7 +324,7 @@ static int jmb38x_ms_transfer_data(struc
 			p_cnt = min(p_cnt, length);
 
 			local_irq_save(flags);
-			buf = kmap_atomic(pg, KM_BIO_SRC_IRQ) + p_off;
+			buf = kmap_atomic(pg) + p_off;
 		} else {
 			buf = host->req->data + host->block_pos;
 			p_cnt = host->req->data_len - host->block_pos;
@@ -340,7 +340,7 @@ static int jmb38x_ms_transfer_data(struc
 				 : jmb38x_ms_read_reg_data(host, buf, p_cnt);
 
 		if (host->req->long_data) {
-			kunmap_atomic(buf - p_off, KM_BIO_SRC_IRQ);
+			kunmap_atomic(buf - p_off);
 			local_irq_restore(flags);
 		}
 
Index: linux-2.6/drivers/memstick/host/tifm_ms.c
===================================================================
--- linux-2.6.orig/drivers/memstick/host/tifm_ms.c
+++ linux-2.6/drivers/memstick/host/tifm_ms.c
@@ -209,7 +209,7 @@ static unsigned int tifm_ms_transfer_dat
 			p_cnt = min(p_cnt, length);
 
 			local_irq_save(flags);
-			buf = kmap_atomic(pg, KM_BIO_SRC_IRQ) + p_off;
+			buf = kmap_atomic(pg) + p_off;
 		} else {
 			buf = host->req->data + host->block_pos;
 			p_cnt = host->req->data_len - host->block_pos;
@@ -220,7 +220,7 @@ static unsigned int tifm_ms_transfer_dat
 			 : tifm_ms_read_data(host, buf, p_cnt);
 
 		if (host->req->long_data) {
-			kunmap_atomic(buf - p_off, KM_BIO_SRC_IRQ);
+			kunmap_atomic(buf - p_off);
 			local_irq_restore(flags);
 		}
 
Index: linux-2.6/drivers/mmc/host/at91_mci.c
===================================================================
--- linux-2.6.orig/drivers/mmc/host/at91_mci.c
+++ linux-2.6/drivers/mmc/host/at91_mci.c
@@ -233,7 +233,7 @@ static inline void at91_mci_sg_to_dma(st
 
 		sg = &data->sg[i];
 
-		sgbuffer = kmap_atomic(sg_page(sg), KM_BIO_SRC_IRQ) + sg->offset;
+		sgbuffer = kmap_atomic(sg_page(sg)) + sg->offset;
 		amount = min(size, sg->length);
 		size -= amount;
 
@@ -249,7 +249,7 @@ static inline void at91_mci_sg_to_dma(st
 			dmabuf = (unsigned *)tmpv;
 		}
 
-		kunmap_atomic(sgbuffer, KM_BIO_SRC_IRQ);
+		kunmap_atomic(sgbuffer);
 
 		if (size == 0)
 			break;
@@ -299,7 +299,7 @@ static void at91_mci_post_dma_read(struc
 
 		sg = &data->sg[i];
 
-		sgbuffer = kmap_atomic(sg_page(sg), KM_BIO_SRC_IRQ) + sg->offset;
+		sgbuffer = kmap_atomic(sg_page(sg)) + sg->offset;
 		amount = min(size, sg->length);
 		size -= amount;
 
@@ -315,7 +315,7 @@ static void at91_mci_post_dma_read(struc
 		}
 
 		flush_kernel_dcache_page(sg_page(sg));
-		kunmap_atomic(sgbuffer, KM_BIO_SRC_IRQ);
+		kunmap_atomic(sgbuffer);
 		data->bytes_xfered += amount;
 		if (size == 0)
 			break;
Index: linux-2.6/drivers/mmc/host/msm_sdcc.c
===================================================================
--- linux-2.6.orig/drivers/mmc/host/msm_sdcc.c
+++ linux-2.6/drivers/mmc/host/msm_sdcc.c
@@ -644,7 +644,7 @@ msmsdcc_pio_irq(int irq, void *dev_id)
 			len = msmsdcc_pio_write(host, buffer, remain, status);
 
 		/* Unmap the buffer */
-		kunmap_atomic(buffer, KM_BIO_SRC_IRQ);
+		kunmap_atomic(buffer);
 		local_irq_restore(flags);
 
 		host->pio.sg_off += len;
Index: linux-2.6/drivers/mmc/host/sdhci.c
===================================================================
--- linux-2.6.orig/drivers/mmc/host/sdhci.c
+++ linux-2.6/drivers/mmc/host/sdhci.c
@@ -380,12 +380,12 @@ static void sdhci_transfer_pio(struct sd
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
 
Index: linux-2.6/drivers/mmc/host/tifm_sd.c
===================================================================
--- linux-2.6.orig/drivers/mmc/host/tifm_sd.c
+++ linux-2.6/drivers/mmc/host/tifm_sd.c
@@ -117,7 +117,7 @@ static void tifm_sd_read_fifo(struct tif
 	unsigned char *buf;
 	unsigned int pos = 0, val;
 
-	buf = kmap_atomic(pg, KM_BIO_DST_IRQ) + off;
+	buf = kmap_atomic(pg) + off;
 	if (host->cmd_flags & DATA_CARRY) {
 		buf[pos++] = host->bounce_buf_data[0];
 		host->cmd_flags &= ~DATA_CARRY;
@@ -133,7 +133,7 @@ static void tifm_sd_read_fifo(struct tif
 		}
 		buf[pos++] = (val >> 8) & 0xff;
 	}
-	kunmap_atomic(buf - off, KM_BIO_DST_IRQ);
+	kunmap_atomic(buf - off);
 }
 
 static void tifm_sd_write_fifo(struct tifm_sd *host, struct page *pg,
@@ -143,7 +143,7 @@ static void tifm_sd_write_fifo(struct ti
 	unsigned char *buf;
 	unsigned int pos = 0, val;
 
-	buf = kmap_atomic(pg, KM_BIO_SRC_IRQ) + off;
+	buf = kmap_atomic(pg) + off;
 	if (host->cmd_flags & DATA_CARRY) {
 		val = host->bounce_buf_data[0] | ((buf[pos++] << 8) & 0xff00);
 		writel(val, sock->addr + SOCK_MMCSD_DATA);
@@ -160,7 +160,7 @@ static void tifm_sd_write_fifo(struct ti
 		val |= (buf[pos++] << 8) & 0xff00;
 		writel(val, sock->addr + SOCK_MMCSD_DATA);
 	}
-	kunmap_atomic(buf - off, KM_BIO_SRC_IRQ);
+	kunmap_atomic(buf - off);
 }
 
 static void tifm_sd_transfer_data(struct tifm_sd *host)
@@ -211,13 +211,13 @@ static void tifm_sd_copy_page(struct pag
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
Index: linux-2.6/drivers/mmc/host/tmio_mmc.h
===================================================================
--- linux-2.6.orig/drivers/mmc/host/tmio_mmc.h
+++ linux-2.6/drivers/mmc/host/tmio_mmc.h
@@ -183,13 +183,13 @@ static inline char *tmio_mmc_kmap_atomic
 	struct scatterlist *sg = host->sg_ptr;
 
 	local_irq_save(*flags);
-	return kmap_atomic(sg_page(sg), KM_BIO_SRC_IRQ) + sg->offset;
+	return kmap_atomic(sg_page(sg)) + sg->offset;
 }
 
 static inline void tmio_mmc_kunmap_atomic(struct tmio_mmc_host *host,
 	unsigned long *flags)
 {
-	kunmap_atomic(sg_page(host->sg_ptr), KM_BIO_SRC_IRQ);
+	kunmap_atomic(sg_page(host->sg_ptr));
 	local_irq_restore(*flags);
 }
 
Index: linux-2.6/drivers/net/cassini.c
===================================================================
--- linux-2.6.orig/drivers/net/cassini.c
+++ linux-2.6/drivers/net/cassini.c
@@ -103,8 +103,8 @@
 #include <asm/byteorder.h>
 #include <asm/uaccess.h>
 
-#define cas_page_map(x)      kmap_atomic((x), KM_SKB_DATA_SOFTIRQ)
-#define cas_page_unmap(x)    kunmap_atomic((x), KM_SKB_DATA_SOFTIRQ)
+#define cas_page_map(x)      kmap_atomic((x))
+#define cas_page_unmap(x)    kunmap_atomic((x))
 #define CAS_NCPUS            num_online_cpus()
 
 #define cas_skb_release(x)  netif_rx(x)
Index: linux-2.6/drivers/net/e1000e/netdev.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000e/netdev.c
+++ linux-2.6/drivers/net/e1000e/netdev.c
@@ -1164,9 +1164,9 @@ static bool e1000_clean_rx_irq_ps(struct
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
 
Index: linux-2.6/drivers/scsi/arcmsr/arcmsr_hba.c
===================================================================
--- linux-2.6.orig/drivers/scsi/arcmsr/arcmsr_hba.c
+++ linux-2.6/drivers/scsi/arcmsr/arcmsr_hba.c
@@ -1761,7 +1761,7 @@ static int arcmsr_iop_message_xfer(struc
 						(uint32_t ) cmd->cmnd[8];
 						/* 4 bytes: Areca io control code */
 	sg = scsi_sglist(cmd);
-	buffer = kmap_atomic(sg_page(sg), KM_IRQ0) + sg->offset;
+	buffer = kmap_atomic(sg_page(sg)) + sg->offset;
 	if (scsi_sg_count(cmd) > 1) {
 		retvalue = ARCMSR_MESSAGE_FAIL;
 		goto message_out;
@@ -2010,7 +2010,7 @@ static int arcmsr_iop_message_xfer(struc
 	}
 	message_out:
 	sg = scsi_sglist(cmd);
-	kunmap_atomic(buffer - sg->offset, KM_IRQ0);
+	kunmap_atomic(buffer - sg->offset);
 	return retvalue;
 }
 
@@ -2060,11 +2060,11 @@ static void arcmsr_handle_virtual_comman
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
Index: linux-2.6/drivers/scsi/cxgb3i/cxgb3i_pdu.c
===================================================================
--- linux-2.6.orig/drivers/scsi/cxgb3i/cxgb3i_pdu.c
+++ linux-2.6/drivers/scsi/cxgb3i/cxgb3i_pdu.c
@@ -325,7 +325,7 @@ int cxgb3i_conn_init_pdu(struct iscsi_ta
 
 				memcpy(dst, src+frag->page_offset, frag->size);
 				dst += frag->size;
-				kunmap_atomic(src, KM_SOFTIRQ0);
+				kunmap_atomic(src);
 			}
 			if (padlen) {
 				memset(dst, 0, padlen);
Index: linux-2.6/drivers/scsi/fcoe/fcoe.c
===================================================================
--- linux-2.6.orig/drivers/scsi/fcoe/fcoe.c
+++ linux-2.6/drivers/scsi/fcoe/fcoe.c
@@ -1459,7 +1459,7 @@ u32 fcoe_fc_crc(struct fc_frame *fp)
 			data = kmap_atomic(frag->page + (off >> PAGE_SHIFT),
 					   KM_SKB_DATA_SOFTIRQ);
 			crc = crc32(crc, data + (off & ~PAGE_MASK), clen);
-			kunmap_atomic(data, KM_SKB_DATA_SOFTIRQ);
+			kunmap_atomic(data);
 			off += clen;
 			len -= clen;
 		}
@@ -1533,7 +1533,7 @@ int fcoe_xmit(struct fc_lport *lport, st
 			return -ENOMEM;
 		}
 		frag = &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
-		cp = kmap_atomic(frag->page, KM_SKB_DATA_SOFTIRQ)
+		cp = kmap_atomic(frag->page)
 			+ frag->page_offset;
 	} else {
 		cp = (struct fcoe_crc_eof *)skb_put(skb, tlen);
@@ -1544,7 +1544,7 @@ int fcoe_xmit(struct fc_lport *lport, st
 	cp->fcoe_crc32 = cpu_to_le32(~crc);
 
 	if (skb_is_nonlinear(skb)) {
-		kunmap_atomic(cp, KM_SKB_DATA_SOFTIRQ);
+		kunmap_atomic(cp);
 		cp = NULL;
 	}
 
Index: linux-2.6/drivers/scsi/gdth.c
===================================================================
--- linux-2.6.orig/drivers/scsi/gdth.c
+++ linux-2.6/drivers/scsi/gdth.c
@@ -2308,10 +2308,10 @@ static void gdth_copy_internal_data(gdth
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
Index: linux-2.6/drivers/scsi/ips.c
===================================================================
--- linux-2.6.orig/drivers/scsi/ips.c
+++ linux-2.6/drivers/scsi/ips.c
@@ -1509,14 +1509,14 @@ static int ips_is_passthru(struct scsi_c
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
Index: linux-2.6/drivers/scsi/libfc/fc_fcp.c
===================================================================
--- linux-2.6.orig/drivers/scsi/libfc/fc_fcp.c
+++ linux-2.6/drivers/scsi/libfc/fc_fcp.c
@@ -473,11 +473,11 @@ static void fc_fcp_recv_data(struct fc_f
 
 	if (!(fr_flags(fp) & FCPHF_CRC_UNCHECKED)) {
 		copy_len = fc_copy_buffer_to_sglist(buf, len, sg, &nents,
-						    &offset, KM_SOFTIRQ0, NULL);
+						    &offset, NULL);
 	} else {
 		crc = crc32(~0, (u8 *) fh, sizeof(*fh));
 		copy_len = fc_copy_buffer_to_sglist(buf, len, sg, &nents,
-						    &offset, KM_SOFTIRQ0, &crc);
+						    &offset, &crc);
 		buf = fc_frame_payload_get(fp, 0);
 		if (len % 4)
 			crc = crc32(crc, buf + len, 4 - (len % 4));
@@ -636,10 +636,10 @@ static int fc_fcp_send_data(struct fc_fc
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
Index: linux-2.6/drivers/scsi/libfc/fc_lport.c
===================================================================
--- linux-2.6.orig/drivers/scsi/libfc/fc_lport.c
+++ linux-2.6/drivers/scsi/libfc/fc_lport.c
@@ -1636,7 +1636,7 @@ static void fc_lport_bsg_resp(struct fc_
 
 	job->reply->reply_payload_rcv_len +=
 		fc_copy_buffer_to_sglist(buf, len, info->sg, &info->nents,
-					 &info->offset, KM_BIO_SRC_IRQ, NULL);
+					 &info->offset, NULL);
 
 	if (fr_eof(fp) == FC_EOF_T &&
 	    (ntoh24(fh->fh_f_ctl) & (FC_FC_LAST_SEQ | FC_FC_END_SEQ)) ==
Index: linux-2.6/drivers/scsi/libiscsi_tcp.c
===================================================================
--- linux-2.6.orig/drivers/scsi/libiscsi_tcp.c
+++ linux-2.6/drivers/scsi/libiscsi_tcp.c
@@ -132,14 +132,14 @@ static void iscsi_tcp_segment_map(struct
 	if (page_count(sg_page(sg)) >= 1 && !recv)
 		return;
 
-	segment->sg_mapped = kmap_atomic(sg_page(sg), KM_SOFTIRQ0);
+	segment->sg_mapped = kmap_atomic(sg_page(sg));
 	segment->data = segment->sg_mapped + sg->offset + segment->sg_offset;
 }
 
 void iscsi_tcp_segment_unmap(struct iscsi_segment *segment)
 {
 	if (segment->sg_mapped) {
-		kunmap_atomic(segment->sg_mapped, KM_SOFTIRQ0);
+		kunmap_atomic(segment->sg_mapped);
 		segment->sg_mapped = NULL;
 		segment->data = NULL;
 	}
Index: linux-2.6/drivers/scsi/libsas/sas_host_smp.c
===================================================================
--- linux-2.6.orig/drivers/scsi/libsas/sas_host_smp.c
+++ linux-2.6/drivers/scsi/libsas/sas_host_smp.c
@@ -160,9 +160,9 @@ int sas_smp_host_handler(struct Scsi_Hos
 	}
 
 	local_irq_disable();
-	buf = kmap_atomic(bio_page(req->bio), KM_USER0) + bio_offset(req->bio);
+	buf = kmap_atomic(bio_page(req->bio)) + bio_offset(req->bio);
 	memcpy(req_data, buf, blk_rq_bytes(req));
-	kunmap_atomic(buf - bio_offset(req->bio), KM_USER0);
+	kunmap_atomic(buf - bio_offset(req->bio));
 	local_irq_enable();
 
 	if (req_data[0] != SMP_REQUEST)
@@ -261,10 +261,10 @@ int sas_smp_host_handler(struct Scsi_Hos
 	}
 
 	local_irq_disable();
-	buf = kmap_atomic(bio_page(rsp->bio), KM_USER0) + bio_offset(rsp->bio);
+	buf = kmap_atomic(bio_page(rsp->bio)) + bio_offset(rsp->bio);
 	memcpy(buf, resp_data, blk_rq_bytes(rsp));
 	flush_kernel_dcache_page(bio_page(rsp->bio));
-	kunmap_atomic(buf - bio_offset(rsp->bio), KM_USER0);
+	kunmap_atomic(buf - bio_offset(rsp->bio));
 	local_irq_enable();
 
  out:
Index: linux-2.6/drivers/scsi/megaraid.c
===================================================================
--- linux-2.6.orig/drivers/scsi/megaraid.c
+++ linux-2.6/drivers/scsi/megaraid.c
@@ -663,10 +663,10 @@ mega_build_cmd(adapter_t *adapter, Scsi_
 			struct scatterlist *sg;
 
 			sg = scsi_sglist(cmd);
-			buf = kmap_atomic(sg_page(sg), KM_IRQ0) + sg->offset;
+			buf = kmap_atomic(sg_page(sg)) + sg->offset;
 
 			memset(buf, 0, cmd->cmnd[4]);
-			kunmap_atomic(buf - sg->offset, KM_IRQ0);
+			kunmap_atomic(buf - sg->offset);
 
 			cmd->result = (DID_OK << 16);
 			cmd->scsi_done(cmd);
Index: linux-2.6/drivers/scsi/mvsas/mv_sas.c
===================================================================
--- linux-2.6.orig/drivers/scsi/mvsas/mv_sas.c
+++ linux-2.6/drivers/scsi/mvsas/mv_sas.c
@@ -554,9 +554,9 @@ static int mvs_task_prep_smp(struct mvs_
 
 #if _MV_DUMP
 	/* copy cmd table */
-	from = kmap_atomic(sg_page(sg_req), KM_IRQ0);
+	from = kmap_atomic(sg_page(sg_req));
 	memcpy(buf_cmd, from + sg_req->offset, req_len);
-	kunmap_atomic(from, KM_IRQ0);
+	kunmap_atomic(from);
 #endif
 	return 0;
 
@@ -1896,11 +1896,11 @@ int mvs_slot_complete(struct mvs_info *m
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
 
Index: linux-2.6/drivers/scsi/scsi_debug.c
===================================================================
--- linux-2.6.orig/drivers/scsi/scsi_debug.c
+++ linux-2.6/drivers/scsi/scsi_debug.c
@@ -1746,7 +1746,7 @@ static int prot_verify_read(struct scsi_
 	scsi_for_each_prot_sg(SCpnt, psgl, scsi_prot_sg_count(SCpnt), i) {
 		int len = min(psgl->length, resid);
 
-		paddr = kmap_atomic(sg_page(psgl), KM_IRQ0) + psgl->offset;
+		paddr = kmap_atomic(sg_page(psgl)) + psgl->offset;
 		memcpy(paddr, dif_storep + dif_offset(sector), len);
 
 		sector += len >> 3;
@@ -1756,7 +1756,7 @@ static int prot_verify_read(struct scsi_
 			sector = do_div(tmp_sec, sdebug_store_sectors);
 		}
 		resid -= len;
-		kunmap_atomic(paddr, KM_IRQ0);
+		kunmap_atomic(paddr);
 	}
 
 	dix_reads++;
@@ -1848,12 +1848,12 @@ static int prot_verify_write(struct scsi
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
@@ -1862,10 +1862,10 @@ static int prot_verify_write(struct scsi
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
@@ -1938,10 +1938,10 @@ static int prot_verify_write(struct scsi
 			ppage_offset += sizeof(struct sd_dif_tuple);
 		}
 
-		kunmap_atomic(daddr, KM_IRQ0);
+		kunmap_atomic(daddr);
 	}
 
-	kunmap_atomic(paddr, KM_IRQ1);
+	kunmap_atomic(paddr);
 
 	dix_writes++;
 
@@ -1949,8 +1949,8 @@ static int prot_verify_write(struct scsi
 
 out:
 	dif_errors++;
-	kunmap_atomic(daddr, KM_IRQ0);
-	kunmap_atomic(paddr, KM_IRQ1);
+	kunmap_atomic(daddr);
+	kunmap_atomic(paddr);
 	return ret;
 }
 
@@ -2264,7 +2264,7 @@ static int resp_xdwriteread(struct scsi_
 
 	offset = 0;
 	for_each_sg(sdb->table.sgl, sg, sdb->table.nents, i) {
-		kaddr = (unsigned char *)kmap_atomic(sg_page(sg), KM_USER0);
+		kaddr = (unsigned char *)kmap_atomic(sg_page(sg));
 		if (!kaddr)
 			goto out;
 
@@ -2272,7 +2272,7 @@ static int resp_xdwriteread(struct scsi_
 			*(kaddr + sg->offset + j) ^= *(buf + offset + j);
 
 		offset += sg->length;
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 	ret = 0;
 out:
Index: linux-2.6/drivers/scsi/scsi_lib.c
===================================================================
--- linux-2.6.orig/drivers/scsi/scsi_lib.c
+++ linux-2.6/drivers/scsi/scsi_lib.c
@@ -2537,7 +2537,7 @@ void *scsi_kmap_atomic_sg(struct scatter
 	if (*len > sg_len)
 		*len = sg_len;
 
-	return kmap_atomic(page, KM_BIO_SRC_IRQ);
+	return kmap_atomic(page);
 }
 EXPORT_SYMBOL(scsi_kmap_atomic_sg);
 
@@ -2547,6 +2547,6 @@ EXPORT_SYMBOL(scsi_kmap_atomic_sg);
  */
 void scsi_kunmap_atomic_sg(void *virt)
 {
-	kunmap_atomic(virt, KM_BIO_SRC_IRQ);
+	kunmap_atomic(virt);
 }
 EXPORT_SYMBOL(scsi_kunmap_atomic_sg);
Index: linux-2.6/drivers/scsi/sd_dif.c
===================================================================
--- linux-2.6.orig/drivers/scsi/sd_dif.c
+++ linux-2.6/drivers/scsi/sd_dif.c
@@ -393,7 +393,7 @@ int sd_dif_prepare(struct request *rq, s
 		virt = bio->bi_integrity->bip_sector & 0xffffffff;
 
 		bip_for_each_vec(iv, bio->bi_integrity, i) {
-			sdt = kmap_atomic(iv->bv_page, KM_USER0)
+			sdt = kmap_atomic(iv->bv_page)
 				+ iv->bv_offset;
 
 			for (j = 0 ; j < iv->bv_len ; j += tuple_sz, sdt++) {
@@ -406,14 +406,14 @@ int sd_dif_prepare(struct request *rq, s
 				phys++;
 			}
 
-			kunmap_atomic(sdt, KM_USER0);
+			kunmap_atomic(sdt);
 		}
 	}
 
 	return 0;
 
 error:
-	kunmap_atomic(sdt, KM_USER0);
+	kunmap_atomic(sdt);
 	sd_printk(KERN_ERR, sdkp, "%s: virt %u, phys %u, ref %u, app %4x\n",
 		  __func__, virt, phys, be32_to_cpu(sdt->ref_tag),
 		  be16_to_cpu(sdt->app_tag));
@@ -452,13 +452,13 @@ void sd_dif_complete(struct scsi_cmnd *s
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
 
@@ -473,7 +473,7 @@ void sd_dif_complete(struct scsi_cmnd *s
 				sectors--;
 			}
 
-			kunmap_atomic(sdt, KM_USER0);
+			kunmap_atomic(sdt);
 		}
 	}
 }
Index: linux-2.6/drivers/staging/hv/netvsc_drv.c
===================================================================
--- linux-2.6.orig/drivers/staging/hv/netvsc_drv.c
+++ linux-2.6/drivers/staging/hv/netvsc_drv.c
@@ -283,7 +283,7 @@ static int netvsc_recv_callback(struct h
 		       packet->PageBuffers[i].Length);
 
 		kunmap_atomic((void *)((unsigned long)data -
-				       packet->PageBuffers[i].Offset), KM_IRQ1);
+				       packet->PageBuffers[i].Offset));
 	}
 
 	local_irq_restore(flags);
Index: linux-2.6/drivers/staging/hv/rndis_filter.c
===================================================================
--- linux-2.6.orig/drivers/staging/hv/rndis_filter.c
+++ linux-2.6/drivers/staging/hv/rndis_filter.c
@@ -396,7 +396,7 @@ static int RndisFilterOnReceive(struct h
 	}
 
 	rndisHeader = (struct rndis_message *)kmap_atomic(
-			pfn_to_page(Packet->PageBuffers[0].Pfn), KM_IRQ0);
+			pfn_to_page(Packet->PageBuffers[0].Pfn));
 
 	rndisHeader = (void *)((unsigned long)rndisHeader +
 			Packet->PageBuffers[0].Offset);
@@ -433,7 +433,7 @@ static int RndisFilterOnReceive(struct h
 			sizeof(struct rndis_message) :
 			rndisHeader->MessageLength);
 
-	kunmap_atomic(rndisHeader - Packet->PageBuffers[0].Offset, KM_IRQ0);
+	kunmap_atomic(rndisHeader - Packet->PageBuffers[0].Offset);
 
 	DumpRndisMessage(&rndisMessage);
 
Index: linux-2.6/drivers/staging/hv/storvsc_drv.c
===================================================================
--- linux-2.6.orig/drivers/staging/hv/storvsc_drv.c
+++ linux-2.6/drivers/staging/hv/storvsc_drv.c
@@ -496,7 +496,7 @@ static unsigned int copy_to_bounce_buffe
 		/* ASSERT(orig_sgl[i].offset + orig_sgl[i].length <= PAGE_SIZE); */
 
 		if (j == 0)
-			bounce_addr = (unsigned long)kmap_atomic(sg_page((&bounce_sgl[j])), KM_IRQ0);
+			bounce_addr = (unsigned long)kmap_atomic(sg_page((&bounce_sgl[j])));
 
 		while (srclen) {
 			/* assume bounce offset always == 0 */
@@ -513,19 +513,19 @@ static unsigned int copy_to_bounce_buffe
 
 			if (bounce_sgl[j].length == PAGE_SIZE) {
 				/* full..move to next entry */
-				kunmap_atomic((void *)bounce_addr, KM_IRQ0);
+				kunmap_atomic((void *)bounce_addr);
 				j++;
 
 				/* if we need to use another bounce buffer */
 				if (srclen || i != orig_sgl_count - 1)
-					bounce_addr = (unsigned long)kmap_atomic(sg_page((&bounce_sgl[j])), KM_IRQ0);
+					bounce_addr = (unsigned long)kmap_atomic(sg_page((&bounce_sgl[j])));
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
@@ -557,7 +557,7 @@ static unsigned int copy_from_bounce_buf
 		/* ASSERT(orig_sgl[i].offset + orig_sgl[i].length <= PAGE_SIZE); */
 
 		if (j == 0)
-			bounce_addr = (unsigned long)kmap_atomic(sg_page((&bounce_sgl[j])), KM_IRQ0);
+			bounce_addr = (unsigned long)kmap_atomic(sg_page((&bounce_sgl[j])));
 
 		while (destlen) {
 			src = bounce_addr + bounce_sgl[j].offset;
@@ -573,15 +573,15 @@ static unsigned int copy_from_bounce_buf
 
 			if (bounce_sgl[j].offset == bounce_sgl[j].length) {
 				/* full */
-				kunmap_atomic((void *)bounce_addr, KM_IRQ0);
+				kunmap_atomic((void *)bounce_addr);
 				j++;
 
 				/* if we need to use another bounce buffer */
 				if (destlen || i != orig_sgl_count - 1)
-					bounce_addr = (unsigned long)kmap_atomic(sg_page((&bounce_sgl[j])), KM_IRQ0);
+					bounce_addr = (unsigned long)kmap_atomic(sg_page((&bounce_sgl[j])));
 			} else if (destlen == 0 && i == orig_sgl_count - 1) {
 				/* unmap the last bounce that is < PAGE_SIZE */
-				kunmap_atomic((void *)bounce_addr, KM_IRQ0);
+				kunmap_atomic((void *)bounce_addr);
 			}
 		}
 
Index: linux-2.6/drivers/staging/pohmelfs/inode.c
===================================================================
--- linux-2.6.orig/drivers/staging/pohmelfs/inode.c
+++ linux-2.6/drivers/staging/pohmelfs/inode.c
@@ -605,11 +605,11 @@ static int pohmelfs_write_begin(struct f
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
@@ -635,11 +635,11 @@ static int pohmelfs_write_end(struct fil
 
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
Index: linux-2.6/drivers/staging/zram/xvmalloc.c
===================================================================
--- linux-2.6.orig/drivers/staging/zram/xvmalloc.c
+++ linux-2.6/drivers/staging/zram/xvmalloc.c
@@ -50,7 +50,7 @@ static void clear_flag(struct block_head
  * This is called from xv_malloc/xv_free path, so it
  * needs to be fast.
  */
-static void *get_ptr_atomic(struct page *page, u16 offset, enum km_type type)
+static void *get_ptr_atomic(struct page *page, u16 offset)
 {
 	unsigned char *base;
 
@@ -58,7 +58,7 @@ static void *get_ptr_atomic(struct page 
 	return base + offset;
 }
 
-static void put_ptr_atomic(void *ptr, enum km_type type)
+static void put_ptr_atomic(void *ptr)
 {
 	kunmap_atomic(ptr, type);
 }
@@ -196,10 +196,10 @@ static void insert_block(struct xv_pool 
 
 	if (block->link.next_page) {
 		nextblock = get_ptr_atomic(block->link.next_page,
-					block->link.next_offset, KM_USER1);
+					block->link.next_offset);
 		nextblock->link.prev_page = page;
 		nextblock->link.prev_offset = offset;
-		put_ptr_atomic(nextblock, KM_USER1);
+		put_ptr_atomic(nextblock);
 	}
 
 	__set_bit(slindex % BITS_PER_LONG, &pool->slbitmap[flindex]);
@@ -231,10 +231,10 @@ static void remove_block_head(struct xv_
 		 * sanity, lets do it.
 		 */
 		tmpblock = get_ptr_atomic(pool->freelist[slindex].page,
-				pool->freelist[slindex].offset, KM_USER1);
+				pool->freelist[slindex].offset);
 		tmpblock->link.prev_page = 0;
 		tmpblock->link.prev_offset = 0;
-		put_ptr_atomic(tmpblock, KM_USER1);
+		put_ptr_atomic(tmpblock);
 	}
 }
 
@@ -257,18 +257,18 @@ static void remove_block(struct xv_pool 
 
 	if (block->link.prev_page) {
 		tmpblock = get_ptr_atomic(block->link.prev_page,
-				block->link.prev_offset, KM_USER1);
+				block->link.prev_offset);
 		tmpblock->link.next_page = block->link.next_page;
 		tmpblock->link.next_offset = block->link.next_offset;
-		put_ptr_atomic(tmpblock, KM_USER1);
+		put_ptr_atomic(tmpblock);
 	}
 
 	if (block->link.next_page) {
 		tmpblock = get_ptr_atomic(block->link.next_page,
-				block->link.next_offset, KM_USER1);
+				block->link.next_offset);
 		tmpblock->link.prev_page = block->link.prev_page;
 		tmpblock->link.prev_offset = block->link.prev_offset;
-		put_ptr_atomic(tmpblock, KM_USER1);
+		put_ptr_atomic(tmpblock);
 	}
 }
 
@@ -287,7 +287,7 @@ static int grow_pool(struct xv_pool *poo
 	stat_inc(&pool->total_pages);
 
 	spin_lock(&pool->lock);
-	block = get_ptr_atomic(page, 0, KM_USER0);
+	block = get_ptr_atomic(page, 0);
 
 	block->size = PAGE_SIZE - XV_ALIGN;
 	set_flag(block, BLOCK_FREE);
@@ -296,7 +296,7 @@ static int grow_pool(struct xv_pool *poo
 
 	insert_block(pool, page, 0, block);
 
-	put_ptr_atomic(block, KM_USER0);
+	put_ptr_atomic(block);
 	spin_unlock(&pool->lock);
 
 	return 0;
@@ -376,7 +376,7 @@ int xv_malloc(struct xv_pool *pool, u32 
 		return -ENOMEM;
 	}
 
-	block = get_ptr_atomic(*page, *offset, KM_USER0);
+	block = get_ptr_atomic(*page, *offset);
 
 	remove_block_head(pool, block, index);
 
@@ -406,7 +406,7 @@ int xv_malloc(struct xv_pool *pool, u32 
 	block->size = origsize;
 	clear_flag(block, BLOCK_FREE);
 
-	put_ptr_atomic(block, KM_USER0);
+	put_ptr_atomic(block);
 	spin_unlock(&pool->lock);
 
 	*offset += XV_ALIGN;
@@ -426,7 +426,7 @@ void xv_free(struct xv_pool *pool, struc
 
 	spin_lock(&pool->lock);
 
-	page_start = get_ptr_atomic(page, 0, KM_USER0);
+	page_start = get_ptr_atomic(page, 0);
 	block = (struct block_header *)((char *)page_start + offset);
 
 	/* Catch double free bugs */
@@ -468,7 +468,7 @@ void xv_free(struct xv_pool *pool, struc
 
 	/* No used objects in this page. Free it. */
 	if (block->size == PAGE_SIZE - XV_ALIGN) {
-		put_ptr_atomic(page_start, KM_USER0);
+		put_ptr_atomic(page_start);
 		spin_unlock(&pool->lock);
 
 		__free_page(page);
@@ -486,7 +486,7 @@ void xv_free(struct xv_pool *pool, struc
 		set_blockprev(tmpblock, offset);
 	}
 
-	put_ptr_atomic(page_start, KM_USER0);
+	put_ptr_atomic(page_start);
 	spin_unlock(&pool->lock);
 }
 
Index: linux-2.6/drivers/staging/zram/zram_drv.c
===================================================================
--- linux-2.6.orig/drivers/staging/zram/zram_drv.c
+++ linux-2.6/drivers/staging/zram/zram_drv.c
@@ -171,9 +171,9 @@ static void zram_free_page(struct zram *
 		goto out;
 	}
 
-	obj = kmap_atomic(page, KM_USER0) + offset;
+	obj = kmap_atomic(page) + offset;
 	clen = xv_get_object_size(obj) - sizeof(struct zobj_header);
-	kunmap_atomic(obj, KM_USER0);
+	kunmap_atomic(obj);
 
 	xv_free(zram->mem_pool, page, offset);
 	if (clen <= PAGE_SIZE / 2)
@@ -191,9 +191,9 @@ static void handle_zero_page(struct page
 {
 	void *user_mem;
 
-	user_mem = kmap_atomic(page, KM_USER0);
+	user_mem = kmap_atomic(page);
 	memset(user_mem, 0, PAGE_SIZE);
-	kunmap_atomic(user_mem, KM_USER0);
+	kunmap_atomic(user_mem);
 
 	flush_dcache_page(page);
 }
@@ -203,13 +203,13 @@ static void handle_uncompressed_page(str
 {
 	unsigned char *user_mem, *cmem;
 
-	user_mem = kmap_atomic(page, KM_USER0);
-	cmem = kmap_atomic(zram->table[index].page, KM_USER1) +
+	user_mem = kmap_atomic(page);
+	cmem = kmap_atomic(zram->table[index].page) +
 			zram->table[index].offset;
 
 	memcpy(user_mem, cmem, PAGE_SIZE);
-	kunmap_atomic(user_mem, KM_USER0);
-	kunmap_atomic(cmem, KM_USER1);
+	kunmap_atomic(user_mem);
+	kunmap_atomic(cmem);
 
 	flush_dcache_page(page);
 }
@@ -252,10 +252,10 @@ static int zram_read(struct zram *zram, 
 			continue;
 		}
 
-		user_mem = kmap_atomic(page, KM_USER0);
+		user_mem = kmap_atomic(page);
 		clen = PAGE_SIZE;
 
-		cmem = kmap_atomic(zram->table[index].page, KM_USER1) +
+		cmem = kmap_atomic(zram->table[index].page) +
 				zram->table[index].offset;
 
 		ret = lzo1x_decompress_safe(
@@ -263,8 +263,8 @@ static int zram_read(struct zram *zram, 
 			xv_get_object_size(cmem) - sizeof(*zheader),
 			user_mem, &clen);
 
-		kunmap_atomic(user_mem, KM_USER0);
-		kunmap_atomic(cmem, KM_USER1);
+		kunmap_atomic(user_mem);
+		kunmap_atomic(cmem);
 
 		/* Should NEVER happen. Return bio error if it does. */
 		if (unlikely(ret != LZO_E_OK)) {
@@ -318,9 +318,9 @@ static int zram_write(struct zram *zram,
 
 		mutex_lock(&zram->lock);
 
-		user_mem = kmap_atomic(page, KM_USER0);
+		user_mem = kmap_atomic(page);
 		if (page_zero_filled(user_mem)) {
-			kunmap_atomic(user_mem, KM_USER0);
+			kunmap_atomic(user_mem);
 			mutex_unlock(&zram->lock);
 			zram_stat_inc(&zram->stats.pages_zero);
 			zram_set_flag(zram, index, ZRAM_ZERO);
@@ -330,7 +330,7 @@ static int zram_write(struct zram *zram,
 		ret = lzo1x_1_compress(user_mem, PAGE_SIZE, src, &clen,
 					zram->compress_workmem);
 
-		kunmap_atomic(user_mem, KM_USER0);
+		kunmap_atomic(user_mem);
 
 		if (unlikely(ret != LZO_E_OK)) {
 			mutex_unlock(&zram->lock);
@@ -360,7 +360,7 @@ static int zram_write(struct zram *zram,
 			zram_set_flag(zram, index, ZRAM_UNCOMPRESSED);
 			zram_stat_inc(&zram->stats.pages_expand);
 			zram->table[index].page = page_store;
-			src = kmap_atomic(page, KM_USER0);
+			src = kmap_atomic(page);
 			goto memstore;
 		}
 
@@ -377,7 +377,7 @@ static int zram_write(struct zram *zram,
 memstore:
 		zram->table[index].offset = offset;
 
-		cmem = kmap_atomic(zram->table[index].page, KM_USER1) +
+		cmem = kmap_atomic(zram->table[index].page) +
 				zram->table[index].offset;
 
 #if 0
@@ -391,9 +391,9 @@ memstore:
 
 		memcpy(cmem, src, clen);
 
-		kunmap_atomic(cmem, KM_USER1);
+		kunmap_atomic(cmem);
 		if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED)))
-			kunmap_atomic(src, KM_USER0);
+			kunmap_atomic(src);
 
 		/* Update stats */
 		zram->stats.compr_size += clen;
Index: linux-2.6/drivers/vhost/vhost.c
===================================================================
--- linux-2.6.orig/drivers/vhost/vhost.c
+++ linux-2.6/drivers/vhost/vhost.c
@@ -774,9 +774,9 @@ static int set_bit_to_user(int nr, void 
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
Index: linux-2.6/fs/afs/fsclient.c
===================================================================
--- linux-2.6.orig/fs/afs/fsclient.c
+++ linux-2.6/fs/afs/fsclient.c
@@ -364,10 +364,10 @@ static int afs_deliver_fs_fetch_data(str
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
@@ -410,9 +410,9 @@ static int afs_deliver_fs_fetch_data(str
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
Index: linux-2.6/fs/afs/mntpt.c
===================================================================
--- linux-2.6.orig/fs/afs/mntpt.c
+++ linux-2.6/fs/afs/mntpt.c
@@ -201,9 +201,9 @@ static struct vfsmount *afs_mntpt_do_aut
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
Index: linux-2.6/fs/aio.c
===================================================================
--- linux-2.6.orig/fs/aio.c
+++ linux-2.6/fs/aio.c
@@ -171,7 +171,7 @@ static int aio_setup_ring(struct kioctx 
 
 	info->nr = nr_events;		/* trusted copy */
 
-	ring = kmap_atomic(info->ring_pages[0], KM_USER0);
+	ring = kmap_atomic(info->ring_pages[0]);
 	ring->nr = nr_events;	/* user copy */
 	ring->id = ctx->user_id;
 	ring->head = ring->tail = 0;
@@ -179,7 +179,7 @@ static int aio_setup_ring(struct kioctx 
 	ring->compat_features = AIO_RING_COMPAT_FEATURES;
 	ring->incompat_features = AIO_RING_INCOMPAT_FEATURES;
 	ring->header_length = sizeof(struct aio_ring);
-	kunmap_atomic(ring, KM_USER0);
+	kunmap_atomic(ring);
 
 	return 0;
 }
@@ -466,13 +466,13 @@ static struct kiocb *__aio_get_req(struc
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
@@ -946,10 +946,10 @@ int aio_complete(struct kiocb *iocb, lon
 	if (kiocbIsCancelled(iocb))
 		goto put_rq;
 
-	ring = kmap_atomic(info->ring_pages[0], KM_IRQ1);
+	ring = kmap_atomic(info->ring_pages[0]);
 
 	tail = info->tail;
-	event = aio_ring_event(info, tail, KM_IRQ0);
+	event = aio_ring_event(info, tail);
 	if (++tail >= info->nr)
 		tail = 0;
 
@@ -970,8 +970,8 @@ int aio_complete(struct kiocb *iocb, lon
 	info->tail = tail;
 	ring->tail = tail;
 
-	put_aio_ring_event(event, KM_IRQ0);
-	kunmap_atomic(ring, KM_IRQ1);
+	put_aio_ring_event(event);
+	kunmap_atomic(ring);
 
 	pr_debug("added to ring %p at [%lu]\n", iocb, tail);
 
@@ -1016,7 +1016,7 @@ static int aio_read_evt(struct kioctx *i
 	unsigned long head;
 	int ret = 0;
 
-	ring = kmap_atomic(info->ring_pages[0], KM_USER0);
+	ring = kmap_atomic(info->ring_pages[0]);
 	dprintk("in aio_read_evt h%lu t%lu m%lu\n",
 		 (unsigned long)ring->head, (unsigned long)ring->tail,
 		 (unsigned long)ring->nr);
@@ -1028,18 +1028,18 @@ static int aio_read_evt(struct kioctx *i
 
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
Index: linux-2.6/fs/bio-integrity.c
===================================================================
--- linux-2.6.orig/fs/bio-integrity.c
+++ linux-2.6/fs/bio-integrity.c
@@ -356,7 +356,7 @@ static void bio_integrity_generate(struc
 	bix.sector_size = bi->sector_size;
 
 	bio_for_each_segment(bv, bio, i) {
-		void *kaddr = kmap_atomic(bv->bv_page, KM_USER0);
+		void *kaddr = kmap_atomic(bv->bv_page);
 		bix.data_buf = kaddr + bv->bv_offset;
 		bix.data_size = bv->bv_len;
 		bix.prot_buf = prot_buf;
@@ -370,7 +370,7 @@ static void bio_integrity_generate(struc
 		total += sectors * bi->tuple_size;
 		BUG_ON(total > bio->bi_integrity->bip_size);
 
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 }
 
@@ -497,7 +497,7 @@ static int bio_integrity_verify(struct b
 	bix.sector_size = bi->sector_size;
 
 	bio_for_each_segment(bv, bio, i) {
-		void *kaddr = kmap_atomic(bv->bv_page, KM_USER0);
+		void *kaddr = kmap_atomic(bv->bv_page);
 		bix.data_buf = kaddr + bv->bv_offset;
 		bix.data_size = bv->bv_len;
 		bix.prot_buf = prot_buf;
@@ -506,7 +506,7 @@ static int bio_integrity_verify(struct b
 		ret = bi->verify_fn(&bix);
 
 		if (ret) {
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 			return ret;
 		}
 
@@ -516,7 +516,7 @@ static int bio_integrity_verify(struct b
 		total += sectors * bi->tuple_size;
 		BUG_ON(total > bio->bi_integrity->bip_size);
 
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 
 	return ret;
Index: linux-2.6/fs/btrfs/compression.c
===================================================================
--- linux-2.6.orig/fs/btrfs/compression.c
+++ linux-2.6/fs/btrfs/compression.c
@@ -129,10 +129,10 @@ static int check_compressed_csum(struct 
 		page = cb->compressed_pages[i];
 		csum = ~(u32)0;
 
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		csum = btrfs_csum_data(root, kaddr, csum, PAGE_CACHE_SIZE);
 		btrfs_csum_final(csum, (char *)&csum);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 
 		if (csum != *cb_sum) {
 			printk(KERN_INFO "btrfs csum failed ino %lu "
@@ -518,10 +518,10 @@ static noinline int add_ra_bio_pages(str
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
 
Index: linux-2.6/fs/btrfs/ctree.c
===================================================================
--- linux-2.6.orig/fs/btrfs/ctree.c
+++ linux-2.6/fs/btrfs/ctree.c
@@ -885,14 +885,14 @@ static noinline int generic_bin_search(s
 		    (offset + sizeof(struct btrfs_disk_key)) >
 		    map_start + map_len) {
 			if (map_token) {
-				unmap_extent_buffer(eb, map_token, KM_USER0);
+				unmap_extent_buffer(eb, map_token);
 				map_token = NULL;
 			}
 
 			err = map_private_extent_buffer(eb, offset,
 						sizeof(struct btrfs_disk_key),
 						&map_token, &kaddr,
-						&map_start, &map_len, KM_USER0);
+						&map_start, &map_len);
 
 			if (!err) {
 				tmp = (struct btrfs_disk_key *)(kaddr + offset -
@@ -916,13 +916,13 @@ static noinline int generic_bin_search(s
 		else {
 			*slot = mid;
 			if (map_token)
-				unmap_extent_buffer(eb, map_token, KM_USER0);
+				unmap_extent_buffer(eb, map_token);
 			return 0;
 		}
 	}
 	*slot = low;
 	if (map_token)
-		unmap_extent_buffer(eb, map_token, KM_USER0);
+		unmap_extent_buffer(eb, map_token);
 	return 1;
 }
 
@@ -2374,7 +2374,7 @@ static noinline int __push_leaf_right(st
 		i--;
 	}
 	if (left->map_token) {
-		unmap_extent_buffer(left, left->map_token, KM_USER1);
+		unmap_extent_buffer(left, left->map_token);
 		left->map_token = NULL;
 	}
 
@@ -2430,7 +2430,7 @@ static noinline int __push_leaf_right(st
 	}
 
 	if (right->map_token) {
-		unmap_extent_buffer(right, right->map_token, KM_USER1);
+		unmap_extent_buffer(right, right->map_token);
 		right->map_token = NULL;
 	}
 	left_nritems -= push_items;
@@ -2599,7 +2599,7 @@ static noinline int __push_leaf_left(str
 	}
 
 	if (right->map_token) {
-		unmap_extent_buffer(right, right->map_token, KM_USER1);
+		unmap_extent_buffer(right, right->map_token);
 		right->map_token = NULL;
 	}
 
@@ -2646,7 +2646,7 @@ static noinline int __push_leaf_left(str
 	}
 	btrfs_set_header_nritems(left, old_left_nritems + push_items);
 	if (left->map_token) {
-		unmap_extent_buffer(left, left->map_token, KM_USER1);
+		unmap_extent_buffer(left, left->map_token);
 		left->map_token = NULL;
 	}
 
@@ -2688,7 +2688,7 @@ static noinline int __push_leaf_left(str
 		btrfs_set_item_offset(right, item, push_space);
 	}
 	if (right->map_token) {
-		unmap_extent_buffer(right, right->map_token, KM_USER1);
+		unmap_extent_buffer(right, right->map_token);
 		right->map_token = NULL;
 	}
 
@@ -2841,7 +2841,7 @@ static noinline int copy_for_split(struc
 	}
 
 	if (right->map_token) {
-		unmap_extent_buffer(right, right->map_token, KM_USER1);
+		unmap_extent_buffer(right, right->map_token);
 		right->map_token = NULL;
 	}
 
@@ -3379,7 +3379,7 @@ int btrfs_truncate_item(struct btrfs_tra
 	}
 
 	if (leaf->map_token) {
-		unmap_extent_buffer(leaf, leaf->map_token, KM_USER1);
+		unmap_extent_buffer(leaf, leaf->map_token);
 		leaf->map_token = NULL;
 	}
 
@@ -3495,7 +3495,7 @@ int btrfs_extend_item(struct btrfs_trans
 	}
 
 	if (leaf->map_token) {
-		unmap_extent_buffer(leaf, leaf->map_token, KM_USER1);
+		unmap_extent_buffer(leaf, leaf->map_token);
 		leaf->map_token = NULL;
 	}
 
@@ -3618,7 +3618,7 @@ int btrfs_insert_some_items(struct btrfs
 			btrfs_set_item_offset(leaf, item, ioff - total_data);
 		}
 		if (leaf->map_token) {
-			unmap_extent_buffer(leaf, leaf->map_token, KM_USER1);
+			unmap_extent_buffer(leaf, leaf->map_token);
 			leaf->map_token = NULL;
 		}
 
@@ -3733,7 +3733,7 @@ setup_items_for_insert(struct btrfs_tran
 			btrfs_set_item_offset(leaf, item, ioff - total_data);
 		}
 		if (leaf->map_token) {
-			unmap_extent_buffer(leaf, leaf->map_token, KM_USER1);
+			unmap_extent_buffer(leaf, leaf->map_token);
 			leaf->map_token = NULL;
 		}
 
@@ -3962,7 +3962,7 @@ int btrfs_del_items(struct btrfs_trans_h
 		}
 
 		if (leaf->map_token) {
-			unmap_extent_buffer(leaf, leaf->map_token, KM_USER1);
+			unmap_extent_buffer(leaf, leaf->map_token);
 			leaf->map_token = NULL;
 		}
 
Index: linux-2.6/fs/btrfs/ctree.h
===================================================================
--- linux-2.6.orig/fs/btrfs/ctree.h
+++ linux-2.6/fs/btrfs/ctree.h
@@ -1241,17 +1241,17 @@ void btrfs_set_##name(struct extent_buff
 #define BTRFS_SETGET_HEADER_FUNCS(name, type, member, bits)		\
 static inline u##bits btrfs_##name(struct extent_buffer *eb)		\
 {									\
-	type *p = kmap_atomic(eb->first_page, KM_USER0);		\
+	type *p = kmap_atomic(eb->first_page);		\
 	u##bits res = le##bits##_to_cpu(p->member);			\
-	kunmap_atomic(p, KM_USER0);					\
+	kunmap_atomic(p);					\
 	return res;							\
 }									\
 static inline void btrfs_set_##name(struct extent_buffer *eb,		\
 				    u##bits val)			\
 {									\
-	type *p = kmap_atomic(eb->first_page, KM_USER0);		\
+	type *p = kmap_atomic(eb->first_page);		\
 	p->member = cpu_to_le##bits(val);				\
-	kunmap_atomic(p, KM_USER0);					\
+	kunmap_atomic(p);					\
 }
 
 #define BTRFS_SETGET_STACK_FUNCS(name, type, member, bits)		\
Index: linux-2.6/fs/btrfs/disk-io.c
===================================================================
--- linux-2.6.orig/fs/btrfs/disk-io.c
+++ linux-2.6/fs/btrfs/disk-io.c
@@ -211,7 +211,7 @@ static int csum_tree_block(struct btrfs_
 	while (len > 0) {
 		err = map_private_extent_buffer(buf, offset, 32,
 					&map_token, &kaddr,
-					&map_start, &map_len, KM_USER0);
+					&map_start, &map_len);
 		if (err)
 			return 1;
 		cur_len = min(len, map_len - (offset - map_start));
@@ -219,7 +219,7 @@ static int csum_tree_block(struct btrfs_
 				      crc, cur_len);
 		len -= cur_len;
 		offset += cur_len;
-		unmap_extent_buffer(buf, map_token, KM_USER0);
+		unmap_extent_buffer(buf, map_token);
 	}
 	if (csum_size > sizeof(inline_result)) {
 		result = kzalloc(csum_size * sizeof(char), GFP_NOFS);
Index: linux-2.6/fs/btrfs/extent_io.c
===================================================================
--- linux-2.6.orig/fs/btrfs/extent_io.c
+++ linux-2.6/fs/btrfs/extent_io.c
@@ -2044,20 +2044,20 @@ static int __extent_read_full_page(struc
 
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
 		if (cur >= last_byte) {
 			char *userpage;
 			iosize = PAGE_CACHE_SIZE - page_offset;
-			userpage = kmap_atomic(page, KM_USER0);
+			userpage = kmap_atomic(page);
 			memset(userpage + page_offset, 0, iosize);
 			flush_dcache_page(page);
-			kunmap_atomic(userpage, KM_USER0);
+			kunmap_atomic(userpage);
 			set_extent_uptodate(tree, cur, cur + iosize - 1,
 					    GFP_NOFS);
 			unlock_extent(tree, cur, cur + iosize - 1, GFP_NOFS);
@@ -2097,10 +2097,10 @@ static int __extent_read_full_page(struc
 		/* we've found a hole, just zero and go on */
 		if (block_start == EXTENT_MAP_HOLE) {
 			char *userpage;
-			userpage = kmap_atomic(page, KM_USER0);
+			userpage = kmap_atomic(page);
 			memset(userpage + page_offset, 0, iosize);
 			flush_dcache_page(page);
-			kunmap_atomic(userpage, KM_USER0);
+			kunmap_atomic(userpage);
 
 			set_extent_uptodate(tree, cur, cur + iosize - 1,
 					    GFP_NOFS);
@@ -2239,10 +2239,10 @@ static int __extent_writepage(struct pag
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
@@ -2789,14 +2789,14 @@ int extent_prepare_write(struct extent_i
 		    (block_off_end > to || block_off_start < from)) {
 			void *kaddr;
 
-			kaddr = kmap_atomic(page, KM_USER0);
+			kaddr = kmap_atomic(page);
 			if (block_off_end > to)
 				memset(kaddr + to, 0, block_off_end - to);
 			if (block_off_start < from)
 				memset(kaddr + block_off_start, 0,
 				       from - block_off_start);
 			flush_dcache_page(page);
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 		}
 		if ((em->block_start != EXTENT_MAP_HOLE &&
 		     em->block_start != EXTENT_MAP_INLINE) &&
@@ -3490,9 +3490,9 @@ void read_extent_buffer(struct extent_bu
 		page = extent_buffer_page(eb, i);
 
 		cur = min(len, (PAGE_CACHE_SIZE - offset));
-		kaddr = kmap_atomic(page, KM_USER1);
+		kaddr = kmap_atomic(page);
 		memcpy(dst, kaddr + offset, cur);
-		kunmap_atomic(kaddr, KM_USER1);
+		kunmap_atomic(kaddr);
 
 		dst += cur;
 		len -= cur;
@@ -3592,9 +3592,9 @@ int memcmp_extent_buffer(struct extent_b
 
 		cur = min(len, (PAGE_CACHE_SIZE - offset));
 
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		ret = memcmp(ptr, kaddr + offset, cur);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		if (ret)
 			break;
 
@@ -3627,9 +3627,9 @@ void write_extent_buffer(struct extent_b
 		WARN_ON(!PageUptodate(page));
 
 		cur = min(len, PAGE_CACHE_SIZE - offset);
-		kaddr = kmap_atomic(page, KM_USER1);
+		kaddr = kmap_atomic(page);
 		memcpy(kaddr + offset, src, cur);
-		kunmap_atomic(kaddr, KM_USER1);
+		kunmap_atomic(kaddr);
 
 		src += cur;
 		len -= cur;
@@ -3658,9 +3658,9 @@ void memset_extent_buffer(struct extent_
 		WARN_ON(!PageUptodate(page));
 
 		cur = min(len, PAGE_CACHE_SIZE - offset);
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		memset(kaddr + offset, c, cur);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 
 		len -= cur;
 		offset = 0;
@@ -3691,9 +3691,9 @@ void copy_extent_buffer(struct extent_bu
 
 		cur = min(len, (unsigned long)(PAGE_CACHE_SIZE - offset));
 
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		read_extent_buffer(src, kaddr + offset, src_offset, cur);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 
 		src_offset += cur;
 		len -= cur;
@@ -3706,38 +3706,38 @@ static void move_pages(struct page *dst_
 		       unsigned long dst_off, unsigned long src_off,
 		       unsigned long len)
 {
-	char *dst_kaddr = kmap_atomic(dst_page, KM_USER0);
+	char *dst_kaddr = kmap_atomic(dst_page);
 	if (dst_page == src_page) {
 		memmove(dst_kaddr + dst_off, dst_kaddr + src_off, len);
 	} else {
-		char *src_kaddr = kmap_atomic(src_page, KM_USER1);
+		char *src_kaddr = kmap_atomic(src_page);
 		char *p = dst_kaddr + dst_off + len;
 		char *s = src_kaddr + src_off + len;
 
 		while (len--)
 			*--p = *--s;
 
-		kunmap_atomic(src_kaddr, KM_USER1);
+		kunmap_atomic(src_kaddr);
 	}
-	kunmap_atomic(dst_kaddr, KM_USER0);
+	kunmap_atomic(dst_kaddr);
 }
 
 static void copy_pages(struct page *dst_page, struct page *src_page,
 		       unsigned long dst_off, unsigned long src_off,
 		       unsigned long len)
 {
-	char *dst_kaddr = kmap_atomic(dst_page, KM_USER0);
+	char *dst_kaddr = kmap_atomic(dst_page);
 	char *src_kaddr;
 
 	if (dst_page != src_page)
-		src_kaddr = kmap_atomic(src_page, KM_USER1);
+		src_kaddr = kmap_atomic(src_page);
 	else
 		src_kaddr = dst_kaddr;
 
 	memcpy(dst_kaddr + dst_off, src_kaddr + src_off, len);
-	kunmap_atomic(dst_kaddr, KM_USER0);
+	kunmap_atomic(dst_kaddr);
 	if (dst_page != src_page)
-		kunmap_atomic(src_kaddr, KM_USER1);
+		kunmap_atomic(src_kaddr);
 }
 
 void memcpy_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
Index: linux-2.6/fs/btrfs/file-item.c
===================================================================
--- linux-2.6.orig/fs/btrfs/file-item.c
+++ linux-2.6/fs/btrfs/file-item.c
@@ -427,13 +427,13 @@ int btrfs_csum_one_bio(struct btrfs_root
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
@@ -808,12 +808,12 @@ next_sector:
 		int err;
 
 		if (eb_token)
-			unmap_extent_buffer(leaf, eb_token, KM_USER1);
+			unmap_extent_buffer(leaf, eb_token);
 		eb_token = NULL;
 		err = map_private_extent_buffer(leaf, (unsigned long)item,
 						csum_size,
 						&eb_token, &eb_map,
-						&map_start, &map_len, KM_USER1);
+						&map_start, &map_len);
 		if (err)
 			eb_token = NULL;
 	}
@@ -837,7 +837,7 @@ next_sector:
 		}
 	}
 	if (eb_token) {
-		unmap_extent_buffer(leaf, eb_token, KM_USER1);
+		unmap_extent_buffer(leaf, eb_token);
 		eb_token = NULL;
 	}
 	btrfs_mark_buffer_dirty(path->nodes[0]);
Index: linux-2.6/fs/btrfs/inode.c
===================================================================
--- linux-2.6.orig/fs/btrfs/inode.c
+++ linux-2.6/fs/btrfs/inode.c
@@ -167,9 +167,9 @@ static noinline int insert_inline_extent
 			cur_size = min_t(unsigned long, compressed_size,
 				       PAGE_CACHE_SIZE);
 
-			kaddr = kmap_atomic(cpage, KM_USER0);
+			kaddr = kmap_atomic(cpage);
 			write_extent_buffer(leaf, kaddr, ptr, cur_size);
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 
 			i++;
 			ptr += cur_size;
@@ -181,10 +181,10 @@ static noinline int insert_inline_extent
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
@@ -403,10 +403,10 @@ again:
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
@@ -1922,7 +1922,7 @@ static int btrfs_readpage_end_io_hook(st
 	} else {
 		ret = get_state_private(io_tree, start, &private);
 	}
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	if (ret)
 		goto zeroit;
 
@@ -1931,7 +1931,7 @@ static int btrfs_readpage_end_io_hook(st
 	if (csum != private)
 		goto zeroit;
 
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 good:
 	/* if the io failure tree for this inode is non-empty,
 	 * check to see if we've recovered from a failed IO
@@ -1948,7 +1948,7 @@ zeroit:
 	}
 	memset(kaddr + offset, 1, end - start + 1);
 	flush_dcache_page(page);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	if (private == 0)
 		return 0;
 	return -EIO;
@@ -4900,12 +4900,12 @@ static noinline int uncompress_inline(st
 	ret = btrfs_zlib_decompress(tmp, page, extent_offset,
 				    inline_size, max_size);
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
@@ -5511,11 +5511,11 @@ static void btrfs_endio_direct_read(stru
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
Index: linux-2.6/fs/btrfs/struct-funcs.c
===================================================================
--- linux-2.6.orig/fs/btrfs/struct-funcs.c
+++ linux-2.6/fs/btrfs/struct-funcs.c
@@ -68,7 +68,7 @@ u##bits btrfs_##name(struct extent_buffe
 		err = map_extent_buffer(eb, offset,			\
 				sizeof(((type *)0)->member),		\
 				&map_token, &kaddr,			\
-				&map_start, &map_len, KM_USER1);	\
+				&map_start, &map_len);	\
 		if (err) {						\
 			__le##bits leres;				\
 			read_eb_member(eb, s, type, member, &leres);	\
@@ -77,7 +77,7 @@ u##bits btrfs_##name(struct extent_buffe
 		p = (type *)(kaddr + part_offset - map_start);		\
 		res = le##bits##_to_cpu(p->member);			\
 		if (unmap_on_exit)					\
-			unmap_extent_buffer(eb, map_token, KM_USER1);	\
+			unmap_extent_buffer(eb, map_token);	\
 		return res;						\
 	}								\
 }									\
@@ -105,7 +105,7 @@ void btrfs_set_##name(struct extent_buff
 		err = map_extent_buffer(eb, offset,			\
 				sizeof(((type *)0)->member),		\
 				&map_token, &kaddr,			\
-				&map_start, &map_len, KM_USER1);	\
+				&map_start, &map_len);	\
 		if (err) {						\
 			__le##bits val2;				\
 			val2 = cpu_to_le##bits(val);			\
@@ -115,7 +115,7 @@ void btrfs_set_##name(struct extent_buff
 		p = (type *)(kaddr + part_offset - map_start);		\
 		p->member = cpu_to_le##bits(val);			\
 		if (unmap_on_exit)					\
-			unmap_extent_buffer(eb, map_token, KM_USER1);	\
+			unmap_extent_buffer(eb, map_token);	\
 	}								\
 }
 
@@ -131,7 +131,7 @@ void btrfs_node_key(struct extent_buffer
 			sizeof(*disk_key));
 		return;
 	} else if (eb->map_token) {
-		unmap_extent_buffer(eb, eb->map_token, KM_USER1);
+		unmap_extent_buffer(eb, eb->map_token);
 		eb->map_token = NULL;
 	}
 	read_eb_member(eb, (struct btrfs_key_ptr *)ptr,
Index: linux-2.6/fs/btrfs/zlib.c
===================================================================
--- linux-2.6.orig/fs/btrfs/zlib.c
+++ linux-2.6/fs/btrfs/zlib.c
@@ -448,10 +448,10 @@ int btrfs_zlib_decompress_biovec(struct 
 			bytes = min(PAGE_CACHE_SIZE - pg_offset,
 				    PAGE_CACHE_SIZE - buf_offset);
 			bytes = min(bytes, working_bytes);
-			kaddr = kmap_atomic(page_out, KM_USER0);
+			kaddr = kmap_atomic(page_out);
 			memcpy(kaddr + pg_offset, workspace->buf + buf_offset,
 			       bytes);
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 			flush_dcache_page(page_out);
 
 			pg_offset += bytes;
@@ -604,9 +604,9 @@ int btrfs_zlib_decompress(unsigned char 
 			    PAGE_CACHE_SIZE - buf_offset);
 		bytes = min(bytes, bytes_left);
 
-		kaddr = kmap_atomic(dest_page, KM_USER0);
+		kaddr = kmap_atomic(dest_page);
 		memcpy(kaddr + pg_offset, workspace->buf + buf_offset, bytes);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 
 		pg_offset += bytes;
 		bytes_left -= bytes;
Index: linux-2.6/fs/cifs/file.c
===================================================================
--- linux-2.6.orig/fs/cifs/file.c
+++ linux-2.6/fs/cifs/file.c
@@ -1926,7 +1926,7 @@ static void cifs_copy_cache_pages(struct
 		}
 		page_cache_release(page);
 
-		target = kmap_atomic(page, KM_USER0);
+		target = kmap_atomic(page);
 
 		if (PAGE_CACHE_SIZE > bytes_read) {
 			memcpy(target, data, bytes_read);
@@ -1938,7 +1938,7 @@ static void cifs_copy_cache_pages(struct
 			memcpy(target, data, PAGE_CACHE_SIZE);
 			bytes_read -= PAGE_CACHE_SIZE;
 		}
-		kunmap_atomic(target, KM_USER0);
+		kunmap_atomic(target);
 
 		flush_dcache_page(page);
 		SetPageUptodate(page);
Index: linux-2.6/fs/ecryptfs/mmap.c
===================================================================
--- linux-2.6.orig/fs/ecryptfs/mmap.c
+++ linux-2.6/fs/ecryptfs/mmap.c
@@ -134,7 +134,7 @@ ecryptfs_copy_up_encrypted_with_header(s
 			/* This is a header extent */
 			char *page_virt;
 
-			page_virt = kmap_atomic(page, KM_USER0);
+			page_virt = kmap_atomic(page);
 			memset(page_virt, 0, PAGE_CACHE_SIZE);
 			/* TODO: Support more than one header extent */
 			if (view_extent_num == 0) {
@@ -147,7 +147,7 @@ ecryptfs_copy_up_encrypted_with_header(s
 							       crypt_stat,
 							       &written);
 			}
-			kunmap_atomic(page_virt, KM_USER0);
+			kunmap_atomic(page_virt);
 			flush_dcache_page(page);
 			if (rc) {
 				printk(KERN_ERR "%s: Error reading xattr "
Index: linux-2.6/fs/ecryptfs/read_write.c
===================================================================
--- linux-2.6.orig/fs/ecryptfs/read_write.c
+++ linux-2.6/fs/ecryptfs/read_write.c
@@ -154,7 +154,7 @@ int ecryptfs_write(struct inode *ecryptf
 			       ecryptfs_page_idx, rc);
 			goto out;
 		}
-		ecryptfs_page_virt = kmap_atomic(ecryptfs_page, KM_USER0);
+		ecryptfs_page_virt = kmap_atomic(ecryptfs_page);
 
 		/*
 		 * pos: where we're now writing, offset: where the request was
@@ -177,7 +177,7 @@ int ecryptfs_write(struct inode *ecryptf
 			       (data + data_offset), num_bytes);
 			data_offset += num_bytes;
 		}
-		kunmap_atomic(ecryptfs_page_virt, KM_USER0);
+		kunmap_atomic(ecryptfs_page_virt);
 		flush_dcache_page(ecryptfs_page);
 		SetPageUptodate(ecryptfs_page);
 		unlock_page(ecryptfs_page);
@@ -336,11 +336,11 @@ int ecryptfs_read(char *data, loff_t off
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
Index: linux-2.6/fs/exec.c
===================================================================
--- linux-2.6.orig/fs/exec.c
+++ linux-2.6/fs/exec.c
@@ -1213,13 +1213,13 @@ int remove_arg_zero(struct linux_binprm 
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
Index: linux-2.6/fs/exofs/dir.c
===================================================================
--- linux-2.6.orig/fs/exofs/dir.c
+++ linux-2.6/fs/exofs/dir.c
@@ -594,7 +594,7 @@ int exofs_make_empty(struct inode *inode
 		goto fail;
 	}
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	de = (struct exofs_dir_entry *)kaddr;
 	de->name_len = 1;
 	de->rec_len = cpu_to_le16(EXOFS_DIR_REC_LEN(1));
@@ -608,7 +608,7 @@ int exofs_make_empty(struct inode *inode
 	de->inode_no = cpu_to_le64(parent->i_ino);
 	memcpy(de->name, PARENT_DIR, sizeof(PARENT_DIR));
 	exofs_set_de_type(de, inode);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	err = exofs_commit_chunk(page, 0, chunk_size);
 fail:
 	page_cache_release(page);
Index: linux-2.6/fs/ext2/dir.c
===================================================================
--- linux-2.6.orig/fs/ext2/dir.c
+++ linux-2.6/fs/ext2/dir.c
@@ -636,7 +636,7 @@ int ext2_make_empty(struct inode *inode,
 		unlock_page(page);
 		goto fail;
 	}
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memset(kaddr, 0, chunk_size);
 	de = (struct ext2_dir_entry_2 *)kaddr;
 	de->name_len = 1;
@@ -651,7 +651,7 @@ int ext2_make_empty(struct inode *inode,
 	de->inode = cpu_to_le32(parent->i_ino);
 	memcpy (de->name, "..\0", 4);
 	ext2_set_de_type (de, inode);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	err = ext2_commit_chunk(page, 0, chunk_size);
 fail:
 	page_cache_release(page);
Index: linux-2.6/fs/fuse/dev.c
===================================================================
--- linux-2.6.orig/fs/fuse/dev.c
+++ linux-2.6/fs/fuse/dev.c
@@ -810,9 +810,9 @@ static int fuse_copy_page(struct fuse_co
 	struct page *page = *pagep;
 
 	if (page && zeroing && count < PAGE_SIZE) {
-		void *mapaddr = kmap_atomic(page, KM_USER1);
+		void *mapaddr = kmap_atomic(page);
 		memset(mapaddr, 0, PAGE_SIZE);
-		kunmap_atomic(mapaddr, KM_USER1);
+		kunmap_atomic(mapaddr);
 	}
 	while (count) {
 		if (cs->write && cs->pipebufs && page) {
@@ -830,10 +830,10 @@ static int fuse_copy_page(struct fuse_co
 			}
 		}
 		if (page) {
-			void *mapaddr = kmap_atomic(page, KM_USER1);
+			void *mapaddr = kmap_atomic(page);
 			void *buf = mapaddr + offset;
 			offset += fuse_copy_do(cs, &buf, &count);
-			kunmap_atomic(mapaddr, KM_USER1);
+			kunmap_atomic(mapaddr);
 		} else
 			offset += fuse_copy_do(cs, NULL, &count);
 	}
Index: linux-2.6/fs/fuse/file.c
===================================================================
--- linux-2.6.orig/fs/fuse/file.c
+++ linux-2.6/fs/fuse/file.c
@@ -1803,9 +1803,9 @@ long fuse_do_ioctl(struct file *file, un
 			goto out;
 
 		/* okay, copy in iovs and retry */
-		vaddr = kmap_atomic(pages[0], KM_USER0);
+		vaddr = kmap_atomic(pages[0]);
 		memcpy(page_address(iov_page), vaddr, transferred);
-		kunmap_atomic(vaddr, KM_USER0);
+		kunmap_atomic(vaddr);
 
 		in_iov = page_address(iov_page);
 		out_iov = in_iov + in_iovs;
Index: linux-2.6/fs/gfs2/aops.c
===================================================================
--- linux-2.6.orig/fs/gfs2/aops.c
+++ linux-2.6/fs/gfs2/aops.c
@@ -434,12 +434,12 @@ static int stuffed_readpage(struct gfs2_
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
@@ -542,9 +542,9 @@ int gfs2_internal_read(struct gfs2_inode
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
@@ -790,11 +790,11 @@ static int gfs2_stuffed_write_end(struct
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
Index: linux-2.6/fs/gfs2/lops.c
===================================================================
--- linux-2.6.orig/fs/gfs2/lops.c
+++ linux-2.6/fs/gfs2/lops.c
@@ -545,11 +545,11 @@ static void gfs2_check_magic(struct buff
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
@@ -586,10 +586,10 @@ static void gfs2_write_blocks(struct gfs
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
Index: linux-2.6/fs/gfs2/quota.c
===================================================================
--- linux-2.6.orig/fs/gfs2/quota.c
+++ linux-2.6/fs/gfs2/quota.c
@@ -710,12 +710,12 @@ get_a_page:
 
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
 
Index: linux-2.6/fs/jbd/journal.c
===================================================================
--- linux-2.6.orig/fs/jbd/journal.c
+++ linux-2.6/fs/jbd/journal.c
@@ -323,7 +323,7 @@ repeat:
 		new_offset = offset_in_page(jh2bh(jh_in)->b_data);
 	}
 
-	mapped_data = kmap_atomic(new_page, KM_USER0);
+	mapped_data = kmap_atomic(new_page);
 	/*
 	 * Check for escaping
 	 */
@@ -332,7 +332,7 @@ repeat:
 		need_copy_out = 1;
 		do_escape = 1;
 	}
-	kunmap_atomic(mapped_data, KM_USER0);
+	kunmap_atomic(mapped_data);
 
 	/*
 	 * Do we need to do a data copy?
@@ -349,9 +349,9 @@ repeat:
 		}
 
 		jh_in->b_frozen_data = tmp;
-		mapped_data = kmap_atomic(new_page, KM_USER0);
+		mapped_data = kmap_atomic(new_page);
 		memcpy(tmp, mapped_data + new_offset, jh2bh(jh_in)->b_size);
-		kunmap_atomic(mapped_data, KM_USER0);
+		kunmap_atomic(mapped_data);
 
 		new_page = virt_to_page(tmp);
 		new_offset = offset_in_page(tmp);
@@ -363,9 +363,9 @@ repeat:
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
Index: linux-2.6/fs/jbd/transaction.c
===================================================================
--- linux-2.6.orig/fs/jbd/transaction.c
+++ linux-2.6/fs/jbd/transaction.c
@@ -714,9 +714,9 @@ done:
 			    "Possible IO failure.\n");
 		page = jh2bh(jh)->b_page;
 		offset = ((unsigned long) jh2bh(jh)->b_data) & ~PAGE_MASK;
-		source = kmap_atomic(page, KM_USER0);
+		source = kmap_atomic(page);
 		memcpy(jh->b_frozen_data, source+offset, jh2bh(jh)->b_size);
-		kunmap_atomic(source, KM_USER0);
+		kunmap_atomic(source);
 	}
 	jbd_unlock_bh_state(bh);
 
Index: linux-2.6/fs/jbd2/commit.c
===================================================================
--- linux-2.6.orig/fs/jbd2/commit.c
+++ linux-2.6/fs/jbd2/commit.c
@@ -316,10 +316,10 @@ static __u32 jbd2_checksum_data(__u32 cr
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
Index: linux-2.6/fs/jbd2/journal.c
===================================================================
--- linux-2.6.orig/fs/jbd2/journal.c
+++ linux-2.6/fs/jbd2/journal.c
@@ -341,7 +341,7 @@ repeat:
 		new_offset = offset_in_page(jh2bh(jh_in)->b_data);
 	}
 
-	mapped_data = kmap_atomic(new_page, KM_USER0);
+	mapped_data = kmap_atomic(new_page);
 	/*
 	 * Fire data frozen trigger if data already wasn't frozen.  Do this
 	 * before checking for escaping, as the trigger may modify the magic
@@ -360,7 +360,7 @@ repeat:
 		need_copy_out = 1;
 		do_escape = 1;
 	}
-	kunmap_atomic(mapped_data, KM_USER0);
+	kunmap_atomic(mapped_data);
 
 	/*
 	 * Do we need to do a data copy?
@@ -381,9 +381,9 @@ repeat:
 		}
 
 		jh_in->b_frozen_data = tmp;
-		mapped_data = kmap_atomic(new_page, KM_USER0);
+		mapped_data = kmap_atomic(new_page);
 		memcpy(tmp, mapped_data + new_offset, jh2bh(jh_in)->b_size);
-		kunmap_atomic(mapped_data, KM_USER0);
+		kunmap_atomic(mapped_data);
 
 		new_page = virt_to_page(tmp);
 		new_offset = offset_in_page(tmp);
@@ -402,9 +402,9 @@ repeat:
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
Index: linux-2.6/fs/jbd2/transaction.c
===================================================================
--- linux-2.6.orig/fs/jbd2/transaction.c
+++ linux-2.6/fs/jbd2/transaction.c
@@ -774,12 +774,12 @@ done:
 			    "Possible IO failure.\n");
 		page = jh2bh(jh)->b_page;
 		offset = ((unsigned long) jh2bh(jh)->b_data) & ~PAGE_MASK;
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
Index: linux-2.6/fs/logfs/dir.c
===================================================================
--- linux-2.6.orig/fs/logfs/dir.c
+++ linux-2.6/fs/logfs/dir.c
@@ -177,17 +177,17 @@ static struct page *logfs_get_dd_page(st
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
@@ -365,9 +365,9 @@ static struct dentry *logfs_lookup(struc
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
@@ -404,12 +404,12 @@ static int logfs_write_dir(struct inode 
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
@@ -586,9 +586,9 @@ static int logfs_get_dd(struct inode *di
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
Index: linux-2.6/fs/logfs/readwrite.c
===================================================================
--- linux-2.6.orig/fs/logfs/readwrite.c
+++ linux-2.6/fs/logfs/readwrite.c
@@ -519,9 +519,9 @@ static int indirect_write_alias(struct s
 
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
@@ -667,9 +667,9 @@ static void alloc_indirect_block(struct 
 	alloc_data_block(inode, page);
 
 	block = logfs_block(page);
-	array = kmap_atomic(page, KM_USER0);
+	array = kmap_atomic(page);
 	initialize_block_counters(page, block, array, page_is_empty);
-	kunmap_atomic(array, KM_USER0);
+	kunmap_atomic(array);
 }
 
 static void block_set_pointer(struct page *page, int index, u64 ptr)
@@ -679,10 +679,10 @@ static void block_set_pointer(struct pag
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
@@ -695,9 +695,9 @@ static u64 block_get_pointer(struct page
 	__be64 *block;
 	u64 ptr;
 
-	block = kmap_atomic(page, KM_USER0);
+	block = kmap_atomic(page);
 	ptr = be64_to_cpu(block[index]);
-	kunmap_atomic(block, KM_USER0);
+	kunmap_atomic(block);
 	return ptr;
 }
 
@@ -844,7 +844,7 @@ static u64 seek_holedata_loop(struct ino
 		}
 
 		slot = get_bits(bix, SUBLEVEL(level));
-		rblock = kmap_atomic(page, KM_USER0);
+		rblock = kmap_atomic(page);
 		while (slot < LOGFS_BLOCK_FACTOR) {
 			if (data && (rblock[slot] != 0))
 				break;
@@ -855,12 +855,12 @@ static u64 seek_holedata_loop(struct ino
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
@@ -1944,9 +1944,9 @@ int logfs_read_inode(struct inode *inode
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
@@ -1965,9 +1965,9 @@ static struct page *inode_to_page(struct
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
@@ -2021,13 +2021,13 @@ static void logfs_mod_segment_entry(stru
 
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
@@ -2225,10 +2225,10 @@ int logfs_inode_write(struct inode *inod
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
Index: linux-2.6/fs/logfs/segment.c
===================================================================
--- linux-2.6.orig/fs/logfs/segment.c
+++ linux-2.6/fs/logfs/segment.c
@@ -529,9 +529,9 @@ void move_page_to_btree(struct page *pag
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
Index: linux-2.6/fs/minix/dir.c
===================================================================
--- linux-2.6.orig/fs/minix/dir.c
+++ linux-2.6/fs/minix/dir.c
@@ -335,7 +335,7 @@ int minix_make_empty(struct inode *inode
 		goto fail;
 	}
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memset(kaddr, 0, PAGE_CACHE_SIZE);
 
 	if (sbi->s_version == MINIX_V3) {
@@ -355,7 +355,7 @@ int minix_make_empty(struct inode *inode
 		de->inode = dir->i_ino;
 		strcpy(de->name, "..");
 	}
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	err = dir_commit_chunk(page, 0, 2 * sbi->s_dirsize);
 fail:
Index: linux-2.6/fs/namei.c
===================================================================
--- linux-2.6.orig/fs/namei.c
+++ linux-2.6/fs/namei.c
@@ -2855,9 +2855,9 @@ retry:
 	if (err)
 		goto fail;
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memcpy(kaddr, symname, len-1);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	err = pagecache_write_end(NULL, mapping, 0, len-1, len-1,
 							page, fsdata);
Index: linux-2.6/fs/nfs/dir.c
===================================================================
--- linux-2.6.orig/fs/nfs/dir.c
+++ linux-2.6/fs/nfs/dir.c
@@ -1532,11 +1532,11 @@ static int nfs_symlink(struct inode *dir
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
Index: linux-2.6/fs/nfs/nfs2xdr.c
===================================================================
--- linux-2.6.orig/fs/nfs/nfs2xdr.c
+++ linux-2.6/fs/nfs/nfs2xdr.c
@@ -445,7 +445,7 @@ nfs_xdr_readdirres(struct rpc_rqst *req,
 	if (pglen > recvd)
 		pglen = recvd;
 	page = rcvbuf->pages;
-	kaddr = p = kmap_atomic(*page, KM_USER0);
+	kaddr = p = kmap_atomic(*page);
 	end = (__be32 *)((char *)p + pglen);
 	entry = p;
 
@@ -479,7 +479,7 @@ nfs_xdr_readdirres(struct rpc_rqst *req,
 		entry[1] = 1;
 	}
  out:
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	return nr;
  short_pkt:
 	/*
@@ -624,9 +624,9 @@ nfs_xdr_readlinkres(struct rpc_rqst *req
 	}
 
 	/* NULL terminate the string we got */
-	kaddr = (char *)kmap_atomic(rcvbuf->pages[0], KM_USER0);
+	kaddr = (char *)kmap_atomic(rcvbuf->pages[0]);
 	kaddr[len+rcvbuf->page_base] = '\0';
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	return 0;
 }
 
Index: linux-2.6/fs/nfs/nfs3xdr.c
===================================================================
--- linux-2.6.orig/fs/nfs/nfs3xdr.c
+++ linux-2.6/fs/nfs/nfs3xdr.c
@@ -536,7 +536,7 @@ nfs3_xdr_readdirres(struct rpc_rqst *req
 	if (pglen > recvd)
 		pglen = recvd;
 	page = rcvbuf->pages;
-	kaddr = p = kmap_atomic(*page, KM_USER0);
+	kaddr = p = kmap_atomic(*page);
 	end = (__be32 *)((char *)p + pglen);
 	entry = p;
 
@@ -594,7 +594,7 @@ nfs3_xdr_readdirres(struct rpc_rqst *req
 		entry[1] = 1;
 	}
  out:
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	return nr;
  short_pkt:
 	/*
@@ -858,9 +858,9 @@ nfs3_xdr_readlinkres(struct rpc_rqst *re
 	}
 
 	/* NULL terminate the string we got */
-	kaddr = (char*)kmap_atomic(rcvbuf->pages[0], KM_USER0);
+	kaddr = (char*)kmap_atomic(rcvbuf->pages[0]);
 	kaddr[len+rcvbuf->page_base] = '\0';
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	return 0;
 }
 
Index: linux-2.6/fs/nfs/nfs4proc.c
===================================================================
--- linux-2.6.orig/fs/nfs/nfs4proc.c
+++ linux-2.6/fs/nfs/nfs4proc.c
@@ -175,7 +175,7 @@ static void nfs4_setup_readdir(u64 cooki
 	 * when talking to the server, we always send cookie 0
 	 * instead of 1 or 2.
 	 */
-	start = p = kmap_atomic(*readdir->pages, KM_USER0);
+	start = p = kmap_atomic(*readdir->pages);
 	
 	if (cookie == 0) {
 		*p++ = xdr_one;                                  /* next */
@@ -203,7 +203,7 @@ static void nfs4_setup_readdir(u64 cooki
 
 	readdir->pgbase = (char *)p - (char *)start;
 	readdir->count -= readdir->pgbase;
-	kunmap_atomic(start, KM_USER0);
+	kunmap_atomic(start);
 }
 
 static int nfs4_wait_clnt_recover(struct nfs_client *clp)
Index: linux-2.6/fs/nfs/nfs4xdr.c
===================================================================
--- linux-2.6.orig/fs/nfs/nfs4xdr.c
+++ linux-2.6/fs/nfs/nfs4xdr.c
@@ -4226,7 +4226,7 @@ static int decode_readdir(struct xdr_str
 	xdr_read_pages(xdr, pglen);
 
 	BUG_ON(pglen + readdir->pgbase > PAGE_CACHE_SIZE);
-	kaddr = p = kmap_atomic(page, KM_USER0);
+	kaddr = p = kmap_atomic(page);
 	end = p + ((pglen + readdir->pgbase) >> 2);
 	entry = p;
 
@@ -4271,7 +4271,7 @@ static int decode_readdir(struct xdr_str
 		entry[1] = 1;
 	}
 out:
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	return 0;
 short_pkt:
 	/*
@@ -4288,7 +4288,7 @@ short_pkt:
 	if (nr)
 		goto out;
 err_unmap:
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	return -errno_NFSERR_IO;
 }
 
@@ -4330,9 +4330,9 @@ static int decode_readlink(struct xdr_st
 	 * and and null-terminate the text (the VFS expects
 	 * null-termination).
 	 */
-	kaddr = (char *)kmap_atomic(rcvbuf->pages[0], KM_USER0);
+	kaddr = (char *)kmap_atomic(rcvbuf->pages[0]);
 	kaddr[len+rcvbuf->page_base] = '\0';
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
Index: linux-2.6/fs/nilfs2/cpfile.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/cpfile.c
+++ linux-2.6/fs/nilfs2/cpfile.c
@@ -218,11 +218,11 @@ int nilfs_cpfile_get_checkpoint(struct i
 								 kaddr, 1);
 		nilfs_mdt_mark_buffer_dirty(cp_bh);
 
-		kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(header_bh->b_page);
 		header = nilfs_cpfile_block_get_header(cpfile, header_bh,
 						       kaddr);
 		le64_add_cpu(&header->ch_ncheckpoints, 1);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		nilfs_mdt_mark_buffer_dirty(header_bh);
 		nilfs_mdt_mark_dirty(cpfile);
 	}
@@ -313,7 +313,7 @@ int nilfs_cpfile_delete_checkpoints(stru
 			continue;
 		}
 
-		kaddr = kmap_atomic(cp_bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(cp_bh->b_page);
 		cp = nilfs_cpfile_block_get_checkpoint(
 			cpfile, cno, cp_bh, kaddr);
 		nicps = 0;
@@ -334,7 +334,7 @@ int nilfs_cpfile_delete_checkpoints(stru
 						cpfile, cp_bh, kaddr, nicps);
 				if (count == 0) {
 					/* make hole */
-					kunmap_atomic(kaddr, KM_USER0);
+					kunmap_atomic(kaddr);
 					brelse(cp_bh);
 					ret =
 					  nilfs_cpfile_delete_checkpoint_block(
@@ -349,18 +349,18 @@ int nilfs_cpfile_delete_checkpoints(stru
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
 		nilfs_mdt_mark_buffer_dirty(header_bh);
 		nilfs_mdt_mark_dirty(cpfile);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 	}
 
 	brelse(header_bh);
@@ -408,7 +408,7 @@ static ssize_t nilfs_cpfile_do_get_cpinf
 			continue; /* skip hole */
 		}
 
-		kaddr = kmap_atomic(bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(bh->b_page);
 		cp = nilfs_cpfile_block_get_checkpoint(cpfile, cno, bh, kaddr);
 		for (i = 0; i < ncps && n < nci; i++, cp = (void *)cp + cpsz) {
 			if (!nilfs_checkpoint_invalid(cp)) {
@@ -418,7 +418,7 @@ static ssize_t nilfs_cpfile_do_get_cpinf
 				n++;
 			}
 		}
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		brelse(bh);
 	}
 
@@ -451,10 +451,10 @@ static ssize_t nilfs_cpfile_do_get_ssinf
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
@@ -472,7 +472,7 @@ static ssize_t nilfs_cpfile_do_get_ssinf
 			ret = 0; /* No snapshots (started from a hole block) */
 		goto out;
 	}
-	kaddr = kmap_atomic(bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(bh->b_page);
 	while (n < nci) {
 		cp = nilfs_cpfile_block_get_checkpoint(cpfile, curr, bh, kaddr);
 		curr = ~(__u64)0; /* Terminator */
@@ -488,7 +488,7 @@ static ssize_t nilfs_cpfile_do_get_ssinf
 
 		next_blkoff = nilfs_cpfile_get_blkoff(cpfile, next);
 		if (curr_blkoff != next_blkoff) {
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 			brelse(bh);
 			ret = nilfs_cpfile_get_checkpoint_block(cpfile, next,
 								0, &bh);
@@ -496,12 +496,12 @@ static ssize_t nilfs_cpfile_do_get_ssinf
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
@@ -592,24 +592,24 @@ static int nilfs_cpfile_set_snapshot(str
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
@@ -621,13 +621,13 @@ static int nilfs_cpfile_set_snapshot(str
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
@@ -635,7 +635,7 @@ static int nilfs_cpfile_set_snapshot(str
 		list = &cp->cp_snapshot_list;
 		prev = le64_to_cpu(list->ssl_prev);
 	}
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	if (prev != 0) {
 		ret = nilfs_cpfile_get_checkpoint_block(cpfile, prev, 0,
@@ -647,29 +647,29 @@ static int nilfs_cpfile_set_snapshot(str
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
 
 	nilfs_mdt_mark_buffer_dirty(prev_bh);
 	nilfs_mdt_mark_buffer_dirty(curr_bh);
@@ -710,23 +710,23 @@ static int nilfs_cpfile_clear_snapshot(s
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
@@ -750,29 +750,29 @@ static int nilfs_cpfile_clear_snapshot(s
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
 
 	nilfs_mdt_mark_buffer_dirty(next_bh);
 	nilfs_mdt_mark_buffer_dirty(prev_bh);
@@ -829,13 +829,13 @@ int nilfs_cpfile_is_snapshot(struct inod
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
@@ -919,12 +919,12 @@ int nilfs_cpfile_get_stat(struct inode *
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
Index: linux-2.6/fs/nilfs2/dat.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/dat.c
+++ linux-2.6/fs/nilfs2/dat.c
@@ -84,13 +84,13 @@ void nilfs_dat_commit_alloc(struct inode
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
@@ -107,13 +107,13 @@ void nilfs_dat_commit_free(struct inode 
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
@@ -134,12 +134,12 @@ void nilfs_dat_commit_start(struct inode
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
@@ -158,12 +158,12 @@ int nilfs_dat_prepare_end(struct inode *
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
@@ -184,7 +184,7 @@ void nilfs_dat_commit_end(struct inode *
 	sector_t blocknr;
 	void *kaddr;
 
-	kaddr = kmap_atomic(req->pr_entry_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(req->pr_entry_bh->b_page);
 	entry = nilfs_palloc_block_get_entry(dat, req->pr_entry_nr,
 					     req->pr_entry_bh, kaddr);
 	end = start = le64_to_cpu(entry->de_start);
@@ -194,7 +194,7 @@ void nilfs_dat_commit_end(struct inode *
 	}
 	entry->de_end = cpu_to_le64(end);
 	blocknr = le64_to_cpu(entry->de_blocknr);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	if (blocknr == 0)
 		nilfs_dat_commit_free(dat, req);
@@ -209,12 +209,12 @@ void nilfs_dat_abort_end(struct inode *d
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
@@ -327,20 +327,20 @@ int nilfs_dat_move(struct inode *dat, __
 	ret = nilfs_palloc_get_entry_block(dat, vblocknr, 0, &entry_bh);
 	if (ret < 0)
 		return ret;
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
 
 	nilfs_mdt_mark_buffer_dirty(entry_bh);
 	nilfs_mdt_mark_dirty(dat);
@@ -381,7 +381,7 @@ int nilfs_dat_translate(struct inode *da
 	if (ret < 0)
 		return ret;
 
-	kaddr = kmap_atomic(entry_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(entry_bh->b_page);
 	entry = nilfs_palloc_block_get_entry(dat, vblocknr, entry_bh, kaddr);
 	blocknr = le64_to_cpu(entry->de_blocknr);
 	if (blocknr == 0) {
@@ -391,7 +391,7 @@ int nilfs_dat_translate(struct inode *da
 	*blocknrp = blocknr;
 
  out:
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	brelse(entry_bh);
 	return ret;
 }
@@ -412,7 +412,7 @@ ssize_t nilfs_dat_get_vinfo(struct inode
 						   0, &entry_bh);
 		if (ret < 0)
 			return ret;
-		kaddr = kmap_atomic(entry_bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(entry_bh->b_page);
 		/* last virtual block number in this block */
 		first = vinfo->vi_vblocknr;
 		do_div(first, entries_per_block);
@@ -428,7 +428,7 @@ ssize_t nilfs_dat_get_vinfo(struct inode
 			vinfo->vi_end = le64_to_cpu(entry->de_end);
 			vinfo->vi_blocknr = le64_to_cpu(entry->de_blocknr);
 		}
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		brelse(entry_bh);
 	}
 
Index: linux-2.6/fs/nilfs2/dir.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/dir.c
+++ linux-2.6/fs/nilfs2/dir.c
@@ -606,7 +606,7 @@ int nilfs_make_empty(struct inode *inode
 		unlock_page(page);
 		goto fail;
 	}
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	memset(kaddr, 0, chunk_size);
 	de = (struct nilfs_dir_entry *)kaddr;
 	de->name_len = 1;
@@ -621,7 +621,7 @@ int nilfs_make_empty(struct inode *inode
 	de->inode = cpu_to_le64(parent->i_ino);
 	memcpy(de->name, "..\0", 4);
 	nilfs_set_de_type(de, inode);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	nilfs_commit_chunk(page, mapping, 0, chunk_size);
 fail:
 	page_cache_release(page);
Index: linux-2.6/fs/nilfs2/ifile.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/ifile.c
+++ linux-2.6/fs/nilfs2/ifile.c
@@ -122,11 +122,11 @@ int nilfs_ifile_delete_inode(struct inod
 		return ret;
 	}
 
-	kaddr = kmap_atomic(req.pr_entry_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(req.pr_entry_bh->b_page);
 	raw_inode = nilfs_palloc_block_get_entry(ifile, req.pr_entry_nr,
 						 req.pr_entry_bh, kaddr);
 	raw_inode->i_flags = 0;
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	nilfs_mdt_mark_buffer_dirty(req.pr_entry_bh);
 	brelse(req.pr_entry_bh);
Index: linux-2.6/fs/nilfs2/mdt.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/mdt.c
+++ linux-2.6/fs/nilfs2/mdt.c
@@ -59,12 +59,12 @@ nilfs_mdt_insert_new_block(struct inode 
 
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
 	nilfs_mark_buffer_dirty(bh);
Index: linux-2.6/fs/nilfs2/page.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/page.c
+++ linux-2.6/fs/nilfs2/page.c
@@ -156,11 +156,11 @@ void nilfs_copy_buffer(struct buffer_hea
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
Index: linux-2.6/fs/nilfs2/recovery.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/recovery.c
+++ linux-2.6/fs/nilfs2/recovery.c
@@ -495,9 +495,9 @@ static int nilfs_recovery_copy_block(str
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
Index: linux-2.6/fs/nilfs2/segbuf.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/segbuf.c
+++ linux-2.6/fs/nilfs2/segbuf.c
@@ -227,9 +227,9 @@ static void nilfs_segbuf_fill_in_data_cr
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
Index: linux-2.6/fs/nilfs2/segment.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/segment.c
+++ linux-2.6/fs/nilfs2/segment.c
@@ -1585,7 +1585,7 @@ nilfs_copy_replace_page_buffers(struct p
 		return -ENOMEM;
 
 	bh2 = page_buffers(clone_page);
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	do {
 		if (list_empty(&bh->b_assoc_buffers))
 			continue;
@@ -1596,7 +1596,7 @@ nilfs_copy_replace_page_buffers(struct p
 		list_replace(&bh->b_assoc_buffers, &bh2->b_assoc_buffers);
 		list_add_tail(&bh->b_assoc_buffers, out);
 	} while (bh = bh->b_this_page, bh2 = bh2->b_this_page, bh != head);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	if (!TestSetPageWriteback(clone_page))
 		inc_zone_page_state(clone_page, NR_WRITEBACK);
Index: linux-2.6/fs/nilfs2/sufile.c
===================================================================
--- linux-2.6.orig/fs/nilfs2/sufile.c
+++ linux-2.6/fs/nilfs2/sufile.c
@@ -102,11 +102,11 @@ static void nilfs_sufile_mod_counter(str
 	struct nilfs_sufile_header *header;
 	void *kaddr;
 
-	kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(header_bh->b_page);
 	header = kaddr + bh_offset(header_bh);
 	le64_add_cpu(&header->sh_ncleansegs, ncleanadd);
 	le64_add_cpu(&header->sh_ndirtysegs, ndirtyadd);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	nilfs_mdt_mark_buffer_dirty(header_bh);
 }
@@ -280,11 +280,11 @@ int nilfs_sufile_alloc(struct inode *suf
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
 	segnum = last_alloc + 1;
@@ -299,7 +299,7 @@ int nilfs_sufile_alloc(struct inode *suf
 							   &su_bh);
 		if (ret < 0)
 			goto out_header;
-		kaddr = kmap_atomic(su_bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(su_bh->b_page);
 		su = nilfs_sufile_block_get_segment_usage(
 			sufile, segnum, su_bh, kaddr);
 
@@ -310,14 +310,14 @@ int nilfs_sufile_alloc(struct inode *suf
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
 
 			NILFS_SUI(sufile)->ncleansegs--;
 			nilfs_mdt_mark_buffer_dirty(header_bh);
@@ -328,7 +328,7 @@ int nilfs_sufile_alloc(struct inode *suf
 			goto out_header;
 		}
 
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		brelse(su_bh);
 	}
 
@@ -350,16 +350,16 @@ void nilfs_sufile_do_cancel_free(struct 
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
@@ -376,11 +376,11 @@ void nilfs_sufile_do_scrap(struct inode 
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
@@ -390,7 +390,7 @@ void nilfs_sufile_do_scrap(struct inode 
 	su->su_lastmod = cpu_to_le64(0);
 	su->su_nblocks = cpu_to_le32(0);
 	su->su_flags = cpu_to_le32(1UL << NILFS_SEGMENT_USAGE_DIRTY);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	nilfs_sufile_mod_counter(header_bh, clean ? (u64)-1 : 0, dirty ? 0 : 1);
 	NILFS_SUI(sufile)->ncleansegs -= clean;
@@ -407,12 +407,12 @@ void nilfs_sufile_do_free(struct inode *
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
@@ -420,7 +420,7 @@ void nilfs_sufile_do_free(struct inode *
 
 	sudirty = nilfs_segment_usage_dirty(su);
 	nilfs_segment_usage_set_clean(su);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	nilfs_mdt_mark_buffer_dirty(su_bh);
 
 	nilfs_sufile_mod_counter(header_bh, 1, sudirty ? (u64)-1 : 0);
@@ -468,13 +468,13 @@ int nilfs_sufile_set_segment_usage(struc
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
 
 	nilfs_mdt_mark_buffer_dirty(bh);
 	nilfs_mdt_mark_dirty(sufile);
@@ -515,7 +515,7 @@ int nilfs_sufile_get_stat(struct inode *
 	if (ret < 0)
 		goto out_sem;
 
-	kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+	kaddr = kmap_atomic(header_bh->b_page);
 	header = kaddr + bh_offset(header_bh);
 	sustat->ss_nsegs = nilfs_sufile_get_nsegments(sufile);
 	sustat->ss_ncleansegs = le64_to_cpu(header->sh_ncleansegs);
@@ -525,7 +525,7 @@ int nilfs_sufile_get_stat(struct inode *
 	spin_lock(&nilfs->ns_last_segment_lock);
 	sustat->ss_prot_seq = nilfs->ns_prot_seq;
 	spin_unlock(&nilfs->ns_last_segment_lock);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	brelse(header_bh);
 
  out_sem:
@@ -541,15 +541,15 @@ void nilfs_sufile_do_set_error(struct in
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
@@ -611,7 +611,7 @@ ssize_t nilfs_sufile_get_suinfo(struct i
 			continue;
 		}
 
-		kaddr = kmap_atomic(su_bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(su_bh->b_page);
 		su = nilfs_sufile_block_get_segment_usage(
 			sufile, segnum, su_bh, kaddr);
 		for (j = 0; j < n;
@@ -624,7 +624,7 @@ ssize_t nilfs_sufile_get_suinfo(struct i
 				si->sui_flags |=
 					(1UL << NILFS_SEGMENT_USAGE_ACTIVE);
 		}
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		brelse(su_bh);
 	}
 	ret = nsegs;
@@ -653,10 +653,10 @@ int nilfs_sufile_read(struct inode *sufi
 
 	ret = nilfs_sufile_get_header_block(sufile, &header_bh);
 	if (!ret) {
-		kaddr = kmap_atomic(header_bh->b_page, KM_USER0);
+		kaddr = kmap_atomic(header_bh->b_page);
 		header = kaddr + bh_offset(header_bh);
 		sui->ncleansegs = le64_to_cpu(header->sh_ncleansegs);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		brelse(header_bh);
 	}
 	return ret;
Index: linux-2.6/fs/ntfs/aops.c
===================================================================
--- linux-2.6.orig/fs/ntfs/aops.c
+++ linux-2.6/fs/ntfs/aops.c
@@ -94,11 +94,11 @@ static void ntfs_end_buffer_async_read(s
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
@@ -147,11 +147,11 @@ static void ntfs_end_buffer_async_read(s
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
Index: linux-2.6/fs/ntfs/attrib.c
===================================================================
--- linux-2.6.orig/fs/ntfs/attrib.c
+++ linux-2.6/fs/ntfs/attrib.c
@@ -1656,12 +1656,12 @@ int ntfs_attr_make_non_resident(ntfs_ino
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
@@ -2540,10 +2540,10 @@ int ntfs_attr_set(ntfs_inode *ni, const 
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
@@ -2561,10 +2561,10 @@ int ntfs_attr_set(ntfs_inode *ni, const 
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
@@ -2598,10 +2598,10 @@ int ntfs_attr_set(ntfs_inode *ni, const 
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
Index: linux-2.6/fs/ntfs/file.c
===================================================================
--- linux-2.6.orig/fs/ntfs/file.c
+++ linux-2.6/fs/ntfs/file.c
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
@@ -1287,9 +1287,9 @@ static inline size_t ntfs_copy_from_user
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
@@ -1402,10 +1402,10 @@ static inline size_t ntfs_copy_from_user
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
@@ -1692,7 +1692,7 @@ static int ntfs_commit_pages_after_write
 	BUG_ON(end > le32_to_cpu(a->length) -
 			le16_to_cpu(a->data.resident.value_offset));
 	kattr = (u8*)a + le16_to_cpu(a->data.resident.value_offset);
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	/* Copy the received data from the page to the mft record. */
 	memcpy(kattr + pos, kaddr + pos, bytes);
 	/* Update the attribute length if necessary. */
@@ -1714,7 +1714,7 @@ static int ntfs_commit_pages_after_write
 		flush_dcache_page(page);
 		SetPageUptodate(page);
 	}
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	/* Update initialized_size/i_size if necessary. */
 	read_lock_irqsave(&ni->size_lock, flags);
 	initialized_size = ni->initialized_size;
Index: linux-2.6/fs/ntfs/super.c
===================================================================
--- linux-2.6.orig/fs/ntfs/super.c
+++ linux-2.6/fs/ntfs/super.c
@@ -2491,7 +2491,7 @@ static s64 get_nr_free_clusters(ntfs_vol
 			nr_free -= PAGE_CACHE_SIZE * 8;
 			continue;
 		}
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		/*
 		 * Subtract the number of set bits. If this
 		 * is the last page and it is partial we don't really care as
@@ -2501,7 +2501,7 @@ static s64 get_nr_free_clusters(ntfs_vol
 		 */
 		nr_free -= bitmap_weight(kaddr,
 					PAGE_CACHE_SIZE * BITS_PER_BYTE);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		page_cache_release(page);
 	}
 	ntfs_debug("Finished reading $Bitmap, last index = 0x%lx.", index - 1);
@@ -2562,7 +2562,7 @@ static unsigned long __get_nr_free_mft_r
 			nr_free -= PAGE_CACHE_SIZE * 8;
 			continue;
 		}
-		kaddr = kmap_atomic(page, KM_USER0);
+		kaddr = kmap_atomic(page);
 		/*
 		 * Subtract the number of set bits. If this
 		 * is the last page and it is partial we don't really care as
@@ -2572,7 +2572,7 @@ static unsigned long __get_nr_free_mft_r
 		 */
 		nr_free -= bitmap_weight(kaddr,
 					PAGE_CACHE_SIZE * BITS_PER_BYTE);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		page_cache_release(page);
 	}
 	ntfs_debug("Finished reading $MFT/$BITMAP, last index = 0x%lx.",
Index: linux-2.6/fs/ocfs2/aops.c
===================================================================
--- linux-2.6.orig/fs/ocfs2/aops.c
+++ linux-2.6/fs/ocfs2/aops.c
@@ -101,7 +101,7 @@ static int ocfs2_symlink_get_block(struc
 		 * copy, the data is still good. */
 		if (buffer_jbd(buffer_cache_bh)
 		    && ocfs2_inode_is_new(inode)) {
-			kaddr = kmap_atomic(bh_result->b_page, KM_USER0);
+			kaddr = kmap_atomic(bh_result->b_page);
 			if (!kaddr) {
 				mlog(ML_ERROR, "couldn't kmap!\n");
 				goto bail;
@@ -109,7 +109,7 @@ static int ocfs2_symlink_get_block(struc
 			memcpy(kaddr + (bh_result->b_size * iblock),
 			       buffer_cache_bh->b_data,
 			       bh_result->b_size);
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 			set_buffer_uptodate(bh_result);
 		}
 		brelse(buffer_cache_bh);
@@ -236,13 +236,13 @@ int ocfs2_read_inline_data(struct inode 
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
 
@@ -696,7 +696,7 @@ static void ocfs2_clear_page_regions(str
 
 	ocfs2_figure_cluster_boundaries(osb, cpos, &cluster_start, &cluster_end);
 
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 
 	if (from || to) {
 		if (from > cluster_start)
@@ -707,7 +707,7 @@ static void ocfs2_clear_page_regions(str
 		memset(kaddr + cluster_start, 0, cluster_end - cluster_start);
 	}
 
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 }
 
 /*
@@ -1888,9 +1888,9 @@ static void ocfs2_write_end_inline(struc
 		}
 	}
 
-	kaddr = kmap_atomic(wc->w_target_page, KM_USER0);
+	kaddr = kmap_atomic(wc->w_target_page);
 	memcpy(di->id2.i_data.id_data + pos, kaddr + pos, *copied);
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	mlog(0, "Data written to inode at offset %llu. "
 	     "id_count = %u, copied = %u, i_dyn_features = 0x%x\n",
Index: linux-2.6/fs/pipe.c
===================================================================
--- linux-2.6.orig/fs/pipe.c
+++ linux-2.6/fs/pipe.c
@@ -230,7 +230,7 @@ void *generic_pipe_buf_map(struct pipe_i
 {
 	if (atomic) {
 		buf->flags |= PIPE_BUF_FLAG_ATOMIC;
-		return kmap_atomic(buf->page, KM_USER0);
+		return kmap_atomic(buf->page);
 	}
 
 	return kmap(buf->page);
@@ -251,7 +251,7 @@ void generic_pipe_buf_unmap(struct pipe_
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
 
Index: linux-2.6/fs/reiserfs/stree.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/stree.c
+++ linux-2.6/fs/reiserfs/stree.c
@@ -1284,12 +1284,12 @@ int reiserfs_delete_item(struct reiserfs
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
Index: linux-2.6/fs/reiserfs/tail_conversion.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/tail_conversion.c
+++ linux-2.6/fs/reiserfs/tail_conversion.c
@@ -128,9 +128,9 @@ int direct2indirect(struct reiserfs_tran
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
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
@@ -750,11 +750,11 @@ int pipe_to_file(struct pipe_inode_info 
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
Index: linux-2.6/fs/squashfs/file.c
===================================================================
--- linux-2.6.orig/fs/squashfs/file.c
+++ linux-2.6/fs/squashfs/file.c
@@ -464,10 +464,10 @@ static int squashfs_readpage(struct file
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
Index: linux-2.6/fs/squashfs/symlink.c
===================================================================
--- linux-2.6.orig/fs/squashfs/symlink.c
+++ linux-2.6/fs/squashfs/symlink.c
@@ -90,14 +90,14 @@ static int squashfs_symlink_readpage(str
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
 
Index: linux-2.6/fs/ubifs/file.c
===================================================================
--- linux-2.6.orig/fs/ubifs/file.c
+++ linux-2.6/fs/ubifs/file.c
@@ -1038,10 +1038,10 @@ static int ubifs_writepage(struct page *
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
Index: linux-2.6/fs/udf/file.c
===================================================================
--- linux-2.6.orig/fs/udf/file.c
+++ linux-2.6/fs/udf/file.c
@@ -88,10 +88,10 @@ static int udf_adinicb_write_end(struct 
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
Index: linux-2.6/include/linux/bio.h
===================================================================
--- linux-2.6.orig/include/linux/bio.h
+++ linux-2.6/include/linux/bio.h
@@ -330,7 +330,7 @@ static inline char *bvec_kmap_irq(struct
 	 * balancing is a lot nicer this way
 	 */
 	local_irq_save(*flags);
-	addr = (unsigned long) kmap_atomic(bvec->bv_page, KM_BIO_SRC_IRQ);
+	addr = (unsigned long) kmap_atomic(bvec->bv_page);
 
 	BUG_ON(addr & ~PAGE_MASK);
 
@@ -341,7 +341,7 @@ static inline void bvec_kunmap_irq(char 
 {
 	unsigned long ptr = (unsigned long) buffer & PAGE_MASK;
 
-	kunmap_atomic((void *) ptr, KM_BIO_SRC_IRQ);
+	kunmap_atomic((void *) ptr);
 	local_irq_restore(*flags);
 }
 
Index: linux-2.6/include/linux/highmem.h
===================================================================
--- linux-2.6.orig/include/linux/highmem.h
+++ linux-2.6/include/linux/highmem.h
@@ -105,9 +105,9 @@ static inline void kunmap_atomic_notypec
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
 
@@ -158,16 +158,16 @@ alloc_zeroed_user_highpage_movable(struc
 
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
 
@@ -177,7 +177,7 @@ static inline void zero_user_segments(st
 	if (end2 > start2)
 		memset(kaddr + start2, 0, end2 - start2);
 
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 	flush_dcache_page(page);
 }
 
@@ -206,11 +206,11 @@ static inline void copy_user_highpage(st
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
@@ -219,11 +219,11 @@ static inline void copy_highpage(struct 
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
Index: linux-2.6/kernel/debug/kdb/kdb_support.c
===================================================================
--- linux-2.6.orig/kernel/debug/kdb/kdb_support.c
+++ linux-2.6/kernel/debug/kdb/kdb_support.c
@@ -384,9 +384,9 @@ static int kdb_getphys(void *res, unsign
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
Index: linux-2.6/kernel/power/snapshot.c
===================================================================
--- linux-2.6.orig/kernel/power/snapshot.c
+++ linux-2.6/kernel/power/snapshot.c
@@ -976,20 +976,20 @@ static void copy_data_page(unsigned long
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
 			memcpy(dst, buffer, PAGE_SIZE);
-			kunmap_atomic(dst, KM_USER0);
+			kunmap_atomic(dst);
 		} else {
 			safe_copy_page(page_address(d_page), s_page);
 		}
@@ -1649,9 +1649,9 @@ int snapshot_read_next(struct snapshot_h
 			 */
 			void *kaddr;
 
-			kaddr = kmap_atomic(page, KM_USER0);
+			kaddr = kmap_atomic(page);
 			memcpy(buffer, kaddr, PAGE_SIZE);
-			kunmap_atomic(kaddr, KM_USER0);
+			kunmap_atomic(kaddr);
 			handle->buffer = buffer;
 		} else {
 			handle->buffer = page_address(page);
@@ -1932,9 +1932,9 @@ static void copy_last_highmem_page(void)
 	if (last_highmem_page) {
 		void *dst;
 
-		dst = kmap_atomic(last_highmem_page, KM_USER0);
+		dst = kmap_atomic(last_highmem_page);
 		memcpy(dst, buffer, PAGE_SIZE);
-		kunmap_atomic(dst, KM_USER0);
+		kunmap_atomic(dst);
 		last_highmem_page = NULL;
 	}
 }
@@ -2217,13 +2217,13 @@ swap_two_pages_data(struct page *p1, str
 {
 	void *kaddr1, *kaddr2;
 
-	kaddr1 = kmap_atomic(p1, KM_USER0);
-	kaddr2 = kmap_atomic(p2, KM_USER1);
+	kaddr1 = kmap_atomic(p1);
+	kaddr2 = kmap_atomic(p2);
 	memcpy(buf, kaddr1, PAGE_SIZE);
 	memcpy(kaddr1, kaddr2, PAGE_SIZE);
 	memcpy(kaddr2, buf, PAGE_SIZE);
-	kunmap_atomic(kaddr2, KM_USER1);
-	kunmap_atomic(kaddr1, KM_USER0);
+	kunmap_atomic(kaddr2);
+	kunmap_atomic(kaddr1);
 }
 
 /**
Index: linux-2.6/lib/scatterlist.c
===================================================================
--- linux-2.6.orig/lib/scatterlist.c
+++ linux-2.6/lib/scatterlist.c
@@ -380,7 +380,7 @@ bool sg_miter_next(struct sg_mapping_ite
 	miter->consumed = miter->length;
 
 	if (miter->__flags & SG_MITER_ATOMIC)
-		miter->addr = kmap_atomic(miter->page, KM_BIO_SRC_IRQ) + off;
+		miter->addr = kmap_atomic(miter->page) + off;
 	else
 		miter->addr = kmap(miter->page) + off;
 
@@ -414,7 +414,7 @@ void sg_miter_stop(struct sg_mapping_ite
 
 		if (miter->__flags & SG_MITER_ATOMIC) {
 			WARN_ON(!irqs_disabled());
-			kunmap_atomic(miter->addr, KM_BIO_SRC_IRQ);
+			kunmap_atomic(miter->addr);
 		} else
 			kunmap(miter->page);
 
Index: linux-2.6/lib/swiotlb.c
===================================================================
--- linux-2.6.orig/lib/swiotlb.c
+++ linux-2.6/lib/swiotlb.c
@@ -349,7 +349,7 @@ void swiotlb_bounce(phys_addr_t phys, ch
 				memcpy(dma_addr, buffer + offset, sz);
 			else
 				memcpy(buffer + offset, dma_addr, sz);
-			kunmap_atomic(buffer, KM_BOUNCE_READ);
+			kunmap_atomic(buffer);
 			local_irq_restore(flags);
 
 			size -= sz;
Index: linux-2.6/mm/bounce.c
===================================================================
--- linux-2.6.orig/mm/bounce.c
+++ linux-2.6/mm/bounce.c
@@ -51,9 +51,9 @@ static void bounce_copy_vec(struct bio_v
 	unsigned char *vto;
 
 	local_irq_save(flags);
-	vto = kmap_atomic(to->bv_page, KM_BOUNCE_READ);
+	vto = kmap_atomic(to->bv_page);
 	memcpy(vto + to->bv_offset, vfrom, to->bv_len);
-	kunmap_atomic(vto, KM_BOUNCE_READ);
+	kunmap_atomic(vto);
 	local_irq_restore(flags);
 }
 
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1197,10 +1197,10 @@ int file_read_actor(read_descriptor_t *d
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
@@ -1908,7 +1908,7 @@ size_t iov_iter_copy_from_user_atomic(st
 	size_t copied;
 
 	BUG_ON(!in_atomic());
-	kaddr = kmap_atomic(page, KM_USER0);
+	kaddr = kmap_atomic(page);
 	if (likely(i->nr_segs == 1)) {
 		int left;
 		char __user *buf = i->iov->iov_base + i->iov_offset;
@@ -1918,7 +1918,7 @@ size_t iov_iter_copy_from_user_atomic(st
 		copied = __iovec_copy_from_user_inatomic(kaddr + offset,
 						i->iov, i->iov_offset, bytes);
 	}
-	kunmap_atomic(kaddr, KM_USER0);
+	kunmap_atomic(kaddr);
 
 	return copied;
 }
Index: linux-2.6/mm/ksm.c
===================================================================
--- linux-2.6.orig/mm/ksm.c
+++ linux-2.6/mm/ksm.c
@@ -670,9 +670,9 @@ error:
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
 
@@ -681,11 +681,11 @@ static int memcmp_pages(struct page *pag
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
 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -2069,7 +2069,7 @@ static inline void cow_user_page(struct 
 	 * fails, we just zero-fill it. Live with it.
 	 */
 	if (unlikely(!src)) {
-		void *kaddr = kmap_atomic(dst, KM_USER0);
+		void *kaddr = kmap_atomic(dst);
 		void __user *uaddr = (void __user *)(va & PAGE_MASK);
 
 		/*
@@ -2080,7 +2080,7 @@ static inline void cow_user_page(struct 
 		 */
 		if (__copy_from_user_inatomic(kaddr, uaddr, PAGE_SIZE))
 			memset(kaddr, 0, PAGE_SIZE);
-		kunmap_atomic(kaddr, KM_USER0);
+		kunmap_atomic(kaddr);
 		flush_dcache_page(dst);
 	} else
 		copy_user_highpage(dst, src, va, vma);
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c
+++ linux-2.6/mm/shmem.c
@@ -142,17 +142,17 @@ static inline void shmem_dir_free(struct
 
 static struct page **shmem_dir_map(struct page *page)
 {
-	return (struct page **)kmap_atomic(page, KM_USER0);
+	return (struct page **)kmap_atomic(page);
 }
 
 static inline void shmem_dir_unmap(struct page **dir)
 {
-	kunmap_atomic(dir, KM_USER0);
+	kunmap_atomic(dir);
 }
 
 static swp_entry_t *shmem_swp_map(struct page *page)
 {
-	return (swp_entry_t *)kmap_atomic(page, KM_USER1);
+	return (swp_entry_t *)kmap_atomic(page);
 }
 
 static inline void shmem_swp_balance_unmap(void)
@@ -164,12 +164,12 @@ static inline void shmem_swp_balance_unm
 	 * What kmap_atomic of a lowmem page does depends on config
 	 * and architecture, so pretend to kmap_atomic some lowmem page.
 	 */
-	(void) kmap_atomic(ZERO_PAGE(0), KM_USER1);
+	(void) kmap_atomic(ZERO_PAGE(0));
 }
 
 static inline void shmem_swp_unmap(swp_entry_t *entry)
 {
-	kunmap_atomic(entry, KM_USER1);
+	kunmap_atomic(entry);
 }
 
 static inline struct shmem_sb_info *SHMEM_SB(struct super_block *sb)
@@ -2006,9 +2006,9 @@ static int shmem_symlink(struct inode *d
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
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c
+++ linux-2.6/mm/swapfile.c
@@ -2418,9 +2418,9 @@ int add_swap_count_continuation(swp_entr
 		if (!(count & COUNT_CONTINUED))
 			goto out;
 
-		map = kmap_atomic(list_page, KM_USER0) + offset;
+		map = kmap_atomic(list_page) + offset;
 		count = *map;
-		kunmap_atomic(map, KM_USER0);
+		kunmap_atomic(map);
 
 		/*
 		 * If this continuation count now has some space in it,
@@ -2463,7 +2463,7 @@ static bool swap_count_continued(struct 
 
 	offset &= ~PAGE_MASK;
 	page = list_entry(head->lru.next, struct page, lru);
-	map = kmap_atomic(page, KM_USER0) + offset;
+	map = kmap_atomic(page) + offset;
 
 	if (count == SWAP_MAP_MAX)	/* initial increment from swap_map */
 		goto init_map;		/* jump over SWAP_CONT_MAX checks */
@@ -2473,26 +2473,26 @@ static bool swap_count_continued(struct 
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
@@ -2503,22 +2503,22 @@ init_map:		*map = 0;		/* we didn't zero 
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
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -1740,9 +1740,9 @@ static int aligned_vread(char *buf, char
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
 
@@ -1779,9 +1779,9 @@ static int aligned_vwrite(char *buf, cha
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
Index: linux-2.6/net/core/kmap_skb.h
===================================================================
--- linux-2.6.orig/net/core/kmap_skb.h
+++ linux-2.6/net/core/kmap_skb.h
@@ -7,12 +7,12 @@ static inline void *kmap_skb_frag(const 
 
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
Index: linux-2.6/net/rds/ib_recv.c
===================================================================
--- linux-2.6.orig/net/rds/ib_recv.c
+++ linux-2.6/net/rds/ib_recv.c
@@ -579,11 +579,11 @@ static struct rds_header *rds_ib_get_hea
 	        return hdr_buff;
 
 	if (data_len <= (RDS_FRAG_SIZE - sizeof(struct rds_header))) {
-		addr = kmap_atomic(recv->r_frag->f_page, KM_SOFTIRQ0);
+		addr = kmap_atomic(recv->r_frag->f_page);
 		memcpy(hdr_buff,
 		       addr + recv->r_frag->f_offset + data_len,
 		       sizeof(struct rds_header));
-		kunmap_atomic(addr, KM_SOFTIRQ0);
+		kunmap_atomic(addr);
 		return hdr_buff;
 	}
 
@@ -591,10 +591,10 @@ static struct rds_header *rds_ib_get_hea
 
 	memmove(hdr_buff + misplaced_hdr_bytes, hdr_buff, misplaced_hdr_bytes);
 
-	addr = kmap_atomic(recv->r_frag->f_page, KM_SOFTIRQ0);
+	addr = kmap_atomic(recv->r_frag->f_page);
 	memcpy(hdr_buff, addr + recv->r_frag->f_offset + data_len,
 	       sizeof(struct rds_header) - misplaced_hdr_bytes);
-	kunmap_atomic(addr, KM_SOFTIRQ0);
+	kunmap_atomic(addr);
 	return hdr_buff;
 }
 
@@ -639,7 +639,7 @@ static void rds_ib_cong_recv(struct rds_
 		to_copy = min(RDS_FRAG_SIZE - frag_off, PAGE_SIZE - map_off);
 		BUG_ON(to_copy & 7); /* Must be 64bit aligned. */
 
-		addr = kmap_atomic(frag->f_page, KM_SOFTIRQ0);
+		addr = kmap_atomic(frag->f_page);
 
 		src = addr + frag_off;
 		dst = (void *)map->m_page_addrs[map_page] + map_off;
@@ -649,7 +649,7 @@ static void rds_ib_cong_recv(struct rds_
 			uncongested |= ~(*src) & *dst;
 			*dst++ = *src++;
 		}
-		kunmap_atomic(addr, KM_SOFTIRQ0);
+		kunmap_atomic(addr);
 
 		copied += to_copy;
 
Index: linux-2.6/net/rds/info.c
===================================================================
--- linux-2.6.orig/net/rds/info.c
+++ linux-2.6/net/rds/info.c
@@ -103,7 +103,7 @@ EXPORT_SYMBOL_GPL(rds_info_deregister_fu
 void rds_info_iter_unmap(struct rds_info_iterator *iter)
 {
 	if (iter->addr != NULL) {
-		kunmap_atomic(iter->addr, KM_USER0);
+		kunmap_atomic(iter->addr);
 		iter->addr = NULL;
 	}
 }
@@ -118,7 +118,7 @@ void rds_info_copy(struct rds_info_itera
 
 	while (bytes) {
 		if (iter->addr == NULL)
-			iter->addr = kmap_atomic(*iter->pages, KM_USER0);
+			iter->addr = kmap_atomic(*iter->pages);
 
 		this = min(bytes, PAGE_SIZE - iter->offset);
 
@@ -133,7 +133,7 @@ void rds_info_copy(struct rds_info_itera
 		iter->offset += this;
 
 		if (iter->offset == PAGE_SIZE) {
-			kunmap_atomic(iter->addr, KM_USER0);
+			kunmap_atomic(iter->addr);
 			iter->addr = NULL;
 			iter->offset = 0;
 			iter->pages++;
Index: linux-2.6/net/rds/iw_recv.c
===================================================================
--- linux-2.6.orig/net/rds/iw_recv.c
+++ linux-2.6/net/rds/iw_recv.c
@@ -598,7 +598,7 @@ static void rds_iw_cong_recv(struct rds_
 		to_copy = min(RDS_FRAG_SIZE - frag_off, PAGE_SIZE - map_off);
 		BUG_ON(to_copy & 7); /* Must be 64bit aligned. */
 
-		addr = kmap_atomic(frag->f_page, KM_SOFTIRQ0);
+		addr = kmap_atomic(frag->f_page);
 
 		src = addr + frag_off;
 		dst = (void *)map->m_page_addrs[map_page] + map_off;
@@ -608,7 +608,7 @@ static void rds_iw_cong_recv(struct rds_
 			uncongested |= ~(*src) & *dst;
 			*dst++ = *src++;
 		}
-		kunmap_atomic(addr, KM_SOFTIRQ0);
+		kunmap_atomic(addr);
 
 		copied += to_copy;
 
Index: linux-2.6/net/rds/loop.c
===================================================================
--- linux-2.6.orig/net/rds/loop.c
+++ linux-2.6/net/rds/loop.c
@@ -67,7 +67,7 @@ static int rds_loop_xmit(struct rds_conn
 	rds_message_addref(rm); /* for the inc */
 
 	rds_recv_incoming(conn, conn->c_laddr, conn->c_faddr, &rm->m_inc,
-			  GFP_KERNEL, KM_USER0);
+			  GFP_KERNEL);
 
 	rds_send_drop_acked(conn, be64_to_cpu(rm->m_inc.i_hdr.h_sequence),
 			    NULL);
Index: linux-2.6/net/rds/page.c
===================================================================
--- linux-2.6.orig/net/rds/page.c
+++ linux-2.6/net/rds/page.c
@@ -62,12 +62,12 @@ int rds_page_copy_user(struct page *page
 	else
 		rds_stats_add(s_copy_from_user, bytes);
 
-	addr = kmap_atomic(page, KM_USER0);
+	addr = kmap_atomic(page);
 	if (to_user)
 		ret = __copy_to_user_inatomic(ptr, addr + offset, bytes);
 	else
 		ret = __copy_from_user_inatomic(addr + offset, ptr, bytes);
-	kunmap_atomic(addr, KM_USER0);
+	kunmap_atomic(addr);
 
 	if (ret) {
 		addr = kmap(page);
Index: linux-2.6/net/rds/tcp_recv.c
===================================================================
--- linux-2.6.orig/net/rds/tcp_recv.c
+++ linux-2.6/net/rds/tcp_recv.c
@@ -310,7 +310,7 @@ int rds_tcp_recv(struct rds_connection *
 	rdsdebug("recv worker conn %p tc %p sock %p\n", conn, tc, sock);
 
 	lock_sock(sock->sk);
-	ret = rds_tcp_read_sock(conn, GFP_KERNEL, KM_USER0);
+	ret = rds_tcp_read_sock(conn, GFP_KERNEL);
 	release_sock(sock->sk);
 
 	return ret;
@@ -335,7 +335,7 @@ void rds_tcp_data_ready(struct sock *sk,
 	ready = tc->t_orig_data_ready;
 	rds_tcp_stats_inc(s_tcp_data_ready_calls);
 
-	if (rds_tcp_read_sock(conn, GFP_ATOMIC, KM_SOFTIRQ0) == -ENOMEM)
+	if (rds_tcp_read_sock(conn, GFP_ATOMIC) == -ENOMEM)
 		queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
 out:
 	read_unlock(&sk->sk_callback_lock);
Index: linux-2.6/net/sunrpc/auth_gss/gss_krb5_wrap.c
===================================================================
--- linux-2.6.orig/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ linux-2.6/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -82,9 +82,9 @@ gss_krb5_remove_padding(struct xdr_buf *
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
Index: linux-2.6/net/sunrpc/socklib.c
===================================================================
--- linux-2.6.orig/net/sunrpc/socklib.c
+++ linux-2.6/net/sunrpc/socklib.c
@@ -113,7 +113,7 @@ ssize_t xdr_partial_copy_from_skb(struct
 		}
 
 		len = PAGE_CACHE_SIZE;
-		kaddr = kmap_atomic(*ppage, KM_SKB_SUNRPC_DATA);
+		kaddr = kmap_atomic(*ppage);
 		if (base) {
 			len -= base;
 			if (pglen < len)
@@ -126,7 +126,7 @@ ssize_t xdr_partial_copy_from_skb(struct
 			ret = copy_actor(desc, kaddr, len);
 		}
 		flush_dcache_page(*ppage);
-		kunmap_atomic(kaddr, KM_SKB_SUNRPC_DATA);
+		kunmap_atomic(kaddr);
 		copied += ret;
 		if (ret != len || !desc->count)
 			goto out;
Index: linux-2.6/net/sunrpc/xdr.c
===================================================================
--- linux-2.6.orig/net/sunrpc/xdr.c
+++ linux-2.6/net/sunrpc/xdr.c
@@ -215,12 +215,12 @@ _shift_data_right_pages(struct page **pa
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
@@ -250,9 +250,9 @@ _copy_to_pages(struct page **pages, size
 		if (copy > len)
 			copy = len;
 
-		vto = kmap_atomic(*pgto, KM_USER0);
+		vto = kmap_atomic(*pgto);
 		memcpy(vto + pgbase, p, copy);
-		kunmap_atomic(vto, KM_USER0);
+		kunmap_atomic(vto);
 
 		len -= copy;
 		if (len == 0)
@@ -294,9 +294,9 @@ _copy_from_pages(char *p, struct page **
 		if (copy > len)
 			copy = len;
 
-		vfrom = kmap_atomic(*pgfrom, KM_USER0);
+		vfrom = kmap_atomic(*pgfrom);
 		memcpy(p, vfrom + pgbase, copy);
-		kunmap_atomic(vfrom, KM_USER0);
+		kunmap_atomic(vfrom);
 
 		pgbase += copy;
 		if (pgbase == PAGE_CACHE_SIZE) {
Index: linux-2.6/net/sunrpc/xprtrdma/rpc_rdma.c
===================================================================
--- linux-2.6.orig/net/sunrpc/xprtrdma/rpc_rdma.c
+++ linux-2.6/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -342,7 +342,7 @@ rpcrdma_inline_pullup(struct rpc_rqst *r
 			memcpy(destp, srcp+rqst->rq_snd_buf.page_base, curlen);
 		else
 			memcpy(destp, srcp, curlen);
-		kunmap_atomic(srcp, KM_SKB_SUNRPC_DATA);
+		kunmap_atomic(srcp);
 		rqst->rq_svec[0].iov_len += curlen;
 		destp += curlen;
 		copy_len -= curlen;
@@ -645,7 +645,7 @@ rpcrdma_inline_fixup(struct rpc_rqst *rq
 			else
 				memcpy(destp, srcp, curlen);
 			flush_dcache_page(rqst->rq_rcv_buf.pages[i]);
-			kunmap_atomic(destp, KM_SKB_SUNRPC_DATA);
+			kunmap_atomic(destp);
 			srcp += curlen;
 			copy_len -= curlen;
 			if (copy_len == 0)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
