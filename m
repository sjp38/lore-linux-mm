Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA0BE6B0266
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 03:53:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g62so221338207pfb.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 00:53:35 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id yk3si2971213pac.233.2016.07.01.00.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 00:53:35 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id ts6so9203236pac.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 00:53:35 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH] kasan/quarantine: fix NULL pointer dereference bug
Date: Fri,  1 Jul 2016 16:53:48 +0900
Message-Id: <1467359628-8493-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

If we move an item on qlist's tail, we need to update qlist's tail
properly. curr->next can be NULL since it is singly linked list
so it is invalid for tail. curr is scheduled to be moved so
using prev would be correct.

Unfortunately, I got this bug sometime ago and lose oops message.
But, the bug looks trivial and no need to attach oops.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/quarantine.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 4973505..9a132fd 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -255,7 +255,7 @@ static void qlist_move_cache(struct qlist_head *from,
 			} else
 				prev->next = curr->next;
 			if (unlikely(from->tail == qlink))
-				from->tail = curr->next;
+				from->tail = prev;
 			from->bytes -= cache->size;
 			qlist_put(to, qlink, cache->size);
 		} else {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
