Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8DC78E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:18:24 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id k18-v6so13786890otl.16
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:18:24 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u30-v6si10976626otb.374.2018.09.21.15.18.23
        for <linux-mm@kvack.org>;
        Fri, 21 Sep 2018 15:18:23 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v6 09/18] ACPI / APEI: Let the notification helper specify the fixmap slot
Date: Fri, 21 Sep 2018 23:16:56 +0100
Message-Id: <20180921221705.6478-10-james.morse@arm.com>
In-Reply-To: <20180921221705.6478-1-james.morse@arm.com>
References: <20180921221705.6478-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

ghes_copy_tofrom_phys() uses a different fixmap slot depending on in_nmi().
This doesn't work when we have multiple NMI-like notifications, that
can interrupt each other.

As with the locking, move the chosen fixmap_idx to the notification helper.
This only matters for NMI-like notifications, anything calling
ghes_proc() can use the IRQ fixmap slot as its already holding an irqsave
spinlock.

This lets us collapse the ghes_ioremap_pfn_*() helpers.

Signed-off-by: James Morse <james.morse@arm.com>
---

The fixmap-idx and vaddr are passed back to ghes_unmap()
to allow ioremap() to be used in process context in the
future.
---
 drivers/acpi/apei/ghes.c | 76 ++++++++++++++--------------------------
 1 file changed, 27 insertions(+), 49 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index ed8669a6c100..adf7fd402813 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -41,6 +41,7 @@
 #include <linux/llist.h>
 #include <linux/genalloc.h>
 #include <linux/pci.h>
+#include <linux/pfn.h>
 #include <linux/aer.h>
 #include <linux/nmi.h>
 #include <linux/sched/clock.h>
@@ -129,38 +130,24 @@ static atomic_t ghes_estatus_cache_alloced;
 
 static int ghes_panic_timeout __read_mostly = 30;
 
-static void __iomem *ghes_ioremap_pfn_nmi(u64 pfn)
+static void __iomem *ghes_map(u64 pfn, int fixmap_idx)
 {
 	phys_addr_t paddr;
 	pgprot_t prot;
 
-	paddr = pfn << PAGE_SHIFT;
+	paddr = PFN_PHYS(pfn);
 	prot = arch_apei_get_mem_attribute(paddr);
-	__set_fixmap(FIX_APEI_GHES_NMI, paddr, prot);
+	__set_fixmap(fixmap_idx, paddr, prot);
 
-	return (void __iomem *) fix_to_virt(FIX_APEI_GHES_NMI);
+	return (void __iomem *) __fix_to_virt(fixmap_idx);
 }
 
-static void __iomem *ghes_ioremap_pfn_irq(u64 pfn)
+static void ghes_unmap(int fixmap_idx, void __iomem *vaddr)
 {
-	phys_addr_t paddr;
-	pgprot_t prot;
-
-	paddr = pfn << PAGE_SHIFT;
-	prot = arch_apei_get_mem_attribute(paddr);
-	__set_fixmap(FIX_APEI_GHES_IRQ, paddr, prot);
-
-	return (void __iomem *) fix_to_virt(FIX_APEI_GHES_IRQ);
-}
-
-static void ghes_iounmap_nmi(void)
-{
-	clear_fixmap(FIX_APEI_GHES_NMI);
-}
+	int _idx = virt_to_fix((unsigned long)vaddr);
 
-static void ghes_iounmap_irq(void)
-{
-	clear_fixmap(FIX_APEI_GHES_IRQ);
+	WARN_ON_ONCE(fixmap_idx != _idx);
+	clear_fixmap(fixmap_idx);
 }
 
 static int ghes_estatus_pool_init(void)
@@ -289,20 +276,15 @@ static inline int ghes_severity(int severity)
 }
 
 static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
-				  int from_phys)
+				  int from_phys, int fixmap_idx)
 {
 	void __iomem *vaddr;
-	int in_nmi = in_nmi();
 	u64 offset;
 	u32 trunk;
 
 	while (len > 0) {
 		offset = paddr - (paddr & PAGE_MASK);
-		if (in_nmi) {
-			vaddr = ghes_ioremap_pfn_nmi(paddr >> PAGE_SHIFT);
-		} else {
-			vaddr = ghes_ioremap_pfn_irq(paddr >> PAGE_SHIFT);
-		}
+		vaddr = ghes_map(PHYS_PFN(paddr), fixmap_idx);
 		trunk = PAGE_SIZE - offset;
 		trunk = min(trunk, len);
 		if (from_phys)
@@ -312,15 +294,11 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 		len -= trunk;
 		paddr += trunk;
 		buffer += trunk;
-		if (in_nmi) {
-			ghes_iounmap_nmi();
-		} else {
-			ghes_iounmap_irq();
-		}
+		ghes_unmap(fixmap_idx, vaddr);
 	}
 }
 
-static int ghes_read_estatus(struct ghes *ghes, int silent)
+static int ghes_read_estatus(struct ghes *ghes, int silent, int fixmap_idx)
 {
 	struct acpi_hest_generic *g = ghes->generic;
 	u64 buf_paddr;
@@ -339,7 +317,7 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
 		return -ENOENT;
 
 	ghes_copy_tofrom_phys(ghes->estatus, buf_paddr,
-			      sizeof(*ghes->estatus), 1);
+			      sizeof(*ghes->estatus), 1, fixmap_idx);
 	if (!ghes->estatus->block_status)
 		return -ENOENT;
 
@@ -356,7 +334,7 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
 		goto err_read_block;
 	ghes_copy_tofrom_phys(ghes->estatus + 1,
 			      buf_paddr + sizeof(*ghes->estatus),
-			      len - sizeof(*ghes->estatus), 1);
+			      len - sizeof(*ghes->estatus), 1, fixmap_idx);
 	if (cper_estatus_check(ghes->estatus))
 		goto err_read_block;
 	rc = 0;
@@ -368,13 +346,13 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
 	return rc;
 }
 
-static void ghes_clear_estatus(struct ghes *ghes)
+static void ghes_clear_estatus(struct ghes *ghes, int fixmap_idx)
 {
 	ghes->estatus->block_status = 0;
 	if (!(ghes->flags & GHES_TO_CLEAR))
 		return;
 	ghes_copy_tofrom_phys(ghes->estatus, ghes->buffer_paddr,
-			      sizeof(ghes->estatus->block_status), 0);
+			      sizeof(ghes->estatus->block_status), 0, fixmap_idx);
 	ghes->flags &= ~GHES_TO_CLEAR;
 }
 
@@ -740,12 +718,12 @@ static void __process_error(struct ghes *ghes)
 	llist_add(&estatus_node->llnode, &ghes_estatus_llist);
 }
 
-static int _in_nmi_notify_one(struct ghes *ghes)
+static int _in_nmi_notify_one(struct ghes *ghes, int fixmap_idx)
 {
 	int sev;
 
-	if (ghes_read_estatus(ghes, 1)) {
-		ghes_clear_estatus(ghes);
+	if (ghes_read_estatus(ghes, 1, fixmap_idx)) {
+		ghes_clear_estatus(ghes, fixmap_idx);
 		return -ENOENT;
 	}
 
@@ -759,19 +737,19 @@ static int _in_nmi_notify_one(struct ghes *ghes)
 		return 0;
 
 	__process_error(ghes);
-	ghes_clear_estatus(ghes);
+	ghes_clear_estatus(ghes, fixmap_idx);
 
 	return 0;
 }
 
-static int ghes_estatus_queue_notified(struct list_head *rcu_list)
+static int ghes_estatus_queue_notified(struct list_head *rcu_list, int fixmap_idx)
 {
 	int ret = -ENOENT;
 	struct ghes *ghes;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ghes, rcu_list, list) {
-		if (!_in_nmi_notify_one(ghes))
+		if (!_in_nmi_notify_one(ghes, fixmap_idx))
 			ret = 0;
 	}
 	rcu_read_unlock();
@@ -876,7 +854,7 @@ static int ghes_proc(struct ghes *ghes)
 {
 	int rc;
 
-	rc = ghes_read_estatus(ghes, 0);
+	rc = ghes_read_estatus(ghes, 0, FIX_APEI_GHES_IRQ);
 	if (rc)
 		goto out;
 
@@ -891,7 +869,7 @@ static int ghes_proc(struct ghes *ghes)
 	ghes_do_proc(ghes, ghes->estatus);
 
 out:
-	ghes_clear_estatus(ghes);
+	ghes_clear_estatus(ghes, FIX_APEI_GHES_IRQ);
 
 	if (rc == -ENOENT)
 		return rc;
@@ -984,7 +962,7 @@ int ghes_notify_sea(void)
 	int rv;
 
 	raw_spin_lock(&ghes_notify_lock_sea);
-	rv = ghes_estatus_queue_notified(&ghes_sea);
+	rv = ghes_estatus_queue_notified(&ghes_sea, FIX_APEI_GHES_NMI);
 	raw_spin_unlock(&ghes_notify_lock_sea);
 
 	return rv;
@@ -1031,7 +1009,7 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 		return ret;
 
 	raw_spin_lock(&ghes_notify_lock_nmi);
-	if (!ghes_estatus_queue_notified(&ghes_nmi))
+	if (!ghes_estatus_queue_notified(&ghes_nmi, FIX_APEI_GHES_NMI))
 		ret = NMI_HANDLED;
 	raw_spin_unlock(&ghes_notify_lock_nmi);
 
-- 
2.19.0
