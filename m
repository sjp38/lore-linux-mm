Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C3DF628025A
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 17:04:35 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id rf5so28044121pab.3
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 14:04:35 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id uk7si9703608pab.97.2016.11.03.14.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 14:04:34 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id y68so5822153pfb.1
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 14:04:34 -0700 (PDT)
Date: Thu, 3 Nov 2016 22:04:28 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATH] z3fold: extend compaction function
Message-Id: <20161103220428.984a8d09d0c9569e6bc6b8cc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

z3fold_compact_page() currently only handles the situation when
there's a single middle chunk within the z3fold page. However it
may be worth it to move middle chunk closer to either first or
last chunk, whichever is there, if the gap between them is big
enough.

This patch adds the relevant code, using BIG_CHUNK_GAP define as
a threshold for middle chunk to be worth moving.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 60 +++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 47 insertions(+), 13 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 4d02280..fea6791 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -250,26 +250,60 @@ static void z3fold_destroy_pool(struct z3fold_pool *pool)
 	kfree(pool);
 }
 
+static inline void *mchunk_memmove(struct z3fold_header *zhdr,
+				unsigned short dst_chunk)
+{
+	void *beg = zhdr;
+	return memmove(beg + (dst_chunk << CHUNK_SHIFT),
+		       beg + (zhdr->start_middle << CHUNK_SHIFT),
+		       zhdr->middle_chunks << CHUNK_SHIFT);
+}
+
+#define BIG_CHUNK_GAP	3
 /* Has to be called with lock held */
 static int z3fold_compact_page(struct z3fold_header *zhdr)
 {
 	struct page *page = virt_to_page(zhdr);
-	void *beg = zhdr;
+	int ret = 0;
+
+	if (test_bit(MIDDLE_CHUNK_MAPPED, &page->private))
+		goto out;
 
+	if (zhdr->middle_chunks != 0) {
+		if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
+			mchunk_memmove(zhdr, 1); /* move to the beginning */
+			zhdr->first_chunks = zhdr->middle_chunks;
+			zhdr->middle_chunks = 0;
+			zhdr->start_middle = 0;
+			zhdr->first_num++;
+			ret = 1;
+			goto out;
+		}
 
-	if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
-	    zhdr->middle_chunks != 0 &&
-	    zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
-		memmove(beg + ZHDR_SIZE_ALIGNED,
-			beg + (zhdr->start_middle << CHUNK_SHIFT),
-			zhdr->middle_chunks << CHUNK_SHIFT);
-		zhdr->first_chunks = zhdr->middle_chunks;
-		zhdr->middle_chunks = 0;
-		zhdr->start_middle = 0;
-		zhdr->first_num++;
-		return 1;
+		/*
+		 * moving data is expensive, so let's only do that if
+		 * there's substantial gain (at least BIG_CHUNK_GAP chunks)
+		 */
+		if (zhdr->first_chunks != 0 && zhdr->last_chunks == 0 &&
+		    zhdr->start_middle > zhdr->first_chunks + BIG_CHUNK_GAP) {
+			mchunk_memmove(zhdr, zhdr->first_chunks + 1);
+			zhdr->start_middle = zhdr->first_chunks + 1;
+			ret = 1;
+			goto out;
+		}
+		if (zhdr->last_chunks != 0 && zhdr->first_chunks == 0 &&
+		    zhdr->middle_chunks + zhdr->last_chunks <=
+		    NCHUNKS - zhdr->start_middle - BIG_CHUNK_GAP) {
+			unsigned short new_start = NCHUNKS - zhdr->last_chunks -
+				zhdr->middle_chunks;
+			mchunk_memmove(zhdr, new_start);
+			zhdr->start_middle = new_start;
+			ret = 1;
+			goto out;
+		}
 	}
-	return 0;
+out:
+	return ret;
 }
 
 /**
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
