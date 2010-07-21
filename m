Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 26A9E6B02A5
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 22:45:05 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o6L2j0Cm030606
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:45:01 -0700
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by wpaz13.hot.corp.google.com with ESMTP id o6L2ixKh006645
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:44:59 -0700
Received: by pzk26 with SMTP id 26so2397505pzk.33
        for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:44:59 -0700 (PDT)
Date: Tue, 20 Jul 2010 19:44:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/6] infiniband: remove dependency on __GFP_NOFAIL
In-Reply-To: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1007201938570.8728@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Wise <swise@chelsio.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Roland Dreier <rolandd@cisco.com>, linux-rdma@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The alloc_skb() in various allocations are failable, so remove
__GFP_NOFAIL from their masks.

Cc: Roland Dreier <rolandd@cisco.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 drivers/infiniband/hw/cxgb4/cq.c  |    4 ++--
 drivers/infiniband/hw/cxgb4/mem.c |    2 +-
 drivers/infiniband/hw/cxgb4/qp.c  |    6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -43,7 +43,7 @@ static int destroy_cq(struct c4iw_rdev *rdev, struct t4_cq *cq,
 	int ret;
 
 	wr_len = sizeof *res_wr + sizeof *res;
-	skb = alloc_skb(wr_len, GFP_KERNEL | __GFP_NOFAIL);
+	skb = alloc_skb(wr_len, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
 	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
@@ -118,7 +118,7 @@ static int create_cq(struct c4iw_rdev *rdev, struct t4_cq *cq,
 	/* build fw_ri_res_wr */
 	wr_len = sizeof *res_wr + sizeof *res;
 
-	skb = alloc_skb(wr_len, GFP_KERNEL | __GFP_NOFAIL);
+	skb = alloc_skb(wr_len, GFP_KERNEL);
 	if (!skb) {
 		ret = -ENOMEM;
 		goto err4;
diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -59,7 +59,7 @@ static int write_adapter_mem(struct c4iw_rdev *rdev, u32 addr, u32 len,
 		wr_len = roundup(sizeof *req + sizeof *sc +
 				 roundup(copy_len, T4_ULPTX_MIN_IO), 16);
 
-		skb = alloc_skb(wr_len, GFP_KERNEL | __GFP_NOFAIL);
+		skb = alloc_skb(wr_len, GFP_KERNEL);
 		if (!skb)
 			return -ENOMEM;
 		set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -130,7 +130,7 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 	/* build fw_ri_res_wr */
 	wr_len = sizeof *res_wr + 2 * sizeof *res;
 
-	skb = alloc_skb(wr_len, GFP_KERNEL | __GFP_NOFAIL);
+	skb = alloc_skb(wr_len, GFP_KERNEL);
 	if (!skb) {
 		ret = -ENOMEM;
 		goto err7;
@@ -961,7 +961,7 @@ static int rdma_fini(struct c4iw_dev *rhp, struct c4iw_qp *qhp)
 	PDBG("%s qhp %p qid 0x%x tid %u\n", __func__, qhp, qhp->wq.sq.qid,
 	     qhp->ep->hwtid);
 
-	skb = alloc_skb(sizeof *wqe, GFP_KERNEL | __GFP_NOFAIL);
+	skb = alloc_skb(sizeof *wqe, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
 	set_wr_txq(skb, CPL_PRIORITY_DATA, qhp->ep->txq_idx);
@@ -1035,7 +1035,7 @@ static int rdma_init(struct c4iw_dev *rhp, struct c4iw_qp *qhp)
 	PDBG("%s qhp %p qid 0x%x tid %u\n", __func__, qhp, qhp->wq.sq.qid,
 	     qhp->ep->hwtid);
 
-	skb = alloc_skb(sizeof *wqe, GFP_KERNEL | __GFP_NOFAIL);
+	skb = alloc_skb(sizeof *wqe, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
 	set_wr_txq(skb, CPL_PRIORITY_DATA, qhp->ep->txq_idx);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
