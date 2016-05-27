Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C23F6B0264
	for <linux-mm@kvack.org>; Fri, 27 May 2016 12:06:08 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id h68so19544556lfh.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 09:06:08 -0700 (PDT)
Received: from mail-lb0-x241.google.com (mail-lb0-x241.google.com. [2a00:1450:4010:c04::241])
        by mx.google.com with ESMTPS id h10si28723lbs.137.2016.05.27.09.06.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 09:06:06 -0700 (PDT)
Received: by mail-lb0-x241.google.com with SMTP id rs7so1574176lbb.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 09:06:05 -0700 (PDT)
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH] z3fold: avoid modifying HEADLESS page and minor cleanup
Message-ID: <5748706F.9020208@gmail.com>
Date: Fri, 27 May 2016 18:06:07 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

This patch fixes erroneous z3fold header access in a HEADLESS page
in reclaim function, and changes one remaining direct
handle-to-buddy conversion to use the appropriate helper.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
  mm/z3fold.c | 24 ++++++++++++++----------
  1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 34917d5..8f9e89c 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -412,7 +412,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
  		/* HEADLESS page stored */
  		bud = HEADLESS;
  	} else {
-		bud = (handle - zhdr->first_num) & BUDDY_MASK;
+		bud = handle_to_buddy(handle);
  
  		switch (bud) {
  		case FIRST:
@@ -572,15 +572,19 @@ next:
  			pool->pages_nr--;
  			spin_unlock(&pool->lock);
  			return 0;
-		} else if (zhdr->first_chunks != 0 &&
-			   zhdr->last_chunks != 0 && zhdr->middle_chunks != 0) {
-			/* Full, add to buddied list */
-			list_add(&zhdr->buddy, &pool->buddied);
-		} else if (!test_bit(PAGE_HEADLESS, &page->private)) {
-			z3fold_compact_page(zhdr);
-			/* add to unbuddied list */
-			freechunks = num_free_chunks(zhdr);
-			list_add(&zhdr->buddy, &pool->unbuddied[freechunks]);
+		}  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
+			if (zhdr->first_chunks != 0 &&
+			    zhdr->last_chunks != 0 &&
+			    zhdr->middle_chunks != 0) {
+				/* Full, add to buddied list */
+				list_add(&zhdr->buddy, &pool->buddied);
+			} else {
+				z3fold_compact_page(zhdr);
+				/* add to unbuddied list */
+				freechunks = num_free_chunks(zhdr);
+				list_add(&zhdr->buddy,
+					 &pool->unbuddied[freechunks]);
+			}
  		}
  
  		/* add to beginning of LRU */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
