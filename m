Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2528E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:18:20 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b8-v6so13460044oib.4
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:18:20 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s10-v6si9240045oth.173.2018.09.21.15.18.18
        for <linux-mm@kvack.org>;
        Fri, 21 Sep 2018 15:18:18 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v6 08/18] ACPI / APEI: Move locking to the notification helper
Date: Fri, 21 Sep 2018 23:16:55 +0100
Message-Id: <20180921221705.6478-9-james.morse@arm.com>
In-Reply-To: <20180921221705.6478-1-james.morse@arm.com>
References: <20180921221705.6478-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

ghes_copy_tofrom_phys() takes different locks depending on in_nmi().
This doesn't work when we have multiple NMI-like notifications, that
can interrupt each other.

Now that NOTIFY_SEA is always called as an NMI, move the lock-taking
to the notification helper. The helper will always know which lock
to take. This avoids ghes_copy_tofrom_phys() taking a guess based
on in_nmi().

This splits NOTIFY_NMI and NOTIFY_SEA to use different locks. All
the other notifications use ghes_proc(), and are called in process
or IRQ context. Move the spin_lock_irqsave() around their ghes_proc()
calls.

Signed-off-by: James Morse <james.morse@arm.com>
---
Changes since v5:
 * Moved locking further out, to allow no-irq-masking in the future.


 drivers/acpi/apei/ghes.c | 40 +++++++++++++++++++++++++++++-----------
 1 file changed, 29 insertions(+), 11 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 2880547e13b8..ed8669a6c100 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -113,12 +113,13 @@ static DEFINE_MUTEX(ghes_list_mutex);
  * from BIOS to Linux can be determined only in NMI, IRQ or timer
  * handler, but general ioremap can not be used in atomic context, so
  * the fixmap is used instead.
- *
- * These 2 spinlocks are used to prevent the fixmap entries from being used
- * simultaneously.
  */
-static DEFINE_RAW_SPINLOCK(ghes_ioremap_lock_nmi);
-static DEFINE_SPINLOCK(ghes_ioremap_lock_irq);
+
+/*
+ * Used by ghes_proc() to prevent non-NMI notifications from interacting.
+ * This also protects the FIX_APEI_GHES_IRQ fixmap slot.
+ */
+static DEFINE_SPINLOCK(ghes_notify_lock_irq);
 
 static struct gen_pool *ghes_estatus_pool;
 static unsigned long ghes_estatus_pool_size_request;
@@ -291,7 +292,6 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 				  int from_phys)
 {
 	void __iomem *vaddr;
-	unsigned long flags = 0;
 	int in_nmi = in_nmi();
 	u64 offset;
 	u32 trunk;
@@ -299,10 +299,8 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 	while (len > 0) {
 		offset = paddr - (paddr & PAGE_MASK);
 		if (in_nmi) {
-			raw_spin_lock(&ghes_ioremap_lock_nmi);
 			vaddr = ghes_ioremap_pfn_nmi(paddr >> PAGE_SHIFT);
 		} else {
-			spin_lock_irqsave(&ghes_ioremap_lock_irq, flags);
 			vaddr = ghes_ioremap_pfn_irq(paddr >> PAGE_SHIFT);
 		}
 		trunk = PAGE_SIZE - offset;
@@ -316,10 +314,8 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 		buffer += trunk;
 		if (in_nmi) {
 			ghes_iounmap_nmi();
-			raw_spin_unlock(&ghes_ioremap_lock_nmi);
 		} else {
 			ghes_iounmap_irq();
-			spin_unlock_irqrestore(&ghes_ioremap_lock_irq, flags);
 		}
 	}
 }
@@ -928,8 +924,11 @@ static void ghes_add_timer(struct ghes *ghes)
 static void ghes_poll_func(struct timer_list *t)
 {
 	struct ghes *ghes = from_timer(ghes, t, timer);
+	unsigned long flags;
 
+	spin_lock_irqsave(&ghes_notify_lock_irq, flags);
 	ghes_proc(ghes);
+	spin_unlock_irqrestore(&ghes_notify_lock_irq, flags);
 	if (!(ghes->flags & GHES_EXITING))
 		ghes_add_timer(ghes);
 }
@@ -937,9 +936,12 @@ static void ghes_poll_func(struct timer_list *t)
 static irqreturn_t ghes_irq_func(int irq, void *data)
 {
 	struct ghes *ghes = data;
+	unsigned long flags;
 	int rc;
 
+	spin_lock_irqsave(&ghes_notify_lock_irq, flags);
 	rc = ghes_proc(ghes);
+	spin_unlock_irqrestore(&ghes_notify_lock_irq, flags);
 	if (rc)
 		return IRQ_NONE;
 
@@ -950,14 +952,17 @@ static int ghes_notify_hed(struct notifier_block *this, unsigned long event,
 			   void *data)
 {
 	struct ghes *ghes;
+	unsigned long flags;
 	int ret = NOTIFY_DONE;
 
+	spin_lock_irqsave(&ghes_notify_lock_irq, flags);
 	rcu_read_lock();
 	list_for_each_entry_rcu(ghes, &ghes_hed, list) {
 		if (!ghes_proc(ghes))
 			ret = NOTIFY_OK;
 	}
 	rcu_read_unlock();
+	spin_unlock_irqrestore(&ghes_notify_lock_irq, flags);
 
 	return ret;
 }
@@ -968,6 +973,7 @@ static struct notifier_block ghes_notifier_hed = {
 
 #ifdef CONFIG_ACPI_APEI_SEA
 static LIST_HEAD(ghes_sea);
+static DEFINE_RAW_SPINLOCK(ghes_notify_lock_sea);
 
 /*
  * Return 0 only if one of the SEA error sources successfully reported an error
@@ -975,7 +981,13 @@ static LIST_HEAD(ghes_sea);
  */
 int ghes_notify_sea(void)
 {
-	return ghes_estatus_queue_notified(&ghes_sea);
+	int rv;
+
+	raw_spin_lock(&ghes_notify_lock_sea);
+	rv = ghes_estatus_queue_notified(&ghes_sea);
+	raw_spin_unlock(&ghes_notify_lock_sea);
+
+	return rv;
 }
 
 static void ghes_sea_add(struct ghes *ghes)
@@ -1009,6 +1021,7 @@ static inline void ghes_sea_remove(struct ghes *ghes) { }
 static atomic_t ghes_in_nmi = ATOMIC_INIT(0);
 
 static LIST_HEAD(ghes_nmi);
+static DEFINE_RAW_SPINLOCK(ghes_notify_lock_nmi);
 
 static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 {
@@ -1017,8 +1030,10 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 	if (!atomic_add_unless(&ghes_in_nmi, 1, 1))
 		return ret;
 
+	raw_spin_lock(&ghes_notify_lock_nmi);
 	if (!ghes_estatus_queue_notified(&ghes_nmi))
 		ret = NMI_HANDLED;
+	raw_spin_unlock(&ghes_notify_lock_nmi);
 
 	atomic_dec(&ghes_in_nmi);
 	return ret;
@@ -1060,6 +1075,7 @@ static int ghes_probe(struct platform_device *ghes_dev)
 {
 	struct acpi_hest_generic *generic;
 	struct ghes *ghes = NULL;
+	unsigned long flags;
 
 	int rc = -EINVAL;
 
@@ -1162,7 +1178,9 @@ static int ghes_probe(struct platform_device *ghes_dev)
 	ghes_edac_register(ghes, &ghes_dev->dev);
 
 	/* Handle any pending errors right away */
+	spin_lock_irqsave(&ghes_notify_lock_irq, flags);
 	ghes_proc(ghes);
+	spin_unlock_irqrestore(&ghes_notify_lock_irq, flags);
 
 	return 0;
 
-- 
2.19.0
