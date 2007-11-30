Message-Id: <20071130173510.887469642@sgi.com>
References: <20071130173448.951783014@sgi.com>
Date: Fri, 30 Nov 2007 09:35:07 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 19/19] Use page_cache_xxx in drivers/block/rd.c
Content-Disposition: inline; filename=0020-Use-page_cache_xxx-in-drivers-block-rd.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in drivers/block/rd.c

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 drivers/block/rd.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: mm/drivers/block/rd.c
===================================================================
--- mm.orig/drivers/block/rd.c	2007-11-28 16:54:34.007439863 -0800
+++ mm/drivers/block/rd.c	2007-11-29 11:23:58.900823092 -0800
@@ -122,7 +122,7 @@ static void make_page_uptodate(struct pa
 			}
 		} while ((bh = bh->b_this_page) != head);
 	} else {
-		memset(page_address(page), 0, PAGE_CACHE_SIZE);
+		memset(page_address(page), 0, page_cache_size(page_mapping(page)));
 	}
 	flush_dcache_page(page);
 	SetPageUptodate(page);
@@ -215,9 +215,9 @@ static const struct address_space_operat
 static int rd_blkdev_pagecache_IO(int rw, struct bio_vec *vec, sector_t sector,
 				struct address_space *mapping)
 {
-	pgoff_t index = sector >> (PAGE_CACHE_SHIFT - 9);
+	pgoff_t index = sector >> (page_cache_shift(mapping) - 9);
 	unsigned int vec_offset = vec->bv_offset;
-	int offset = (sector << 9) & ~PAGE_CACHE_MASK;
+	int offset = page_cache_offset(mapping, (sector << 9));
 	int size = vec->bv_len;
 	int err = 0;
 
@@ -227,7 +227,7 @@ static int rd_blkdev_pagecache_IO(int rw
 		char *src;
 		char *dst;
 
-		count = PAGE_CACHE_SIZE - offset;
+		count = page_cache_size(mapping) - offset;
 		if (count > size)
 			count = size;
 		size -= count;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
