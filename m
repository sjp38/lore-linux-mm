Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 202BF6B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 10:06:26 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id b200so68447048lfe.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 07:06:26 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id x26si3626255lja.91.2017.01.11.07.06.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 07:06:24 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id v186so11665511lfa.2
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 07:06:24 -0800 (PST)
Date: Wed, 11 Jan 2017 16:06:22 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH/RESEND v2 3/5] z3fold: extend compaction function
Message-Id: <20170111160622.44ac261b12ed4778556c56dc@gmail.com>
In-Reply-To: <20170111155948.aa61c5b995b6523caf87d862@gmail.com>
References: <20170111155948.aa61c5b995b6523caf87d862@gmail.com>
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
 mm/z3fold.c | 26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 98ab01f..fca3310 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -268,6 +268,7 @@ static inline void *mchunk_memmove(struct z3fold_header *zhdr,
 		       zhdr->middle_chunks << CHUNK_SHIFT);
 }
 
+#define BIG_CHUNK_GAP	3
 /* Has to be called with lock held */
 static int z3fold_compact_page(struct z3fold_header *zhdr)
 {
@@ -286,8 +287,31 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
 		zhdr->middle_chunks = 0;
 		zhdr->start_middle = 0;
 		zhdr->first_num++;
+		return 1;
 	}
-	return 1;
+
+	/*
+	 * moving data is expensive, so let's only do that if
+	 * there's substantial gain (at least BIG_CHUNK_GAP chunks)
+	 */
+	if (zhdr->first_chunks != 0 && zhdr->last_chunks == 0 &&
+	    zhdr->start_middle - (zhdr->first_chunks + ZHDR_CHUNKS) >=
+			BIG_CHUNK_GAP) {
+		mchunk_memmove(zhdr, zhdr->first_chunks + 1);
+		zhdr->start_middle = zhdr->first_chunks + 1;
+		return 1;
+	} else if (zhdr->last_chunks != 0 && zhdr->first_chunks == 0 &&
+		   TOTAL_CHUNKS - (zhdr->last_chunks + zhdr->start_middle
+					+ zhdr->middle_chunks) >=
+			BIG_CHUNK_GAP) {
+		unsigned short new_start = NCHUNKS - zhdr->last_chunks -
+			zhdr->middle_chunks;
+		mchunk_memmove(zhdr, new_start);
+		zhdr->start_middle = new_start;
+		return 1;
+	}
+
+	return 0;
 }
 
 /**
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
