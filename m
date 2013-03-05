Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 8613E6B000D
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 01:59:03 -0500 (EST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MJ6003GFE1TOQR0@mailout3.samsung.com> for
 linux-mm@kvack.org; Tue, 05 Mar 2013 15:58:46 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [RFC/PATCH 5/5] media: vb2: use FOLL_DURABLE and __get_user_pages() to
 avoid CMA migration issues
Date: Tue, 05 Mar 2013 07:57:59 +0100
Message-id: <1362466679-17111-6-git-send-email-m.szyprowski@samsung.com>
In-reply-to: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com>
References: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

V4L2 devices usually grab additional references to user pages for a very
long period of time, what causes permanent migration failures if the given
page has been allocated from CMA pageblock. By setting FOLL_DURABLE flag,
videobuf2 will instruct __get_user_pages() to migrate user pages out of
CMA pageblocks before blocking them with an additional reference.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 drivers/media/v4l2-core/videobuf2-dma-contig.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf2-dma-contig.c b/drivers/media/v4l2-core/videobuf2-dma-contig.c
index 10beaee..70649ab 100644
--- a/drivers/media/v4l2-core/videobuf2-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf2-dma-contig.c
@@ -443,9 +443,13 @@ static int vb2_dc_get_user_pages(unsigned long start, struct page **pages,
 		}
 	} else {
 		int n;
+		int flags = FOLL_TOUCH | FOLL_GET | FOLL_FORCE | FOLL_DURABLE;
 
-		n = get_user_pages(current, current->mm, start & PAGE_MASK,
-			n_pages, write, 1, pages, NULL);
+		if (write)
+			flags |= FOLL_WRITE;
+
+		n = __get_user_pages(current, current->mm, start & PAGE_MASK,
+			n_pages, flags, pages, NULL, NULL);
 		/* negative error means that no page was pinned */
 		n = max(n, 0);
 		if (n != n_pages) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
