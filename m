Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 24FB16B0036
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 12:40:39 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id cc10so2037086wib.16
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 09:40:38 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id j6si1664904wia.101.2014.03.26.09.40.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Mar 2014 09:40:37 -0700 (PDT)
Received: by mail-wi0-f175.google.com with SMTP id cc10so4874704wib.8
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 09:40:37 -0700 (PDT)
Date: Wed, 26 Mar 2014 17:40:28 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [PATCH] mm: remove unused arg of set_page_dirty_balance()
Message-ID: <20140326164028.GA10187@tucsk.piliscsaba.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Miklos Szeredi <mszeredi@suse.cz>

There's only one caller of set_page_dirty_balance() and that will call it
with page_mkwrite == 0.

The page_mkwrite argument was unused since commit b827e496c893 "mm: close
page_mkwrite races".

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 include/linux/writeback.h |    2 +-
 mm/memory.c               |    2 +-
 mm/page-writeback.c       |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -178,7 +178,7 @@ int write_cache_pages(struct address_spa
 		      struct writeback_control *wbc, writepage_t writepage,
 		      void *data);
 int do_writepages(struct address_space *mapping, struct writeback_control *wbc);
-void set_page_dirty_balance(struct page *page, int page_mkwrite);
+void set_page_dirty_balance(struct page *page);
 void writeback_set_ratelimit(void);
 void tag_pages_for_writeback(struct address_space *mapping,
 			     pgoff_t start, pgoff_t end);
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2752,7 +2752,7 @@ static int do_wp_page(struct mm_struct *
 		 */
 		if (!page_mkwrite) {
 			wait_on_page_locked(dirty_page);
-			set_page_dirty_balance(dirty_page, page_mkwrite);
+			set_page_dirty_balance(dirty_page);
 			/* file_update_time outside page_lock */
 			if (vma->vm_file)
 				file_update_time(vma->vm_file);
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1562,9 +1562,9 @@ static void balance_dirty_pages(struct a
 		bdi_start_background_writeback(bdi);
 }
 
-void set_page_dirty_balance(struct page *page, int page_mkwrite)
+void set_page_dirty_balance(struct page *page)
 {
-	if (set_page_dirty(page) || page_mkwrite) {
+	if (set_page_dirty(page)) {
 		struct address_space *mapping = page_mapping(page);
 
 		if (mapping)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
