Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E35886B0023
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:22:02 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id h21so8267739qtm.22
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:22:02 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l64si394914qkc.285.2018.03.09.19.22.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:22:01 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 12/13] drm/nouveau: HMM area creation helpers for nouveau client
Date: Fri,  9 Mar 2018 22:21:40 -0500
Message-Id: <20180310032141.6096-13-jglisse@redhat.com>
In-Reply-To: <20180310032141.6096-1-jglisse@redhat.com>
References: <20180310032141.6096-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Ben Skeggs <bskeggs@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Helpers to create area of virtual address under HMM control for a nouveau
client. GPU access to HMM area are valid as long as the hole vma exist in
the process virtual address space.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Ben Skeggs <bskeggs@redhat.com>
---
 drivers/gpu/drm/nouveau/nouveau_hmm.c | 28 ++++++++++++
 drivers/gpu/drm/nouveau/nouveau_hmm.h |  1 +
 drivers/gpu/drm/nouveau/nouveau_vmm.c | 83 +++++++++++++++++++++++++++++++++++
 drivers/gpu/drm/nouveau/nouveau_vmm.h | 12 +++++
 4 files changed, 124 insertions(+)

diff --git a/drivers/gpu/drm/nouveau/nouveau_hmm.c b/drivers/gpu/drm/nouveau/nouveau_hmm.c
index a4c6f687f6a8..680e29bbf367 100644
--- a/drivers/gpu/drm/nouveau/nouveau_hmm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_hmm.c
@@ -245,6 +245,31 @@ nouveau_vmm_sync_pagetables(struct hmm_mirror *mirror,
 			    unsigned long start,
 			    unsigned long end)
 {
+	struct nouveau_hmm *hmm;
+	struct nouveau_cli *cli;
+
+	hmm = container_of(mirror, struct nouveau_hmm, mirror);
+	if (!hmm->hole.vma || hmm->hole.start == hmm->hole.end)
+		return;
+
+	/* Ignore area inside hole */
+	end = min(end, TASK_SIZE);
+	if (start >= hmm->hole.start && end <= hmm->hole.end)
+		return;
+	if (start < hmm->hole.start && end > hmm->hole.start) {
+		nouveau_vmm_sync_pagetables(mirror, update, start,
+					    hmm->hole.start);
+		start = hmm->hole.end;
+	} else if (start < hmm->hole.end && start >= hmm->hole.start) {
+		start = hmm->hole.end;
+	}
+	if (end <= start)
+		return;
+
+	cli = container_of(hmm, struct nouveau_cli, hmm);
+	mutex_lock(&hmm->mutex);
+	nvif_vmm_hmm_unmap(&cli->vmm.vmm, start, (end - start) >> PAGE_SHIFT);
+	mutex_unlock(&hmm->mutex);
 }
 
 static const struct hmm_mirror_ops nouveau_hmm_mirror_ops = {
@@ -254,6 +279,8 @@ static const struct hmm_mirror_ops nouveau_hmm_mirror_ops = {
 void
 nouveau_hmm_fini(struct nouveau_cli *cli)
 {
+	struct nouveau_hmm *hmm = &cli->hmm;
+
 	if (!cli->hmm.enabled)
 		return;
 
@@ -262,6 +289,7 @@ nouveau_hmm_fini(struct nouveau_cli *cli)
 	nvif_object_fini(&cli->hmm.rpfb);
 
 	hmm_mirror_unregister(&cli->hmm.mirror);
+	nvif_vmm_hmm_fini(&cli->vmm.vmm, hmm->hole.start, hmm->hole.end);
 	nouveau_vmm_sync_pagetables(&cli->hmm.mirror, HMM_UPDATE_INVALIDATE,
 				    PAGE_SIZE, TASK_SIZE);
 }
diff --git a/drivers/gpu/drm/nouveau/nouveau_hmm.h b/drivers/gpu/drm/nouveau/nouveau_hmm.h
index 47f31cf8ac56..bc68dcf0748b 100644
--- a/drivers/gpu/drm/nouveau/nouveau_hmm.h
+++ b/drivers/gpu/drm/nouveau/nouveau_hmm.h
@@ -33,6 +33,7 @@
 #if defined(CONFIG_HMM_MIRROR) && defined(CONFIG_DEVICE_PRIVATE)
 
 struct nouveau_hmm {
+	struct nouveau_vmm_hole hole;
 	struct nvif_object rpfb;
 	struct nvif_notify pending;
 	struct task_struct *task;
diff --git a/drivers/gpu/drm/nouveau/nouveau_vmm.c b/drivers/gpu/drm/nouveau/nouveau_vmm.c
index f5371d96b003..8e6c47a99edb 100644
--- a/drivers/gpu/drm/nouveau/nouveau_vmm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_vmm.c
@@ -115,6 +115,89 @@ nouveau_vma_new(struct nouveau_bo *nvbo, struct nouveau_vmm *vmm,
 	return ret;
 }
 
+static int
+vmm_hole_fault(struct vm_fault *vmf)
+{
+	return VM_FAULT_SIGBUS;
+}
+
+static void
+vmm_hole_open(struct vm_area_struct *vma)
+{
+	struct nouveau_cli *cli = vma->vm_private_data;
+	struct nouveau_vmm_hole *hole = &cli->hmm.hole;
+
+	/*
+	 * No need for atomic this happen under mmap_sem write lock. Make sure
+	 * this assumption holds with a BUG_ON()
+	 */
+	BUG_ON(down_read_trylock(&vma->vm_mm->mmap_sem));
+	hole->count++;
+}
+
+static void
+vmm_hole_close(struct vm_area_struct *vma)
+{
+	struct nouveau_cli *cli = vma->vm_private_data;
+	struct nouveau_vmm_hole *hole = &cli->hmm.hole;
+
+	/*
+	 * No need for atomic this happen under mmap_sem write lock with one
+	 * exception when a process is being kill (from do_exit()). For that
+	 * reasons we don't test with BUG_ON().
+	 */
+	if ((--hole->count) <= 0) {
+		nouveau_hmm_fini(cli);
+		hole->vma = NULL;
+	}
+}
+
+static int
+vmm_hole_access(struct vm_area_struct *vma, unsigned long addr,
+		void *buf, int len, int write)
+{
+	return -EIO;
+}
+
+static const struct vm_operations_struct vmm_hole_vm_ops = {
+	.access = vmm_hole_access,
+	.close = vmm_hole_close,
+	.fault = vmm_hole_fault,
+	.open = vmm_hole_open,
+};
+
+int
+nouveau_vmm_hmm(struct nouveau_cli *cli, struct file *file,
+		struct vm_area_struct *vma)
+{
+	struct nouveau_vmm_hole *hole = &cli->hmm.hole;
+	unsigned long size = vma->vm_end - vma->vm_start;
+	unsigned long pgsize = size >> PAGE_SHIFT;
+	int ret;
+
+	if ((vma->vm_pgoff + pgsize) > (DRM_FILE_PAGE_OFFSET + (4UL << 30)))
+		return -EINVAL;
+
+	if (!cli->hmm.enabled)
+		return -EINVAL;
+
+	hole->vma = vma;
+	hole->cli = cli;
+	hole->file = file;
+	hole->start = vma->vm_start;
+	hole->end = vma->vm_end;
+	hole->count = 1;
+
+	ret = nvif_vmm_hmm_init(&cli->vmm.vmm, vma->vm_start, vma->vm_end);
+	if (ret)
+		return ret;
+
+	vma->vm_private_data = cli;
+	vma->vm_ops = &vmm_hole_vm_ops;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
+	return 0;
+}
+
 void
 nouveau_vmm_fini(struct nouveau_vmm *vmm)
 {
diff --git a/drivers/gpu/drm/nouveau/nouveau_vmm.h b/drivers/gpu/drm/nouveau/nouveau_vmm.h
index 5c31f43678d3..43d30feb3057 100644
--- a/drivers/gpu/drm/nouveau/nouveau_vmm.h
+++ b/drivers/gpu/drm/nouveau/nouveau_vmm.h
@@ -13,6 +13,15 @@ struct nouveau_vma {
 	struct nouveau_mem *mem;
 };
 
+struct nouveau_vmm_hole {
+	struct vm_area_struct *vma;
+	struct nouveau_cli *cli;
+	struct file *file;
+	unsigned long start;
+	unsigned long end;
+	int count;
+};
+
 struct nouveau_vma *nouveau_vma_find(struct nouveau_bo *, struct nouveau_vmm *);
 int nouveau_vma_new(struct nouveau_bo *, struct nouveau_vmm *,
 		    struct nouveau_vma **);
@@ -26,6 +35,9 @@ struct nouveau_vmm {
 	struct nvkm_vm *vm;
 };
 
+int nouveau_vmm_hmm(struct nouveau_cli *cli, struct file *file,
+		    struct vm_area_struct *vma);
+
 int nouveau_vmm_init(struct nouveau_cli *, s32 oclass, struct nouveau_vmm *);
 void nouveau_vmm_fini(struct nouveau_vmm *);
 #endif
-- 
2.14.3
