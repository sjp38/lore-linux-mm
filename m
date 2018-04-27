Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47F156B000D
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 11:38:47 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b192-v6so1216505oii.12
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 08:38:47 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d10-v6si523112oia.5.2018.04.27.08.38.45
        for <linux-mm@kvack.org>;
        Fri, 27 Apr 2018 08:38:46 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v3 07/12] ACPI / APEI: Make the nmi_fixmap_idx per-ghes to allow multiple in_nmi() users
Date: Fri, 27 Apr 2018 16:35:05 +0100
Message-Id: <20180427153510.5799-8-james.morse@arm.com>
In-Reply-To: <20180427153510.5799-1-james.morse@arm.com>
References: <20180427153510.5799-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

Arm64 has multiple NMI-like notifications, but ghes.c only has one
in_nmi() path, risking deadlock if one NMI-like notification can
interrupt another.

To support this we need a fixmap entry and lock for each notification
type. But ghes_probe() attempts to process each struct ghes at probe
time, to ensure any error that was notified before ghes_probe() was
called has been done, and the buffer released (and maybe acknowledge
to firmware) so that future errors can be delivered.

This means NMI-like notifications need two fixmap entries and locks,
one for the ghes_probe() time call, and another for the actual NMI
that could interrupt ghes_probe().

Split this single path up by adding an NMI fixmap idx and lock into
the struct ghes. Any notification that can be called as an NMI can
use these to separate its resources from any other notification it
may interrupt.

The majority of notifications occur in IRQ context, so unless its
called in_nmi(), ghes_copy_tofrom_phys() will use the FIX_APEI_GHES_IRQ
fixmap entry and the ghes_fixmap_lock_irq lock. This allows
NMI-notifications to be processed by ghes_probe(), and then taken
as an NMI.

The double-underscore version of fix_to_virt() is used because the index
to be mapped can't be tested against the end of the enum at compile
time.

Signed-off-by: James Morse <james.morse@arm.com>

---
Changes since v1:
 * Fixed for ghes_proc() always calling every notification in process context.
   Now only NMI-like notifications need an additional fixmap-slot/lock.

 drivers/acpi/apei/ghes.c | 70 +++++++++++++++++-------------------------------
 include/acpi/ghes.h      |  4 +++
 2 files changed, 28 insertions(+), 46 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 1859f27c37ff..48d9eb55ebb8 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -117,12 +117,9 @@ static DEFINE_MUTEX(ghes_list_mutex);
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
@@ -132,38 +129,16 @@ static atomic_t ghes_estatus_cache_alloced;
 
 static int ghes_panic_timeout __read_mostly = 30;
 
-static void __iomem *ghes_ioremap_pfn_nmi(u64 pfn)
-{
-	phys_addr_t paddr;
-	pgprot_t prot;
-
-	paddr = pfn << PAGE_SHIFT;
-	prot = arch_apei_get_mem_attribute(paddr);
-	__set_fixmap(FIX_APEI_GHES_NMI, paddr, prot);
-
-	return (void __iomem *) fix_to_virt(FIX_APEI_GHES_NMI);
-}
-
-static void __iomem *ghes_ioremap_pfn_irq(u64 pfn)
+static void __iomem *ghes_fixmap_pfn(int fixmap_idx, u64 pfn)
 {
 	phys_addr_t paddr;
 	pgprot_t prot;
 
 	paddr = pfn << PAGE_SHIFT;
 	prot = arch_apei_get_mem_attribute(paddr);
-	__set_fixmap(FIX_APEI_GHES_IRQ, paddr, prot);
+	__set_fixmap(fixmap_idx, paddr, prot);
 
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
@@ -291,10 +266,11 @@ static inline int ghes_severity(int severity)
 	}
 }
 
-static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
-				  int from_phys)
+static void ghes_copy_tofrom_phys(struct ghes *ghes, void *buffer, u64 paddr,
+				  u32 len, int from_phys)
 {
 	void __iomem *vaddr;
+	int fixmap_idx = FIX_APEI_GHES_IRQ;
 	unsigned long flags = 0;
 	int in_nmi = in_nmi();
 	u64 offset;
@@ -303,12 +279,12 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 	while (len > 0) {
 		offset = paddr - (paddr & PAGE_MASK);
 		if (in_nmi) {
-			raw_spin_lock(&ghes_ioremap_lock_nmi);
-			vaddr = ghes_ioremap_pfn_nmi(paddr >> PAGE_SHIFT);
+			raw_spin_lock(ghes->nmi_fixmap_lock);
+			fixmap_idx = ghes->nmi_fixmap_idx;
 		} else {
-			spin_lock_irqsave(&ghes_ioremap_lock_irq, flags);
-			vaddr = ghes_ioremap_pfn_irq(paddr >> PAGE_SHIFT);
+			spin_lock_irqsave(&ghes_fixmap_lock_irq, flags);
 		}
+		vaddr = ghes_fixmap_pfn(fixmap_idx, paddr >> PAGE_SHIFT);
 		trunk = PAGE_SIZE - offset;
 		trunk = min(trunk, len);
 		if (from_phys)
@@ -318,13 +294,11 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
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
+		clear_fixmap(fixmap_idx);
+		if (in_nmi)
+			raw_spin_unlock(ghes->nmi_fixmap_lock);
+		else
+			spin_unlock_irqrestore(&ghes_fixmap_lock_irq, flags);
 	}
 }
 
@@ -346,7 +320,7 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
 	if (!buf_paddr)
 		return -ENOENT;
 
-	ghes_copy_tofrom_phys(ghes->estatus, buf_paddr,
+	ghes_copy_tofrom_phys(ghes, ghes->estatus, buf_paddr,
 			      sizeof(*ghes->estatus), 1);
 	if (!ghes->estatus->block_status)
 		return -ENOENT;
@@ -362,7 +336,7 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
 		goto err_read_block;
 	if (cper_estatus_check_header(ghes->estatus))
 		goto err_read_block;
-	ghes_copy_tofrom_phys(ghes->estatus + 1,
+	ghes_copy_tofrom_phys(ghes, ghes->estatus + 1,
 			      buf_paddr + sizeof(*ghes->estatus),
 			      len - sizeof(*ghes->estatus), 1);
 	if (cper_estatus_check(ghes->estatus))
@@ -381,7 +355,7 @@ static void ghes_clear_estatus(struct ghes *ghes)
 	ghes->estatus->block_status = 0;
 	if (!(ghes->flags & GHES_TO_CLEAR))
 		return;
-	ghes_copy_tofrom_phys(ghes->estatus, ghes->buffer_paddr,
+	ghes_copy_tofrom_phys(ghes, ghes->estatus, ghes->buffer_paddr,
 			      sizeof(ghes->estatus->block_status), 0);
 	ghes->flags &= ~GHES_TO_CLEAR;
 }
@@ -986,6 +960,8 @@ int ghes_notify_sea(void)
 
 static void ghes_sea_add(struct ghes *ghes)
 {
+	ghes->nmi_fixmap_lock = &ghes_fixmap_lock_nmi;
+	ghes->nmi_fixmap_idx = FIX_APEI_GHES_NMI;
 	ghes_estatus_queue_grow_pool(ghes);
 
 	mutex_lock(&ghes_list_mutex);
@@ -1032,6 +1008,8 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 
 static void ghes_nmi_add(struct ghes *ghes)
 {
+	ghes->nmi_fixmap_lock = &ghes_fixmap_lock_nmi;
+	ghes->nmi_fixmap_idx = FIX_APEI_GHES_NMI;
 	ghes_estatus_queue_grow_pool(ghes);
 
 	mutex_lock(&ghes_list_mutex);
diff --git a/include/acpi/ghes.h b/include/acpi/ghes.h
index 8feb0c866ee0..9c6a92730699 100644
--- a/include/acpi/ghes.h
+++ b/include/acpi/ghes.h
@@ -29,6 +29,10 @@ struct ghes {
 		struct timer_list timer;
 		unsigned int irq;
 	};
+
+	/* If this ghes can be called in NMI contet, these must be populated. */
+	raw_spinlock_t *nmi_fixmap_lock;
+	int nmi_fixmap_idx;
 };
 
 struct ghes_estatus_node {
-- 
2.16.2
