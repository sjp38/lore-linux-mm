Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7006B01B3
	for <linux-mm@kvack.org>; Thu, 21 May 2015 16:24:19 -0400 (EDT)
Received: by qkx62 with SMTP id 62so18643015qkx.3
        for <linux-mm@kvack.org>; Thu, 21 May 2015 13:24:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x9si1586738qcs.32.2015.05.21.13.24.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 13:24:14 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 34/36] IB/mlx5/hmm: add mlx5 HMM device initialization and callback.
Date: Thu, 21 May 2015 16:23:10 -0400
Message-Id: <1432239792-5002-15-git-send-email-jglisse@redhat.com>
In-Reply-To: <1432239792-5002-1-git-send-email-jglisse@redhat.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432239792-5002-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, linux-rdma@vger.kernel.org

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This add the core HMM callback for mlx5 device driver and initialize
the HMM device for the mlx5 infiniband device driver.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
cc: <linux-rdma@vger.kernel.org>
---
 drivers/infiniband/core/umem_odp.c   |  12 ++-
 drivers/infiniband/hw/mlx5/main.c    |   5 +
 drivers/infiniband/hw/mlx5/mem.c     |  36 ++++++-
 drivers/infiniband/hw/mlx5/mlx5_ib.h |  19 +++-
 drivers/infiniband/hw/mlx5/mr.c      |   9 +-
 drivers/infiniband/hw/mlx5/odp.c     | 177 ++++++++++++++++++++++++++++++++++-
 include/rdma/ib_umem_odp.h           |  20 +++-
 7 files changed, 268 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index d5d57a8..559542d 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -132,7 +132,7 @@ int ib_umem_odp_get(struct ib_ucontext *context, struct ib_umem *umem)
 			return -ENOMEM;
 		}
 		kref_init(&ib_mirror->kref);
-		init_rwsem(&ib_mirror->hmm_mr_rwsem);
+		init_rwsem(&ib_mirror->umem_rwsem);
 		ib_mirror->umem_tree = RB_ROOT;
 		ib_mirror->ib_device = ib_device;
 
@@ -149,10 +149,11 @@ int ib_umem_odp_get(struct ib_ucontext *context, struct ib_umem *umem)
 		context->ib_mirror = ib_mirror_ref(ib_mirror);
 	}
 	mutex_unlock(&ib_device->hmm_mutex);
-	umem->odp_data.ib_mirror = ib_mirror;
+	umem->odp_data->ib_mirror = ib_mirror;
 
 	down_write(&ib_mirror->umem_rwsem);
-	rbt_ib_umem_insert(&umem->odp_data->interval_tree, &mirror->umem_tree);
+	rbt_ib_umem_insert(&umem->odp_data->interval_tree,
+			   &ib_mirror->umem_tree);
 	up_write(&ib_mirror->umem_rwsem);
 
 	mmput(mm);
@@ -161,7 +162,7 @@ int ib_umem_odp_get(struct ib_ucontext *context, struct ib_umem *umem)
 
 void ib_umem_odp_release(struct ib_umem *umem)
 {
-	struct ib_mirror *ib_mirror = umem->odp_data;
+	struct ib_mirror *ib_mirror = umem->odp_data->ib_mirror;
 
 	/*
 	 * Ensure that no more pages are mapped in the umem.
@@ -178,7 +179,8 @@ void ib_umem_odp_release(struct ib_umem *umem)
 	 * range covered by one and only one umem while holding the umem rwsem.
 	 */
 	down_write(&ib_mirror->umem_rwsem);
-	rbt_ib_umem_remove(&umem->odp_data->interval_tree, &mirror->umem_tree);
+	rbt_ib_umem_remove(&umem->odp_data->interval_tree,
+			   &ib_mirror->umem_tree);
 	up_write(&ib_mirror->umem_rwsem);
 
 	ib_mirror_unref(ib_mirror);
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index d553f90..eddabf0 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1316,6 +1316,9 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	if (err)
 		goto err_rsrc;
 
+	/* If HMM initialization fails we just do not enable odp. */
+	mlx5_dev_init_odp_hmm(&dev->ib_dev, &mdev->pdev->dev);
+
 	err = ib_register_device(&dev->ib_dev, NULL);
 	if (err)
 		goto err_odp;
@@ -1340,6 +1343,7 @@ err_umrc:
 
 err_dev:
 	ib_unregister_device(&dev->ib_dev);
+	mlx5_dev_fini_odp_hmm(&dev->ib_dev);
 
 err_odp:
 	mlx5_ib_odp_remove_one(dev);
@@ -1359,6 +1363,7 @@ static void mlx5_ib_remove(struct mlx5_core_dev *mdev, void *context)
 
 	ib_unregister_device(&dev->ib_dev);
 	destroy_umrc_res(dev);
+	mlx5_dev_fini_odp_hmm(&dev->ib_dev);
 	mlx5_ib_odp_remove_one(dev);
 	destroy_dev_resources(&dev->devr);
 	ib_dealloc_device(&dev->ib_dev);
diff --git a/drivers/infiniband/hw/mlx5/mem.c b/drivers/infiniband/hw/mlx5/mem.c
index 21084c7..f150825 100644
--- a/drivers/infiniband/hw/mlx5/mem.c
+++ b/drivers/infiniband/hw/mlx5/mem.c
@@ -164,7 +164,41 @@ void __mlx5_ib_populate_pas(struct mlx5_ib_dev *dev, struct ib_umem *umem,
 	int entry;
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM
-#error "CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM not supported at this stage !"
+	if (umem->odp_data) {
+		struct ib_mirror *ib_mirror = umem->odp_data->ib_mirror;
+		struct hmm_mirror *mirror = &ib_mirror->base;
+		struct hmm_pt_iter *iter = data, local_iter;
+		unsigned long addr;
+
+		if (iter == NULL) {
+			iter = &local_iter;
+			hmm_pt_iter_init(iter);
+		}
+
+		for (i = 0, addr = ib_umem_start(umem) + (offset << PAGE_SHIFT);
+		     i < num_pages; ++i, addr += PAGE_SIZE) {
+			dma_addr_t *ptep, pte;
+
+			/* Get and lock pointer to mirror page table. */
+			ptep = hmm_pt_iter_update(iter, &mirror->pt, addr);
+			pte = ptep ? *ptep : 0;
+			/* HMM will not have any page tables set up, if this
+			 * function is called before page faults have happened
+			 * on the MR. In that case, we don't have PA's yet, so
+			 * just set each one to zero and continue on. The hw
+			 * will trigger a page fault.
+			 */
+			if (hmm_pte_test_valid_dma(&pte))
+				pas[i] = cpu_to_be64(umem_dma_to_mtt(pte));
+			else
+				pas[i] = (__be64)0;
+		}
+
+		if (iter == &local_iter)
+			hmm_pt_iter_fini(iter, &mirror->pt);
+
+		return;
+	}
 #else /* CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM */
 	const bool odp = umem->odp_data != NULL;
 
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index a6d62be..f1bafd4 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -615,6 +615,7 @@ int mlx5_ib_check_mr_status(struct ib_mr *ibmr, u32 check_mask,
 			    struct ib_mr_status *mr_status);
 
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
+
 extern struct workqueue_struct *mlx5_ib_page_fault_wq;
 
 int mlx5_ib_internal_query_odp_caps(struct mlx5_ib_dev *dev);
@@ -629,13 +630,18 @@ void mlx5_ib_qp_disable_pagefaults(struct mlx5_ib_qp *qp);
 void mlx5_ib_qp_enable_pagefaults(struct mlx5_ib_qp *qp);
 
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM
-#error "CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM not supported at this stage !"
+void mlx5_dev_init_odp_hmm(struct ib_device *ib_dev, struct device *dev);
+void mlx5_dev_fini_odp_hmm(struct ib_device *ib_dev);
+int mlx5_ib_umem_invalidate(struct ib_umem *umem, u64 start,
+			    u64 end, void *cookie);
 #else /* CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM */
 void mlx5_ib_invalidate_range(struct ib_umem *umem, unsigned long start,
 			      unsigned long end);
 #endif /* CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM */
 
+
 #else /* CONFIG_INFINIBAND_ON_DEMAND_PAGING */
+
 static inline int mlx5_ib_internal_query_odp_caps(struct mlx5_ib_dev *dev)
 {
 	return 0;
@@ -671,4 +677,15 @@ static inline u8 convert_access(int acc)
 #define MLX5_MAX_UMR_SHIFT 16
 #define MLX5_MAX_UMR_PAGES (1 << MLX5_MAX_UMR_SHIFT)
 
+#ifndef CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM
+static inline void mlx5_dev_init_odp_hmm(struct ib_device *ib_dev,
+					 struct device *dev)
+{
+}
+
+static inline void mlx5_dev_fini_odp_hmm(struct ib_device *ib_dev)
+{
+}
+#endif /* ! CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM */
+
 #endif /* MLX5_IB_H */
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 23cd123..7b2d84a 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -1210,7 +1210,14 @@ int mlx5_ib_dereg_mr(struct ib_mr *ibmr)
 		/* Wait for all running page-fault handlers to finish. */
 		synchronize_srcu(&dev->mr_srcu);
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM
-#error "CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM not supported at this stage !"
+		if (mlx5_ib_umem_invalidate(umem, ib_umem_start(umem),
+					    ib_umem_end(umem), NULL))
+			/*
+			 * FIXME do something to kill all mr and umem
+			 * in use by this process.
+			 */
+			pr_err("killing all mr with odp due to "
+			       "mtt update failure\n");
 #else /* CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM */
 		/* Destroy all page mappings */
 		mlx5_ib_invalidate_range(umem, ib_umem_start(umem),
diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index 1de4d13..bd29155 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -52,8 +52,183 @@ static struct mlx5_ib_mr *mlx5_ib_odp_find_mr_lkey(struct mlx5_ib_dev *dev,
 	return container_of(mmr, struct mlx5_ib_mr, mmr);
 }
 
+
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM
-#error "CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM not supported at this stage !"
+
+
+int mlx5_ib_umem_invalidate(struct ib_umem *umem, u64 start,
+			    u64 end, void *cookie)
+{
+	const u64 umr_block_mask = (MLX5_UMR_MTT_ALIGNMENT / sizeof(u64)) - 1;
+	u64 idx = 0, blk_start_idx = 0;
+	struct hmm_pt_iter iter;
+	struct mlx5_ib_mr *mlx5_ib_mr;
+	struct hmm_mirror *mirror;
+	int in_block = 0;
+	u64 addr;
+	int ret = 0;
+
+	if (!umem || !umem->odp_data) {
+		pr_err("invalidation called on NULL umem or non-ODP umem\n");
+		return -EINVAL;
+	}
+
+	/* Is this ib_mr active and registered yet ? */
+	if (umem->odp_data->private == NULL)
+		return 0;
+
+	mlx5_ib_mr = umem->odp_data->private;
+	if (!mlx5_ib_mr->ibmr.pd)
+		return 0;
+
+	start = max_t(u64, ib_umem_start(umem), start);
+	end = min_t(u64, ib_umem_end(umem), end);
+	hmm_pt_iter_init(&iter);
+	mirror = &umem->odp_data->ib_mirror->base;
+
+	/*
+	 * Iteration one - zap the HW's MTTs. HMM ensures that while we are
+	 * doing the invalidation, no page fault will attempt to overwrite the
+	 * same MTTs.  Concurent invalidations might race us, but they will
+	 * write 0s as well, so no difference in the end result.
+	 */
+	for (addr = start; addr < end; addr += (u64)umem->page_size) {
+		dma_addr_t *ptep;
+
+		/* Need to happen before ptep as ptep might break the loop and
+		 * idx might be use outside the loop.
+		 */
+		idx = (addr - ib_umem_start(umem)) / PAGE_SIZE;
+
+		/* Get and lock pointer to mirror page table. */
+		ptep = hmm_pt_iter_update(&iter, &mirror->pt, addr);
+		if (!ptep) {
+			addr = hmm_pt_iter_next(&iter, &mirror->pt, addr, end);
+			continue;
+		}
+
+		/*
+		 * Strive to write the MTTs in chunks, but avoid overwriting
+		 * non-existing MTTs. The huristic here can be improved to
+		 * estimate the cost of another UMR vs. the cost of bigger
+		 * UMR.
+		 */
+		if ((*ptep) & (ODP_READ_ALLOWED_BIT | ODP_WRITE_ALLOWED_BIT)) {
+			if ((*ptep) & ODP_WRITE_ALLOWED_BIT)
+				hmm_pte_set_dirty(ptep);
+			/*
+			 * Because there can not be concurrent overlapping
+			 * munmap, page migrate, page write protect then it
+			 * is safe here to clear those bits.
+			 */
+			hmm_pte_clear_bit(ptep, ODP_READ_ALLOWED_SHIFT);
+			hmm_pte_clear_bit(ptep, ODP_WRITE_ALLOWED_SHIFT);
+			if (!in_block) {
+				blk_start_idx = idx;
+				in_block = 1;
+			}
+		} else {
+			u64 umr_offset = idx & umr_block_mask;
+
+			if (in_block && umr_offset == 0) {
+				ret = mlx5_ib_update_mtt(mlx5_ib_mr,
+							 blk_start_idx,
+							 idx - blk_start_idx, 1,
+							 &iter) || ret;
+				in_block = 0;
+			}
+		}
+	}
+	if (in_block)
+		ret = mlx5_ib_update_mtt(mlx5_ib_mr, blk_start_idx,
+					 idx - blk_start_idx + 1, 1,
+					 &iter) || ret;
+	hmm_pt_iter_fini(&iter, &mirror->pt);
+	return ret;
+}
+
+static int mlx5_hmm_invalidate_range(struct hmm_mirror *mirror,
+				     unsigned long start,
+				     unsigned long end)
+{
+	struct ib_mirror *ib_mirror;
+	int ret;
+
+	ib_mirror = container_of(mirror, struct ib_mirror, base);
+
+	/* Go over all memory region and invalidate them. */
+	down_read(&ib_mirror->umem_rwsem);
+	ret = rbt_ib_umem_for_each_in_range(&ib_mirror->umem_tree, start, end,
+					    mlx5_ib_umem_invalidate, NULL);
+	up_read(&ib_mirror->umem_rwsem);
+	return ret;
+}
+
+static void mlx5_hmm_release(struct hmm_mirror *mirror)
+{
+	struct ib_mirror *ib_mirror;
+
+	ib_mirror = container_of(mirror, struct ib_mirror, base);
+
+	/* Go over all memory region and invalidate them. */
+	mlx5_hmm_invalidate_range(mirror, 0, ULLONG_MAX);
+}
+
+static int mlx5_hmm_update(struct hmm_mirror *mirror,
+			   const struct hmm_event *event)
+{
+	struct device *device = mirror->device->dev;
+	int ret = 0;
+
+	switch (event->etype) {
+	case HMM_DEVICE_RFAULT:
+	case HMM_DEVICE_WFAULT:
+		/* FIXME implement. */
+		break;
+	case HMM_ISDIRTY:
+		hmm_mirror_range_dirty(mirror, event->start, event->end);
+		break;
+	case HMM_NONE:
+	default:
+		dev_warn(device, "Warning: unhandled HMM event (%d)"
+			 "defaulting to invalidation\n", event->etype);
+		/* Fallthrough. */
+	/* For write protect and fork we could only invalidate writeable mr. */
+	case HMM_WRITE_PROTECT:
+	case HMM_MIGRATE:
+	case HMM_MUNMAP:
+	case HMM_FORK:
+		ret = mlx5_hmm_invalidate_range(mirror,
+						event->start,
+						event->end);
+		break;
+	}
+
+	return ret;
+}
+
+static const struct hmm_device_ops mlx5_hmm_ops = {
+	.release		= &mlx5_hmm_release,
+	.update			= &mlx5_hmm_update,
+};
+
+void mlx5_dev_init_odp_hmm(struct ib_device *ib_device, struct device *dev)
+{
+	INIT_LIST_HEAD(&ib_device->ib_mirrors);
+	ib_device->hmm_dev.dev = dev;
+	ib_device->hmm_dev.ops = &mlx5_hmm_ops;
+	ib_device->hmm_ready = !hmm_device_register(&ib_device->hmm_dev);
+	mutex_init(&ib_device->hmm_mutex);
+}
+
+void mlx5_dev_fini_odp_hmm(struct ib_device *ib_device)
+{
+	if (!ib_device->hmm_ready)
+		return;
+	hmm_device_unregister(&ib_device->hmm_dev);
+}
+
+
 #else /* CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM */
 
 
diff --git a/include/rdma/ib_umem_odp.h b/include/rdma/ib_umem_odp.h
index c7c2670..e982fd3 100644
--- a/include/rdma/ib_umem_odp.h
+++ b/include/rdma/ib_umem_odp.h
@@ -133,7 +133,25 @@ struct umem_odp_node *rbt_ib_umem_iter_next(struct umem_odp_node *node,
 
 
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM
-#error "CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM not supported at this stage !"
+
+
+/*
+ * HMM have few bits reserved for hardware specific bits inside the mirror page
+ * table. For IB we record the mapping protection per page there.
+ */
+#define ODP_READ_ALLOWED_SHIFT	(HMM_PTE_HW_SHIFT + 0)
+#define ODP_WRITE_ALLOWED_SHIFT	(HMM_PTE_HW_SHIFT + 1)
+#define ODP_READ_ALLOWED_BIT	(1 << ODP_READ_ALLOWED_SHIFT)
+#define ODP_WRITE_ALLOWED_BIT	(1 << ODP_WRITE_ALLOWED_SHIFT)
+
+/* Make sure we are not overwritting valid address bit on target arch. */
+#if (HMM_PTE_HW_SHIFT + 2) > PAGE_SHIFT
+#error (HMM_PTE_HW_SHIFT + 2) > PAGE_SHIFT
+#endif
+
+#define ODP_DMA_ADDR_MASK HMM_PTE_DMA_MASK
+
+
 #else /* CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM */
 
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
