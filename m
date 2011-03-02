Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5F7718D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 03:38:34 -0500 (EST)
Received: by mail-gy0-f169.google.com with SMTP id 13so2949935gyb.14
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 00:38:33 -0800 (PST)
From: Liu Yuan <namei.unix@gmail.com>
Subject: [RFC PATCH 4/5] mm: Add hit/miss accounting for Page Cache
Date: Wed,  2 Mar 2011 16:38:09 +0800
Message-Id: <1299055090-23976-4-git-send-email-namei.unix@gmail.com>
In-Reply-To: <no>
References: <no>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com

From: Liu Yuan <tailai.ly@taobao.com>

Hit/Miss accountings are request-centric: that is, single request
would either cause one hit or one miss to be accounted for the very
first time that kernel query the page cache. In some rare error
conditions, kernel would re-query the page cache, but we donnot
account for it and ignore it for simplicity.

Signed-off-by: Liu Yuan <tailai.ly@taobao.com>
---
 mm/filemap.c |   26 ++++++++++++++++++++++----
 1 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 83a45d3..5388b2a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1009,10 +1009,15 @@ static void do_generic_file_read(struct file *filp, loff_t *ppos,
 		pgoff_t end_index;
 		loff_t isize;
 		unsigned long nr, ret;
+		int retry_find = 0;
 
 		cond_resched();
 find_page:
 		page = find_get_page(mapping, index);
+		if (likely(!retry_find) && page && PageUptodate(page))
+			page_cache_acct_hit(inode->i_sb, READ);
+		else
+			page_cache_acct_missed(inode->i_sb, READ);
 		if (!page) {
 			page_cache_sync_readahead(mapping,
 					ra, filp,
@@ -1137,6 +1142,7 @@ readpage:
 		if (unlikely(error)) {
 			if (error == AOP_TRUNCATED_PAGE) {
 				page_cache_release(page);
+				retry_find = 1;
 				goto find_page;
 			}
 			goto readpage_error;
@@ -1153,6 +1159,7 @@ readpage:
 					 */
 					unlock_page(page);
 					page_cache_release(page);
+					retry_find = 1;
 					goto find_page;
 				}
 				unlock_page(page);
@@ -1185,8 +1192,10 @@ no_cached_page:
 						index, GFP_KERNEL);
 		if (error) {
 			page_cache_release(page);
-			if (error == -EEXIST)
+			if (error == -EEXIST) {
+				retry_find = 1;
 				goto find_page;
+			}
 			desc->error = error;
 			goto out;
 		}
@@ -1543,6 +1552,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct page *page;
 	pgoff_t size;
 	int ret = 0;
+	int rw = !!(vmf->flags & FAULT_FLAG_WRITE);
 
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	if (offset >= size)
@@ -1552,6 +1562,10 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	 * Do we have something in the page cache already?
 	 */
 	page = find_get_page(mapping, offset);
+	if (page && page->mapping && PageUptodate(page))
+		page_cache_acct_hit(inode->i_sb, rw);
+	else
+		page_cache_acct_missed(inode->i_sb, rw);
 	if (likely(page)) {
 		/*
 		 * We found the page, so try async readahead before
@@ -2227,20 +2241,24 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 		gfp_notmask = __GFP_FS;
 repeat:
 	page = find_lock_page(mapping, index);
-	if (page)
+	if (page) {
+		page_cache_acct_hit(mapping->host->i_sb, WRITE);
 		return page;
+	}
 
 	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~gfp_notmask);
 	if (!page)
-		return NULL;
+		goto out;
 	status = add_to_page_cache_lru(page, mapping, index,
 						GFP_KERNEL & ~gfp_notmask);
 	if (unlikely(status)) {
 		page_cache_release(page);
 		if (status == -EEXIST)
 			goto repeat;
-		return NULL;
+		page = NULL;
 	}
+out:
+	page_cache_acct_missed(mapping->host->i_sb, WRITE);
 	return page;
 }
 EXPORT_SYMBOL(grab_cache_page_write_begin);
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
