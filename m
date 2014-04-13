Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 10E746B00B2
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 19:00:01 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so7506479pbc.16
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 16:00:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id si6si7753220pab.285.2014.04.13.16.00.00
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 16:00:01 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v3 2/7] Factor clean_buffers() out of __mpage_writepage()
Date: Sun, 13 Apr 2014 18:59:51 -0400
Message-Id: <633307eab154ee954ee10f0e0cf2222dd4816006.1397429628.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1397429628.git.matthew.r.wilcox@intel.com>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1397429628.git.matthew.r.wilcox@intel.com>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

__mpage_writepage() is over 200 lines long, has 20 local variables,
four goto labels and could desperately use simplification.  Splitting
clean_buffers() into a helper function improves matters a little,
removing 20+ lines from it.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/mpage.c | 54 ++++++++++++++++++++++++++++++------------------------
 1 file changed, 30 insertions(+), 24 deletions(-)

diff --git a/fs/mpage.c b/fs/mpage.c
index 4979ffa..4cc9c5d 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -439,6 +439,35 @@ struct mpage_data {
 	unsigned use_writepage;
 };
 
+/*
+ * We have our BIO, so we can now mark the buffers clean.  Make
+ * sure to only clean buffers which we know we'll be writing.
+ */
+static void clean_buffers(struct page *page, unsigned first_unmapped)
+{
+	unsigned buffer_counter = 0;
+	struct buffer_head *bh, *head;
+	if (!page_has_buffers(page))
+		return;
+	head = page_buffers(page);
+	bh = head;
+
+	do {
+		if (buffer_counter++ == first_unmapped)
+			break;
+		clear_buffer_dirty(bh);
+		bh = bh->b_this_page;
+	} while (bh != head);
+
+	/*
+	 * we cannot drop the bh if the page is not uptodate or a concurrent
+	 * readpage would fail to serialize with the bh and it would read from
+	 * disk before we reach the platter.
+	 */
+	if (buffer_heads_over_limit && PageUptodate(page))
+		try_to_free_buffers(page);
+}
+
 static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 		      void *data)
 {
@@ -591,30 +620,7 @@ alloc_new:
 		goto alloc_new;
 	}
 
-	/*
-	 * OK, we have our BIO, so we can now mark the buffers clean.  Make
-	 * sure to only clean buffers which we know we'll be writing.
-	 */
-	if (page_has_buffers(page)) {
-		struct buffer_head *head = page_buffers(page);
-		struct buffer_head *bh = head;
-		unsigned buffer_counter = 0;
-
-		do {
-			if (buffer_counter++ == first_unmapped)
-				break;
-			clear_buffer_dirty(bh);
-			bh = bh->b_this_page;
-		} while (bh != head);
-
-		/*
-		 * we cannot drop the bh if the page is not uptodate
-		 * or a concurrent readpage would fail to serialize with the bh
-		 * and it would read from disk before we reach the platter.
-		 */
-		if (buffer_heads_over_limit && PageUptodate(page))
-			try_to_free_buffers(page);
-	}
+	clean_buffers(page, first_unmapped);
 
 	BUG_ON(PageWriteback(page));
 	set_page_writeback(page);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
