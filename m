Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id D86E86B0082
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 08:37:13 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so5701001pdb.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:37:13 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id jx7si69819221pbc.201.2015.06.30.05.37.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 05:37:13 -0700 (PDT)
Received: by pabvl15 with SMTP id vl15so5104297pab.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:37:12 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCHv4 6/7] zsmalloc: account the number of compacted pages
Date: Tue, 30 Jun 2015 21:35:57 +0900
Message-Id: <1435667758-14075-7-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1435667758-14075-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1435667758-14075-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Compaction returns back to zram the number of migrated objects,
which is quite uninformative -- we have objects of different
sizes so user space cannot obtain any valuable data from that
number. Change compaction to operate in terms of pages and
return back to compaction issuer the number of pages that
were freed during compaction. So from now on `num_compacted'
column in zram<id>/mm_stat represents more meaningful value:
the number of freed (compacted) pages.

Update documentation.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 Documentation/blockdev/zram.txt | 3 ++-
 mm/zsmalloc.c                   | 8 ++++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
index c4de576..71f4744 100644
--- a/Documentation/blockdev/zram.txt
+++ b/Documentation/blockdev/zram.txt
@@ -144,7 +144,8 @@ mem_used_max      RW    the maximum amount memory zram have consumed to
                         store compressed data
 mem_limit         RW    the maximum amount of memory ZRAM can use to store
                         the compressed data
-num_migrated      RO    the number of objects migrated migrated by compaction
+num_migrated      RO    the number of pages freed during compaction
+                        (available only via zram<id>/mm_stat node)
 compact           WO    trigger memory compaction
 
 WARNING
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e0f508a..51165df 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -245,7 +245,7 @@ struct zs_pool {
 	/* Allocation flags used when growing pool */
 	gfp_t			flags;
 	atomic_long_t		pages_allocated;
-	/* How many objects were migrated */
+	/* How many pages were migrated (freed) */
 	unsigned long		num_migrated;
 
 #ifdef CONFIG_ZSMALLOC_STAT
@@ -1758,7 +1758,11 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 	if (src_page)
 		putback_zspage(pool, class, src_page);
 
-	pool->num_migrated += cc.nr_migrated;
+	cc.nr_migrated /= get_maxobj_per_zspage(class->size,
+			class->pages_per_zspage);
+
+	pool->num_migrated += cc.nr_migrated *
+		get_pages_per_zspage(class->size);
 
 	spin_unlock(&class->lock);
 }
-- 
2.5.0.rc0.3.g912bd49

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
