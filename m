Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 897DD6B005A
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:51 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so1681813eek.16
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5si40543694eei.268.2014.04.18.07.50.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:50 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/16] mm: Do not use atomic operations when releasing pages
Date: Fri, 18 Apr 2014 15:50:40 +0100
Message-Id: <1397832643-14275-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-1-git-send-email-mgorman@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

There should be no references to it any more and a parallel mark should
not be reordered against us. Use non-locked varient to clear page active.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/swap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swap.c b/mm/swap.c
index 9ce43ba..fed4caf 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -854,7 +854,7 @@ void release_pages(struct page **pages, int nr, int cold)
 		}
 
 		/* Clear Active bit in case of parallel mark_page_accessed */
-		ClearPageActive(page);
+		__ClearPageActive(page);
 
 		list_add(&page->lru, &pages_to_free);
 	}
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
