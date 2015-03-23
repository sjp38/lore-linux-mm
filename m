Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B9CA46B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 17:04:39 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so203068251pac.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 14:04:39 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id pc10si1110548pdb.109.2015.03.23.06.26.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 06:26:32 -0700 (PDT)
Received: by pacwe9 with SMTP id we9so191749582pac.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 06:26:32 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 2/2] zsmalloc: remove extra cond_resched() in __zs_compact
Date: Mon, 23 Mar 2015 22:26:39 +0900
Message-Id: <1427117199-2763-3-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1427117199-2763-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1427117199-2763-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Do not perform cond_resched() before the busy compaction
loop in __zs_compact(), because this loop does it when
needed.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index d1bbb04..d920e8b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1715,8 +1715,6 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 	struct page *dst_page = NULL;
 	unsigned long nr_total_migrated = 0;
 
-	cond_resched();
-
 	spin_lock(&class->lock);
 	while ((src_page = isolate_source_page(class))) {
 
-- 
2.3.3.262.ge80e85a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
