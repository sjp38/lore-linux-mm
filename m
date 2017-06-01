Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6536B0314
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:34:37 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 10so8706517wml.4
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:34:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d9si8978923wra.169.2017.06.01.02.33.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 07/35] mm: Implement find_get_pages_range()
Date: Thu,  1 Jun 2017 11:32:17 +0200
Message-Id: <20170601093245.29238-8-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

Implement a variant of find_get_pages() that stops iterating at given
index. This may be substantial performance gain if the mapping is
sparse. See following commit for details. Furthermore lots of users of
this function (through pagevec_lookup()) actually want a range lookup
and all of them are currently open-coding this.

Also create corresponding pagevec_lookup_range() function.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/pagemap.h | 12 ++++++++++--
 include/linux/pagevec.h | 13 +++++++++++--
 mm/filemap.c            | 42 ++++++++++++++++++++++++++++++------------
 mm/swap.c               | 22 ++++++++++++++--------
 4 files changed, 65 insertions(+), 24 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 86de6f9c8607..2bb5e636a8c8 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -336,8 +336,16 @@ struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset);
 unsigned find_get_entries(struct address_space *mapping, pgoff_t start,
 			  unsigned int nr_entries, struct page **entries,
 			  pgoff_t *indices);
-unsigned find_get_pages(struct address_space *mapping, pgoff_t *start,
-			unsigned int nr_pages, struct page **pages);
+unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
+			pgoff_t end, unsigned int nr_pages,
+			struct page **pages);
+static inline unsigned find_get_pages(struct address_space *mapping,
+			pgoff_t *start, unsigned int nr_pages,
+			struct page **pages)
+{
+	return find_get_pages_range(mapping, start, (pgoff_t)-1, nr_pages,
+				    pages);
+}
 unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
 			       unsigned int nr_pages, struct page **pages);
 unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index c395a5bb58b2..7df056910437 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -27,8 +27,17 @@ unsigned pagevec_lookup_entries(struct pagevec *pvec,
 				pgoff_t start, unsigned nr_entries,
 				pgoff_t *indices);
 void pagevec_remove_exceptionals(struct pagevec *pvec);
-unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
-		pgoff_t *start, unsigned nr_pages);
+unsigned pagevec_lookup_range(struct pagevec *pvec,
+			      struct address_space *mapping,
+			      pgoff_t *start, pgoff_t end, unsigned nr_pages);
+static inline unsigned pagevec_lookup(struct pagevec *pvec,
+				      struct address_space *mapping,
+				      pgoff_t *start, unsigned nr_pages)
+{
+	return pagevec_lookup_range(pvec, mapping, start, (pgoff_t)-1,
+				    nr_pages);
+}
+
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, int tag,
 		unsigned nr_pages);
diff --git a/mm/filemap.c b/mm/filemap.c
index 10d926a423e2..2693f87a7968 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1438,24 +1438,29 @@ unsigned find_get_entries(struct address_space *mapping,
 }
 
 /**
- * find_get_pages - gang pagecache lookup
+ * find_get_pages_range - gang pagecache lookup
  * @mapping:	The address_space to search
  * @start:	The starting page index
+ * @end:	The final page index (inclusive)
  * @nr_pages:	The maximum number of pages
  * @pages:	Where the resulting pages are placed
  *
- * find_get_pages() will search for and return a group of up to
- * @nr_pages pages in the mapping.  The pages are placed at @pages.
- * find_get_pages() takes a reference against the returned pages.
+ * find_get_pages_range() will search for and return a group of up to @nr_pages
+ * pages in the mapping starting at index @start and up to index @end
+ * (inclusive).  The pages are placed at @pages.  find_get_pages_range() takes
+ * a reference against the returned pages.
  *
  * The search returns a group of mapping-contiguous pages with ascending
  * indexes.  There may be holes in the indices due to not-present pages.
  * We also update @start to index the next page for the traversal.
  *
- * find_get_pages() returns the number of pages which were found.
+ * find_get_pages_range() returns the number of pages which were found. If this
+ * number is smaller than @nr_pages, the end of specified range has been
+ * reached.
  */
-unsigned find_get_pages(struct address_space *mapping, pgoff_t *start,
-			    unsigned int nr_pages, struct page **pages)
+unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
+			      pgoff_t end, unsigned int nr_pages,
+			      struct page **pages)
 {
 	struct radix_tree_iter iter;
 	void **slot;
@@ -1467,6 +1472,9 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t *start,
 	rcu_read_lock();
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, *start) {
 		struct page *head, *page;
+
+		if (iter.index > end)
+			break;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1502,15 +1510,25 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t *start,
 		}
 
 		pages[ret] = page;
-		if (++ret == nr_pages)
-			break;
+		if (++ret == nr_pages) {
+			*start = pages[ret - 1]->index + 1;
+			goto out;
+		}
 	}
 
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
-		*start = pages[ret - 1]->index + 1;
-
 	return ret;
 }
 
diff --git a/mm/swap.c b/mm/swap.c
index 368d627cf279..804c9867af96 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -940,29 +940,35 @@ void pagevec_remove_exceptionals(struct pagevec *pvec)
 }
 
 /**
- * pagevec_lookup - gang pagecache lookup
+ * pagevec_lookup_range - gang pagecache lookup
  * @pvec:	Where the resulting pages are placed
  * @mapping:	The address_space to search
  * @start:	The starting page index
+ * @end:	The final page index
  * @nr_pages:	The maximum number of pages
  *
- * pagevec_lookup() will search for and return a group of up to @nr_pages pages
- * in the mapping.  The pages are placed in @pvec.  pagevec_lookup() takes a
+ * pagevec_lookup_range() will search for and return a group of up to @nr_pages
+ * pages in the mapping starting from index @start and upto index @end
+ * (inclusive).  The pages are placed in @pvec.  pagevec_lookup() takes a
  * reference against the pages in @pvec.
  *
  * The search returns a group of mapping-contiguous pages with ascending
  * indexes.  There may be holes in the indices due to not-present pages. We
  * also update @start to index the next page for the traversal.
  *
- * pagevec_lookup() returns the number of pages which were found.
+ * pagevec_lookup_range() returns the number of pages which were found. If this
+ * number is smaller than @nr_pages, the end of specified range has been
+ * reached.
  */
-unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
-		pgoff_t *start, unsigned nr_pages)
+unsigned pagevec_lookup_range(struct pagevec *pvec,
+		struct address_space *mapping, pgoff_t *start, pgoff_t end,
+		unsigned nr_pages)
 {
-	pvec->nr = find_get_pages(mapping, start, nr_pages, pvec->pages);
+	pvec->nr = find_get_pages_range(mapping, start, end, nr_pages,
+					pvec->pages);
 	return pagevec_count(pvec);
 }
-EXPORT_SYMBOL(pagevec_lookup);
+EXPORT_SYMBOL(pagevec_lookup_range);
 
 unsigned pagevec_lookup_tag(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t *index, int tag, unsigned nr_pages)
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
