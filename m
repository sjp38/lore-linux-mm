Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 818C06B0010
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:59:11 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id 1so319625oiq.8
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:59:11 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u32si1034739otd.333.2018.02.15.10.59.10
        for <linux-mm@kvack.org>;
        Thu, 15 Feb 2018 10:59:10 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH 06/11] ACPI / APEI: Make the fixmap_idx per-ghes to allow multiple in_nmi() users
Date: Thu, 15 Feb 2018 18:56:01 +0000
Message-Id: <20180215185606.26736-7-james.morse@arm.com>
In-Reply-To: <20180215185606.26736-1-james.morse@arm.com>
References: <20180215185606.26736-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, James Morse <james.morse@arm.com>

Arm64 has multiple NMI-like notifications, but GHES only has one
in_nmi() path. The interactions between these multiple NMI-like
notifications is, unclear.

Split this single path up by moving the fixmap idx and lock into
the struct ghes. Each notification's init function can consider
which other notifications it masks and can share a fixmap_idx with.
This lets us merge the two ghes_ioremap_pfn_* flavours.

Two lock pointers are provided, but only one will be used by
ghes_copy_tofrom_phys(), depending on in_nmi(). This means any
notification that might arrive as an NMI must always be wrapped in
nmi_enter()/nmi_exit().

The double-underscore version of fix_to_virt() is used because
the index to be mapped can't be tested against the end of the
enum at compile time.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 79 ++++++++++++++++++------------------------------
 include/acpi/ghes.h      |  5 +++
 2 files changed, 35 insertions(+), 49 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 7b2504aa23b1..70ccb309a9d8 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -118,12 +118,9 @@ static DEFINE_MUTEX(ghes_list_mutex);
  * from BIOS to Linux can be determined only in NMI, IRQ or timer
  * handler, but general ioremap can not be used in atomic context, so
  * the fixmap is used instead.
- *
- * These 2 spinlocks are used to prevent the fixmap entries from being used
- * simultaneously.
  */
-static DEFINE_RAW_SPINLOCK(ghes_ioremap_lock_nmi);
-static DEFINE_SPINLOCK(ghes_ioremap_lock_irq);
+static DEFINE_RAW_SPINLOCK(ghes_fixmap_lock_nmi);
+static DEFINE_SPINLOCK(ghes_fixmap_lock_irq);
 
 static struct gen_pool *ghes_estatus_pool;
 static unsigned long ghes_estatus_pool_size_request;
@@ -133,38 +130,16 @@ static atomic_t ghes_estatus_cache_alloced;
 
 static int ghes_panic_timeout __read_mostly = 30;
 
-static void __iomem *ghes_ioremap_pfn_nmi(u64 pfn)
+static void __iomem *ghes_fixmap_pfn(int fixmap_idx, u64 pfn)
 {
 	phys_addr_t paddr;
 	pgprot_t prot;
 
 	paddr = pfn << PAGE_SHIFT;
 	prot = arch_apei_get_mem_attribute(paddr);
-	__set_fixmap(FIX_APEI_GHES_NMI, paddr, prot);
-
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
+	__set_fixmap(fixmap_idx, paddr, prot);
 
-static void ghes_iounmap_irq(void)
-{
-	clear_fixmap(FIX_APEI_GHES_IRQ);
+	return (void __iomem *) __fix_to_virt(fixmap_idx);
 }
 
 static int ghes_estatus_pool_init(void)
@@ -292,8 +267,8 @@ static inline int ghes_severity(int severity)
 	}
 }
 
-static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
-				  int from_phys)
+static void ghes_copy_tofrom_phys(struct ghes *ghes, void *buffer, u64 paddr,
+				  u32 len, int from_phys)
 {
 	void __iomem *vaddr;
 	unsigned long flags = 0;
@@ -303,13 +278,11 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 
 	while (len > 0) {
 		offset = paddr - (paddr & PAGE_MASK);
-		if (in_nmi) {
-			raw_spin_lock(&ghes_ioremap_lock_nmi);
-			vaddr = ghes_ioremap_pfn_nmi(paddr >> PAGE_SHIFT);
-		} else {
-			spin_lock_irqsave(&ghes_ioremap_lock_irq, flags);
-			vaddr = ghes_ioremap_pfn_irq(paddr >> PAGE_SHIFT);
-		}
+		if (in_nmi)
+			raw_spin_lock(ghes->nmi_fixmap_lock);
+		else
+			spin_lock_irqsave(ghes->fixmap_lock, flags);
+		vaddr = ghes_fixmap_pfn(ghes->fixmap_idx, paddr >> PAGE_SHIFT);
 		trunk = PAGE_SIZE - offset;
 		trunk = min(trunk, len);
 		if (from_phys)
@@ -319,13 +292,11 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 		len -= trunk;
 		paddr += trunk;
 		buffer += trunk;
-		if (in_nmi) {
-			ghes_iounmap_nmi();
-			raw_spin_unlock(&ghes_ioremap_lock_nmi);
-		} else {
-			ghes_iounmap_irq();
-			spin_unlock_irqrestore(&ghes_ioremap_lock_irq, flags);
-		}
+		clear_fixmap(ghes->fixmap_idx);
+		if (in_nmi)
+			raw_spin_unlock(ghes->nmi_fixmap_lock);
+		else
+			spin_unlock_irqrestore(ghes->fixmap_lock, flags);
 	}
 }
 
@@ -347,7 +318,7 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
 	if (!buf_paddr)
 		return -ENOENT;
 
-	ghes_copy_tofrom_phys(ghes->estatus, buf_paddr,
+	ghes_copy_tofrom_phys(ghes, ghes->estatus, buf_paddr,
 			      sizeof(*ghes->estatus), 1);
 	if (!ghes->estatus->block_status)
 		return -ENOENT;
@@ -363,7 +334,7 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
 		goto err_read_block;
 	if (cper_estatus_check_header(ghes->estatus))
 		goto err_read_block;
-	ghes_copy_tofrom_phys(ghes->estatus + 1,
+	ghes_copy_tofrom_phys(ghes, ghes->estatus + 1,
 			      buf_paddr + sizeof(*ghes->estatus),
 			      len - sizeof(*ghes->estatus), 1);
 	if (cper_estatus_check(ghes->estatus))
@@ -382,7 +353,7 @@ static void ghes_clear_estatus(struct ghes *ghes)
 	ghes->estatus->block_status = 0;
 	if (!(ghes->flags & GHES_TO_CLEAR))
 		return;
-	ghes_copy_tofrom_phys(ghes->estatus, ghes->buffer_paddr,
+	ghes_copy_tofrom_phys(ghes, ghes->estatus, ghes->buffer_paddr,
 			      sizeof(ghes->estatus->block_status), 0);
 	ghes->flags &= ~GHES_TO_CLEAR;
 }
@@ -995,6 +966,8 @@ int ghes_notify_sea(void)
 
 static void ghes_sea_add(struct ghes *ghes)
 {
+	ghes->nmi_fixmap_lock = &ghes_fixmap_lock_nmi;
+	ghes->fixmap_idx = FIX_APEI_GHES_NMI;
 	ghes_estatus_queue_grow_pool(ghes);
 
 	mutex_lock(&ghes_list_mutex);
@@ -1041,6 +1014,8 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 
 static void ghes_nmi_add(struct ghes *ghes)
 {
+	ghes->nmi_fixmap_lock = &ghes_fixmap_lock_nmi;
+	ghes->fixmap_idx = FIX_APEI_GHES_NMI;
 	ghes_estatus_queue_grow_pool(ghes);
 
 	mutex_lock(&ghes_list_mutex);
@@ -1136,11 +1111,15 @@ static int ghes_probe(struct platform_device *ghes_dev)
 
 	switch (generic->notify.type) {
 	case ACPI_HEST_NOTIFY_POLLED:
+		ghes->fixmap_lock = &ghes_fixmap_lock_irq;
+		ghes->fixmap_idx = FIX_APEI_GHES_IRQ;
 		timer_setup(&ghes->timer, ghes_poll_func, TIMER_DEFERRABLE);
 		ghes_add_timer(ghes);
 		break;
 	case ACPI_HEST_NOTIFY_EXTERNAL:
 		/* External interrupt vector is GSI */
+		ghes->fixmap_lock = &ghes_fixmap_lock_irq;
+		ghes->fixmap_idx = FIX_APEI_GHES_IRQ;
 		rc = acpi_gsi_to_irq(generic->notify.vector, &ghes->irq);
 		if (rc) {
 			pr_err(GHES_PFX "Failed to map GSI to IRQ for generic hardware error source: %d\n",
@@ -1159,6 +1138,8 @@ static int ghes_probe(struct platform_device *ghes_dev)
 	case ACPI_HEST_NOTIFY_SCI:
 	case ACPI_HEST_NOTIFY_GSIV:
 	case ACPI_HEST_NOTIFY_GPIO:
+		ghes->fixmap_lock = &ghes_fixmap_lock_irq;
+		ghes->fixmap_idx = FIX_APEI_GHES_IRQ;
 		mutex_lock(&ghes_list_mutex);
 		if (list_empty(&ghes_hed))
 			register_acpi_hed_notifier(&ghes_notifier_hed);
diff --git a/include/acpi/ghes.h b/include/acpi/ghes.h
index 8feb0c866ee0..74dbd164f3fe 100644
--- a/include/acpi/ghes.h
+++ b/include/acpi/ghes.h
@@ -29,6 +29,11 @@ struct ghes {
 		struct timer_list timer;
 		unsigned int irq;
 	};
+
+	spinlock_t *fixmap_lock;
+	raw_spinlock_t *nmi_fixmap_lock;
+
+	int fixmap_idx;
 };
 
 struct ghes_estatus_node {
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
