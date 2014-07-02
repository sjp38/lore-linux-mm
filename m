Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 55E9A6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 23:39:32 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id tp5so8912143ieb.22
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 20:39:32 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id h20si37069593icc.67.2014.07.01.20.39.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 20:39:31 -0700 (PDT)
Received: by mail-ie0-f176.google.com with SMTP id rd18so9043132iec.35
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 20:39:31 -0700 (PDT)
From: Liu Ping Fan <kernelfans@gmail.com>
Subject: [PATCH] mm: swap: avoid to writepage when a page is !PageSwapCache
Date: Wed,  2 Jul 2014 11:42:53 +0800
Message-Id: <1404272573-24448-1-git-send-email-pingfank@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>

There is race between do_swap_page() and swap_writepage(), if
do_swap_page() had deleted a page from swap cache, there is no need
to write it. So changing the ret of try_to_free_swap() to make
swap_writepage() aware of this scene.

Signed-off-by: Liu Ping Fan <pingfank@linux.vnet.ibm.com>
---
 mm/swapfile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 4c524f7..9d80671 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -910,7 +910,7 @@ int try_to_free_swap(struct page *page)
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
 	if (!PageSwapCache(page))
-		return 0;
+		return -1;
 	if (PageWriteback(page))
 		return 0;
 	if (page_swapcount(page))
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
