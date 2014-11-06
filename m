Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 91DD66B0071
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 03:09:15 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so676490pdb.25
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 00:09:15 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id le15si5281905pab.45.2014.11.06.00.09.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 06 Nov 2014 00:09:14 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NEL00LZDYN4NMC0@mailout4.samsung.com> for
 linux-mm@kvack.org; Thu, 06 Nov 2014 17:09:04 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 1/2] mm: page_isolation: check pfn validity before access
Date: Thu, 06 Nov 2014 16:08:02 +0800
Message-id: <000001cff998$ee0b31d0$ca219570$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com, 'Minchan Kim' <minchan@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, mina86@mina86.com, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

In the undo path of start_isolate_page_range(), we need to check
the pfn validity before access its page, or it will trigger an
addressing exception if there is hole in the zone.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/page_isolation.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index d1473b2..3ddc8b3 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -137,8 +137,11 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 undo:
 	for (pfn = start_pfn;
 	     pfn < undo_pfn;
-	     pfn += pageblock_nr_pages)
-		unset_migratetype_isolate(pfn_to_page(pfn), migratetype);
+	     pfn += pageblock_nr_pages) {
+		page = __first_valid_page(pfn, pageblock_nr_pages);
+		if (page)
+			unset_migratetype_isolate(page, migratetype);
+	}
 
 	return -EBUSY;
 }
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
