Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C7A26280947
	for <linux-mm@kvack.org>; Sat, 11 Mar 2017 16:22:51 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id p78so72899522lfd.0
        for <linux-mm@kvack.org>; Sat, 11 Mar 2017 13:22:51 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id y18si7179842lja.11.2017.03.11.13.22.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Mar 2017 13:22:50 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id v2so9247775lfi.2
        for <linux-mm@kvack.org>; Sat, 11 Mar 2017 13:22:50 -0800 (PST)
Date: Sat, 11 Mar 2017 22:22:39 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH] z3fold: fix spinlock unlocking in page reclaim
Message-Id: <20170311222239.7b83d8e7ef1914e05497649f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>

The patch "z3fold: add kref refcounting" introduced a bug in
z3fold_reclaim_page() with function exit that may leave pool->lock
spinlock held. Here comes the trivial fix.

Reported-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 8970a2f..f9492bc 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -667,6 +667,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			z3fold_page_unlock(zhdr);
 			spin_lock(&pool->lock);
 			if (kref_put(&zhdr->refcount, release_z3fold_page)) {
+				spin_unlock(&pool->lock);
 				atomic64_dec(&pool->pages_nr);
 				return 0;
 			}
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
