Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4BE526B01F7
	for <linux-mm@kvack.org>; Thu, 21 May 2015 16:24:49 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so23488299wic.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 13:24:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id hf10si4739714wib.2.2015.05.21.13.24.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 13:24:47 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 35/36] IB/mlx5/hmm: add page fault support for ODP on HMM.
Date: Thu, 21 May 2015 16:23:11 -0400
Message-Id: <1432239792-5002-16-git-send-email-jglisse@redhat.com>
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

This patch add HMM specific support for hardware page faulting of
user memory region.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
cc: <linux-rdma@vger.kernel.org>
---
 drivers/infiniband/hw/mlx5/odp.c | 147 ++++++++++++++++++++++++++++++++++++++-
 1 file changed, 146 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index bd29155..093f5b8 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -56,6 +56,55 @@ static struct mlx5_ib_mr *mlx5_ib_odp_find_mr_lkey(struct mlx5_ib_dev *dev,
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM
 
 
+struct mlx5_hmm_pfault {
+	struct mlx5_ib_mr	*mlx5_ib_mr;
+	u64			start_idx;
+	dma_addr_t		access_mask;
+	unsigned		npages;
+	struct hmm_event	event;
+};
+
+static int mlx5_hmm_pfault(struct mlx5_ib_dev *mlx5_ib_dev,
+			   struct hmm_mirror *mirror,
+			   const struct hmm_event *event)
+{
+	struct mlx5_hmm_pfault *pfault;
+	struct hmm_pt_iter iter;
+	unsigned long addr, cnt;
+	int ret;
+
+	pfault = container_of(event, struct mlx5_hmm_pfault, event);
+	hmm_pt_iter_init(&iter);
+
+	for (addr = event->start, cnt = 0; addr < event->end;
+	     addr += PAGE_SIZE, ++cnt) {
+		dma_addr_t *ptep;
+
+		/* Get and lock pointer to mirror page table. */
+		ptep = hmm_pt_iter_update(&iter, &mirror->pt, addr);
+		/* This could be BUG_ON() as it can not happen. */
+		if (!ptep || !hmm_pte_test_valid_dma(ptep)) {
+			pr_warn("got empty mirror page table on pagefault.\n");
+			return -EINVAL;
+		}
+		if ((pfault->access_mask & ODP_WRITE_ALLOWED_BIT)) {
+			if (!hmm_pte_test_write(ptep)) {
+				pr_warn("got wrong protection permission on "
+					"pagefault.\n");
+				return -EINVAL;
+			}
+			hmm_pte_set_bit(ptep, ODP_WRITE_ALLOWED_SHIFT);
+		}
+		hmm_pte_set_bit(ptep, ODP_READ_ALLOWED_SHIFT);
+		pfault->npages++;
+	}
+	ret = mlx5_ib_update_mtt(pfault->mlx5_ib_mr,
+				 pfault->start_idx,
+				 cnt, 0, &iter);
+	hmm_pt_iter_fini(&iter, &mirror->pt);
+	return ret;
+}
+
 int mlx5_ib_umem_invalidate(struct ib_umem *umem, u64 start,
 			    u64 end, void *cookie)
 {
@@ -178,12 +227,19 @@ static int mlx5_hmm_update(struct hmm_mirror *mirror,
 			   const struct hmm_event *event)
 {
 	struct device *device = mirror->device->dev;
+	struct mlx5_ib_dev *mlx5_ib_dev;
+	struct ib_device *ib_device;
 	int ret = 0;
 
+	ib_device = container_of(mirror->device, struct ib_device, hmm_dev);
+	mlx5_ib_dev = to_mdev(ib_device);
+
 	switch (event->etype) {
 	case HMM_DEVICE_RFAULT:
 	case HMM_DEVICE_WFAULT:
-		/* FIXME implement. */
+		ret = mlx5_hmm_pfault(mlx5_ib_dev, mirror, event);
+		if (ret)
+			return ret;
 		break;
 	case HMM_ISDIRTY:
 		hmm_mirror_range_dirty(mirror, event->start, event->end);
@@ -228,6 +284,95 @@ void mlx5_dev_fini_odp_hmm(struct ib_device *ib_device)
 	hmm_device_unregister(&ib_device->hmm_dev);
 }
 
+/*
+ * Handle a single data segment in a page-fault WQE.
+ *
+ * Returns number of pages retrieved on success. The caller will continue to
+ * the next data segment.
+ * Can return the following error codes:
+ * -EAGAIN to designate a temporary error. The caller will abort handling the
+ *  page fault and resolve it.
+ * -EFAULT when there's an error mapping the requested pages. The caller will
+ *  abort the page fault handling and possibly move the QP to an error state.
+ * On other errors the QP should also be closed with an error.
+ */
+static int pagefault_single_data_segment(struct mlx5_ib_qp *qp,
+					 struct mlx5_ib_pfault *pfault,
+					 u32 key, u64 io_virt, size_t bcnt,
+					 u32 *bytes_mapped)
+{
+	struct mlx5_ib_dev *mlx5_ib_dev = to_mdev(qp->ibqp.pd->device);
+	struct ib_mirror *ib_mirror;
+	struct mlx5_hmm_pfault hmm_pfault;
+	int srcu_key;
+	int ret = 0;
+
+	srcu_key = srcu_read_lock(&mlx5_ib_dev->mr_srcu);
+	hmm_pfault.mlx5_ib_mr = mlx5_ib_odp_find_mr_lkey(mlx5_ib_dev, key);
+	/*
+	 * If we didn't find the MR, it means the MR was closed while we were
+	 * handling the ODP event. In this case we return -EFAULT so that the
+	 * QP will be closed.
+	 */
+	if (!hmm_pfault.mlx5_ib_mr || !hmm_pfault.mlx5_ib_mr->ibmr.pd) {
+		pr_err("Failed to find relevant mr for lkey=0x%06x, probably "
+		       "the MR was destroyed\n", key);
+		ret = -EFAULT;
+		goto srcu_unlock;
+	}
+	if (!hmm_pfault.mlx5_ib_mr->umem->odp_data) {
+		pr_debug("skipping non ODP MR (lkey=0x%06x) in page fault "
+		         "handler.\n", key);
+		if (bytes_mapped)
+			*bytes_mapped +=
+				(bcnt - pfault->mpfault.bytes_committed);
+		goto srcu_unlock;
+	}
+	if (hmm_pfault.mlx5_ib_mr->ibmr.pd != qp->ibqp.pd) {
+		pr_err("Page-fault with different PDs for QP and MR.\n");
+		ret = -EFAULT;
+		goto srcu_unlock;
+	}
+
+	ib_mirror = hmm_pfault.mlx5_ib_mr->umem->odp_data->ib_mirror;
+	if (ib_mirror->base.hmm == NULL) {
+		/* Somehow the mirror was kill from under us. */
+		ret = -EFAULT;
+		goto srcu_unlock;
+	}
+
+	/*
+	 * Avoid branches - this code will perform correctly
+	 * in all iterations (in iteration 2 and above,
+	 * bytes_committed == 0).
+	 */
+	io_virt += pfault->mpfault.bytes_committed;
+	bcnt -= pfault->mpfault.bytes_committed;
+
+	hmm_pfault.npages = 0;
+	hmm_pfault.start_idx = (io_virt - (hmm_pfault.mlx5_ib_mr->mmr.iova &
+					   PAGE_MASK)) >> PAGE_SHIFT;
+	hmm_pfault.access_mask = ODP_READ_ALLOWED_BIT;
+	hmm_pfault.access_mask |= hmm_pfault.mlx5_ib_mr->umem->writable ?
+				  ODP_WRITE_ALLOWED_BIT : 0;
+	hmm_pfault.event.start = io_virt & PAGE_MASK;
+	hmm_pfault.event.end = PAGE_ALIGN(io_virt + bcnt);
+	hmm_pfault.event.etype = hmm_pfault.mlx5_ib_mr->umem->writable ?
+				 HMM_DEVICE_WFAULT : HMM_DEVICE_RFAULT;
+	ret = hmm_mirror_fault(&ib_mirror->base, &hmm_pfault.event);
+
+	if (!ret && hmm_pfault.npages && bytes_mapped) {
+		u32 new_mappings = hmm_pfault.npages * PAGE_SIZE -
+				   (io_virt - round_down(io_virt, PAGE_SIZE));
+		*bytes_mapped += min_t(u32, new_mappings, bcnt);
+	}
+
+srcu_unlock:
+	srcu_read_unlock(&mlx5_ib_dev->mr_srcu, srcu_key);
+	pfault->mpfault.bytes_committed = 0;
+	return ret ? ret : hmm_pfault.npages;
+}
+
 
 #else /* CONFIG_INFINIBAND_ON_DEMAND_PAGING_HMM */
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
