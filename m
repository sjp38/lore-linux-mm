Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6296B000A
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:22:01 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id h16so2555079qke.8
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:22:01 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z13si283128qkl.148.2018.03.09.19.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:21:59 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 08/13] drm/nouveau: special mapping method for HMM (user interface)
Date: Fri,  9 Mar 2018 22:21:36 -0500
Message-Id: <20180310032141.6096-9-jglisse@redhat.com>
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

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Ben Skeggs <bskeggs@redhat.com>
---
 drivers/gpu/drm/nouveau/include/nvif/if000c.h     | 17 ++++++++
 drivers/gpu/drm/nouveau/include/nvif/vmm.h        |  2 +
 drivers/gpu/drm/nouveau/include/nvkm/subdev/mmu.h | 25 ++++--------
 drivers/gpu/drm/nouveau/nvif/vmm.c                | 29 ++++++++++++++
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/uvmm.c    | 49 ++++++++++++++++++++---
 5 files changed, 99 insertions(+), 23 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/include/nvif/if000c.h b/drivers/gpu/drm/nouveau/include/nvif/if000c.h
index 2928ecd989ad..2c24817ca533 100644
--- a/drivers/gpu/drm/nouveau/include/nvif/if000c.h
+++ b/drivers/gpu/drm/nouveau/include/nvif/if000c.h
@@ -14,6 +14,8 @@ struct nvif_vmm_v0 {
 #define NVIF_VMM_V0_PUT                                                    0x02
 #define NVIF_VMM_V0_MAP                                                    0x03
 #define NVIF_VMM_V0_UNMAP                                                  0x04
+#define NVIF_VMM_V0_HMM_MAP                                                0x05
+#define NVIF_VMM_V0_HMM_UNMAP                                              0x06
 
 struct nvif_vmm_page_v0 {
 	__u8  version;
@@ -61,4 +63,19 @@ struct nvif_vmm_unmap_v0 {
 	__u8  pad01[7];
 	__u64 addr;
 };
+
+struct nvif_vmm_hmm_map_v0 {
+	__u8  version;
+	__u8  pad01[7];
+	__u64 addr;
+	__u64 npages;
+	__u64 pages;
+};
+
+struct nvif_vmm_hmm_unmap_v0 {
+	__u8  version;
+	__u8  pad01[7];
+	__u64 addr;
+	__u64 npages;
+};
 #endif
diff --git a/drivers/gpu/drm/nouveau/include/nvif/vmm.h b/drivers/gpu/drm/nouveau/include/nvif/vmm.h
index c5db8a2e82df..c5e4adaa0e3c 100644
--- a/drivers/gpu/drm/nouveau/include/nvif/vmm.h
+++ b/drivers/gpu/drm/nouveau/include/nvif/vmm.h
@@ -39,4 +39,6 @@ void nvif_vmm_put(struct nvif_vmm *, struct nvif_vma *);
 int nvif_vmm_map(struct nvif_vmm *, u64 addr, u64 size, void *argv, u32 argc,
 		 struct nvif_mem *, u64 offset);
 int nvif_vmm_unmap(struct nvif_vmm *, u64);
+int nvif_vmm_hmm_map(struct nvif_vmm *vmm, u64 addr, u64 npages, u64 *pages);
+int nvif_vmm_hmm_unmap(struct nvif_vmm *vmm, u64 addr, u64 npages);
 #endif
diff --git a/drivers/gpu/drm/nouveau/include/nvkm/subdev/mmu.h b/drivers/gpu/drm/nouveau/include/nvkm/subdev/mmu.h
index 719d50e6296f..8f08718e05aa 100644
--- a/drivers/gpu/drm/nouveau/include/nvkm/subdev/mmu.h
+++ b/drivers/gpu/drm/nouveau/include/nvkm/subdev/mmu.h
@@ -4,20 +4,6 @@
 #include <core/subdev.h>
 #include <linux/hmm.h>
 
-/* Need to change HMM to be more driver friendly */
-#if IS_ENABLED(CONFIG_HMM)
-#else
-typedef unsigned long hmm_pfn_t;
-#define HMM_PFN_VALID (1 << 0)
-#define HMM_PFN_READ (1 << 1)
-#define HMM_PFN_WRITE (1 << 2)
-#define HMM_PFN_ERROR (1 << 3)
-#define HMM_PFN_EMPTY (1 << 4)
-#define HMM_PFN_SPECIAL (1 << 5)
-#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 6)
-#define HMM_PFN_SHIFT 7
-#endif
-
 struct nvkm_vma {
 	struct list_head head;
 	struct rb_node tree;
@@ -79,10 +65,13 @@ struct nvkm_vmm_map {
 	struct nvkm_mm_node *mem;
 	struct scatterlist *sgl;
 	dma_addr_t *dma;
-#define NV_HMM_PAGE_FLAG_V HMM_PFN_VALID
-#define NV_HMM_PAGE_FLAG_W HMM_PFN_WRITE
-#define NV_HMM_PAGE_FLAG_E HMM_PFN_ERROR
-#define NV_HMM_PAGE_PFN_SHIFT HMM_PFN_SHIFT
+#define NV_HMM_PAGE_FLAG_V (1 << 0)
+#define NV_HMM_PAGE_FLAG_R 0
+#define NV_HMM_PAGE_FLAG_W (1 << 1)
+#define NV_HMM_PAGE_FLAG_E (-1ULL)
+#define NV_HMM_PAGE_FLAG_N 0
+#define NV_HMM_PAGE_FLAG_S (1ULL << 63)
+#define NV_HMM_PAGE_PFN_SHIFT 8
 	u64 *pages;
 	u64 off;
 
diff --git a/drivers/gpu/drm/nouveau/nvif/vmm.c b/drivers/gpu/drm/nouveau/nvif/vmm.c
index 31cdb2d2e1ff..27a7b95b4e9c 100644
--- a/drivers/gpu/drm/nouveau/nvif/vmm.c
+++ b/drivers/gpu/drm/nouveau/nvif/vmm.c
@@ -32,6 +32,35 @@ nvif_vmm_unmap(struct nvif_vmm *vmm, u64 addr)
 				sizeof(struct nvif_vmm_unmap_v0));
 }
 
+int
+nvif_vmm_hmm_map(struct nvif_vmm *vmm, u64 addr, u64 npages, u64 *pages)
+{
+	struct nvif_vmm_hmm_map_v0 args;
+	int ret;
+
+	args.version = 0;
+	args.addr = addr;
+	args.npages = npages;
+	args.pages = (uint64_t)pages;
+	ret = nvif_object_mthd(&vmm->object, NVIF_VMM_V0_HMM_MAP,
+			       &args, sizeof(args));
+	return ret;
+}
+
+int
+nvif_vmm_hmm_unmap(struct nvif_vmm *vmm, u64 addr, u64 npages)
+{
+	struct nvif_vmm_hmm_unmap_v0 args;
+	int ret;
+
+	args.version = 0;
+	args.addr = addr;
+	args.npages = npages;
+	ret = nvif_object_mthd(&vmm->object, NVIF_VMM_V0_HMM_UNMAP,
+			       &args, sizeof(args));
+	return ret;
+}
+
 int
 nvif_vmm_map(struct nvif_vmm *vmm, u64 addr, u64 size, void *argv, u32 argc,
 	     struct nvif_mem *mem, u64 offset)
diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/uvmm.c b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/uvmm.c
index 37b201b95f15..739f2af02552 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/uvmm.c
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/uvmm.c
@@ -274,16 +274,55 @@ nvkm_uvmm_mthd_page(struct nvkm_uvmm *uvmm, void *argv, u32 argc)
 	return 0;
 }
 
+static int
+nvkm_uvmm_mthd_hmm_map(struct nvkm_uvmm *uvmm, void *argv, u32 argc)
+{
+	union {
+		struct nvif_vmm_hmm_map_v0 v0;
+	} *args = argv;
+	struct nvkm_vmm *vmm = uvmm->vmm;
+	int ret = -ENOSYS;
+
+	if ((ret = nvif_unpack(ret, &argv, &argc, args->v0, 0, 0, false)))
+		return ret;
+
+	mutex_lock(&vmm->mutex);
+	nvkm_vmm_hmm_map(vmm, args->v0.addr, args->v0.npages,
+			(u64 *)args->v0.pages);
+	mutex_unlock(&vmm->mutex);
+	return 0;
+}
+
+static int
+nvkm_uvmm_mthd_hmm_unmap(struct nvkm_uvmm *uvmm, void *argv, u32 argc)
+{
+	union {
+		struct nvif_vmm_hmm_unmap_v0 v0;
+	} *args = argv;
+	struct nvkm_vmm *vmm = uvmm->vmm;
+	int ret = -ENOSYS;
+
+	if ((ret = nvif_unpack(ret, &argv, &argc, args->v0, 0, 0, false)))
+		return ret;
+
+	mutex_lock(&vmm->mutex);
+	nvkm_vmm_hmm_unmap(vmm, args->v0.addr, args->v0.npages);
+	mutex_unlock(&vmm->mutex);
+	return 0;
+}
+
 static int
 nvkm_uvmm_mthd(struct nvkm_object *object, u32 mthd, void *argv, u32 argc)
 {
 	struct nvkm_uvmm *uvmm = nvkm_uvmm(object);
 	switch (mthd) {
-	case NVIF_VMM_V0_PAGE  : return nvkm_uvmm_mthd_page  (uvmm, argv, argc);
-	case NVIF_VMM_V0_GET   : return nvkm_uvmm_mthd_get   (uvmm, argv, argc);
-	case NVIF_VMM_V0_PUT   : return nvkm_uvmm_mthd_put   (uvmm, argv, argc);
-	case NVIF_VMM_V0_MAP   : return nvkm_uvmm_mthd_map   (uvmm, argv, argc);
-	case NVIF_VMM_V0_UNMAP : return nvkm_uvmm_mthd_unmap (uvmm, argv, argc);
+	case NVIF_VMM_V0_PAGE     : return nvkm_uvmm_mthd_page     (uvmm, argv, argc);
+	case NVIF_VMM_V0_GET      : return nvkm_uvmm_mthd_get      (uvmm, argv, argc);
+	case NVIF_VMM_V0_PUT      : return nvkm_uvmm_mthd_put      (uvmm, argv, argc);
+	case NVIF_VMM_V0_MAP      : return nvkm_uvmm_mthd_map      (uvmm, argv, argc);
+	case NVIF_VMM_V0_UNMAP    : return nvkm_uvmm_mthd_unmap    (uvmm, argv, argc);
+	case NVIF_VMM_V0_HMM_MAP  : return nvkm_uvmm_mthd_hmm_map  (uvmm, argv, argc);
+	case NVIF_VMM_V0_HMM_UNMAP: return nvkm_uvmm_mthd_hmm_unmap(uvmm, argv, argc);
 	default:
 		break;
 	}
-- 
2.14.3
