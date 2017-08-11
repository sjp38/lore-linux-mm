Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B26D6B02F4
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 01:17:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b83so27627491pfl.6
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 22:17:50 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id r5si19582pfr.419.2017.08.10.22.17.48
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 22:17:49 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 4/7] mm:swap: remove end_swap_bio_write argument
Date: Fri, 11 Aug 2017 14:17:24 +0900
Message-Id: <1502428647-28928-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1502428647-28928-1-git-send-email-minchan@kernel.org>
References: <1502428647-28928-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

Every caller of __swap_writepage uses end_swap_bio_write as
end_write_func argument so the argument is pointless.
Remove it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h | 3 +--
 mm/page_io.c         | 7 +++----
 mm/zswap.c           | 2 +-
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 76f1632eea5a..ae3da979a7b7 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -336,8 +336,7 @@ extern void kswapd_stop(int nid);
 extern int swap_readpage(struct page *page, bool do_poll);
 extern int swap_writepage(struct page *page, struct writeback_control *wbc);
 extern void end_swap_bio_write(struct bio *bio);
-extern int __swap_writepage(struct page *page, struct writeback_control *wbc,
-	bio_end_io_t end_write_func);
+extern int __swap_writepage(struct page *page, struct writeback_control *wbc);
 extern int swap_set_page_dirty(struct page *page);
 
 int add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
diff --git a/mm/page_io.c b/mm/page_io.c
index 20139b90125a..3502a97f7c48 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -254,7 +254,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 		end_page_writeback(page);
 		goto out;
 	}
-	ret = __swap_writepage(page, wbc, end_swap_bio_write);
+	ret = __swap_writepage(page, wbc);
 out:
 	return ret;
 }
@@ -273,8 +273,7 @@ static inline void count_swpout_vm_event(struct page *page)
 	count_vm_events(PSWPOUT, hpage_nr_pages(page));
 }
 
-int __swap_writepage(struct page *page, struct writeback_control *wbc,
-		bio_end_io_t end_write_func)
+int __swap_writepage(struct page *page, struct writeback_control *wbc)
 {
 	struct bio *bio;
 	int ret;
@@ -329,7 +328,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 	}
 
 	ret = 0;
-	bio = get_swap_bio(GFP_NOIO, page, end_write_func);
+	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
 	if (bio == NULL) {
 		set_page_dirty(page);
 		unlock_page(page);
diff --git a/mm/zswap.c b/mm/zswap.c
index d39581a076c3..38db258515b5 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -900,7 +900,7 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
 	SetPageReclaim(page);
 
 	/* start writeback */
-	__swap_writepage(page, &wbc, end_swap_bio_write);
+	__swap_writepage(page, &wbc);
 	put_page(page);
 	zswap_written_back_pages++;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
