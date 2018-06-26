Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7FAF96B0282
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 13:02:45 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id p12-v6so12419447oti.6
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:02:45 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a22-v6si722909ote.424.2018.06.26.10.02.43
        for <linux-mm@kvack.org>;
        Tue, 26 Jun 2018 10:02:43 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v5 13/20] ACPI / APEI: Don't update struct ghes' flags in read/clear estatus
Date: Tue, 26 Jun 2018 18:01:09 +0100
Message-Id: <20180626170116.25825-14-james.morse@arm.com>
In-Reply-To: <20180626170116.25825-1-james.morse@arm.com>
References: <20180626170116.25825-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

ghes_read_estatus() sets a flag in struct ghes if the buffer of
CPER records needs to be cleared once the records have been
processed. This global flags value is a problem if a struct ghes
can be processed concurrently, as happens at probe time if an
NMI arrives for the same error source.

The GHES_TO_CLEAR flags was only set at the same time as
buffer_paddr, which is now owned by the caller and passed to
ghes_clear_estatus(). Use this as the flag.

A non-zero buf_paddr returned by ghes_read_estatus() means
ghes_clear_estatus() will clear this address. ghes_read_estatus()
already checks for a read of error_status_address being zero,
so we can never get CPER records written at zero.

After this ghes_clear_estatus() no longer needs the struct ghes.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 26 ++++++++++++--------------
 include/acpi/ghes.h      |  1 -
 2 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index b0054dfad9cc..75360525935d 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -310,10 +310,10 @@ static int ghes_read_estatus(struct ghes *ghes,
 
 	ghes_copy_tofrom_phys(estatus, *buf_paddr,
 			      sizeof(*estatus), 1, fixmap_idx);
-	if (!estatus->block_status)
+	if (!estatus->block_status) {
+		*buf_paddr = 0;
 		return -ENOENT;
-
-	ghes->flags |= GHES_TO_CLEAR;
+	}
 
 	rc = -EIO;
 	len = cper_estatus_len(estatus);
@@ -337,16 +337,14 @@ static int ghes_read_estatus(struct ghes *ghes,
 	return rc;
 }
 
-static void ghes_clear_estatus(struct ghes *ghes,
-			       struct acpi_hest_generic_status *estatus,
+static void ghes_clear_estatus(struct acpi_hest_generic_status *estatus,
 			       phys_addr_t buf_paddr, int fixmap_idx)
 {
 	estatus->block_status = 0;
-	if (!(ghes->flags & GHES_TO_CLEAR))
-		return;
-	ghes_copy_tofrom_phys(estatus, buf_paddr,
-			      sizeof(estatus->block_status), 0, fixmap_idx);
-	ghes->flags &= ~GHES_TO_CLEAR;
+	if (buf_paddr)
+		ghes_copy_tofrom_phys(estatus, buf_paddr,
+				      sizeof(estatus->block_status), 0,
+				      fixmap_idx);
 }
 
 static void ghes_handle_memory_failure(struct acpi_hest_generic_data *gdata, int sev)
@@ -720,7 +718,7 @@ static int _in_nmi_notify_one(struct ghes *ghes, int fixmap_idx)
 	struct acpi_hest_generic_status *estatus = ghes->estatus;
 
 	if (ghes_read_estatus(ghes, estatus, &buf_paddr, fixmap_idx)) {
-		ghes_clear_estatus(ghes, estatus, buf_paddr, fixmap_idx);
+		ghes_clear_estatus(estatus, buf_paddr, fixmap_idx);
 		return -ENOENT;
 	}
 
@@ -730,11 +728,11 @@ static int _in_nmi_notify_one(struct ghes *ghes, int fixmap_idx)
 		__ghes_panic(ghes, estatus);
 	}
 
-	if (!(ghes->flags & GHES_TO_CLEAR))
+	if (!buf_paddr)
 		return 0;
 
 	__process_error(ghes, estatus);
-	ghes_clear_estatus(ghes, estatus, buf_paddr, fixmap_idx);
+	ghes_clear_estatus(estatus, buf_paddr, fixmap_idx);
 
 	return 0;
 }
@@ -871,7 +869,7 @@ static int ghes_proc(struct ghes *ghes)
 	ghes_do_proc(ghes, estatus);
 
 out:
-	ghes_clear_estatus(ghes, estatus, buf_paddr, FIX_APEI_GHES_IRQ);
+	ghes_clear_estatus(estatus, buf_paddr, FIX_APEI_GHES_IRQ);
 
 	if (rc == -ENOENT)
 		goto unlock;
diff --git a/include/acpi/ghes.h b/include/acpi/ghes.h
index 3d77452e3a1d..0b6fe48e6671 100644
--- a/include/acpi/ghes.h
+++ b/include/acpi/ghes.h
@@ -13,7 +13,6 @@
  * estatus: memory buffer for error status block, allocated during
  * HEST parsing.
  */
-#define GHES_TO_CLEAR		0x0001
 #define GHES_EXITING		0x0002
 
 struct ghes {
-- 
2.17.1
