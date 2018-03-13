Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3261F6B0276
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:27:11 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v2so8093932pgv.23
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:27:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u186si121534pgc.462.2018.03.13.06.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Mar 2018 06:27:09 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v9 58/61] lustre: Convert to XArray
Date: Tue, 13 Mar 2018 06:26:36 -0700
Message-Id: <20180313132639.17387-59-willy@infradead.org>
In-Reply-To: <20180313132639.17387-1-willy@infradead.org>
References: <20180313132639.17387-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/staging/lustre/lustre/llite/glimpse.c   | 12 +++++-------
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 16 ++++++++--------
 2 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index 3075358f3f08..014035be5ac7 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -57,7 +57,7 @@ static const struct cl_lock_descr whole_file = {
 };
 
 /*
- * Check whether file has possible unwriten pages.
+ * Check whether file has possible unwritten pages.
  *
  * \retval 1    file is mmap-ed or has dirty pages
  *	 0    otherwise
@@ -66,16 +66,14 @@ blkcnt_t dirty_cnt(struct inode *inode)
 {
 	blkcnt_t cnt = 0;
 	struct vvp_object *vob = cl_inode2vvp(inode);
-	void	      *results[1];
 
-	if (inode->i_mapping)
-		cnt += radix_tree_gang_lookup_tag(&inode->i_mapping->i_pages,
-						  results, 0, 1,
-						  PAGECACHE_TAG_DIRTY);
+	if (inode->i_mapping && xa_tagged(&inode->i_mapping->i_pages,
+				PAGECACHE_TAG_DIRTY))
+		cnt = 1;
 	if (cnt == 0 && atomic_read(&vob->vob_mmap_cnt) > 0)
 		cnt = 1;
 
-	return (cnt > 0) ? 1 : 0;
+	return cnt;
 }
 
 int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 6950cb21638e..dbda8a9e351d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -931,17 +931,18 @@ static struct page *mdc_page_locate(struct address_space *mapping, __u64 *hash,
 	 * hash _smaller_ than one we are looking for.
 	 */
 	unsigned long offset = hash_x_index(*hash, hash64);
+	XA_STATE(xas, &mapping->i_pages, offset);
 	struct page *page;
-	int found;
 
-	xa_lock_irq(&mapping->i_pages);
-	found = radix_tree_gang_lookup(&mapping->i_pages,
-				       (void **)&page, offset, 1);
-	if (found > 0 && !xa_is_value(page)) {
+	xas_lock_irq(&xas);
+	page = xas_find(&xas, ULONG_MAX);
+	if (xa_is_value(page))
+		page = NULL;
+	if (page) {
 		struct lu_dirpage *dp;
 
 		get_page(page);
-		xa_unlock_irq(&mapping->i_pages);
+		xas_unlock_irq(&xas);
 		/*
 		 * In contrast to find_lock_page() we are sure that directory
 		 * page cannot be truncated (while DLM lock is held) and,
@@ -989,8 +990,7 @@ static struct page *mdc_page_locate(struct address_space *mapping, __u64 *hash,
 			page = ERR_PTR(-EIO);
 		}
 	} else {
-		xa_unlock_irq(&mapping->i_pages);
-		page = NULL;
+		xas_unlock_irq(&xas);
 	}
 	return page;
 }
-- 
2.16.1
