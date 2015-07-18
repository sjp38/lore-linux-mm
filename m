Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id CA2BB280344
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 20:52:05 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so70424087pdj.3
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 17:52:05 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id qv6si21141015pab.172.2015.07.17.17.52.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 17:52:04 -0700 (PDT)
Received: by pacan13 with SMTP id an13so69093974pac.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 17:52:04 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v3] zsmalloc: do not take class lock in zs_shrinker_count()
Date: Sat, 18 Jul 2015 09:51:05 +0900
Message-Id: <1437180665-3607-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

We can avoid taking class ->lock around zs_can_compact() in
zs_shrinker_count(), because the number that we return back
is outdated in general case, by design. We have different
sources that are able to change class's state right after we
return from zs_can_compact() -- ongoing I/O operations, manually
triggered compaction, or two of them happening simultaneously.

We re-do this calculations during compaction on a per class basis
anyway.

zs_unregister_shrinker() will not return until we have an
active shrinker, so classes won't unexpectedly disappear
while zs_shrinker_count() iterates them.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 1edd8a0..c1399e8 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1711,8 +1711,6 @@ static struct page *isolate_source_page(struct size_class *class)
  *
  * Based on the number of unused allocated objects calculate
  * and return the number of pages that we can free.
- *
- * Should be called under class->lock.
  */
 static unsigned long zs_can_compact(struct size_class *class)
 {
@@ -1836,9 +1834,7 @@ static unsigned long zs_shrinker_count(struct shrinker *shrinker,
 		if (class->index != i)
 			continue;
 
-		spin_lock(&class->lock);
 		pages_to_free += zs_can_compact(class);
-		spin_unlock(&class->lock);
 	}
 
 	return pages_to_free;
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
