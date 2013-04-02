Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id C13746B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 23:50:06 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kp14so52263pab.22
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 20:50:06 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 1/2] mm: break up swap_writepage() for frontswap backends
Date: Tue,  2 Apr 2013 11:50:00 +0800
Message-Id: <1364874600-878-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, minchan@kernel.org, sjenning@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com, ngupta@vflare.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, Bob Liu <bob.liu@oracle.com>

From: Seth Jennings <sjenning@linux.vnet.ibm.com>

swap_writepage() is currently where frontswap hooks into the swap
write path to capture pages with the frontswap_store() function.
However, if a frontswap backend wants to "resume" the writeback of
a page to the swap device, it can't call swap_writepage() as
the page will simply reenter the backend.

This patch separates swap_writepage() into a top and bottom half, the
bottom half named __swap_writepage() to allow a frontswap backend,
like zswap, to resume writeback beyond the frontswap_store() hook.

__add_to_swap_cache() is also made non-static so that the page for
which writeback is to be resumed can be added to the swap cache.

Acked-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 include/linux/swap.h |    2 ++
 mm/page_io.c         |   14 +++++++++++---
 mm/swap_state.c      |    2 +-
 3 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 2818a12..76f6c3b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -330,6 +330,7 @@ static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct page *);
 extern int swap_writepage(struct page *page, struct writeback_control *wbc);
+extern int __swap_writepage(struct page *page, struct writeback_control *wbc);
 extern int swap_set_page_dirty(struct page *page);
 extern void end_swap_bio_read(struct bio *bio, int err);
 
@@ -345,6 +346,7 @@ extern unsigned long total_swapcache_pages(void);
 extern void show_swap_cache_info(void);
 extern int add_to_swap(struct page *);
 extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
+extern int __add_to_swap_cache(struct page *page, swp_entry_t entry);
 extern void __delete_from_swap_cache(struct page *);
 extern void delete_from_swap_cache(struct page *);
 extern void free_page_and_swap_cache(struct page *);
diff --git a/mm/page_io.c b/mm/page_io.c
index 78eee32..8e6bcf1 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -185,9 +185,7 @@ bad_bmap:
  */
 int swap_writepage(struct page *page, struct writeback_control *wbc)
 {
-	struct bio *bio;
-	int ret = 0, rw = WRITE;
-	struct swap_info_struct *sis = page_swap_info(page);
+	int ret = 0;
 
 	if (try_to_free_swap(page)) {
 		unlock_page(page);
@@ -199,6 +197,16 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 		end_page_writeback(page);
 		goto out;
 	}
+	ret = __swap_writepage(page, wbc);
+out:
+	return ret;
+}
+
+int __swap_writepage(struct page *page, struct writeback_control *wbc)
+{
+	struct bio *bio;
+	int ret = 0, rw = WRITE;
+	struct swap_info_struct *sis = page_swap_info(page);
 
 	if (sis->flags & SWP_FILE) {
 		struct kiocb kiocb;
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 7efcf15..fe43fd5 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -78,7 +78,7 @@ void show_swap_cache_info(void)
  * __add_to_swap_cache resembles add_to_page_cache_locked on swapper_space,
  * but sets SwapCache flag and private instead of mapping and index.
  */
-static int __add_to_swap_cache(struct page *page, swp_entry_t entry)
+int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 {
 	int error;
 	struct address_space *address_space;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
