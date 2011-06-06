Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 475586B012C
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 00:35:52 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p564Znt0007673
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:35:50 -0700
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by hpaq14.eem.corp.google.com with ESMTP id p564ZKQd014826
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:35:48 -0700
Received: by pxi2 with SMTP id 2so2766060pxi.24
        for <linux-mm@kvack.org>; Sun, 05 Jun 2011 21:35:47 -0700 (PDT)
Date: Sun, 5 Jun 2011 21:35:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 9/14] mm: cleanup descriptions of filler arg
In-Reply-To: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106052134300.17116@sister.anvils>
References: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

The often-NULL data arg to read_cache_page() and read_mapping_page()
functions is misdescribed as "destination for read data": no, it's the
first arg to the filler function, often struct file * to ->readpage().

Satisfy checkpatch.pl on those filler prototypes, and tidy up the
declarations in linux/pagemap.h.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/pagemap.h |   12 +++++-------
 mm/filemap.c            |   12 ++++++------
 2 files changed, 11 insertions(+), 13 deletions(-)

--- linux.orig/mm/filemap.c	2011-05-29 18:42:37.421882556 -0700
+++ linux/mm/filemap.c	2011-06-05 18:50:34.473713659 -0700
@@ -1795,7 +1795,7 @@ EXPORT_SYMBOL(generic_file_readonly_mmap
 
 static struct page *__read_cache_page(struct address_space *mapping,
 				pgoff_t index,
-				int (*filler)(void *,struct page*),
+				int (*filler)(void *, struct page *),
 				void *data,
 				gfp_t gfp)
 {
@@ -1826,7 +1826,7 @@ repeat:
 
 static struct page *do_read_cache_page(struct address_space *mapping,
 				pgoff_t index,
-				int (*filler)(void *,struct page*),
+				int (*filler)(void *, struct page *),
 				void *data,
 				gfp_t gfp)
 
@@ -1866,7 +1866,7 @@ out:
  * @mapping:	the page's address_space
  * @index:	the page index
  * @filler:	function to perform the read
- * @data:	destination for read data
+ * @data:	first arg to filler(data, page) function, often left as NULL
  *
  * Same as read_cache_page, but don't wait for page to become unlocked
  * after submitting it to the filler.
@@ -1878,7 +1878,7 @@ out:
  */
 struct page *read_cache_page_async(struct address_space *mapping,
 				pgoff_t index,
-				int (*filler)(void *,struct page*),
+				int (*filler)(void *, struct page *),
 				void *data)
 {
 	return do_read_cache_page(mapping, index, filler, data, mapping_gfp_mask(mapping));
@@ -1926,7 +1926,7 @@ EXPORT_SYMBOL(read_cache_page_gfp);
  * @mapping:	the page's address_space
  * @index:	the page index
  * @filler:	function to perform the read
- * @data:	destination for read data
+ * @data:	first arg to filler(data, page) function, often left as NULL
  *
  * Read into the page cache. If a page already exists, and PageUptodate() is
  * not set, try to fill the page then wait for it to become unlocked.
@@ -1935,7 +1935,7 @@ EXPORT_SYMBOL(read_cache_page_gfp);
  */
 struct page *read_cache_page(struct address_space *mapping,
 				pgoff_t index,
-				int (*filler)(void *,struct page*),
+				int (*filler)(void *, struct page *),
 				void *data)
 {
 	return wait_on_page_read(read_cache_page_async(mapping, index, filler, data));
--- linux.orig/include/linux/pagemap.h	2011-06-05 17:56:03.000000000 -0700
+++ linux/include/linux/pagemap.h	2011-06-05 18:53:54.758707823 -0700
@@ -255,26 +255,24 @@ static inline struct page *grab_cache_pa
 extern struct page * grab_cache_page_nowait(struct address_space *mapping,
 				pgoff_t index);
 extern struct page * read_cache_page_async(struct address_space *mapping,
-				pgoff_t index, filler_t *filler,
-				void *data);
+				pgoff_t index, filler_t *filler, void *data);
 extern struct page * read_cache_page(struct address_space *mapping,
-				pgoff_t index, filler_t *filler,
-				void *data);
+				pgoff_t index, filler_t *filler, void *data);
 extern struct page * read_cache_page_gfp(struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 extern int read_cache_pages(struct address_space *mapping,
 		struct list_head *pages, filler_t *filler, void *data);
 
 static inline struct page *read_mapping_page_async(
-						struct address_space *mapping,
-						     pgoff_t index, void *data)
+				struct address_space *mapping,
+				pgoff_t index, void *data)
 {
 	filler_t *filler = (filler_t *)mapping->a_ops->readpage;
 	return read_cache_page_async(mapping, index, filler, data);
 }
 
 static inline struct page *read_mapping_page(struct address_space *mapping,
-					     pgoff_t index, void *data)
+				pgoff_t index, void *data)
 {
 	filler_t *filler = (filler_t *)mapping->a_ops->readpage;
 	return read_cache_page(mapping, index, filler, data);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
