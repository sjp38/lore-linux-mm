Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id C81128E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:18:41 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id j27-v6so13832705oth.3
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:18:41 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m24-v6si11448293oth.48.2018.09.21.15.18.40
        for <linux-mm@kvack.org>;
        Fri, 21 Sep 2018 15:18:40 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v6 12/18] ACPI / APEI: Don't store CPER records physical address in struct ghes
Date: Fri, 21 Sep 2018 23:16:59 +0100
Message-Id: <20180921221705.6478-13-james.morse@arm.com>
In-Reply-To: <20180921221705.6478-1-james.morse@arm.com>
References: <20180921221705.6478-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

When CPER records are found the address of the records is stashed
in the struct ghes. Once the records have been processed, this
address is overwritten with zero so that it won't be processed
again without being re-populated by firmware.

This goes wrong if a struct ghes can be processed concurrently,
as can happen at probe time when an NMI occurs.

Avoid this stashing by letting the caller hold the address. A
later patch will do away with the use of ghes->flags in the
read/clear code too.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 28 ++++++++++++++--------------
 include/acpi/ghes.h      |  1 -
 2 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index ba5344d26a39..c58f9b330ed3 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -300,14 +300,13 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 
 static int ghes_read_estatus(struct ghes *ghes,
 			     struct acpi_hest_generic_status *estatus,
-			     int fixmap_idx)
+			     u64 *buf_paddr, int fixmap_idx)
 {
 	struct acpi_hest_generic *g = ghes->generic;
-	u64 buf_paddr;
 	u32 len;
 	int rc;
 
-	rc = apei_read(&buf_paddr, &g->error_status_address);
+	rc = apei_read(buf_paddr, &g->error_status_address);
 	if (rc) {
 		if (printk_ratelimit())
 			pr_warning(FW_WARN GHES_PFX
@@ -315,15 +314,14 @@ static int ghes_read_estatus(struct ghes *ghes,
 				   g->header.source_id);
 		return -EIO;
 	}
-	if (!buf_paddr)
+	if (!*buf_paddr)
 		return -ENOENT;
 
-	ghes_copy_tofrom_phys(estatus, buf_paddr,
+	ghes_copy_tofrom_phys(estatus, *buf_paddr,
 			      sizeof(*estatus), 1, fixmap_idx);
 	if (!estatus->block_status)
 		return -ENOENT;
 
-	ghes->buffer_paddr = buf_paddr;
 	ghes->flags |= GHES_TO_CLEAR;
 
 	rc = -EIO;
@@ -335,7 +333,7 @@ static int ghes_read_estatus(struct ghes *ghes,
 	if (cper_estatus_check_header(estatus))
 		goto err_read_block;
 	ghes_copy_tofrom_phys(estatus + 1,
-			      buf_paddr + sizeof(*estatus),
+			      *buf_paddr + sizeof(*estatus),
 			      len - sizeof(*estatus), 1, fixmap_idx);
 	if (cper_estatus_check(estatus))
 		goto err_read_block;
@@ -350,12 +348,12 @@ static int ghes_read_estatus(struct ghes *ghes,
 
 static void ghes_clear_estatus(struct ghes *ghes,
 			       struct acpi_hest_generic_status *estatus,
-			       int fixmap_idx)
+			       u64 buf_paddr, int fixmap_idx)
 {
 	estatus->block_status = 0;
 	if (!(ghes->flags & GHES_TO_CLEAR))
 		return;
-	ghes_copy_tofrom_phys(estatus, ghes->buffer_paddr,
+	ghes_copy_tofrom_phys(estatus, buf_paddr,
 			      sizeof(estatus->block_status), 0, fixmap_idx);
 	ghes->flags &= ~GHES_TO_CLEAR;
 }
@@ -727,10 +725,11 @@ static void __process_error(struct ghes *ghes,
 static int _in_nmi_notify_one(struct ghes *ghes, int fixmap_idx)
 {
 	int sev;
+	u64 buf_paddr;
 	struct acpi_hest_generic_status *estatus = ghes->estatus;
 
-	if (ghes_read_estatus(ghes, estatus, fixmap_idx)) {
-		ghes_clear_estatus(ghes, estatus, fixmap_idx);
+	if (ghes_read_estatus(ghes, estatus, &buf_paddr, fixmap_idx)) {
+		ghes_clear_estatus(ghes, estatus, buf_paddr, fixmap_idx);
 		return -ENOENT;
 	}
 
@@ -744,7 +743,7 @@ static int _in_nmi_notify_one(struct ghes *ghes, int fixmap_idx)
 		return 0;
 
 	__process_error(ghes, estatus);
-	ghes_clear_estatus(ghes, estatus, fixmap_idx);
+	ghes_clear_estatus(ghes, estatus, buf_paddr, fixmap_idx);
 
 	return 0;
 }
@@ -861,9 +860,10 @@ static int ghes_ack_error(struct acpi_hest_generic_v2 *gv2)
 static int ghes_proc(struct ghes *ghes)
 {
 	int rc;
+	u64 buf_paddr;
 	struct acpi_hest_generic_status *estatus = ghes->estatus;
 
-	rc = ghes_read_estatus(ghes, estatus, FIX_APEI_GHES_IRQ);
+	rc = ghes_read_estatus(ghes, estatus, &buf_paddr, FIX_APEI_GHES_IRQ);
 	if (rc)
 		goto out;
 
@@ -877,7 +877,7 @@ static int ghes_proc(struct ghes *ghes)
 	ghes_do_proc(ghes, estatus);
 
 out:
-	ghes_clear_estatus(ghes, estatus, FIX_APEI_GHES_IRQ);
+	ghes_clear_estatus(ghes, estatus, buf_paddr, FIX_APEI_GHES_IRQ);
 
 	if (rc == -ENOENT)
 		return rc;
diff --git a/include/acpi/ghes.h b/include/acpi/ghes.h
index 82cb4eb225a4..6dc021e9cdad 100644
--- a/include/acpi/ghes.h
+++ b/include/acpi/ghes.h
@@ -22,7 +22,6 @@ struct ghes {
 		struct acpi_hest_generic_v2 *generic_v2;
 	};
 	struct acpi_hest_generic_status *estatus;
-	u64 buffer_paddr;
 	unsigned long flags;
 	union {
 		struct list_head list;
-- 
2.19.0
