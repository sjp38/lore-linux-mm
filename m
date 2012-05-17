Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 974D96B0083
	for <linux-mm@kvack.org>; Thu, 17 May 2012 09:16:02 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M46005MS4V3GV50@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 14:16:15 +0100 (BST)
Received: from ubuntu.arm.acom ([106.210.236.191])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M46005864TPC2@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 14:15:58 +0100 (BST)
Date: Thu, 17 May 2012 15:13:53 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv10 03/11] ARM: dma-mapping: use pr_* instread of printk
In-reply-to: <1337260441-8121-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1337260441-8121-4-git-send-email-m.szyprowski@samsung.com>
References: <1337260441-8121-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

Replace all calls to printk with pr_* functions family.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
Tested-By: Subash Patel <subash.ramaswamy@linaro.org>
---
 arch/arm/mm/dma-mapping.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 7ec0863..322c70a 100644
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
@@ -222,7 +222,7 @@ __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot,
 	int bit;
 
 	if (!consistent_pte) {
-		printk(KERN_ERR "%s: not initialised\n", __func__);
+		pr_err("%s: not initialised\n", __func__);
 		dump_stack();
 		return NULL;
 	}
@@ -281,14 +281,14 @@ static void __dma_free_remap(void *cpu_addr, size_t size)
 
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
@@ -310,8 +310,8 @@ static void __dma_free_remap(void *cpu_addr, size_t size)
 		}
 
 		if (pte_none(pte) || !pte_present(pte))
-			printk(KERN_CRIT "%s: bad page in kernel page table\n",
-			       __func__);
+			pr_crit("%s: bad page in kernel page table\n",
+				__func__);
 	} while (size -= PAGE_SIZE);
 
 	flush_tlb_kernel_range(c->vm_start, c->vm_end);
-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
