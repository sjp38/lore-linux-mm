Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 140296B0062
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:53:13 -0400 (EDT)
Received: by mail-qc0-f179.google.com with SMTP id x3so1465292qcv.24
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:53:12 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id k5si14172572qgf.166.2014.05.02.06.53.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:53:12 -0700 (PDT)
Received: by mail-qg0-f50.google.com with SMTP id 63so4661519qgz.37
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:53:12 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 09/11] fs/ext4: add support for hmm migration to remote memory of pagecache.
Date: Fri,  2 May 2014 09:52:08 -0400
Message-Id: <1399038730-25641-10-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This add support for migrating page of ext4 filesystem to remote device
memory using the hmm infrastructure. Writeback need special handling as
we want to keep content inside remote memory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 fs/ext4/file.c  |  20 +++++++
 fs/ext4/inode.c | 175 +++++++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 174 insertions(+), 21 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 708aad7..7c787d5 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -26,6 +26,7 @@
 #include <linux/aio.h>
 #include <linux/quotaops.h>
 #include <linux/pagevec.h>
+#include <linux/hmm.h>
 #include "ext4.h"
 #include "ext4_jbd2.h"
 #include "xattr.h"
@@ -304,6 +305,7 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 		unsigned long nr_pages;
 
 		num = min_t(pgoff_t, end - index, PAGEVEC_SIZE);
+retry:
 		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, index,
 					  (pgoff_t)num);
 		if (nr_pages == 0) {
@@ -321,6 +323,24 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 			break;
 		}
 
+		for (i = 0; i < nr_pages; i++) {
+			struct page *page = pvec.pages[i];
+
+			if (radix_tree_exception(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				/* FIXME How to handle hmm migration failure ? */
+				hmm_pagecache_migrate(inode->i_mapping, swap);
+				for (; i < nr_pages; i++) {
+					if (radix_tree_exception(pvec.pages[i])) {
+						pvec.pages[i] = NULL;
+					}
+				}
+				pagevec_release(&pvec);
+				goto retry;
+			}
+		}
+
 		/*
 		 * If this is the first time to go into the loop and
 		 * offset is smaller than the first page offset, it will be a
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index b1dc334..f2558e2 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -39,6 +39,7 @@
 #include <linux/ratelimit.h>
 #include <linux/aio.h>
 #include <linux/bitops.h>
+#include <linux/hmm.h>
 
 #include "ext4_jbd2.h"
 #include "xattr.h"
@@ -1462,16 +1463,37 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 			break;
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
-			if (page->index > end)
-				break;
-			BUG_ON(!PageLocked(page));
-			BUG_ON(PageWriteback(page));
-			if (invalidate) {
-				block_invalidatepage(page, 0, PAGE_CACHE_SIZE);
-				ClearPageUptodate(page);
+
+			if (radix_tree_exceptional_entry(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				page = hmm_pagecache_page(mapping, swap);
+				pvec.pages[i] = page;
+				if (page->index > end)
+					break;
+			} else {
+				if (page->index > end)
+					break;
+				BUG_ON(!PageLocked(page));
+				BUG_ON(PageWriteback(page));
+				if (invalidate) {
+					block_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+					ClearPageUptodate(page);
+				}
 			}
 			unlock_page(page);
 		}
+		for (; i < nr_pages; i++) {
+			struct page *page = pvec.pages[i];
+
+			if (radix_tree_exceptional_entry(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				page = hmm_pagecache_page(mapping, swap);
+				unlock_page(page);
+				pvec.pages[i] = page;
+			}
+		}
 		index = pvec.pages[nr_pages - 1]->index + 1;
 		pagevec_release(&pvec);
 	}
@@ -2060,6 +2082,20 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 					  PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			break;
+
+		/* Replace hmm entry with the page backing it. At this point
+		 * they are uptodate and locked.
+		 */
+		for (i = 0; i < nr_pages; i++) {
+			struct page *page = pvec.pages[i];
+
+			if (radix_tree_exceptional_entry(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				 pvec.pages[i] = hmm_pagecache_page(inode->i_mapping, swap);
+			}
+		}
+
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
@@ -2331,13 +2367,61 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 	mpd->map.m_len = 0;
 	mpd->next_page = index;
 	while (index <= end) {
+		pgoff_t save_index = index;
+		bool migrated;
+
 		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
 			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
 		if (nr_pages == 0)
 			goto out;
 
+		for (i = 0, migrated = false; i < nr_pages; i++) {
+			struct page *page = pvec.pages[i];
+
+			if (radix_tree_exceptional_entry(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				/* This can not happen ! */
+				VM_BUG_ON(!is_hmm_entry(swap));
+				page = hmm_pagecache_writeback(mapping, swap);
+				if (page == NULL) {
+					migrated = true;
+					pvec.pages[i] = NULL;
+				}
+			}
+		}
+
+		/* Some rmem was migrated we need to redo the page cache lookup. */
+		if (migrated) {
+			for (i = 0; i < nr_pages; i++) {
+				struct page *page = pvec.pages[i];
+
+				if (page && radix_tree_exceptional_entry(page)) {
+					swp_entry_t swap = radix_to_swp_entry(page);
+
+					page = hmm_pagecache_page(mapping, swap);
+					unlock_page(page);
+					page_cache_release(page);
+					pvec.pages[i] = page;
+				}
+			}
+			pagevec_release(&pvec);
+			cond_resched();
+			index = save_index;
+			continue;
+		}
+
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
+			struct page *hmm_page = NULL;
+
+			if (radix_tree_exceptional_entry(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				pvec.pages[i] = hmm_pagecache_page(mapping, swap);
+				hmm_page = page = pvec.pages[i];
+				page_cache_release(hmm_page);
+			}
 
 			/*
 			 * At this point, the page may be truncated or
@@ -2364,20 +2448,24 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			if (mpd->map.m_len > 0 && mpd->next_page != page->index)
 				goto out;
 
-			lock_page(page);
-			/*
-			 * If the page is no longer dirty, or its mapping no
-			 * longer corresponds to inode we are writing (which
-			 * means it has been truncated or invalidated), or the
-			 * page is already under writeback and we are not doing
-			 * a data integrity writeback, skip the page
-			 */
-			if (!PageDirty(page) ||
-			    (PageWriteback(page) &&
-			     (mpd->wbc->sync_mode == WB_SYNC_NONE)) ||
-			    unlikely(page->mapping != mapping)) {
-				unlock_page(page);
-				continue;
+			if (!hmm_page) {
+				lock_page(page);
+
+				/* If the page is no longer dirty, or its
+				 * mapping no longer corresponds to inode
+				 * we are writing (which means it has been
+				 * truncated or invalidated), or the page
+				 * is already under writeback and we are
+				 * not doing a data integrity writeback,
+				 * skip the page
+				 */
+				if (!PageDirty(page) ||
+				    (PageWriteback(page) &&
+				     (mpd->wbc->sync_mode == WB_SYNC_NONE)) ||
+				    unlikely(page->mapping != mapping)) {
+					unlock_page(page);
+					continue;
+				}
 			}
 
 			wait_on_page_writeback(page);
@@ -2396,11 +2484,37 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			err = 0;
 			left--;
 		}
+		/* Some entry of pvec might still be exceptional ! */
+		for (i = 0; i < nr_pages; i++) {
+			struct page *page = pvec.pages[i];
+
+			if (radix_tree_exceptional_entry(page)) {
+				swp_entry_t swap = radix_to_swp_entry(page);
+
+				page = hmm_pagecache_page(mapping, swap);
+				unlock_page(page);
+				page_cache_release(page);
+				pvec.pages[i] = page;
+			}
+		}
 		pagevec_release(&pvec);
 		cond_resched();
 	}
 	return 0;
 out:
+	/* Some entry of pvec might still be exceptional ! */
+	for (i = 0; i < nr_pages; i++) {
+		struct page *page = pvec.pages[i];
+
+		if (radix_tree_exceptional_entry(page)) {
+			swp_entry_t swap = radix_to_swp_entry(page);
+
+			page = hmm_pagecache_page(mapping, swap);
+			unlock_page(page);
+			page_cache_release(page);
+			pvec.pages[i] = page;
+		}
+	}
 	pagevec_release(&pvec);
 	return err;
 }
@@ -3281,6 +3395,7 @@ static const struct address_space_operations ext4_aops = {
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
 	.error_remove_page	= generic_error_remove_page,
+	.features		= AOPS_FEATURE_HMM,
 };
 
 static const struct address_space_operations ext4_journalled_aops = {
@@ -3297,6 +3412,7 @@ static const struct address_space_operations ext4_journalled_aops = {
 	.direct_IO		= ext4_direct_IO,
 	.is_partially_uptodate  = block_is_partially_uptodate,
 	.error_remove_page	= generic_error_remove_page,
+	.features		= AOPS_FEATURE_HMM,
 };
 
 static const struct address_space_operations ext4_da_aops = {
@@ -3313,6 +3429,7 @@ static const struct address_space_operations ext4_da_aops = {
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
 	.error_remove_page	= generic_error_remove_page,
+	.features		= AOPS_FEATURE_HMM,
 };
 
 void ext4_set_aops(struct inode *inode)
@@ -3355,11 +3472,20 @@ static int ext4_block_zero_page_range(handle_t *handle,
 	struct page *page;
 	int err = 0;
 
+retry:
 	page = find_or_create_page(mapping, from >> PAGE_CACHE_SHIFT,
 				   mapping_gfp_mask(mapping) & ~__GFP_FS);
 	if (!page)
 		return -ENOMEM;
 
+	if (radix_tree_exception(page)) {
+		swp_entry_t swap = radix_to_swp_entry(page);
+
+		/* FIXME How to handle hmm migration failure ? */
+		hmm_pagecache_migrate(mapping, swap);
+		goto retry;
+	}
+
 	blocksize = inode->i_sb->s_blocksize;
 	max = blocksize - (offset & (blocksize - 1));
 
@@ -4529,6 +4655,13 @@ static void ext4_wait_for_tail_page_commit(struct inode *inode)
 				      inode->i_size >> PAGE_CACHE_SHIFT);
 		if (!page)
 			return;
+		if (radix_tree_exception(page)) {
+			swp_entry_t swap = radix_to_swp_entry(page);
+
+			/* FIXME How to handle hmm migration failure ? */
+			hmm_pagecache_migrate(inode->i_mapping, swap);
+			continue;
+		}
 		ret = __ext4_journalled_invalidatepage(page, offset,
 						PAGE_CACHE_SIZE - offset);
 		unlock_page(page);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
