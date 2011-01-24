Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B4FF66B00E8
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 17:56:21 -0500 (EST)
From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH 8/9] xen/mmu: use apply_to_page_range_batch() in xen_remap_domain_mfn_range()
Date: Mon, 24 Jan 2011 14:56:06 -0800
Message-Id: <e35361f09bf25ecb5ba6877e44319de315b76f5e.1295653400.git.jeremy.fitzhardinge@citrix.com>
In-Reply-To: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
References: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
In-Reply-To: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
References: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@kernel.dk>, Xen-devel <xen-devel@lists.xensource.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
List-ID: <linux-mm.kvack.org>

From: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
---
 arch/x86/xen/mmu.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 38ba804..25da278 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -2292,14 +2292,19 @@ struct remap_data {
 	struct mmu_update *mmu_update;
 };
 
-static int remap_area_mfn_pte_fn(pte_t *ptep, unsigned long addr, void *data)
+static int remap_area_mfn_pte_fn(pte_t *ptep, unsigned count,
+				 unsigned long addr, void *data)
 {
 	struct remap_data *rmd = data;
-	pte_t pte = pte_mkspecial(pfn_pte(rmd->mfn++, rmd->prot));
 
-	rmd->mmu_update->ptr = arbitrary_virt_to_machine(ptep).maddr;
-	rmd->mmu_update->val = pte_val_ma(pte);
-	rmd->mmu_update++;
+	while (count--) {
+		pte_t pte = pte_mkspecial(pfn_pte(rmd->mfn++, rmd->prot));
+
+		rmd->mmu_update->ptr = arbitrary_virt_to_machine(ptep).maddr;
+		rmd->mmu_update->val = pte_val_ma(pte);
+		rmd->mmu_update++;
+		ptep++;
+	}
 
 	return 0;
 }
@@ -2328,8 +2333,8 @@ int xen_remap_domain_mfn_range(struct vm_area_struct *vma,
 		range = (unsigned long)batch << PAGE_SHIFT;
 
 		rmd.mmu_update = mmu_update;
-		err = apply_to_page_range(vma->vm_mm, addr, range,
-					  remap_area_mfn_pte_fn, &rmd);
+		err = apply_to_page_range_batch(vma->vm_mm, addr, range,
+						remap_area_mfn_pte_fn, &rmd);
 		if (err)
 			goto out;
 
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
