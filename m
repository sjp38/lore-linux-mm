Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 064FF6B0298
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:49:55 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id t76so20411939pfk.7
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:49:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h88sor9466669pfk.10.2017.11.27.23.49.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:49:54 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 10/18] vchecker: Use __GFP_ATOMIC to save stacktrace
Date: Tue, 28 Nov 2017 16:48:45 +0900
Message-Id: <1511855333-3570-11-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Namhyung Kim <namhyung@kernel.org>

Since we're finding a cause of broken data, it'd be desired not to miss
any suspects.  It doesn't use GFP_ATOMIC since it includes __GFP_HIGH
which is for system making forward progress.

It also adds a WARN_ON whenever it fails to allocate pages even with
__GFP_ATOMIC.

Signed-off-by: Namhyung Kim <namhyung@kernel.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/vchecker.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
index 6b3824f..df480d5 100644
--- a/mm/kasan/vchecker.c
+++ b/mm/kasan/vchecker.c
@@ -301,13 +301,20 @@ static noinline depot_stack_handle_t save_stack(int skip, bool *is_new)
 		.max_entries = VCHECKER_STACK_DEPTH,
 		.skip = skip,
 	};
+	depot_stack_handle_t handle;
 
 	save_stack_trace(&trace);
 	if (trace.nr_entries != 0 &&
 	    trace.entries[trace.nr_entries-1] == ULONG_MAX)
 		trace.nr_entries--;
 
-	return depot_save_stack(NULL, &trace, GFP_NOWAIT, is_new);
+	if (trace.nr_entries == 0)
+		return 0;
+
+	handle = depot_save_stack(NULL, &trace, __GFP_ATOMIC, is_new);
+	WARN_ON(!handle);
+
+	return handle;
 }
 
 static ssize_t vchecker_type_write(struct file *filp, const char __user *ubuf,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
