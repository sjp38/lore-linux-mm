Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0BD2C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5683A214C6
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:16:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="OggTUEsp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5683A214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8036F6B026F; Tue,  6 Aug 2019 19:16:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E86A6B026A; Tue,  6 Aug 2019 19:16:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B70B6B026B; Tue,  6 Aug 2019 19:16:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D22AC6B0266
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:16:19 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e32so80331820qtc.7
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:16:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Pn+tyQ3Pr4O2LIFi6En+JQU77nMjukrgPYCGXMr75Sc=;
        b=i7t/1xgmeUOXiGIVM7NXoMFOHn10vVBxfkO6UBmZ0MgM5eIF5hW2K7l3jA7gea/y68
         r257WwfJq/a00BIrHYs+wK85u9M1jrRQfkSYBWZ2grSBV96umuxcyFl8MhYkVSTfA2QP
         cwnZn+f9GHJ4hg7or9pkgjjGCAqeH3wAVGrN0000oe3EEFu5o1S5w3cSYiUY8iarRmiY
         Dg37SGwJE5Ha6UL9Gl3qz3CjID4D+nTxHs8zBiPlODXTuAB8KceFp/vnA6UP6hfenlMM
         wK7SjRwK/7hehIs7bsYQQ8Rmsgq/t6BfWtBXreDPn+J4H8HTSuzwn/dHe3mB4RwErcfW
         8jFw==
X-Gm-Message-State: APjAAAVMSQBvkHZUs7h7Cricipvsd96w6+TltHdchG8Y+VDFCqY5S15W
	801UybwrHai1C/UTLQKDFCP7pvChF1Z8V/HTxfkZoisDRjymS0ITcEcCC2IMzMCbSv7ZQFB2Vyl
	2rHpfLRYTmXe7wCTRdhDotrNpRWvvyCqMyya9VhOwSrj18eZRTw7D0iQDbGJy5w8Faw==
X-Received: by 2002:a05:6214:1306:: with SMTP id a6mr3271665qvv.38.1565133379624;
        Tue, 06 Aug 2019 16:16:19 -0700 (PDT)
X-Received: by 2002:a05:6214:1306:: with SMTP id a6mr3271602qvv.38.1565133378720;
        Tue, 06 Aug 2019 16:16:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565133378; cv=none;
        d=google.com; s=arc-20160816;
        b=dDC9gUJhGd5DqcnvXjtlRDbwQjEGWf9xpL4SKtSMIMJxZIiUUDIrrudWvbI1ZoJuk5
         H/1PUITj8u5nhY8WoAIJb5aiMvhLijQU3DVGHav6Hkb/ogquRGyJ4fhBvd+u0o0KV+5I
         h1uT6+H8cPUUh9bXtN0PNJmAjBgDTtuTfhOiQEpDsNb9nsV9JWuzVGq6dNnk3JpWNwmz
         t+ZWEure02h8ch036E7uVAIwp2iJzUtcJKqg1a5VBAfUH2ciKbD2UwgfLFYKj/dqGZDh
         70Cj4ObHfEkI+N47EMbI9q3Qfzc7DSAWDI/xr4YnLoW6JOKHVLvVR3zNDS/A9W0lsXjO
         KQtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Pn+tyQ3Pr4O2LIFi6En+JQU77nMjukrgPYCGXMr75Sc=;
        b=Iye30NwmwVNH9pSlLLJWFMu5E7D1pVpXgggHZL9VJO/ZvFZc/UlJAE86Lz7xFyUBSR
         Ysk8jcbowF12Kb9BDqWZfCZ9UMS3gIsQi/ZwRx89SRkGc1uRp2erPzZEY96+mb98xT/8
         k3Q2ZkHP+kWDQDb1q1EqnYwp7qAaPwTBd/VtBVt57NyKPzZ25UX3lKN5vwwlWtSM3bhG
         To6kvkwoZkxyB+8Mygld7ltsALUqbkLG1IVkL+tFRGUTP7coj+UOzlmDT50wIYNG42Ng
         xIVfjaQv0BWicSuaDmMNPDQtuKzQWH9KVNn0hOPGkoWpdbKYKwxmmmiv4U3lksp+9oMb
         CO2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=OggTUEsp;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w13sor115179686qta.62.2019.08.06.16.16.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 16:16:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=OggTUEsp;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Pn+tyQ3Pr4O2LIFi6En+JQU77nMjukrgPYCGXMr75Sc=;
        b=OggTUEspMMn1b2yn+uWIxqTUSf36GrQvvrKxao/PHqyl+DTzlNDH4G1PGH3Rn0oGUS
         9yWjg40oqduC6+lBlaQt5AEvzMMt0+HwZg55qm2B0NolxD6rKy/+kW7fIzbbXJKBopU0
         i0almRR6UKPo/GhOflLmKlphmx9M/H798dmunpZq7PtsAO2b61x95N71srn2s2CDP8O8
         2Nnw5Qr44QCLihcSGiRyMe3Kj2uVDFPch0f783vgeAsiRsnpUJHeAgiwM1GQwWYB1VHE
         DvJqjSXNfKnDYlNgHN92XgTfN016uxa+ZXPo1oS4z0q6EyI5dcvmeyhfMveigWb28Muk
         7f4w==
X-Google-Smtp-Source: APXvYqxTw9+mlouFwWoFRA0XatHqfMRrcpDdIv2NXf5/HvRxmFylGt3sJXAS2PMqHoBRobENBadT3A==
X-Received: by 2002:ac8:285c:: with SMTP id 28mr5575869qtr.186.1565133378273;
        Tue, 06 Aug 2019 16:16:18 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id r40sm47669868qtr.57.2019.08.06.16.16.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 16:16:17 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv8gg-0006ey-Dk; Tue, 06 Aug 2019 20:16:14 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	intel-gfx@lists.freedesktop.org,
	Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v3 hmm 08/11] drm/radeon: use mmu_notifier_get/put for struct radeon_mn
Date: Tue,  6 Aug 2019 20:15:45 -0300
Message-Id: <20190806231548.25242-9-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190806231548.25242-1-jgg@ziepe.ca>
References: <20190806231548.25242-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

radeon is using a device global hash table to track what mmu_notifiers
have been registered on struct mm. This is better served with the new
get/put scheme instead.

radeon has a bug where it was not blocking notifier release() until all
the BO's had been invalidated. This could result in a use after free of
pages the BOs. This is tied into a second bug where radeon left the
notifiers running endlessly even once the interval tree became
empty. This could result in a use after free with module unload.

Both are fixed by changing the lifetime model, the BOs exist in the
interval tree with their natural lifetimes independent of the mm_struct
lifetime using the get/put scheme. The release runs synchronously and just
does invalidate_start across the entire interval tree to create the
required DMA fence.

Additions to the interval tree after release are already impossible as
only current->mm is used during the add.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/gpu/drm/radeon/radeon.h        |   3 -
 drivers/gpu/drm/radeon/radeon_device.c |   2 -
 drivers/gpu/drm/radeon/radeon_drv.c    |   2 +
 drivers/gpu/drm/radeon/radeon_mn.c     | 157 ++++++-------------------
 4 files changed, 38 insertions(+), 126 deletions(-)

AMD team: I wonder if kfd has similar lifetime issues?

diff --git a/drivers/gpu/drm/radeon/radeon.h b/drivers/gpu/drm/radeon/radeon.h
index 32808e50be12f8..918164f90b114a 100644
--- a/drivers/gpu/drm/radeon/radeon.h
+++ b/drivers/gpu/drm/radeon/radeon.h
@@ -2451,9 +2451,6 @@ struct radeon_device {
 	/* tracking pinned memory */
 	u64 vram_pin_size;
 	u64 gart_pin_size;
-
-	struct mutex	mn_lock;
-	DECLARE_HASHTABLE(mn_hash, 7);
 };
 
 bool radeon_is_px(struct drm_device *dev);
diff --git a/drivers/gpu/drm/radeon/radeon_device.c b/drivers/gpu/drm/radeon/radeon_device.c
index dceb554e567446..788b1d8a80e660 100644
--- a/drivers/gpu/drm/radeon/radeon_device.c
+++ b/drivers/gpu/drm/radeon/radeon_device.c
@@ -1325,8 +1325,6 @@ int radeon_device_init(struct radeon_device *rdev,
 	init_rwsem(&rdev->pm.mclk_lock);
 	init_rwsem(&rdev->exclusive_lock);
 	init_waitqueue_head(&rdev->irq.vblank_queue);
-	mutex_init(&rdev->mn_lock);
-	hash_init(rdev->mn_hash);
 	r = radeon_gem_init(rdev);
 	if (r)
 		return r;
diff --git a/drivers/gpu/drm/radeon/radeon_drv.c b/drivers/gpu/drm/radeon/radeon_drv.c
index a6cbe11f79c611..b6535ac91fdb74 100644
--- a/drivers/gpu/drm/radeon/radeon_drv.c
+++ b/drivers/gpu/drm/radeon/radeon_drv.c
@@ -35,6 +35,7 @@
 #include <linux/module.h>
 #include <linux/pm_runtime.h>
 #include <linux/vga_switcheroo.h>
+#include <linux/mmu_notifier.h>
 
 #include <drm/drm_crtc_helper.h>
 #include <drm/drm_drv.h>
@@ -624,6 +625,7 @@ static void __exit radeon_exit(void)
 {
 	pci_unregister_driver(pdriver);
 	radeon_unregister_atpx_handler();
+	mmu_notifier_synchronize();
 }
 
 module_init(radeon_init);
diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
index 8c3871ed23a9f0..fc8254273a800b 100644
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -37,17 +37,8 @@
 #include "radeon.h"
 
 struct radeon_mn {
-	/* constant after initialisation */
-	struct radeon_device	*rdev;
-	struct mm_struct	*mm;
 	struct mmu_notifier	mn;
 
-	/* only used on destruction */
-	struct work_struct	work;
-
-	/* protected by rdev->mn_lock */
-	struct hlist_node	node;
-
 	/* objects protected by lock */
 	struct mutex		lock;
 	struct rb_root_cached	objects;
@@ -58,55 +49,6 @@ struct radeon_mn_node {
 	struct list_head		bos;
 };
 
-/**
- * radeon_mn_destroy - destroy the rmn
- *
- * @work: previously sheduled work item
- *
- * Lazy destroys the notifier from a work item
- */
-static void radeon_mn_destroy(struct work_struct *work)
-{
-	struct radeon_mn *rmn = container_of(work, struct radeon_mn, work);
-	struct radeon_device *rdev = rmn->rdev;
-	struct radeon_mn_node *node, *next_node;
-	struct radeon_bo *bo, *next_bo;
-
-	mutex_lock(&rdev->mn_lock);
-	mutex_lock(&rmn->lock);
-	hash_del(&rmn->node);
-	rbtree_postorder_for_each_entry_safe(node, next_node,
-					     &rmn->objects.rb_root, it.rb) {
-
-		interval_tree_remove(&node->it, &rmn->objects);
-		list_for_each_entry_safe(bo, next_bo, &node->bos, mn_list) {
-			bo->mn = NULL;
-			list_del_init(&bo->mn_list);
-		}
-		kfree(node);
-	}
-	mutex_unlock(&rmn->lock);
-	mutex_unlock(&rdev->mn_lock);
-	mmu_notifier_unregister(&rmn->mn, rmn->mm);
-	kfree(rmn);
-}
-
-/**
- * radeon_mn_release - callback to notify about mm destruction
- *
- * @mn: our notifier
- * @mn: the mm this callback is about
- *
- * Shedule a work item to lazy destroy our notifier.
- */
-static void radeon_mn_release(struct mmu_notifier *mn,
-			      struct mm_struct *mm)
-{
-	struct radeon_mn *rmn = container_of(mn, struct radeon_mn, mn);
-	INIT_WORK(&rmn->work, radeon_mn_destroy);
-	schedule_work(&rmn->work);
-}
-
 /**
  * radeon_mn_invalidate_range_start - callback to notify about mm change
  *
@@ -183,65 +125,44 @@ static int radeon_mn_invalidate_range_start(struct mmu_notifier *mn,
 	return ret;
 }
 
-static const struct mmu_notifier_ops radeon_mn_ops = {
-	.release = radeon_mn_release,
-	.invalidate_range_start = radeon_mn_invalidate_range_start,
-};
+static void radeon_mn_release(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	struct mmu_notifier_range range = {
+		.mm = mm,
+		.start = 0,
+		.end = ULONG_MAX,
+		.flags = 0,
+		.event = MMU_NOTIFY_UNMAP,
+	};
+
+	radeon_mn_invalidate_range_start(mn, &range);
+}
 
-/**
- * radeon_mn_get - create notifier context
- *
- * @rdev: radeon device pointer
- *
- * Creates a notifier context for current->mm.
- */
-static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
+static struct mmu_notifier *radeon_mn_alloc_notifier(struct mm_struct *mm)
 {
-	struct mm_struct *mm = current->mm;
 	struct radeon_mn *rmn;
-	int r;
-
-	if (down_write_killable(&mm->mmap_sem))
-		return ERR_PTR(-EINTR);
-
-	mutex_lock(&rdev->mn_lock);
-
-	hash_for_each_possible(rdev->mn_hash, rmn, node, (unsigned long)mm)
-		if (rmn->mm == mm)
-			goto release_locks;
 
 	rmn = kzalloc(sizeof(*rmn), GFP_KERNEL);
-	if (!rmn) {
-		rmn = ERR_PTR(-ENOMEM);
-		goto release_locks;
-	}
+	if (!rmn)
+		return ERR_PTR(-ENOMEM);
 
-	rmn->rdev = rdev;
-	rmn->mm = mm;
-	rmn->mn.ops = &radeon_mn_ops;
 	mutex_init(&rmn->lock);
 	rmn->objects = RB_ROOT_CACHED;
-	
-	r = __mmu_notifier_register(&rmn->mn, mm);
-	if (r)
-		goto free_rmn;
-
-	hash_add(rdev->mn_hash, &rmn->node, (unsigned long)mm);
-
-release_locks:
-	mutex_unlock(&rdev->mn_lock);
-	up_write(&mm->mmap_sem);
-
-	return rmn;
-
-free_rmn:
-	mutex_unlock(&rdev->mn_lock);
-	up_write(&mm->mmap_sem);
-	kfree(rmn);
+	return &rmn->mn;
+}
 
-	return ERR_PTR(r);
+static void radeon_mn_free_notifier(struct mmu_notifier *mn)
+{
+	kfree(container_of(mn, struct radeon_mn, mn));
 }
 
+static const struct mmu_notifier_ops radeon_mn_ops = {
+	.release = radeon_mn_release,
+	.invalidate_range_start = radeon_mn_invalidate_range_start,
+	.alloc_notifier = radeon_mn_alloc_notifier,
+	.free_notifier = radeon_mn_free_notifier,
+};
+
 /**
  * radeon_mn_register - register a BO for notifier updates
  *
@@ -254,15 +175,16 @@ static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
 int radeon_mn_register(struct radeon_bo *bo, unsigned long addr)
 {
 	unsigned long end = addr + radeon_bo_size(bo) - 1;
-	struct radeon_device *rdev = bo->rdev;
+	struct mmu_notifier *mn;
 	struct radeon_mn *rmn;
 	struct radeon_mn_node *node = NULL;
 	struct list_head bos;
 	struct interval_tree_node *it;
 
-	rmn = radeon_mn_get(rdev);
-	if (IS_ERR(rmn))
-		return PTR_ERR(rmn);
+	mn = mmu_notifier_get(&radeon_mn_ops, current->mm);
+	if (IS_ERR(mn))
+		return PTR_ERR(mn);
+	rmn = container_of(mn, struct radeon_mn, mn);
 
 	INIT_LIST_HEAD(&bos);
 
@@ -309,22 +231,13 @@ int radeon_mn_register(struct radeon_bo *bo, unsigned long addr)
  */
 void radeon_mn_unregister(struct radeon_bo *bo)
 {
-	struct radeon_device *rdev = bo->rdev;
-	struct radeon_mn *rmn;
+	struct radeon_mn *rmn = bo->mn;
 	struct list_head *head;
 
-	mutex_lock(&rdev->mn_lock);
-	rmn = bo->mn;
-	if (rmn == NULL) {
-		mutex_unlock(&rdev->mn_lock);
-		return;
-	}
-
 	mutex_lock(&rmn->lock);
 	/* save the next list entry for later */
 	head = bo->mn_list.next;
 
-	bo->mn = NULL;
 	list_del(&bo->mn_list);
 
 	if (list_empty(head)) {
@@ -335,5 +248,7 @@ void radeon_mn_unregister(struct radeon_bo *bo)
 	}
 
 	mutex_unlock(&rmn->lock);
-	mutex_unlock(&rdev->mn_lock);
+
+	mmu_notifier_put(&rmn->mn);
+	bo->mn = NULL;
 }
-- 
2.22.0

