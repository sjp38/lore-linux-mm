Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 057E76B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 04:59:30 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z190so116589265qkc.4
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:59:30 -0700 (PDT)
Received: from mail-qt0-x229.google.com (mail-qt0-x229.google.com. [2607:f8b0:400d:c0d::229])
        by mx.google.com with ESMTPS id u86si17379714qki.249.2016.10.17.01.59.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 01:59:29 -0700 (PDT)
Received: by mail-qt0-x229.google.com with SMTP id f6so114223029qtd.2
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:59:29 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH v2] kasan: support panic_on_warn
Date: Mon, 17 Oct 2016 10:59:24 +0200
Message-Id: <1476694764-31986-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, glider@google.com, akpm@linux-foundation.org
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

Changes from v1:
 - don't reset panic_on_warn before calling panic()
---
 mm/kasan/report.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 24c1211..0ee8211 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -133,6 +133,8 @@ static void kasan_end_report(unsigned long *flags)
 	pr_err("==================================================================\n");
 	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
 	spin_unlock_irqrestore(&report_lock, *flags);
+	if (panic_on_warn)
+		panic("panic_on_warn set ...\n");
 	kasan_enable_current();
 }
 
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
