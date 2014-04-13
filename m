Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 91C556B00BE
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 19:00:07 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so7375522pdj.37
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 16:00:07 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id bi5si7753862pbb.191.2014.04.13.16.00.06
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 16:00:06 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v3 7/7] brd: Return -ENOSPC rather than -ENOMEM on page allocation failure
Date: Sun, 13 Apr 2014 18:59:56 -0400
Message-Id: <f79dcaa7a00de26924c563f91e22418896904167.1397429628.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1397429628.git.matthew.r.wilcox@intel.com>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1397429628.git.matthew.r.wilcox@intel.com>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

brd is effectively a thinly provisioned device.  Thinly provisioned
devices return -ENOSPC when they can't write a new block.  -ENOMEM is
an implementation detail that callers shouldn't know.

Acked-by: Dave Chinner <david@fromorbit.com>
Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 drivers/block/brd.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 807d3d5..c7d138e 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -200,11 +200,11 @@ static int copy_to_brd_setup(struct brd_device *brd, sector_t sector, size_t n)
 
 	copy = min_t(size_t, n, PAGE_SIZE - offset);
 	if (!brd_insert_page(brd, sector))
-		return -ENOMEM;
+		return -ENOSPC;
 	if (copy < n) {
 		sector += copy >> SECTOR_SHIFT;
 		if (!brd_insert_page(brd, sector))
-			return -ENOMEM;
+			return -ENOSPC;
 	}
 	return 0;
 }
@@ -384,7 +384,7 @@ static int brd_direct_access(struct block_device *bdev, sector_t sector,
 		return -ERANGE;
 	page = brd_insert_page(brd, sector);
 	if (!page)
-		return -ENOMEM;
+		return -ENOSPC;
 	*kaddr = page_address(page);
 	*pfn = page_to_pfn(page);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
