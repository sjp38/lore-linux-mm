Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 47A436B02F9
	for <linux-mm@kvack.org>; Tue,  8 May 2018 20:42:52 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f35-v6so2745853plb.10
        for <linux-mm@kvack.org>; Tue, 08 May 2018 17:42:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c21-v6sor7280490pls.113.2018.05.08.17.42.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 17:42:49 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 11/13] treewide: Use array_size() for vmalloc()
Date: Tue,  8 May 2018 17:42:27 -0700
Message-Id: <20180509004229.36341-12-keescook@chromium.org>
In-Reply-To: <20180509004229.36341-1-keescook@chromium.org>
References: <20180509004229.36341-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Generated with the following Coccinelle script:

// 2-factor product with sizeof(variable)
@@
identifier alloc =~ "vmalloc|vzalloc";
expression THING;
identifier COUNT;
@@

- alloc(sizeof(THING) * COUNT)
+ alloc(array_size(COUNT, sizeof(THING)))

// 2-factor product with sizeof(type)
@@
identifier alloc =~ "vmalloc|vzalloc";
identifier COUNT;
type TYPE;
@@

- alloc(sizeof(TYPE) * COUNT)
+ alloc(array_size(COUNT, sizeof(TYPE)))

// 2-factor product with sizeof(variable) and constant
@@
identifier alloc =~ "vmalloc|vzalloc";
expression THING;
constant COUNT;
@@

- alloc(sizeof(THING) * COUNT)
+ alloc(array_size(COUNT, sizeof(THING)))

// 2-factor product with sizeof(type) and constant
@@
identifier alloc =~ "vmalloc|vzalloc";
constant COUNT;
type TYPE;
@@

- alloc(sizeof(TYPE) * COUNT)
+ alloc(array_size(COUNT, sizeof(TYPE)))

// 3-factor product with 1 sizeof(variable)
@@
identifier alloc =~ "vmalloc|vzalloc";
expression THING;
identifier STRIDE, COUNT;
@@

- alloc(sizeof(THING) * COUNT * STRIDE)
+ alloc(array3_size(COUNT, STRIDE, sizeof(THING)))

// 3-factor product with 2 sizeof(variable)
@@
identifier alloc =~ "vmalloc|vzalloc";
expression THING1, THING2;
identifier COUNT;
@@

- alloc(sizeof(THING1) * sizeof(THING2) * COUNT)
+ alloc(array3_size(COUNT, sizeof(THING1), sizeof(THING2)))

// 3-factor product with 1 sizeof(type)
@@
identifier alloc =~ "vmalloc|vzalloc";
identifier STRIDE, COUNT;
type TYPE;
@@

- alloc(sizeof(TYPE) * COUNT * STRIDE)
+ alloc(array3_size(COUNT, STRIDE, sizeof(TYPE)))

// 3-factor product with 2 sizeof(type)
@@
identifier alloc =~ "vmalloc|vzalloc";
identifier COUNT;
type TYPE1, TYPE2;
@@

- alloc(sizeof(TYPE1) * sizeof(TYPE2) * COUNT)
+ alloc(array3_size(COUNT, sizeof(TYPE1), sizeof(TYPE2)))

// 3-factor product with mixed sizeof() type/variable
@@
identifier alloc =~ "vmalloc|vzalloc";
expression THING;
identifier COUNT;
type TYPE;
@@

- alloc(sizeof(TYPE) * sizeof(THING) * COUNT)
+ alloc(array3_size(COUNT, sizeof(TYPE), sizeof(THING)))

// 2-factor product, only identifiers
@@
identifier alloc =~ "vmalloc|vzalloc";
identifier SIZE, COUNT;
@@

- alloc(SIZE * COUNT)
+ alloc(array_size(COUNT, SIZE))

// 3-factor product, only identifiers
@@
identifier alloc =~ "vmalloc|vzalloc";
identifier STRIDE, SIZE, COUNT;
@@

- alloc(COUNT * STRIDE * SIZE)
+ alloc(array3_size(COUNT, STRIDE, SIZE))

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/powerpc/kernel/rtasd.c                   |  2 +-
 arch/powerpc/kvm/book3s_64_mmu_hv.c           |  2 +-
 arch/powerpc/kvm/book3s_hv.c                  |  2 +-
 arch/powerpc/mm/mmu_context_iommu.c           |  2 +-
 arch/s390/kernel/sthyi.c                      |  2 +-
 arch/s390/kvm/gaccess.c                       |  2 +-
 block/partitions/check.c                      |  2 +-
 drivers/base/firmware_loader/fallback.c       |  2 +-
 drivers/block/zram/zram_drv.c                 |  2 +-
 drivers/char/raw.c                            |  2 +-
 drivers/dma/ipu/ipu_idmac.c                   |  2 +-
 drivers/dma/mic_x100_dma.c                    |  2 +-
 drivers/gpu/drm/drm_hashtab.c                 |  2 +-
 drivers/gpu/drm/drm_memory.c                  |  2 +-
 drivers/gpu/drm/gma500/mmu.c                  |  2 +-
 drivers/gpu/drm/selftests/test-drm_mm.c       | 20 +++++++++----------
 drivers/infiniband/core/umem_odp.c            |  4 ++--
 drivers/infiniband/hw/hns/hns_roce_mr.c       |  2 +-
 drivers/infiniband/hw/qib/qib_file_ops.c      |  2 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c       |  6 +++---
 drivers/infiniband/ulp/ipoib/ipoib_main.c     |  2 +-
 drivers/isdn/i4l/isdn_bsdcomp.c               |  2 +-
 drivers/lightnvm/pblk-init.c                  |  2 +-
 drivers/md/dm-cache-policy-smq.c              |  4 ++--
 drivers/md/dm-region-hash.c                   |  2 +-
 drivers/md/dm-switch.c                        |  2 +-
 drivers/md/dm-thin.c                          |  2 +-
 drivers/media/common/v4l2-tpg/v4l2-tpg-core.c |  4 ++--
 drivers/media/pci/meye/meye.c                 |  6 +++---
 drivers/media/pci/pt1/pt1.c                   |  2 +-
 drivers/media/pci/ttpci/av7110_ipack.c        |  2 +-
 .../media/platform/soc_camera/soc_camera.c    |  2 +-
 drivers/media/platform/vivid/vivid-core.c     |  4 ++--
 drivers/media/usb/gspca/gspca.c               |  2 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c     |  4 ++--
 drivers/mtd/ftl.c                             |  2 +-
 drivers/mtd/mtdswap.c                         |  4 ++--
 .../cavium/liquidio/request_manager.c         |  3 +--
 .../ethernet/hisilicon/hns/hns_dsaf_main.c    |  3 +--
 .../net/ethernet/intel/fm10k/fm10k_ethtool.c  |  2 +-
 .../net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |  2 +-
 .../ethernet/netronome/nfp/flower/metadata.c  |  2 +-
 .../ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c   |  3 +--
 drivers/net/ethernet/sfc/ef10.c               |  2 +-
 drivers/net/ppp/bsd_comp.c                    |  2 +-
 drivers/net/xen-netback/xenbus.c              |  3 +--
 drivers/oprofile/event_buffer.c               |  2 +-
 drivers/scsi/fnic/fnic_trace.c                |  9 +++------
 drivers/scsi/ipr.c                            |  4 ++--
 drivers/scsi/megaraid/megaraid_sas_fusion.c   |  6 ++----
 drivers/scsi/qla2xxx/tcm_qla2xxx.c            |  2 +-
 drivers/staging/android/ion/ion_heap.c        |  2 +-
 drivers/staging/greybus/camera.c              |  3 +--
 drivers/target/target_core_transport.c        |  2 +-
 fs/cifs/misc.c                                |  4 ++--
 fs/dlm/lockspace.c                            |  2 +-
 fs/nfsd/nfscache.c                            |  2 +-
 fs/reiserfs/bitmap.c                          |  2 +-
 fs/reiserfs/journal.c                         |  2 +-
 fs/reiserfs/resize.c                          |  2 +-
 kernel/bpf/verifier.c                         |  2 +-
 kernel/cgroup/cgroup-v1.c                     |  2 +-
 kernel/power/swap.c                           |  6 +++---
 kernel/rcu/rcutorture.c                       |  3 +--
 lib/test_rhashtable.c                         |  4 ++--
 net/bridge/netfilter/ebtables.c               | 10 +++++-----
 net/core/ethtool.c                            |  4 ++--
 net/netfilter/ipvs/ip_vs_conn.c               |  2 +-
 sound/pci/cs46xx/dsp_spos.c                   |  3 +--
 sound/pci/trident/trident_main.c              |  2 +-
 70 files changed, 102 insertions(+), 114 deletions(-)

diff --git a/arch/powerpc/kernel/rtasd.c b/arch/powerpc/kernel/rtasd.c
index f915db93cd42..9419baa5c226 100644
--- a/arch/powerpc/kernel/rtasd.c
+++ b/arch/powerpc/kernel/rtasd.c
@@ -559,7 +559,7 @@ static int __init rtas_event_scan_init(void)
 	rtas_error_log_max = rtas_get_error_log_max();
 	rtas_error_log_buffer_max = rtas_error_log_max + sizeof(int);
 
-	rtas_log_buf = vmalloc(rtas_error_log_buffer_max*LOG_NUMBER);
+	rtas_log_buf = vmalloc(array_size(LOG_NUMBER, rtas_error_log_buffer_max));
 	if (!rtas_log_buf) {
 		printk(KERN_ERR "rtasd: no memory\n");
 		return -ENOMEM;
diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index a670fa5fbe50..1b3fcafc685e 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -108,7 +108,7 @@ int kvmppc_allocate_hpt(struct kvm_hpt_info *info, u32 order)
 	npte = 1ul << (order - 4);
 
 	/* Allocate reverse map array */
-	rev = vmalloc(sizeof(struct revmap_entry) * npte);
+	rev = vmalloc(array_size(npte, sizeof(struct revmap_entry)));
 	if (!rev) {
 		if (cma)
 			kvm_free_hpt_cma(page, 1 << (order - PAGE_SHIFT));
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 4d07fca5121c..24ac126a61cc 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -3543,7 +3543,7 @@ static void kvmppc_core_free_memslot_hv(struct kvm_memory_slot *free,
 static int kvmppc_core_create_memslot_hv(struct kvm_memory_slot *slot,
 					 unsigned long npages)
 {
-	slot->arch.rmap = vzalloc(npages * sizeof(*slot->arch.rmap));
+	slot->arch.rmap = vzalloc(array_size(npages, sizeof(*slot->arch.rmap)));
 	if (!slot->arch.rmap)
 		return -ENOMEM;
 
diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index 4c615fcb0cf0..abb43646927a 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -159,7 +159,7 @@ long mm_iommu_get(struct mm_struct *mm, unsigned long ua, unsigned long entries,
 		goto unlock_exit;
 	}
 
-	mem->hpas = vzalloc(entries * sizeof(mem->hpas[0]));
+	mem->hpas = vzalloc(array_size(entries, sizeof(mem->hpas[0])));
 	if (!mem->hpas) {
 		kfree(mem);
 		ret = -ENOMEM;
diff --git a/arch/s390/kernel/sthyi.c b/arch/s390/kernel/sthyi.c
index 80b862e9c53c..0859cde36f75 100644
--- a/arch/s390/kernel/sthyi.c
+++ b/arch/s390/kernel/sthyi.c
@@ -315,7 +315,7 @@ static void fill_diag(struct sthyi_sctns *sctns)
 	if (pages <= 0)
 		return;
 
-	diag204_buf = vmalloc(PAGE_SIZE * pages);
+	diag204_buf = vmalloc(array_size(pages, PAGE_SIZE));
 	if (!diag204_buf)
 		return;
 
diff --git a/arch/s390/kvm/gaccess.c b/arch/s390/kvm/gaccess.c
index 8e2b8647ee12..07d30ffcfa41 100644
--- a/arch/s390/kvm/gaccess.c
+++ b/arch/s390/kvm/gaccess.c
@@ -847,7 +847,7 @@ int access_guest(struct kvm_vcpu *vcpu, unsigned long ga, u8 ar, void *data,
 	nr_pages = (((ga & ~PAGE_MASK) + len - 1) >> PAGE_SHIFT) + 1;
 	pages = pages_array;
 	if (nr_pages > ARRAY_SIZE(pages_array))
-		pages = vmalloc(nr_pages * sizeof(unsigned long));
+		pages = vmalloc(array_size(nr_pages, sizeof(unsigned long)));
 	if (!pages)
 		return -ENOMEM;
 	need_ipte_lock = psw_bits(*psw).dat && !asce.r;
diff --git a/block/partitions/check.c b/block/partitions/check.c
index 720145c49066..ffe408fead0c 100644
--- a/block/partitions/check.c
+++ b/block/partitions/check.c
@@ -122,7 +122,7 @@ static struct parsed_partitions *allocate_partitions(struct gendisk *hd)
 		return NULL;
 
 	nr = disk_max_parts(hd);
-	state->parts = vzalloc(nr * sizeof(state->parts[0]));
+	state->parts = vzalloc(array_size(nr, sizeof(state->parts[0])));
 	if (!state->parts) {
 		kfree(state);
 		return NULL;
diff --git a/drivers/base/firmware_loader/fallback.c b/drivers/base/firmware_loader/fallback.c
index 31b5015b59fe..f184a61173e0 100644
--- a/drivers/base/firmware_loader/fallback.c
+++ b/drivers/base/firmware_loader/fallback.c
@@ -403,7 +403,7 @@ static int fw_realloc_pages(struct fw_sysfs *fw_sysfs, int min_size)
 					 fw_priv->page_array_size * 2);
 		struct page **new_pages;
 
-		new_pages = vmalloc(new_array_size * sizeof(void *));
+		new_pages = vmalloc(array_size(new_array_size, sizeof(void *)));
 		if (!new_pages) {
 			fw_load_abort(fw_sysfs);
 			return -ENOMEM;
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 0f3fadd71230..8c5dbc573bf4 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -781,7 +781,7 @@ static bool zram_meta_alloc(struct zram *zram, u64 disksize)
 	size_t num_pages;
 
 	num_pages = disksize >> PAGE_SHIFT;
-	zram->table = vzalloc(num_pages * sizeof(*zram->table));
+	zram->table = vzalloc(array_size(num_pages, sizeof(*zram->table)));
 	if (!zram->table)
 		return false;
 
diff --git a/drivers/char/raw.c b/drivers/char/raw.c
index 293167c6e254..9d4a917710b8 100644
--- a/drivers/char/raw.c
+++ b/drivers/char/raw.c
@@ -321,7 +321,7 @@ static int __init raw_init(void)
 		max_raw_minors = MAX_RAW_MINORS;
 	}
 
-	raw_devices = vzalloc(sizeof(struct raw_device_data) * max_raw_minors);
+	raw_devices = vzalloc(array_size(max_raw_minors, sizeof(struct raw_device_data)));
 	if (!raw_devices) {
 		printk(KERN_ERR "Not enough memory for raw device structures\n");
 		ret = -ENOMEM;
diff --git a/drivers/dma/ipu/ipu_idmac.c b/drivers/dma/ipu/ipu_idmac.c
index ed76044ce4b9..8fb7268fd53c 100644
--- a/drivers/dma/ipu/ipu_idmac.c
+++ b/drivers/dma/ipu/ipu_idmac.c
@@ -910,7 +910,7 @@ static dma_cookie_t idmac_tx_submit(struct dma_async_tx_descriptor *tx)
 /* Called with ichan->chan_mutex held */
 static int idmac_desc_alloc(struct idmac_channel *ichan, int n)
 {
-	struct idmac_tx_desc *desc = vmalloc(n * sizeof(struct idmac_tx_desc));
+	struct idmac_tx_desc *desc = vmalloc(array_size(n, sizeof(struct idmac_tx_desc)));
 	struct idmac *idmac = to_idmac(ichan->dma_chan.device);
 
 	if (!desc)
diff --git a/drivers/dma/mic_x100_dma.c b/drivers/dma/mic_x100_dma.c
index 94d7bd7d2880..5fef4cfae678 100644
--- a/drivers/dma/mic_x100_dma.c
+++ b/drivers/dma/mic_x100_dma.c
@@ -385,7 +385,7 @@ static int mic_dma_alloc_desc_ring(struct mic_dma_chan *ch)
 	if (dma_mapping_error(dev, ch->desc_ring_micpa))
 		goto map_error;
 
-	ch->tx_array = vzalloc(MIC_DMA_DESC_RX_SIZE * sizeof(*ch->tx_array));
+	ch->tx_array = vzalloc(array_size(MIC_DMA_DESC_RX_SIZE, sizeof(*ch->tx_array)));
 	if (!ch->tx_array)
 		goto tx_error;
 	return 0;
diff --git a/drivers/gpu/drm/drm_hashtab.c b/drivers/gpu/drm/drm_hashtab.c
index dae18e58e79b..c92b00d42ece 100644
--- a/drivers/gpu/drm/drm_hashtab.c
+++ b/drivers/gpu/drm/drm_hashtab.c
@@ -47,7 +47,7 @@ int drm_ht_create(struct drm_open_hash *ht, unsigned int order)
 	if (size <= PAGE_SIZE / sizeof(*ht->table))
 		ht->table = kcalloc(size, sizeof(*ht->table), GFP_KERNEL);
 	else
-		ht->table = vzalloc(size*sizeof(*ht->table));
+		ht->table = vzalloc(array_size(size, sizeof(*ht->table)));
 	if (!ht->table) {
 		DRM_ERROR("Out of memory for hash table\n");
 		return -ENOMEM;
diff --git a/drivers/gpu/drm/drm_memory.c b/drivers/gpu/drm/drm_memory.c
index 3c54044214db..d69e4fc1ee77 100644
--- a/drivers/gpu/drm/drm_memory.c
+++ b/drivers/gpu/drm/drm_memory.c
@@ -80,7 +80,7 @@ static void *agp_remap(unsigned long offset, unsigned long size,
 	 * page-table instead (that's probably faster anyhow...).
 	 */
 	/* note: use vmalloc() because num_pages could be large... */
-	page_map = vmalloc(num_pages * sizeof(struct page *));
+	page_map = vmalloc(array_size(num_pages, sizeof(struct page *)));
 	if (!page_map)
 		return NULL;
 
diff --git a/drivers/gpu/drm/gma500/mmu.c b/drivers/gpu/drm/gma500/mmu.c
index ccb161c73a59..d74c0a4d71a2 100644
--- a/drivers/gpu/drm/gma500/mmu.c
+++ b/drivers/gpu/drm/gma500/mmu.c
@@ -217,7 +217,7 @@ struct psb_mmu_pd *psb_mmu_alloc_pd(struct psb_mmu_driver *driver,
 	clear_page(kmap(pd->dummy_page));
 	kunmap(pd->dummy_page);
 
-	pd->tables = vmalloc_user(sizeof(struct psb_mmu_pt *) * 1024);
+	pd->tables = vmalloc_user(array_size(1024, sizeof(struct psb_mmu_pt *)));
 	if (!pd->tables)
 		goto out_err4;
 
diff --git a/drivers/gpu/drm/selftests/test-drm_mm.c b/drivers/gpu/drm/selftests/test-drm_mm.c
index 12701321ce77..3d9b86ac6fac 100644
--- a/drivers/gpu/drm/selftests/test-drm_mm.c
+++ b/drivers/gpu/drm/selftests/test-drm_mm.c
@@ -389,7 +389,7 @@ static int __igt_reserve(unsigned int count, u64 size)
 	if (!order)
 		goto err;
 
-	nodes = vzalloc(sizeof(*nodes) * count);
+	nodes = vzalloc(array_size(count, sizeof(*nodes)));
 	if (!nodes)
 		goto err_order;
 
@@ -579,7 +579,7 @@ static int __igt_insert(unsigned int count, u64 size, bool replace)
 	DRM_MM_BUG_ON(!size);
 
 	ret = -ENOMEM;
-	nodes = vmalloc(count * sizeof(*nodes));
+	nodes = vmalloc(array_size(count, sizeof(*nodes)));
 	if (!nodes)
 		goto err;
 
@@ -889,7 +889,7 @@ static int __igt_insert_range(unsigned int count, u64 size, u64 start, u64 end)
 	 */
 
 	ret = -ENOMEM;
-	nodes = vzalloc(count * sizeof(*nodes));
+	nodes = vzalloc(array_size(count, sizeof(*nodes)));
 	if (!nodes)
 		goto err;
 
@@ -1046,7 +1046,7 @@ static int igt_align(void *ignored)
 	 * meets our requirements.
 	 */
 
-	nodes = vzalloc(max_count * sizeof(*nodes));
+	nodes = vzalloc(array_size(max_count, sizeof(*nodes)));
 	if (!nodes)
 		goto err;
 
@@ -1416,7 +1416,7 @@ static int igt_evict(void *ignored)
 	 */
 
 	ret = -ENOMEM;
-	nodes = vzalloc(size * sizeof(*nodes));
+	nodes = vzalloc(array_size(size, sizeof(*nodes)));
 	if (!nodes)
 		goto err;
 
@@ -1526,7 +1526,7 @@ static int igt_evict_range(void *ignored)
 	 */
 
 	ret = -ENOMEM;
-	nodes = vzalloc(size * sizeof(*nodes));
+	nodes = vzalloc(array_size(size, sizeof(*nodes)));
 	if (!nodes)
 		goto err;
 
@@ -1627,7 +1627,7 @@ static int igt_topdown(void *ignored)
 	 */
 
 	ret = -ENOMEM;
-	nodes = vzalloc(count * sizeof(*nodes));
+	nodes = vzalloc(array_size(count, sizeof(*nodes)));
 	if (!nodes)
 		goto err;
 
@@ -1741,7 +1741,7 @@ static int igt_bottomup(void *ignored)
 	 */
 
 	ret = -ENOMEM;
-	nodes = vzalloc(count * sizeof(*nodes));
+	nodes = vzalloc(array_size(count, sizeof(*nodes)));
 	if (!nodes)
 		goto err;
 
@@ -2098,7 +2098,7 @@ static int igt_color_evict(void *ignored)
 	 */
 
 	ret = -ENOMEM;
-	nodes = vzalloc(total_size * sizeof(*nodes));
+	nodes = vzalloc(array_size(total_size, sizeof(*nodes)));
 	if (!nodes)
 		goto err;
 
@@ -2199,7 +2199,7 @@ static int igt_color_evict_range(void *ignored)
 	 */
 
 	ret = -ENOMEM;
-	nodes = vzalloc(total_size * sizeof(*nodes));
+	nodes = vzalloc(array_size(total_size, sizeof(*nodes)));
 	if (!nodes)
 		goto err;
 
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 2aadf5813a40..a4c01bf25f02 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -285,13 +285,13 @@ struct ib_umem *ib_alloc_odp_umem(struct ib_ucontext *context,
 	mutex_init(&odp_data->umem_mutex);
 	init_completion(&odp_data->notifier_completion);
 
-	odp_data->page_list = vzalloc(pages * sizeof(*odp_data->page_list));
+	odp_data->page_list = vzalloc(array_size(pages, sizeof(*odp_data->page_list)));
 	if (!odp_data->page_list) {
 		ret = -ENOMEM;
 		goto out_odp_data;
 	}
 
-	odp_data->dma_list = vzalloc(pages * sizeof(*odp_data->dma_list));
+	odp_data->dma_list = vzalloc(array_size(pages, sizeof(*odp_data->dma_list)));
 	if (!odp_data->dma_list) {
 		ret = -ENOMEM;
 		goto out_page_list;
diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c b/drivers/infiniband/hw/hns/hns_roce_mr.c
index f7256d88d38f..e0b61ee6c12f 100644
--- a/drivers/infiniband/hw/hns/hns_roce_mr.c
+++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
@@ -144,7 +144,7 @@ static int hns_roce_buddy_init(struct hns_roce_buddy *buddy, int max_order)
 		buddy->bits[i] = kcalloc(s, sizeof(long), GFP_KERNEL |
 					 __GFP_NOWARN);
 		if (!buddy->bits[i]) {
-			buddy->bits[i] = vzalloc(s * sizeof(long));
+			buddy->bits[i] = vzalloc(array_size(s, sizeof(long)));
 			if (!buddy->bits[i])
 				goto err_out_free;
 		}
diff --git a/drivers/infiniband/hw/qib/qib_file_ops.c b/drivers/infiniband/hw/qib/qib_file_ops.c
index 6a8800b65047..493852cb5564 100644
--- a/drivers/infiniband/hw/qib/qib_file_ops.c
+++ b/drivers/infiniband/hw/qib/qib_file_ops.c
@@ -1239,7 +1239,7 @@ static int init_subctxts(struct qib_devdata *dd,
 		goto bail;
 	}
 
-	rcd->subctxt_uregbase = vmalloc_user(PAGE_SIZE * num_subctxts);
+	rcd->subctxt_uregbase = vmalloc_user(array_size(num_subctxts, PAGE_SIZE));
 	if (!rcd->subctxt_uregbase) {
 		ret = -ENOMEM;
 		goto bail;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 962fbcb57dc7..78a5168e055f 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -358,7 +358,7 @@ static int ipoib_cm_nonsrq_init_rx(struct net_device *dev, struct ib_cm_id *cm_i
 	int ret;
 	int i;
 
-	rx->rx_ring = vzalloc(ipoib_recvq_size * sizeof *rx->rx_ring);
+	rx->rx_ring = vzalloc(array_size(ipoib_recvq_size, sizeof(*rx->rx_ring)));
 	if (!rx->rx_ring)
 		return -ENOMEM;
 
@@ -1145,7 +1145,7 @@ static int ipoib_cm_tx_init(struct ipoib_cm_tx *p, u32 qpn,
 	int ret;
 
 	noio_flag = memalloc_noio_save();
-	p->tx_ring = vzalloc(ipoib_sendq_size * sizeof(*p->tx_ring));
+	p->tx_ring = vzalloc(array_size(ipoib_sendq_size, sizeof(*p->tx_ring)));
 	if (!p->tx_ring) {
 		memalloc_noio_restore(noio_flag);
 		ret = -ENOMEM;
@@ -1570,7 +1570,7 @@ static void ipoib_cm_create_srq(struct net_device *dev, int max_sge)
 		return;
 	}
 
-	priv->cm.srq_ring = vzalloc(ipoib_recvq_size * sizeof *priv->cm.srq_ring);
+	priv->cm.srq_ring = vzalloc(array_size(ipoib_recvq_size, sizeof(*priv->cm.srq_ring)));
 	if (!priv->cm.srq_ring) {
 		ib_destroy_srq(priv->cm.srq);
 		priv->cm.srq = NULL;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 8097b1d8422f..751196121be8 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1708,7 +1708,7 @@ static int ipoib_dev_init_default(struct net_device *dev)
 	if (!priv->rx_ring)
 		goto out;
 
-	priv->tx_ring = vzalloc(ipoib_sendq_size * sizeof *priv->tx_ring);
+	priv->tx_ring = vzalloc(array_size(ipoib_sendq_size, sizeof(*priv->tx_ring)));
 	if (!priv->tx_ring) {
 		pr_warn("%s: failed to allocate TX ring (%d entries)\n",
 			priv->ca->name, ipoib_sendq_size);
diff --git a/drivers/isdn/i4l/isdn_bsdcomp.c b/drivers/isdn/i4l/isdn_bsdcomp.c
index 99012c047751..88494b20f0e4 100644
--- a/drivers/isdn/i4l/isdn_bsdcomp.c
+++ b/drivers/isdn/i4l/isdn_bsdcomp.c
@@ -340,7 +340,7 @@ static void *bsd_alloc(struct isdn_ppp_comp_data *data)
 	 * Allocate space for the dictionary. This may be more than one page in
 	 * length.
 	 */
-	db->dict = vmalloc(hsize * sizeof(struct bsd_dict));
+	db->dict = vmalloc(array_size(hsize, sizeof(struct bsd_dict)));
 	if (!db->dict) {
 		bsd_free(db);
 		return NULL;
diff --git a/drivers/lightnvm/pblk-init.c b/drivers/lightnvm/pblk-init.c
index ae92984028d8..791f45d7843c 100644
--- a/drivers/lightnvm/pblk-init.c
+++ b/drivers/lightnvm/pblk-init.c
@@ -174,7 +174,7 @@ static int pblk_rwb_init(struct pblk *pblk)
 
 	nr_entries = pblk_rb_calculate_size(pblk->pgs_in_buffer);
 
-	entries = vzalloc(nr_entries * sizeof(struct pblk_rb_entry));
+	entries = vzalloc(array_size(nr_entries, sizeof(struct pblk_rb_entry)));
 	if (!entries)
 		return -ENOMEM;
 
diff --git a/drivers/md/dm-cache-policy-smq.c b/drivers/md/dm-cache-policy-smq.c
index 4ab23d0075f6..1b5b9ad9e492 100644
--- a/drivers/md/dm-cache-policy-smq.c
+++ b/drivers/md/dm-cache-policy-smq.c
@@ -69,7 +69,7 @@ static int space_init(struct entry_space *es, unsigned nr_entries)
 		return 0;
 	}
 
-	es->begin = vzalloc(sizeof(struct entry) * nr_entries);
+	es->begin = vzalloc(array_size(nr_entries, sizeof(struct entry)));
 	if (!es->begin)
 		return -ENOMEM;
 
@@ -588,7 +588,7 @@ static int h_init(struct smq_hash_table *ht, struct entry_space *es, unsigned nr
 	nr_buckets = roundup_pow_of_two(max(nr_entries / 4u, 16u));
 	ht->hash_bits = __ffs(nr_buckets);
 
-	ht->buckets = vmalloc(sizeof(*ht->buckets) * nr_buckets);
+	ht->buckets = vmalloc(array_size(nr_buckets, sizeof(*ht->buckets)));
 	if (!ht->buckets)
 		return -ENOMEM;
 
diff --git a/drivers/md/dm-region-hash.c b/drivers/md/dm-region-hash.c
index 85c32b22a420..b0f2eb9b972c 100644
--- a/drivers/md/dm-region-hash.c
+++ b/drivers/md/dm-region-hash.c
@@ -201,7 +201,7 @@ struct dm_region_hash *dm_region_hash_create(
 	rh->shift = RH_HASH_SHIFT;
 	rh->prime = RH_HASH_MULT;
 
-	rh->buckets = vmalloc(nr_buckets * sizeof(*rh->buckets));
+	rh->buckets = vmalloc(array_size(nr_buckets, sizeof(*rh->buckets)));
 	if (!rh->buckets) {
 		DMERR("unable to allocate region hash bucket memory");
 		kfree(rh);
diff --git a/drivers/md/dm-switch.c b/drivers/md/dm-switch.c
index 7924a6a33ddc..1af8db11f827 100644
--- a/drivers/md/dm-switch.c
+++ b/drivers/md/dm-switch.c
@@ -114,7 +114,7 @@ static int alloc_region_table(struct dm_target *ti, unsigned nr_paths)
 		return -EINVAL;
 	}
 
-	sctx->region_table = vmalloc(nr_slots * sizeof(region_table_slot_t));
+	sctx->region_table = vmalloc(array_size(nr_slots, sizeof(region_table_slot_t)));
 	if (!sctx->region_table) {
 		ti->error = "Cannot allocate region table";
 		return -ENOMEM;
diff --git a/drivers/md/dm-thin.c b/drivers/md/dm-thin.c
index b11107497d2e..d5e51ee26dad 100644
--- a/drivers/md/dm-thin.c
+++ b/drivers/md/dm-thin.c
@@ -2939,7 +2939,7 @@ static struct pool *pool_create(struct mapped_device *pool_md,
 		goto bad_mapping_pool;
 	}
 
-	pool->cell_sort_array = vmalloc(sizeof(*pool->cell_sort_array) * CELL_SORT_ARRAY_SIZE);
+	pool->cell_sort_array = vmalloc(array_size(CELL_SORT_ARRAY_SIZE, sizeof(*pool->cell_sort_array)));
 	if (!pool->cell_sort_array) {
 		*error = "Error allocating cell sort array";
 		err_p = ERR_PTR(-ENOMEM);
diff --git a/drivers/media/common/v4l2-tpg/v4l2-tpg-core.c b/drivers/media/common/v4l2-tpg/v4l2-tpg-core.c
index 9b64f4f354bf..ec9b4a448f60 100644
--- a/drivers/media/common/v4l2-tpg/v4l2-tpg-core.c
+++ b/drivers/media/common/v4l2-tpg/v4l2-tpg-core.c
@@ -132,10 +132,10 @@ int tpg_alloc(struct tpg_data *tpg, unsigned max_w)
 	for (plane = 0; plane < TPG_MAX_PLANES; plane++) {
 		unsigned pixelsz = plane ? 2 : 4;
 
-		tpg->contrast_line[plane] = vzalloc(max_w * pixelsz);
+		tpg->contrast_line[plane] = vzalloc(array_size(pixelsz, max_w));
 		if (!tpg->contrast_line[plane])
 			return -ENOMEM;
-		tpg->black_line[plane] = vzalloc(max_w * pixelsz);
+		tpg->black_line[plane] = vzalloc(array_size(pixelsz, max_w));
 		if (!tpg->black_line[plane])
 			return -ENOMEM;
 		tpg->random_line[plane] = vzalloc(max_w * 2 * pixelsz);
diff --git a/drivers/media/pci/meye/meye.c b/drivers/media/pci/meye/meye.c
index dedcdb573427..ca335d3ac382 100644
--- a/drivers/media/pci/meye/meye.c
+++ b/drivers/media/pci/meye/meye.c
@@ -1250,7 +1250,7 @@ static int vidioc_reqbufs(struct file *file, void *fh,
 
 	gbuffers = max(2, min((int)req->count, MEYE_MAX_BUFNBRS));
 	req->count = gbuffers;
-	meye.grab_fbuffer = rvmalloc(gbuffers * gbufsize);
+	meye.grab_fbuffer = rvmalloc(array_size(gbufsize, gbuffers));
 
 	if (!meye.grab_fbuffer) {
 		printk(KERN_ERR "meye: v4l framebuffer allocation failed\n");
@@ -1468,7 +1468,7 @@ static int meye_mmap(struct file *file, struct vm_area_struct *vma)
 		int i;
 
 		/* lazy allocation */
-		meye.grab_fbuffer = rvmalloc(gbuffers*gbufsize);
+		meye.grab_fbuffer = rvmalloc(array_size(gbufsize, gbuffers));
 		if (!meye.grab_fbuffer) {
 			printk(KERN_ERR "meye: v4l framebuffer allocation failed\n");
 			mutex_unlock(&meye.lock);
@@ -1625,7 +1625,7 @@ static int meye_probe(struct pci_dev *pcidev, const struct pci_device_id *ent)
 	ret = -ENOMEM;
 	meye.mchip_dev = pcidev;
 
-	meye.grab_temp = vmalloc(MCHIP_NB_PAGES_MJPEG * PAGE_SIZE);
+	meye.grab_temp = vmalloc(array_size(PAGE_SIZE, MCHIP_NB_PAGES_MJPEG));
 	if (!meye.grab_temp)
 		goto outvmalloc;
 
diff --git a/drivers/media/pci/pt1/pt1.c b/drivers/media/pci/pt1/pt1.c
index 4f6867af8311..e7e555add43e 100644
--- a/drivers/media/pci/pt1/pt1.c
+++ b/drivers/media/pci/pt1/pt1.c
@@ -446,7 +446,7 @@ static int pt1_init_tables(struct pt1 *pt1)
 	if (!pt1_nr_tables)
 		return 0;
 
-	tables = vmalloc(sizeof(struct pt1_table) * pt1_nr_tables);
+	tables = vmalloc(array_size(pt1_nr_tables, sizeof(struct pt1_table)));
 	if (tables == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/media/pci/ttpci/av7110_ipack.c b/drivers/media/pci/ttpci/av7110_ipack.c
index 5aff26574fe1..4a940ad2c57a 100644
--- a/drivers/media/pci/ttpci/av7110_ipack.c
+++ b/drivers/media/pci/ttpci/av7110_ipack.c
@@ -24,7 +24,7 @@ void av7110_ipack_reset(struct ipack *p)
 int av7110_ipack_init(struct ipack *p, int size,
 		      void (*func)(u8 *buf, int size, void *priv))
 {
-	if (!(p->buf = vmalloc(size*sizeof(u8)))) {
+	if (!(p->buf = vmalloc(array_size(size, sizeof(u8))))) {
 		printk(KERN_WARNING "Couldn't allocate memory for ipack\n");
 		return -ENOMEM;
 	}
diff --git a/drivers/media/platform/soc_camera/soc_camera.c b/drivers/media/platform/soc_camera/soc_camera.c
index 69f0d8e80bd8..67b7ab892688 100644
--- a/drivers/media/platform/soc_camera/soc_camera.c
+++ b/drivers/media/platform/soc_camera/soc_camera.c
@@ -481,7 +481,7 @@ static int soc_camera_init_user_formats(struct soc_camera_device *icd)
 		return -ENXIO;
 
 	icd->user_formats =
-		vmalloc(fmts * sizeof(struct soc_camera_format_xlate));
+		vmalloc(array_size(fmts, sizeof(struct soc_camera_format_xlate)));
 	if (!icd->user_formats)
 		return -ENOMEM;
 
diff --git a/drivers/media/platform/vivid/vivid-core.c b/drivers/media/platform/vivid/vivid-core.c
index 9042f17de0bc..2f60ba329f03 100644
--- a/drivers/media/platform/vivid/vivid-core.c
+++ b/drivers/media/platform/vivid/vivid-core.c
@@ -844,10 +844,10 @@ static int vivid_create_instance(struct platform_device *pdev, int inst)
 	tpg_init(&dev->tpg, 640, 360);
 	if (tpg_alloc(&dev->tpg, MAX_ZOOM * MAX_WIDTH))
 		goto free_dev;
-	dev->scaled_line = vzalloc(MAX_ZOOM * MAX_WIDTH);
+	dev->scaled_line = vzalloc(array_size(MAX_WIDTH, MAX_ZOOM));
 	if (!dev->scaled_line)
 		goto free_dev;
-	dev->blended_line = vzalloc(MAX_ZOOM * MAX_WIDTH);
+	dev->blended_line = vzalloc(array_size(MAX_WIDTH, MAX_ZOOM));
 	if (!dev->blended_line)
 		goto free_dev;
 
diff --git a/drivers/media/usb/gspca/gspca.c b/drivers/media/usb/gspca/gspca.c
index d29773b8f696..6e4201f2ca59 100644
--- a/drivers/media/usb/gspca/gspca.c
+++ b/drivers/media/usb/gspca/gspca.c
@@ -506,7 +506,7 @@ static int frame_alloc(struct gspca_dev *gspca_dev, struct file *file,
 	frsz = PAGE_ALIGN(frsz);
 	if (count >= GSPCA_MAX_FRAMES)
 		count = GSPCA_MAX_FRAMES - 1;
-	gspca_dev->frbuf = vmalloc_32(frsz * count);
+	gspca_dev->frbuf = vmalloc_32(array_size(count, frsz));
 	if (!gspca_dev->frbuf) {
 		pr_err("frame alloc failed\n");
 		return -ENOMEM;
diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index d713c1d56fbd..dd991cb9e126 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -69,7 +69,7 @@ static struct scatterlist *videobuf_vmalloc_to_sg(unsigned char *virt,
 	struct page *pg;
 	int i;
 
-	sglist = vzalloc(nr_pages * sizeof(*sglist));
+	sglist = vzalloc(array_size(nr_pages, sizeof(*sglist)));
 	if (NULL == sglist)
 		return NULL;
 	sg_init_table(sglist, nr_pages);
@@ -100,7 +100,7 @@ static struct scatterlist *videobuf_pages_to_sg(struct page **pages,
 
 	if (NULL == pages[0])
 		return NULL;
-	sglist = vmalloc(nr_pages * sizeof(*sglist));
+	sglist = vmalloc(array_size(nr_pages, sizeof(*sglist)));
 	if (NULL == sglist)
 		return NULL;
 	sg_init_table(sglist, nr_pages);
diff --git a/drivers/mtd/ftl.c b/drivers/mtd/ftl.c
index 75d0acf73395..7d1321c3cb17 100644
--- a/drivers/mtd/ftl.c
+++ b/drivers/mtd/ftl.c
@@ -262,7 +262,7 @@ static int build_maps(partition_t *part)
 
     /* Set up virtual page map */
     blocks = le32_to_cpu(header.FormattedSize) >> header.BlockSize;
-    part->VirtualBlockMap = vmalloc(blocks * sizeof(uint32_t));
+    part->VirtualBlockMap = vmalloc(array_size(blocks, sizeof(uint32_t)));
     if (!part->VirtualBlockMap)
 	    goto out_XferInfo;
 
diff --git a/drivers/mtd/mtdswap.c b/drivers/mtd/mtdswap.c
index 239668f07916..b73eb981dbea 100644
--- a/drivers/mtd/mtdswap.c
+++ b/drivers/mtd/mtdswap.c
@@ -1317,11 +1317,11 @@ static int mtdswap_init(struct mtdswap_dev *d, unsigned int eblocks,
 	for (i = 0; i < MTDSWAP_TREE_CNT; i++)
 		d->trees[i].root = RB_ROOT;
 
-	d->page_data = vmalloc(sizeof(int)*pages);
+	d->page_data = vmalloc(array_size(pages, sizeof(int)));
 	if (!d->page_data)
 		goto page_data_fail;
 
-	d->revmap = vmalloc(sizeof(int)*blocks);
+	d->revmap = vmalloc(array_size(blocks, sizeof(int)));
 	if (!d->revmap)
 		goto revmap_fail;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index b1270355b0b1..ee7c2d58b36b 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -98,8 +98,7 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 	iq->request_list = vmalloc_node((sizeof(*iq->request_list) * num_descs),
 					       numa_node);
 	if (!iq->request_list)
-		iq->request_list = vmalloc(sizeof(*iq->request_list) *
-						  num_descs);
+		iq->request_list = vmalloc(array_size(num_descs, sizeof(*iq->request_list)));
 	if (!iq->request_list) {
 		lio_dma_free(oct, q_size, iq->base_addr, iq->base_addr_dma);
 		dev_err(&oct->pci_dev->dev, "Alloc failed for IQ[%d] nr free list\n",
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index e0bc79ea3d88..4ab2fb909d80 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -1406,8 +1406,7 @@ static int hns_dsaf_init(struct dsaf_device *dsaf_dev)
 		return ret;
 
 	/* malloc mem for tcam mac key(vlan+mac) */
-	priv->soft_mac_tbl = vzalloc(sizeof(*priv->soft_mac_tbl)
-		  * DSAF_TCAM_SUM);
+	priv->soft_mac_tbl = vzalloc(array_size(DSAF_TCAM_SUM, sizeof(*priv->soft_mac_tbl)));
 	if (!priv->soft_mac_tbl) {
 		ret = -ENOMEM;
 		goto remove_hw;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 28b6b4e56487..f94cf6b9b73b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -578,7 +578,7 @@ static int fm10k_set_ringparam(struct net_device *netdev,
 
 	/* allocate temporary buffer to store rings in */
 	i = max_t(int, interface->num_tx_queues, interface->num_rx_queues);
-	temp_ring = vmalloc(i * sizeof(struct fm10k_ring));
+	temp_ring = vmalloc(array_size(i, sizeof(struct fm10k_ring)));
 
 	if (!temp_ring) {
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index d234c52debbf..f5580d876198 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1088,7 +1088,7 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 	/* allocate temporary buffer to store rings in */
 	i = max_t(int, adapter->num_tx_queues + adapter->num_xdp_queues,
 		  adapter->num_rx_queues);
-	temp_ring = vmalloc(i * sizeof(struct ixgbe_ring));
+	temp_ring = vmalloc(array_size(i, sizeof(struct ixgbe_ring)));
 
 	if (!temp_ring) {
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/netronome/nfp/flower/metadata.c b/drivers/net/ethernet/netronome/nfp/flower/metadata.c
index db977cf8e933..47fa9cdb0205 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/metadata.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/metadata.c
@@ -413,7 +413,7 @@ int nfp_flower_metadata_init(struct nfp_app *app)
 
 	/* Init ring buffer and unallocated stats_ids. */
 	priv->stats_ids.free_list.buf =
-		vmalloc(NFP_FL_STATS_ENTRY_RS * NFP_FL_STATS_ELEM_RS);
+		vmalloc(array_size(NFP_FL_STATS_ELEM_RS, NFP_FL_STATS_ENTRY_RS));
 	if (!priv->stats_ids.free_list.buf)
 		goto err_free_last_used;
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 97c146e7698a..2e2c2b187508 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -386,8 +386,7 @@ int qlcnic_83xx_setup_intr(struct qlcnic_adapter *adapter)
 	}
 
 	/* setup interrupt mapping table for fw */
-	ahw->intr_tbl = vzalloc(num_msix *
-				sizeof(struct qlcnic_intrpt_config));
+	ahw->intr_tbl = vzalloc(array_size(num_msix, sizeof(struct qlcnic_intrpt_config)));
 	if (!ahw->intr_tbl)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 83ce229f4eb7..2a7a02bd9d08 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -4971,7 +4971,7 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 		net_dev->hw_features &= ~NETIF_F_HW_VLAN_CTAG_FILTER;
 	}
 
-	table->entry = vzalloc(HUNT_FILTER_TBL_ROWS * sizeof(*table->entry));
+	table->entry = vzalloc(array_size(HUNT_FILTER_TBL_ROWS, sizeof(*table->entry)));
 	if (!table->entry) {
 		rc = -ENOMEM;
 		goto fail;
diff --git a/drivers/net/ppp/bsd_comp.c b/drivers/net/ppp/bsd_comp.c
index a9b759add187..7665c945f54c 100644
--- a/drivers/net/ppp/bsd_comp.c
+++ b/drivers/net/ppp/bsd_comp.c
@@ -406,7 +406,7 @@ static void *bsd_alloc (unsigned char *options, int opt_len, int decomp)
  * Allocate space for the dictionary. This may be more than one page in
  * length.
  */
-    db->dict = vmalloc(hsize * sizeof(struct bsd_dict));
+    db->dict = vmalloc(array_size(hsize, sizeof(struct bsd_dict)));
     if (!db->dict)
       {
 	bsd_free (db);
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index e1aef253601e..3cc3c7eb6bf6 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -977,8 +977,7 @@ static void connect(struct backend_info *be)
 	}
 
 	/* Use the number of queues requested by the frontend */
-	be->vif->queues = vzalloc(requested_num_queues *
-				  sizeof(struct xenvif_queue));
+	be->vif->queues = vzalloc(array_size(requested_num_queues, sizeof(struct xenvif_queue)));
 	if (!be->vif->queues) {
 		xenbus_dev_fatal(dev, -ENOMEM,
 				 "allocating queues");
diff --git a/drivers/oprofile/event_buffer.c b/drivers/oprofile/event_buffer.c
index 32888f2bd1a9..12ea4a4ad607 100644
--- a/drivers/oprofile/event_buffer.c
+++ b/drivers/oprofile/event_buffer.c
@@ -91,7 +91,7 @@ int alloc_event_buffer(void)
 		return -EINVAL;
 
 	buffer_pos = 0;
-	event_buffer = vmalloc(sizeof(unsigned long) * buffer_size);
+	event_buffer = vmalloc(array_size(buffer_size, sizeof(unsigned long)));
 	if (!event_buffer)
 		return -ENOMEM;
 
diff --git a/drivers/scsi/fnic/fnic_trace.c b/drivers/scsi/fnic/fnic_trace.c
index abddde11982b..bbd018179d7d 100644
--- a/drivers/scsi/fnic/fnic_trace.c
+++ b/drivers/scsi/fnic/fnic_trace.c
@@ -477,8 +477,7 @@ int fnic_trace_buf_init(void)
 	}
 	memset((void *)fnic_trace_buf_p, 0, (trace_max_pages * PAGE_SIZE));
 
-	fnic_trace_entries.page_offset = vmalloc(fnic_max_trace_entries *
-						  sizeof(unsigned long));
+	fnic_trace_entries.page_offset = vmalloc(array_size(fnic_max_trace_entries, sizeof(unsigned long)));
 	if (!fnic_trace_entries.page_offset) {
 		printk(KERN_ERR PFX "Failed to allocate memory for"
 				  " page_offset\n");
@@ -555,8 +554,7 @@ int fnic_fc_trace_init(void)
 
 	fc_trace_max_entries = (fnic_fc_trace_max_pages * PAGE_SIZE)/
 				FC_TRC_SIZE_BYTES;
-	fnic_fc_ctlr_trace_buf_p = (unsigned long)vmalloc(
-					fnic_fc_trace_max_pages * PAGE_SIZE);
+	fnic_fc_ctlr_trace_buf_p = (unsigned long)vmalloc(array_size(PAGE_SIZE, fnic_fc_trace_max_pages));
 	if (!fnic_fc_ctlr_trace_buf_p) {
 		pr_err("fnic: Failed to allocate memory for "
 		       "FC Control Trace Buf\n");
@@ -568,8 +566,7 @@ int fnic_fc_trace_init(void)
 			fnic_fc_trace_max_pages * PAGE_SIZE);
 
 	/* Allocate memory for page offset */
-	fc_trace_entries.page_offset = vmalloc(fc_trace_max_entries *
-						sizeof(unsigned long));
+	fc_trace_entries.page_offset = vmalloc(array_size(fc_trace_max_entries, sizeof(unsigned long)));
 	if (!fc_trace_entries.page_offset) {
 		pr_err("fnic:Failed to allocate memory for page_offset\n");
 		if (fnic_fc_ctlr_trace_buf_p) {
diff --git a/drivers/scsi/ipr.c b/drivers/scsi/ipr.c
index 45b9469cb963..984ed8fb398d 100644
--- a/drivers/scsi/ipr.c
+++ b/drivers/scsi/ipr.c
@@ -4329,9 +4329,9 @@ static int ipr_alloc_dump(struct ipr_ioa_cfg *ioa_cfg)
 	}
 
 	if (ioa_cfg->sis64)
-		ioa_data = vmalloc(IPR_FMT3_MAX_NUM_DUMP_PAGES * sizeof(__be32 *));
+		ioa_data = vmalloc(array_size(IPR_FMT3_MAX_NUM_DUMP_PAGES, sizeof(__be32 *)));
 	else
-		ioa_data = vmalloc(IPR_FMT2_MAX_NUM_DUMP_PAGES * sizeof(__be32 *));
+		ioa_data = vmalloc(array_size(IPR_FMT2_MAX_NUM_DUMP_PAGES, sizeof(__be32 *)));
 
 	if (!ioa_data) {
 		ipr_err("Dump memory allocation failed\n");
diff --git a/drivers/scsi/megaraid/megaraid_sas_fusion.c b/drivers/scsi/megaraid/megaraid_sas_fusion.c
index 093abc602f7d..083e6614660a 100644
--- a/drivers/scsi/megaraid/megaraid_sas_fusion.c
+++ b/drivers/scsi/megaraid/megaraid_sas_fusion.c
@@ -4827,8 +4827,7 @@ megasas_alloc_fusion_context(struct megasas_instance *instance)
 		(PLD_SPAN_INFO)__get_free_pages(GFP_KERNEL | __GFP_ZERO,
 						fusion->log_to_span_pages);
 	if (!fusion->log_to_span) {
-		fusion->log_to_span = vzalloc(MAX_LOGICAL_DRIVES_EXT *
-					      sizeof(LD_SPAN_INFO));
+		fusion->log_to_span = vzalloc(array_size(MAX_LOGICAL_DRIVES_EXT, sizeof(LD_SPAN_INFO)));
 		if (!fusion->log_to_span) {
 			dev_err(&instance->pdev->dev, "Failed from %s %d\n",
 				__func__, __LINE__);
@@ -4842,8 +4841,7 @@ megasas_alloc_fusion_context(struct megasas_instance *instance)
 		(struct LD_LOAD_BALANCE_INFO *)__get_free_pages(GFP_KERNEL | __GFP_ZERO,
 		fusion->load_balance_info_pages);
 	if (!fusion->load_balance_info) {
-		fusion->load_balance_info = vzalloc(MAX_LOGICAL_DRIVES_EXT *
-			sizeof(struct LD_LOAD_BALANCE_INFO));
+		fusion->load_balance_info = vzalloc(array_size(MAX_LOGICAL_DRIVES_EXT, sizeof(struct LD_LOAD_BALANCE_INFO)));
 		if (!fusion->load_balance_info)
 			dev_err(&instance->pdev->dev, "Failed to allocate load_balance_info, "
 				"continuing without Load Balance support\n");
diff --git a/drivers/scsi/qla2xxx/tcm_qla2xxx.c b/drivers/scsi/qla2xxx/tcm_qla2xxx.c
index aadfeaac3898..c367c0143c31 100644
--- a/drivers/scsi/qla2xxx/tcm_qla2xxx.c
+++ b/drivers/scsi/qla2xxx/tcm_qla2xxx.c
@@ -1635,7 +1635,7 @@ static int tcm_qla2xxx_init_lport(struct tcm_qla2xxx_lport *lport)
 		return rc;
 	}
 
-	lport->lport_loopid_map = vzalloc(sizeof(struct tcm_qla2xxx_fc_loopid) * 65536);
+	lport->lport_loopid_map = vzalloc(array_size(65536, sizeof(struct tcm_qla2xxx_fc_loopid)));
 	if (!lport->lport_loopid_map) {
 		pr_err("Unable to allocate lport->lport_loopid_map of %zu bytes\n",
 		    sizeof(struct tcm_qla2xxx_fc_loopid) * 65536);
diff --git a/drivers/staging/android/ion/ion_heap.c b/drivers/staging/android/ion/ion_heap.c
index 772dad65396e..6f1f1303e2cf 100644
--- a/drivers/staging/android/ion/ion_heap.c
+++ b/drivers/staging/android/ion/ion_heap.c
@@ -25,7 +25,7 @@ void *ion_heap_map_kernel(struct ion_heap *heap,
 	pgprot_t pgprot;
 	struct sg_table *table = buffer->sg_table;
 	int npages = PAGE_ALIGN(buffer->size) / PAGE_SIZE;
-	struct page **pages = vmalloc(sizeof(struct page *) * npages);
+	struct page **pages = vmalloc(array_size(npages, sizeof(struct page *)));
 	struct page **tmp = pages;
 
 	if (!pages)
diff --git a/drivers/staging/greybus/camera.c b/drivers/staging/greybus/camera.c
index 07ebfb88db9b..f15b4e1f3735 100644
--- a/drivers/staging/greybus/camera.c
+++ b/drivers/staging/greybus/camera.c
@@ -1180,8 +1180,7 @@ static int gb_camera_debugfs_init(struct gb_camera *gcam)
 		return PTR_ERR(gcam->debugfs.root);
 	}
 
-	gcam->debugfs.buffers = vmalloc(sizeof(*gcam->debugfs.buffers) *
-					GB_CAMERA_DEBUGFS_BUFFER_MAX);
+	gcam->debugfs.buffers = vmalloc(array_size(GB_CAMERA_DEBUGFS_BUFFER_MAX, sizeof(*gcam->debugfs.buffers)));
 	if (!gcam->debugfs.buffers)
 		return -ENOMEM;
 
diff --git a/drivers/target/target_core_transport.c b/drivers/target/target_core_transport.c
index 57ebd8f96c4c..c3b18506c393 100644
--- a/drivers/target/target_core_transport.c
+++ b/drivers/target/target_core_transport.c
@@ -253,7 +253,7 @@ int transport_alloc_session_tags(struct se_session *se_sess,
 	se_sess->sess_cmd_map = kzalloc(array_size(tag_size, tag_num),
 					GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_MAYFAIL);
 	if (!se_sess->sess_cmd_map) {
-		se_sess->sess_cmd_map = vzalloc(tag_num * tag_size);
+		se_sess->sess_cmd_map = vzalloc(array_size(tag_size, tag_num));
 		if (!se_sess->sess_cmd_map) {
 			pr_err("Unable to allocate se_sess->sess_cmd_map\n");
 			return -ENOMEM;
diff --git a/fs/cifs/misc.c b/fs/cifs/misc.c
index 460084a8eac5..efc020769b28 100644
--- a/fs/cifs/misc.c
+++ b/fs/cifs/misc.c
@@ -786,7 +786,7 @@ setup_aio_ctx_iter(struct cifs_aio_ctx *ctx, struct iov_iter *iter, int rw)
 				   GFP_KERNEL);
 
 	if (!bv) {
-		bv = vmalloc(max_pages * sizeof(struct bio_vec));
+		bv = vmalloc(array_size(max_pages, sizeof(struct bio_vec)));
 		if (!bv)
 			return -ENOMEM;
 	}
@@ -796,7 +796,7 @@ setup_aio_ctx_iter(struct cifs_aio_ctx *ctx, struct iov_iter *iter, int rw)
 				      GFP_KERNEL);
 
 	if (!pages) {
-		pages = vmalloc(max_pages * sizeof(struct page *));
+		pages = vmalloc(array_size(max_pages, sizeof(struct page *)));
 		if (!pages) {
 			kvfree(bv);
 			return -ENOMEM;
diff --git a/fs/dlm/lockspace.c b/fs/dlm/lockspace.c
index 78a7c855b06b..5ba94be006ee 100644
--- a/fs/dlm/lockspace.c
+++ b/fs/dlm/lockspace.c
@@ -517,7 +517,7 @@ static int new_lockspace(const char *name, const char *cluster,
 	size = dlm_config.ci_rsbtbl_size;
 	ls->ls_rsbtbl_size = size;
 
-	ls->ls_rsbtbl = vmalloc(sizeof(struct dlm_rsbtable) * size);
+	ls->ls_rsbtbl = vmalloc(array_size(size, sizeof(struct dlm_rsbtable)));
 	if (!ls->ls_rsbtbl)
 		goto out_lsfree;
 	for (i = 0; i < size; i++) {
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 334f2ad60704..6a9e09b64fb7 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -177,7 +177,7 @@ int nfsd_reply_cache_init(void)
 
 	drc_hashtbl = kcalloc(hashsize, sizeof(*drc_hashtbl), GFP_KERNEL);
 	if (!drc_hashtbl) {
-		drc_hashtbl = vzalloc(hashsize * sizeof(*drc_hashtbl));
+		drc_hashtbl = vzalloc(array_size(hashsize, sizeof(*drc_hashtbl)));
 		if (!drc_hashtbl)
 			goto out_nomem;
 	}
diff --git a/fs/reiserfs/bitmap.c b/fs/reiserfs/bitmap.c
index edc8ef78b63f..bf708ac287b4 100644
--- a/fs/reiserfs/bitmap.c
+++ b/fs/reiserfs/bitmap.c
@@ -1456,7 +1456,7 @@ int reiserfs_init_bitmap_cache(struct super_block *sb)
 	struct reiserfs_bitmap_info *bitmap;
 	unsigned int bmap_nr = reiserfs_bmap_count(sb);
 
-	bitmap = vmalloc(sizeof(*bitmap) * bmap_nr);
+	bitmap = vmalloc(array_size(bmap_nr, sizeof(*bitmap)));
 	if (bitmap == NULL)
 		return -ENOMEM;
 
diff --git a/fs/reiserfs/journal.c b/fs/reiserfs/journal.c
index d8c85c9a3227..3ec43a92c300 100644
--- a/fs/reiserfs/journal.c
+++ b/fs/reiserfs/journal.c
@@ -350,7 +350,7 @@ static struct reiserfs_journal_cnode *allocate_cnodes(int num_cnodes)
 	if (num_cnodes <= 0) {
 		return NULL;
 	}
-	head = vzalloc(num_cnodes * sizeof(struct reiserfs_journal_cnode));
+	head = vzalloc(array_size(num_cnodes, sizeof(struct reiserfs_journal_cnode)));
 	if (!head) {
 		return NULL;
 	}
diff --git a/fs/reiserfs/resize.c b/fs/reiserfs/resize.c
index 6052d323bc9a..38bac15d7be8 100644
--- a/fs/reiserfs/resize.c
+++ b/fs/reiserfs/resize.c
@@ -120,7 +120,7 @@ int reiserfs_resize(struct super_block *s, unsigned long block_count_new)
 		 * array of bitmap block pointers
 		 */
 		bitmap =
-		    vzalloc(sizeof(struct reiserfs_bitmap_info) * bmap_nr_new);
+		    vzalloc(array_size(bmap_nr_new, sizeof(struct reiserfs_bitmap_info)));
 		if (!bitmap) {
 			/*
 			 * Journal bitmaps are still supersized, but the
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index a3170ed0f8c9..490ebc646c16 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -5054,7 +5054,7 @@ static int adjust_insn_aux_data(struct bpf_verifier_env *env, u32 prog_len,
 
 	if (cnt == 1)
 		return 0;
-	new_data = vzalloc(sizeof(struct bpf_insn_aux_data) * prog_len);
+	new_data = vzalloc(array_size(prog_len, sizeof(struct bpf_insn_aux_data)));
 	if (!new_data)
 		return -ENOMEM;
 	memcpy(new_data, old_data, sizeof(struct bpf_insn_aux_data) * off);
diff --git a/kernel/cgroup/cgroup-v1.c b/kernel/cgroup/cgroup-v1.c
index 017db02d747c..4b57212b12fc 100644
--- a/kernel/cgroup/cgroup-v1.c
+++ b/kernel/cgroup/cgroup-v1.c
@@ -195,7 +195,7 @@ struct cgroup_pidlist {
 static void *pidlist_allocate(int count)
 {
 	if (PIDLIST_TOO_LARGE(count))
-		return vmalloc(count * sizeof(pid_t));
+		return vmalloc(array_size(count, sizeof(pid_t)));
 	else
 		return kmalloc(array_size(count, sizeof(pid_t)), GFP_KERNEL);
 }
diff --git a/kernel/power/swap.c b/kernel/power/swap.c
index 11b4282c2d20..9dd69d62a5d1 100644
--- a/kernel/power/swap.c
+++ b/kernel/power/swap.c
@@ -698,7 +698,7 @@ static int save_image_lzo(struct swap_map_handle *handle,
 		goto out_clean;
 	}
 
-	data = vmalloc(sizeof(*data) * nr_threads);
+	data = vmalloc(array_size(nr_threads, sizeof(*data)));
 	if (!data) {
 		pr_err("Failed to allocate LZO data\n");
 		ret = -ENOMEM;
@@ -1183,14 +1183,14 @@ static int load_image_lzo(struct swap_map_handle *handle,
 	nr_threads = num_online_cpus() - 1;
 	nr_threads = clamp_val(nr_threads, 1, LZO_THREADS);
 
-	page = vmalloc(sizeof(*page) * LZO_MAX_RD_PAGES);
+	page = vmalloc(array_size(LZO_MAX_RD_PAGES, sizeof(*page)));
 	if (!page) {
 		pr_err("Failed to allocate LZO page\n");
 		ret = -ENOMEM;
 		goto out_clean;
 	}
 
-	data = vmalloc(sizeof(*data) * nr_threads);
+	data = vmalloc(array_size(nr_threads, sizeof(*data)));
 	if (!data) {
 		pr_err("Failed to allocate LZO data\n");
 		ret = -ENOMEM;
diff --git a/kernel/rcu/rcutorture.c b/kernel/rcu/rcutorture.c
index 680c96d8c00f..277154745be4 100644
--- a/kernel/rcu/rcutorture.c
+++ b/kernel/rcu/rcutorture.c
@@ -826,8 +826,7 @@ rcu_torture_cbflood(void *arg)
 	    cbflood_intra_holdoff > 0 &&
 	    cur_ops->call &&
 	    cur_ops->cb_barrier) {
-		rhp = vmalloc(sizeof(*rhp) *
-			      cbflood_n_burst * cbflood_n_per_burst);
+		rhp = vmalloc(array3_size(cbflood_n_burst, cbflood_n_per_burst, sizeof(*rhp)));
 		err = !rhp;
 	}
 	if (err) {
diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index f4000c137dbe..31905f6a0c1e 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -285,7 +285,7 @@ static int __init test_rhltable(unsigned int entries)
 	if (entries == 0)
 		entries = 1;
 
-	rhl_test_objects = vzalloc(sizeof(*rhl_test_objects) * entries);
+	rhl_test_objects = vzalloc(array_size(entries, sizeof(*rhl_test_objects)));
 	if (!rhl_test_objects)
 		return -ENOMEM;
 
@@ -753,7 +753,7 @@ static int __init test_rht_init(void)
 	pr_info("Testing concurrent rhashtable access from %d threads\n",
 	        tcount);
 	sema_init(&prestart_sem, 1 - tcount);
-	tdata = vzalloc(tcount * sizeof(struct thread_data));
+	tdata = vzalloc(array_size(tcount, sizeof(struct thread_data)));
 	if (!tdata)
 		return -ENOMEM;
 	objs  = vzalloc(tcount * entries * sizeof(struct test_obj));
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 032e0fe45940..82321ddcd238 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -889,12 +889,12 @@ static int translate_table(struct net *net, const char *name,
 		 * if an error occurs
 		 */
 		newinfo->chainstack =
-			vmalloc(nr_cpu_ids * sizeof(*(newinfo->chainstack)));
+			vmalloc(array_size(nr_cpu_ids, sizeof(*(newinfo->chainstack))));
 		if (!newinfo->chainstack)
 			return -ENOMEM;
 		for_each_possible_cpu(i) {
 			newinfo->chainstack[i] =
-			  vmalloc(udc_cnt * sizeof(*(newinfo->chainstack[0])));
+			  vmalloc(array_size(udc_cnt, sizeof(*(newinfo->chainstack[0]))));
 			if (!newinfo->chainstack[i]) {
 				while (i)
 					vfree(newinfo->chainstack[--i]);
@@ -904,7 +904,7 @@ static int translate_table(struct net *net, const char *name,
 			}
 		}
 
-		cl_s = vmalloc(udc_cnt * sizeof(*cl_s));
+		cl_s = vmalloc(array_size(udc_cnt, sizeof(*cl_s)));
 		if (!cl_s)
 			return -ENOMEM;
 		i = 0; /* the i'th udc */
@@ -1298,7 +1298,7 @@ static int do_update_counters(struct net *net, const char *name,
 	if (num_counters == 0)
 		return -EINVAL;
 
-	tmp = vmalloc(num_counters * sizeof(*tmp));
+	tmp = vmalloc(array_size(num_counters, sizeof(*tmp)));
 	if (!tmp)
 		return -ENOMEM;
 
@@ -1439,7 +1439,7 @@ static int copy_counters_to_user(struct ebt_table *t,
 		return -EINVAL;
 	}
 
-	counterstmp = vmalloc(nentries * sizeof(*counterstmp));
+	counterstmp = vmalloc(array_size(nentries, sizeof(*counterstmp)));
 	if (!counterstmp)
 		return -ENOMEM;
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 136d81b40ade..cb5e77bae918 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1972,7 +1972,7 @@ static int ethtool_get_stats(struct net_device *dev, void __user *useraddr)
 		return -EFAULT;
 
 	stats.n_stats = n_stats;
-	data = vzalloc(n_stats * sizeof(u64));
+	data = vzalloc(array_size(n_stats, sizeof(u64)));
 	if (n_stats && !data)
 		return -ENOMEM;
 
@@ -2012,7 +2012,7 @@ static int ethtool_get_phy_stats(struct net_device *dev, void __user *useraddr)
 		return -EFAULT;
 
 	stats.n_stats = n_stats;
-	data = vzalloc(n_stats * sizeof(u64));
+	data = vzalloc(array_size(n_stats, sizeof(u64)));
 	if (n_stats && !data)
 		return -ENOMEM;
 
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 370abbf6f421..0b954efa67c0 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1410,7 +1410,7 @@ int __init ip_vs_conn_init(void)
 	/*
 	 * Allocate the connection hash table and initialize its list heads
 	 */
-	ip_vs_conn_tab = vmalloc(ip_vs_conn_tab_size * sizeof(*ip_vs_conn_tab));
+	ip_vs_conn_tab = vmalloc(array_size(ip_vs_conn_tab_size, sizeof(*ip_vs_conn_tab)));
 	if (!ip_vs_conn_tab)
 		return -ENOMEM;
 
diff --git a/sound/pci/cs46xx/dsp_spos.c b/sound/pci/cs46xx/dsp_spos.c
index 361a48c21b4a..1d656fbc80fd 100644
--- a/sound/pci/cs46xx/dsp_spos.c
+++ b/sound/pci/cs46xx/dsp_spos.c
@@ -240,8 +240,7 @@ struct dsp_spos_instance *cs46xx_dsp_spos_create (struct snd_cs46xx * chip)
 		return NULL;
 
 	/* better to use vmalloc for this big table */
-	ins->symbol_table.symbols = vmalloc(sizeof(struct dsp_symbol_entry) *
-					    DSP_MAX_SYMBOLS);
+	ins->symbol_table.symbols = vmalloc(array_size(DSP_MAX_SYMBOLS, sizeof(struct dsp_symbol_entry)));
 	ins->code.data = kmalloc(DSP_CODE_BYTE_SIZE, GFP_KERNEL);
 	ins->modules = kmalloc(array_size(DSP_MAX_MODULES, sizeof(struct dsp_module_desc)),
 			       GFP_KERNEL);
diff --git a/sound/pci/trident/trident_main.c b/sound/pci/trident/trident_main.c
index eabd84d9ffee..c802f655efbb 100644
--- a/sound/pci/trident/trident_main.c
+++ b/sound/pci/trident/trident_main.c
@@ -3362,7 +3362,7 @@ static int snd_trident_tlb_alloc(struct snd_trident *trident)
 	trident->tlb.entries = (unsigned int*)ALIGN((unsigned long)trident->tlb.buffer.area, SNDRV_TRIDENT_MAX_PAGES * 4);
 	trident->tlb.entries_dmaaddr = ALIGN(trident->tlb.buffer.addr, SNDRV_TRIDENT_MAX_PAGES * 4);
 	/* allocate shadow TLB page table (virtual addresses) */
-	trident->tlb.shadow_entries = vmalloc(SNDRV_TRIDENT_MAX_PAGES*sizeof(unsigned long));
+	trident->tlb.shadow_entries = vmalloc(array_size(SNDRV_TRIDENT_MAX_PAGES, sizeof(unsigned long)));
 	if (!trident->tlb.shadow_entries)
 		return -ENOMEM;
 
-- 
2.17.0
