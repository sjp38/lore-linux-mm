Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 128688E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:17:58 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id q3-v6so13806908otl.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:17:58 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x19-v6si11961739oix.68.2018.09.21.15.17.56
        for <linux-mm@kvack.org>;
        Fri, 21 Sep 2018 15:17:56 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v6 03/18] ACPI / APEI: don't wait to serialise with oops messages when panic()ing
Date: Fri, 21 Sep 2018 23:16:50 +0100
Message-Id: <20180921221705.6478-4-james.morse@arm.com>
In-Reply-To: <20180921221705.6478-1-james.morse@arm.com>
References: <20180921221705.6478-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

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
index 29d863ff2f87..d7c46236b353 100644
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
2.19.0
