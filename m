Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 04C806B0309
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 22:37:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y29so17614879pff.6
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 19:37:24 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id t185si6929319pgd.623.2017.09.11.19.37.22
        for <linux-mm@kvack.org>;
        Mon, 11 Sep 2017 19:37:22 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 4/5] mm:swap: respect page_cluster for readahead
Date: Tue, 12 Sep 2017 11:37:12 +0900
Message-Id: <1505183833-4739-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1505183833-4739-1-git-send-email-minchan@kernel.org>
References: <1505183833-4739-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>, Ilya Dryomov <idryomov@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "Huang, Ying" <ying.huang@intel.com>

page_cluster 0 means "we don't want readahead" so in the case,
let's skip the readahead detection logic.

Cc: "Huang, Ying" <ying.huang@intel.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 0f54b491e118..739d94397c47 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -427,7 +427,8 @@ extern bool has_usable_swap(void);
 
 static inline bool swap_use_vma_readahead(void)
 {
-	return READ_ONCE(swap_vma_readahead) && !atomic_read(&nr_rotate_swap);
+	return page_cluster > 0 && READ_ONCE(swap_vma_readahead)
+				&& !atomic_read(&nr_rotate_swap);
 }
 
 /* Swap 50% full? Release swapcache more aggressively.. */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
