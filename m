Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 954F06B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 03:11:46 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id k14so13239857wgh.38
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 00:11:46 -0800 (PST)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id cz10si30179794wib.49.2014.12.01.00.11.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Dec 2014 00:11:45 -0800 (PST)
Received: by mail-wi0-f169.google.com with SMTP id r20so25925379wiv.0
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 00:11:45 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] Fix memory ordering bug in mm/vmalloc.c.
Date: Mon,  1 Dec 2014 11:11:26 +0300
Message-Id: <1417421486-13976-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Dmitry Vyukov <dvyukov@google.com>, edumazet@google.com, js1304@gmail.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

Read memory barriers must follow the read operations.

Cc: edumazet@google.com
Cc: js1304@gmail.com
Cc: iamjoonsoo.kim@lge.com
Cc: akpm@linux-foundation.org
Cc: linux-mm@kvack.org

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
---
 mm/vmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 90520af..e052a34 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2575,10 +2575,10 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 		if (!counters)
 			return;
 
-		/* Pair with smp_wmb() in clear_vm_uninitialized_flag() */
-		smp_rmb();
 		if (v->flags & VM_UNINITIALIZED)
 			return;
+		/* Pair with smp_wmb() in clear_vm_uninitialized_flag() */
+		smp_rmb();
 
 		memset(counters, 0, nr_node_ids * sizeof(unsigned int));
 
-- 
2.2.0.rc0.207.ga3a616c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
