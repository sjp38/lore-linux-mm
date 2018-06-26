Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 96DC46B027A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 13:02:28 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 130-v6so5713851oii.8
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:02:28 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p205-v6si635038oib.291.2018.06.26.10.02.26
        for <linux-mm@kvack.org>;
        Tue, 26 Jun 2018 10:02:27 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v5 09/20] ACPI / APEI: Let the notification helper specify the fixmap slot
Date: Tue, 26 Jun 2018 18:01:05 +0100
Message-Id: <20180626170116.25825-10-james.morse@arm.com>
In-Reply-To: <20180626170116.25825-1-james.morse@arm.com>
References: <20180626170116.25825-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

ghes_copy_tofrom_phys() uses a different fixmap slot depending on in_nmi().
This doesn't work when we have multiple NMI-like notifications, that
can interrupt each other.

As with the locking, move the chosen fixmap_idx to the notification helper.
This only matters for NMI-like notifications, anything calling
ghes_proc() can use the IRQ fixmap slot.

This lets us collapse the ghes_ioremap_pfn_*() helpers.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 73 ++++++++++++----------------------------
 1 file changed, 21 insertions(+), 52 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index f30e6fae57c0..77505cfa930e 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -129,38 +129,16 @@ static atomic_t ghes_estatus_cache_alloced;
 
 static int ghes_panic_timeout __read_mostly = 30;
 
-static void __iomem *ghes_ioremap_pfn_nmi(u64 pfn)
+static void __iomem *ghes_fixmap(u64 pfn, int fixmap_idx)
 {
 	phys_addr_t paddr;
 	pgprot_t prot;
 
 	paddr = pfn << PAGE_SHIFT;
 	prot = arch_apei_get_mem_attribute(paddr);
-	__set_fixmap(FIX_APEI_GHES_NMI, paddr, prot);
+	__set_fixmap(fixmap_idx, paddr, prot);
 
-	return (void __iomem *) fix_to_virt(FIX_APEI_GHES_NMI);
-}
-
-static void __iomem *ghes_ioremap_pfn_irq(u64 pfn)
-{
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
-
-static void ghes_iounmap_irq(void)
-{
-	clear_fixmap(FIX_APEI_GHES_IRQ);
+	return (void __iomem *) __fix_to_virt(fixmap_idx);
 }
 
 static int ghes_estatus_pool_init(void)
@@ -289,20 +267,15 @@ static inline int ghes_severity(int severity)
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
+		vaddr = ghes_fixmap(paddr >> PAGE_SHIFT, fixmap_idx);
 		trunk = PAGE_SIZE - offset;
 		trunk = min(trunk, len);
 		if (from_phys)
@@ -312,15 +285,11 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 		len -= trunk;
 		paddr += trunk;
 		buffer += trunk;
-		if (in_nmi) {
-			ghes_iounmap_nmi();
-		} else {
-			ghes_iounmap_irq();
-		}
+		clear_fixmap(fixmap_idx);
 	}
 }
 
-static int ghes_read_estatus(struct ghes *ghes, int silent)
+static int ghes_read_estatus(struct ghes *ghes, int silent, int fixmap_idx)
 {
 	struct acpi_hest_generic *g = ghes->generic;
 	u64 buf_paddr;
@@ -339,7 +308,7 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
 		return -ENOENT;
 
 	ghes_copy_tofrom_phys(ghes->estatus, buf_paddr,
-			      sizeof(*ghes->estatus), 1);
+			      sizeof(*ghes->estatus), 1, fixmap_idx);
 	if (!ghes->estatus->block_status)
 		return -ENOENT;
 
@@ -356,7 +325,7 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
 		goto err_read_block;
 	ghes_copy_tofrom_phys(ghes->estatus + 1,
 			      buf_paddr + sizeof(*ghes->estatus),
-			      len - sizeof(*ghes->estatus), 1);
+			      len - sizeof(*ghes->estatus), 1, fixmap_idx);
 	if (cper_estatus_check(ghes->estatus))
 		goto err_read_block;
 	rc = 0;
@@ -368,13 +337,13 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
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
 
@@ -740,12 +709,12 @@ static void __process_error(struct ghes *ghes)
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
 
@@ -759,19 +728,19 @@ static int _in_nmi_notify_one(struct ghes *ghes)
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
@@ -879,7 +848,7 @@ static int ghes_proc(struct ghes *ghes)
 
 	spin_lock_irqsave(&ghes_notify_lock_irq, flags);
 
-	rc = ghes_read_estatus(ghes, 0);
+	rc = ghes_read_estatus(ghes, 0, FIX_APEI_GHES_IRQ);
 	if (rc)
 		goto out;
 
@@ -894,7 +863,7 @@ static int ghes_proc(struct ghes *ghes)
 	ghes_do_proc(ghes, ghes->estatus);
 
 out:
-	ghes_clear_estatus(ghes);
+	ghes_clear_estatus(ghes, FIX_APEI_GHES_IRQ);
 
 	if (rc == -ENOENT)
 		goto unlock;
@@ -981,7 +950,7 @@ int ghes_notify_sea(void)
 	int rv;
 
 	raw_spin_lock(&ghes_notify_lock_sea);
-	rv = ghes_estatus_queue_notified(&ghes_sea);
+	rv = ghes_estatus_queue_notified(&ghes_sea, FIX_APEI_GHES_NMI);
 	raw_spin_unlock(&ghes_notify_lock_sea);
 
 	return rv;
@@ -1028,7 +997,7 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 		return ret;
 
 	raw_spin_lock(&ghes_notify_lock_nmi);
-	if (!ghes_estatus_queue_notified(&ghes_nmi))
+	if (!ghes_estatus_queue_notified(&ghes_nmi, FIX_APEI_GHES_NMI))
 		ret = NMI_HANDLED;
 	raw_spin_unlock(&ghes_notify_lock_nmi);
 
-- 
2.17.1
