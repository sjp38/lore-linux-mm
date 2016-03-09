Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0AA6B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 01:16:56 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id w104so33527632qge.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 22:16:56 -0800 (PST)
Received: from scadrial.mjdsystems.ca (scadrial.mjdsystems.ca. [198.100.154.185])
        by mx.google.com with ESMTPS id g83si6660576qhg.109.2016.03.08.22.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 22:16:55 -0800 (PST)
From: Matthew Dawson <matthew@mjdsystems.ca>
Subject: [PATCH] mm/mempool: Avoid KASAN marking mempool posion checks as use-after-free
Date: Wed,  9 Mar 2016 01:16:19 -0500
Message-Id: <1457504179-18942-1-git-send-email-matthew@mjdsystems.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

When removing an element from the mempool, mark it as unpoisoned in KASAN
before verifying its contents for SLUB/SLAB debugging.  Otherwise KASAN
will flag the reads checking the element use-after-free writes as
use-after-free reads.

Signed-off-by: Matthew Dawson <matthew@mjdsystems.ca>
---
 mm/mempool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempool.c b/mm/mempool.c
index 004d42b..7924f4f 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -135,8 +135,8 @@ static void *remove_element(mempool_t *pool)
 	void *element = pool->elements[--pool->curr_nr];
 
 	BUG_ON(pool->curr_nr < 0);
-	check_element(pool, element);
 	kasan_unpoison_element(pool, element);
+	check_element(pool, element);
 	return element;
 }
 
-- 
2.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
