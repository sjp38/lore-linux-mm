Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E5D996B0274
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 12:04:06 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p5so28343788pgn.7
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:04:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5si7830198plm.581.2017.09.27.09.03.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 09:03:58 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 01/15] mm: Implement find_get_pages_range_tag()
Date: Wed, 27 Sep 2017 18:03:20 +0200
Message-Id: <20170927160334.29513-2-jack@suse.cz>
In-Reply-To: <20170927160334.29513-1-jack@suse.cz>
References: <20170927160334.29513-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>

Implement a variant of find_get_pages_tag() that stops iterating at
given index. Lots of users of this function (through pagevec_lookup())
actually want a range lookup and all of them are currently open-coding
this.

Also create corresponding pagevec_lookup_range_tag() function.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/pagemap.h | 12 ++++++++++--
 include/linux/pagevec.h | 11 +++++++++--
 mm/filemap.c            | 33 ++++++++++++++++++++++++---------
 mm/swap.c               |  9 +++++----
 4 files changed, 48 insertions(+), 17 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 5bbd6780f205..75cd074a23b4 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -365,8 +365,16 @@ static inline unsigned find_get_pages(struct address_space *mapping,
 }
 unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
 			       unsigned int nr_pages, struct page **pages);
-unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
-			int tag, unsigned int nr_pages, struct page **pages);
+unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
+			pgoff_t end, int tag, unsigned int nr_pages,
+			struct page **pages);
+static inline unsigned find_get_pages_tag(struct address_space *mapping,
+			pgoff_t *index, int tag, unsigned int nr_pages,
+			struct page **pages)
+{
+	return find_get_pages_range_tag(mapping, index, (pgoff_t)-1, tag,
+					nr_pages, pages);
+}
 unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 			int tag, unsigned int nr_entries,
 			struct page **entries, pgoff_t *indices);
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 4dcd5506f1ed..371edacc10d5 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -37,9 +37,16 @@ static inline unsigned pagevec_lookup(struct pagevec *pvec,
 	return pagevec_lookup_range(pvec, mapping, start, (pgoff_t)-1);
 }
 
-unsigned pagevec_lookup_tag(struct pagevec *pvec,
+unsigned pagevec_lookup_range_tag(struct pagevec *pvec,
+		struct address_space *mapping, pgoff_t *index, pgoff_t end,
+		int tag, unsigned nr_pages);
+static inline unsigned pagevec_lookup_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, int tag,
-		unsigned nr_pages);
+		unsigned nr_pages)
+{
+	return pagevec_lookup_range_tag(pvec, mapping, index, (pgoff_t)-1, tag,
+					nr_pages);
+}
 
 static inline void pagevec_init(struct pagevec *pvec, int cold)
 {
diff --git a/mm/filemap.c b/mm/filemap.c
index 9d21afd692b9..fe20329c83cd 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1726,9 +1726,10 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 EXPORT_SYMBOL(find_get_pages_contig);
 
 /**
- * find_get_pages_tag - find and return pages that match @tag
+ * find_get_pages_range_tag - find and return pages in given range matching @tag
  * @mapping:	the address_space to search
  * @index:	the starting page index
+ * @end:	The final page index (inclusive)
  * @tag:	the tag index
  * @nr_pages:	the maximum number of pages
  * @pages:	where the resulting pages are placed
@@ -1736,8 +1737,9 @@ EXPORT_SYMBOL(find_get_pages_contig);
  * Like find_get_pages, except we only return pages which are tagged with
  * @tag.   We update @index to index the next page for the traversal.
  */
-unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
-			int tag, unsigned int nr_pages, struct page **pages)
+unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
+			pgoff_t end, int tag, unsigned int nr_pages,
+			struct page **pages)
 {
 	struct radix_tree_iter iter;
 	void **slot;
@@ -1750,6 +1752,9 @@ unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 	radix_tree_for_each_tagged(slot, &mapping->page_tree,
 				   &iter, *index, tag) {
 		struct page *head, *page;
+
+		if (iter.index > end)
+			break;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1791,18 +1796,28 @@ unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 		}
 
 		pages[ret] = page;
-		if (++ret == nr_pages)
-			break;
+		if (++ret == nr_pages) {
+			*index = pages[ret - 1]->index + 1;
+			goto out;
+		}
 	}
 
+	/*
+	 * We come here when we got at @end. We take care to not overflow the
+	 * index @index as it confuses some of the callers. This breaks the
+	 * iteration when there is page at index -1 but that is already broken
+	 * anyway.
+	 */
+	if (end == (pgoff_t)-1)
+		*index = (pgoff_t)-1;
+	else
+		*index = end + 1;
+out:
 	rcu_read_unlock();
 
-	if (ret)
-		*index = pages[ret - 1]->index + 1;
-
 	return ret;
 }
-EXPORT_SYMBOL(find_get_pages_tag);
+EXPORT_SYMBOL(find_get_pages_range_tag);
 
 /**
  * find_get_entries_tag - find and return entries that match @tag
diff --git a/mm/swap.c b/mm/swap.c
index 9295ae960d66..a00065f2a8f2 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -986,14 +986,15 @@ unsigned pagevec_lookup_range(struct pagevec *pvec,
 }
 EXPORT_SYMBOL(pagevec_lookup_range);
 
-unsigned pagevec_lookup_tag(struct pagevec *pvec, struct address_space *mapping,
-		pgoff_t *index, int tag, unsigned nr_pages)
+unsigned pagevec_lookup_range_tag(struct pagevec *pvec,
+		struct address_space *mapping, pgoff_t *index, pgoff_t end,
+		int tag, unsigned nr_pages)
 {
-	pvec->nr = find_get_pages_tag(mapping, index, tag,
+	pvec->nr = find_get_pages_range_tag(mapping, index, end, tag,
 					nr_pages, pvec->pages);
 	return pagevec_count(pvec);
 }
-EXPORT_SYMBOL(pagevec_lookup_tag);
+EXPORT_SYMBOL(pagevec_lookup_range_tag);
 
 /*
  * Perform any setup for the swap system
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
