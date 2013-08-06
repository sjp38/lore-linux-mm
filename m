Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id A30476B0037
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 07:37:30 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id bg4so604364pad.18
        for <linux-mm@kvack.org>; Tue, 06 Aug 2013 04:37:29 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH v2 4/4] mm: add WasActive page flag
Date: Tue,  6 Aug 2013 19:36:17 +0800
Message-Id: <1375788977-12105-5-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
References: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: gregkh@linuxfoundation.org, ngupta@vflare.org, akpm@linux-foundation.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, riel@redhat.com, mgorman@suse.de, kyungmin.park@samsung.com, p.sarna@partner.samsung.com, barry.song@csr.com, penberg@kernel.org, Bob Liu <bob.liu@oracle.com>

Zcache could be ineffective if the compressed memory pool is full with
compressed inactive file pages and most of them will be never used again.

So we pick up pages from active file list only, those pages would probably be
accessed again. Compress them in memory can reduce the latency significantly
compared with rereading from disk.

When a file page is shrinked from active file list to inactive file list,
PageActive flag is also cleared.
So adding an extra WasActive page flag for zcache to know whether the file page
was shrinked from the active list.

Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 include/linux/page-flags.h |    9 ++++++++-
 mm/page_alloc.c            |    3 +++
 mm/vmscan.c                |   11 ++++++++++-
 mm/zcache.c                |   15 +++++++++++++++
 4 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6d53675..ab433916 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -109,6 +109,9 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+#ifdef CONFIG_CLEANCACHE
+	PG_was_active,
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -210,6 +213,9 @@ PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 
 __PAGEFLAG(SlobFree, slob_free)
+#ifdef CONFIG_CLEANCACHE
+PAGEFLAG(WasActive, was_active)
+#endif
 
 /*
  * Private page markings that may be used by the filesystem that owns the page
@@ -509,7 +515,8 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
  * Pages being prepped should not have any flags set.  It they are set,
  * there has been a kernel bug or struct page corruption.
  */
-#define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
+#define PAGE_FLAGS_CHECK_AT_PREP	(((1 << NR_PAGEFLAGS) - 1) |\
+	(1 << PG_was_active))
 
 #define PAGE_FLAGS_PRIVATE				\
 	(1 << PG_private | 1 << PG_private_2)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..9505ced 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6345,6 +6345,9 @@ static const struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	{1UL << PG_compound_lock,	"compound_lock"	},
 #endif
+#ifdef CONFIG_CLEANCACHE
+	{1UL << PG_was_active,	"was_active"	},
+#endif
 };
 
 static void dump_page_flags(unsigned long flags)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2cff0d4..674f33f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1325,8 +1325,11 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 		lru = page_lru(page);
 		add_page_to_lru_list(page, lruvec, lru);
 
+		int file = is_file_lru(lru);
+		if (IS_ENABLED(CONFIG_ZCACHE))
+			if (file)
+				SetPageWasActive(page);
 		if (is_active_lru(lru)) {
-			int file = is_file_lru(lru);
 			int numpages = hpage_nr_pages(page);
 			reclaim_stat->recent_rotated[file] += numpages;
 		}
@@ -1632,6 +1635,12 @@ static void shrink_active_list(unsigned long nr_to_scan,
 		}
 
 		ClearPageActive(page);	/* we are de-activating */
+		if (IS_ENABLED(CONFIG_ZCACHE))
+			/*
+			 * For zcache to know whether the page is from active
+			 * file list
+			 */
+			SetPageWasActive(page);
 		list_add(&page->lru, &l_inactive);
 	}
 
diff --git a/mm/zcache.c b/mm/zcache.c
index 8c3222e..97ca274 100644
--- a/mm/zcache.c
+++ b/mm/zcache.c
@@ -67,6 +67,7 @@ static u64 zcache_zbud_alloc_fail;
 static u64 zcache_pool_pages;
 static u64 zcache_evict_zpages;
 static u64 zcache_evict_filepages;
+static u64 zcache_inactive_pages_refused;
 static u64 zcache_reclaim_fail;
 static atomic_t zcache_stored_pages = ATOMIC_INIT(0);
 
@@ -495,6 +496,17 @@ static void zcache_store_page(int pool_id, struct cleancache_filekey key,
 
 	struct zcache_pool *zpool = zcache.pools[pool_id];
 
+	/*
+	 * Zcache will be ineffective if the compressed memory pool is full with
+	 * compressed inactive file pages and most of them will never be used
+	 * again.
+	 * So we refuse to compress pages that are not from active file list.
+	 */
+	if (!PageWasActive(page)) {
+		zcache_inactive_pages_refused++;
+		return;
+	}
+
 	if (zcache_is_full()) {
 		zcache_pool_limit_hit++;
 		if (zbud_reclaim_page(zpool->pool, 8)) {
@@ -588,6 +600,7 @@ static int zcache_load_page(int pool_id, struct cleancache_filekey key,
 	/* update stats */
 	atomic_dec(&zcache_stored_pages);
 	zcache_pool_pages = zbud_get_pool_size(zpool->pool);
+	SetPageWasActive(page);
 	return ret;
 }
 
@@ -873,6 +886,8 @@ static int __init zcache_debugfs_init(void)
 			&zcache_evict_filepages);
 	debugfs_create_u64("reclaim_fail", S_IRUGO, zcache_debugfs_root,
 			&zcache_reclaim_fail);
+	debugfs_create_u64("inactive_pages_refused", S_IRUGO,
+			zcache_debugfs_root, &zcache_inactive_pages_refused);
 	return 0;
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
