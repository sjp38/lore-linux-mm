Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A612B6B0069
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 03:52:54 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y13so7924463pdi.9
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 00:52:54 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id jy15si37466361pad.148.2014.11.18.00.52.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 18 Nov 2014 00:52:53 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NF80067H8NW85D0@mailout4.samsung.com> for
 linux-mm@kvack.org; Tue, 18 Nov 2014 17:52:44 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH] mm: frontswap: invalidate expired data on a dup-store failure
Date: Tue, 18 Nov 2014 16:51:36 +0800
Message-id: <000001d0030d$0505aaa0$0f10ffe0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Seth Jennings' <sjennings@variantweb.net>, 'Dan Streetman' <ddstreet@ieee.org>, 'Minchan Kim' <minchan@kernel.org>, 'Bob Liu' <bob.liu@oracle.com>, xfishcoder@gmail.com, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If a frontswap dup-store failed, it should invalidate the expired page
in the backend, or it could trigger some data corruption issue.
Such as:
1. use zswap as the frontswap backend with writeback feature
2. store a swap page(version_1) to entry A, success
3. dup-store a newer page(version_2) to the same entry A, fail
4. use __swap_writepage() write version_2 page to swapfile, success
5. zswap do shrink, writeback version_1 page to swapfile
6. version_2 page is overwrited by version_1, data corrupt.

This patch fixes this issue by invalidating expired data immediately
when meet a dup-store failure.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/frontswap.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index c30eec5..f2a3571 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -244,8 +244,10 @@ int __frontswap_store(struct page *page)
 		  the (older) page from frontswap
 		 */
 		inc_frontswap_failed_stores();
-		if (dup)
+		if (dup) {
 			__frontswap_clear(sis, offset);
+			frontswap_ops->invalidate_page(type, offset);
+		}
 	}
 	if (frontswap_writethrough_enabled)
 		/* report failure so swap also writes to swap device */
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
