Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CE6EC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:58:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD80F20815
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:58:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD80F20815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92FDB8E0005; Tue, 29 Jan 2019 11:58:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B8C78E0002; Tue, 29 Jan 2019 11:58:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 781D58E0005; Tue, 29 Jan 2019 11:58:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4415A8E0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:58:51 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id j5so25079710qtk.11
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:58:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=w0Xi1J3ywU2BSwQE03vBO6SwXMaqgB0FMxpXivRfQnE=;
        b=IN5mv2qheX1xDpUkVDwzawP23LsS1RW5wtixuGVXWJXwUADVXm2zeXdw2BvqxGNznf
         OFXfNdUUr3m9F+t8ktMUdkyRADgAel9FP521YK66aWNHX5NO6gfo4Zic6d1tB7do4E5C
         5JC+p0nyKAEqKNh55bnNe6QvGiJ+ayR+9oXForaSMRzpe0v/NQX6WasNizZkI+q7UW7l
         Ag0EMIHZVS7Gp9+3bvWH6gMzjj6kB/hcpixadmESCbHDrMyyfuzUM84yNZyOn3N5xV8L
         zIRtL/iYZcz+NTbLhWqoH4aw4/tW8MyY1wpG8tvElQMFEBkUqMOdvaNZmjbcv+tAcVO0
         kXQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdSvA4B2OpEFsoz/OD5DKHGZLCFP//jx4NzEgmWDJvF2rcQcgDa
	V5ENnEbFtYjlCMji2xugTeLAeO42iyfsEOZoW7cA7bIhMM8wghOmHYpwu23zucLYGnZw48kuseJ
	cZQVMdsnfjBWghOOqxPOUSnMsqDOzQfnXpWliOz+dRUFnJ9nxMTZC2GEc3wzlckprTw==
X-Received: by 2002:a37:491:: with SMTP id 139mr24657599qke.182.1548781130961;
        Tue, 29 Jan 2019 08:58:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7N+9jkCFyGcGoic+VlFBb4P2K0V5HlnnKKFx2F6Y5RoYIkuB+NW+Fw0evJVszl4sOr96AP
X-Received: by 2002:a37:491:: with SMTP id 139mr24657529qke.182.1548781129769;
        Tue, 29 Jan 2019 08:58:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548781129; cv=none;
        d=google.com; s=arc-20160816;
        b=M78wiJ92GR6NFGabzWiE6DxlkQxrFKYg06Hyjd/v6Jtc16sjQrSwYjKMwgjAmZsu5j
         N/WSnOoZxtAaNzFMmri7XXpO0rupB6cnu37VzRHtEJu7HTpE8nPGmWPkNMEgfR+6Rre/
         4cZMBZVH5WaPyliON6/AwcgomJVtWeYRkvLyttOucNkOT7Y0Yp/ksa3kG0VgAU+6rZvR
         Z10R7dt/SNOPA6zGs3HSN81likRKwH8b1V0dLqHS9mqmvVI8Oraz9hIcX0JZFBiduJSE
         ZsZ2Y/JKs14qvjsVr9oQfz5A4tFoRaiMDYgJuZh8POftgnw7DtuFza/mTkvf5+zM561O
         yitQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=w0Xi1J3ywU2BSwQE03vBO6SwXMaqgB0FMxpXivRfQnE=;
        b=wYdaK/nknXqsbcilpOVrBTGdHBCgvg408uCjRZK2DBzsOwprtgi9NqEIDmmNRpMg4R
         KMFKRMDk3Huqtzz1rCKRo+xpl7T0Gfow1i8nKZdcAyEOZfiSx/DnEHlisXfWgWIYWyio
         yintxN/OZFtUBfaqKd6670LjdM5hh9taoR0ouJE6sEjLqbR0O7i//d4CiCKOF8k2Be0T
         UP27olO4QsFEFGoMzDQbNtmoLsGfv45QZfmLHQD1vNax1ywD/jRUbyXz2pRwI0g0SmP8
         SLc2bKzejTDHiF6oKdVjbdb4bd3KAspy6Avf87XseOes7TsrHstNAtQfgX+orctLZb0Q
         YdVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 36si16126qta.249.2019.01.29.08.58.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:58:49 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B46F181256;
	Tue, 29 Jan 2019 16:58:48 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1CE295C6D9;
	Tue, 29 Jan 2019 16:58:47 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-rdma@vger.kernel.org,
	Jason Gunthorpe <jgg@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>
Subject: [PATCH 1/1] RDMA/odp: convert to use HMM for ODP
Date: Tue, 29 Jan 2019 11:58:39 -0500
Message-Id: <20190129165839.4127-2-jglisse@redhat.com>
In-Reply-To: <20190129165839.4127-1-jglisse@redhat.com>
References: <20190129165839.4127-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 29 Jan 2019 16:58:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Convert ODP to use HMM so that we can build on common infrastructure
for different class of devices that want to mirror a process address
space into a device. There is no functional changes.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: linux-rdma@vger.kernel.org
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Leon Romanovsky <leonro@mellanox.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Artemy Kovalyov <artemyko@mellanox.com>
Cc: Moni Shoua <monis@mellanox.com>
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
Cc: Kaike Wan <kaike.wan@intel.com>
Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
---
 drivers/infiniband/core/umem_odp.c | 483 ++++++++---------------------
 drivers/infiniband/hw/mlx5/mem.c   |  20 +-
 drivers/infiniband/hw/mlx5/mr.c    |   2 +-
 drivers/infiniband/hw/mlx5/odp.c   |  95 +++---
 include/rdma/ib_umem_odp.h         |  54 +---
 5 files changed, 202 insertions(+), 452 deletions(-)

diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index a4ec43093cb3..8afa707f1d9a 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -45,6 +45,20 @@
 #include <rdma/ib_umem.h>
 #include <rdma/ib_umem_odp.h>
 
+
+static uint64_t odp_hmm_flags[HMM_PFN_FLAG_MAX] = {
+	ODP_READ_BIT,	/* HMM_PFN_VALID */
+	ODP_WRITE_BIT,	/* HMM_PFN_WRITE */
+	ODP_DEVICE_BIT,	/* HMM_PFN_DEVICE_PRIVATE */
+};
+
+static uint64_t odp_hmm_values[HMM_PFN_VALUE_MAX] = {
+	-1UL,	/* HMM_PFN_ERROR */
+	0UL,	/* HMM_PFN_NONE */
+	-2UL,	/* HMM_PFN_SPECIAL */
+};
+
+
 /*
  * The ib_umem list keeps track of memory regions for which the HW
  * device request to receive notification when the related memory
@@ -77,57 +91,25 @@ static u64 node_last(struct umem_odp_node *n)
 INTERVAL_TREE_DEFINE(struct umem_odp_node, rb, u64, __subtree_last,
 		     node_start, node_last, static, rbt_ib_umem)
 
-static void ib_umem_notifier_start_account(struct ib_umem_odp *umem_odp)
-{
-	mutex_lock(&umem_odp->umem_mutex);
-	if (umem_odp->notifiers_count++ == 0)
-		/*
-		 * Initialize the completion object for waiting on
-		 * notifiers. Since notifier_count is zero, no one should be
-		 * waiting right now.
-		 */
-		reinit_completion(&umem_odp->notifier_completion);
-	mutex_unlock(&umem_odp->umem_mutex);
-}
-
-static void ib_umem_notifier_end_account(struct ib_umem_odp *umem_odp)
-{
-	mutex_lock(&umem_odp->umem_mutex);
-	/*
-	 * This sequence increase will notify the QP page fault that the page
-	 * that is going to be mapped in the spte could have been freed.
-	 */
-	++umem_odp->notifiers_seq;
-	if (--umem_odp->notifiers_count == 0)
-		complete_all(&umem_odp->notifier_completion);
-	mutex_unlock(&umem_odp->umem_mutex);
-}
-
 static int ib_umem_notifier_release_trampoline(struct ib_umem_odp *umem_odp,
 					       u64 start, u64 end, void *cookie)
 {
 	struct ib_umem *umem = &umem_odp->umem;
 
-	/*
-	 * Increase the number of notifiers running, to
-	 * prevent any further fault handling on this MR.
-	 */
-	ib_umem_notifier_start_account(umem_odp);
 	umem_odp->dying = 1;
 	/* Make sure that the fact the umem is dying is out before we release
 	 * all pending page faults. */
 	smp_wmb();
-	complete_all(&umem_odp->notifier_completion);
 	umem->context->invalidate_range(umem_odp, ib_umem_start(umem),
 					ib_umem_end(umem));
 	return 0;
 }
 
-static void ib_umem_notifier_release(struct mmu_notifier *mn,
-				     struct mm_struct *mm)
+static void ib_umem_notifier_release(struct hmm_mirror *mirror)
 {
-	struct ib_ucontext_per_mm *per_mm =
-		container_of(mn, struct ib_ucontext_per_mm, mn);
+	struct ib_ucontext_per_mm *per_mm;
+
+	per_mm = container_of(mirror, struct ib_ucontext_per_mm, mirror);
 
 	down_read(&per_mm->umem_rwsem);
 	if (per_mm->active)
@@ -135,21 +117,24 @@ static void ib_umem_notifier_release(struct mmu_notifier *mn,
 			&per_mm->umem_tree, 0, ULLONG_MAX,
 			ib_umem_notifier_release_trampoline, true, NULL);
 	up_read(&per_mm->umem_rwsem);
+
+	per_mm->mm = NULL;
 }
 
-static int invalidate_range_start_trampoline(struct ib_umem_odp *item,
-					     u64 start, u64 end, void *cookie)
+static int invalidate_range_trampoline(struct ib_umem_odp *item,
+				       u64 start, u64 end, void *cookie)
 {
-	ib_umem_notifier_start_account(item);
 	item->umem.context->invalidate_range(item, start, end);
 	return 0;
 }
 
-static int ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
-				const struct mmu_notifier_range *range)
+static int ib_sync_cpu_device_pagetables(struct hmm_mirror *mirror,
+			    const struct hmm_update *range)
 {
-	struct ib_ucontext_per_mm *per_mm =
-		container_of(mn, struct ib_ucontext_per_mm, mn);
+	struct ib_ucontext_per_mm *per_mm;
+	int ret;
+
+	per_mm = container_of(mirror, struct ib_ucontext_per_mm, mirror);
 
 	if (range->blockable)
 		down_read(&per_mm->umem_rwsem);
@@ -166,38 +151,17 @@ static int ib_umem_notifier_invalidate_range_start(struct mmu_notifier *mn,
 		return 0;
 	}
 
-	return rbt_ib_umem_for_each_in_range(&per_mm->umem_tree, range->start,
+	ret = rbt_ib_umem_for_each_in_range(&per_mm->umem_tree, range->start,
 					     range->end,
-					     invalidate_range_start_trampoline,
+					     invalidate_range_trampoline,
 					     range->blockable, NULL);
-}
-
-static int invalidate_range_end_trampoline(struct ib_umem_odp *item, u64 start,
-					   u64 end, void *cookie)
-{
-	ib_umem_notifier_end_account(item);
-	return 0;
-}
-
-static void ib_umem_notifier_invalidate_range_end(struct mmu_notifier *mn,
-				const struct mmu_notifier_range *range)
-{
-	struct ib_ucontext_per_mm *per_mm =
-		container_of(mn, struct ib_ucontext_per_mm, mn);
-
-	if (unlikely(!per_mm->active))
-		return;
-
-	rbt_ib_umem_for_each_in_range(&per_mm->umem_tree, range->start,
-				      range->end,
-				      invalidate_range_end_trampoline, true, NULL);
 	up_read(&per_mm->umem_rwsem);
+	return ret;
 }
 
-static const struct mmu_notifier_ops ib_umem_notifiers = {
+static const struct hmm_mirror_ops ib_umem_notifiers = {
 	.release                    = ib_umem_notifier_release,
-	.invalidate_range_start     = ib_umem_notifier_invalidate_range_start,
-	.invalidate_range_end       = ib_umem_notifier_invalidate_range_end,
+	.sync_cpu_device_pagetables = ib_sync_cpu_device_pagetables,
 };
 
 static void add_umem_to_per_mm(struct ib_umem_odp *umem_odp)
@@ -221,7 +185,6 @@ static void remove_umem_from_per_mm(struct ib_umem_odp *umem_odp)
 	if (likely(ib_umem_start(umem) != ib_umem_end(umem)))
 		rbt_ib_umem_remove(&umem_odp->interval_tree,
 				   &per_mm->umem_tree);
-	complete_all(&umem_odp->notifier_completion);
 
 	up_write(&per_mm->umem_rwsem);
 }
@@ -248,11 +211,13 @@ static struct ib_ucontext_per_mm *alloc_per_mm(struct ib_ucontext *ctx,
 
 	WARN_ON(mm != current->mm);
 
-	per_mm->mn.ops = &ib_umem_notifiers;
-	ret = mmu_notifier_register(&per_mm->mn, per_mm->mm);
+	per_mm->mirror.ops = &ib_umem_notifiers;
+	down_write(&mm->mmap_sem);
+	ret = hmm_mirror_register(&per_mm->mirror, per_mm->mm);
+	up_write(&mm->mmap_sem);
 	if (ret) {
 		dev_err(&ctx->device->dev,
-			"Failed to register mmu_notifier %d\n", ret);
+			"Failed to register HMM mirror %d\n", ret);
 		goto out_pid;
 	}
 
@@ -294,11 +259,6 @@ static int get_per_mm(struct ib_umem_odp *umem_odp)
 	return 0;
 }
 
-static void free_per_mm(struct rcu_head *rcu)
-{
-	kfree(container_of(rcu, struct ib_ucontext_per_mm, rcu));
-}
-
 void put_per_mm(struct ib_umem_odp *umem_odp)
 {
 	struct ib_ucontext_per_mm *per_mm = umem_odp->per_mm;
@@ -327,9 +287,10 @@ void put_per_mm(struct ib_umem_odp *umem_odp)
 	up_write(&per_mm->umem_rwsem);
 
 	WARN_ON(!RB_EMPTY_ROOT(&per_mm->umem_tree.rb_root));
-	mmu_notifier_unregister_no_release(&per_mm->mn, per_mm->mm);
+	hmm_mirror_unregister(&per_mm->mirror);
 	put_pid(per_mm->tgid);
-	mmu_notifier_call_srcu(&per_mm->rcu, free_per_mm);
+
+	kfree(per_mm);
 }
 
 struct ib_umem_odp *ib_alloc_odp_umem(struct ib_ucontext_per_mm *per_mm,
@@ -354,11 +315,9 @@ struct ib_umem_odp *ib_alloc_odp_umem(struct ib_ucontext_per_mm *per_mm,
 	odp_data->per_mm = per_mm;
 
 	mutex_init(&odp_data->umem_mutex);
-	init_completion(&odp_data->notifier_completion);
 
-	odp_data->page_list =
-		vzalloc(array_size(pages, sizeof(*odp_data->page_list)));
-	if (!odp_data->page_list) {
+	odp_data->pfns = vzalloc(array_size(pages, sizeof(*odp_data->pfns)));
+	if (!odp_data->pfns) {
 		ret = -ENOMEM;
 		goto out_odp_data;
 	}
@@ -367,7 +326,7 @@ struct ib_umem_odp *ib_alloc_odp_umem(struct ib_ucontext_per_mm *per_mm,
 		vzalloc(array_size(pages, sizeof(*odp_data->dma_list)));
 	if (!odp_data->dma_list) {
 		ret = -ENOMEM;
-		goto out_page_list;
+		goto out_pfns;
 	}
 
 	/*
@@ -381,8 +340,8 @@ struct ib_umem_odp *ib_alloc_odp_umem(struct ib_ucontext_per_mm *per_mm,
 
 	return odp_data;
 
-out_page_list:
-	vfree(odp_data->page_list);
+out_pfns:
+	vfree(odp_data->pfns);
 out_odp_data:
 	kfree(odp_data);
 	return ERR_PTR(ret);
@@ -419,13 +378,11 @@ int ib_umem_odp_get(struct ib_umem_odp *umem_odp, int access)
 
 	mutex_init(&umem_odp->umem_mutex);
 
-	init_completion(&umem_odp->notifier_completion);
-
 	if (ib_umem_num_pages(umem)) {
-		umem_odp->page_list =
-			vzalloc(array_size(sizeof(*umem_odp->page_list),
+		umem_odp->pfns =
+			vzalloc(array_size(sizeof(*umem_odp->pfns),
 					   ib_umem_num_pages(umem)));
-		if (!umem_odp->page_list)
+		if (!umem_odp->pfns)
 			return -ENOMEM;
 
 		umem_odp->dma_list =
@@ -433,7 +390,7 @@ int ib_umem_odp_get(struct ib_umem_odp *umem_odp, int access)
 					   ib_umem_num_pages(umem)));
 		if (!umem_odp->dma_list) {
 			ret_val = -ENOMEM;
-			goto out_page_list;
+			goto out_pfns;
 		}
 	}
 
@@ -446,8 +403,8 @@ int ib_umem_odp_get(struct ib_umem_odp *umem_odp, int access)
 
 out_dma_list:
 	vfree(umem_odp->dma_list);
-out_page_list:
-	vfree(umem_odp->page_list);
+out_pfns:
+	vfree(umem_odp->pfns);
 	return ret_val;
 }
 
@@ -467,291 +424,113 @@ void ib_umem_odp_release(struct ib_umem_odp *umem_odp)
 	remove_umem_from_per_mm(umem_odp);
 	put_per_mm(umem_odp);
 	vfree(umem_odp->dma_list);
-	vfree(umem_odp->page_list);
+	vfree(umem_odp->pfns);
 }
 
-/*
- * Map for DMA and insert a single page into the on-demand paging page tables.
- *
- * @umem: the umem to insert the page to.
- * @page_index: index in the umem to add the page to.
- * @page: the page struct to map and add.
- * @access_mask: access permissions needed for this page.
- * @current_seq: sequence number for synchronization with invalidations.
- *               the sequence number is taken from
- *               umem_odp->notifiers_seq.
- *
- * The function returns -EFAULT if the DMA mapping operation fails. It returns
- * -EAGAIN if a concurrent invalidation prevents us from updating the page.
+/**
+ * ib_umem_odp_map_dma_pages - Pin and DMA map userspace memory in an ODP MR.
+ * @umem_odp: the umem to map and pin
+ * @range: range of virtual address to be mapped to the device
+ * Returns: -EINVAL some invalid arguments, -EAGAIN need to try again, -ENOENT
+ *          if process is being terminated, number of pages mapped otherwise.
  *
- * The page is released via put_page even if the operation failed. For
- * on-demand pinning, the page is released whenever it isn't stored in the
- * umem.
+ * Map to device a range of virtual address passed in the argument. The DMA
+ * addresses are in umem_odp->dma_list and the corresponding page informations
+ * in umem_odp->pfns.
  */
-static int ib_umem_odp_map_dma_single_page(
-		struct ib_umem_odp *umem_odp,
-		int page_index,
-		struct page *page,
-		u64 access_mask,
-		unsigned long current_seq)
+long ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp,
+			       struct hmm_range *range)
 {
+	struct device *device = umem_odp->umem.context->device->dma_device;
+	struct ib_ucontext_per_mm *per_mm = umem_odp->per_mm;
 	struct ib_umem *umem = &umem_odp->umem;
-	struct ib_device *dev = umem->context->device;
-	dma_addr_t dma_addr;
-	int stored_page = 0;
-	int remove_existing_mapping = 0;
-	int ret = 0;
-
-	/*
-	 * Note: we avoid writing if seq is different from the initial seq, to
-	 * handle case of a racing notifier. This check also allows us to bail
-	 * early if we have a notifier running in parallel with us.
-	 */
-	if (ib_umem_mmu_notifier_retry(umem_odp, current_seq)) {
-		ret = -EAGAIN;
-		goto out;
-	}
-	if (!(umem_odp->dma_list[page_index])) {
-		dma_addr = ib_dma_map_page(dev,
-					   page,
-					   0, BIT(umem->page_shift),
-					   DMA_BIDIRECTIONAL);
-		if (ib_dma_mapping_error(dev, dma_addr)) {
-			ret = -EFAULT;
-			goto out;
-		}
-		umem_odp->dma_list[page_index] = dma_addr | access_mask;
-		umem_odp->page_list[page_index] = page;
-		umem->npages++;
-		stored_page = 1;
-	} else if (umem_odp->page_list[page_index] == page) {
-		umem_odp->dma_list[page_index] |= access_mask;
-	} else {
-		pr_err("error: got different pages in IB device and from get_user_pages. IB device page: %p, gup page: %p\n",
-		       umem_odp->page_list[page_index], page);
-		/* Better remove the mapping now, to prevent any further
-		 * damage. */
-		remove_existing_mapping = 1;
-	}
+	struct mm_struct *mm = per_mm->mm;
+	unsigned long idx, npages;
+	long ret;
 
-out:
-	/* On Demand Paging - avoid pinning the page */
-	if (umem->context->invalidate_range || !stored_page)
-		put_page(page);
-
-	if (remove_existing_mapping && umem->context->invalidate_range) {
-		ib_umem_notifier_start_account(umem_odp);
-		umem->context->invalidate_range(
-			umem_odp,
-			ib_umem_start(umem) + (page_index << umem->page_shift),
-			ib_umem_start(umem) +
-				((page_index + 1) << umem->page_shift));
-		ib_umem_notifier_end_account(umem_odp);
-		ret = -EAGAIN;
-	}
+	if (mm == NULL)
+		return -ENOENT;
 
-	return ret;
-}
+	/* Only drivers with invalidate support can use this function. */
+	if (!umem->context->invalidate_range)
+		return -EINVAL;
 
-/**
- * ib_umem_odp_map_dma_pages - Pin and DMA map userspace memory in an ODP MR.
- *
- * Pins the range of pages passed in the argument, and maps them to
- * DMA addresses. The DMA addresses of the mapped pages is updated in
- * umem_odp->dma_list.
- *
- * Returns the number of pages mapped in success, negative error code
- * for failure.
- * An -EAGAIN error code is returned when a concurrent mmu notifier prevents
- * the function from completing its task.
- * An -ENOENT error code indicates that userspace process is being terminated
- * and mm was already destroyed.
- * @umem_odp: the umem to map and pin
- * @user_virt: the address from which we need to map.
- * @bcnt: the minimal number of bytes to pin and map. The mapping might be
- *        bigger due to alignment, and may also be smaller in case of an error
- *        pinning or mapping a page. The actual pages mapped is returned in
- *        the return value.
- * @access_mask: bit mask of the requested access permissions for the given
- *               range.
- * @current_seq: the MMU notifiers sequance value for synchronization with
- *               invalidations. the sequance number is read from
- *               umem_odp->notifiers_seq before calling this function
- */
-int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
-			      u64 bcnt, u64 access_mask,
-			      unsigned long current_seq)
-{
-	struct ib_umem *umem = &umem_odp->umem;
-	struct task_struct *owning_process  = NULL;
-	struct mm_struct *owning_mm = umem_odp->umem.owning_mm;
-	struct page       **local_page_list = NULL;
-	u64 page_mask, off;
-	int j, k, ret = 0, start_idx, npages = 0, page_shift;
-	unsigned int flags = 0;
-	phys_addr_t p = 0;
-
-	if (access_mask == 0)
+	/* Sanity checks. */
+	if (range->default_flags == 0)
 		return -EINVAL;
 
-	if (user_virt < ib_umem_start(umem) ||
-	    user_virt + bcnt > ib_umem_end(umem))
-		return -EFAULT;
+	if (range->start < ib_umem_start(umem) ||
+	    range->end > ib_umem_end(umem))
+		return -EINVAL;
 
-	local_page_list = (struct page **)__get_free_page(GFP_KERNEL);
-	if (!local_page_list)
-		return -ENOMEM;
+	idx = (range->start - ib_umem_start(umem)) >> umem->page_shift;
+	range->pfns = &umem_odp->pfns[idx];
+	range->pfn_shift = ODP_FLAGS_BITS;
+	range->values = odp_hmm_values;
+	range->flags = odp_hmm_flags;
 
-	page_shift = umem->page_shift;
-	page_mask = ~(BIT(page_shift) - 1);
-	off = user_virt & (~page_mask);
-	user_virt = user_virt & page_mask;
-	bcnt += off; /* Charge for the first page offset as well. */
+	ret = hmm_mirror_mm_down_read(&per_mm->mirror);
+	if (ret)
+		return ret;
+	mutex_lock(&umem_odp->umem_mutex);
+	ret = hmm_range_dma_map(range, device,
+		&umem_odp->dma_list[idx], true);
+	mutex_unlock(&umem_odp->umem_mutex);
+	npages = ret;
 
 	/*
-	 * owning_process is allowed to be NULL, this means somehow the mm is
-	 * existing beyond the lifetime of the originating process.. Presumably
-	 * mmget_not_zero will fail in this case.
+	 * The mmap_sem have been drop if hmm_vma_fault_and_dma_map() returned
+	 * with -EAGAIN. In which case we need to retry as -EBUSY but we also
+	 * need to take the mmap_sem again.
 	 */
-	owning_process = get_pid_task(umem_odp->per_mm->tgid, PIDTYPE_PID);
-	if (WARN_ON(!mmget_not_zero(umem_odp->umem.owning_mm))) {
-		ret = -EINVAL;
-		goto out_put_task;
-	}
-
-	if (access_mask & ODP_WRITE_ALLOWED_BIT)
-		flags |= FOLL_WRITE;
-
-	start_idx = (user_virt - ib_umem_start(umem)) >> page_shift;
-	k = start_idx;
-
-	while (bcnt > 0) {
-		const size_t gup_num_pages = min_t(size_t,
-				(bcnt + BIT(page_shift) - 1) >> page_shift,
-				PAGE_SIZE / sizeof(struct page *));
-
-		down_read(&owning_mm->mmap_sem);
-		/*
-		 * Note: this might result in redundent page getting. We can
-		 * avoid this by checking dma_list to be 0 before calling
-		 * get_user_pages. However, this make the code much more
-		 * complex (and doesn't gain us much performance in most use
-		 * cases).
-		 */
-		npages = get_user_pages_remote(owning_process, owning_mm,
-				user_virt, gup_num_pages,
-				flags, local_page_list, NULL, NULL);
-		up_read(&owning_mm->mmap_sem);
-
-		if (npages < 0) {
-			if (npages != -EAGAIN)
-				pr_warn("fail to get %zu user pages with error %d\n", gup_num_pages, npages);
-			else
-				pr_debug("fail to get %zu user pages with error %d\n", gup_num_pages, npages);
-			break;
-		}
-
-		bcnt -= min_t(size_t, npages << PAGE_SHIFT, bcnt);
-		mutex_lock(&umem_odp->umem_mutex);
-		for (j = 0; j < npages; j++, user_virt += PAGE_SIZE) {
-			if (user_virt & ~page_mask) {
-				p += PAGE_SIZE;
-				if (page_to_phys(local_page_list[j]) != p) {
-					ret = -EFAULT;
-					break;
-				}
-				put_page(local_page_list[j]);
-				continue;
-			}
-
-			ret = ib_umem_odp_map_dma_single_page(
-					umem_odp, k, local_page_list[j],
-					access_mask, current_seq);
-			if (ret < 0) {
-				if (ret != -EAGAIN)
-					pr_warn("ib_umem_odp_map_dma_single_page failed with error %d\n", ret);
-				else
-					pr_debug("ib_umem_odp_map_dma_single_page failed with error %d\n", ret);
-				break;
-			}
-
-			p = page_to_phys(local_page_list[j]);
-			k++;
-		}
-		mutex_unlock(&umem_odp->umem_mutex);
+	if (ret != -EAGAIN)
+		 hmm_mirror_mm_up_read(&per_mm->mirror);
 
-		if (ret < 0) {
-			/* Release left over pages when handling errors. */
-			for (++j; j < npages; ++j)
-				put_page(local_page_list[j]);
-			break;
-		}
-	}
-
-	if (ret >= 0) {
-		if (npages < 0 && k == start_idx)
-			ret = npages;
-		else
-			ret = k - start_idx;
+	if (ret <= 0) {
+		/* Convert -EBUSY to -EAGAIN and 0 to -EAGAIN */
+		ret = ret == -EBUSY ? -EAGAIN : ret;
+		return ret ? ret : -EAGAIN;
 	}
 
-	mmput(owning_mm);
-out_put_task:
-	if (owning_process)
-		put_task_struct(owning_process);
-	free_page((unsigned long)local_page_list);
-	return ret;
+	umem->npages += npages;
+	return npages;
 }
 EXPORT_SYMBOL(ib_umem_odp_map_dma_pages);
 
-void ib_umem_odp_unmap_dma_pages(struct ib_umem_odp *umem_odp, u64 virt,
-				 u64 bound)
+void ib_umem_odp_unmap_dma_pages(struct ib_umem_odp *umem_odp,
+				 u64 virt, u64 bound)
 {
+	struct device *device = umem_odp->umem.context->device->dma_device;
 	struct ib_umem *umem = &umem_odp->umem;
-	int idx;
-	u64 addr;
-	struct ib_device *dev = umem->context->device;
+	unsigned long idx, page_mask;
+	struct hmm_range range;
+	long ret;
+
+	if (!umem->npages)
+		return;
+
+	bound = ALIGN(bound, 1UL << umem->page_shift);
+	page_mask = ~(BIT(umem->page_shift) - 1);
+	virt &= page_mask;
 
 	virt  = max_t(u64, virt,  ib_umem_start(umem));
 	bound = min_t(u64, bound, ib_umem_end(umem));
-	/* Note that during the run of this function, the
-	 * notifiers_count of the MR is > 0, preventing any racing
-	 * faults from completion. We might be racing with other
-	 * invalidations, so we must make sure we free each page only
-	 * once. */
+
+	idx = ((unsigned long)virt - ib_umem_start(umem)) >> PAGE_SHIFT;
+
+	range.page_shift = umem->page_shift;
+	range.pfns = &umem_odp->pfns[idx];
+	range.pfn_shift = ODP_FLAGS_BITS;
+	range.values = odp_hmm_values;
+	range.flags = odp_hmm_flags;
+	range.start = virt;
+	range.end = bound;
+
 	mutex_lock(&umem_odp->umem_mutex);
-	for (addr = virt; addr < bound; addr += BIT(umem->page_shift)) {
-		idx = (addr - ib_umem_start(umem)) >> umem->page_shift;
-		if (umem_odp->page_list[idx]) {
-			struct page *page = umem_odp->page_list[idx];
-			dma_addr_t dma = umem_odp->dma_list[idx];
-			dma_addr_t dma_addr = dma & ODP_DMA_ADDR_MASK;
-
-			WARN_ON(!dma_addr);
-
-			ib_dma_unmap_page(dev, dma_addr, PAGE_SIZE,
-					  DMA_BIDIRECTIONAL);
-			if (dma & ODP_WRITE_ALLOWED_BIT) {
-				struct page *head_page = compound_head(page);
-				/*
-				 * set_page_dirty prefers being called with
-				 * the page lock. However, MMU notifiers are
-				 * called sometimes with and sometimes without
-				 * the lock. We rely on the umem_mutex instead
-				 * to prevent other mmu notifiers from
-				 * continuing and allowing the page mapping to
-				 * be removed.
-				 */
-				set_page_dirty(head_page);
-			}
-			/* on demand pinning support */
-			if (!umem->context->invalidate_range)
-				put_page(page);
-			umem_odp->page_list[idx] = NULL;
-			umem_odp->dma_list[idx] = 0;
-			umem->npages--;
-		}
-	}
+	ret = hmm_range_dma_unmap(&range, NULL, device,
+		&umem_odp->dma_list[idx], true);
+	if (ret > 0)
+		umem->npages -= ret;
 	mutex_unlock(&umem_odp->umem_mutex);
 }
 EXPORT_SYMBOL(ib_umem_odp_unmap_dma_pages);
diff --git a/drivers/infiniband/hw/mlx5/mem.c b/drivers/infiniband/hw/mlx5/mem.c
index 549234988bb4..b9621d4d80b1 100644
--- a/drivers/infiniband/hw/mlx5/mem.c
+++ b/drivers/infiniband/hw/mlx5/mem.c
@@ -112,16 +112,16 @@ void mlx5_ib_cont_pages(struct ib_umem *umem, u64 addr,
 }
 
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
-static u64 umem_dma_to_mtt(dma_addr_t umem_dma)
+static u64 umem_dma_to_mtt(struct ib_umem_odp *odp, size_t idx)
 {
-	u64 mtt_entry = umem_dma & ODP_DMA_ADDR_MASK;
+	u64 mtt_entry = odp->dma_list[idx];
 
-	if (umem_dma & ODP_READ_ALLOWED_BIT)
+	if (odp->pfns[idx] & ODP_READ_BIT)
 		mtt_entry |= MLX5_IB_MTT_READ;
-	if (umem_dma & ODP_WRITE_ALLOWED_BIT)
+	if (odp->pfns[idx] & ODP_WRITE_BIT)
 		mtt_entry |= MLX5_IB_MTT_WRITE;
 
-	return mtt_entry;
+	return cpu_to_be64(mtt_entry);
 }
 #endif
 
@@ -153,15 +153,13 @@ void __mlx5_ib_populate_pas(struct mlx5_ib_dev *dev, struct ib_umem *umem,
 	int entry;
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
 	if (umem->is_odp) {
+		struct ib_umem_odp *odp = to_ib_umem_odp(umem);
+
 		WARN_ON(shift != 0);
 		WARN_ON(access_flags != (MLX5_IB_MTT_READ | MLX5_IB_MTT_WRITE));
 
-		for (i = 0; i < num_pages; ++i) {
-			dma_addr_t pa =
-				to_ib_umem_odp(umem)->dma_list[offset + i];
-
-			pas[i] = cpu_to_be64(umem_dma_to_mtt(pa));
-		}
+		for (i = 0; i < num_pages; ++i)
+			pas[i] = umem_dma_to_mtt(odp, offset + i);
 		return;
 	}
 #endif
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index fd6ea1f75085..e764855e4044 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -1650,7 +1650,7 @@ static void dereg_mr(struct mlx5_ib_dev *dev, struct mlx5_ib_mr *mr)
 		/* Wait for all running page-fault handlers to finish. */
 		synchronize_srcu(&dev->mr_srcu);
 		/* Destroy all page mappings */
-		if (umem_odp->page_list)
+		if (umem_odp->pfns)
 			mlx5_ib_invalidate_range(umem_odp, ib_umem_start(umem),
 						 ib_umem_end(umem));
 		else
diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index 01e0f6200631..9d551b044017 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -257,8 +257,7 @@ void mlx5_ib_invalidate_range(struct ib_umem_odp *umem_odp, unsigned long start,
 		 * estimate the cost of another UMR vs. the cost of bigger
 		 * UMR.
 		 */
-		if (umem_odp->dma_list[idx] &
-		    (ODP_READ_ALLOWED_BIT | ODP_WRITE_ALLOWED_BIT)) {
+		if (umem_odp->pfns[idx] & ODP_READ_BIT) {
 			if (!in_block) {
 				blk_start_idx = idx;
 				in_block = 1;
@@ -555,17 +554,18 @@ static int pagefault_mr(struct mlx5_ib_dev *dev, struct mlx5_ib_mr *mr,
 			u64 io_virt, size_t bcnt, u32 *bytes_mapped,
 			u32 flags)
 {
-	int npages = 0, current_seq, page_shift, ret, np;
-	bool implicit = false;
 	struct ib_umem_odp *odp_mr = to_ib_umem_odp(mr->umem);
 	bool downgrade = flags & MLX5_PF_FLAGS_DOWNGRADE;
 	bool prefetch = flags & MLX5_PF_FLAGS_PREFETCH;
-	u64 access_mask = ODP_READ_ALLOWED_BIT;
+	unsigned long npages = 0, page_shift, np, off;
 	u64 start_idx, page_mask;
 	struct ib_umem_odp *odp;
+	struct hmm_range range;
+	bool implicit = false;
 	size_t size;
+	long ret;
 
-	if (!odp_mr->page_list) {
+	if (!odp_mr->pfns) {
 		odp = implicit_mr_get_data(mr, io_virt, bcnt);
 
 		if (IS_ERR(odp))
@@ -578,11 +578,27 @@ static int pagefault_mr(struct mlx5_ib_dev *dev, struct mlx5_ib_mr *mr,
 
 next_mr:
 	size = min_t(size_t, bcnt, ib_umem_end(&odp->umem) - io_virt);
-
 	page_shift = mr->umem->page_shift;
 	page_mask = ~(BIT(page_shift) - 1);
+	off = (io_virt & (~page_mask));
+	size += (io_virt & (~page_mask));
+	io_virt = io_virt & page_mask;
+	off += (size & (~page_mask));
+	size = ALIGN(size, 1UL << page_shift);
+
+	if (io_virt < ib_umem_start(&odp->umem))
+		return -EINVAL;
+
 	start_idx = (io_virt - (mr->mmkey.iova & page_mask)) >> page_shift;
 
+	if (odp_mr->per_mm == NULL || odp_mr->per_mm->mm == NULL)
+		return -ENOENT;
+
+	ret = hmm_range_register(&range, odp_mr->per_mm->mm,
+				 io_virt, io_virt + size, page_shift);
+	if (ret)
+		return ret;
+
 	if (prefetch && !downgrade && !mr->umem->writable) {
 		/* prefetch with write-access must
 		 * be supported by the MR
@@ -591,55 +607,48 @@ static int pagefault_mr(struct mlx5_ib_dev *dev, struct mlx5_ib_mr *mr,
 		goto out;
 	}
 
+	range.default_flags = ODP_READ_BIT;
 	if (mr->umem->writable && !downgrade)
-		access_mask |= ODP_WRITE_ALLOWED_BIT;
-
-	current_seq = READ_ONCE(odp->notifiers_seq);
-	/*
-	 * Ensure the sequence number is valid for some time before we call
-	 * gup.
-	 */
-	smp_rmb();
-
-	ret = ib_umem_odp_map_dma_pages(to_ib_umem_odp(mr->umem), io_virt, size,
-					access_mask, current_seq);
+		range.default_flags |= ODP_WRITE_BIT;
 
+	ret = ib_umem_odp_map_dma_pages(to_ib_umem_odp(mr->umem), &range);
 	if (ret < 0)
-		goto out;
+		goto again;
 
 	np = ret;
 
 	mutex_lock(&odp->umem_mutex);
-	if (!ib_umem_mmu_notifier_retry(to_ib_umem_odp(mr->umem),
-					current_seq)) {
+	if (hmm_range_valid(&range)) {
 		/*
 		 * No need to check whether the MTTs really belong to
-		 * this MR, since ib_umem_odp_map_dma_pages already
+		 * this MR, since ib_umem_odp_map_dma_pages() already
 		 * checks this.
 		 */
 		ret = mlx5_ib_update_xlt(mr, start_idx, np,
 					 page_shift, MLX5_IB_UPD_XLT_ATOMIC);
-	} else {
+	} else
 		ret = -EAGAIN;
-	}
 	mutex_unlock(&odp->umem_mutex);
 
 	if (ret < 0) {
-		if (ret != -EAGAIN)
+		if (ret != -EAGAIN) {
 			mlx5_ib_err(dev, "Failed to update mkey page tables\n");
-		goto out;
+			goto out;
+		}
+		goto again;
 	}
 
 	if (bytes_mapped) {
-		u32 new_mappings = (np << page_shift) -
-			(io_virt - round_down(io_virt, 1 << page_shift));
+		long new_mappings = (np << page_shift) - off;
+		new_mappings = new_mappings < 0 ? 0 : new_mappings;
 		*bytes_mapped += min_t(u32, new_mappings, size);
 	}
 
 	npages += np << (page_shift - PAGE_SHIFT);
+	hmm_range_unregister(&range);
 	bcnt -= size;
 
-	if (unlikely(bcnt)) {
+	if (unlikely(bcnt > 0)) {
 		struct ib_umem_odp *next;
 
 		io_virt += size;
@@ -656,24 +665,18 @@ static int pagefault_mr(struct mlx5_ib_dev *dev, struct mlx5_ib_mr *mr,
 
 	return npages;
 
-out:
-	if (ret == -EAGAIN) {
-		if (implicit || !odp->dying) {
-			unsigned long timeout =
-				msecs_to_jiffies(MMU_NOTIFIER_TIMEOUT);
-
-			if (!wait_for_completion_timeout(
-					&odp->notifier_completion,
-					timeout)) {
-				mlx5_ib_warn(dev, "timeout waiting for mmu notifier. seq %d against %d. notifiers_count=%d\n",
-					     current_seq, odp->notifiers_seq, odp->notifiers_count);
-			}
-		} else {
-			/* The MR is being killed, kill the QP as well. */
-			ret = -EFAULT;
-		}
-	}
+again:
+	if (ret != -EAGAIN)
+		goto out;
 
+	/* Check if the MR is being killed, kill the QP as well. */
+	if (!implicit || odp->dying)
+		ret = -EFAULT;
+	else if (!hmm_range_wait_until_valid(&range, MMU_NOTIFIER_TIMEOUT))
+		mlx5_ib_warn(dev, "timeout waiting for mmu notifier.\n");
+
+out:
+	hmm_range_unregister(&range);
 	return ret;
 }
 
diff --git a/include/rdma/ib_umem_odp.h b/include/rdma/ib_umem_odp.h
index 0b1446fe2fab..1d61a616b3b6 100644
--- a/include/rdma/ib_umem_odp.h
+++ b/include/rdma/ib_umem_odp.h
@@ -36,6 +36,7 @@
 #include <rdma/ib_umem.h>
 #include <rdma/ib_verbs.h>
 #include <linux/interval_tree.h>
+#include <linux/hmm.h>
 
 struct umem_odp_node {
 	u64 __subtree_last;
@@ -47,11 +48,11 @@ struct ib_umem_odp {
 	struct ib_ucontext_per_mm *per_mm;
 
 	/*
-	 * An array of the pages included in the on-demand paging umem.
-	 * Indices of pages that are currently not mapped into the device will
-	 * contain NULL.
+	 * An array of the pages included in the on-demand paging umem. Indices
+	 * of pages that are currently not mapped into the device will contain
+	 * 0.
 	 */
-	struct page		**page_list;
+	uint64_t *pfns;
 	/*
 	 * An array of the same size as page_list, with DMA addresses mapped
 	 * for pages the pages in page_list. The lower two bits designate
@@ -67,13 +68,9 @@ struct ib_umem_odp {
 	struct mutex		umem_mutex;
 	void			*private; /* for the HW driver to use. */
 
-	int notifiers_seq;
-	int notifiers_count;
-
 	/* Tree tracking */
 	struct umem_odp_node	interval_tree;
 
-	struct completion	notifier_completion;
 	int			dying;
 	struct work_struct	work;
 };
@@ -95,11 +92,10 @@ struct ib_ucontext_per_mm {
 	/* Protects umem_tree */
 	struct rw_semaphore umem_rwsem;
 
-	struct mmu_notifier mn;
+	struct hmm_mirror mirror;
 	unsigned int odp_mrs_count;
 
 	struct list_head ucontext_list;
-	struct rcu_head rcu;
 };
 
 int ib_umem_odp_get(struct ib_umem_odp *umem_odp, int access);
@@ -107,22 +103,13 @@ struct ib_umem_odp *ib_alloc_odp_umem(struct ib_ucontext_per_mm *per_mm,
 				      unsigned long addr, size_t size);
 void ib_umem_odp_release(struct ib_umem_odp *umem_odp);
 
-/*
- * The lower 2 bits of the DMA address signal the R/W permissions for
- * the entry. To upgrade the permissions, provide the appropriate
- * bitmask to the map_dma_pages function.
- *
- * Be aware that upgrading a mapped address might result in change of
- * the DMA address for the page.
- */
-#define ODP_READ_ALLOWED_BIT  (1<<0ULL)
-#define ODP_WRITE_ALLOWED_BIT (1<<1ULL)
-
-#define ODP_DMA_ADDR_MASK (~(ODP_READ_ALLOWED_BIT | ODP_WRITE_ALLOWED_BIT))
+#define ODP_READ_BIT	(1<<0ULL)
+#define ODP_WRITE_BIT	(1<<1ULL)
+#define ODP_DEVICE_BIT	(1<<2ULL)
+#define ODP_FLAGS_BITS	3
 
-int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 start_offset,
-			      u64 bcnt, u64 access_mask,
-			      unsigned long current_seq);
+long ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp,
+			       struct hmm_range *range);
 
 void ib_umem_odp_unmap_dma_pages(struct ib_umem_odp *umem_odp, u64 start_offset,
 				 u64 bound);
@@ -145,23 +132,6 @@ int rbt_ib_umem_for_each_in_range(struct rb_root_cached *root,
 struct ib_umem_odp *rbt_ib_umem_lookup(struct rb_root_cached *root,
 				       u64 addr, u64 length);
 
-static inline int ib_umem_mmu_notifier_retry(struct ib_umem_odp *umem_odp,
-					     unsigned long mmu_seq)
-{
-	/*
-	 * This code is strongly based on the KVM code from
-	 * mmu_notifier_retry. Should be called with
-	 * the relevant locks taken (umem_odp->umem_mutex
-	 * and the ucontext umem_mutex semaphore locked for read).
-	 */
-
-	if (unlikely(umem_odp->notifiers_count))
-		return 1;
-	if (umem_odp->notifiers_seq != mmu_seq)
-		return 1;
-	return 0;
-}
-
 #else /* CONFIG_INFINIBAND_ON_DEMAND_PAGING */
 
 static inline int ib_umem_odp_get(struct ib_umem_odp *umem_odp, int access)
-- 
2.17.2

