Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7E14C82F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 12:28:54 -0400 (EDT)
Received: by lfaz124 with SMTP id z124so23792558lfa.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 09:28:53 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id rk9si6966048lbb.167.2015.10.21.09.28.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 09:28:53 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] kasan: always taint kernel on report.
Date: Wed, 21 Oct 2015 19:28:58 +0300
Message-ID: <1445444938-28018-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

Currently we already taint the kernel in some cases.
E.g. if we hit some bug in slub memory we call object_err()
which will taint the kernel with TAINT_BAD_PAGE flag.
But for other kind of bugs kernel left untainted.

Always taint with TAINT_BAD_PAGE if kasan found some bug.
This is useful for automated testing.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/kasan/report.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index f5e068a..12f222d 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -238,6 +238,7 @@ static void kasan_report_error(struct kasan_access_info *info)
 	}
 	pr_err("================================="
 		"=================================\n");
+	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
 	spin_unlock_irqrestore(&report_lock, flags);
 	kasan_enable_current();
 }
-- 
2.4.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
