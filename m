From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20050930073237.10631.27035.sendpatchset@cherry.local>
In-Reply-To: <20050930073232.10631.63786.sendpatchset@cherry.local>
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
Subject: [PATCH 01/07] i386: srat non acpi
Date: Fri, 30 Sep 2005 16:33:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
From: Magnus Damm <magnus@valinux.co.jp>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch adds code to check the return value of acpi_find_root_pointer().
Without this patch systems without ACPI support such as QEMU crashes when 
booting a NUMA kernel configured with CONFIG_ACPI_SRAT=y.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 srat.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)

--- from-0002/arch/i386/kernel/srat.c
+++ to-work/arch/i386/kernel/srat.c	2005-09-28 15:59:13.000000000 +0900
@@ -327,7 +327,12 @@ int __init get_memcfg_from_srat(void)
 	int tables = 0;
 	int i = 0;
 
-	acpi_find_root_pointer(ACPI_PHYSICAL_ADDRESSING, rsdp_address);
+	if (ACPI_FAILURE(acpi_find_root_pointer(ACPI_PHYSICAL_ADDRESSING, 
+						rsdp_address))) {
+		printk("%s: System description tables not found\n",
+		       __FUNCTION__);
+		goto out_err;
+	}
 
 	if (rsdp_address->pointer_type == ACPI_PHYSICAL_POINTER) {
 		printk("%s: assigning address to rsdp\n", __FUNCTION__);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
