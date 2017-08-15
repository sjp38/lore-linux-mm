Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED3E36B02FA
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 21:52:43 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c2so59874307qkb.10
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:52:43 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id s12si7774738qta.167.2017.08.14.18.52.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 18:52:43 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 4/4] mm: hwpoison: soft offline supports thp migration
Date: Mon, 14 Aug 2017 21:52:16 -0400
Message-Id: <20170815015216.31827-5-zi.yan@sent.com>
In-Reply-To: <20170815015216.31827-1-zi.yan@sent.com>
References: <20170815015216.31827-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>

From: Zi Yan <zi.yan@cs.rutgers.edu>

This patch enables thp migration for soft offline.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/memory-failure.c | 19 -------------------
 1 file changed, 19 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index c05107548d72..02ae1aff51a4 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1712,25 +1712,6 @@ static int __soft_offline_page(struct page *page, int flags, int *split)
 static int soft_offline_in_use_page(struct page *page, int flags, int *split)
 {
 	int ret;
-	struct page *hpage = compound_head(page);
-
-	if (!PageHuge(page) && PageTransHuge(hpage)) {
-		lock_page(hpage);
-		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
-			unlock_page(hpage);
-			if (!PageAnon(hpage))
-				pr_info("soft offline: %#lx: non anonymous thp\n", page_to_pfn(page));
-			else
-				pr_info("soft offline: %#lx: thp split failed\n", page_to_pfn(page));
-			put_hwpoison_page(hpage);
-			return -EBUSY;
-		}
-		if (split)
-			*split = 1;
-		unlock_page(hpage);
-		get_hwpoison_page(page);
-		put_hwpoison_page(hpage);
-	}
 
 	if (PageHuge(page))
 		ret = soft_offline_huge_page(page, flags);
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
