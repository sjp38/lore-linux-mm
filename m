Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC65B6B6A77
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:06:40 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id t83so8729032oie.16
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:06:40 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w81si6866609oie.88.2018.12.03.10.06.39
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:06:39 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 01/25] ACPI / APEI: Don't wait to serialise with oops messages when panic()ing
Date: Mon,  3 Dec 2018 18:05:49 +0000
Message-Id: <20181203180613.228133-2-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

oops_begin() exists to group printk() messages with the oops message
printed by die(). To reach this caller we know that platform firmware
took this error first, then notified the OS via NMI with a 'panic'
severity.

Don't wait for another CPU to release the die-lock before panic()ing,
our only goal is to print this fatal error and panic().

This code is always called in_nmi(), and since commit 42a0bb3f7138
("printk/nmi: generic solution for safe printk in NMI"), it has been
safe to call printk() from this context. Messages are batched in a
per-cpu buffer and printed via irq-work, or a call back from panic().

Link: https://patchwork.kernel.org/patch/10313555/
Acked-by: Borislav Petkov <bp@suse.de>
Signed-off-by: James Morse <james.morse@arm.com>

---
Changes since v6:
 * Capitals in patch subject
 * Tinkered with the commit message.
---
 drivers/acpi/apei/ghes.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 02c6fd9caff7..ab2dae6fc7e4 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -33,7 +33,6 @@
 #include <linux/interrupt.h>
 #include <linux/timer.h>
 #include <linux/cper.h>
-#include <linux/kdebug.h>
 #include <linux/platform_device.h>
 #include <linux/mutex.h>
 #include <linux/ratelimit.h>
@@ -947,7 +946,6 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 
 		sev = ghes_severity(ghes->estatus->error_severity);
 		if (sev >= GHES_SEV_PANIC) {
-			oops_begin();
 			ghes_print_queued_estatus();
 			__ghes_panic(ghes);
 		}
-- 
2.19.2
