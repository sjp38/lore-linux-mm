Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 56F646B0008
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 11:38:31 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x192-v6so1252879oix.2
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 08:38:31 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v13-v6si585779ota.230.2018.04.27.08.38.30
        for <linux-mm@kvack.org>;
        Fri, 27 Apr 2018 08:38:30 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v3 03/12] ACPI / APEI: don't wait to serialise with oops messages when panic()ing
Date: Fri, 27 Apr 2018 16:35:01 +0100
Message-Id: <20180427153510.5799-4-james.morse@arm.com>
In-Reply-To: <20180427153510.5799-1-james.morse@arm.com>
References: <20180427153510.5799-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

oops_begin() exists to group printk() messages with the oops message
printed by die(). To reach this caller we know that platform firmware
took this error first, then notified the OS via NMI with a 'panic'
severity.

Don't wait for another CPU to release the die-lock before we can
panic(), our only goal is to print this fatal error and panic().

This code is always called in_nmi(), and since 42a0bb3f7138 ("printk/nmi:
generic solution for safe printk in NMI"), it has been safe to call
printk() from this context. Messages are batched in a per-cpu buffer
and printed via irq-work, or a call back from panic().

Link: https://patchwork.kernel.org/patch/10313555/
Acked-by: Borislav Petkov <bp@suse.de>
Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index c8a6c5b0516e..ed8ad9898365 100644
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
@@ -758,9 +757,6 @@ static int _in_nmi_notify_one(struct ghes *ghes)
 
 	sev = ghes_severity(ghes->estatus->error_severity);
 	if (sev >= GHES_SEV_PANIC) {
-#ifdef CONFIG_X86
-		oops_begin();
-#endif
 		ghes_print_queued_estatus();
 		__ghes_panic(ghes);
 	}
-- 
2.16.2
