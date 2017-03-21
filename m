Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7436B0388
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 05:10:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x124so1974875wmf.1
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 02:10:37 -0700 (PDT)
Received: from mail-wr0-x22b.google.com (mail-wr0-x22b.google.com. [2a00:1450:400c:c0c::22b])
        by mx.google.com with ESMTPS id f3si19031866wme.93.2017.03.21.02.10.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 02:10:36 -0700 (PDT)
Received: by mail-wr0-x22b.google.com with SMTP id u48so107781945wrc.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 02:10:36 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] kcov: simplify interrupt check
Date: Tue, 21 Mar 2017 10:10:26 +0100
Message-Id: <20170321091026.139655-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, James Morse <james.morse@arm.com>, Alexander Popov <alex.popov@linux.com>, Andrey Konovalov <andreyknvl@google.com>, linux-kernel@vger.kernel.org, syzkaller@googlegroups.com

in_interrupt() semantics are confusing and wrong for most users
as it also returns true when bh is disabled. Thus we open coded
a proper check for interrupts in __sanitizer_cov_trace_pc()
with a lengthy explanatory comment.

Use the new in_task() predicate instead.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kefeng Wang <wangkefeng.wang@huawei.com>
Cc: James Morse <james.morse@arm.com>
Cc: Alexander Popov <alex.popov@linux.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: syzkaller@googlegroups.com
---
 kernel/kcov.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/kernel/kcov.c b/kernel/kcov.c
index 85e5546cd791..cd771993f96f 100644
--- a/kernel/kcov.c
+++ b/kernel/kcov.c
@@ -60,15 +60,8 @@ void notrace __sanitizer_cov_trace_pc(void)
 	/*
 	 * We are interested in code coverage as a function of a syscall inputs,
 	 * so we ignore code executed in interrupts.
-	 * The checks for whether we are in an interrupt are open-coded, because
-	 * 1. We can't use in_interrupt() here, since it also returns true
-	 *    when we are inside local_bh_disable() section.
-	 * 2. We don't want to use (in_irq() | in_serving_softirq() | in_nmi()),
-	 *    since that leads to slower generated code (three separate tests,
-	 *    one for each of the flags).
 	 */
-	if (!t || (preempt_count() & (HARDIRQ_MASK | SOFTIRQ_OFFSET
-							| NMI_MASK)))
+	if (!t || !in_task())
 		return;
 	mode = READ_ONCE(t->kcov_mode);
 	if (mode == KCOV_MODE_TRACE) {
-- 
2.12.1.500.gab5fba24ee-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
