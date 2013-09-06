Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 56E766B0034
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 01:17:57 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MSO001FPUPM5NE0@mailout4.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Sep 2013 14:17:56 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH v2 3/4] mm/zswap: avoid unnecessary page scanning
Date: Fri, 06 Sep 2013 13:16:45 +0800
Message-id: <000701ceaac0$71c43590$554ca0b0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com
Cc: minchan@kernel.org, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

add SetPageReclaim before __swap_writepage so that page can be moved to the
tail of the inactive list, which can avoid unnecessary page scanning as this
page was reclaimed by swap subsystem before.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
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
