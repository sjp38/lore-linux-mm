Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id CEFDB6B007E
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 10:04:46 -0500 (EST)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M0500B29TVVK4@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 29 Feb 2012 15:04:43 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M0500HNZTVWUE@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 29 Feb 2012 15:04:44 +0000 (GMT)
Date: Wed, 29 Feb 2012 16:04:15 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv7 2/9] ARM: dma-mapping: use pr_* instread of printk
In-reply-to: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1330527862-16234-3-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Replace all calls to printk with pr_* functions family.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/mm/dma-mapping.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 496b453..3ca9f40 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -184,14 +184,14 @@ static int __init consistent_init(void)
 
 		pud = pud_alloc(&init_mm, pgd, base);
 		if (!pud) {
-			printk(KERN_ERR "%s: no pud tables\n", __func__);
+			pr_err("%s: no pud tables\n", __func__);
 			ret = -ENOMEM;
 			break;
 		}
 
 		pmd = pmd_alloc(&init_mm, pud, base);
 		if (!pmd) {
-			printk(KERN_ERR "%s: no pmd tables\n", __func__);
+			pr_err("%s: no pmd tables\n", __func__);
 			ret = -ENOMEM;
 			break;
 		}
@@ -199,7 +199,7 @@ static int __init consistent_init(void)
 
 		pte = pte_alloc_kernel(pmd, base);
 		if (!pte) {
-			printk(KERN_ERR "%s: no pte tables\n", __func__);
+			pr_err("%s: no pte tables\n", __func__);
 			ret = -ENOMEM;
 			break;
 		}
@@ -221,7 +221,7 @@ __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot)
 	int bit;
 
 	if (!consistent_pte) {
-		printk(KERN_ERR "%s: not initialised\n", __func__);
+		pr_err("%s: not initialised\n", __func__);
 		dump_stack();
 		return NULL;
 	}
@@ -280,14 +280,14 @@ static void __dma_free_remap(void *cpu_addr, size_t size)
 
 	c = arm_vmregion_find_remove(&consistent_head, (unsigned long)cpu_addr);
 	if (!c) {
-		printk(KERN_ERR "%s: trying to free invalid coherent area: %p\n",
+		pr_err("%s: trying to free invalid coherent area: %p\n",
 		       __func__, cpu_addr);
 		dump_stack();
 		return;
 	}
 
 	if ((c->vm_end - c->vm_start) != size) {
-		printk(KERN_ERR "%s: freeing wrong coherent size (%ld != %d)\n",
+		pr_err("%s: freeing wrong coherent size (%ld != %d)\n",
 		       __func__, c->vm_end - c->vm_start, size);
 		dump_stack();
 		size = c->vm_end - c->vm_start;
@@ -309,8 +309,8 @@ static void __dma_free_remap(void *cpu_addr, size_t size)
 		}
 
 		if (pte_none(pte) || !pte_present(pte))
-			printk(KERN_CRIT "%s: bad page in kernel page table\n",
-			       __func__);
+			pr_crit("%s: bad page in kernel page table\n",
+				__func__);
 	} while (size -= PAGE_SIZE);
 
 	flush_tlb_kernel_range(c->vm_start, c->vm_end);
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
