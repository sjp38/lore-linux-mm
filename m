Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 8BECD6B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 10:30:12 -0400 (EDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MQ30083D4A8AZV0@mailout1.samsung.com> for linux-mm@kvack.org;
 Wed, 17 Jul 2013 23:30:10 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [PATCH] mm: zbud: fix condition check on allocation size
Date: Wed, 17 Jul 2013 23:30:10 +0900
Message-id: <1374071410-9337-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dongjun Shin <d.j.shin@samsung.com>, Sunae Seo <sunae.seo@samsung.com>, Heesub Shin <heesub@gmail.com>, Heesub Shin <heesub.shin@samsung.com>

zbud_alloc() incorrectly verifies the size of allocation limit. It
should deny the allocation request greater than (PAGE_SIZE -
ZHDR_SIZE_ALIGNED - CHUNK_SIZE), not (PAGE_SIZE - ZHDR_SIZE_ALIGNED)
which has no remaining spaces for its buddy. There is no point in
spending the entire zbud page storing only a single page, since we don't
have any benefits.

Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
---
 mm/zbud.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index 9bb4710..ad1e781 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -257,7 +257,7 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 
 	if (size <= 0 || gfp & __GFP_HIGHMEM)
 		return -EINVAL;
-	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED)
+	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
 		return -ENOSPC;
 	chunks = size_to_chunks(size);
 	spin_lock(&pool->lock);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
