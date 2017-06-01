Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF0A6B0311
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:33:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b86so8692483wmi.6
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:33:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u29si19974412wru.142.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:17 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 35/35] mm: Implement find_get_entries_range_tag()
Date: Thu,  1 Jun 2017 11:32:45 +0200
Message-Id: <20170601093245.29238-36-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

Implement find_get_entries_range_tag() (actually convert
find_get_entries_tag() tag to it as the only user of
find_get_entries_tag() needs a ranged lookup) and use it in DAX which is
the only user of this interface. This is mostly for consistency with
other page/entry iteration interfaces.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c                | 12 +++---------
 include/linux/pagemap.h |  3 ++-
 mm/filemap.c            | 36 ++++++++++++++++++++++++++----------
 3 files changed, 31 insertions(+), 20 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 4b295c544fd4..acf17b55f76b 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -819,7 +819,6 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 	pgoff_t indices[PAGEVEC_SIZE];
 	struct dax_device *dax_dev;
 	struct pagevec pvec;
-	bool done = false;
 	int i, ret = 0;
 
 	if (WARN_ON_ONCE(inode->i_blkbits != PAGE_SHIFT))
@@ -840,20 +839,15 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 	tag_pages_for_writeback(mapping, start_index, end_index);
 
 	pagevec_init(&pvec, 0);
-	while (!done) {
-		pvec.nr = find_get_entries_tag(mapping, &start_index,
-				PAGECACHE_TAG_TOWRITE, PAGEVEC_SIZE,
+	while (start_index <= end_index) {
+		pvec.nr = find_get_entries_range_tag(mapping, &start_index,
+				end_index, PAGECACHE_TAG_TOWRITE, PAGEVEC_SIZE,
 				pvec.pages, indices);
 
 		if (pvec.nr == 0)
 			break;
 
 		for (i = 0; i < pvec.nr; i++) {
-			if (indices[i] > end_index) {
-				done = true;
-				break;
-			}
-
 			ret = dax_writeback_one(bdev, dax_dev, mapping,
 					indices[i], pvec.pages[i]);
 			if (ret < 0)
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 1dc7e54ec32a..38227e670a83 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -365,7 +365,8 @@ static inline unsigned find_get_pages_tag(struct address_space *mapping,
 	return find_get_pages_range_tag(mapping, index, (pgoff_t)-1, tag,
 					nr_pages, pages);
 }
-unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t *start,
+unsigned find_get_entries_range_tag(struct address_space *mapping,
+			pgoff_t *start, pgoff_t end,
 			int tag, unsigned int nr_entries,
 			struct page **entries, pgoff_t *indices);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 3eb05c91c07a..06f82ed9096e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1720,9 +1720,10 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
 EXPORT_SYMBOL(find_get_pages_range_tag);
 
 /**
- * find_get_entries_tag - find and return entries that match @tag
+ * find_get_entries_range_tag - find and return entries that match @tag
  * @mapping:	the address_space to search
  * @start:	the starting page cache index
+ * @end:	the final page cache index (inclusive)
  * @tag:	the tag index
  * @nr_entries:	the maximum number of entries
  * @entries:	where the resulting entries are placed
@@ -1731,9 +1732,10 @@ EXPORT_SYMBOL(find_get_pages_range_tag);
  * Like find_get_entries, except we only return entries which are tagged with
  * @tag.
  */
-unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t *start,
-			int tag, unsigned int nr_entries,
-			struct page **entries, pgoff_t *indices)
+unsigned find_get_entries_range_tag(struct address_space *mapping,
+			pgoff_t *start, pgoff_t end, int tag,
+			unsigned int nr_entries, struct page **entries,
+			pgoff_t *indices)
 {
 	void **slot;
 	unsigned int ret = 0;
@@ -1746,6 +1748,9 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t *start,
 	radix_tree_for_each_tagged(slot, &mapping->page_tree,
 				   &iter, *start, tag) {
 		struct page *head, *page;
+
+		if (iter.index > end)
+			break;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1782,17 +1787,28 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t *start,
 export:
 		indices[ret] = iter.index;
 		entries[ret] = page;
-		if (++ret == nr_entries)
-			break;
+		if (++ret == nr_entries) {
+			*start = indices[ret - 1] + 1;
+			goto out;
+		}
 	}
-	rcu_read_unlock();
 
-	if (ret)
-		*start = indices[ret - 1] + 1;
+	/*
+	 * We come here when we got at @end. We take care to not overflow the
+	 * index @index as it confuses some of the callers. This breaks the
+	 * iteration when there is page at index -1 but that is already broken
+	 * anyway.
+	 */
+	if (end == (pgoff_t)-1)
+		*start = (pgoff_t)-1;
+	else
+		*start = end + 1;
+out:
+	rcu_read_unlock();
 
 	return ret;
 }
-EXPORT_SYMBOL(find_get_entries_tag);
+EXPORT_SYMBOL(find_get_entries_range_tag);
 
 /*
  * CD/DVDs are error prone. When a medium error occurs, the driver may fail
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
