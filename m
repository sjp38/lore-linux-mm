Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30C736B0284
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 13:02:50 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id r58-v6so12421316otr.0
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:02:50 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t2-v6si669291oig.82.2018.06.26.10.02.47
        for <linux-mm@kvack.org>;
        Tue, 26 Jun 2018 10:02:48 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v5 14/20] ACPI / APEI: Split ghes_read_estatus() to read CPER length
Date: Tue, 26 Jun 2018 18:01:10 +0100
Message-Id: <20180626170116.25825-15-james.morse@arm.com>
In-Reply-To: <20180626170116.25825-1-james.morse@arm.com>
References: <20180626170116.25825-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

ghes_read_estatus() reads the record address, then the record's
header, then performs some sanity checks before reading the
records into the provided estatus buffer.

We either need to know the size of the records before we call
ghes_read_estatus(), or always provide a worst-case sized buffer,
as happens today.

Add a function to peek at the record's header to find the size. This
will let the NMI path allocate the right amount of memory before reading
the records, instead of using the worst-case size, and having to copy
the records.

Split ghes_read_estatus() to create ghes_peek_estatus() which
returns the address and size of the CPER records.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 55 ++++++++++++++++++++++++++++++----------
 1 file changed, 41 insertions(+), 14 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 75360525935d..1d59d85b38d2 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -289,11 +289,12 @@ static void ghes_copy_tofrom_phys(void *buffer, phys_addr_t paddr, u32 len,
 	}
 }
 
-static int ghes_read_estatus(struct ghes *ghes,
-			     struct acpi_hest_generic_status *estatus,
-			     phys_addr_t *buf_paddr, int fixmap_idx)
+/* read the CPER block returning its address and size */
+static int ghes_peek_estatus(struct ghes *ghes, int fixmap_idx,
+			     phys_addr_t *buf_paddr, u32 *buf_len)
 {
 	struct acpi_hest_generic *g = ghes->generic;
+	struct acpi_hest_generic_status estatus;
 	u32 len;
 	int rc;
 
@@ -308,26 +309,23 @@ static int ghes_read_estatus(struct ghes *ghes,
 	if (!*buf_paddr)
 		return -ENOENT;
 
-	ghes_copy_tofrom_phys(estatus, *buf_paddr,
-			      sizeof(*estatus), 1, fixmap_idx);
-	if (!estatus->block_status) {
+	ghes_copy_tofrom_phys(&estatus, *buf_paddr,
+			      sizeof(estatus), 1, fixmap_idx);
+	if (!estatus.block_status) {
 		*buf_paddr = 0;
 		return -ENOENT;
 	}
 
 	rc = -EIO;
-	len = cper_estatus_len(estatus);
-	if (len < sizeof(*estatus))
+	len = cper_estatus_len(&estatus);
+	if (len < sizeof(estatus))
 		goto err_read_block;
 	if (len > ghes->generic->error_block_length)
 		goto err_read_block;
-	if (cper_estatus_check_header(estatus))
-		goto err_read_block;
-	ghes_copy_tofrom_phys(estatus + 1,
-			      *buf_paddr + sizeof(*estatus),
-			      len - sizeof(*estatus), 1, fixmap_idx);
-	if (cper_estatus_check(estatus))
+	if (cper_estatus_check_header(&estatus))
 		goto err_read_block;
+	*buf_len = len;
+
 	rc = 0;
 
 err_read_block:
@@ -337,6 +335,35 @@ static int ghes_read_estatus(struct ghes *ghes,
 	return rc;
 }
 
+static int __ghes_read_estatus(struct acpi_hest_generic_status *estatus,
+			       phys_addr_t buf_paddr, size_t buf_len,
+			       int fixmap_idx)
+{
+	ghes_copy_tofrom_phys(estatus, buf_paddr, buf_len, 1, fixmap_idx);
+	if (cper_estatus_check(estatus)) {
+		if (printk_ratelimit())
+			pr_warning(FW_WARN GHES_PFX
+				   "Failed to read error status block!\n");
+		return -EIO;
+	}
+
+	return 0;
+}
+
+static int ghes_read_estatus(struct ghes *ghes,
+			     struct acpi_hest_generic_status *estatus,
+			     phys_addr_t *buf_paddr, int fixmap_idx)
+{
+	int rc;
+	u32 buf_len;
+
+	rc = ghes_peek_estatus(ghes, fixmap_idx, buf_paddr, &buf_len);
+	if (rc)
+		return rc;
+
+	return __ghes_read_estatus(estatus, *buf_paddr, buf_len, fixmap_idx);
+}
+
 static void ghes_clear_estatus(struct acpi_hest_generic_status *estatus,
 			       phys_addr_t buf_paddr, int fixmap_idx)
 {
-- 
2.17.1
