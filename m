Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E230DC282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:27:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FF502147A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:27:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FF502147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=il.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DD618E0002; Tue, 29 Jan 2019 08:27:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18F128E0001; Tue, 29 Jan 2019 08:27:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02E058E0002; Tue, 29 Jan 2019 08:27:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFD9F8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:27:07 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w1so24281976qta.12
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:27:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id
         :content-transfer-encoding:mime-version;
        bh=K8gAFbcIx1XiRGsc1R9BpomGX0soI2ZVcq8AoXCBI30=;
        b=lRffVxh6Eeyius3HdGgBcA0+fE9lBf7DAswuKpuJM6veUnbZe2F9saFJIJcG9ClSfX
         iPk51i5st2pInrX7fr6BXocRoe99lGW+95tONMrKYkMQkUHIT2oPU9IXxwDlhAYBg/CS
         gmrP+QcpZ0tKyYQKgzn+Cu/3o0TeAxU8+F2I5g0CwKHjxi0yH4HkJc7ArUhNxDYgEm/F
         2Dr88bsijh0wqTmph6Xel/+DACuawA7GbByNCLRjyHOSlzNP5/HIRnRJ1h1sm0x0UaaY
         UH3SJIzvOZwHR/CT8hXSycK06r26p+zcKSQLS7/9pppKgLk2N85Ix+0cYJi9/GM5mljb
         zoAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=joeln@il.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukfOV08/xGKJrJarcb8tiA7j+gaec3KfANzxqNfyIq7q0lv1VDmP
	rz2BQEaCiYmIflWX4iULCkz+WqabV3EEAMzyhEmUg2mRY25ltjPMoAn4dmDIBpT0gUr3BF8uAMV
	G12QfJiXoc1mdD0rneixZUeDeUePa8pAUQV2YdDdp868oOxfTbcMCgflvk8WzF4aalA==
X-Received: by 2002:a37:8882:: with SMTP id k124mr23164056qkd.1.1548768427373;
        Tue, 29 Jan 2019 05:27:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6I0Wy+Z3lQPqvk4SpUAJORFJHS1jNZecjWPZwF2Bdhghb6KIWt3OGpLck3HMD51JBeqkO+
X-Received: by 2002:a37:8882:: with SMTP id k124mr23163946qkd.1.1548768425437;
        Tue, 29 Jan 2019 05:27:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548768425; cv=none;
        d=google.com; s=arc-20160816;
        b=1Iwlm32FVuf2ATmeMKmIJn4ymPXodWv/HhN/rWEjjKXubp9N4U7l758PVQmLPlj3Ui
         T1H9aF+c7Zuq6A7LY35GJ0aYMhYIk+Hxldo9lKZG8vqlXlorRlcopeFHOu3L7ycXj98S
         KrT568Y31hL11GeK0U3HRkCueFij3248DgGJM9fQXWcG+4w0S1/scna6VLzBmlDkYRbe
         iVejFyOGjZqhGzyR75X0RJJC+YpRUNjo1O8gc9KfXL1w9HX00cOjJUYnGn0Cj3z1O89h
         b2Ec+TlkGwfTzWr34dJHgU22Ah6T72vZeKCgaaZVuAwCQ5/vH//CpuH8/T2f3xYCmj+R
         UkTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:message-id:references
         :in-reply-to:date:subject:cc:to:from;
        bh=K8gAFbcIx1XiRGsc1R9BpomGX0soI2ZVcq8AoXCBI30=;
        b=m/h0eSAULa1T9cpupEEXTKZ8eg9opMg0c0vuqtZQ6XW/1S63widPlc1r3NgEDlKekK
         OIG/RqyWbVBdp9Jd6lPYLHV2HlCbf8kLyIimN8Pjdqq2eHQtBMOApLjmIj63NdRqz5Dk
         Owpb1C4jJJRxhX9z1N953NeWJQnCbWIV1qDyeefhkvwfDGNZcNVIeRsYW0mtmoEgDOVx
         2gWqeF+Kn0iDuWbebhTIozgb2WGkx077EgTtLlSPtZYyjWM6qLgCHuKnk5+52xvyYt0Y
         jOuLpmSWb9aJgFscFx3xchTWsfH41K8hlw2Wvf3/gNOpFp9cm6cvVJFzX6YtWGO1Ba2Q
         peQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=joeln@il.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j36si2695268qvj.88.2019.01.29.05.27.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 05:27:05 -0800 (PST)
Received-SPF: pass (google.com: domain of joeln@il.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=joeln@il.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0TDQwgr020025
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:27:04 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qaqcv1a4q-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:27:03 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <joeln@il.ibm.com>;
	Tue, 29 Jan 2019 13:27:01 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 29 Jan 2019 13:26:57 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0TDQtFw3604910
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 29 Jan 2019 13:26:55 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9E80CAE045;
	Tue, 29 Jan 2019 13:26:55 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EB841AE04D;
	Tue, 29 Jan 2019 13:26:53 +0000 (GMT)
Received: from tal (unknown [9.148.32.96])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 29 Jan 2019 13:26:53 +0000 (GMT)
Received: by tal (sSMTP sendmail emulation); Tue, 29 Jan 2019 15:26:53 +0200
From: Joel Nider <joeln@il.ibm.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Leon Romanovsky <leon@kernel.org>, Doug Ledford <dledford@redhat.com>,
        Mike Rapoport <rppt@linux.ibm.com>, Joel Nider <joeln@il.ibm.com>,
        linux-mm@kvack.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 3/5] RDMA/uverbs: add owner parameter to ib_umem_get
Date: Tue, 29 Jan 2019 15:26:24 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
References: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19012913-0008-0000-0000-000002B7768C
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19012913-0009-0000-0000-00002223B94A
Message-Id: <1548768386-28289-4-git-send-email-joeln@il.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-29_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901290102
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ib_umem_get is a core function used by drivers that support RDMA.
The 'owner' parameter signifies the process that owns the memory.
Until now, it was assumed that the owning process was the current
process. This adds the flexibility to specify a process other than
the current process. All drivers that call this function are also
updated, but the default behaviour is to keep backwards
compatibility by assuming the current process is the owner when
the 'owner' parameter is NULL.

Signed-off-by: Joel Nider <joeln@il.ibm.com>
---
 drivers/infiniband/core/umem.c                | 26 ++++++++++++++++++++------
 drivers/infiniband/hw/bnxt_re/ib_verbs.c      | 10 +++++-----
 drivers/infiniband/hw/cxgb3/iwch_provider.c   |  3 ++-
 drivers/infiniband/hw/cxgb4/mem.c             |  3 ++-
 drivers/infiniband/hw/hns/hns_roce_cq.c       |  2 +-
 drivers/infiniband/hw/hns/hns_roce_db.c       |  2 +-
 drivers/infiniband/hw/hns/hns_roce_mr.c       |  4 ++--
 drivers/infiniband/hw/hns/hns_roce_qp.c       |  2 +-
 drivers/infiniband/hw/hns/hns_roce_srq.c      |  2 +-
 drivers/infiniband/hw/i40iw/i40iw_verbs.c     |  2 +-
 drivers/infiniband/hw/mlx4/cq.c               |  2 +-
 drivers/infiniband/hw/mlx4/doorbell.c         |  2 +-
 drivers/infiniband/hw/mlx4/mr.c               |  2 +-
 drivers/infiniband/hw/mlx4/qp.c               |  2 +-
 drivers/infiniband/hw/mlx4/srq.c              |  2 +-
 drivers/infiniband/hw/mlx5/cq.c               |  4 ++--
 drivers/infiniband/hw/mlx5/devx.c             |  2 +-
 drivers/infiniband/hw/mlx5/doorbell.c         |  2 +-
 drivers/infiniband/hw/mlx5/mr.c               | 15 ++++++++-------
 drivers/infiniband/hw/mlx5/odp.c              |  5 +++--
 drivers/infiniband/hw/mlx5/qp.c               |  4 ++--
 drivers/infiniband/hw/mlx5/srq.c              |  2 +-
 drivers/infiniband/hw/mthca/mthca_provider.c  |  2 +-
 drivers/infiniband/hw/nes/nes_verbs.c         |  3 ++-
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.c   |  3 ++-
 drivers/infiniband/hw/qedr/verbs.c            |  8 +++++---
 drivers/infiniband/hw/vmw_pvrdma/pvrdma_cq.c  |  2 +-
 drivers/infiniband/hw/vmw_pvrdma/pvrdma_mr.c  |  2 +-
 drivers/infiniband/hw/vmw_pvrdma/pvrdma_qp.c  |  5 +++--
 drivers/infiniband/hw/vmw_pvrdma/pvrdma_srq.c |  2 +-
 drivers/infiniband/sw/rdmavt/mr.c             |  2 +-
 drivers/infiniband/sw/rxe/rxe_mr.c            |  3 ++-
 include/rdma/ib_umem.h                        |  3 ++-
 33 files changed, 80 insertions(+), 55 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index c6144df..9646cee 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -71,15 +71,21 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
  *
  * If access flags indicate ODP memory, avoid pinning. Instead, stores
  * the mm for future page fault handling in conjunction with MMU notifiers.
+ * If the process doing the pinning is the same as the process that owns
+ * the memory being pinned, 'owner' should be NULL. Otherwise, 'owner' should
+ * be the process ID of the owning process. The process ID must be in the
+ * same PID namespace as the calling userspace context.
  *
- * @context: userspace context to pin memory for
+ * @context: userspace context that is pinning the memory
  * @addr: userspace virtual address to start at
  * @size: length of region to pin
  * @access: IB_ACCESS_xxx flags for memory being pinned
  * @dmasync: flush in-flight DMA when the memory region is written
+ * @owner: the ID of the process that owns the memory being pinned
  */
 struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
-			    size_t size, int access, int dmasync)
+			    size_t size, int access, int dmasync,
+			    struct pid *owner)
 {
 	struct ib_umem *umem;
 	struct page **page_list;
@@ -94,6 +100,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	unsigned long dma_attrs = 0;
 	struct scatterlist *sg, *sg_list_start;
 	unsigned int gup_flags = FOLL_WRITE;
+	struct task_struct *owner_task = current;
 
 	if (dmasync)
 		dma_attrs |= DMA_ATTR_WRITE_BARRIER;
@@ -120,12 +127,18 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 			return ERR_PTR(-ENOMEM);
 	}
 
+	if (owner) {
+		rcu_read_lock();
+		owner_task = pid_task(owner, PIDTYPE_PID);
+		rcu_read_unlock();
+	}
+
 	umem->context    = context;
 	umem->length     = size;
 	umem->address    = addr;
 	umem->page_shift = PAGE_SHIFT;
 	umem->writable   = ib_access_writable(access);
-	umem->owning_mm = mm = current->mm;
+	umem->owning_mm = mm = owner_task->mm;
 	mmgrab(mm);
 
 	if (access & IB_ACCESS_ON_DEMAND) {
@@ -183,10 +196,11 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 
 	while (npages) {
 		down_read(&mm->mmap_sem);
-		ret = get_user_pages_longterm(cur_base,
+		ret = get_user_pages_remote_longterm(owner_task,
+				     mm, cur_base,
 				     min_t(unsigned long, npages,
-					   PAGE_SIZE / sizeof (struct page *)),
-				     gup_flags, page_list, vma_list);
+				     PAGE_SIZE / sizeof(struct page *)),
+				     gup_flags, page_list, vma_list, NULL);
 		if (ret < 0) {
 			up_read(&mm->mmap_sem);
 			goto umem_release;
diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.c b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
index 0828f27..96eca44 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.c
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
@@ -896,7 +896,7 @@ static int bnxt_re_init_user_qp(struct bnxt_re_dev *rdev, struct bnxt_re_pd *pd,
 		bytes += (qplib_qp->sq.max_wqe * sizeof(struct sq_psn_search));
 	bytes = PAGE_ALIGN(bytes);
 	umem = ib_umem_get(context, ureq.qpsva, bytes,
-			   IB_ACCESS_LOCAL_WRITE, 1);
+			   IB_ACCESS_LOCAL_WRITE, 1, NULL);
 	if (IS_ERR(umem))
 		return PTR_ERR(umem);
 
@@ -909,7 +909,7 @@ static int bnxt_re_init_user_qp(struct bnxt_re_dev *rdev, struct bnxt_re_pd *pd,
 		bytes = (qplib_qp->rq.max_wqe * BNXT_QPLIB_MAX_RQE_ENTRY_SIZE);
 		bytes = PAGE_ALIGN(bytes);
 		umem = ib_umem_get(context, ureq.qprva, bytes,
-				   IB_ACCESS_LOCAL_WRITE, 1);
+				   IB_ACCESS_LOCAL_WRITE, 1, NULL);
 		if (IS_ERR(umem))
 			goto rqfail;
 		qp->rumem = umem;
@@ -1371,7 +1371,7 @@ static int bnxt_re_init_user_srq(struct bnxt_re_dev *rdev,
 	bytes = (qplib_srq->max_wqe * BNXT_QPLIB_MAX_RQE_ENTRY_SIZE);
 	bytes = PAGE_ALIGN(bytes);
 	umem = ib_umem_get(context, ureq.srqva, bytes,
-			   IB_ACCESS_LOCAL_WRITE, 1);
+			   IB_ACCESS_LOCAL_WRITE, 1, NULL);
 	if (IS_ERR(umem))
 		return PTR_ERR(umem);
 
@@ -2624,7 +2624,7 @@ struct ib_cq *bnxt_re_create_cq(struct ib_device *ibdev,
 
 		cq->umem = ib_umem_get(context, req.cq_va,
 				       entries * sizeof(struct cq_base),
-				       IB_ACCESS_LOCAL_WRITE, 1);
+				       IB_ACCESS_LOCAL_WRITE, 1, NULL);
 		if (IS_ERR(cq->umem)) {
 			rc = PTR_ERR(cq->umem);
 			goto fail;
@@ -3591,7 +3591,7 @@ struct ib_mr *bnxt_re_reg_user_mr(struct ib_pd *ib_pd, u64 start, u64 length,
 	mr->ib_mr.rkey = mr->qplib_mr.rkey;
 
 	umem = ib_umem_get(ib_pd->uobject->context, start, length,
-			   mr_access_flags, 0);
+			   mr_access_flags, 0, NULL);
 	if (IS_ERR(umem)) {
 		dev_err(rdev_to_dev(rdev), "Failed to get umem");
 		rc = -EFAULT;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infiniband/hw/cxgb3/iwch_provider.c
index 54d8b38..fd94576 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -541,7 +541,8 @@ static struct ib_mr *iwch_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 
 	mhp->rhp = rhp;
 
-	mhp->umem = ib_umem_get(pd->uobject->context, start, length, acc, 0);
+	mhp->umem = ib_umem_get(pd->uobject->context, start, length, acc, 0,
+				owner);
 	if (IS_ERR(mhp->umem)) {
 		err = PTR_ERR(mhp->umem);
 		kfree(mhp);
diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index ec9b0b4..fa3ebbc 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -538,7 +538,8 @@ struct ib_mr *c4iw_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 
 	mhp->rhp = rhp;
 
-	mhp->umem = ib_umem_get(pd->uobject->context, start, length, acc, 0);
+	mhp->umem = ib_umem_get(pd->uobject->context, start, length, acc, 0,
+				owner);
 	if (IS_ERR(mhp->umem))
 		goto err_free_skb;
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_cq.c b/drivers/infiniband/hw/hns/hns_roce_cq.c
index 3a485f5..6fc6f6a 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cq.c
+++ b/drivers/infiniband/hw/hns/hns_roce_cq.c
@@ -224,7 +224,7 @@ static int hns_roce_ib_get_cq_umem(struct hns_roce_dev *hr_dev,
 	u32 npages;
 
 	*umem = ib_umem_get(context, buf_addr, cqe * hr_dev->caps.cq_entry_sz,
-			    IB_ACCESS_LOCAL_WRITE, 1);
+			    IB_ACCESS_LOCAL_WRITE, 1, NULL);
 	if (IS_ERR(*umem))
 		return PTR_ERR(*umem);
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_db.c b/drivers/infiniband/hw/hns/hns_roce_db.c
index e2f93c1..e125502 100644
--- a/drivers/infiniband/hw/hns/hns_roce_db.c
+++ b/drivers/infiniband/hw/hns/hns_roce_db.c
@@ -29,7 +29,7 @@ int hns_roce_db_map_user(struct hns_roce_ucontext *context, unsigned long virt,
 	refcount_set(&page->refcount, 1);
 	page->user_virt = (virt & PAGE_MASK);
 	page->umem = ib_umem_get(&context->ibucontext, virt & PAGE_MASK,
-				 PAGE_SIZE, 0, 0);
+				 PAGE_SIZE, 0, 0, NULL);
 	if (IS_ERR(page->umem)) {
 		ret = PTR_ERR(page->umem);
 		kfree(page);
diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c b/drivers/infiniband/hw/hns/hns_roce_mr.c
index ee5991b..4f023b8 100644
--- a/drivers/infiniband/hw/hns/hns_roce_mr.c
+++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
@@ -1111,7 +1111,7 @@ struct ib_mr *hns_roce_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 		return ERR_PTR(-ENOMEM);
 
 	mr->umem = ib_umem_get(pd->uobject->context, start, length,
-			       access_flags, 0);
+			       access_flags, 0, owner);
 	if (IS_ERR(mr->umem)) {
 		ret = PTR_ERR(mr->umem);
 		goto err_free;
@@ -1221,7 +1221,7 @@ int hns_roce_rereg_user_mr(struct ib_mr *ibmr, int flags, u64 start, u64 length,
 		ib_umem_release(mr->umem);
 
 		mr->umem = ib_umem_get(ibmr->uobject->context, start, length,
-				       mr_access_flags, 0);
+				       mr_access_flags, 0, NULL);
 		if (IS_ERR(mr->umem)) {
 			ret = PTR_ERR(mr->umem);
 			mr->umem = NULL;
diff --git a/drivers/infiniband/hw/hns/hns_roce_qp.c b/drivers/infiniband/hw/hns/hns_roce_qp.c
index 54031c5..3e1dfdf 100644
--- a/drivers/infiniband/hw/hns/hns_roce_qp.c
+++ b/drivers/infiniband/hw/hns/hns_roce_qp.c
@@ -614,7 +614,7 @@ static int hns_roce_create_qp_common(struct hns_roce_dev *hr_dev,
 
 		hr_qp->umem = ib_umem_get(ib_pd->uobject->context,
 					  ucmd.buf_addr, hr_qp->buff_size, 0,
-					  0);
+					  0, NULL);
 		if (IS_ERR(hr_qp->umem)) {
 			dev_err(dev, "ib_umem_get error for create qp\n");
 			ret = PTR_ERR(hr_qp->umem);
diff --git a/drivers/infiniband/hw/hns/hns_roce_srq.c b/drivers/infiniband/hw/hns/hns_roce_srq.c
index 960b194..bcfc092 100644
--- a/drivers/infiniband/hw/hns/hns_roce_srq.c
+++ b/drivers/infiniband/hw/hns/hns_roce_srq.c
@@ -253,7 +253,7 @@ struct ib_srq *hns_roce_create_srq(struct ib_pd *pd,
 		}
 
 		srq->umem = ib_umem_get(pd->uobject->context, ucmd.buf_addr,
-					srq_buf_size, 0, 0);
+					srq_buf_size, 0, 0, NULL);
 		if (IS_ERR(srq->umem)) {
 			ret = PTR_ERR(srq->umem);
 			goto err_srq;
diff --git a/drivers/infiniband/hw/i40iw/i40iw_verbs.c b/drivers/infiniband/hw/i40iw/i40iw_verbs.c
index fc2e6c8..e34ac01 100644
--- a/drivers/infiniband/hw/i40iw/i40iw_verbs.c
+++ b/drivers/infiniband/hw/i40iw/i40iw_verbs.c
@@ -1853,7 +1853,7 @@ static struct ib_mr *i40iw_reg_user_mr(struct ib_pd *pd,
 
 	if (length > I40IW_MAX_MR_SIZE)
 		return ERR_PTR(-EINVAL);
-	region = ib_umem_get(pd->uobject->context, start, length, acc, 0);
+	region = ib_umem_get(pd->uobject->context, start, length, acc, 0, NULL);
 	if (IS_ERR(region))
 		return (struct ib_mr *)region;
 
diff --git a/drivers/infiniband/hw/mlx4/cq.c b/drivers/infiniband/hw/mlx4/cq.c
index 4351234..a66a1ef 100644
--- a/drivers/infiniband/hw/mlx4/cq.c
+++ b/drivers/infiniband/hw/mlx4/cq.c
@@ -144,7 +144,7 @@ static int mlx4_ib_get_cq_umem(struct mlx4_ib_dev *dev, struct ib_ucontext *cont
 	int n;
 
 	*umem = ib_umem_get(context, buf_addr, cqe * cqe_size,
-			    IB_ACCESS_LOCAL_WRITE, 1);
+			    IB_ACCESS_LOCAL_WRITE, 1, NULL);
 	if (IS_ERR(*umem))
 		return PTR_ERR(*umem);
 
diff --git a/drivers/infiniband/hw/mlx4/doorbell.c b/drivers/infiniband/hw/mlx4/doorbell.c
index c517409..6abc3b7 100644
--- a/drivers/infiniband/hw/mlx4/doorbell.c
+++ b/drivers/infiniband/hw/mlx4/doorbell.c
@@ -62,7 +62,7 @@ int mlx4_ib_db_map_user(struct mlx4_ib_ucontext *context, unsigned long virt,
 	page->user_virt = (virt & PAGE_MASK);
 	page->refcnt    = 0;
 	page->umem      = ib_umem_get(&context->ibucontext, virt & PAGE_MASK,
-				      PAGE_SIZE, 0, 0);
+				      PAGE_SIZE, 0, 0, NULL);
 	if (IS_ERR(page->umem)) {
 		err = PTR_ERR(page->umem);
 		kfree(page);
diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
index 76fa83c..4a474698 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -398,7 +398,7 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_ucontext *context, u64 start,
 		up_read(&current->mm->mmap_sem);
 	}
 
-	return ib_umem_get(context, start, length, access_flags, 0);
+	return ib_umem_get(context, start, length, access_flags, 0, NULL);
 }
 
 struct ib_mr *mlx4_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 971e9a9..4a984da 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -1017,7 +1017,7 @@ static int create_qp_common(struct mlx4_ib_dev *dev, struct ib_pd *pd,
 
 		qp->umem = ib_umem_get(pd->uobject->context,
 				(src == MLX4_IB_QP_SRC) ? ucmd.qp.buf_addr :
-				ucmd.wq.buf_addr, qp->buf_size, 0, 0);
+				ucmd.wq.buf_addr, qp->buf_size, 0, 0, NULL);
 		if (IS_ERR(qp->umem)) {
 			err = PTR_ERR(qp->umem);
 			goto err;
diff --git a/drivers/infiniband/hw/mlx4/srq.c b/drivers/infiniband/hw/mlx4/srq.c
index 4456f1b..2919d62 100644
--- a/drivers/infiniband/hw/mlx4/srq.c
+++ b/drivers/infiniband/hw/mlx4/srq.c
@@ -114,7 +114,7 @@ struct ib_srq *mlx4_ib_create_srq(struct ib_pd *pd,
 		}
 
 		srq->umem = ib_umem_get(pd->uobject->context, ucmd.buf_addr,
-					buf_size, 0, 0);
+					buf_size, 0, 0, NULL);
 		if (IS_ERR(srq->umem)) {
 			err = PTR_ERR(srq->umem);
 			goto err_srq;
diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index 90f1b0b..847f4ab 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -709,7 +709,7 @@ static int create_cq_user(struct mlx5_ib_dev *dev, struct ib_udata *udata,
 
 	cq->buf.umem = ib_umem_get(context, ucmd.buf_addr,
 				   entries * ucmd.cqe_size,
-				   IB_ACCESS_LOCAL_WRITE, 1);
+				   IB_ACCESS_LOCAL_WRITE, 1, NULL);
 	if (IS_ERR(cq->buf.umem)) {
 		err = PTR_ERR(cq->buf.umem);
 		return err;
@@ -1126,7 +1126,7 @@ static int resize_user(struct mlx5_ib_dev *dev, struct mlx5_ib_cq *cq,
 
 	umem = ib_umem_get(context, ucmd.buf_addr,
 			   (size_t)ucmd.cqe_size * entries,
-			   IB_ACCESS_LOCAL_WRITE, 1);
+			   IB_ACCESS_LOCAL_WRITE, 1, NULL);
 	if (IS_ERR(umem)) {
 		err = PTR_ERR(umem);
 		return err;
diff --git a/drivers/infiniband/hw/mlx5/devx.c b/drivers/infiniband/hw/mlx5/devx.c
index 5a588f3..7dafdc3 100644
--- a/drivers/infiniband/hw/mlx5/devx.c
+++ b/drivers/infiniband/hw/mlx5/devx.c
@@ -1195,7 +1195,7 @@ static int devx_umem_get(struct mlx5_ib_dev *dev, struct ib_ucontext *ucontext,
 	if (err)
 		return err;
 
-	obj->umem = ib_umem_get(ucontext, addr, size, access, 0);
+	obj->umem = ib_umem_get(ucontext, addr, size, access, 0, NULL);
 	if (IS_ERR(obj->umem))
 		return PTR_ERR(obj->umem);
 
diff --git a/drivers/infiniband/hw/mlx5/doorbell.c b/drivers/infiniband/hw/mlx5/doorbell.c
index a0e4e6d..8527574 100644
--- a/drivers/infiniband/hw/mlx5/doorbell.c
+++ b/drivers/infiniband/hw/mlx5/doorbell.c
@@ -64,7 +64,7 @@ int mlx5_ib_db_map_user(struct mlx5_ib_ucontext *context, unsigned long virt,
 	page->user_virt = (virt & PAGE_MASK);
 	page->refcnt    = 0;
 	page->umem      = ib_umem_get(&context->ibucontext, virt & PAGE_MASK,
-				      PAGE_SIZE, 0, 0);
+				      PAGE_SIZE, 0, 0, NULL);
 	if (IS_ERR(page->umem)) {
 		err = PTR_ERR(page->umem);
 		kfree(page);
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 6add486..8eb606a 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -849,7 +849,7 @@ static int mr_cache_max_order(struct mlx5_ib_dev *dev)
 static int mr_umem_get(struct ib_pd *pd, u64 start, u64 length,
 		       int access_flags, struct ib_umem **umem,
 		       int *npages, int *page_shift, int *ncont,
-		       int *order)
+		       int *order, struct pid *owner)
 {
 	struct mlx5_ib_dev *dev = to_mdev(pd->device);
 	struct ib_umem *u;
@@ -857,7 +857,8 @@ static int mr_umem_get(struct ib_pd *pd, u64 start, u64 length,
 
 	*umem = NULL;
 
-	u = ib_umem_get(pd->uobject->context, start, length, access_flags, 0);
+	u = ib_umem_get(pd->uobject->context, start, length, access_flags, 0,
+			owner);
 	err = PTR_ERR_OR_ZERO(u);
 	if (err) {
 		mlx5_ib_dbg(dev, "umem get failed (%d)\n", err);
@@ -1328,8 +1329,8 @@ struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 	if (!IS_ENABLED(CONFIG_INFINIBAND_USER_MEM))
 		return ERR_PTR(-EOPNOTSUPP);
 
-	mlx5_ib_dbg(dev, "start 0x%llx, virt_addr 0x%llx, length 0x%llx, access_flags 0x%x\n",
-		    start, virt_addr, length, access_flags);
+	mlx5_ib_dbg(dev, "start=0x%llx, virt_addr=0x%llx, length=0x%llx, access_flags=0x%x owner=%i\n",
+			start, virt_addr, length, access_flags, pid_vnr(owner));
 
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
 	if (!start && length == U64_MAX) {
@@ -1337,7 +1338,7 @@ struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 		    !(dev->odp_caps.general_caps & IB_ODP_SUPPORT_IMPLICIT))
 			return ERR_PTR(-EINVAL);
 
-		mr = mlx5_ib_alloc_implicit_mr(to_mpd(pd), access_flags);
+		mr = mlx5_ib_alloc_implicit_mr(to_mpd(pd), access_flags, owner);
 		if (IS_ERR(mr))
 			return ERR_CAST(mr);
 		return &mr->ibmr;
@@ -1345,7 +1346,7 @@ struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 #endif
 
 	err = mr_umem_get(pd, start, length, access_flags, &umem, &npages,
-			   &page_shift, &ncont, &order);
+			   &page_shift, &ncont, &order, owner);
 
 	if (err < 0)
 		return ERR_PTR(err);
@@ -1496,7 +1497,7 @@ int mlx5_ib_rereg_user_mr(struct ib_mr *ib_mr, int flags, u64 start,
 		ib_umem_release(mr->umem);
 		mr->umem = NULL;
 		err = mr_umem_get(pd, addr, len, access_flags, &mr->umem,
-				  &npages, &page_shift, &ncont, &order);
+				  &npages, &page_shift, &ncont, &order, NULL);
 		if (err)
 			goto err;
 	}
diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index 01e0f62..c317e18 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -492,13 +492,14 @@ static struct ib_umem_odp *implicit_mr_get_data(struct mlx5_ib_mr *mr,
 }
 
 struct mlx5_ib_mr *mlx5_ib_alloc_implicit_mr(struct mlx5_ib_pd *pd,
-					     int access_flags)
+					     int access_flags,
+					     struct pid *owner)
 {
 	struct ib_ucontext *ctx = pd->ibpd.uobject->context;
 	struct mlx5_ib_mr *imr;
 	struct ib_umem *umem;
 
-	umem = ib_umem_get(ctx, 0, 0, IB_ACCESS_ON_DEMAND, 0);
+	umem = ib_umem_get(ctx, 0, 0, IB_ACCESS_ON_DEMAND, 0, owner);
 	if (IS_ERR(umem))
 		return ERR_CAST(umem);
 
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index dd2ae64..f2b72e7 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -654,7 +654,7 @@ static int mlx5_ib_umem_get(struct mlx5_ib_dev *dev,
 {
 	int err;
 
-	*umem = ib_umem_get(pd->uobject->context, addr, size, 0, 0);
+	*umem = ib_umem_get(pd->uobject->context, addr, size, 0, 0, NULL);
 	if (IS_ERR(*umem)) {
 		mlx5_ib_dbg(dev, "umem_get failed\n");
 		return PTR_ERR(*umem);
@@ -710,7 +710,7 @@ static int create_user_rq(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 
 	context = to_mucontext(pd->uobject->context);
 	rwq->umem = ib_umem_get(pd->uobject->context, ucmd->buf_addr,
-			       rwq->buf_size, 0, 0);
+			       rwq->buf_size, 0, 0, NULL);
 	if (IS_ERR(rwq->umem)) {
 		mlx5_ib_dbg(dev, "umem_get failed\n");
 		err = PTR_ERR(rwq->umem);
diff --git a/drivers/infiniband/hw/mlx5/srq.c b/drivers/infiniband/hw/mlx5/srq.c
index 4e8d180..d51f6f3 100644
--- a/drivers/infiniband/hw/mlx5/srq.c
+++ b/drivers/infiniband/hw/mlx5/srq.c
@@ -80,7 +80,7 @@ static int create_srq_user(struct ib_pd *pd, struct mlx5_ib_srq *srq,
 	srq->wq_sig = !!(ucmd.flags & MLX5_SRQ_FLAG_SIGNATURE);
 
 	srq->umem = ib_umem_get(pd->uobject->context, ucmd.buf_addr, buf_size,
-				0, 0);
+				0, 0, NULL);
 	if (IS_ERR(srq->umem)) {
 		mlx5_ib_dbg(dev, "failed umem get, size %d\n", buf_size);
 		err = PTR_ERR(srq->umem);
diff --git a/drivers/infiniband/hw/mthca/mthca_provider.c b/drivers/infiniband/hw/mthca/mthca_provider.c
index 77e678e..5cc9f3c 100644
--- a/drivers/infiniband/hw/mthca/mthca_provider.c
+++ b/drivers/infiniband/hw/mthca/mthca_provider.c
@@ -933,7 +933,7 @@ static struct ib_mr *mthca_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 		return ERR_PTR(-ENOMEM);
 
 	mr->umem = ib_umem_get(pd->uobject->context, start, length, acc,
-			       ucmd.mr_attrs & MTHCA_MR_DMASYNC);
+			       ucmd.mr_attrs & MTHCA_MR_DMASYNC, owner);
 
 	if (IS_ERR(mr->umem)) {
 		err = PTR_ERR(mr->umem);
diff --git a/drivers/infiniband/hw/nes/nes_verbs.c b/drivers/infiniband/hw/nes/nes_verbs.c
index e07cb02..0e3295e 100644
--- a/drivers/infiniband/hw/nes/nes_verbs.c
+++ b/drivers/infiniband/hw/nes/nes_verbs.c
@@ -2134,7 +2134,8 @@ static struct ib_mr *nes_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 	u8 stag_key;
 	int first_page = 1;
 
-	region = ib_umem_get(pd->uobject->context, start, length, acc, 0);
+	region = ib_umem_get(pd->uobject->context, start, length, acc, 0,
+			owner);
 	if (IS_ERR(region)) {
 		return (struct ib_mr *)region;
 	}
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
index 01d076a..e817d45 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
@@ -917,7 +917,8 @@ struct ib_mr *ocrdma_reg_user_mr(struct ib_pd *ibpd, u64 start, u64 len,
 	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
 	if (!mr)
 		return ERR_PTR(status);
-	mr->umem = ib_umem_get(ibpd->uobject->context, start, len, acc, 0);
+	mr->umem = ib_umem_get(ibpd->uobject->context, start, len, acc, 0,
+			owner);
 	if (IS_ERR(mr->umem)) {
 		status = -EFAULT;
 		goto umem_err;
diff --git a/drivers/infiniband/hw/qedr/verbs.c b/drivers/infiniband/hw/qedr/verbs.c
index e1ccf32..15b87d0 100644
--- a/drivers/infiniband/hw/qedr/verbs.c
+++ b/drivers/infiniband/hw/qedr/verbs.c
@@ -748,7 +748,8 @@ static inline int qedr_init_user_queue(struct ib_ucontext *ib_ctx,
 
 	q->buf_addr = buf_addr;
 	q->buf_len = buf_len;
-	q->umem = ib_umem_get(ib_ctx, q->buf_addr, q->buf_len, access, dmasync);
+	q->umem = ib_umem_get(ib_ctx, q->buf_addr, q->buf_len, access, dmasync,
+			NULL);
 	if (IS_ERR(q->umem)) {
 		DP_ERR(dev, "create user queue: failed ib_umem_get, got %ld\n",
 		       PTR_ERR(q->umem));
@@ -1359,7 +1360,7 @@ static int qedr_init_srq_user_params(struct ib_ucontext *ib_ctx,
 
 	srq->prod_umem = ib_umem_get(ib_ctx, ureq->prod_pair_addr,
 				     sizeof(struct rdma_srq_producers),
-				     access, dmasync);
+				     access, dmasync, NULL);
 	if (IS_ERR(srq->prod_umem)) {
 		qedr_free_pbl(srq->dev, &srq->usrq.pbl_info, srq->usrq.pbl_tbl);
 		ib_umem_release(srq->usrq.umem);
@@ -2719,7 +2720,8 @@ struct ib_mr *qedr_reg_user_mr(struct ib_pd *ibpd, u64 start, u64 len,
 
 	mr->type = QEDR_MR_USER;
 
-	mr->umem = ib_umem_get(ibpd->uobject->context, start, len, acc, 0);
+	mr->umem = ib_umem_get(ibpd->uobject->context, start, len, acc, 0,
+			NULL);
 	if (IS_ERR(mr->umem)) {
 		rc = -EFAULT;
 		goto err0;
diff --git a/drivers/infiniband/hw/vmw_pvrdma/pvrdma_cq.c b/drivers/infiniband/hw/vmw_pvrdma/pvrdma_cq.c
index 0f004c7..4ade730 100644
--- a/drivers/infiniband/hw/vmw_pvrdma/pvrdma_cq.c
+++ b/drivers/infiniband/hw/vmw_pvrdma/pvrdma_cq.c
@@ -142,7 +142,7 @@ struct ib_cq *pvrdma_create_cq(struct ib_device *ibdev,
 		}
 
 		cq->umem = ib_umem_get(context, ucmd.buf_addr, ucmd.buf_size,
-				       IB_ACCESS_LOCAL_WRITE, 1);
+				       IB_ACCESS_LOCAL_WRITE, 1, NULL);
 		if (IS_ERR(cq->umem)) {
 			ret = PTR_ERR(cq->umem);
 			goto err_cq;
diff --git a/drivers/infiniband/hw/vmw_pvrdma/pvrdma_mr.c b/drivers/infiniband/hw/vmw_pvrdma/pvrdma_mr.c
index fa96fa4..f5466ad 100644
--- a/drivers/infiniband/hw/vmw_pvrdma/pvrdma_mr.c
+++ b/drivers/infiniband/hw/vmw_pvrdma/pvrdma_mr.c
@@ -127,7 +127,7 @@ struct ib_mr *pvrdma_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 	}
 
 	umem = ib_umem_get(pd->uobject->context, start,
-			   length, access_flags, 0);
+			   length, access_flags, 0, NULL);
 	if (IS_ERR(umem)) {
 		dev_warn(&dev->pdev->dev,
 			 "could not get umem for mem region\n");
diff --git a/drivers/infiniband/hw/vmw_pvrdma/pvrdma_qp.c b/drivers/infiniband/hw/vmw_pvrdma/pvrdma_qp.c
index 3acf74c..ae8c826 100644
--- a/drivers/infiniband/hw/vmw_pvrdma/pvrdma_qp.c
+++ b/drivers/infiniband/hw/vmw_pvrdma/pvrdma_qp.c
@@ -264,7 +264,8 @@ struct ib_qp *pvrdma_create_qp(struct ib_pd *pd,
 				/* set qp->sq.wqe_cnt, shift, buf_size.. */
 				qp->rumem = ib_umem_get(pd->uobject->context,
 							ucmd.rbuf_addr,
-							ucmd.rbuf_size, 0, 0);
+							ucmd.rbuf_size, 0, 0,
+							NULL);
 				if (IS_ERR(qp->rumem)) {
 					ret = PTR_ERR(qp->rumem);
 					goto err_qp;
@@ -277,7 +278,7 @@ struct ib_qp *pvrdma_create_qp(struct ib_pd *pd,
 
 			qp->sumem = ib_umem_get(pd->uobject->context,
 						ucmd.sbuf_addr,
-						ucmd.sbuf_size, 0, 0);
+						ucmd.sbuf_size, 0, 0, NULL);
 			if (IS_ERR(qp->sumem)) {
 				if (!is_srq)
 					ib_umem_release(qp->rumem);
diff --git a/drivers/infiniband/hw/vmw_pvrdma/pvrdma_srq.c b/drivers/infiniband/hw/vmw_pvrdma/pvrdma_srq.c
index 06ba7c7..d235fcd 100644
--- a/drivers/infiniband/hw/vmw_pvrdma/pvrdma_srq.c
+++ b/drivers/infiniband/hw/vmw_pvrdma/pvrdma_srq.c
@@ -155,7 +155,7 @@ struct ib_srq *pvrdma_create_srq(struct ib_pd *pd,
 
 	srq->umem = ib_umem_get(pd->uobject->context,
 				ucmd.buf_addr,
-				ucmd.buf_size, 0, 0);
+				ucmd.buf_size, 0, 0, NULL);
 	if (IS_ERR(srq->umem)) {
 		ret = PTR_ERR(srq->umem);
 		goto err_srq;
diff --git a/drivers/infiniband/sw/rdmavt/mr.c b/drivers/infiniband/sw/rdmavt/mr.c
index 2bc95c9..f4cdcfe 100644
--- a/drivers/infiniband/sw/rdmavt/mr.c
+++ b/drivers/infiniband/sw/rdmavt/mr.c
@@ -390,7 +390,7 @@ struct ib_mr *rvt_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 		return ERR_PTR(-EINVAL);
 
 	umem = ib_umem_get(pd->uobject->context, start, length,
-			   mr_access_flags, 0);
+			   mr_access_flags, 0, NULL);
 	if (IS_ERR(umem))
 		return (void *)umem;
 
diff --git a/drivers/infiniband/sw/rxe/rxe_mr.c b/drivers/infiniband/sw/rxe/rxe_mr.c
index 9d3916b..f91346a 100644
--- a/drivers/infiniband/sw/rxe/rxe_mr.c
+++ b/drivers/infiniband/sw/rxe/rxe_mr.c
@@ -171,7 +171,8 @@ int rxe_mem_init_user(struct rxe_pd *pd, u64 start,
 	void			*vaddr;
 	int err;
 
-	umem = ib_umem_get(pd->ibpd.uobject->context, start, length, access, 0);
+	umem = ib_umem_get(pd->ibpd.uobject->context, start, length,
+		access, 0, NULL);
 	if (IS_ERR(umem)) {
 		pr_warn("err %d from rxe_umem_get\n",
 			(int)PTR_ERR(umem));
diff --git a/include/rdma/ib_umem.h b/include/rdma/ib_umem.h
index 5d3755e..4951dcb 100644
--- a/include/rdma/ib_umem.h
+++ b/include/rdma/ib_umem.h
@@ -81,7 +81,8 @@ static inline size_t ib_umem_num_pages(struct ib_umem *umem)
 #ifdef CONFIG_INFINIBAND_USER_MEM
 
 struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
-			    size_t size, int access, int dmasync);
+			    size_t size, int access, int dmasync,
+			    struct pid *owner);
 void ib_umem_release(struct ib_umem *umem);
 int ib_umem_page_count(struct ib_umem *umem);
 int ib_umem_copy_from(void *dst, struct ib_umem *umem, size_t offset,
-- 
2.7.4

