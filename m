Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 22D336B0033
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 04:23:03 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so2006447pad.30
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 01:23:02 -0700 (PDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MTK00CU5KLLCSW0@mailout3.samsung.com> for
 linux-mm@kvack.org; Mon, 23 Sep 2013 17:22:59 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH v3 3/3] mm/zswap: avoid unnecessary page scanning
Date: Mon, 23 Sep 2013 16:21:49 +0800
Message-id: <000101ceb836$1a4c0ee0$4ee42ca0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, minchan@kernel.org, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, d.j.shin@samsung.com, heesub.shin@samsung.com, kyungmin.park@samsung.com, hau.chen@samsung.com, bifeng.tong@samsung.com, rui.xie@samsung.com

add SetPageReclaim before __swap_writepage so that page can be moved to the
tail of the inactive list, which can avoid unnecessary page scanning as this
page was reclaimed by swap subsystem before.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
Reviewed-by: Bob Liu <bob.liu@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: stable@vger.kernel.org
Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 mm/zswap.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/zswap.c b/mm/zswap.c
index 1be7b90..cc40e6a 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -556,6 +556,9 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 		SetPageUptodate(page);
 	}
 
+	/* move it to the tail of the inactive list after end_writeback */
+	SetPageReclaim(page);
+
 	/* start writeback */
 	__swap_writepage(page, &wbc, end_swap_bio_write);
 	page_cache_release(page);
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
