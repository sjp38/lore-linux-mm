Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 63E43280322
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 07:19:22 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so61155766pdj.3
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 04:19:22 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id rh1si18195687pbc.88.2015.07.17.04.19.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 04:19:21 -0700 (PDT)
Received: by pdbqm3 with SMTP id qm3so60542637pdb.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 04:19:21 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v2] zsmalloc: do not take class lock in zs_shrinker_count()
Date: Fri, 17 Jul 2015 20:18:18 +0900
Message-Id: <1437131898-2231-1-git-send-email-sergey.senozhatsky@gmail.com>
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
---
 mm/zsmalloc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 1edd8a0..ed64cf5 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1836,9 +1836,7 @@ static unsigned long zs_shrinker_count(struct shrinker *shrinker,
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
