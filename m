Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 74F756B6A7B
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:07:05 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id p131so1297616oig.10
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:07:05 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v7si5802576otk.268.2018.12.03.10.07.04
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:07:04 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 08/25] ACPI / APEI: Don't update struct ghes' flags in read/clear estatus
Date: Mon,  3 Dec 2018 18:05:56 +0000
Message-Id: <20181203180613.228133-9-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

ghes_read_estatus() sets a flag in struct ghes if the buffer of
CPER records needs to be cleared once the records have been
processed. This flag value is a problem if a struct ghes can be
processed concurrently, as happens at probe time if an NMI arrives
for the same error source. The NMI clears the flag, meaning the
interrupted handler may never do the ghes_estatus_clear() work.

The GHES_TO_CLEAR flags is only set at the same time as
buffer_paddr, which is now owned by the caller and passed to
ghes_clear_estatus(). Use this value as the flag.

A non-zero buf_paddr returned by ghes_read_estatus() means
ghes_clear_estatus() should clear this address. ghes_read_estatus()
already checks for a read of error_status_address being zero,
so CPER records cannot be written here.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Borislav Petkov <bp@suse.de>

--
Changes since v6:
 * Added Boris' RB, then:
 * Moved earlier in the series,
 * Tinkered with the commit message,
 * Always cleared buf_paddr on errors in the previous patch, which was
   previously in here.
---
 drivers/acpi/apei/ghes.c | 8 +-------
 include/acpi/ghes.h      | 1 -
 2 files changed, 1 insertion(+), 8 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index f7a0ff1c785a..d06456e60318 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -329,8 +329,6 @@ static int ghes_read_estatus(struct ghes *ghes, u64 *buf_paddr)
 		return -ENOENT;
 	}
 
-	ghes->flags |= GHES_TO_CLEAR;
-
 	rc = -EIO;
 	len = cper_estatus_len(ghes->estatus);
 	if (len < sizeof(*ghes->estatus))
@@ -357,13 +355,9 @@ static int ghes_read_estatus(struct ghes *ghes, u64 *buf_paddr)
 static void ghes_clear_estatus(struct ghes *ghes, u64 buf_paddr)
 {
 	ghes->estatus->block_status = 0;
-	if (!(ghes->flags & GHES_TO_CLEAR))
-		return;
-	if (buf_paddr) {
+	if (buf_paddr)
 		ghes_copy_tofrom_phys(ghes->estatus, buf_paddr,
 				      sizeof(ghes->estatus->block_status), 0);
-		ghes->flags &= ~GHES_TO_CLEAR;
-	}
 }
 
 static void ghes_handle_memory_failure(struct acpi_hest_generic_data *gdata, int sev)
diff --git a/include/acpi/ghes.h b/include/acpi/ghes.h
index f82f4a7ddd90..e3f1cddb4ac8 100644
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
2.19.2
