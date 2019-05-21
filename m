Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C83DBC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:54:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6116B21019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:54:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6116B21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3D306B0279; Tue, 21 May 2019 00:54:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA53D6B0278; Tue, 21 May 2019 00:54:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B819C6B027B; Tue, 21 May 2019 00:54:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3026E6B0278
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:54:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n23so28708775edv.9
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:54:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=LyrlYnPqImlXi6EZsUBZqGli+s8YboIZe1+k5D6g4v4=;
        b=hyGt3rA6JOj8Bu5tSBjND3T3ii9sbjGtMPlwr7CRMe6P3q/5EPel+UsDfIJDqCaJAn
         zzUFysAldNViSHghZQJabkzi3AYXn0YYmWoNLIkIbYMkLL4QhRDb/AwPlcMN4Oo9Rlv1
         9rJm06vQqmfoLBPHN8Z/fnio9tgzqGpHD72hC1OFQKQIbwavEulA6MF7T5tyrN/50qSZ
         BUXQF3mJkCRPaDI1UaxpcYqKt87huzRAZOfrSxUUWhqRracHy4Dk40Pv0NpetLg2DaDy
         f2HY0BtNHsrpWIYmK1eG3SyQo+aCm30Pp7eIvs+dNyBYTUaMxmsDS0Kdznw66Jk3Wa3K
         9hyw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAVjYT76H6kBysaj4bfN61HblMrIfb7y1y3Xfhbk98RlDkp0k6IR
	Da4RgMnjWUDtsxhSt4UIBhr82gpNbDq+KEFsQFfRYusec4apxBUNF3h9SAzIkNpdv0jhpajodGD
	a+4TLzSwI5iNuP2THQ0EyJeaLkPjZNccet+lT9Goq3SZ8GTypvxVQZsc0pZT6vhk=
X-Received: by 2002:a05:6402:1256:: with SMTP id l22mr51677036edw.22.1558414445571;
        Mon, 20 May 2019 21:54:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmNiS5OU0JaDX5+kX5X7uejybwtlu1V5Xxd4jUMhE4RUHVr4KOg0m871CptNWG9dEHqpgr
X-Received: by 2002:a05:6402:1256:: with SMTP id l22mr51676819edw.22.1558414443193;
        Mon, 20 May 2019 21:54:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414443; cv=none;
        d=google.com; s=arc-20160816;
        b=nK8hl/AKzTAvL5lq7nttzS1N9enhq4Z2LAEArkcDTlLn+2mVfLqOfvjbTGqww0ItwU
         KwysdwpkOX1d4f/TgDs+GuIu0IDe8gGm1pn09/sO4Bs8qZnlzcqzerhBrD75Bsq7xRQ5
         PVEReqHFBFghymvVcgz/Cy4Se0i3GX2gca+vr6hcaaIQabRhVz4xtd0x+QXfqw3Msf6d
         EoVN55DGlBjl1ZIzt3rYHcTfaEyY8B/r8TJu/VvJmZCnm7aT4T5guxRI6+8l09bOfmxM
         +pLNsDoGwWRpCtsylea1mx27RVuYjV879Y/QFn5WmiATHDN3BEmzgvNQ3CN1DT6JFbVr
         i22Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=LyrlYnPqImlXi6EZsUBZqGli+s8YboIZe1+k5D6g4v4=;
        b=IOgsBCTamciHiUlMlDGSEeZrxaS9QvWyNgz8wUPSJ3jtmMYusBkl5PvyEfOAEHm0H2
         mEPaAJ/je60kC0uSMJE0vV5mD8m7xcW4ewlcjEU247z9h3IzUR/Trks/KjHjLAjtjTZ8
         zfoOfRsW2IodaQ7XkWF5oD55zj7GZRAHgcF59rejDc0v8JFXCDgkPVLdlMlPm/QruZ9T
         QIFFYg5VZsFeBfraEQM6qVbW/AsYEYsmLaSQB4IyXxTe9t8s7ZlYBGlkfmWx1u6eJ1C7
         Xqay86Lqdd26vwqk48a0H4yG6Nnjb34UluuIASvHKrGAdsFREwtX9REopAfoAaqKCf8s
         r7Fg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id 15si2491625ejn.380.2019.05.20.21.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:54:03 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 06:54:02 +0200
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 05:53:24 +0100
From: Davidlohr Bueso <dave@stgolabs.net>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	jglisse@redhat.com,
	ldufour@linux.vnet.ibm.com,
	dave@stgolabs.net,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 13/14] drivers: teach the mm about range locking
Date: Mon, 20 May 2019 21:52:41 -0700
Message-Id: <20190521045242.24378-14-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190521045242.24378-1-dave@stgolabs.net>
References: <20190521045242.24378-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Conversion is straightforward, mmap_sem is used within the
the same function context most of the time. No change in
semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/android/binder_alloc.c                   |  7 ++++---
 drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c |  4 ++--
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c           |  7 ++++---
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c          |  9 +++++----
 drivers/gpu/drm/amd/amdkfd/kfd_events.c          |  5 +++--
 drivers/gpu/drm/i915/i915_gem.c                  |  5 +++--
 drivers/gpu/drm/i915/i915_gem_userptr.c          | 11 +++++++----
 drivers/gpu/drm/nouveau/nouveau_svm.c            | 23 ++++++++++++++---------
 drivers/gpu/drm/radeon/radeon_cs.c               |  5 +++--
 drivers/gpu/drm/radeon/radeon_gem.c              |  8 +++++---
 drivers/gpu/drm/radeon/radeon_mn.c               |  7 ++++---
 drivers/gpu/drm/ttm/ttm_bo_vm.c                  |  4 ++--
 drivers/infiniband/core/umem.c                   |  7 ++++---
 drivers/infiniband/core/umem_odp.c               | 12 +++++++-----
 drivers/infiniband/core/uverbs_main.c            |  5 +++--
 drivers/infiniband/hw/mlx4/mr.c                  |  5 +++--
 drivers/infiniband/hw/qib/qib_user_pages.c       |  7 ++++---
 drivers/infiniband/hw/usnic/usnic_uiom.c         |  5 +++--
 drivers/iommu/amd_iommu_v2.c                     |  4 ++--
 drivers/iommu/intel-svm.c                        |  4 ++--
 drivers/media/v4l2-core/videobuf-core.c          |  5 +++--
 drivers/media/v4l2-core/videobuf-dma-contig.c    |  5 +++--
 drivers/media/v4l2-core/videobuf-dma-sg.c        |  5 +++--
 drivers/misc/cxl/cxllib.c                        |  5 +++--
 drivers/misc/cxl/fault.c                         |  5 +++--
 drivers/misc/sgi-gru/grufault.c                  | 20 ++++++++++++--------
 drivers/misc/sgi-gru/grufile.c                   |  5 +++--
 drivers/misc/sgi-gru/grukservices.c              |  4 +++-
 drivers/misc/sgi-gru/grumain.c                   |  6 ++++--
 drivers/misc/sgi-gru/grutables.h                 |  5 ++++-
 drivers/oprofile/buffer_sync.c                   | 12 +++++++-----
 drivers/staging/kpc2000/kpc_dma/fileops.c        |  5 +++--
 drivers/tee/optee/call.c                         |  5 +++--
 drivers/vfio/vfio_iommu_type1.c                  |  9 +++++----
 drivers/xen/gntdev.c                             |  5 +++--
 drivers/xen/privcmd.c                            | 17 ++++++++++-------
 include/linux/hmm.h                              |  7 ++++---
 37 files changed, 160 insertions(+), 109 deletions(-)

diff --git a/drivers/android/binder_alloc.c b/drivers/android/binder_alloc.c
index bb929eb87116..0b9cd9becd76 100644
--- a/drivers/android/binder_alloc.c
+++ b/drivers/android/binder_alloc.c
@@ -195,6 +195,7 @@ static int binder_update_page_range(struct binder_alloc *alloc, int allocate,
 	struct vm_area_struct *vma = NULL;
 	struct mm_struct *mm = NULL;
 	bool need_mm = false;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	binder_alloc_debug(BINDER_DEBUG_BUFFER_ALLOC,
 		     "%d: %s pages %pK-%pK\n", alloc->pid,
@@ -220,7 +221,7 @@ static int binder_update_page_range(struct binder_alloc *alloc, int allocate,
 		mm = alloc->vma_vm_mm;
 
 	if (mm) {
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		vma = alloc->vma;
 	}
 
@@ -279,7 +280,7 @@ static int binder_update_page_range(struct binder_alloc *alloc, int allocate,
 		/* vm_insert_page does not seem to increment the refcount */
 	}
 	if (mm) {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		mmput(mm);
 	}
 	return 0;
@@ -310,7 +311,7 @@ static int binder_update_page_range(struct binder_alloc *alloc, int allocate,
 	}
 err_no_vma:
 	if (mm) {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		mmput(mm);
 	}
 	return vma ? -ENOMEM : -ESRCH;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
index 123eb0d7e2e9..28ddd42b27be 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
@@ -1348,9 +1348,9 @@ int amdgpu_amdkfd_gpuvm_map_memory_to_gpu(
 	 * concurrently and the queues are actually stopped
 	 */
 	if (amdgpu_ttm_tt_get_usermm(bo->tbo.ttm)) {
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm, &mmrange);
 		is_invalid_userptr = atomic_read(&mem->invalid);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm, &mmrange);
 	}
 
 	mutex_lock(&mem->lock);
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index 58ed401c5996..d002df91c7b9 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -376,13 +376,14 @@ static const struct mmu_notifier_ops amdgpu_mn_ops[] = {
 struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device *adev,
 				enum amdgpu_mn_type type)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	struct mm_struct *mm = current->mm;
 	struct amdgpu_mn *amn;
 	unsigned long key = AMDGPU_MN_KEY(mm, type);
 	int r;
 
 	mutex_lock(&adev->mn_lock);
-	if (down_write_killable(&mm->mmap_sem)) {
+	if (mm_write_lock_killable(mm, &mmrange)) {
 		mutex_unlock(&adev->mn_lock);
 		return ERR_PTR(-EINTR);
 	}
@@ -413,13 +414,13 @@ struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device *adev,
 	hash_add(adev->mn_hash, &amn->node, AMDGPU_MN_KEY(mm, type));
 
 release_locks:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	mutex_unlock(&adev->mn_lock);
 
 	return amn;
 
 free_amn:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	mutex_unlock(&adev->mn_lock);
 	kfree(amn);
 
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index d81101ac57eb..86e5a7549031 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -735,6 +735,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 	unsigned int flags = 0;
 	unsigned pinned = 0;
 	int r;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!mm) /* Happens during process shutdown */
 		return -ESRCH;
@@ -742,7 +743,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 	if (!(gtt->userflags & AMDGPU_GEM_USERPTR_READONLY))
 		flags |= FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	if (gtt->userflags & AMDGPU_GEM_USERPTR_ANONONLY) {
 		/*
@@ -754,7 +755,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 
 		vma = find_vma(mm, gtt->userptr);
 		if (!vma || vma->vm_file || vma->vm_end < end) {
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 			return -EPERM;
 		}
 	}
@@ -789,12 +790,12 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 
 	} while (pinned < ttm->num_pages);
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return 0;
 
 release_pages:
 	release_pages(pages, pinned);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return r;
 }
 
diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_events.c b/drivers/gpu/drm/amd/amdkfd/kfd_events.c
index d674d4b3340f..41eedbb2e120 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_events.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_events.c
@@ -887,6 +887,7 @@ void kfd_signal_iommu_event(struct kfd_dev *dev, unsigned int pasid,
 	 */
 	struct kfd_process *p = kfd_lookup_process_by_pasid(pasid);
 	struct mm_struct *mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!p)
 		return; /* Presumably process exited. */
@@ -902,7 +903,7 @@ void kfd_signal_iommu_event(struct kfd_dev *dev, unsigned int pasid,
 
 	memset(&memory_exception_data, 0, sizeof(memory_exception_data));
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_vma(mm, address);
 
 	memory_exception_data.gpu_id = dev->id;
@@ -925,7 +926,7 @@ void kfd_signal_iommu_event(struct kfd_dev *dev, unsigned int pasid,
 			memory_exception_data.failure.NoExecute = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	mmput(mm);
 
 	pr_debug("notpresent %d, noexecute %d, readonly %d\n",
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index ad01c92aaf74..320516346bbf 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -1644,6 +1644,7 @@ int
 i915_gem_mmap_ioctl(struct drm_device *dev, void *data,
 		    struct drm_file *file)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	struct drm_i915_gem_mmap *args = data;
 	struct drm_i915_gem_object *obj;
 	unsigned long addr;
@@ -1681,7 +1682,7 @@ i915_gem_mmap_ioctl(struct drm_device *dev, void *data,
 		struct mm_struct *mm = current->mm;
 		struct vm_area_struct *vma;
 
-		if (down_write_killable(&mm->mmap_sem)) {
+		if (mm_write_lock_killable(mm, &mmrange)) {
 			addr = -EINTR;
 			goto err;
 		}
@@ -1691,7 +1692,7 @@ i915_gem_mmap_ioctl(struct drm_device *dev, void *data,
 				pgprot_writecombine(vm_get_page_prot(vma->vm_flags));
 		else
 			addr = -ENOMEM;
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 		if (IS_ERR_VALUE(addr))
 			goto err;
 
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 67f718015e42..0bba318098bb 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -231,6 +231,7 @@ i915_mmu_notifier_find(struct i915_mm_struct *mm)
 {
 	struct i915_mmu_notifier *mn;
 	int err = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	mn = mm->mn;
 	if (mn)
@@ -240,7 +241,7 @@ i915_mmu_notifier_find(struct i915_mm_struct *mm)
 	if (IS_ERR(mn))
 		err = PTR_ERR(mn);
 
-	down_write(&mm->mm->mmap_sem);
+	mm_write_lock(mm->mm, &mmrange);
 	mutex_lock(&mm->i915->mm_lock);
 	if (mm->mn == NULL && !err) {
 		/* Protected by mmap_sem (write-lock) */
@@ -257,7 +258,7 @@ i915_mmu_notifier_find(struct i915_mm_struct *mm)
 		err = 0;
 	}
 	mutex_unlock(&mm->i915->mm_lock);
-	up_write(&mm->mm->mmap_sem);
+	mm_write_unlock(mm->mm, &mmrange);
 
 	if (mn && !IS_ERR(mn))
 		kfree(mn);
@@ -504,7 +505,9 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 
 		ret = -EFAULT;
 		if (mmget_not_zero(mm)) {
-			down_read(&mm->mmap_sem);
+			DEFINE_RANGE_LOCK_FULL(mmrange);
+
+			mm_read_lock(mm, &mmrange);
 			while (pinned < npages) {
 				ret = get_user_pages_remote
 					(work->task, mm,
@@ -517,7 +520,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 
 				pinned += ret;
 			}
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 			mmput(mm);
 		}
 	}
diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 93ed43c413f0..1df4227c0967 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -171,7 +171,7 @@ nouveau_svmm_bind(struct drm_device *dev, void *data,
 	 */
 
 	mm = get_task_mm(current);
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	for (addr = args->va_start, end = args->va_start + size; addr < end;) {
 		struct vm_area_struct *vma;
@@ -194,7 +194,7 @@ nouveau_svmm_bind(struct drm_device *dev, void *data,
 	 */
 	args->result = 0;
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	mmput(mm);
 
 	return 0;
@@ -307,6 +307,7 @@ nouveau_svmm_init(struct drm_device *dev, void *data,
 	struct nouveau_svmm *svmm;
 	struct drm_nouveau_svm_init *args = data;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* Allocate tracking for SVM-enabled VMM. */
 	if (!(svmm = kzalloc(sizeof(*svmm), GFP_KERNEL)))
@@ -339,14 +340,14 @@ nouveau_svmm_init(struct drm_device *dev, void *data,
 
 	/* Enable HMM mirroring of CPU address-space to VMM. */
 	svmm->mm = get_task_mm(current);
-	down_write(&svmm->mm->mmap_sem);
+	mm_write_lock(svmm->mm, &mmrange);
 	svmm->mirror.ops = &nouveau_svmm;
 	ret = hmm_mirror_register(&svmm->mirror, svmm->mm);
 	if (ret == 0) {
 		cli->svm.svmm = svmm;
 		cli->svm.cli = cli;
 	}
-	up_write(&svmm->mm->mmap_sem);
+	mm_write_unlock(svmm->mm, &mmrange);
 	mmput(svmm->mm);
 
 done:
@@ -548,6 +549,8 @@ nouveau_svm_fault(struct nvif_notify *notify)
 	args.i.p.version = 0;
 
 	for (fi = 0; fn = fi + 1, fi < buffer->fault_nr; fi = fn) {
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
 		/* Cancel any faults from non-SVM channels. */
 		if (!(svmm = buffer->fault[fi]->svmm)) {
 			nouveau_svm_fault_cancel_fault(svm, buffer->fault[fi]);
@@ -570,11 +573,11 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		/* Intersect fault window with the CPU VMA, cancelling
 		 * the fault if the address is invalid.
 		 */
-		down_read(&svmm->mm->mmap_sem);
+		mm_read_lock(svmm->mm, &mmrange);
 		vma = find_vma_intersection(svmm->mm, start, limit);
 		if (!vma) {
 			SVMM_ERR(svmm, "wndw %016llx-%016llx", start, limit);
-			up_read(&svmm->mm->mmap_sem);
+			mm_read_unlock(svmm->mm, &mmrange);
 			nouveau_svm_fault_cancel_fault(svm, buffer->fault[fi]);
 			continue;
 		}
@@ -584,7 +587,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
 
 		if (buffer->fault[fi]->addr != start) {
 			SVMM_ERR(svmm, "addr %016llx", buffer->fault[fi]->addr);
-			up_read(&svmm->mm->mmap_sem);
+			mm_read_unlock(svmm->mm, &mmrange);
 			nouveau_svm_fault_cancel_fault(svm, buffer->fault[fi]);
 			continue;
 		}
@@ -596,6 +599,8 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		args.i.p.page = PAGE_SHIFT;
 		args.i.p.addr = start;
 		for (fn = fi, pi = 0;;) {
+			DEFINE_RANGE_LOCK_FULL(mmrange);
+
 			/* Determine required permissions based on GPU fault
 			 * access flags.
 			 *XXX: atomic?
@@ -649,7 +654,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		range.values = nouveau_svm_pfn_values;
 		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
 again:
-		ret = hmm_vma_fault(&range, true);
+		ret = hmm_vma_fault(&range, true, &mmrange);
 		if (ret == 0) {
 			mutex_lock(&svmm->mutex);
 			if (!hmm_vma_range_done(&range)) {
@@ -667,7 +672,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
 			svmm->vmm->vmm.object.client->super = false;
 			mutex_unlock(&svmm->mutex);
 		}
-		up_read(&svmm->mm->mmap_sem);
+		mm_read_unlock(svmm->mm, &mmrange);
 
 		/* Cancel any faults in the window whose pages didn't manage
 		 * to keep their valid bit, or stay writeable when required.
diff --git a/drivers/gpu/drm/radeon/radeon_cs.c b/drivers/gpu/drm/radeon/radeon_cs.c
index f43305329939..8015a1b7f6ef 100644
--- a/drivers/gpu/drm/radeon/radeon_cs.c
+++ b/drivers/gpu/drm/radeon/radeon_cs.c
@@ -79,6 +79,7 @@ static int radeon_cs_parser_relocs(struct radeon_cs_parser *p)
 	unsigned i;
 	bool need_mmap_lock = false;
 	int r;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (p->chunk_relocs == NULL) {
 		return 0;
@@ -190,12 +191,12 @@ static int radeon_cs_parser_relocs(struct radeon_cs_parser *p)
 		p->vm_bos = radeon_vm_get_bos(p->rdev, p->ib.vm,
 					      &p->validated);
 	if (need_mmap_lock)
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 
 	r = radeon_bo_list_validate(p->rdev, &p->ticket, &p->validated, p->ring);
 
 	if (need_mmap_lock)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 
 	return r;
 }
diff --git a/drivers/gpu/drm/radeon/radeon_gem.c b/drivers/gpu/drm/radeon/radeon_gem.c
index 44617dec8183..fa6ba354f59d 100644
--- a/drivers/gpu/drm/radeon/radeon_gem.c
+++ b/drivers/gpu/drm/radeon/radeon_gem.c
@@ -334,17 +334,19 @@ int radeon_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	}
 
 	if (args->flags & RADEON_GEM_USERPTR_VALIDATE) {
-		down_read(&current->mm->mmap_sem);
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
+		mm_read_lock(current->mm, &mmrange);
 		r = radeon_bo_reserve(bo, true);
 		if (r) {
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm, &mmrange);
 			goto release_object;
 		}
 
 		radeon_ttm_placement_from_domain(bo, RADEON_GEM_DOMAIN_GTT);
 		r = ttm_bo_validate(&bo->tbo, &bo->placement, &ctx);
 		radeon_bo_unreserve(bo);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 		if (r)
 			goto release_object;
 	}
diff --git a/drivers/gpu/drm/radeon/radeon_mn.c b/drivers/gpu/drm/radeon/radeon_mn.c
index c9bd1278f573..a4fc3fadb8d5 100644
--- a/drivers/gpu/drm/radeon/radeon_mn.c
+++ b/drivers/gpu/drm/radeon/radeon_mn.c
@@ -197,11 +197,12 @@ static const struct mmu_notifier_ops radeon_mn_ops = {
  */
 static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	struct mm_struct *mm = current->mm;
 	struct radeon_mn *rmn;
 	int r;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return ERR_PTR(-EINTR);
 
 	mutex_lock(&rdev->mn_lock);
@@ -230,13 +231,13 @@ static struct radeon_mn *radeon_mn_get(struct radeon_device *rdev)
 
 release_locks:
 	mutex_unlock(&rdev->mn_lock);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	return rmn;
 
 free_rmn:
 	mutex_unlock(&rdev->mn_lock);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	kfree(rmn);
 
 	return ERR_PTR(r);
diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index 6dacff49c1cc..ba3eda092010 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -69,7 +69,7 @@ static vm_fault_t ttm_bo_vm_fault_idle(struct ttm_buffer_object *bo,
 			goto out_unlock;
 
 		ttm_bo_get(bo);
-		up_read(&vmf->vma->vm_mm->mmap_sem);
+		mm_read_unlock(vmf->vma->vm_mm, vmf->lockrange);
 		(void) dma_fence_wait(bo->moving, true);
 		reservation_object_unlock(bo->resv);
 		ttm_bo_put(bo);
@@ -135,7 +135,7 @@ static vm_fault_t ttm_bo_vm_fault(struct vm_fault *vmf)
 		if (vmf->flags & FAULT_FLAG_ALLOW_RETRY) {
 			if (!(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
 				ttm_bo_get(bo);
-				up_read(&vmf->vma->vm_mm->mmap_sem);
+				mm_read_unlock(vmf->vma->vm_mm, vmf->lockrange);
 				(void) ttm_bo_wait_unreserved(bo);
 				ttm_bo_put(bo);
 			}
diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index e7ea819fcb11..7356911bcf9e 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -207,6 +207,7 @@ struct ib_umem *ib_umem_get(struct ib_udata *udata, unsigned long addr,
 	unsigned long dma_attrs = 0;
 	struct scatterlist *sg;
 	unsigned int gup_flags = FOLL_WRITE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!udata)
 		return ERR_PTR(-EIO);
@@ -294,14 +295,14 @@ struct ib_umem *ib_umem_get(struct ib_udata *udata, unsigned long addr,
 	sg = umem->sg_head.sgl;
 
 	while (npages) {
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		ret = get_user_pages(cur_base,
 				     min_t(unsigned long, npages,
 					   PAGE_SIZE / sizeof (struct page *)),
 				     gup_flags | FOLL_LONGTERM,
 				     page_list, NULL);
 		if (ret < 0) {
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 			goto umem_release;
 		}
 
@@ -312,7 +313,7 @@ struct ib_umem *ib_umem_get(struct ib_udata *udata, unsigned long addr,
 			dma_get_max_seg_size(context->device->dma_device),
 			&umem->sg_nents);
 
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	}
 
 	sg_mark_end(sg);
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 62b5de027dd1..a21e575e90d0 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -408,16 +408,17 @@ int ib_umem_odp_get(struct ib_umem_odp *umem_odp, int access)
 	if (access & IB_ACCESS_HUGETLB) {
 		struct vm_area_struct *vma;
 		struct hstate *h;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		vma = find_vma(mm, ib_umem_start(umem));
 		if (!vma || !is_vm_hugetlb_page(vma)) {
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 			return -EINVAL;
 		}
 		h = hstate_vma(vma);
 		umem->page_shift = huge_page_shift(h);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	}
 
 	mutex_init(&umem_odp->umem_mutex);
@@ -589,6 +590,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 	int j, k, ret = 0, start_idx, npages = 0, page_shift;
 	unsigned int flags = 0;
 	phys_addr_t p = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (access_mask == 0)
 		return -EINVAL;
@@ -629,7 +631,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 				(bcnt + BIT(page_shift) - 1) >> page_shift,
 				PAGE_SIZE / sizeof(struct page *));
 
-		down_read(&owning_mm->mmap_sem);
+		mm_read_lock(owning_mm, &mmrange);
 		/*
 		 * Note: this might result in redundent page getting. We can
 		 * avoid this by checking dma_list to be 0 before calling
@@ -640,7 +642,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 		npages = get_user_pages_remote(owning_process, owning_mm,
 				user_virt, gup_num_pages,
 			        flags, local_page_list, NULL, NULL, NULL);
-		up_read(&owning_mm->mmap_sem);
+		mm_read_unlock(owning_mm, &mmrange);
 
 		if (npages < 0) {
 			if (npages != -EAGAIN)
diff --git a/drivers/infiniband/core/uverbs_main.c b/drivers/infiniband/core/uverbs_main.c
index 84a5e9a6d483..dcc94e5d617e 100644
--- a/drivers/infiniband/core/uverbs_main.c
+++ b/drivers/infiniband/core/uverbs_main.c
@@ -967,6 +967,7 @@ EXPORT_SYMBOL(rdma_user_mmap_io);
 void uverbs_user_mmap_disassociate(struct ib_uverbs_file *ufile)
 {
 	struct rdma_umap_priv *priv, *next_priv;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	lockdep_assert_held(&ufile->hw_destroy_rwsem);
 
@@ -999,7 +1000,7 @@ void uverbs_user_mmap_disassociate(struct ib_uverbs_file *ufile)
 		 * at a time to get the lock ordering right. Typically there
 		 * will only be one mm, so no big deal.
 		 */
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		if (!mmget_still_valid(mm))
 			goto skip_mm;
 		mutex_lock(&ufile->umap_lock);
@@ -1016,7 +1017,7 @@ void uverbs_user_mmap_disassociate(struct ib_uverbs_file *ufile)
 		}
 		mutex_unlock(&ufile->umap_lock);
 	skip_mm:
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		mmput(mm);
 	}
 }
diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
index 355205a28544..b67ada7e86c2 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -379,8 +379,9 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
 	 */
 	if (!ib_access_writable(access_flags)) {
 		struct vm_area_struct *vma;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		/*
 		 * FIXME: Ideally this would iterate over all the vmas that
 		 * cover the memory, but for now it requires a single vma to
@@ -395,7 +396,7 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
 			access_flags |= IB_ACCESS_LOCAL_WRITE;
 		}
 
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 	}
 
 	return ib_umem_get(udata, start, length, access_flags, 0);
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index f712fb7fa82f..0fd47aa11b28 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -103,6 +103,7 @@ int qib_get_user_pages(unsigned long start_page, size_t num_pages,
 	unsigned long locked, lock_limit;
 	size_t got;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 	locked = atomic64_add_return(num_pages, &current->mm->pinned_vm);
@@ -112,18 +113,18 @@ int qib_get_user_pages(unsigned long start_page, size_t num_pages,
 		goto bail;
 	}
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	for (got = 0; got < num_pages; got += ret) {
 		ret = get_user_pages(start_page + got * PAGE_SIZE,
 				     num_pages - got,
 				     FOLL_LONGTERM | FOLL_WRITE | FOLL_FORCE,
 				     p + got, NULL);
 		if (ret < 0) {
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm, &mmrange);
 			goto bail_release;
 		}
 	}
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	return 0;
 bail_release:
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index e312f522a66d..851aec8ecf41 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -102,6 +102,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	dma_addr_t pa;
 	unsigned int gup_flags;
 	struct mm_struct *mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * If the combination of the addr and size requested for this memory
@@ -125,7 +126,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	npages = PAGE_ALIGN(size + (addr & ~PAGE_MASK)) >> PAGE_SHIFT;
 
 	uiomr->owning_mm = mm = current->mm;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	locked = atomic64_add_return(npages, &current->mm->pinned_vm);
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
@@ -189,7 +190,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	} else
 		mmgrab(uiomr->owning_mm);
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	free_page((unsigned long) page_list);
 	return ret;
 }
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 67c609b26249..7073c2cd6915 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -500,7 +500,7 @@ static void do_fault(struct work_struct *work)
 		flags |= FAULT_FLAG_WRITE;
 	flags |= FAULT_FLAG_REMOTE;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_extend_vma(mm, address);
 	if (!vma || address < vma->vm_start)
 		/* failed to get a vma in the right range */
@@ -512,7 +512,7 @@ static void do_fault(struct work_struct *work)
 
 	ret = handle_mm_fault(vma, address, flags, &mmrange);
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	if (ret & VM_FAULT_ERROR)
 		/* failed to service fault */
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index 74d535ea6a03..192a2f8f824c 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -595,7 +595,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 		if (!is_canonical_address(address))
 			goto bad_req;
 
-		down_read(&svm->mm->mmap_sem);
+		mm_read_lock(svm->mm, &mmrange);
 		vma = find_extend_vma(svm->mm, address);
 		if (!vma || address < vma->vm_start)
 			goto invalid;
@@ -610,7 +610,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 
 		result = QI_RESP_SUCCESS;
 	invalid:
-		up_read(&svm->mm->mmap_sem);
+		mm_read_unlock(svm->mm, &mmrange);
 		mmput(svm->mm);
 	bad_req:
 		/* Accounting for major/minor faults? */
diff --git a/drivers/media/v4l2-core/videobuf-core.c b/drivers/media/v4l2-core/videobuf-core.c
index bf7dfb2a34af..a6b7d890d2cb 100644
--- a/drivers/media/v4l2-core/videobuf-core.c
+++ b/drivers/media/v4l2-core/videobuf-core.c
@@ -533,11 +533,12 @@ int videobuf_qbuf(struct videobuf_queue *q, struct v4l2_buffer *b)
 	enum v4l2_field field;
 	unsigned long flags = 0;
 	int retval;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	MAGIC_CHECK(q->int_ops->magic, MAGIC_QTYPE_OPS);
 
 	if (b->memory == V4L2_MEMORY_MMAP)
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 
 	videobuf_queue_lock(q);
 	retval = -EBUSY;
@@ -624,7 +625,7 @@ int videobuf_qbuf(struct videobuf_queue *q, struct v4l2_buffer *b)
 	videobuf_queue_unlock(q);
 
 	if (b->memory == V4L2_MEMORY_MMAP)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 
 	return retval;
 }
diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
index e1bf50df4c70..04ff0c7c7ebc 100644
--- a/drivers/media/v4l2-core/videobuf-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
@@ -166,12 +166,13 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 	unsigned long pages_done, user_address;
 	unsigned int offset;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	offset = vb->baddr & ~PAGE_MASK;
 	mem->size = PAGE_ALIGN(vb->size + offset);
 	ret = -EINVAL;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	vma = find_vma(mm, vb->baddr);
 	if (!vma)
@@ -203,7 +204,7 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 	}
 
 out_up:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	return ret;
 }
diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index 870a2a526e0b..488d484acf6c 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -202,10 +202,11 @@ static int videobuf_dma_init_user(struct videobuf_dmabuf *dma, int direction,
 			   unsigned long data, unsigned long size)
 {
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	ret = videobuf_dma_init_user_locked(dma, direction, data, size);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	return ret;
 }
diff --git a/drivers/misc/cxl/cxllib.c b/drivers/misc/cxl/cxllib.c
index 5a3f91255258..c287f47d5e2c 100644
--- a/drivers/misc/cxl/cxllib.c
+++ b/drivers/misc/cxl/cxllib.c
@@ -210,8 +210,9 @@ static int get_vma_info(struct mm_struct *mm, u64 addr,
 {
 	struct vm_area_struct *vma = NULL;
 	int rc = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	vma = find_vma(mm, addr);
 	if (!vma) {
@@ -222,7 +223,7 @@ static int get_vma_info(struct mm_struct *mm, u64 addr,
 	*vma_start = vma->vm_start;
 	*vma_end = vma->vm_end;
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return rc;
 }
 
diff --git a/drivers/misc/cxl/fault.c b/drivers/misc/cxl/fault.c
index a4d17a5a9763..b97950440ee8 100644
--- a/drivers/misc/cxl/fault.c
+++ b/drivers/misc/cxl/fault.c
@@ -317,6 +317,7 @@ static void cxl_prefault_vma(struct cxl_context *ctx)
 	struct vm_area_struct *vma;
 	int rc;
 	struct mm_struct *mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	mm = get_mem_context(ctx);
 	if (mm == NULL) {
@@ -325,7 +326,7 @@ static void cxl_prefault_vma(struct cxl_context *ctx)
 		return;
 	}
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		for (ea = vma->vm_start; ea < vma->vm_end;
 				ea = next_segment(ea, slb.vsid)) {
@@ -340,7 +341,7 @@ static void cxl_prefault_vma(struct cxl_context *ctx)
 			last_esid = slb.esid;
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	mmput(mm);
 }
diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index 2ec5808ba464..a89d541c236e 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -81,15 +81,16 @@ static struct gru_thread_state *gru_find_lock_gts(unsigned long vaddr)
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	struct gru_thread_state *gts = NULL;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = gru_find_vma(vaddr);
 	if (vma)
 		gts = gru_find_thread_state(vma, TSID(vaddr, vma));
 	if (gts)
 		mutex_lock(&gts->ts_ctxlock);
 	else
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	return gts;
 }
 
@@ -98,8 +99,9 @@ static struct gru_thread_state *gru_alloc_locked_gts(unsigned long vaddr)
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	struct gru_thread_state *gts = ERR_PTR(-EINVAL);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	vma = gru_find_vma(vaddr);
 	if (!vma)
 		goto err;
@@ -108,11 +110,11 @@ static struct gru_thread_state *gru_alloc_locked_gts(unsigned long vaddr)
 	if (IS_ERR(gts))
 		goto err;
 	mutex_lock(&gts->ts_ctxlock);
-	downgrade_write(&mm->mmap_sem);
+	mm_downgrade_write(mm, &mmrange);
 	return gts;
 
 err:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return gts;
 }
 
@@ -122,7 +124,7 @@ static struct gru_thread_state *gru_alloc_locked_gts(unsigned long vaddr)
 static void gru_unlock_gts(struct gru_thread_state *gts)
 {
 	mutex_unlock(&gts->ts_ctxlock);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, gts->mmrange);
 }
 
 /*
@@ -563,6 +565,8 @@ static irqreturn_t gru_intr(int chiplet, int blade)
 	}
 
 	for_each_cbr_in_tfm(cbrnum, imap.fault_bits) {
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
 		STAT(intr_tfh);
 		tfh = get_tfh_by_index(gru, cbrnum);
 		prefetchw(tfh);	/* Helps on hdw, required for emulator */
@@ -588,9 +592,9 @@ static irqreturn_t gru_intr(int chiplet, int blade)
 		 */
 		gts->ustats.fmm_tlbmiss++;
 		if (!gts->ts_force_cch_reload &&
-					down_read_trylock(&gts->ts_mm->mmap_sem)) {
+					mm_read_trylock(gts->ts_mm, &mmrange)) {
 			gru_try_dropin(gru, gts, tfh, NULL);
-			up_read(&gts->ts_mm->mmap_sem);
+			mm_read_unlock(gts->ts_mm, &mmrange);
 		} else {
 			tfh_user_polling_mode(tfh);
 			STAT(intr_mm_lock_failed);
diff --git a/drivers/misc/sgi-gru/grufile.c b/drivers/misc/sgi-gru/grufile.c
index 104a05f6b738..1403a4f73cbd 100644
--- a/drivers/misc/sgi-gru/grufile.c
+++ b/drivers/misc/sgi-gru/grufile.c
@@ -136,6 +136,7 @@ static int gru_create_new_context(unsigned long arg)
 	struct vm_area_struct *vma;
 	struct gru_vma_data *vdata;
 	int ret = -EINVAL;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (copy_from_user(&req, (void __user *)arg, sizeof(req)))
 		return -EFAULT;
@@ -148,7 +149,7 @@ static int gru_create_new_context(unsigned long arg)
 	if (!(req.options & GRU_OPT_MISS_MASK))
 		req.options |= GRU_OPT_MISS_FMM_INTR;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &mmrange);
 	vma = gru_find_vma(req.gseg);
 	if (vma) {
 		vdata = vma->vm_private_data;
@@ -159,7 +160,7 @@ static int gru_create_new_context(unsigned long arg)
 		vdata->vd_tlb_preload_count = req.tlb_preload_count;
 		ret = 0;
 	}
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 
 	return ret;
 }
diff --git a/drivers/misc/sgi-gru/grukservices.c b/drivers/misc/sgi-gru/grukservices.c
index 4b23d586fc3f..ceed48ecbd15 100644
--- a/drivers/misc/sgi-gru/grukservices.c
+++ b/drivers/misc/sgi-gru/grukservices.c
@@ -178,7 +178,9 @@ static void gru_load_kernel_context(struct gru_blade_state *bs, int blade_id)
 		kgts->ts_dsr_au_count = GRU_DS_BYTES_TO_AU(
 			GRU_NUM_KERNEL_DSR_BYTES * ncpus +
 				bs->bs_async_dsr_bytes);
-		while (!gru_assign_gru_context(kgts)) {
+
+		/*** BROKEN mmrange, we don't care about gru (for now) */
+		while (!gru_assign_gru_context(kgts, NULL)) {
 			msleep(1);
 			gru_steal_context(kgts);
 		}
diff --git a/drivers/misc/sgi-gru/grumain.c b/drivers/misc/sgi-gru/grumain.c
index ab174f28e3be..d33d94cc35e0 100644
--- a/drivers/misc/sgi-gru/grumain.c
+++ b/drivers/misc/sgi-gru/grumain.c
@@ -866,7 +866,8 @@ static int gru_assign_context_number(struct gru_state *gru)
 /*
  * Scan the GRUs on the local blade & assign a GRU context.
  */
-struct gru_state *gru_assign_gru_context(struct gru_thread_state *gts)
+struct gru_state *gru_assign_gru_context(struct gru_thread_state *gts,
+					 struct range_lock *mmrange)
 {
 	struct gru_state *gru, *grux;
 	int i, max_active_contexts;
@@ -902,6 +903,7 @@ struct gru_state *gru_assign_gru_context(struct gru_thread_state *gts)
 		gts->ts_blade = gru->gs_blade_id;
 		gts->ts_ctxnum = gru_assign_context_number(gru);
 		atomic_inc(&gts->ts_refcnt);
+		gts->mmrange = mmrange;
 		gru->gs_gts[gts->ts_ctxnum] = gts;
 		spin_unlock(&gru->gs_lock);
 
@@ -951,7 +953,7 @@ vm_fault_t gru_fault(struct vm_fault *vmf)
 
 	if (!gts->ts_gru) {
 		STAT(load_user_context);
-		if (!gru_assign_gru_context(gts)) {
+		if (!gru_assign_gru_context(gts, vmf->lockrange)) {
 			preempt_enable();
 			mutex_unlock(&gts->ts_ctxlock);
 			set_current_state(TASK_INTERRUPTIBLE);
diff --git a/drivers/misc/sgi-gru/grutables.h b/drivers/misc/sgi-gru/grutables.h
index 3e041b6f7a68..a4c75178ad46 100644
--- a/drivers/misc/sgi-gru/grutables.h
+++ b/drivers/misc/sgi-gru/grutables.h
@@ -389,6 +389,8 @@ struct gru_thread_state {
 	struct gru_gseg_statistics ustats;	/* User statistics */
 	unsigned long		ts_gdata[0];	/* save area for GRU data (CB,
 						   DS, CBE) */
+	struct range_lock       *mmrange;       /* for faulting */
+
 };
 
 /*
@@ -633,7 +635,8 @@ extern struct gru_thread_state *gru_find_thread_state(struct vm_area_struct
 				*vma, int tsid);
 extern struct gru_thread_state *gru_alloc_thread_state(struct vm_area_struct
 				*vma, int tsid);
-extern struct gru_state *gru_assign_gru_context(struct gru_thread_state *gts);
+extern struct gru_state *gru_assign_gru_context(struct gru_thread_state *gts,
+						struct range_lock *mmrange);
 extern void gru_load_context(struct gru_thread_state *gts);
 extern void gru_steal_context(struct gru_thread_state *gts);
 extern void gru_unload_context(struct gru_thread_state *gts, int savestate);
diff --git a/drivers/oprofile/buffer_sync.c b/drivers/oprofile/buffer_sync.c
index ac27f3d3fbb4..33a36b97f8a5 100644
--- a/drivers/oprofile/buffer_sync.c
+++ b/drivers/oprofile/buffer_sync.c
@@ -90,12 +90,13 @@ munmap_notify(struct notifier_block *self, unsigned long val, void *data)
 	unsigned long addr = (unsigned long)data;
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *mpnt;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	mpnt = find_vma(mm, addr);
 	if (mpnt && mpnt->vm_file && (mpnt->vm_flags & VM_EXEC)) {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		/* To avoid latency problems, we only process the current CPU,
 		 * hoping that most samples for the task are on this CPU
 		 */
@@ -103,7 +104,7 @@ munmap_notify(struct notifier_block *self, unsigned long val, void *data)
 		return 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return 0;
 }
 
@@ -255,8 +256,9 @@ lookup_dcookie(struct mm_struct *mm, unsigned long addr, off_t *offset)
 {
 	unsigned long cookie = NO_COOKIE;
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
 
 		if (addr < vma->vm_start || addr >= vma->vm_end)
@@ -276,7 +278,7 @@ lookup_dcookie(struct mm_struct *mm, unsigned long addr, off_t *offset)
 
 	if (!vma)
 		cookie = INVALID_COOKIE;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return cookie;
 }
diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
index 5741d2b49a7d..9b1523a0e7bd 100644
--- a/drivers/staging/kpc2000/kpc_dma/fileops.c
+++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
@@ -50,6 +50,7 @@ int  kpc_dma_transfer(struct dev_private_data *priv, struct kiocb *kcb, unsigned
 	u64 card_addr;
 	u64 dma_addr;
 	u64 user_ctl;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	
 	BUG_ON(priv == NULL);
 	ldev = priv->ldev;
@@ -81,9 +82,9 @@ int  kpc_dma_transfer(struct dev_private_data *priv, struct kiocb *kcb, unsigned
 	}
 	
 	// Lock the user buffer pages in memory, and hold on to the page pointers (for the sglist)
-	down_read(&current->mm->mmap_sem);      /*  get memory map semaphore */
+	mm_read_lock(current->mm, &mmrange);      /*  get memory map semaphore */
 	rv = get_user_pages(iov_base, acd->page_count, FOLL_TOUCH | FOLL_WRITE | FOLL_GET, acd->user_pages, NULL);
-	up_read(&current->mm->mmap_sem);        /*  release the semaphore */
+	mm_read_unlock(current->mm, &mmrange);        /*  release the semaphore */
 	if (rv != acd->page_count){
 		dev_err(&priv->ldev->pldev->dev, "Couldn't get_user_pages (%ld)\n", rv);
 		goto err_get_user_pages;
diff --git a/drivers/tee/optee/call.c b/drivers/tee/optee/call.c
index a5afbe6dee68..488a08e17a93 100644
--- a/drivers/tee/optee/call.c
+++ b/drivers/tee/optee/call.c
@@ -561,11 +561,12 @@ static int check_mem_type(unsigned long start, size_t num_pages)
 {
 	struct mm_struct *mm = current->mm;
 	int rc;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	rc = __check_mem_type(find_vma(mm, start),
 			      start + num_pages * PAGE_SIZE);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return rc;
 }
diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index b5f911222ae6..c83cd7d1c25b 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -344,11 +344,12 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 	struct vm_area_struct *vmas[1];
 	unsigned int flags = 0;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (prot & IOMMU_WRITE)
 		flags |= FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	if (mm == current->mm) {
 		ret = get_user_pages(vaddr, 1, flags | FOLL_LONGTERM, page,
 				     vmas);
@@ -367,14 +368,14 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 			put_page(page[0]);
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	if (ret == 1) {
 		*pfn = page_to_pfn(page[0]);
 		return 0;
 	}
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	vma = find_vma_intersection(mm, vaddr, vaddr + 1);
 
@@ -384,7 +385,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 			ret = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return ret;
 }
 
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 469dfbd6cf90..ab154712642b 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -742,12 +742,13 @@ static long gntdev_ioctl_get_offset_for_vaddr(struct gntdev_priv *priv,
 	struct vm_area_struct *vma;
 	struct gntdev_grant_map *map;
 	int rv = -EINVAL;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (copy_from_user(&op, u, sizeof(op)) != 0)
 		return -EFAULT;
 	pr_debug("priv %p, offset for vaddr %lx\n", priv, (unsigned long)op.vaddr);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	vma = find_vma(current->mm, op.vaddr);
 	if (!vma || vma->vm_ops != &gntdev_vmops)
 		goto out_unlock;
@@ -761,7 +762,7 @@ static long gntdev_ioctl_get_offset_for_vaddr(struct gntdev_priv *priv,
 	rv = 0;
 
  out_unlock:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	if (rv == 0 && copy_to_user(u, &op, sizeof(op)) != 0)
 		return -EFAULT;
diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index b24ddac1604b..dca0ad37e1b2 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -258,6 +258,7 @@ static long privcmd_ioctl_mmap(struct file *file, void __user *udata)
 	int rc;
 	LIST_HEAD(pagelist);
 	struct mmap_gfn_state state;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* We only support privcmd_ioctl_mmap_batch for auto translated. */
 	if (xen_feature(XENFEAT_auto_translated_physmap))
@@ -277,7 +278,7 @@ static long privcmd_ioctl_mmap(struct file *file, void __user *udata)
 	if (rc || list_empty(&pagelist))
 		goto out;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 
 	{
 		struct page *page = list_first_entry(&pagelist,
@@ -302,7 +303,7 @@ static long privcmd_ioctl_mmap(struct file *file, void __user *udata)
 
 
 out_up:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 out:
 	free_page_list(&pagelist);
@@ -452,6 +453,7 @@ static long privcmd_ioctl_mmap_batch(
 	unsigned long nr_pages;
 	LIST_HEAD(pagelist);
 	struct mmap_batch_state state;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	switch (version) {
 	case 1:
@@ -498,7 +500,7 @@ static long privcmd_ioctl_mmap_batch(
 		}
 	}
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 
 	vma = find_vma(mm, m.addr);
 	if (!vma ||
@@ -554,7 +556,7 @@ static long privcmd_ioctl_mmap_batch(
 	BUG_ON(traverse_pages_block(m.num, sizeof(xen_pfn_t),
 				    &pagelist, mmap_batch_fn, &state));
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	if (state.global_error) {
 		/* Write back errors in second pass. */
@@ -575,7 +577,7 @@ static long privcmd_ioctl_mmap_batch(
 	return ret;
 
 out_unlock:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	goto out;
 }
 
@@ -752,6 +754,7 @@ static long privcmd_ioctl_mmap_resource(struct file *file, void __user *udata)
 	xen_pfn_t *pfns = NULL;
 	struct xen_mem_acquire_resource xdata;
 	int rc;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (copy_from_user(&kdata, udata, sizeof(kdata)))
 		return -EFAULT;
@@ -760,7 +763,7 @@ static long privcmd_ioctl_mmap_resource(struct file *file, void __user *udata)
 	if (data->domid != DOMID_INVALID && data->domid != kdata.dom)
 		return -EPERM;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 
 	vma = find_vma(mm, kdata.addr);
 	if (!vma || vma->vm_ops != &privcmd_vm_ops) {
@@ -845,7 +848,7 @@ static long privcmd_ioctl_mmap_resource(struct file *file, void __user *udata)
 	}
 
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	kfree(pfns);
 
 	return rc;
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 51ec27a84668..a77d42ece14f 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -538,7 +538,8 @@ static inline bool hmm_vma_range_done(struct hmm_range *range)
 }
 
 /* This is a temporary helper to avoid merge conflict between trees. */
-static inline int hmm_vma_fault(struct hmm_range *range, bool block)
+static inline int hmm_vma_fault(struct hmm_range *range, bool block,
+				struct range_lock *mmrange)
 {
 	long ret;
 
@@ -563,7 +564,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
 		 * returns -EAGAIN which correspond to mmap_sem have been
 		 * drop in the old API.
 		 */
-		up_read(&range->vma->vm_mm->mmap_sem);
+		mm_read_unlock(range->vma->vm_mm, mmrange);
 		return -EAGAIN;
 	}
 
@@ -571,7 +572,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
 	if (ret <= 0) {
 		if (ret == -EBUSY || !ret) {
 			/* Same as above  drop mmap_sem to match old API. */
-			up_read(&range->vma->vm_mm->mmap_sem);
+			mm_read_unlock(range->vma->vm_mm, mmrange);
 			ret = -EBUSY;
 		} else if (ret == -EAGAIN)
 			ret = -EBUSY;
-- 
2.16.4

