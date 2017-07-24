Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 839786B02FD
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 01:18:59 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id c14so140162964pgn.11
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 22:18:59 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f8si6429674pgr.494.2017.07.23.22.18.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jul 2017 22:18:58 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v3 06/12] Test code to write THP to swap device as a whole
Date: Mon, 24 Jul 2017 13:18:34 +0800
Message-Id: <20170724051840.2309-7-ying.huang@intel.com>
In-Reply-To: <20170724051840.2309-1-ying.huang@intel.com>
References: <20170724051840.2309-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>

From: Huang Ying <ying.huang@intel.com>

To support to delay splitting THP (Transparent Huge Page) after
swapped out.  We need to enhance swap writing code to support to write
a THP as a whole.  This will improve swap write IO performance.  As
Ming Lei <ming.lei@redhat.com> pointed out, this should be based on
multipage bvec support, which hasn't been merged yet.  So this patch
is only for testing the functionality of the other patches in the
series.  And will be reimplemented after multipage bvec support is
merged.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/bio.h           |  8 ++++++++
 include/linux/page-flags.h    |  4 ++--
 include/linux/vm_event_item.h |  1 +
 mm/page_io.c                  | 21 ++++++++++++++++-----
 mm/vmstat.c                   |  1 +
 5 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 7b1cf4ba0902..1f0720de8990 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -38,7 +38,15 @@
 #define BIO_BUG_ON
 #endif
 
+#ifdef CONFIG_THP_SWAP
+#if HPAGE_PMD_NR > 256
+#define BIO_MAX_PAGES		HPAGE_PMD_NR
+#else
 #define BIO_MAX_PAGES		256
+#endif
+#else
+#define BIO_MAX_PAGES		256
+#endif
 
 #define bio_prio(bio)			(bio)->bi_ioprio
 #define bio_set_prio(bio, prio)		((bio)->bi_ioprio = prio)
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
index 37e8d31a4632..c75024e80eed 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -85,6 +85,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
+		THP_SWPOUT,
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 		BALLOON_INFLATE,
diff --git a/mm/page_io.c b/mm/page_io.c
index b6c4ac388209..d5d9871a14e5 100644
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
@@ -260,6 +262,15 @@ static sector_t swap_page_sector(struct page *page)
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
@@ -311,7 +322,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 
 	ret = bdev_write_page(sis->bdev, swap_page_sector(page), page, wbc);
 	if (!ret) {
-		count_vm_event(PSWPOUT);
+		count_swpout_vm_event(page);
 		return 0;
 	}
 
@@ -324,7 +335,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 		goto out;
 	}
 	bio->bi_opf = REQ_OP_WRITE | wbc_to_write_flags(wbc);
-	count_vm_event(PSWPOUT);
+	count_swpout_vm_event(page);
 	set_page_writeback(page);
 	unlock_page(page);
 	submit_bio(bio);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9a4441bbeef2..bccf426453cd 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1071,6 +1071,7 @@ const char * const vmstat_text[] = {
 #endif
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
+	"thp_swpout",
 #endif
 #ifdef CONFIG_MEMORY_BALLOON
 	"balloon_inflate",
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
