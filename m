Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4ACD96B0296
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 11:00:49 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id o1so5550609ito.7
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 08:00:49 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 19si16145105ior.109.2016.11.15.08.00.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 08:00:44 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id i88so8194730pfk.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 08:00:44 -0800 (PST)
Date: Tue, 15 Nov 2016 17:00:38 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 3/3] z3fold: discourage use of pages that weren't compacted
Message-Id: <20161115170038.75e127739b66f850e50d7fc1@gmail.com>
In-Reply-To: <20161115165538.878698352bd45e212751b57a@gmail.com>
References: <20161115165538.878698352bd45e212751b57a@gmail.com>
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
 mm/z3fold.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index ffd9353..e282ba0 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -539,11 +539,19 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		free_z3fold_page(zhdr);
 		atomic64_dec(&pool->pages_nr);
 	} else {
-		z3fold_compact_page(zhdr);
+		int compacted = z3fold_compact_page(zhdr);
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
@@ -672,12 +680,16 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				spin_lock(&pool->lock);
 				list_add(&zhdr->buddy, &pool->buddied);
 			} else {
-				z3fold_compact_page(zhdr);
+				int compacted = z3fold_compact_page(zhdr);
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
