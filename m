Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0DA8E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:19:01 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id p23-v6so13630607otl.23
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:19:01 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k5-v6si12626985oih.2.2018.09.21.15.19.00
        for <linux-mm@kvack.org>;
        Fri, 21 Sep 2018 15:19:00 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v6 16/18] ACPI / APEI: Split fixmap pages for arm64 NMI-like notifications
Date: Fri, 21 Sep 2018 23:17:03 +0100
Message-Id: <20180921221705.6478-17-james.morse@arm.com>
In-Reply-To: <20180921221705.6478-1-james.morse@arm.com>
References: <20180921221705.6478-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

Now that ghes notification helpers provide the fixmap slots and
take the lock themselves we can support multiple NMI-like
notifications on arm64.

These should be named after their notification method. x86's
NOTIFY_NMI already is, move it to live with the ghes_nmi list.
Change the SEA fixmap entry to be called FIX_APEI_GHES_SEA.

Future patches can add support for FIX_APEI_GHES_SEI and
FIX_APEI_GHES_SDEI_{NORMAL,CRITICAL}.

Signed-off-by: James Morse <james.morse@arm.com>

---
Changes since v3:
 * idx/lock are now in a separate struct.
 * Add to the comment above ghes_fixmap_lock_irq so that it makes more
   sense in isolation.
---
 arch/arm64/include/asm/fixmap.h | 4 +++-
 drivers/acpi/apei/ghes.c        | 6 +++---
 2 files changed, 6 insertions(+), 4 deletions(-)

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
index a0c10b60ad44..463c8e6d1bb5 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -994,7 +994,7 @@ int ghes_notify_sea(void)
 	int rv;
 
 	raw_spin_lock(&ghes_notify_lock_sea);
-	rv = ghes_estatus_queue_notified(&ghes_sea, FIX_APEI_GHES_NMI);
+	rv = ghes_estatus_queue_notified(&ghes_sea, FIX_APEI_GHES_SEA);
 	raw_spin_unlock(&ghes_notify_lock_sea);
 
 	return rv;
@@ -1025,8 +1025,8 @@ static inline void ghes_sea_remove(struct ghes *ghes) { }
 
 #ifdef CONFIG_HAVE_ACPI_APEI_NMI
 /*
- * NMI may be triggered on any CPU, so ghes_in_nmi is used for
- * having only one concurrent reader.
+ * NOTIFY_NMI may be triggered on any CPU, so ghes_in_nmi is
+ * used for having only one concurrent reader.
  */
 static atomic_t ghes_in_nmi = ATOMIC_INIT(0);
 
-- 
2.19.0
