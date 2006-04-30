Message-ID: <4454A8CD.80907@yahoo.com.au>
Date: Sun, 30 Apr 2006 22:08:45 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: read_pages bug?
Content-Type: multipart/mixed;
 boundary="------------070501020905090501010308"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jens Axboe <axboe@suse.de>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070501020905090501010308
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Speaking of read_pages(), doesn't the AOP_TRUNCATED_PAGE case
cause a dangling page which can't get cleaned up because it
is not on the lru (and the file has presumably already been
truncated)?

(also, let's not worry about pretending we propogate errors)

-- 
SUSE Labs, Novell Inc.

--------------070501020905090501010308
Content-Type: text/plain;
 name="mm-fix-ra-error.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-fix-ra-error.patch"

Index: linux-2.6/mm/readahead.c
===================================================================
--- linux-2.6.orig/mm/readahead.c	2006-04-30 21:59:09.000000000 +1000
+++ linux-2.6/mm/readahead.c	2006-04-30 22:02:26.000000000 +1000
@@ -164,16 +164,15 @@ int read_cache_pages(struct address_spac
 
 EXPORT_SYMBOL(read_cache_pages);
 
-static int read_pages(struct address_space *mapping, struct file *filp,
+static void read_pages(struct address_space *mapping, struct file *filp,
 		struct list_head *pages, unsigned nr_pages)
 {
 	unsigned page_idx;
 	struct pagevec lru_pvec;
-	int ret;
 
 	if (mapping->a_ops->readpages) {
-		ret = mapping->a_ops->readpages(filp, mapping, pages, nr_pages);
-		goto out;
+		mapping->a_ops->readpages(filp, mapping, pages, nr_pages);
+		return;
 	}
 
 	pagevec_init(&lru_pvec, 0);
@@ -182,19 +181,13 @@ static int read_pages(struct address_spa
 		list_del(&page->lru);
 		if (!add_to_page_cache(page, mapping,
 					page->index, GFP_KERNEL)) {
-			ret = mapping->a_ops->readpage(filp, page);
-			if (ret != AOP_TRUNCATED_PAGE) {
-				if (!pagevec_add(&lru_pvec, page))
-					__pagevec_lru_add(&lru_pvec);
-				continue;
-			} /* else fall through to release */
-		}
-		page_cache_release(page);
+			mapping->a_ops->readpage(filp, page);
+			if (!pagevec_add(&lru_pvec, page))
+				__pagevec_lru_add(&lru_pvec);
+		} else
+			page_cache_release(page);
 	}
 	pagevec_lru_add(&lru_pvec);
-	ret = 0;
-out:
-	return ret;
 }
 
 /*

--------------070501020905090501010308--
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
