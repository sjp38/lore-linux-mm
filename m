Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED486B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 22:53:49 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so61445321pdr.2
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 19:53:49 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id sz10si17158966pab.68.2015.07.10.19.53.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 19:53:47 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so1694189pac.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 19:53:47 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 1/2] mm/shrinker: do not NULL dereference uninitialized shrinker
Date: Sat, 11 Jul 2015 11:51:54 +0900
Message-Id: <1436583115-6323-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1436583115-6323-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1436583115-6323-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Consider 'all zeroes' shrinker as 'initialized, but not
registered', and, thus, don't unregister such a shrinker.
This helps to avoid accidental NULL pointer dereferences,
when a zeroed shrinker struct is getting passed to
unregister_shrinker() in error handing path, for example.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/vmscan.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c8d8282..cadc8a2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -254,6 +254,12 @@ EXPORT_SYMBOL(register_shrinker);
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
+	/*
+	 * All-zeroes is 'initialized, but not registered' shrinker.
+	 */
+	if (unlikely(!shrinker->list.next))
+		return;
+
 	down_write(&shrinker_rwsem);
 	list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
