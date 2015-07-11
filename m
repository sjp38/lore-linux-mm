Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id BE623280244
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 05:46:37 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so53198297pdb.0
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 02:46:37 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id zl8si18570470pac.150.2015.07.11.02.46.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jul 2015 02:46:37 -0700 (PDT)
Received: by pdbqm3 with SMTP id qm3so53198233pdb.0
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 02:46:36 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 3/3] zsmalloc: do not take class lock in zs_pages_to_compact()
Date: Sat, 11 Jul 2015 18:45:32 +0900
Message-Id: <1436607932-7116-4-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

We can avoid taking class ->lock around zs_can_compact() in
zs_pages_to_compact(), because the number that we return back
is outdated in general case, by design. We have different
source that are able to change class's state right after we
return from zs_can_compact() -- ongoing IO operations, manually
triggered compaction or automatic compaction, or all three
simultaneously.

We re-do this calculations during compaction on a per class basis
anyway.

zs_unregister_shrinker() will not return until we have an active
shrinker, so classes won't unexpectedly disappear while
zs_pages_to_compact(), invoked by zs_shrinker_count(), iterates
them.

When called from zram, we are protected by zram's ->init_lock,
so, again, classes will be there until zs_pages_to_compact()
iterates them.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b10a228..824c182 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1811,9 +1811,7 @@ unsigned long zs_pages_to_compact(struct zs_pool *pool)
 		if (class->index != i)
 			continue;
 
-		spin_lock(&class->lock);
 		pages_to_free += zs_can_compact(class);
-		spin_unlock(&class->lock);
 	}
 
 	return pages_to_free;
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
