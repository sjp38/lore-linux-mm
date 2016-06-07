Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3500C6B026A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 08:12:44 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id j12so75505541lbo.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 05:12:44 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id kn10si1692198wjb.106.2016.06.07.05.12.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 05:12:42 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r5so5505933wmr.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 05:12:42 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm, memcg: use consistent gfp flags during readahead
Date: Tue,  7 Jun 2016 14:12:36 +0200
Message-Id: <1465301556-26431-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Vladimir has noticed that we might declare memcg oom even during
readahead because read_pages only uses GFP_KERNEL (with mapping_gfp
restriction) while __do_page_cache_readahead uses
page_cache_alloc_readahead which adds __GFP_NORETRY to prevent from
OOMs. This gfp mask discrepancy is really unfortunate and easily
fixable. Drop page_cache_alloc_readahead() which only has one user
and outsource the gfp_mask logic into readahead_gfp_mask and propagate
this mask from __do_page_cache_readahead down to read_pages.

This alone would have only very limited impact as most filesystems
are implementing ->readpages and the common implementation
mpage_readpages does GFP_KERNEL (with mapping_gfp restriction) again.
We can tell it to use readahead_gfp_mask instead as this function is
called only during readahead as well. The same applies to
read_cache_pages.

ext4 has its own ext4_mpage_readpages but the path which has pages !=
NULL can use the same gfp mask.
Btrfs, cifs, f2fs and orangefs are doing a very similar pattern to
mpage_readpages so the same can be applied to them as well.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
an alternative solution for ->readpages part would be add the gfp mask
as a new argument. This would be a larger change and I am not even sure
it would be so much better. An explicit usage of the readahead gfp mask
sounds like easier to track. If there is a general agreement this is a
proper way to go I can rework the patch to do so, of course.

Does this make sense?

 fs/btrfs/extent_io.c    |  3 ++-
 fs/cifs/file.c          |  2 +-
 fs/ext4/readpage.c      |  2 +-
 fs/f2fs/data.c          |  3 ++-
 fs/mpage.c              |  2 +-
 fs/orangefs/inode.c     |  2 +-
 include/linux/pagemap.h |  6 +++---
 mm/readahead.c          | 12 ++++++------
 8 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index d247fc0eea19..883031d9f35b 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -4160,7 +4160,8 @@ int extent_readpages(struct extent_io_tree *tree,
 		prefetchw(&page->flags);
 		list_del(&page->lru);
 		if (add_to_page_cache_lru(page, mapping,
-					page->index, GFP_NOFS)) {
+					page->index,
+					readahead_gfp_mask(mapping))) {
 			put_page(page);
 			continue;
 		}
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index c03d0744648b..60e0167b0c1d 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3380,7 +3380,7 @@ readpages_get_pages(struct address_space *mapping, struct list_head *page_list,
 	struct page *page, *tpage;
 	unsigned int expected_index;
 	int rc;
-	gfp_t gfp = mapping_gfp_constraint(mapping, GFP_KERNEL);
+	gfp_t gfp = readahead_gfp_mask(mapping);
 
 	INIT_LIST_HEAD(tmplist);
 
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index dc54a4b60eba..c75b66a64982 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -166,7 +166,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 			page = list_entry(pages->prev, struct page, lru);
 			list_del(&page->lru);
 			if (add_to_page_cache_lru(page, mapping, page->index,
-				  mapping_gfp_constraint(mapping, GFP_KERNEL)))
+				  readahead_gfp_mask(mapping)))
 				goto next_page;
 		}
 
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 5dafb9cef12e..3f914339e4f4 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -928,7 +928,8 @@ static int f2fs_mpage_readpages(struct address_space *mapping,
 			page = list_entry(pages->prev, struct page, lru);
 			list_del(&page->lru);
 			if (add_to_page_cache_lru(page, mapping,
-						  page->index, GFP_KERNEL))
+						  page->index,
+						  readahead_gfp_mask(mapping)))
 				goto next_page;
 		}
 
diff --git a/fs/mpage.c b/fs/mpage.c
index eedc644b78d7..9c11255b0797 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -362,7 +362,7 @@ mpage_readpages(struct address_space *mapping, struct list_head *pages,
 	sector_t last_block_in_bio = 0;
 	struct buffer_head map_bh;
 	unsigned long first_logical_block = 0;
-	gfp_t gfp = mapping_gfp_constraint(mapping, GFP_KERNEL);
+	gfp_t gfp = readahead_gfp_mask(mapping);
 
 	map_bh.b_state = 0;
 	map_bh.b_size = 0;
diff --git a/fs/orangefs/inode.c b/fs/orangefs/inode.c
index 85640e955cde..06a8da75651d 100644
--- a/fs/orangefs/inode.c
+++ b/fs/orangefs/inode.c
@@ -80,7 +80,7 @@ static int orangefs_readpages(struct file *file,
 		if (!add_to_page_cache(page,
 				       mapping,
 				       page->index,
-				       GFP_KERNEL)) {
+				       readahead_gfp_mask(mapping))) {
 			ret = read_one_page(page);
 			gossip_debug(GOSSIP_INODE_DEBUG,
 				"failure adding page to cache, read_one_page returned: %d\n",
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 97354102794d..81363b834900 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -209,10 +209,10 @@ static inline struct page *page_cache_alloc_cold(struct address_space *x)
 	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
 }
 
-static inline struct page *page_cache_alloc_readahead(struct address_space *x)
+static inline gfp_t readahead_gfp_mask(struct address_space *x)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x) |
-				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN);
+	return mapping_gfp_mask(x) |
+				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN;
 }
 
 typedef int filler_t(void *, struct page *);
diff --git a/mm/readahead.c b/mm/readahead.c
index 40be3ae0afe3..7cd032ef17bf 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -89,7 +89,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 		page = lru_to_page(pages);
 		list_del(&page->lru);
 		if (add_to_page_cache_lru(page, mapping, page->index,
-				mapping_gfp_constraint(mapping, GFP_KERNEL))) {
+				readahead_gfp_mask(mapping))) {
 			read_cache_pages_invalidate_page(mapping, page);
 			continue;
 		}
@@ -108,7 +108,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 EXPORT_SYMBOL(read_cache_pages);
 
 static int read_pages(struct address_space *mapping, struct file *filp,
-		struct list_head *pages, unsigned nr_pages)
+		struct list_head *pages, unsigned nr_pages, gfp_t gfp_mask)
 {
 	struct blk_plug plug;
 	unsigned page_idx;
@@ -126,8 +126,7 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 	for (page_idx = 0; page_idx < nr_pages; page_idx++) {
 		struct page *page = lru_to_page(pages);
 		list_del(&page->lru);
-		if (!add_to_page_cache_lru(page, mapping, page->index,
-				mapping_gfp_constraint(mapping, GFP_KERNEL))) {
+		if (!add_to_page_cache_lru(page, mapping, page->index, gfp_mask)) {
 			mapping->a_ops->readpage(filp, page);
 		}
 		put_page(page);
@@ -159,6 +158,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	int page_idx;
 	int ret = 0;
 	loff_t isize = i_size_read(inode);
+	gfp_t gfp_mask = readahead_gfp_mask(mapping);
 
 	if (isize == 0)
 		goto out;
@@ -180,7 +180,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		if (page && !radix_tree_exceptional_entry(page))
 			continue;
 
-		page = page_cache_alloc_readahead(mapping);
+		page = __page_cache_alloc(gfp_mask);
 		if (!page)
 			break;
 		page->index = page_offset;
@@ -196,7 +196,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	 * will then handle the error.
 	 */
 	if (ret)
-		read_pages(mapping, filp, &page_pool, ret);
+		read_pages(mapping, filp, &page_pool, ret, gfp_mask);
 	BUG_ON(!list_empty(&page_pool));
 out:
 	return ret;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
