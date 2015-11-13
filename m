Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 185116B0254
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 06:47:45 -0500 (EST)
Received: by pasz6 with SMTP id z6so101721450pas.2
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 03:47:44 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id ww1si26990634pab.181.2015.11.13.03.47.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 03:47:44 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so98485609pab.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 03:47:44 -0800 (PST)
From: yalin wang <yalin.wang2010@gmail.com>
Subject: [PATCH] mm: change may_enter_fs check condition
Date: Fri, 13 Nov 2015 19:47:35 +0800
Message-Id: <1447415255-832-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.cz, vbabka@suse.cz, vdavydov@parallels.com, hannes@cmpxchg.org, mgorman@techsingularity.net, yalin.wang2010@gmail.com, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Add page_is_file_cache() for __GFP_FS check,
otherwise, a Pageswapcache() && PageDirty() page can always be write
back if the gfp flag is __GFP_FS, this is not the expected behavior.

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bd2918e..f8fc8c1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -930,7 +930,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (page_mapped(page) || PageSwapCache(page))
 			sc->nr_scanned++;
 
-		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
+		may_enter_fs = (page_is_file_cache(page) && (sc->gfp_mask & __GFP_FS)) ||
 			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
 
 		/*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
