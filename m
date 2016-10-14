Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7DBD36B0038
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 13:10:07 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b80so2510868wme.4
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 10:10:07 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id b206si682809wmc.121.2016.10.14.10.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Oct 2016 10:10:06 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id d128so9695681wmf.1
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 10:10:06 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] kasan: support panic_on_warn
Date: Fri, 14 Oct 2016 19:10:02 +0200
Message-Id: <1476465002-2728-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, akpm@linux-foundation.org, glider@google.com
Cc: Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If user sets panic_on_warn, he wants kernel to panic if there is
anything barely wrong with the kernel. KASAN-detected errors
are definitely not less benign than an arbitrary kernel WARNING.

Panic after KASAN errors if panic_on_warn is set.

We use this for continuous fuzzing where we want kernel to stop
and reboot on any error.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev@googlegroups.com
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/kasan/report.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 24c1211..ca0bd48 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -133,6 +133,10 @@ static void kasan_end_report(unsigned long *flags)
 	pr_err("==================================================================\n");
 	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
 	spin_unlock_irqrestore(&report_lock, *flags);
+	if (panic_on_warn) {
+		panic_on_warn = 0;
+		panic("panic_on_warn set ...\n");
+	}
 	kasan_enable_current();
 }
 
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
