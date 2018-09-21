Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8B06D8E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:18:06 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id j65-v6so13813357otc.5
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:18:06 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i11-v6si13063711oia.112.2018.09.21.15.18.05
        for <linux-mm@kvack.org>;
        Fri, 21 Sep 2018 15:18:05 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v6 05/18] ACPI / APEI: Make estatus queue a Kconfig symbol
Date: Fri, 21 Sep 2018 23:16:52 +0100
Message-Id: <20180921221705.6478-6-james.morse@arm.com>
In-Reply-To: <20180921221705.6478-1-james.morse@arm.com>
References: <20180921221705.6478-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

Now that there are two users of the estatus queue, and likely to be more,
make it a Kconfig symbol selected by the appropriate notification. We
can move the ARCH_HAVE_NMI_SAFE_CMPXCHG checks in here too.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/Kconfig |  6 ++++++
 drivers/acpi/apei/ghes.c  | 12 +++---------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/acpi/apei/Kconfig b/drivers/acpi/apei/Kconfig
index 52ae5438edeb..2b191e09b647 100644
--- a/drivers/acpi/apei/Kconfig
+++ b/drivers/acpi/apei/Kconfig
@@ -4,6 +4,7 @@ config HAVE_ACPI_APEI
 
 config HAVE_ACPI_APEI_NMI
 	bool
+	select ACPI_APEI_GHES_ESTATUS_QUEUE
 
 config ACPI_APEI
 	bool "ACPI Platform Error Interface (APEI)"
@@ -33,6 +34,10 @@ config ACPI_APEI_GHES
 	  by firmware to produce more valuable hardware error
 	  information for Linux.
 
+config ACPI_APEI_GHES_ESTATUS_QUEUE
+	bool
+	depends on ACPI_APEI_GHES && ARCH_HAVE_NMI_SAFE_CMPXCHG
+
 config ACPI_APEI_PCIEAER
 	bool "APEI PCIe AER logging/recovering support"
 	depends on ACPI_APEI && PCIEAER
@@ -43,6 +48,7 @@ config ACPI_APEI_PCIEAER
 config ACPI_APEI_SEA
 	bool "APEI Synchronous External Abort logging/recovering support"
 	depends on ARM64 && ACPI_APEI_GHES
+	select ACPI_APEI_GHES_ESTATUS_QUEUE
 	default y
 	help
 	  This option should be enabled if the system supports
diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 150fb184c7cb..2880547e13b8 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -58,10 +58,6 @@
 
 #define GHES_PFX	"GHES: "
 
-#if defined(CONFIG_HAVE_ACPI_APEI_NMI) || defined(CONFIG_ACPI_APEI_SEA)
-#define WANT_NMI_ESTATUS_QUEUE	1
-#endif
-
 #define GHES_ESTATUS_MAX_SIZE		65536
 #define GHES_ESOURCE_PREALLOC_MAX_SIZE	65536
 
@@ -685,7 +681,7 @@ static void ghes_estatus_cache_add(
 	rcu_read_unlock();
 }
 
-#ifdef WANT_NMI_ESTATUS_QUEUE
+#ifdef CONFIG_ACPI_APEI_GHES_ESTATUS_QUEUE
 /*
  * Handlers for CPER records may not be NMI safe. For example,
  * memory_failure_queue() takes spinlocks and calls schedule_work_on().
@@ -727,7 +723,6 @@ static void ghes_print_queued_estatus(void)
 /* Save estatus for further processing in IRQ context */
 static void __process_error(struct ghes *ghes)
 {
-#ifdef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
 	u32 len, node_len;
 	struct ghes_estatus_node *estatus_node;
 	struct acpi_hest_generic_status *estatus;
@@ -747,7 +742,6 @@ static void __process_error(struct ghes *ghes)
 	estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
 	memcpy(estatus, ghes->estatus, len);
 	llist_add(&estatus_node->llnode, &ghes_estatus_llist);
-#endif
 }
 
 static int _in_nmi_notify_one(struct ghes *ghes)
@@ -786,7 +780,7 @@ static int ghes_estatus_queue_notified(struct list_head *rcu_list)
 	}
 	rcu_read_unlock();
 
-	if (IS_ENABLED(CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG) && !ret)
+	if (!ret)
 		irq_work_queue(&ghes_proc_irq_work);
 
 	return ret;
@@ -865,7 +859,7 @@ static void ghes_nmi_init_cxt(void)
 
 #else
 static inline void ghes_nmi_init_cxt(void) { }
-#endif /* WANT_NMI_ESTATUS_QUEUE */
+#endif /* CONFIG_ACPI_APEI_GHES_ESTATUS_QUEUE */
 
 static int ghes_ack_error(struct acpi_hest_generic_v2 *gv2)
 {
-- 
2.19.0
