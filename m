Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C14546B025E
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 04:27:58 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e63so199237849ith.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 01:27:58 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id p191si18479497iod.221.2016.08.22.01.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 01:27:57 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC 1/4] vmscan.c: shrink_page_list: unmap anon pages after pageout
Date: Mon, 22 Aug 2016 16:25:06 +0800
Message-ID: <1471854309-30414-2-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
References: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, hughd@google.com, rostedt@goodmis.org, mingo@redhat.com, peterz@infradead.org, acme@kernel.org, alexander.shishkin@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, zhuhui@xiaomi.com, redkoi@virtuozzo.com, luto@kernel.org, kirill.shutemov@linux.intel.com, geliangtang@163.com, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, aarcange@redhat.com, dvlasenk@redhat.com, jmarchan@redhat.com, koct9i@gmail.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, ross.zwisler@linux.intel.com, tglx@linutronix.de, kwapulinski.piotr@gmail.com, axboe@fb.com, mchristi@redhat.com, joe@perches.com, namit@vmware.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com

The page is unmapped when ZRAM get the compressed size.  At it is added
to swapcache.
To remove it from swapcache need set each pte back to point to pfn.
But these is not a way to do it.

This patch set each pte readonly before pageout.  Then when the page is
written when save its data to ZRAM, its pte will be set to dirty.
After pageout, shrink_page_list will check the pte and re-dirty the page.
After pageout successfully and page is not dirty, unmap the page.

This patch doesn't handle the shmem file pages that use swap too.
The reason is I just find a hack way the make sure a page is shmem file
page. Then I separate code of shmem file pages to last patch of this
series.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 include/linux/rmap.h |  5 ++++
 mm/Kconfig           |  4 +++
 mm/page_io.c         | 11 ++++---
 mm/rmap.c            | 28 ++++++++++++++++++
 mm/vmscan.c          | 81 +++++++++++++++++++++++++++++++++++++++++-----------
 5 files changed, 108 insertions(+), 21 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index b46bb56..4259c46 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -88,6 +88,11 @@ enum ttu_flags {
 	TTU_LZFREE = 8,			/* lazy free mode */
 	TTU_SPLIT_HUGE_PMD = 16,	/* split huge PMD if any */
 
+#ifdef CONFIG_LATE_UNMAP
+	TTU_CHECK_DIRTY = (1 << 5),	/* Check dirty mode */
+	TTU_READONLY = (1 << 6),	/* Change readonly mode */
+#endif
+
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
 	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
 	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
diff --git a/mm/Kconfig b/mm/Kconfig
index 78a23c5..57ecdb3 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -704,3 +704,7 @@ config ARCH_USES_HIGH_VMA_FLAGS
 	bool
 config ARCH_HAS_PKEYS
 	bool
+
+config LATE_UNMAP
+	bool
+	depends on SWAP
diff --git a/mm/page_io.c b/mm/page_io.c
index 16bd82fa..adaf801 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -237,10 +237,13 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 {
 	int ret = 0;
 
-	if (try_to_free_swap(page)) {
-		unlock_page(page);
-		goto out;
-	}
+#ifdef CONFIG_LATE_UNMAP
+	if (!(PageAnon(page) && page_mapped(page)))
+#endif
+		if (try_to_free_swap(page)) {
+			unlock_page(page);
+			goto out;
+		}
 	if (frontswap_store(page) == 0) {
 		set_page_writeback(page);
 		unlock_page(page);
diff --git a/mm/rmap.c b/mm/rmap.c
index 1ef3640..d484f95 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1488,6 +1488,29 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		}
   	}
 
+#ifdef CONFIG_LATE_UNMAP
+	if ((flags & TTU_CHECK_DIRTY) || (flags & TTU_READONLY)) {
+		BUG_ON(!PageAnon(page));
+
+		pteval = *pte;
+
+		BUG_ON(pte_write(pteval) &&
+		       page_mapcount(page) + page_swapcount(page) > 1);
+
+		if ((flags & TTU_CHECK_DIRTY) && pte_dirty(pteval)) {
+			set_page_dirty(page);
+			pteval = pte_mkclean(pteval);
+		}
+
+		if (flags & TTU_READONLY)
+			pteval = pte_wrprotect(pteval);
+
+		if (!pte_same(*pte, pteval))
+			set_pte_at(mm, address, pte, pteval);
+		goto out_unmap;
+	}
+#endif
+
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
 	if (should_defer_flush(mm, flags)) {
@@ -1657,6 +1680,11 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 	else
 		ret = rmap_walk(page, &rwc);
 
+#ifdef CONFIG_LATE_UNMAP
+	if ((flags & (TTU_READONLY | TTU_CHECK_DIRTY)) &&
+	    ret == SWAP_AGAIN)
+		ret = SWAP_SUCCESS;
+#endif
 	if (ret != SWAP_MLOCK && !page_mapcount(page)) {
 		ret = SWAP_SUCCESS;
 		if (rp.lazyfreed && !PageDirty(page))
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 374d95d..32fef7d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -494,12 +494,19 @@ void drop_slab(void)
 
 static inline int is_page_cache_freeable(struct page *page)
 {
+	int count = page_count(page) - page_has_private(page);
+
+#ifdef CONFIG_LATE_UNMAP
+	if (PageAnon(page))
+		count -= page_mapcount(page);
+#endif
+
 	/*
 	 * A freeable page cache page is referenced only by the caller
 	 * that isolated the page, the page cache radix tree and
 	 * optional buffer heads at page->private.
 	 */
-	return page_count(page) - page_has_private(page) == 2;
+	return count == 2;
 }
 
 static int may_write_to_inode(struct inode *inode, struct scan_control *sc)
@@ -894,6 +901,22 @@ static void page_check_dirty_writeback(struct page *page,
 		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
 }
 
+#define TRY_TO_UNMAP(_page, _ttu_flags)				\
+	do {							\
+		switch (try_to_unmap(_page, _ttu_flags)) {	\
+		case SWAP_FAIL:					\
+			goto activate_locked;			\
+		case SWAP_AGAIN:				\
+			goto keep_locked;			\
+		case SWAP_MLOCK:				\
+			goto cull_mlocked;			\
+		case SWAP_LZFREE:				\
+			goto lazyfree;				\
+		case SWAP_SUCCESS:				\
+			; /* try to free the page below */	\
+		}						\
+	} while (0)
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -925,7 +948,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct page *page;
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
-		bool dirty, writeback;
+		bool dirty, writeback, anon;
 		bool lazyfree = false;
 		int ret = SWAP_SUCCESS;
 
@@ -1061,11 +1084,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			; /* try to reclaim the page below */
 		}
 
+		anon = PageAnon(page);
+
 		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page)) {
+		if (anon && !PageSwapCache(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
 			if (!add_to_swap(page, page_list))
@@ -1083,25 +1108,28 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		VM_BUG_ON_PAGE(PageTransHuge(page), page);
 
+		ttu_flags = lazyfree ?
+				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
+				(ttu_flags | TTU_BATCH_FLUSH);
+
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page) && mapping) {
-			switch (ret = try_to_unmap(page, lazyfree ?
-				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
-				(ttu_flags | TTU_BATCH_FLUSH))) {
-			case SWAP_FAIL:
-				goto activate_locked;
-			case SWAP_AGAIN:
-				goto keep_locked;
-			case SWAP_MLOCK:
-				goto cull_mlocked;
-			case SWAP_LZFREE:
-				goto lazyfree;
-			case SWAP_SUCCESS:
-				; /* try to free the page below */
-			}
+			enum ttu_flags l_ttu_flags = ttu_flags;
+
+#ifdef CONFIG_LATE_UNMAP
+			/* Hanle the pte_dirty
+			   and change pte to readonly.
+			   Write behavior before unmap will make
+			   pte dirty again.  Then we can check
+			   pte_dirty before unmap to make sure
+			   the page was written or not.  */
+			if (anon)
+				l_ttu_flags |= TTU_CHECK_DIRTY | TTU_READONLY;
+#endif
+			TRY_TO_UNMAP(page, l_ttu_flags);
 		}
 
 		if (PageDirty(page)) {
@@ -1157,6 +1185,25 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					goto keep;
 				if (PageDirty(page) || PageWriteback(page))
 					goto keep_locked;
+
+#ifdef CONFIG_LATE_UNMAP
+				if (anon) {
+					if (!PageSwapCache(page))
+						goto keep_locked;
+
+					/* Check if pte dirty by do_swap_page
+					   or do_wp_page.  */
+					TRY_TO_UNMAP(page,
+						     ttu_flags |
+						     TTU_CHECK_DIRTY);
+					if (PageDirty(page))
+						goto keep_locked;
+
+					if (page_mapped(page) && mapping)
+						TRY_TO_UNMAP(page, ttu_flags);
+				}
+#endif
+
 				mapping = page_mapping(page);
 			case PAGE_CLEAN:
 				; /* try to free the page below */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
