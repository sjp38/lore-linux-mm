Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 2EAE66B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:19:32 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 14:19:30 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 945F5C9006A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:19:27 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AIJP6f238100
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:19:26 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AIJOhj004513
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:19:25 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCHv9 6/8] mm: allow for outstanding swap writeback accounting
Date: Wed, 10 Apr 2013 13:18:58 -0500
Message-Id: <1365617940-21623-7-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1365617940-21623-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1365617940-21623-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

To prevent flooding the swap device with writebacks, frontswap
backends need to count and limit the number of outstanding
writebacks.  The incrementing of the counter can be done before
the call to __swap_writepage().  However, the caller must receive
a notification when the writeback completes in order to decrement
the counter.

To achieve this functionality, this patch modifies
__swap_writepage() to take the bio completion callback function
as an argument.

end_swap_bio_write(), the normal bio completion function, is also
made non-static so that code doing the accounting can call it
after the accounting is done.

Acked-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 include/linux/swap.h |  4 +++-
 mm/page_io.c         | 12 +++++++-----
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 76f6c3b..b5b12c7 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -330,7 +330,9 @@ static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct page *);
 extern int swap_writepage(struct page *page, struct writeback_control *wbc);
-extern int __swap_writepage(struct page *page, struct writeback_control *wbc);
+extern void end_swap_bio_write(struct bio *bio, int err);
+extern int __swap_writepage(struct page *page, struct writeback_control *wbc,
+	void (*end_write_func)(struct bio *, int));
 extern int swap_set_page_dirty(struct page *page);
 extern void end_swap_bio_read(struct bio *bio, int err);
 
diff --git a/mm/page_io.c b/mm/page_io.c
index 1cb382d..56276fe 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -42,7 +42,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
 	return bio;
 }
 
-static void end_swap_bio_write(struct bio *bio, int err)
+void end_swap_bio_write(struct bio *bio, int err)
 {
 	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
 	struct page *page = bio->bi_io_vec[0].bv_page;
@@ -179,7 +179,8 @@ bad_bmap:
 	goto out;
 }
 
-int __swap_writepage(struct page *page, struct writeback_control *wbc);
+int __swap_writepage(struct page *page, struct writeback_control *wbc,
+	void (*end_write_func)(struct bio *, int));
 
 /*
  * We may have stale swap cache pages in memory: notice
@@ -199,12 +200,13 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 		end_page_writeback(page);
 		goto out;
 	}
-	ret = __swap_writepage(page, wbc);
+	ret = __swap_writepage(page, wbc, end_swap_bio_write);
 out:
 	return ret;
 }
 
-int __swap_writepage(struct page *page, struct writeback_control *wbc)
+int __swap_writepage(struct page *page, struct writeback_control *wbc,
+	void (*end_write_func)(struct bio *, int))
 {
 	struct bio *bio;
 	int ret = 0, rw = WRITE;
@@ -236,7 +238,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc)
 		return ret;
 	}
 
-	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
+	bio = get_swap_bio(GFP_NOIO, page, end_write_func);
 	if (bio == NULL) {
 		set_page_dirty(page);
 		unlock_page(page);
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
