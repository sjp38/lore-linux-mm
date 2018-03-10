Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DD236B000C
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:22:00 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id h16so2555065qke.8
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:22:00 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l35si2241512qtl.174.2018.03.09.19.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:21:59 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 07/13] drm/nouveau: special mapping method for HMM
Date: Fri,  9 Mar 2018 22:21:35 -0500
Message-Id: <20180310032141.6096-8-jglisse@redhat.com>
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

HMM does not have any of the usual memory object properties. For HMM
inside any range the following is true:
    - not all page in a range are valid
    - not all page have same permission (read only, read and write)
    - not all page are in same memory (system memory, GPU memory)

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Ben Skeggs <bskeggs@redhat.com>
---
 drivers/gpu/drm/nouveau/include/nvkm/subdev/mmu.h  |  21 +++++
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c      | 105 ++++++++++++++++++++-
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.h      |   6 ++
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmmgp100.c |  73 ++++++++++++++
 4 files changed, 204 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/include/nvkm/subdev/mmu.h b/drivers/gpu/drm/nouveau/include/nvkm/subdev/mmu.h
index baab93398e54..719d50e6296f 100644
--- a/drivers/gpu/drm/nouveau/include/nvkm/subdev/mmu.h
+++ b/drivers/gpu/drm/nouveau/include/nvkm/subdev/mmu.h
@@ -2,6 +2,21 @@
 #ifndef __NVKM_MMU_H__
 #define __NVKM_MMU_H__
 #include <core/subdev.h>
+#include <linux/hmm.h>
+
+/* Need to change HMM to be more driver friendly */
+#if IS_ENABLED(CONFIG_HMM)
+#else
+typedef unsigned long hmm_pfn_t;
+#define HMM_PFN_VALID (1 << 0)
+#define HMM_PFN_READ (1 << 1)
+#define HMM_PFN_WRITE (1 << 2)
+#define HMM_PFN_ERROR (1 << 3)
+#define HMM_PFN_EMPTY (1 << 4)
+#define HMM_PFN_SPECIAL (1 << 5)
+#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 6)
+#define HMM_PFN_SHIFT 7
+#endif
 
 struct nvkm_vma {
 	struct list_head head;
@@ -56,6 +71,7 @@ void nvkm_vmm_part(struct nvkm_vmm *, struct nvkm_memory *inst);
 int nvkm_vmm_get(struct nvkm_vmm *, u8 page, u64 size, struct nvkm_vma **);
 void nvkm_vmm_put(struct nvkm_vmm *, struct nvkm_vma **);
 
+
 struct nvkm_vmm_map {
 	struct nvkm_memory *memory;
 	u64 offset;
@@ -63,6 +79,11 @@ struct nvkm_vmm_map {
 	struct nvkm_mm_node *mem;
 	struct scatterlist *sgl;
 	dma_addr_t *dma;
+#define NV_HMM_PAGE_FLAG_V HMM_PFN_VALID
+#define NV_HMM_PAGE_FLAG_W HMM_PFN_WRITE
+#define NV_HMM_PAGE_FLAG_E HMM_PFN_ERROR
+#define NV_HMM_PAGE_PFN_SHIFT HMM_PFN_SHIFT
+	u64 *pages;
 	u64 off;
 
 	const struct nvkm_vmm_page *page;
diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c
index 20d31526ba8f..96671987ce53 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c
@@ -75,7 +75,7 @@ struct nvkm_vmm_iter {
 	struct nvkm_vmm *vmm;
 	u64 cnt;
 	u16 max, lvl;
-	u64 start, addr;
+	u64 start, addr, *pages;
 	u32 pte[NVKM_VMM_LEVELS_MAX];
 	struct nvkm_vmm_pt *pt[NVKM_VMM_LEVELS_MAX];
 	int flush;
@@ -281,6 +281,59 @@ nvkm_vmm_unref_ptes(struct nvkm_vmm_iter *it, u32 ptei, u32 ptes)
 	return true;
 }
 
+static bool
+nvkm_vmm_unref_hmm_ptes(struct nvkm_vmm_iter *it, u32 ptei, u32 ptes)
+{
+	const struct nvkm_vmm_desc *desc = it->desc;
+	const int type = desc->type == SPT;
+	struct nvkm_vmm_pt *pgt = it->pt[0];
+	struct nvkm_mmu_pt *pt;
+	int mapped;
+
+	pt = pgt->pt[type];
+	mapped = desc->func->hmm_unmap(it->vmm, pt, ptei, ptes, NULL);
+	if (mapped <= 0)
+		return false;
+	ptes = mapped;
+
+	/* Dual-PTs need special handling, unless PDE becoming invalid. */
+	if (desc->type == SPT && (pgt->refs[0] || pgt->refs[1]))
+		nvkm_vmm_unref_sptes(it, pgt, desc, ptei, ptes);
+
+	/* GPU may have cached the PTs, flush before freeing. */
+	nvkm_vmm_flush_mark(it);
+	nvkm_vmm_flush(it);
+
+	nvkm_kmap(pt->memory);
+	while (mapped--) {
+		u64 data = nvkm_ro64(pt->memory, pt->base + ptei * 8);
+		dma_addr_t dma = (data >> 8) << 12;
+
+		if (!data) {
+			ptei++;
+			continue;
+		}
+		dma_unmap_page(it->vmm->mmu->subdev.device->dev, dma,
+			       PAGE_SIZE, DMA_BIDIRECTIONAL);
+		VMM_WO064(pt, it->vmm, ptei++ * 8, 0UL);
+	}
+	nvkm_done(pt->memory);
+
+	/* Drop PTE references. */
+	pgt->refs[type] -= ptes;
+
+	/* PT no longer neeed?  Destroy it. */
+	if (!pgt->refs[type]) {
+		it->lvl++;
+		TRA(it, "%s empty", nvkm_vmm_desc_type(desc));
+		it->lvl--;
+		nvkm_vmm_unref_pdes(it);
+		return false; /* PTE writes for unmap() not necessary. */
+	}
+
+	return true;
+}
+
 static void
 nvkm_vmm_ref_sptes(struct nvkm_vmm_iter *it, struct nvkm_vmm_pt *pgt,
 		   const struct nvkm_vmm_desc *desc, u32 ptei, u32 ptes)
@@ -349,6 +402,32 @@ nvkm_vmm_ref_sptes(struct nvkm_vmm_iter *it, struct nvkm_vmm_pt *pgt,
 	}
 }
 
+static bool
+nvkm_vmm_ref_hmm_ptes(struct nvkm_vmm_iter *it, u32 ptei, u32 ptes)
+{
+	const struct nvkm_vmm_desc *desc = it->desc;
+	const int type = desc->type == SPT;
+	struct nvkm_vmm_pt *pgt = it->pt[0];
+	struct nvkm_mmu_pt *pt;
+	int mapped;
+
+	pt = pgt->pt[type];
+	mapped = desc->func->hmm_map(it->vmm, pt, ptei, ptes,
+			&it->pages[(it->addr - it->start) >> PAGE_SHIFT]);
+	if (mapped <= 0)
+		return false;
+	ptes = mapped;
+
+	/* Take PTE references. */
+	pgt->refs[type] += ptes;
+
+	/* Dual-PTs need special handling. */
+	if (desc->type == SPT)
+		nvkm_vmm_ref_sptes(it, pgt, desc, ptei, ptes);
+
+	return true;
+}
+
 static bool
 nvkm_vmm_ref_ptes(struct nvkm_vmm_iter *it, u32 ptei, u32 ptes)
 {
@@ -520,6 +599,7 @@ nvkm_vmm_iter(struct nvkm_vmm *vmm, const struct nvkm_vmm_page *page,
 	it.cnt = size >> page->shift;
 	it.flush = NVKM_VMM_LEVELS_MAX;
 	it.start = it.addr = addr;
+	it.pages = map ? map->pages : NULL;
 
 	/* Deconstruct address into PTE indices for each mapping level. */
 	for (it.lvl = 0; desc[it.lvl].bits; it.lvl++) {
@@ -1184,6 +1264,29 @@ nvkm_vmm_map(struct nvkm_vmm *vmm, struct nvkm_vma *vma, void *argv, u32 argc,
 	return ret;
 }
 
+void
+nvkm_vmm_hmm_map(struct nvkm_vmm *vmm, u64 addr, u64 npages, u64 *pages)
+{
+	struct nvkm_vmm_map map = {0};
+
+	for (map.page = vmm->func->page; map.page->shift != 12; map.page++);
+	map.pages = pages;
+
+	nvkm_vmm_iter(vmm, map.page, addr, npages << PAGE_SHIFT, "ref + map",
+		      true, nvkm_vmm_ref_hmm_ptes, NULL, &map, NULL);
+}
+
+void
+nvkm_vmm_hmm_unmap(struct nvkm_vmm *vmm, u64 addr, u64 npages)
+{
+	struct nvkm_vmm_map map = {0};
+
+	for (map.page = vmm->func->page; map.page->shift != 12; map.page++);
+
+	nvkm_vmm_iter(vmm, map.page, addr, npages << PAGE_SHIFT, "unmap + unref",
+		      false, nvkm_vmm_unref_hmm_ptes, NULL, NULL, NULL);
+}
+
 static void
 nvkm_vmm_put_region(struct nvkm_vmm *vmm, struct nvkm_vma *vma)
 {
diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.h b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.h
index da06e64d8a7d..a630aa2a77e4 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.h
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.h
@@ -56,6 +56,8 @@ typedef void (*nvkm_vmm_pde_func)(struct nvkm_vmm *,
 				  struct nvkm_vmm_pt *, u32 pdei);
 typedef void (*nvkm_vmm_pte_func)(struct nvkm_vmm *, struct nvkm_mmu_pt *,
 				  u32 ptei, u32 ptes, struct nvkm_vmm_map *);
+typedef int (*nvkm_vmm_hmm_func)(struct nvkm_vmm *, struct nvkm_mmu_pt *,
+				 u32 ptei, u32 ptes, u64 *pages);
 
 struct nvkm_vmm_desc_func {
 	nvkm_vmm_pxe_func invalid;
@@ -67,6 +69,8 @@ struct nvkm_vmm_desc_func {
 	nvkm_vmm_pte_func mem;
 	nvkm_vmm_pte_func dma;
 	nvkm_vmm_pte_func sgl;
+	nvkm_vmm_hmm_func hmm_map;
+	nvkm_vmm_hmm_func hmm_unmap;
 };
 
 extern const struct nvkm_vmm_desc_func gf100_vmm_pgd;
@@ -163,6 +167,8 @@ int nvkm_vmm_get_locked(struct nvkm_vmm *, bool getref, bool mapref,
 void nvkm_vmm_put_locked(struct nvkm_vmm *, struct nvkm_vma *);
 void nvkm_vmm_unmap_locked(struct nvkm_vmm *, struct nvkm_vma *);
 void nvkm_vmm_unmap_region(struct nvkm_vmm *vmm, struct nvkm_vma *vma);
+void nvkm_vmm_hmm_map(struct nvkm_vmm *vmm, u64 addr, u64 npages, u64 *pages);
+void nvkm_vmm_hmm_unmap(struct nvkm_vmm *vmm, u64 addr, u64 npages);
 
 struct nvkm_vma *nvkm_vma_tail(struct nvkm_vma *, u64 tail);
 void nvkm_vmm_node_insert(struct nvkm_vmm *, struct nvkm_vma *);
diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmmgp100.c b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmmgp100.c
index 8752d9ce4af0..bae32fc28289 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmmgp100.c
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmmgp100.c
@@ -67,6 +67,77 @@ gp100_vmm_pgt_dma(struct nvkm_vmm *vmm, struct nvkm_mmu_pt *pt,
 	VMM_MAP_ITER_DMA(vmm, pt, ptei, ptes, map, gp100_vmm_pgt_pte);
 }
 
+static int
+gp100_vmm_pgt_hmm_map(struct nvkm_vmm *vmm, struct nvkm_mmu_pt *pt,
+		      u32 ptei, u32 ptes, u64 *pages)
+{
+	int mapped = 0;
+
+	nvkm_kmap(pt->memory);
+	while (ptes--) {
+		u64 data = nvkm_ro64(pt->memory, pt->base + ptei * 8);
+		u64 page = *pages;
+		struct page *tmp;
+		dma_addr_t dma;
+
+		if (!(page & NV_HMM_PAGE_FLAG_V)) {
+			pages++; ptei++;
+			continue;
+		}
+
+		if ((data & 1)) {
+			*pages |= NV_HMM_PAGE_FLAG_V;
+			pages++; ptei++;
+			continue;
+		}
+
+		tmp = pfn_to_page(page >> NV_HMM_PAGE_PFN_SHIFT);
+		dma = dma_map_page(vmm->mmu->subdev.device->dev, tmp,
+				   0, PAGE_SIZE, DMA_BIDIRECTIONAL);
+		if (dma_mapping_error(vmm->mmu->subdev.device->dev, dma)) {
+			*pages |= NV_HMM_PAGE_FLAG_E;
+			pages++; ptei++;
+			continue;
+		}
+
+		data = (2 << 1);
+		data |= ((dma >> PAGE_SHIFT) << 8);
+		data |= page & NV_HMM_PAGE_FLAG_V ? (1 << 0) : 0;
+		data |= page & NV_HMM_PAGE_FLAG_W ? 0 : (1 << 6);
+
+		VMM_WO064(pt, vmm, ptei++ * 8, data);
+		mapped++;
+		pages++;
+	}
+	nvkm_done(pt->memory);
+
+	return mapped;
+}
+
+static int
+gp100_vmm_pgt_hmm_unmap(struct nvkm_vmm *vmm, struct nvkm_mmu_pt *pt,
+			u32 ptei, u32 ptes, u64 *pages)
+{
+	int unmapped = 0;
+
+	nvkm_kmap(pt->memory);
+	while (ptes--) {
+		u64 data = nvkm_ro64(pt->memory, pt->base + ptei * 8);
+
+		if (!(data & 1)) {
+			VMM_WO064(pt, vmm, ptei++ * 8, 0UL);
+			continue;
+		}
+
+		/* Clear valid but keep pte value so we can dma_unmap() */
+		VMM_WO064(pt, vmm, ptei++ * 8, data ^ 1);
+		unmapped++;
+	}
+	nvkm_done(pt->memory);
+
+	return unmapped;
+}
+
 static void
 gp100_vmm_pgt_mem(struct nvkm_vmm *vmm, struct nvkm_mmu_pt *pt,
 		  u32 ptei, u32 ptes, struct nvkm_vmm_map *map)
@@ -89,6 +160,8 @@ gp100_vmm_desc_spt = {
 	.mem = gp100_vmm_pgt_mem,
 	.dma = gp100_vmm_pgt_dma,
 	.sgl = gp100_vmm_pgt_sgl,
+	.hmm_map = gp100_vmm_pgt_hmm_map,
+	.hmm_unmap = gp100_vmm_pgt_hmm_unmap,
 };
 
 static void
-- 
2.14.3
