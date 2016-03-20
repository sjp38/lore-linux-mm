Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id DD75982F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:49:11 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id 4so106664409pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:49:11 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id q194si13991762pfq.17.2016.03.20.11.41.43
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:43 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 12/71] mtd: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:19 +0300
Message-Id: <1458499278-1516-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Richard Weinberger <richard@nod.at>, Joern Engel <joern@lazybastard.org>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Boris Brezillon <boris.brezillon@free-electrons.com>
Cc: Richard Weinberger <richard@nod.at>
Cc: Joern Engel <joern@lazybastard.org>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Brian Norris <computersforpeace@gmail.com>
---
 drivers/mtd/devices/block2mtd.c | 6 +++---
 drivers/mtd/nand/nandsim.c      | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/mtd/devices/block2mtd.c b/drivers/mtd/devices/block2mtd.c
index e2c0057737e6..7c887f111a7d 100644
--- a/drivers/mtd/devices/block2mtd.c
+++ b/drivers/mtd/devices/block2mtd.c
@@ -75,7 +75,7 @@ static int _block2mtd_erase(struct block2mtd_dev *dev, loff_t to, size_t len)
 				break;
 			}
 
-		page_cache_release(page);
+		put_page(page);
 		pages--;
 		index++;
 	}
@@ -124,7 +124,7 @@ static int block2mtd_read(struct mtd_info *mtd, loff_t from, size_t len,
 			return PTR_ERR(page);
 
 		memcpy(buf, page_address(page) + offset, cpylen);
-		page_cache_release(page);
+		put_page(page);
 
 		if (retlen)
 			*retlen += cpylen;
@@ -164,7 +164,7 @@ static int _block2mtd_write(struct block2mtd_dev *dev, const u_char *buf,
 			unlock_page(page);
 			balance_dirty_pages_ratelimited(mapping);
 		}
-		page_cache_release(page);
+		put_page(page);
 
 		if (retlen)
 			*retlen += cpylen;
diff --git a/drivers/mtd/nand/nandsim.c b/drivers/mtd/nand/nandsim.c
index 1fd519503bb1..a58169a28741 100644
--- a/drivers/mtd/nand/nandsim.c
+++ b/drivers/mtd/nand/nandsim.c
@@ -1339,7 +1339,7 @@ static void put_pages(struct nandsim *ns)
 	int i;
 
 	for (i = 0; i < ns->held_cnt; i++)
-		page_cache_release(ns->held_pages[i]);
+		put_page(ns->held_pages[i]);
 }
 
 /* Get page cache pages in advance to provide NOFS memory allocation */
@@ -1349,8 +1349,8 @@ static int get_pages(struct nandsim *ns, struct file *file, size_t count, loff_t
 	struct page *page;
 	struct address_space *mapping = file->f_mapping;
 
-	start_index = pos >> PAGE_CACHE_SHIFT;
-	end_index = (pos + count - 1) >> PAGE_CACHE_SHIFT;
+	start_index = pos >> PAGE_SHIFT;
+	end_index = (pos + count - 1) >> PAGE_SHIFT;
 	if (end_index - start_index + 1 > NS_MAX_HELD_PAGES)
 		return -EINVAL;
 	ns->held_cnt = 0;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
