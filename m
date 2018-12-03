Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 92B036B6A8A
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:07:46 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w6so5968783otb.6
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:07:46 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 97si6695626otb.98.2018.12.03.10.07.45
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:07:45 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 19/25] ACPI / APEI: Only use queued estatus entry during _in_nmi_notify_one()
Date: Mon,  3 Dec 2018 18:06:07 +0000
Message-Id: <20181203180613.228133-20-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

Each struct ghes has an worst-case sized buffer for storing the
estatus. If an error is being processed by ghes_proc() in process
context this buffer will be in use. If the error source then triggers
an NMI-like notification, the same buffer will be used by
_in_nmi_notify_one() to stage the estatus data, before
__process_error() copys it into a queued estatus entry.

Merge __process_error()s work into _in_nmi_notify_one() so that
the queued estatus entry is used from the beginning. Use the new
ghes_peek_estatus() to know how much memory to allocate from
the ghes_estatus_pool before reading the records.

Reported-by: Borislav Petkov <bp@suse.de>
Signed-off-by: James Morse <james.morse@arm.com>

Change since v6:
 * Added a comment explaining the 'ack-error, then goto no_work'.
 * Added missing esatus-clearing, which is necessary after reading the GAS,
---
 drivers/acpi/apei/ghes.c | 59 ++++++++++++++++++++++++----------------
 1 file changed, 35 insertions(+), 24 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 07a12aac4c1a..849da0d43a21 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -856,43 +856,43 @@ static void ghes_print_queued_estatus(void)
 	}
 }
 
-/* Save estatus for further processing in IRQ context */
-static void __process_error(struct ghes *ghes,
-			    struct acpi_hest_generic_status *src_estatus)
+static int _in_nmi_notify_one(struct ghes *ghes, int fixmap_idx)
 {
-	u32 len, node_len;
+	struct acpi_hest_generic_status *estatus, tmp_header;
 	struct ghes_estatus_node *estatus_node;
-	struct acpi_hest_generic_status *estatus;
+	u32 len, node_len;
+	u64 buf_paddr;
+	int sev, rc;
 
 	if (!IS_ENABLED(CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG))
-		return;
+		return -EOPNOTSUPP;
 
-	if (ghes_estatus_cached(src_estatus))
-		return;
+	rc = __ghes_peek_estatus(ghes, fixmap_idx, &tmp_header, &buf_paddr);
+	if (rc) {
+		ghes_clear_estatus(&tmp_header, buf_paddr, fixmap_idx);
+		return rc;
+	}
 
-	len = cper_estatus_len(src_estatus);
-	node_len = GHES_ESTATUS_NODE_LEN(len);
+	rc = __ghes_check_estatus(ghes, &tmp_header);
+	if (rc) {
+		ghes_clear_estatus(&tmp_header, buf_paddr, fixmap_idx);
+		return rc;
+	}
 
+	len = cper_estatus_len(&tmp_header);
+	node_len = GHES_ESTATUS_NODE_LEN(len);
 	estatus_node = (void *)gen_pool_alloc(ghes_estatus_pool, node_len);
 	if (!estatus_node)
-		return;
+		return -ENOMEM;
 
 	estatus_node->ghes = ghes;
 	estatus_node->generic = ghes->generic;
 	estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
-	memcpy(estatus, src_estatus, len);
-	llist_add(&estatus_node->llnode, &ghes_estatus_llist);
-}
-
-static int _in_nmi_notify_one(struct ghes *ghes, int fixmap_idx)
-{
-	struct acpi_hest_generic_status *estatus = ghes->estatus;
-	u64 buf_paddr;
-	int sev;
 
-	if (ghes_read_estatus(ghes, estatus, &buf_paddr, fixmap_idx)) {
+	if (__ghes_read_estatus(estatus, buf_paddr, len, fixmap_idx)) {
 		ghes_clear_estatus(estatus, buf_paddr, fixmap_idx);
-		return -ENOENT;
+		rc = -ENOENT;
+		goto no_work;
 	}
 
 	sev = ghes_severity(estatus->error_severity);
@@ -901,14 +901,25 @@ static int _in_nmi_notify_one(struct ghes *ghes, int fixmap_idx)
 		__ghes_panic(ghes, estatus);
 	}
 
-	__process_error(ghes, estatus);
 	ghes_clear_estatus(estatus, buf_paddr, fixmap_idx);
 
 	if (is_hest_type_generic_v2(ghes) && ghes_ack_error(ghes->generic_v2))
 		pr_warn_ratelimited(FW_WARN GHES_PFX
 				    "Failed to ack error status block!\n");
 
-	return 0;
+	/* This error has been reported before, don't process it again. */
+	if (ghes_estatus_cached(estatus))
+		goto no_work;
+
+	llist_add(&estatus_node->llnode, &ghes_estatus_llist);
+
+	return rc;
+
+no_work:
+	gen_pool_free(ghes_estatus_pool, (unsigned long)estatus_node,
+		      node_len);
+
+	return rc;
 }
 
 static int ghes_estatus_queue_notified(struct list_head *rcu_list,
-- 
2.19.2
