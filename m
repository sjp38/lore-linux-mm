Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id A18806B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 02:49:57 -0400 (EDT)
Received: by oiev193 with SMTP id v193so52487687oie.3
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 23:49:57 -0700 (PDT)
Received: from BLU004-OMC1S5.hotmail.com (blu004-omc1s5.hotmail.com. [65.55.116.16])
        by mx.google.com with ESMTPS id cx4si13654040oeb.100.2015.08.09.23.49.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 09 Aug 2015 23:49:56 -0700 (PDT)
Message-ID: <BLU436-SMTP188C7B16D46EEDEB4A9B9F980700@phx.gbl>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Subject: [PATCH 1/2] mm/hwpoison: fix fail to split THP w/ refcount held
Date: Mon, 10 Aug 2015 14:32:30 +0800
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <wanpeng.li@hotmail.com>

THP pages will get a refcount in madvise_hwpoison() w/ MF_COUNT_INCREASED 
flag, however, the refcount is still held when fail to split THP pages.

Fix it by reducing the refcount of THP pages when fail to split THP.

Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
---
 mm/memory-failure.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 8077b1c..56b8a71 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1710,6 +1710,8 @@ int soft_offline_page(struct page *page, int flags)
 		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
 			pr_info("soft offline: %#lx: failed to split THP\n",
 				pfn);
+			if (flags & MF_COUNT_INCREASED)
+				put_page(page);
 			return -EBUSY;
 		}
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
