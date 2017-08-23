Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF0A6280396
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 11:25:35 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 83so3296262pgb.14
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:25:35 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id m11si1306443pln.20.2017.08.23.08.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 08:25:34 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id t12so334054pfk.0
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:25:34 -0700 (PDT)
From: Boqun Feng <boqun.feng@gmail.com>
Subject: [PATCH 1/2] nfit: Use init_completion() in acpi_nfit_flush_probe()
Date: Wed, 23 Aug 2017 23:25:37 +0800
Message-Id: <20170823152542.5150-2-boqun.feng@gmail.com>
In-Reply-To: <20170823152542.5150-1-boqun.feng@gmail.com>
References: <20170823152542.5150-1-boqun.feng@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, walken@google.com, Byungchul Park <byungchul.park@lge.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com, Boqun Feng <boqun.feng@gmail.com>, Dan Williams <dan.j.williams@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org

There is no need to use COMPLETION_INITIALIZER_ONSTACK() in
acpi_nfit_flush_probe(), replace it with init_completion().

Signed-off-by: Boqun Feng <boqun.feng@gmail.com>
---
 drivers/acpi/nfit/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/acpi/nfit/core.c b/drivers/acpi/nfit/core.c
index 19182d091587..1893e416e7c0 100644
--- a/drivers/acpi/nfit/core.c
+++ b/drivers/acpi/nfit/core.c
@@ -2884,7 +2884,7 @@ static int acpi_nfit_flush_probe(struct nvdimm_bus_descriptor *nd_desc)
 	 * need to be interruptible while waiting.
 	 */
 	INIT_WORK_ONSTACK(&flush.work, flush_probe);
-	COMPLETION_INITIALIZER_ONSTACK(flush.cmp);
+	init_completion(&flush.cmp);
 	queue_work(nfit_wq, &flush.work);
 	mutex_unlock(&acpi_desc->init_mutex);
 
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
