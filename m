Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6C36B6A8C
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:07:49 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id q23so5964608otn.3
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:07:49 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t3si6495635otq.54.2018.12.03.10.07.48
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:07:48 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 20/25] ACPI / APEI: Use separate fixmap pages for arm64 NMI-like notifications
Date: Mon,  3 Dec 2018 18:06:08 +0000
Message-Id: <20181203180613.228133-21-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

Now that ghes notification helpers provide the fixmap slots and
take the lock themselves, multiple NMI-like notifications can
be used on arm64.

These should be named after their notification method as they can't
all be called 'NMI'. x86's NOTIFY_NMI already is, change the SEA
fixmap entry to be called FIX_APEI_GHES_SEA.

Future patches can add support for FIX_APEI_GHES_SEI and
FIX_APEI_GHES_SDEI_{NORMAL,CRITICAL}.

Because all of ghes.c builds on both architectures, provide a
constant for each fixmap entry that the architecture will never
use.

Signed-off-by: James Morse <james.morse@arm.com>

---
Changes since v6:
 * Added #ifdef definitions of each missing fixmap entry.

Changes since v3:
 * idx/lock are now in a separate struct.
 * Add to the comment above ghes_fixmap_lock_irq so that it makes more
   sense in isolation.

fixup for split fixmap
---
 arch/arm64/include/asm/fixmap.h |  2 +-
 drivers/acpi/apei/ghes.c        | 10 +++++++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/include/asm/fixmap.h b/arch/arm64/include/asm/fixmap.h
index ec1e6d6fa14c..966dd4bb23f2 100644
--- a/arch/arm64/include/asm/fixmap.h
+++ b/arch/arm64/include/asm/fixmap.h
@@ -55,7 +55,7 @@ enum fixed_addresses {
 #ifdef CONFIG_ACPI_APEI_GHES
 	/* Used for GHES mapping from assorted contexts */
 	FIX_APEI_GHES_IRQ,
-	FIX_APEI_GHES_NMI,
+	FIX_APEI_GHES_SEA,
 #endif /* CONFIG_ACPI_APEI_GHES */
 
 #ifdef CONFIG_UNMAP_KERNEL_AT_EL0
diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 849da0d43a21..6cbf9471b2a2 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -85,6 +85,14 @@
 	((struct acpi_hest_generic_status *)				\
 	 ((struct ghes_estatus_node *)(estatus_node) + 1))
 
+/* NMI-like notifications vary by architecture. Fill in the fixmap gaps */
+#ifndef CONFIG_HAVE_ACPI_APEI_NMI
+#define FIX_APEI_GHES_NMI	-1
+#endif
+#ifndef CONFIG_ACPI_APEI_SEA
+#define FIX_APEI_GHES_SEA	-1
+#endif
+
 static inline bool is_hest_type_generic_v2(struct ghes *ghes)
 {
 	return ghes->generic->header.type == ACPI_HEST_TYPE_GENERIC_ERROR_V2;
@@ -954,7 +962,7 @@ int ghes_notify_sea(void)
 	int rv;
 
 	raw_spin_lock(&ghes_notify_lock_sea);
-	rv = ghes_estatus_queue_notified(&ghes_sea, FIX_APEI_GHES_NMI);
+	rv = ghes_estatus_queue_notified(&ghes_sea, FIX_APEI_GHES_SEA);
 	raw_spin_unlock(&ghes_notify_lock_sea);
 
 	return rv;
-- 
2.19.2
