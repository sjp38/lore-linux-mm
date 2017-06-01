Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 557C46B03BF
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:35:22 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d127so8646623wmf.15
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:35:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o18si22494607wmg.87.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:17 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 30/35] mm: Implement find_get_entries_range()
Date: Thu,  1 Jun 2017 11:32:40 +0200
Message-Id: <20170601093245.29238-31-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

Implement a variant of find_get_entries() that stops iterating at
given index. Some callers want this, so let's provide the interface.
Also it makes the interface consistent with find_get_pages().

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/pagemap.h | 13 ++++++++++---
 include/linux/pagevec.h | 12 ++++++++++--
 mm/filemap.c            | 32 ++++++++++++++++++++++++--------
 mm/swap.c               | 11 ++++++-----
 4 files changed, 50 insertions(+), 18 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 283d191c18be..df128a56f44b 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -333,9 +333,16 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
 
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
 struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset);
-unsigned find_get_entries(struct address_space *mapping, pgoff_t *start,
-			  unsigned int nr_entries, struct page **entries,
-			  pgoff_t *indices);
+unsigned find_get_entries_range(struct address_space *mapping, pgoff_t *start,
+			pgoff_t end, unsigned int nr_entries,
+			struct page **entries, pgoff_t *indices);
+static inline unsigned find_get_entries(struct address_space *mapping,
+			pgoff_t *start, unsigned int nr_entries,
+			struct page **entries, pgoff_t *indices)
+{
+	return find_get_entries_range(mapping, start, (pgoff_t)-1, nr_entries,
+				      entries, indices);
+}
 unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
 			pgoff_t end, unsigned int nr_pages,
 			struct page **pages);
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 3798c142338d..93308689d6a7 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -22,10 +22,18 @@ struct pagevec {
 
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec);
-unsigned pagevec_lookup_entries(struct pagevec *pvec,
+unsigned pagevec_lookup_entries_range(struct pagevec *pvec,
+				struct address_space *mapping,
+				pgoff_t *start, pgoff_t end,
+				unsigned nr_entries, pgoff_t *indices);
+static inline unsigned pagevec_lookup_entries(struct pagevec *pvec,
 				struct address_space *mapping,
 				pgoff_t *start, unsigned nr_entries,
-				pgoff_t *indices);
+				pgoff_t *indices)
+{
+	return pagevec_lookup_entries_range(pvec, mapping, start, (pgoff_t)-1,
+					    nr_entries, indices);
+}
 void pagevec_remove_exceptionals(struct pagevec *pvec);
 unsigned pagevec_lookup_range(struct pagevec *pvec,
 			      struct address_space *mapping,
diff --git a/mm/filemap.c b/mm/filemap.c
index de12b7355821..e55100459710 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1354,9 +1354,10 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 EXPORT_SYMBOL(pagecache_get_page);
 
 /**
- * find_get_entries - gang pagecache lookup
+ * find_get_entries_range - gang pagecache lookup
  * @mapping:	The address_space to search
  * @start:	The starting page cache index
+ * @end:	The final page cache index (inclusive)
  * @nr_entries:	The maximum number of entries
  * @entries:	Where the resulting entries are placed
  * @indices:	The cache indices corresponding to the entries in @entries
@@ -1376,9 +1377,9 @@ EXPORT_SYMBOL(pagecache_get_page);
  * find_get_entries() returns the number of pages and shadow entries which were
  * found. It also updates @start to index the next page for the traversal.
  */
-unsigned find_get_entries(struct address_space *mapping,
-			  pgoff_t *start, unsigned int nr_entries,
-			  struct page **entries, pgoff_t *indices)
+unsigned find_get_entries_range(struct address_space *mapping,
+			pgoff_t *start, pgoff_t end, unsigned int nr_entries,
+			struct page **entries, pgoff_t *indices)
 {
 	void **slot;
 	unsigned int ret = 0;
@@ -1390,6 +1391,9 @@ unsigned find_get_entries(struct address_space *mapping,
 	rcu_read_lock();
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, *start) {
 		struct page *head, *page;
+
+		if (iter.index > end)
+			break;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1425,13 +1429,25 @@ unsigned find_get_entries(struct address_space *mapping,
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
+
+	/*
+	 * We come here when there is no page beyond @end. We take care to not
+	 * overflow the index @start as it confuses some of the callers. This
+	 * breaks the iteration when there is page at index -1 but that is
+	 * already broken anyway.
+	 */
+	if (end == (pgoff_t)-1)
+		*start = (pgoff_t)-1;
+	else
+		*start = end + 1;
+out:
 	rcu_read_unlock();
 
-	if (ret)
-		*start = indices[ret - 1] + 1;
 	return ret;
 }
 
diff --git a/mm/swap.c b/mm/swap.c
index 6ba3dab6e905..88c7eb4e97db 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -889,10 +889,11 @@ void __pagevec_lru_add(struct pagevec *pvec)
 EXPORT_SYMBOL(__pagevec_lru_add);
 
 /**
- * pagevec_lookup_entries - gang pagecache lookup
+ * pagevec_lookup_entries_range - gang pagecache lookup
  * @pvec:	Where the resulting entries are placed
  * @mapping:	The address_space to search
  * @start:	The starting entry index
+ * @end:	The final entry index (inclusive)
  * @nr_entries:	The maximum number of entries
  * @indices:	The cache indices corresponding to the entries in @pvec
  *
@@ -908,13 +909,13 @@ EXPORT_SYMBOL(__pagevec_lru_add);
  * pagevec_lookup_entries() returns the number of entries which were
  * found. It also updates @start to index the next page for the traversal.
  */
-unsigned pagevec_lookup_entries(struct pagevec *pvec,
+unsigned pagevec_lookup_entries_range(struct pagevec *pvec,
 				struct address_space *mapping,
-				pgoff_t *start, unsigned nr_pages,
+				pgoff_t *start, pgoff_t end, unsigned nr_pages,
 				pgoff_t *indices)
 {
-	pvec->nr = find_get_entries(mapping, start, nr_pages,
-				    pvec->pages, indices);
+	pvec->nr = find_get_entries_range(mapping, start, end, nr_pages,
+					  pvec->pages, indices);
 	return pagevec_count(pvec);
 }
 
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
