Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A64D6B0038
	for <linux-mm@kvack.org>; Sun, 25 Dec 2016 19:36:02 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id l68so103138827lfb.1
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 16:36:02 -0800 (PST)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id n74si3519292lfi.135.2016.12.25.16.36.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Dec 2016 16:36:00 -0800 (PST)
Received: by mail-lf0-x242.google.com with SMTP id x140so9970554lfa.2
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 16:36:00 -0800 (PST)
Date: Mon, 26 Dec 2016 01:34:48 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH/RESEND 2/5] mm/z3fold.c: extend compaction function
Message-Id: <20161226013448.d02b73ea0fca7edf0537162b@gmail.com>
In-Reply-To: <20161226013016.968004f3db024ef2111dc458@gmail.com>
References: <20161226013016.968004f3db024ef2111dc458@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

z3fold_compact_page() currently only handles the situation where there's a
single middle chunk within the z3fold page.  However it may be worth it to
move middle chunk closer to either first or last chunk, whichever is
there, if the gap between them is big enough.

Basically compression ratio wise, it always makes sense to move middle
chunk as close as possible to another in-page z3fold object, because then
the third object can use all the remaining space.  However, moving big
object just by one chunk will hurt performance without gaining much
compression ratio wise.  So the gap between the middle object and the edge
object should be big enough to justify the move.

So this patch improves compression ratio because in-page compaction
becomes more comprehensive; this patch (which came as a surprise) also
increases performance in fio randrw tests (I am not 100% sure why, but
probably due to less actual page allocations on hot path due to denser
in-page allocation).

This patch adds the relevant code, using BIG_CHUNK_GAP define as a
threshold for middle chunk to be worth moving.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 60 +++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 47 insertions(+), 13 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 2273789..d2e8aec 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -254,26 +254,60 @@ static void z3fold_destroy_pool(struct z3fold_pool *pool)
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
