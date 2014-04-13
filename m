Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id C73076B00B3
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 19:00:02 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so7480275pbb.40
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 16:00:02 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id l4si7739007pbn.508.2014.04.13.16.00.01
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 16:00:01 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v3 3/7] Factor page_endio() out of mpage_end_io()
Date: Sun, 13 Apr 2014 18:59:52 -0400
Message-Id: <0e407d145508f69c966b0f9b26941cd6c619ebb1.1397429628.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1397429628.git.matthew.r.wilcox@intel.com>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1397429628.git.matthew.r.wilcox@intel.com>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

page_endio() takes care of updating all the appropriate page flags
once I/O has finished to a page.  Switch to using mapping_set_error()
instead of setting AS_EIO directly; this will handle thin-provisioned
devices correctly.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/mpage.c              | 18 +-----------------
 include/linux/pagemap.h |  2 ++
 mm/filemap.c            | 25 +++++++++++++++++++++++++
 3 files changed, 28 insertions(+), 17 deletions(-)

diff --git a/fs/mpage.c b/fs/mpage.c
index 4cc9c5d..10da0da 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -48,23 +48,7 @@ static void mpage_end_io(struct bio *bio, int err)
 
 	bio_for_each_segment_all(bv, bio, i) {
 		struct page *page = bv->bv_page;
-
-		if (bio_data_dir(bio) == READ) {
-			if (!err) {
-				SetPageUptodate(page);
-			} else {
-				ClearPageUptodate(page);
-				SetPageError(page);
-			}
-			unlock_page(page);
-		} else { /* bio_data_dir(bio) == WRITE */
-			if (err) {
-				SetPageError(page);
-				if (page->mapping)
-					set_bit(AS_EIO, &page->mapping->flags);
-			}
-			end_page_writeback(page);
-		}
+		page_endio(page, bio_data_dir(bio), err);
 	}
 
 	bio_put(bio);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 45598f1..718214c 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -425,6 +425,8 @@ static inline void wait_on_page_writeback(struct page *page)
 extern void end_page_writeback(struct page *page);
 void wait_for_stable_page(struct page *page);
 
+void page_endio(struct page *page, int rw, int err);
+
 /*
  * Add an arbitrary waiter to a page's wait queue
  */
diff --git a/mm/filemap.c b/mm/filemap.c
index a82fbe4..ee6a3ce 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -762,6 +762,31 @@ void end_page_writeback(struct page *page)
 }
 EXPORT_SYMBOL(end_page_writeback);
 
+/*
+ * After completing I/O on a page, call this routine to update the page
+ * flags appropriately
+ */
+void page_endio(struct page *page, int rw, int err)
+{
+	if (rw == READ) {
+		if (!err) {
+			SetPageUptodate(page);
+		} else {
+			ClearPageUptodate(page);
+			SetPageError(page);
+		}
+		unlock_page(page);
+	} else { /* rw == WRITE */
+		if (err) {
+			SetPageError(page);
+			if (page->mapping)
+				mapping_set_error(page->mapping, err);
+		}
+		end_page_writeback(page);
+	}
+}
+EXPORT_SYMBOL_GPL(page_endio);
+
 /**
  * __lock_page - get a lock on the page, assuming we need to sleep to get it
  * @page: the page to lock
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
