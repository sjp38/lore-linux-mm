Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:07:52 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 11/13] mm: enable __do_page_cache_readahead() to include present pages
Message-ID: <7b76f5442bab13114bbb75c3143e1ccc5f17de98.1452549431.git.bcrl@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

For the upcoming AIO readahead operation it is necessary to know that
all the pages in a readahead request have had reads issued for them or
that the read was satisfied from cache.  Add a parameter to
__do_page_cache_readahead() to instruct it to count these pages in the
return value.

Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 mm/internal.h  |  4 ++--
 mm/readahead.c | 13 +++++++++----
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 38e24b8..7599068 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -43,7 +43,7 @@ static inline void set_page_count(struct page *page, int v)
 
 extern int __do_page_cache_readahead(struct address_space *mapping,
 		struct file *filp, pgoff_t offset, unsigned long nr_to_read,
-		unsigned long lookahead_size);
+		unsigned long lookahead_size, int report_present);
 
 /*
  * Submit IO for the read-ahead request in file_ra_state.
@@ -52,7 +52,7 @@ static inline unsigned long ra_submit(struct file_ra_state *ra,
 		struct address_space *mapping, struct file *filp)
 {
 	return __do_page_cache_readahead(mapping, filp,
-					ra->start, ra->size, ra->async_size);
+					ra->start, ra->size, ra->async_size, 0);
 }
 
 /*
diff --git a/mm/readahead.c b/mm/readahead.c
index ba22d7f..afd3abe 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -151,12 +151,13 @@ out:
  */
 int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			pgoff_t offset, unsigned long nr_to_read,
-			unsigned long lookahead_size)
+			unsigned long lookahead_size, int report_present)
 {
 	struct inode *inode = mapping->host;
 	struct page *page;
 	unsigned long end_index;	/* The last page we want to read */
 	LIST_HEAD(page_pool);
+	int present = 0;
 	int page_idx;
 	int ret = 0;
 	loff_t isize = i_size_read(inode);
@@ -178,8 +179,10 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->page_tree, page_offset);
 		rcu_read_unlock();
-		if (page && !radix_tree_exceptional_entry(page))
+		if (page && !radix_tree_exceptional_entry(page)) {
+			present++;
 			continue;
+		}
 
 		page = page_cache_alloc_readahead(mapping);
 		if (!page)
@@ -199,6 +202,8 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	if (ret)
 		read_pages(mapping, filp, &page_pool, ret);
 	BUG_ON(!list_empty(&page_pool));
+	if (report_present)
+		ret += present;
 out:
 	return ret;
 }
@@ -222,7 +227,7 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		if (this_chunk > nr_to_read)
 			this_chunk = nr_to_read;
 		err = __do_page_cache_readahead(mapping, filp,
-						offset, this_chunk, 0);
+						offset, this_chunk, 0, 0);
 		if (err < 0)
 			return err;
 
@@ -441,7 +446,7 @@ ondemand_readahead(struct address_space *mapping,
 	 * standalone, small random read
 	 * Read as is, and do not pollute the readahead state.
 	 */
-	return __do_page_cache_readahead(mapping, filp, offset, req_size, 0);
+	return __do_page_cache_readahead(mapping, filp, offset, req_size, 0, 0);
 
 initial_readahead:
 	ra->start = offset;
-- 
2.5.0


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
