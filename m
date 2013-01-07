Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 5B69D6B0071
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 15:25:23 -0500 (EST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 7 Jan 2013 13:25:22 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A1B5219D804A
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 13:25:16 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r07KPBr0225528
	for <linux-mm@kvack.org>; Mon, 7 Jan 2013 13:25:14 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r07KPBCE005723
	for <linux-mm@kvack.org>; Mon, 7 Jan 2013 13:25:11 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCHv2 7/9] mm: break up swap_writepage() for frontswap backends
Date: Mon,  7 Jan 2013 14:24:38 -0600
Message-Id: <1357590280-31535-8-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

swap_writepage() is currently where frontswap hooks into the swap
write path to capture pages with the frontswap_store() function.
However, if a frontswap backend wants to "resume" the writeback of
a page to the swap device, it can't call swap_writepage() as
the page will simply reenter the backend.

This patch separates swap_writepage() into a top and bottom half, the
bottom half named __swap_writepage() to allow a frontswap backend,
like zswap, to resume writeback beyond the frontswap_store() hook and
by notified when the writeback completes.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 include/linux/swap.h |    4 ++++
 mm/page_io.c         |   22 +++++++++++++++++-----
 mm/swap_state.c      |    2 +-
 3 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 8c66486..a3da829 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -321,6 +321,9 @@ static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct page *);
 extern int swap_writepage(struct page *page, struct writeback_control *wbc);
+extern void end_swap_bio_write(struct bio *bio, int err);
+extern int __swap_writepage(struct page *page, struct writeback_control *wbc,
+	void (*end_write_func)(struct bio *, int));
 extern int swap_set_page_dirty(struct page *page);
 extern void end_swap_bio_read(struct bio *bio, int err);
 
@@ -335,6 +338,7 @@ extern struct address_space swapper_space;
 extern void show_swap_cache_info(void);
 extern int add_to_swap(struct page *);
 extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
+extern int __add_to_swap_cache(struct page *page, swp_entry_t entry);
 extern void __delete_from_swap_cache(struct page *);
 extern void delete_from_swap_cache(struct page *);
 extern void free_page_and_swap_cache(struct page *);
diff --git a/mm/page_io.c b/mm/page_io.c
index c535d39..806085e 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -43,7 +43,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
 	return bio;
 }
 
-static void end_swap_bio_write(struct bio *bio, int err)
+void end_swap_bio_write(struct bio *bio, int err)
 {
 	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
 	struct page *page = bio->bi_io_vec[0].bv_page;
@@ -180,15 +180,16 @@ bad_bmap:
 	goto out;
 }
 
+int __swap_writepage(struct page *page, struct writeback_control *wbc,
+	void (*end_write_func)(struct bio *, int));
+
 /*
  * We may have stale swap cache pages in memory: notice
  * them here and get rid of the unnecessary final write.
  */
 int swap_writepage(struct page *page, struct writeback_control *wbc)
 {
-	struct bio *bio;
-	int ret = 0, rw = WRITE;
-	struct swap_info_struct *sis = page_swap_info(page);
+	int ret = 0;
 
 	if (try_to_free_swap(page)) {
 		unlock_page(page);
@@ -200,6 +201,17 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 		end_page_writeback(page);
 		goto out;
 	}
+	ret = __swap_writepage(page, wbc, end_swap_bio_write);
+out:
+	return ret;
+}
+
+int __swap_writepage(struct page *page, struct writeback_control *wbc,
+	void (*end_write_func)(struct bio *, int))
+{
+	struct bio *bio;
+	int ret = 0, rw = WRITE;
+	struct swap_info_struct *sis = page_swap_info(page);
 
 	if (sis->flags & SWP_FILE) {
 		struct kiocb kiocb;
@@ -227,7 +239,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 		return ret;
 	}
 
-	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
+	bio = get_swap_bio(GFP_NOIO, page, end_write_func);
 	if (bio == NULL) {
 		set_page_dirty(page);
 		unlock_page(page);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 0cb36fb..7eded9c 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -67,7 +67,7 @@ void show_swap_cache_info(void)
  * __add_to_swap_cache resembles add_to_page_cache_locked on swapper_space,
  * but sets SwapCache flag and private instead of mapping and index.
  */
-static int __add_to_swap_cache(struct page *page, swp_entry_t entry)
+int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 {
 	int error;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
