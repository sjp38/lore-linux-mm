Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 722C66B69A4
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:06:44 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id r24so3731836otk.7
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:06:44 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r137si6131581oie.147.2018.12.03.10.06.43
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:06:43 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 02/25] ACPI / APEI: Remove silent flag from ghes_read_estatus()
Date: Mon,  3 Dec 2018 18:05:50 +0000
Message-Id: <20181203180613.228133-3-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

Subsequent patches will split up ghes_read_estatus(), at which
point passing around the 'silent' flag gets annoying. This is to
suppress prink() messages, which prior to commit 42a0bb3f7138
("printk/nmi: generic solution for safe printk in NMI"), were
unsafe in NMI context.

This is no longer necessary, remove the flag. printk() messages
are batched in a per-cpu buffer and printed via irq-work, or a call
back from panic().

Signed-off-by: James Morse <james.morse@arm.com>
---
Changes since v6:
 * Moved earlier in the series,
 * Tinkered with the commit message.
 * switched to pr_warn_ratelimited() to shut checkpatch up

shutup checkpatch
---
 drivers/acpi/apei/ghes.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index ab2dae6fc7e4..e8503c7d721f 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -324,7 +324,7 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 	}
 }
 
-static int ghes_read_estatus(struct ghes *ghes, int silent)
+static int ghes_read_estatus(struct ghes *ghes)
 {
 	struct acpi_hest_generic *g = ghes->generic;
 	u64 buf_paddr;
@@ -333,8 +333,7 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
 
 	rc = apei_read(&buf_paddr, &g->error_status_address);
 	if (rc) {
-		if (!silent && printk_ratelimit())
-			pr_warning(FW_WARN GHES_PFX
+		pr_warn_ratelimited(FW_WARN GHES_PFX
 "Failed to read error status block address for hardware error source: %d.\n",
 				   g->header.source_id);
 		return -EIO;
@@ -366,9 +365,9 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
 	rc = 0;
 
 err_read_block:
-	if (rc && !silent && printk_ratelimit())
-		pr_warning(FW_WARN GHES_PFX
-			   "Failed to read error status block!\n");
+	if (rc)
+		pr_warn_ratelimited(FW_WARN GHES_PFX
+				    "Failed to read error status block!\n");
 	return rc;
 }
 
@@ -700,7 +699,7 @@ static int ghes_proc(struct ghes *ghes)
 {
 	int rc;
 
-	rc = ghes_read_estatus(ghes, 0);
+	rc = ghes_read_estatus(ghes);
 	if (rc)
 		goto out;
 
@@ -937,7 +936,7 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 		return ret;
 
 	list_for_each_entry_rcu(ghes, &ghes_nmi, list) {
-		if (ghes_read_estatus(ghes, 1)) {
+		if (ghes_read_estatus(ghes)) {
 			ghes_clear_estatus(ghes);
 			continue;
 		} else {
-- 
2.19.2
