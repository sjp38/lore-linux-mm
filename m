Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB756B0012
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:22:02 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id v68so3613015qki.13
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:22:02 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h7si2189885qkb.315.2018.03.09.19.22.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:22:01 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 11/13] drm/nouveau: add HMM area creation user interface
Date: Fri,  9 Mar 2018 22:21:39 -0500
Message-Id: <20180310032141.6096-12-jglisse@redhat.com>
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

User API to create HMM area.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Ben Skeggs <bskeggs@redhat.com>
---
 drivers/gpu/drm/nouveau/include/nvif/if000c.h  |  9 +++++
 drivers/gpu/drm/nouveau/include/nvif/vmm.h     |  2 +
 drivers/gpu/drm/nouveau/nvif/vmm.c             | 51 ++++++++++++++++++++++++++
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/uvmm.c | 39 ++++++++++++++++++++
 4 files changed, 101 insertions(+)

diff --git a/drivers/gpu/drm/nouveau/include/nvif/if000c.h b/drivers/gpu/drm/nouveau/include/nvif/if000c.h
index 2c24817ca533..0383864b033b 100644
--- a/drivers/gpu/drm/nouveau/include/nvif/if000c.h
+++ b/drivers/gpu/drm/nouveau/include/nvif/if000c.h
@@ -16,6 +16,8 @@ struct nvif_vmm_v0 {
 #define NVIF_VMM_V0_UNMAP                                                  0x04
 #define NVIF_VMM_V0_HMM_MAP                                                0x05
 #define NVIF_VMM_V0_HMM_UNMAP                                              0x06
+#define NVIF_VMM_V0_HMM_INIT                                               0x07
+#define NVIF_VMM_V0_HMM_FINI                                               0x08
 
 struct nvif_vmm_page_v0 {
 	__u8  version;
@@ -78,4 +80,11 @@ struct nvif_vmm_hmm_unmap_v0 {
 	__u64 addr;
 	__u64 npages;
 };
+
+struct nvif_vmm_hmm_v0 {
+	__u8  version;
+	__u8  pad01[7];
+	__u64 start;
+	__u64 end;
+};
 #endif
diff --git a/drivers/gpu/drm/nouveau/include/nvif/vmm.h b/drivers/gpu/drm/nouveau/include/nvif/vmm.h
index c5e4adaa0e3c..f11f8c510ebd 100644
--- a/drivers/gpu/drm/nouveau/include/nvif/vmm.h
+++ b/drivers/gpu/drm/nouveau/include/nvif/vmm.h
@@ -39,6 +39,8 @@ void nvif_vmm_put(struct nvif_vmm *, struct nvif_vma *);
 int nvif_vmm_map(struct nvif_vmm *, u64 addr, u64 size, void *argv, u32 argc,
 		 struct nvif_mem *, u64 offset);
 int nvif_vmm_unmap(struct nvif_vmm *, u64);
+int nvif_vmm_hmm_init(struct nvif_vmm *vmm, u64 hstart, u64 hend);
+void nvif_vmm_hmm_fini(struct nvif_vmm *vmm, u64 hstart, u64 hend);
 int nvif_vmm_hmm_map(struct nvif_vmm *vmm, u64 addr, u64 npages, u64 *pages);
 int nvif_vmm_hmm_unmap(struct nvif_vmm *vmm, u64 addr, u64 npages);
 #endif
diff --git a/drivers/gpu/drm/nouveau/nvif/vmm.c b/drivers/gpu/drm/nouveau/nvif/vmm.c
index 27a7b95b4e9c..788e02e47750 100644
--- a/drivers/gpu/drm/nouveau/nvif/vmm.c
+++ b/drivers/gpu/drm/nouveau/nvif/vmm.c
@@ -32,6 +32,57 @@ nvif_vmm_unmap(struct nvif_vmm *vmm, u64 addr)
 				sizeof(struct nvif_vmm_unmap_v0));
 }
 
+int
+nvif_vmm_hmm_init(struct nvif_vmm *vmm, u64 hstart, u64 hend)
+{
+	struct nvif_vmm_hmm_v0 args;
+	int ret;
+
+	if (hstart > PAGE_SIZE) {
+		args.version = 0;
+		args.start = PAGE_SIZE;
+		args.end = hstart;
+		ret = nvif_object_mthd(&vmm->object, NVIF_VMM_V0_HMM_INIT,
+				       &args, sizeof(args));
+		if (ret)
+			return ret;
+	}
+
+	args.version = 0;
+	args.start = hend;
+	args.end = TASK_SIZE;
+	ret = nvif_object_mthd(&vmm->object, NVIF_VMM_V0_HMM_INIT,
+			       &args, sizeof(args));
+	if (ret && hstart > PAGE_SIZE) {
+		args.version = 0;
+		args.start = PAGE_SIZE;
+		args.end = hstart;
+		nvif_object_mthd(&vmm->object, NVIF_VMM_V0_HMM_FINI,
+				 &args, sizeof(args));
+	}
+	return ret;
+}
+
+void
+nvif_vmm_hmm_fini(struct nvif_vmm *vmm, u64 hstart, u64 hend)
+{
+	struct nvif_vmm_hmm_v0 args;
+
+	if (hstart > PAGE_SIZE) {
+		args.version = 0;
+		args.start = PAGE_SIZE;
+		args.end = hstart;
+		nvif_object_mthd(&vmm->object, NVIF_VMM_V0_HMM_FINI,
+				 &args, sizeof(args));
+	}
+
+	args.version = 0;
+	args.start = hend;
+	args.end = TASK_SIZE;
+	nvif_object_mthd(&vmm->object, NVIF_VMM_V0_HMM_FINI,
+			 &args, sizeof(args));
+}
+
 int
 nvif_vmm_hmm_map(struct nvif_vmm *vmm, u64 addr, u64 npages, u64 *pages)
 {
diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/uvmm.c b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/uvmm.c
index 739f2af02552..34e00aa73fd0 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/uvmm.c
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/uvmm.c
@@ -274,6 +274,43 @@ nvkm_uvmm_mthd_page(struct nvkm_uvmm *uvmm, void *argv, u32 argc)
 	return 0;
 }
 
+static int
+nvkm_uvmm_mthd_hmm_init(struct nvkm_uvmm *uvmm, void *argv, u32 argc)
+{
+	union {
+		struct nvif_vmm_hmm_v0 v0;
+	} *args = argv;
+	struct nvkm_vmm *vmm = uvmm->vmm;
+	struct nvkm_vma *vma;
+	int ret = -ENOSYS;
+
+	if ((ret = nvif_unpack(ret, &argv, &argc, args->v0, 0, 0, false)))
+		return ret;
+
+	mutex_lock(&vmm->mutex);
+	ret = nvkm_vmm_hmm_init(vmm, args->v0.start, args->v0.end, &vma);
+	mutex_unlock(&vmm->mutex);
+	return ret;
+}
+
+static int
+nvkm_uvmm_mthd_hmm_fini(struct nvkm_uvmm *uvmm, void *argv, u32 argc)
+{
+	union {
+		struct nvif_vmm_hmm_v0 v0;
+	} *args = argv;
+	struct nvkm_vmm *vmm = uvmm->vmm;
+	int ret = -ENOSYS;
+
+	if ((ret = nvif_unpack(ret, &argv, &argc, args->v0, 0, 0, false)))
+		return ret;
+
+	mutex_lock(&vmm->mutex);
+	nvkm_vmm_hmm_fini(vmm, args->v0.start, args->v0.end);
+	mutex_unlock(&vmm->mutex);
+	return 0;
+}
+
 static int
 nvkm_uvmm_mthd_hmm_map(struct nvkm_uvmm *uvmm, void *argv, u32 argc)
 {
@@ -321,6 +358,8 @@ nvkm_uvmm_mthd(struct nvkm_object *object, u32 mthd, void *argv, u32 argc)
 	case NVIF_VMM_V0_PUT      : return nvkm_uvmm_mthd_put      (uvmm, argv, argc);
 	case NVIF_VMM_V0_MAP      : return nvkm_uvmm_mthd_map      (uvmm, argv, argc);
 	case NVIF_VMM_V0_UNMAP    : return nvkm_uvmm_mthd_unmap    (uvmm, argv, argc);
+	case NVIF_VMM_V0_HMM_INIT : return nvkm_uvmm_mthd_hmm_init (uvmm, argv, argc);
+	case NVIF_VMM_V0_HMM_FINI : return nvkm_uvmm_mthd_hmm_fini (uvmm, argv, argc);
 	case NVIF_VMM_V0_HMM_MAP  : return nvkm_uvmm_mthd_hmm_map  (uvmm, argv, argc);
 	case NVIF_VMM_V0_HMM_UNMAP: return nvkm_uvmm_mthd_hmm_unmap(uvmm, argv, argc);
 	default:
-- 
2.14.3
