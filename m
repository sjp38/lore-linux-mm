Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B40506B0011
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:22:01 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id r33so3627669qkh.2
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:22:01 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 97si724305qkr.186.2018.03.09.19.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:22:00 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 10/13] drm/nouveau: add HMM area creation
Date: Fri,  9 Mar 2018 22:21:38 -0500
Message-Id: <20180310032141.6096-11-jglisse@redhat.com>
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

HMM area is a virtual address range under HMM control, GPU access inside
such range is like CPU access. For thing to work properly HMM range should
cover everything except a reserved range for GEM buffer object.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Ben Skeggs <bskeggs@redhat.com>
---
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c | 63 +++++++++++++++++++++++++++
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.h |  2 +
 2 files changed, 65 insertions(+)

diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c
index 96671987ce53..ef4b839932fa 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c
@@ -1540,6 +1540,69 @@ nvkm_vmm_get_locked(struct nvkm_vmm *vmm, bool getref, bool mapref, bool sparse,
 	return 0;
 }
 
+int
+nvkm_vmm_hmm_init(struct nvkm_vmm *vmm, u64 start, u64 end,
+		  struct nvkm_vma **pvma)
+{
+	struct nvkm_vma *vma = NULL, *tmp;
+	struct rb_node *node;
+
+	/* Locate smallest block that can possibly satisfy the allocation. */
+	node = vmm->free.rb_node;
+	while (node) {
+		struct nvkm_vma *this = rb_entry(node, typeof(*this), tree);
+
+		if (this->addr <= start && (this->addr + this->size) >= end) {
+			rb_erase(&this->tree, &vmm->free);
+			vma = this;
+			break;
+		}
+		node = node->rb_left;
+	}
+
+	if (vma == NULL) {
+		return -EINVAL;
+	}
+
+	if (start != vma->addr) {
+		if (!(tmp = nvkm_vma_tail(vma, vma->size + vma->addr - start))) {
+			nvkm_vmm_put_region(vmm, vma);
+			return -ENOMEM;
+		}
+		nvkm_vmm_free_insert(vmm, vma);
+		vma = tmp;
+	}
+
+	if (end < (vma->addr + vma->size)) {
+		if (!(tmp = nvkm_vma_tail(vma, vma->size + vma->addr - end))) {
+			nvkm_vmm_put_region(vmm, vma);
+			return -ENOMEM;
+		}
+		nvkm_vmm_free_insert(vmm, tmp);
+	}
+
+	vma->mapref = false;
+	vma->sparse = false;
+	vma->page = NVKM_VMA_PAGE_NONE;
+	vma->refd = NVKM_VMA_PAGE_NONE;
+	vma->used = true;
+	nvkm_vmm_node_insert(vmm, vma);
+	*pvma = vma;
+	return 0;
+}
+
+void
+nvkm_vmm_hmm_fini(struct nvkm_vmm *vmm, u64 start, u64 end)
+{
+	struct nvkm_vma *vma;
+	u64 size = (end - start);
+
+	vma = nvkm_vmm_node_search(vmm, start);
+	if (vma && vma->addr == start && vma->size == size) {
+		nvkm_vmm_put_locked(vmm, vma);
+	}
+}
+
 int
 nvkm_vmm_get(struct nvkm_vmm *vmm, u8 page, u64 size, struct nvkm_vma **pvma)
 {
diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.h b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.h
index a630aa2a77e4..04d672a4dccb 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.h
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.h
@@ -165,6 +165,8 @@ int nvkm_vmm_get_locked(struct nvkm_vmm *, bool getref, bool mapref,
 			bool sparse, u8 page, u8 align, u64 size,
 			struct nvkm_vma **pvma);
 void nvkm_vmm_put_locked(struct nvkm_vmm *, struct nvkm_vma *);
+int nvkm_vmm_hmm_init(struct nvkm_vmm *, u64, u64, struct nvkm_vma **);
+void nvkm_vmm_hmm_fini(struct nvkm_vmm *, u64, u64);
 void nvkm_vmm_unmap_locked(struct nvkm_vmm *, struct nvkm_vma *);
 void nvkm_vmm_unmap_region(struct nvkm_vmm *vmm, struct nvkm_vma *vma);
 void nvkm_vmm_hmm_map(struct nvkm_vmm *vmm, u64 addr, u64 npages, u64 *pages);
-- 
2.14.3
