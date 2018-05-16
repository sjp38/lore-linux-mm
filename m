Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8206B02F6
	for <linux-mm@kvack.org>; Wed, 16 May 2018 01:44:59 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id n26-v6so1315640pgd.2
        for <linux-mm@kvack.org>; Tue, 15 May 2018 22:44:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w12-v6si1773076pld.367.2018.05.15.22.44.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 May 2018 22:44:58 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 11/14] ttm: separate errno from VM_FAULT_* values
Date: Wed, 16 May 2018 07:43:45 +0200
Message-Id: <20180516054348.15950-12-hch@lst.de>
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/ttm/ttm_bo_vm.c | 42 +++++++++++++++++----------------
 1 file changed, 22 insertions(+), 20 deletions(-)

diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index 8eba95b3c737..255e7801f62c 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -43,10 +43,11 @@
 
 #define TTM_BO_VM_NUM_PREFAULT 16
 
-static int ttm_bo_vm_fault_idle(struct ttm_buffer_object *bo,
+static vm_fault_t ttm_bo_vm_fault_idle(struct ttm_buffer_object *bo,
 				struct vm_fault *vmf)
 {
-	int ret = 0;
+	vm_fault_t ret = 0;
+	int err = 0;
 
 	if (likely(!bo->moving))
 		goto out_unlock;
@@ -77,8 +78,8 @@ static int ttm_bo_vm_fault_idle(struct ttm_buffer_object *bo,
 	/*
 	 * Ordinary wait.
 	 */
-	ret = dma_fence_wait(bo->moving, true);
-	if (unlikely(ret != 0)) {
+	err = dma_fence_wait(bo->moving, true);
+	if (unlikely(err != 0)) {
 		ret = (ret != -ERESTARTSYS) ? VM_FAULT_SIGBUS :
 			VM_FAULT_NOPAGE;
 		goto out_unlock;
@@ -104,7 +105,7 @@ static unsigned long ttm_bo_io_mem_pfn(struct ttm_buffer_object *bo,
 		+ page_offset;
 }
 
-static int ttm_bo_vm_fault(struct vm_fault *vmf)
+static vm_fault_t ttm_bo_vm_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct ttm_buffer_object *bo = (struct ttm_buffer_object *)
@@ -115,7 +116,8 @@ static int ttm_bo_vm_fault(struct vm_fault *vmf)
 	unsigned long pfn;
 	struct ttm_tt *ttm = NULL;
 	struct page *page;
-	int ret;
+	vm_fault_t ret;
+	int err;
 	int i;
 	unsigned long address = vmf->address;
 	struct ttm_mem_type_manager *man =
@@ -128,9 +130,9 @@ static int ttm_bo_vm_fault(struct vm_fault *vmf)
 	 * for reserve, and if it fails, retry the fault after waiting
 	 * for the buffer to become unreserved.
 	 */
-	ret = ttm_bo_reserve(bo, true, true, NULL);
-	if (unlikely(ret != 0)) {
-		if (ret != -EBUSY)
+	err = ttm_bo_reserve(bo, true, true, NULL);
+	if (unlikely(err != 0)) {
+		if (err != -EBUSY)
 			return VM_FAULT_NOPAGE;
 
 		if (vmf->flags & FAULT_FLAG_ALLOW_RETRY) {
@@ -162,8 +164,8 @@ static int ttm_bo_vm_fault(struct vm_fault *vmf)
 	}
 
 	if (bdev->driver->fault_reserve_notify) {
-		ret = bdev->driver->fault_reserve_notify(bo);
-		switch (ret) {
+		err = bdev->driver->fault_reserve_notify(bo);
+		switch (err) {
 		case 0:
 			break;
 		case -EBUSY:
@@ -191,13 +193,13 @@ static int ttm_bo_vm_fault(struct vm_fault *vmf)
 		goto out_unlock;
 	}
 
-	ret = ttm_mem_io_lock(man, true);
-	if (unlikely(ret != 0)) {
+	err = ttm_mem_io_lock(man, true);
+	if (unlikely(err != 0)) {
 		ret = VM_FAULT_NOPAGE;
 		goto out_unlock;
 	}
-	ret = ttm_mem_io_reserve_vm(bo);
-	if (unlikely(ret != 0)) {
+	err = ttm_mem_io_reserve_vm(bo);
+	if (unlikely(err != 0)) {
 		ret = VM_FAULT_SIGBUS;
 		goto out_io_unlock;
 	}
@@ -265,21 +267,21 @@ static int ttm_bo_vm_fault(struct vm_fault *vmf)
 		}
 
 		if (vma->vm_flags & VM_MIXEDMAP)
-			ret = vm_insert_mixed(&cvma, address,
+			err = vm_insert_mixed(&cvma, address,
 					__pfn_to_pfn_t(pfn, PFN_DEV));
 		else
-			ret = vm_insert_pfn(&cvma, address, pfn);
+			err = vm_insert_pfn(&cvma, address, pfn);
 
 		/*
 		 * Somebody beat us to this PTE or prefaulting to
 		 * an already populated PTE, or prefaulting error.
 		 */
 
-		if (unlikely((ret == -EBUSY) || (ret != 0 && i > 0)))
+		if (unlikely((err == -EBUSY) || (err != 0 && i > 0)))
 			break;
-		else if (unlikely(ret != 0)) {
+		else if (unlikely(err != 0)) {
 			ret =
-			    (ret == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
+			    (err == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
 			goto out_io_unlock;
 		}
 
-- 
2.17.0
