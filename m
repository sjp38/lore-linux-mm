Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 17EA88E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:18:57 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x145-v6so13426687oia.10
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:18:57 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k70-v6si10681498otk.129.2018.09.21.15.18.55
        for <linux-mm@kvack.org>;
        Fri, 21 Sep 2018 15:18:55 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v6 15/18] ACPI / APEI: Only use queued estatus entry during _in_nmi_notify_one()
Date: Fri, 21 Sep 2018 23:17:02 +0100
Message-Id: <20180921221705.6478-16-james.morse@arm.com>
In-Reply-To: <20180921221705.6478-1-james.morse@arm.com>
References: <20180921221705.6478-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

Each struct ghes has an worst-case sized buffer for storing the
estatus. If an error is being processed by ghes_proc() in process
context this buffer will be in use. If the error source then triggers
an NMI-like notification, the same buffer will be used by
_in_nmi_notify_one() to stage the estatus data, before
__process_error() copys it into a queued estatus entry.

Merge __process_error()s work into _in_nmi_notify_one() so that
the queued estatus entry is used from the beginning. Use the
ghes_peek_estatus() so we know how much memory to allocate from
the ghes_estatus_pool before we read the records.

Reported-by: Borislav Petkov <bp@suse.de>
Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 45 ++++++++++++++++++++--------------------
 1 file changed, 22 insertions(+), 23 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 055176ed68ac..a0c10b60ad44 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -722,40 +722,32 @@ static void ghes_print_queued_estatus(void)
 	}
 }
 
-/* Save estatus for further processing in IRQ context */
-static void __process_error(struct ghes *ghes,
-			    struct acpi_hest_generic_status *ghes_estatus)
+static int _in_nmi_notify_one(struct ghes *ghes, int fixmap_idx)
 {
+	u64 buf_paddr;
+	int sev, rc = 0;
 	u32 len, node_len;
 	struct ghes_estatus_node *estatus_node;
 	struct acpi_hest_generic_status *estatus;
 
-	if (ghes_estatus_cached(ghes_estatus))
-		return;
+	rc = ghes_peek_estatus(ghes, fixmap_idx, &buf_paddr, &len);
+	if (rc)
+		return rc;
 
-	len = cper_estatus_len(ghes_estatus);
 	node_len = GHES_ESTATUS_NODE_LEN(len);
 
 	estatus_node = (void *)gen_pool_alloc(ghes_estatus_pool, node_len);
 	if (!estatus_node)
-		return;
+		return -ENOMEM;
 
 	estatus_node->ghes = ghes;
 	estatus_node->generic = ghes->generic;
 	estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
-	memcpy(estatus, ghes_estatus, len);
-	llist_add(&estatus_node->llnode, &ghes_estatus_llist);
-}
-
-static int _in_nmi_notify_one(struct ghes *ghes, int fixmap_idx)
-{
-	int sev;
-	u64 buf_paddr;
-	struct acpi_hest_generic_status *estatus = ghes->estatus;
 
-	if (ghes_read_estatus(ghes, estatus, &buf_paddr, fixmap_idx)) {
+	if (__ghes_read_estatus(estatus, buf_paddr, len, fixmap_idx)) {
 		ghes_clear_estatus(estatus, buf_paddr, fixmap_idx);
-		return -ENOENT;
+		rc = -ENOENT;
+		goto no_work;
 	}
 
 	sev = ghes_severity(estatus->error_severity);
@@ -764,13 +756,20 @@ static int _in_nmi_notify_one(struct ghes *ghes, int fixmap_idx)
 		__ghes_panic(ghes, estatus);
 	}
 
-	if (!buf_paddr)
-		return 0;
-
-	__process_error(ghes, estatus);
 	ghes_clear_estatus(estatus, buf_paddr, fixmap_idx);
 
-	return 0;
+	if (!buf_paddr || ghes_estatus_cached(estatus))
+		goto no_work;
+
+	llist_add(&estatus_node->llnode, &ghes_estatus_llist);
+
+	return rc;
+
+no_work:
+	gen_pool_free(ghes_estatus_pool, (unsigned long)estatus_node,
+			      node_len);
+
+	return rc;
 }
 
 static int ghes_estatus_queue_notified(struct list_head *rcu_list,
-- 
2.19.0
