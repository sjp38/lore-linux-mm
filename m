Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id BDD0F6B0031
	for <linux-mm@kvack.org>; Sat, 29 Mar 2014 15:09:13 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id z2so53584wiv.0
        for <linux-mm@kvack.org>; Sat, 29 Mar 2014 12:09:13 -0700 (PDT)
Received: from mailrelay008.isp.belgacom.be (mailrelay008.isp.belgacom.be. [195.238.6.174])
        by mx.google.com with ESMTP id pg11si4602685wic.16.2014.03.29.12.09.11
        for <linux-mm@kvack.org>;
        Sat, 29 Mar 2014 12:09:12 -0700 (PDT)
Date: Sat, 29 Mar 2014 20:09:10 +0100
From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH v2] mm/readahead.c: inline ra_submit
Message-Id: <20140329200910.35212c0b8890199b578ba175@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
Cc: akpm <akpm@linux-foundation.org>, linux-mm@kvack.org

f9acc8c7b35a ("readahead: sanify file_ra_state names")
left ra_submit with a single function call.

Move ra_submit to internal.h and inline it to save some stack.
Thanks to Andrew Morton for commenting different versions.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 include/linux/mm.h |  3 ---
 mm/internal.h      | 15 +++++++++++++++
 mm/readahead.c     | 21 +++------------------
 3 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c1b7414..c8ecf29 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1847,9 +1847,6 @@ void page_cache_async_readahead(struct address_space *mapping,
 				unsigned long size);
 
 unsigned long max_sane_readahead(unsigned long nr);
-unsigned long ra_submit(struct file_ra_state *ra,
-			struct address_space *mapping,
-			struct file *filp);
 
 /* Generic expand stack which grows the stack according to GROWS{UP,DOWN} */
 extern int expand_stack(struct vm_area_struct *vma, unsigned long address);
diff --git a/mm/internal.h b/mm/internal.h
index 29e1e76..51f309c 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -11,6 +11,7 @@
 #ifndef __MM_INTERNAL_H
 #define __MM_INTERNAL_H
 
+#include <linux/fs.h>
 #include <linux/mm.h>
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
@@ -21,6 +22,20 @@ static inline void set_page_count(struct page *page, int v)
 	atomic_set(&page->_count, v);
 }
 
+extern int __do_page_cache_readahead(struct address_space *mapping,
+		struct file *filp, pgoff_t offset, unsigned long nr_to_read,
+		unsigned long lookahead_size);
+
+/*
+ * Submit IO for the read-ahead request in file_ra_state.
+ */
+static inline unsigned long ra_submit(struct file_ra_state *ra,
+		struct address_space *mapping, struct file *filp)
+{
+	return __do_page_cache_readahead(mapping, filp,
+					ra->start, ra->size, ra->async_size);
+}
+
 /*
  * Turn a non-refcounted page (->_count == 0) into refcounted with
  * a count of one.
diff --git a/mm/readahead.c b/mm/readahead.c
index 0de2360..4d9f4c2 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -8,9 +8,7 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/fs.h>
 #include <linux/gfp.h>
-#include <linux/mm.h>
 #include <linux/export.h>
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
@@ -20,6 +18,8 @@
 #include <linux/syscalls.h>
 #include <linux/file.h>
 
+#include "internal.h"
+
 /*
  * Initialise a struct file's readahead state.  Assumes that the caller has
  * memset *ra to zero.
@@ -149,8 +149,7 @@ out:
  *
  * Returns the number of pages requested, or the maximum amount of I/O allowed.
  */
-static int
-__do_page_cache_readahead(struct address_space *mapping, struct file *filp,
+int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			pgoff_t offset, unsigned long nr_to_read,
 			unsigned long lookahead_size)
 {
@@ -244,20 +243,6 @@ unsigned long max_sane_readahead(unsigned long nr)
 }
 
 /*
- * Submit IO for the read-ahead request in file_ra_state.
- */
-unsigned long ra_submit(struct file_ra_state *ra,
-		       struct address_space *mapping, struct file *filp)
-{
-	int actual;
-
-	actual = __do_page_cache_readahead(mapping, filp,
-					ra->start, ra->size, ra->async_size);
-
-	return actual;
-}
-
-/*
  * Set the initial window size, round to next power of 2 and square
  * for small size, x 4 for medium, and x 2 for large
  * for 128k (32 page) max ra
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
