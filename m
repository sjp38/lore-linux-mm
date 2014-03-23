Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 16F736B0031
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 15:08:41 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so4515940pad.15
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:08:40 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id tk9si7728991pac.88.2014.03.23.12.08.39
        for <linux-mm@kvack.org>;
        Sun, 23 Mar 2014 12:08:40 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v2 4/6] swap: Use bdev_read_page() / bdev_write_page()
Date: Sun, 23 Mar 2014 15:08:26 -0400
Message-Id: <67a4f1fde869717a22bd22724b6449e6343406ba.1395593198.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395593198.git.matthew.r.wilcox@intel.com>
References: <cover.1395593198.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395593198.git.matthew.r.wilcox@intel.com>
References: <cover.1395593198.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 mm/page_io.c | 23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 7c59ef6..43d7220 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -248,11 +248,16 @@ out:
 	return ret;
 }
 
+static sector_t swap_page_sector(struct page *page)
+{
+	return (sector_t)__page_file_index(page) << (PAGE_CACHE_SHIFT - 9);
+}
+
 int __swap_writepage(struct page *page, struct writeback_control *wbc,
 	void (*end_write_func)(struct bio *, int))
 {
 	struct bio *bio;
-	int ret = 0, rw = WRITE;
+	int ret, rw = WRITE;
 	struct swap_info_struct *sis = page_swap_info(page);
 
 	if (sis->flags & SWP_FILE) {
@@ -297,6 +302,13 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 		return ret;
 	}
 
+	ret = bdev_write_page(sis->bdev, swap_page_sector(page), page, wbc);
+	if (!ret) {
+		count_vm_event(PSWPOUT);
+		return 0;
+	}
+
+	ret = 0;
 	bio = get_swap_bio(GFP_NOIO, page, end_write_func);
 	if (bio == NULL) {
 		set_page_dirty(page);
@@ -317,7 +329,7 @@ out:
 int swap_readpage(struct page *page)
 {
 	struct bio *bio;
-	int ret = 0;
+	int ret;
 	struct swap_info_struct *sis = page_swap_info(page);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
@@ -338,6 +350,13 @@ int swap_readpage(struct page *page)
 		return ret;
 	}
 
+	ret = bdev_read_page(sis->bdev, swap_page_sector(page), page);
+	if (!ret) {
+		count_vm_event(PSWPIN);
+		return 0;
+	}
+
+	ret = 0;
 	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
 	if (bio == NULL) {
 		unlock_page(page);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
