Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD4A36B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 23:21:06 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id l7so35500898qtd.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 20:21:06 -0800 (PST)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id 1si1813070qkg.94.2017.01.18.20.21.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 20:21:05 -0800 (PST)
Received: by mail-qt0-x244.google.com with SMTP id a29so6268242qtb.1
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 20:21:05 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] zswap: change BUG to WARN in zswap_writeback_entry
Date: Wed, 18 Jan 2017 23:20:29 -0500
Message-Id: <20170119042029.31476-1-ddstreet@ieee.org>
In-Reply-To: <20170119030004.GA2046@jagdpanzerIV.localdomain>
References: <20170119030004.GA2046@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, sss123next@list.ru, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, bugzilla-daemon@bugzilla.kernel.org, Linux-MM <linux-mm@kvack.org>

Change the BUG calls to WARN, and return error.

There's no need to call BUG from this function, as it can safely return
the error.  The only caller of this function is the zpool that zswap is
using, when zswap is trying to reduce the zpool size.  While the error
does indicate a bug, as none of the WARN conditions should ever happen,
the zpool implementation can recover by trying to evict another page
or zswap will recover by sending the new page to the swap disk.

This was reported in kernel bug 192571:
https://bugzilla.kernel.org/show_bug.cgi?id=192571

Reported-by: Gluzskiy Alexandr <sss123next@list.ru>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zswap.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 067a0d6..60c4e6f 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -787,7 +787,10 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
 		return 0;
 	}
 	spin_unlock(&tree->lock);
-	BUG_ON(offset != entry->offset);
+	if (WARN_ON(offset != entry->offset)) {
+		ret = -EINVAL;
+		goto fail;
+	}
 
 	/* try to allocate swap cache page */
 	switch (zswap_get_swap_cache_page(swpentry, &page)) {
@@ -813,8 +816,13 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
 		put_cpu_ptr(entry->pool->tfm);
 		kunmap_atomic(dst);
 		zpool_unmap_handle(entry->pool->zpool, entry->handle);
-		BUG_ON(ret);
-		BUG_ON(dlen != PAGE_SIZE);
+		if (WARN(ret, "error decompressing page: %d\n", ret))
+			goto fail;
+		if (WARN(dlen != PAGE_SIZE,
+			 "decompressed page only %x bytes\n", dlen)) {
+			ret = -EINVAL;
+			goto fail;
+		}
 
 		/* page is up to date */
 		SetPageUptodate(page);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
