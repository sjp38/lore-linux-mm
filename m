Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8DC86B0313
	for <linux-mm@kvack.org>; Thu, 25 May 2017 02:47:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y65so218686211pff.13
        for <linux-mm@kvack.org>; Wed, 24 May 2017 23:47:05 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u69si26530689pgb.168.2017.05.24.23.47.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 23:47:05 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 07/13] mm, THP, swap: Support to write THP to swap device as a whole
Date: Thu, 25 May 2017 14:46:29 +0800
Message-Id: <20170525064635.2832-8-ying.huang@intel.com>
In-Reply-To: <20170525064635.2832-1-ying.huang@intel.com>
References: <20170525064635.2832-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@fb.com>

From: Huang Ying <ying.huang@intel.com>

In the patch, the swap writing is enhanced to support to write a
THP (Transparent Huge Page) as a whole.  This is a part of the THP
swap optimization and will improve swap write IO performance for the
more large continuous IOs.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Jens Axboe <axboe@fb.com>
---
 include/linux/page-flags.h    |  4 ++--
 include/linux/vm_event_item.h |  1 +
 mm/page_io.c                  | 21 ++++++++++++++++-----
 mm/vmstat.c                   |  1 +
 4 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index d33e3280c8ad..ba2d470d2d0a 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -303,8 +303,8 @@ PAGEFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
  * Only test-and-set exist for PG_writeback.  The unconditional operators are
  * risky: they bypass page accounting.
  */
-TESTPAGEFLAG(Writeback, writeback, PF_NO_COMPOUND)
-	TESTSCFLAG(Writeback, writeback, PF_NO_COMPOUND)
+TESTPAGEFLAG(Writeback, writeback, PF_NO_TAIL)
+	TESTSCFLAG(Writeback, writeback, PF_NO_TAIL)
 PAGEFLAG(MappedToDisk, mappedtodisk, PF_NO_TAIL)
 
 /* PG_readahead is only used for reads; PG_reclaim is only for writes */
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index d84ae90ccd5c..5b5b0f094060 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -84,6 +84,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
+		THP_SWPOUT,
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 		BALLOON_INFLATE,
diff --git a/mm/page_io.c b/mm/page_io.c
index 23f6d0d3470f..ec5229fb3607 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -27,16 +27,18 @@
 static struct bio *get_swap_bio(gfp_t gfp_flags,
 				struct page *page, bio_end_io_t end_io)
 {
+	int i, nr = hpage_nr_pages(page);
 	struct bio *bio;
 
-	bio = bio_alloc(gfp_flags, 1);
+	bio = bio_alloc(gfp_flags, nr);
 	if (bio) {
 		bio->bi_iter.bi_sector = map_swap_page(page, &bio->bi_bdev);
 		bio->bi_iter.bi_sector <<= PAGE_SHIFT - 9;
 		bio->bi_end_io = end_io;
 
-		bio_add_page(bio, page, PAGE_SIZE, 0);
-		BUG_ON(bio->bi_iter.bi_size != PAGE_SIZE);
+		for (i = 0; i < nr; i++)
+			bio_add_page(bio, page + i, PAGE_SIZE, 0);
+		VM_BUG_ON(bio->bi_iter.bi_size != PAGE_SIZE * nr);
 	}
 	return bio;
 }
@@ -257,6 +259,15 @@ static sector_t swap_page_sector(struct page *page)
 	return (sector_t)__page_file_index(page) << (PAGE_SHIFT - 9);
 }
 
+static inline void count_swpout_vm_event(struct page *page)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (unlikely(PageTransHuge(page)))
+		count_vm_event(THP_SWPOUT);
+#endif
+	count_vm_events(PSWPOUT, hpage_nr_pages(page));
+}
+
 int __swap_writepage(struct page *page, struct writeback_control *wbc,
 		bio_end_io_t end_write_func)
 {
@@ -308,7 +319,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 
 	ret = bdev_write_page(sis->bdev, swap_page_sector(page), page, wbc);
 	if (!ret) {
-		count_vm_event(PSWPOUT);
+		count_swpout_vm_event(page);
 		return 0;
 	}
 
@@ -321,7 +332,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 		goto out;
 	}
 	bio->bi_opf = REQ_OP_WRITE | wbc_to_write_flags(wbc);
-	count_vm_event(PSWPOUT);
+	count_swpout_vm_event(page);
 	set_page_writeback(page);
 	unlock_page(page);
 	submit_bio(bio);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c432e581f9a9..ebfd79df1008 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1070,6 +1070,7 @@ const char * const vmstat_text[] = {
 #endif
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
+	"thp_swpout",
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 	"balloon_inflate",
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
