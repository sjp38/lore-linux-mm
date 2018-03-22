Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0B8B6B000A
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 14:18:05 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id w12-v6so5300317otj.18
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:18:05 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j2-v6si2209660ota.135.2018.03.22.11.18.04
        for <linux-mm@kvack.org>;
        Thu, 22 Mar 2018 11:18:04 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v2 07/11] ACPI / APEI: Split fixmap pages for arm64 NMI-like notifications
Date: Thu, 22 Mar 2018 18:14:41 +0000
Message-Id: <20180322181445.23298-8-james.morse@arm.com>
In-Reply-To: <20180322181445.23298-1-james.morse@arm.com>
References: <20180322181445.23298-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, James Morse <james.morse@arm.com>

Now that ghes uses the fixmap addresses and locks via some indirection
we can support multiple NMI-like notifications on arm64.

These should be named after their notification method. x86's
NOTIFY_NMI already is, change the SEA fixmap entry to be called
FIX_APEI_GHES_SEA.

Future patches can add support for FIX_APEI_GHES_SEI and
FIX_APEI_GHES_SDEI_{NORMAL,CRITICAL}.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
---
 arch/arm64/include/asm/fixmap.h |  4 +++-
 drivers/acpi/apei/ghes.c        | 11 ++++++-----
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/include/asm/fixmap.h b/arch/arm64/include/asm/fixmap.h
index ec1e6d6fa14c..c3974517c2cb 100644
--- a/arch/arm64/include/asm/fixmap.h
+++ b/arch/arm64/include/asm/fixmap.h
@@ -55,7 +55,9 @@ enum fixed_addresses {
 #ifdef CONFIG_ACPI_APEI_GHES
 	/* Used for GHES mapping from assorted contexts */
 	FIX_APEI_GHES_IRQ,
-	FIX_APEI_GHES_NMI,
+#ifdef CONFIG_ACPI_APEI_SEA
+	FIX_APEI_GHES_SEA,
+#endif
 #endif /* CONFIG_ACPI_APEI_GHES */
 
 #ifdef CONFIG_UNMAP_KERNEL_AT_EL0
diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index ffe52382033c..f48bc9061e3a 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -119,7 +119,6 @@ static DEFINE_MUTEX(ghes_list_mutex);
  * handler, but general ioremap can not be used in atomic context, so
  * the fixmap is used instead.
  */
-static DEFINE_RAW_SPINLOCK(ghes_fixmap_lock_nmi);
 static DEFINE_SPINLOCK(ghes_fixmap_lock_irq);
 
 static struct gen_pool *ghes_estatus_pool;
@@ -952,6 +951,7 @@ static struct notifier_block ghes_notifier_hed = {
 
 #ifdef CONFIG_ACPI_APEI_SEA
 static LIST_HEAD(ghes_sea);
+static DEFINE_RAW_SPINLOCK(ghes_fixmap_lock_sea);
 
 /*
  * Return 0 only if one of the SEA error sources successfully reported an error
@@ -964,8 +964,8 @@ int ghes_notify_sea(void)
 
 static void ghes_sea_add(struct ghes *ghes)
 {
-	ghes->nmi_fixmap_lock = &ghes_fixmap_lock_nmi;
-	ghes->nmi_fixmap_idx = FIX_APEI_GHES_NMI;
+	ghes->nmi_fixmap_lock = &ghes_fixmap_lock_sea;
+	ghes->nmi_fixmap_idx = FIX_APEI_GHES_SEA;
 	ghes_estatus_queue_grow_pool(ghes);
 
 	mutex_lock(&ghes_list_mutex);
@@ -989,12 +989,13 @@ static inline void ghes_sea_remove(struct ghes *ghes) { }
 
 #ifdef CONFIG_HAVE_ACPI_APEI_NMI
 /*
- * NMI may be triggered on any CPU, so ghes_in_nmi is used for
- * having only one concurrent reader.
+ * NOTIFY_NMI may be triggered on any CPU, so ghes_in_nmi is
+ * used for having only one concurrent reader.
  */
 static atomic_t ghes_in_nmi = ATOMIC_INIT(0);
 
 static LIST_HEAD(ghes_nmi);
+static DEFINE_RAW_SPINLOCK(ghes_fixmap_lock_nmi);
 
 static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 {
-- 
2.16.2
