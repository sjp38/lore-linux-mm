Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB98B6B02DA
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 08:02:14 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id b132so107651044iti.5
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 05:02:14 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id m10si8435402paf.346.2016.11.11.05.02.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 05:02:14 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id e9so1563282pgc.1
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 05:02:13 -0800 (PST)
Date: Fri, 11 Nov 2016 14:02:07 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH] z3fold: discourage use of pages that weren't compacted
Message-Id: <20161111140207.1a5d89af4e0b37e9d23dcd36@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

If a z3fold page couldn't be compacted, we don't want it to be
used for next object allocation in the first place. It makes more
sense to add it to the end of the relevant unbuddied list. If that
page gets compacted later, it will be added to the beginning of
the list then.

This simple idea gives 5-7% improvement in randrw fio tests and
about 10% improvement in fio sequential read/write.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 32 ++++++++++++++++++++++----------
 1 file changed, 22 insertions(+), 10 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 5fe2652..eb8f9a0 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -277,10 +277,10 @@ static inline void *mchunk_memmove(struct z3fold_header *zhdr,
 
 #define BIG_CHUNK_GAP	3
 /* Has to be called with lock held */
-static int z3fold_compact_page(struct z3fold_header *zhdr)
+static bool z3fold_compact_page(struct z3fold_header *zhdr)
 {
 	struct page *page = virt_to_page(zhdr);
-	int ret = 0;
+	bool ret = false;
 
 	if (test_bit(MIDDLE_CHUNK_MAPPED, &page->private))
 		goto out;
@@ -292,7 +292,7 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
 			zhdr->middle_chunks = 0;
 			zhdr->start_middle = 0;
 			zhdr->first_num++;
-			ret = 1;
+			ret = true;
 			goto out;
 		}
 
@@ -304,7 +304,7 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
 		    zhdr->start_middle > zhdr->first_chunks + BIG_CHUNK_GAP) {
 			mchunk_memmove(zhdr, zhdr->first_chunks + 1);
 			zhdr->start_middle = zhdr->first_chunks + 1;
-			ret = 1;
+			ret = true;
 			goto out;
 		}
 		if (zhdr->last_chunks != 0 && zhdr->first_chunks == 0 &&
@@ -314,7 +314,7 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
 				zhdr->middle_chunks;
 			mchunk_memmove(zhdr, new_start);
 			zhdr->start_middle = new_start;
-			ret = 1;
+			ret = true;
 			goto out;
 		}
 	}
@@ -535,11 +535,19 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		free_z3fold_page(zhdr);
 		atomic64_dec(&pool->pages_nr);
 	} else {
-		z3fold_compact_page(zhdr);
+		bool compacted = z3fold_compact_page(zhdr);
 		/* Add to the unbuddied list */
 		spin_lock(&pool->lock);
 		freechunks = num_free_chunks(zhdr);
-		list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		/*
+		 * If the page has been compacted, we want to use it
+		 * in the first place.
+		 */
+		if (compacted)
+			list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		else
+			list_add_tail(&zhdr->buddy,
+				      &pool->unbuddied[freechunks]);
 		spin_unlock(&pool->lock);
 		z3fold_page_unlock(zhdr);
 	}
@@ -668,12 +676,16 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				spin_lock(&pool->lock);
 				list_add(&zhdr->buddy, &pool->buddied);
 			} else {
-				z3fold_compact_page(zhdr);
+				bool compacted = z3fold_compact_page(zhdr);
 				/* add to unbuddied list */
 				spin_lock(&pool->lock);
 				freechunks = num_free_chunks(zhdr);
-				list_add(&zhdr->buddy,
-					 &pool->unbuddied[freechunks]);
+				if (compacted)
+					list_add(&zhdr->buddy,
+						&pool->unbuddied[freechunks]);
+				else
+					list_add_tail(&zhdr->buddy,
+						&pool->unbuddied[freechunks]);
 			}
 		}
 
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
