Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1476B019F
	for <linux-mm@kvack.org>; Thu, 21 May 2015 16:24:02 -0400 (EDT)
Received: by qkgv12 with SMTP id v12so65542237qkg.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 13:24:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o78si8784319qkh.35.2015.05.21.13.24.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 13:24:01 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 30/36] IB/mlx5: add a new paramter to mlx5_ib_update_mtt() for ODP with HMM.
Date: Thu, 21 May 2015 16:23:06 -0400
Message-Id: <1432239792-5002-11-git-send-email-jglisse@redhat.com>
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

When using HMM for ODP it will be usefull to pass the current mirror
page table iterator for mlx5_ib_update_mtt() function benefit. Add
void parameter for this.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
cc: <linux-rdma@vger.kernel.org>
---
 drivers/infiniband/hw/mlx5/mlx5_ib.h | 2 +-
 drivers/infiniband/hw/mlx5/mr.c      | 4 ++--
 drivers/infiniband/hw/mlx5/odp.c     | 8 +++++---
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index ec532f0..ec629f2 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -569,7 +569,7 @@ struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 				  u64 virt_addr, int access_flags,
 				  struct ib_udata *udata);
 int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index,
-		       int npages, int zap);
+		       int npages, int zap, void *data);
 int mlx5_ib_dereg_mr(struct ib_mr *ibmr);
 int mlx5_ib_destroy_mr(struct ib_mr *ibmr);
 struct ib_mr *mlx5_ib_create_mr(struct ib_pd *pd,
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 51a7775..759ed15 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -845,7 +845,7 @@ free_mr:
 
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
 int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index, int npages,
-		       int zap)
+		       int zap, void *data)
 {
 	struct mlx5_ib_dev *dev = mr->dev;
 	struct device *ddev = dev->ib_dev.dma_device;
@@ -912,7 +912,7 @@ int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index, int npages,
 		if (!zap) {
 			__mlx5_ib_populate_pas(dev, umem, PAGE_SHIFT,
 					       start_page_index, npages, pas,
-					       MLX5_IB_MTT_PRESENT, NULL);
+					       MLX5_IB_MTT_PRESENT, data);
 			/* Clear padding after the pages brought from the
 			 * umem. */
 			memset(pas + npages, 0, size - npages * sizeof(u64));
diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index 5099db0..5171959 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -91,14 +91,15 @@ void mlx5_ib_invalidate_range(struct ib_umem *umem, unsigned long start,
 
 			if (in_block && umr_offset == 0) {
 				mlx5_ib_update_mtt(mr, blk_start_idx,
-						   idx - blk_start_idx, 1);
+						   idx - blk_start_idx, 1,
+						   NULL);
 				in_block = 0;
 			}
 		}
 	}
 	if (in_block)
 		mlx5_ib_update_mtt(mr, blk_start_idx, idx - blk_start_idx + 1,
-				   1);
+				   1, NULL);
 
 	/*
 	 * We are now sure that the device will not access the
@@ -256,7 +257,8 @@ static int pagefault_single_data_segment(struct mlx5_ib_qp *qp,
 			 * this MR, since ib_umem_odp_map_dma_pages already
 			 * checks this.
 			 */
-			ret = mlx5_ib_update_mtt(mr, start_idx, npages, 0);
+			ret = mlx5_ib_update_mtt(mr, start_idx,
+						 npages, 0, NULL);
 		} else {
 			ret = -EAGAIN;
 		}
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
