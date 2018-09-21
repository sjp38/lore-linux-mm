Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFF2A8E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:18:36 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b8-v6so13460722oib.4
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:18:36 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t5-v6si10640577oti.271.2018.09.21.15.18.35
        for <linux-mm@kvack.org>;
        Fri, 21 Sep 2018 15:18:35 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v6 11/18] ACPI / APEI: Remove silent flag from ghes_read_estatus()
Date: Fri, 21 Sep 2018 23:16:58 +0100
Message-Id: <20180921221705.6478-12-james.morse@arm.com>
In-Reply-To: <20180921221705.6478-1-james.morse@arm.com>
References: <20180921221705.6478-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

Subsequent patches will split up ghes_read_estatus(), at which
point passing around the 'silent' flag gets annoying. This is to
suppress prink() messages, which prior to 42a0bb3f7138 ("printk/nmi:
generic solution for safe printk in NMI"), were unsafe in NMI context.

We don't need to do this anymore, remove the flag. printk() messages
are batched in a per-cpu buffer and printed via irq-work, or a call
back from panic().

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 586689cbc0fd..ba5344d26a39 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -300,7 +300,7 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 
 static int ghes_read_estatus(struct ghes *ghes,
 			     struct acpi_hest_generic_status *estatus,
-			     int silent, int fixmap_idx)
+			     int fixmap_idx)
 {
 	struct acpi_hest_generic *g = ghes->generic;
 	u64 buf_paddr;
@@ -309,7 +309,7 @@ static int ghes_read_estatus(struct ghes *ghes,
 
 	rc = apei_read(&buf_paddr, &g->error_status_address);
 	if (rc) {
-		if (!silent && printk_ratelimit())
+		if (printk_ratelimit())
 			pr_warning(FW_WARN GHES_PFX
 "Failed to read error status block address for hardware error source: %d.\n",
 				   g->header.source_id);
@@ -342,7 +342,7 @@ static int ghes_read_estatus(struct ghes *ghes,
 	rc = 0;
 
 err_read_block:
-	if (rc && !silent && printk_ratelimit())
+	if (rc && printk_ratelimit())
 		pr_warning(FW_WARN GHES_PFX
 			   "Failed to read error status block!\n");
 	return rc;
@@ -729,7 +729,7 @@ static int _in_nmi_notify_one(struct ghes *ghes, int fixmap_idx)
 	int sev;
 	struct acpi_hest_generic_status *estatus = ghes->estatus;
 
-	if (ghes_read_estatus(ghes, estatus, 1, fixmap_idx)) {
+	if (ghes_read_estatus(ghes, estatus, fixmap_idx)) {
 		ghes_clear_estatus(ghes, estatus, fixmap_idx);
 		return -ENOENT;
 	}
@@ -863,7 +863,7 @@ static int ghes_proc(struct ghes *ghes)
 	int rc;
 	struct acpi_hest_generic_status *estatus = ghes->estatus;
 
-	rc = ghes_read_estatus(ghes, estatus, 0, FIX_APEI_GHES_IRQ);
+	rc = ghes_read_estatus(ghes, estatus, FIX_APEI_GHES_IRQ);
 	if (rc)
 		goto out;
 
-- 
2.19.0
