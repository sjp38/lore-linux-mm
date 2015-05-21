Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id DCF4D6B019E
	for <linux-mm@kvack.org>; Thu, 21 May 2015 16:23:58 -0400 (EDT)
Received: by qgew3 with SMTP id w3so48101982qge.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 13:23:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 105si2802267qgj.54.2015.05.21.13.23.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 13:23:58 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 29/36] IB/mlx5: add a new paramter to __mlx_ib_populated_pas for ODP with HMM.
Date: Thu, 21 May 2015 16:23:05 -0400
Message-Id: <1432239792-5002-10-git-send-email-jglisse@redhat.com>
In-Reply-To: <1432239792-5002-1-git-send-email-jglisse@redhat.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432239792-5002-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

When using HMM for ODP it will be usefull to pass the current mirror
page table iterator for __mlx_ib_populated_pas() function benefit. Add
void parameter for this.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 drivers/infiniband/hw/mlx5/mem.c     | 8 +++++---
 drivers/infiniband/hw/mlx5/mlx5_ib.h | 2 +-
 drivers/infiniband/hw/mlx5/mr.c      | 2 +-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/mem.c b/drivers/infiniband/hw/mlx5/mem.c
index 40df2cc..df56b7d 100644
--- a/drivers/infiniband/hw/mlx5/mem.c
+++ b/drivers/infiniband/hw/mlx5/mem.c
@@ -145,11 +145,13 @@ static u64 umem_dma_to_mtt(dma_addr_t umem_dma)
  * num_pages - total number of pages to fill
  * pas - bus addresses array to fill
  * access_flags - access flags to set on all present pages.
-		  use enum mlx5_ib_mtt_access_flags for this.
+ *                use enum mlx5_ib_mtt_access_flags for this.
+ * data - intended for odp with hmm, it should point to current mirror page
+ *        table iterator.
  */
 void __mlx5_ib_populate_pas(struct mlx5_ib_dev *dev, struct ib_umem *umem,
 			    int page_shift, size_t offset, size_t num_pages,
-			    __be64 *pas, int access_flags)
+			    __be64 *pas, int access_flags, void *data)
 {
 	unsigned long umem_page_shift = ilog2(umem->page_size);
 	int shift = page_shift - umem_page_shift;
@@ -201,7 +203,7 @@ void mlx5_ib_populate_pas(struct mlx5_ib_dev *dev, struct ib_umem *umem,
 {
 	return __mlx5_ib_populate_pas(dev, umem, page_shift, 0,
 				      ib_umem_num_pages(umem), pas,
-				      access_flags);
+				      access_flags, NULL);
 }
 int mlx5_ib_get_buf_offset(u64 addr, int page_shift, u32 *offset)
 {
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index dff1cfc..ec532f0 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -602,7 +602,7 @@ void mlx5_ib_cont_pages(struct ib_umem *umem, u64 addr, int *count, int *shift,
 			int *ncont, int *order);
 void __mlx5_ib_populate_pas(struct mlx5_ib_dev *dev, struct ib_umem *umem,
 			    int page_shift, size_t offset, size_t num_pages,
-			    __be64 *pas, int access_flags);
+			    __be64 *pas, int access_flags, void *data);
 void mlx5_ib_populate_pas(struct mlx5_ib_dev *dev, struct ib_umem *umem,
 			  int page_shift, __be64 *pas, int access_flags);
 void mlx5_ib_copy_pas(u64 *old, u64 *new, int step, int num);
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 71c5935..51a7775 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -912,7 +912,7 @@ int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index, int npages,
 		if (!zap) {
 			__mlx5_ib_populate_pas(dev, umem, PAGE_SHIFT,
 					       start_page_index, npages, pas,
-					       MLX5_IB_MTT_PRESENT);
+					       MLX5_IB_MTT_PRESENT, NULL);
 			/* Clear padding after the pages brought from the
 			 * umem. */
 			memset(pas + npages, 0, size - npages * sizeof(u64));
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
