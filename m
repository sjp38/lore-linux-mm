Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id D03416B0068
	for <linux-mm@kvack.org>; Thu,  1 May 2014 04:45:05 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id b15so923076eek.12
        for <linux-mm@kvack.org>; Thu, 01 May 2014 01:45:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 49si33513731een.155.2014.05.01.01.45.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 01:45:04 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 14/17] mm: Do not use atomic operations when releasing pages
Date: Thu,  1 May 2014 09:44:45 +0100
Message-Id: <1398933888-4940-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-1-git-send-email-mgorman@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>

There should be no references to it any more and a parallel mark should
not be reordered against us. Use non-locked varient to clear page active.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/swap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swap.c b/mm/swap.c
index f2228b7..7a5bdd7 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -854,7 +854,7 @@ void release_pages(struct page **pages, int nr, bool cold)
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
