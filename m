Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 109D6280284
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 00:30:12 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id bi5so10599410pad.0
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 21:30:12 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id bq2si5909300pab.298.2016.11.10.21.30.10
        for <linux-mm@kvack.org>;
        Thu, 10 Nov 2016 21:30:11 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: support anonymous stable page
Date: Fri, 11 Nov 2016 14:30:02 +0900
Message-Id: <1478842202-24009-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, "Darrick J . Wong" <darrick.wong@oracle.com>

For developemnt for zram-swap asynchronous writeback, I found
strange corruption of compressed page. With investigation, it
reveals currently stable page doesn't support anonymous page.
IOW, reuse_swap_page can reuse the page without waiting
writeback completion so that it can corrupt data during
zram compression. It can affect every swap device which supports
asynchronous writeback and CRC checking as well as zRAM.

Unfortunately, reuse_swap_page should be atomic so that we
cannot wait on writeback in there so the approach in this patch
is simply return false if we found it needs stable page.
Although it increases memory footprint temporarily, it happens
rarely and it should be reclaimed easily althoug it happened.
Also, It would be better than waiting of IO completion, which
is critial path for application latency.

Cc: Hugh Dickins <hughd@google.com>
Cc: Darrick J. Wong <darrick.wong@oracle.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/swapfile.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 816ca8663ae5..ea591435d8e0 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -949,7 +949,12 @@ bool reuse_swap_page(struct page *page, int *total_mapcount)
 			delete_from_swap_cache(page);
 			SetPageDirty(page);
 		} else {
-			wait_for_stable_page(page);
+			struct address_space *mapping;
+
+			mapping = page_mapping(page);
+			if (bdi_cap_stable_pages_required(
+					inode_to_bdi(mapping->host)))
+				return false;
 		}
 	}
 out:
@@ -2185,6 +2190,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 static int claim_swapfile(struct swap_info_struct *p, struct inode *inode)
 {
 	int error;
+	struct address_space *swapper_space;
 
 	if (S_ISBLK(inode->i_mode)) {
 		p->bdev = bdgrab(I_BDEV(inode));
@@ -2207,6 +2213,9 @@ static int claim_swapfile(struct swap_info_struct *p, struct inode *inode)
 	} else
 		return -EINVAL;
 
+	swapper_space = &swapper_spaces[p->type];
+	swapper_space->host = inode;
+
 	return 0;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
