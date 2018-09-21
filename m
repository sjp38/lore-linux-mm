Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC5318E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:18:51 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id m197-v6so13260612oig.18
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:18:51 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n13-v6si11518798ota.180.2018.09.21.15.18.50
        for <linux-mm@kvack.org>;
        Fri, 21 Sep 2018 15:18:50 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v6 14/18] ACPI / APEI: Split ghes_read_estatus() to read CPER length
Date: Fri, 21 Sep 2018 23:17:01 +0100
Message-Id: <20180921221705.6478-15-james.morse@arm.com>
In-Reply-To: <20180921221705.6478-1-james.morse@arm.com>
References: <20180921221705.6478-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
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
index 3028487d43a3..055176ed68ac 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -298,11 +298,12 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 	}
 }
 
-static int ghes_read_estatus(struct ghes *ghes,
-			     struct acpi_hest_generic_status *estatus,
-			     u64 *buf_paddr, int fixmap_idx)
+/* read the CPER block returning its address and size */
+static int ghes_peek_estatus(struct ghes *ghes, int fixmap_idx,
+			     u64 *buf_paddr, u32 *buf_len)
 {
 	struct acpi_hest_generic *g = ghes->generic;
+	struct acpi_hest_generic_status estatus;
 	u32 len;
 	int rc;
 
@@ -317,26 +318,23 @@ static int ghes_read_estatus(struct ghes *ghes,
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
@@ -346,6 +344,35 @@ static int ghes_read_estatus(struct ghes *ghes,
 	return rc;
 }
 
+static int __ghes_read_estatus(struct acpi_hest_generic_status *estatus,
+			       u64 buf_paddr, size_t buf_len,
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
+			     u64 *buf_paddr, int fixmap_idx)
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
 			       u64 buf_paddr, int fixmap_idx)
 {
-- 
2.19.0
