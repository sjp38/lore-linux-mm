Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D308D6B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:21:57 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id y9so8352380qti.3
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:21:57 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z65si2145982qkd.279.2018.03.09.19.21.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:21:56 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 01/13] drm/nouveau/vmm: enable page table iterator over non populated range
Date: Fri,  9 Mar 2018 22:21:29 -0500
Message-Id: <20180310032141.6096-2-jglisse@redhat.com>
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

This patch modify the page table iterator to support empty range when
unmaping a range (ie when it is not trying to populate the range).

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Ben Skeggs <bskeggs@redhat.com>
---
 drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c | 75 ++++++++++++++++++---------
 1 file changed, 51 insertions(+), 24 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c
index 93946dcee319..20d31526ba8f 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mmu/vmm.c
@@ -75,6 +75,7 @@ struct nvkm_vmm_iter {
 	struct nvkm_vmm *vmm;
 	u64 cnt;
 	u16 max, lvl;
+	u64 start, addr;
 	u32 pte[NVKM_VMM_LEVELS_MAX];
 	struct nvkm_vmm_pt *pt[NVKM_VMM_LEVELS_MAX];
 	int flush;
@@ -485,6 +486,23 @@ nvkm_vmm_ref_swpt(struct nvkm_vmm_iter *it, struct nvkm_vmm_pt *pgd, u32 pdei)
 	return true;
 }
 
+static inline u64
+nvkm_vmm_iter_addr(const struct nvkm_vmm_iter *it,
+		   const struct nvkm_vmm_desc *desc)
+{
+	int max = it->max;
+	u64 addr;
+
+	/* Reconstruct address */
+	addr = it->pte[max--];
+	do {
+		addr  = addr << desc[max].bits;
+		addr |= it->pte[max];
+	} while (max--);
+
+	return addr;
+}
+
 static inline u64
 nvkm_vmm_iter(struct nvkm_vmm *vmm, const struct nvkm_vmm_page *page,
 	      u64 addr, u64 size, const char *name, bool ref,
@@ -494,21 +512,23 @@ nvkm_vmm_iter(struct nvkm_vmm *vmm, const struct nvkm_vmm_page *page,
 {
 	const struct nvkm_vmm_desc *desc = page->desc;
 	struct nvkm_vmm_iter it;
-	u64 bits = addr >> page->shift;
+	u64 addr_bits = addr >> page->shift;
 
 	it.page = page;
 	it.desc = desc;
 	it.vmm = vmm;
 	it.cnt = size >> page->shift;
 	it.flush = NVKM_VMM_LEVELS_MAX;
+	it.start = it.addr = addr;
 
 	/* Deconstruct address into PTE indices for each mapping level. */
 	for (it.lvl = 0; desc[it.lvl].bits; it.lvl++) {
-		it.pte[it.lvl] = bits & ((1 << desc[it.lvl].bits) - 1);
-		bits >>= desc[it.lvl].bits;
+		it.pte[it.lvl] = addr_bits & ((1 << desc[it.lvl].bits) - 1);
+		addr_bits >>= desc[it.lvl].bits;
 	}
 	it.max = --it.lvl;
 	it.pt[it.max] = vmm->pd;
+	addr_bits = addr >> page->shift;
 
 	it.lvl = 0;
 	TRA(&it, "%s: %016llx %016llx %d %lld PTEs", name,
@@ -521,7 +541,8 @@ nvkm_vmm_iter(struct nvkm_vmm *vmm, const struct nvkm_vmm_page *page,
 		const int type = desc->type == SPT;
 		const u32 pten = 1 << desc->bits;
 		const u32 ptei = it.pte[0];
-		const u32 ptes = min_t(u64, it.cnt, pten - ptei);
+		u32 ptes = min_t(u64, it.cnt, pten - ptei);
+		u64 tmp;
 
 		/* Walk down the tree, finding page tables for each level. */
 		for (; it.lvl; it.lvl--) {
@@ -529,9 +550,14 @@ nvkm_vmm_iter(struct nvkm_vmm *vmm, const struct nvkm_vmm_page *page,
 			struct nvkm_vmm_pt *pgd = pgt;
 
 			/* Software PT. */
-			if (ref && NVKM_VMM_PDE_INVALID(pgd->pde[pdei])) {
-				if (!nvkm_vmm_ref_swpt(&it, pgd, pdei))
-					goto fail;
+			if (NVKM_VMM_PDE_INVALID(pgd->pde[pdei])) {
+				if (ref) {
+					if (!nvkm_vmm_ref_swpt(&it, pgd, pdei))
+						goto fail;
+				} else {
+					it.pte[it.lvl] += 1;
+					goto next;
+				}
 			}
 			it.pt[it.lvl - 1] = pgt = pgd->pde[pdei];
 
@@ -545,9 +571,16 @@ nvkm_vmm_iter(struct nvkm_vmm *vmm, const struct nvkm_vmm_page *page,
 				if (!nvkm_vmm_ref_hwpt(&it, pgd, pdei))
 					goto fail;
 			}
+
+			/* With HMM we might walk down un-populated range */
+			if (!pgt) {
+				it.pte[it.lvl] += 1;
+				goto next;
+			}
 		}
 
 		/* Handle PTE updates. */
+		it.addr = nvkm_vmm_iter_addr(&it, desc) << PAGE_SHIFT;
 		if (!REF_PTES || REF_PTES(&it, ptei, ptes)) {
 			struct nvkm_mmu_pt *pt = pgt->pt[type];
 			if (MAP_PTES || CLR_PTES) {
@@ -558,32 +591,26 @@ nvkm_vmm_iter(struct nvkm_vmm *vmm, const struct nvkm_vmm_page *page,
 				nvkm_vmm_flush_mark(&it);
 			}
 		}
+		it.pte[it.lvl] += ptes;
 
+next:
 		/* Walk back up the tree to the next position. */
-		it.pte[it.lvl] += ptes;
-		it.cnt -= ptes;
-		if (it.cnt) {
-			while (it.pte[it.lvl] == (1 << desc[it.lvl].bits)) {
-				it.pte[it.lvl++] = 0;
-				it.pte[it.lvl]++;
-			}
+		while (it.pte[it.lvl] == (1 << desc[it.lvl].bits)) {
+			it.pte[it.lvl++] = 0;
+			if (it.lvl == it.max)
+				break;
+			it.pte[it.lvl]++;
 		}
+		tmp = nvkm_vmm_iter_addr(&it, desc);
+		it.cnt -= min_t(u64, it.cnt, tmp - addr_bits);
+		addr_bits = tmp;
 	};
 
 	nvkm_vmm_flush(&it);
 	return ~0ULL;
 
 fail:
-	/* Reconstruct the failure address so the caller is able to
-	 * reverse any partially completed operations.
-	 */
-	addr = it.pte[it.max--];
-	do {
-		addr  = addr << desc[it.max].bits;
-		addr |= it.pte[it.max];
-	} while (it.max--);
-
-	return addr << page->shift;
+	return addr_bits << page->shift;
 }
 
 static void
-- 
2.14.3
