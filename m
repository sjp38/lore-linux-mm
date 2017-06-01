Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DAC726B03B3
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:35:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k15so8719616wmh.3
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:35:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si21834313wrc.2.2017.06.01.02.33.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:15 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 06/35] mm: Make pagevec_lookup() update index
Date: Thu,  1 Jun 2017 11:32:16 +0200
Message-Id: <20170601093245.29238-7-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

Make pagevec_lookup() (and underlying find_get_pages()) update index to
the next page where iteration should continue. Most callers want this
and also pagevec_lookup_tag() already does this.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/buffer.c             |  6 ++----
 fs/ext4/file.c          |  4 +---
 fs/ext4/inode.c         |  8 ++------
 fs/fscache/page.c       |  5 ++---
 fs/hugetlbfs/inode.c    | 17 ++++++++---------
 fs/nilfs2/page.c        |  3 +--
 fs/ramfs/file-nommu.c   |  2 +-
 fs/xfs/xfs_file.c       |  3 +--
 include/linux/pagemap.h |  2 +-
 include/linux/pagevec.h |  2 +-
 mm/filemap.c            |  9 +++++++--
 mm/swap.c               |  5 +++--
 12 files changed, 30 insertions(+), 36 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 161be58c5cb0..fe0ee01c5a44 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1638,13 +1638,12 @@ void clean_bdev_aliases(struct block_device *bdev, sector_t block, sector_t len)
 
 	end = (block + len - 1) >> (PAGE_SHIFT - bd_inode->i_blkbits);
 	pagevec_init(&pvec, 0);
-	while (index <= end && pagevec_lookup(&pvec, bd_mapping, index,
+	while (index <= end && pagevec_lookup(&pvec, bd_mapping, &index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-			index = page->index;
-			if (index > end)
+			if (page->index > end)
 				break;
 			if (!page_has_buffers(page))
 				continue;
@@ -1675,7 +1674,6 @@ void clean_bdev_aliases(struct block_device *bdev, sector_t block, sector_t len)
 		}
 		pagevec_release(&pvec);
 		cond_resched();
-		index++;
 	}
 }
 EXPORT_SYMBOL(clean_bdev_aliases);
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 2b00bf84c05b..ddca17c7875a 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -482,7 +482,7 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 		unsigned long nr_pages;
 
 		num = min_t(pgoff_t, end - index, PAGEVEC_SIZE);
-		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, index,
+		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, &index,
 					  (pgoff_t)num);
 		if (nr_pages == 0)
 			break;
@@ -547,8 +547,6 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 		/* The no. of pages is less than our desired, we are done. */
 		if (nr_pages < num)
 			break;
-
-		index = pvec.pages[i - 1]->index + 1;
 		pagevec_release(&pvec);
 	} while (index <= end);
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 1bd0bfa547f6..784f41328dc8 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1670,7 +1670,7 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 
 	pagevec_init(&pvec, 0);
 	while (index <= end) {
-		nr_pages = pagevec_lookup(&pvec, mapping, index, PAGEVEC_SIZE);
+		nr_pages = pagevec_lookup(&pvec, mapping, &index, PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			break;
 		for (i = 0; i < nr_pages; i++) {
@@ -1687,7 +1687,6 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 			}
 			unlock_page(page);
 		}
-		index = pvec.pages[nr_pages - 1]->index + 1;
 		pagevec_release(&pvec);
 	}
 }
@@ -2284,7 +2283,7 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 
 	pagevec_init(&pvec, 0);
 	while (start <= end) {
-		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, start,
+		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, &start,
 					  PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			break;
@@ -2293,8 +2292,6 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 
 			if (page->index > end)
 				break;
-			/* Up to 'end' pages must be contiguous */
-			BUG_ON(page->index != start);
 			bh = head = page_buffers(page);
 			do {
 				if (lblk < mpd->map.m_lblk)
@@ -2339,7 +2336,6 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 				pagevec_release(&pvec);
 				return err;
 			}
-			start++;
 		}
 		pagevec_release(&pvec);
 	}
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index c8c4f79c7ce1..83018861dcd2 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -1178,11 +1178,10 @@ void __fscache_uncache_all_inode_pages(struct fscache_cookie *cookie,
 	pagevec_init(&pvec, 0);
 	next = 0;
 	do {
-		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE))
+		if (!pagevec_lookup(&pvec, mapping, &next, PAGEVEC_SIZE))
 			break;
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
-			next = page->index;
 			if (PageFsCache(page)) {
 				__fscache_wait_on_page_write(cookie, page);
 				__fscache_uncache_page(cookie, page);
@@ -1190,7 +1189,7 @@ void __fscache_uncache_all_inode_pages(struct fscache_cookie *cookie,
 		}
 		pagevec_release(&pvec);
 		cond_resched();
-	} while (++next);
+	} while (next);
 
 	_leave("");
 }
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index dde861387a40..372fc8aac38e 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -401,7 +401,7 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 	const pgoff_t end = lend >> huge_page_shift(h);
 	struct vm_area_struct pseudo_vma;
 	struct pagevec pvec;
-	pgoff_t next;
+	pgoff_t next, index;
 	int i, freed = 0;
 	long lookup_nr = PAGEVEC_SIZE;
 	bool truncate_op = (lend == LLONG_MAX);
@@ -420,7 +420,7 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 		/*
 		 * When no more pages are found, we are done.
 		 */
-		if (!pagevec_lookup(&pvec, mapping, next, lookup_nr))
+		if (!pagevec_lookup(&pvec, mapping, &next, lookup_nr))
 			break;
 
 		for (i = 0; i < pagevec_count(&pvec); ++i) {
@@ -432,13 +432,13 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			 * only possible in the punch hole case as end is
 			 * max page offset in the truncate case.
 			 */
-			next = page->index;
-			if (next >= end)
+			index = page->index;
+			if (index >= end)
 				break;
 
 			hash = hugetlb_fault_mutex_hash(h, current->mm,
 							&pseudo_vma,
-							mapping, next, 0);
+							mapping, index, 0);
 			mutex_lock(&hugetlb_fault_mutex_table[hash]);
 
 			/*
@@ -455,8 +455,8 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 
 				i_mmap_lock_write(mapping);
 				hugetlb_vmdelete_list(&mapping->i_mmap,
-					next * pages_per_huge_page(h),
-					(next + 1) * pages_per_huge_page(h));
+					index * pages_per_huge_page(h),
+					(index + 1) * pages_per_huge_page(h));
 				i_mmap_unlock_write(mapping);
 			}
 
@@ -475,14 +475,13 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			freed++;
 			if (!truncate_op) {
 				if (unlikely(hugetlb_unreserve_pages(inode,
-							next, next + 1, 1)))
+							index, index + 1, 1)))
 					hugetlb_fix_reserve_counts(inode);
 			}
 
 			unlock_page(page);
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
 		}
-		++next;
 		huge_pagevec_release(&pvec);
 		cond_resched();
 	}
diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
index f11a3ad2df0c..382a36c72d72 100644
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -312,10 +312,9 @@ void nilfs_copy_back_pages(struct address_space *dmap,
 
 	pagevec_init(&pvec, 0);
 repeat:
-	n = pagevec_lookup(&pvec, smap, index, PAGEVEC_SIZE);
+	n = pagevec_lookup(&pvec, smap, &index, PAGEVEC_SIZE);
 	if (!n)
 		return;
-	index = pvec.pages[n - 1]->index + 1;
 
 	for (i = 0; i < pagevec_count(&pvec); i++) {
 		struct page *page = pvec.pages[i], *dpage;
diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index 2ef7ce75c062..3ac1f2387083 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -228,7 +228,7 @@ static unsigned long ramfs_nommu_get_unmapped_area(struct file *file,
 	if (!pages)
 		goto out_free;
 
-	nr = find_get_pages(inode->i_mapping, pgoff, lpages, pages);
+	nr = find_get_pages(inode->i_mapping, &pgoff, lpages, pages);
 	if (nr != lpages)
 		goto out_free_pages; /* leave if some pages were missing */
 
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 5fb5a0958a14..487342078fc7 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1050,7 +1050,7 @@ xfs_find_get_desired_pgoff(
 		unsigned int	i;
 
 		want = min_t(pgoff_t, end - index, PAGEVEC_SIZE - 1) + 1;
-		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, index,
+		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, &index,
 					  want);
 		if (nr_pages == 0)
 			break;
@@ -1124,7 +1124,6 @@ xfs_find_get_desired_pgoff(
 		if (nr_pages < want)
 			break;
 
-		index = pvec.pages[i - 1]->index + 1;
 		pagevec_release(&pvec);
 	} while (index <= end);
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 316a19f6b635..86de6f9c8607 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -336,7 +336,7 @@ struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset);
 unsigned find_get_entries(struct address_space *mapping, pgoff_t start,
 			  unsigned int nr_entries, struct page **entries,
 			  pgoff_t *indices);
-unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
+unsigned find_get_pages(struct address_space *mapping, pgoff_t *start,
 			unsigned int nr_pages, struct page **pages);
 unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
 			       unsigned int nr_pages, struct page **pages);
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index b45d391b4540..c395a5bb58b2 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -28,7 +28,7 @@ unsigned pagevec_lookup_entries(struct pagevec *pvec,
 				pgoff_t *indices);
 void pagevec_remove_exceptionals(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
-		pgoff_t start, unsigned nr_pages);
+		pgoff_t *start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, int tag,
 		unsigned nr_pages);
diff --git a/mm/filemap.c b/mm/filemap.c
index 6f1be573a5e6..10d926a423e2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1450,10 +1450,11 @@ unsigned find_get_entries(struct address_space *mapping,
  *
  * The search returns a group of mapping-contiguous pages with ascending
  * indexes.  There may be holes in the indices due to not-present pages.
+ * We also update @start to index the next page for the traversal.
  *
  * find_get_pages() returns the number of pages which were found.
  */
-unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
+unsigned find_get_pages(struct address_space *mapping, pgoff_t *start,
 			    unsigned int nr_pages, struct page **pages)
 {
 	struct radix_tree_iter iter;
@@ -1464,7 +1465,7 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 		return 0;
 
 	rcu_read_lock();
-	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, *start) {
 		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
@@ -1506,6 +1507,10 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 	}
 
 	rcu_read_unlock();
+
+	if (ret)
+		*start = pages[ret - 1]->index + 1;
+
 	return ret;
 }
 
diff --git a/mm/swap.c b/mm/swap.c
index 98d08b4579fa..368d627cf279 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -951,12 +951,13 @@ void pagevec_remove_exceptionals(struct pagevec *pvec)
  * reference against the pages in @pvec.
  *
  * The search returns a group of mapping-contiguous pages with ascending
- * indexes.  There may be holes in the indices due to not-present pages.
+ * indexes.  There may be holes in the indices due to not-present pages. We
+ * also update @start to index the next page for the traversal.
  *
  * pagevec_lookup() returns the number of pages which were found.
  */
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
-		pgoff_t start, unsigned nr_pages)
+		pgoff_t *start, unsigned nr_pages)
 {
 	pvec->nr = find_get_pages(mapping, start, nr_pages, pvec->pages);
 	return pagevec_count(pvec);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
