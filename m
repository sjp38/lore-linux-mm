Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 934936B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 07:14:07 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id e14so581471iej.36
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 04:14:06 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 23 Aug 2013 19:14:06 +0800
Message-ID: <CAL1ERfMc-KUEvF-vdWvPgQ+igW29fpRrS4oPwoz_DdGRzsGwtw@mail.gmail.com>
Subject: [PATCH 4/4] zswap: avoid unnecessary page scanning
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, sjenning@linux.vnet.ibm.com
Cc: weijie.yang@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

add SetPageReclaim before __swap_writepage, so that page can be moved
to the tail of the inactive list,
which will avoid unnecessary page scanning as this page was reclaimed
by swap subsystem before.

---
 mm/zswap.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 9d34c3c..67a2e38 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -556,6 +556,9 @@ static int zswap_writeback_entry(struct zbud_pool
*pool, unsigned long handle)
 		SetPageUptodate(page);
 	}

+	/* move it to the tail of the inactive list after end_writeback */
+	SetPageReclaim(page);
+
 	/* start writeback */
 	__swap_writepage(page, &wbc, end_swap_bio_write);
 	page_cache_release(page);
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
