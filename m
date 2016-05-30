Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B2DAA6B025E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 05:01:57 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id w16so77304651lfd.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:01:57 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id yy9si43283342wjc.217.2016.05.30.02.01.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 02:01:56 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id E032C98C38
	for <linux-mm@kvack.org>; Mon, 30 May 2016 09:01:55 +0000 (UTC)
Date: Mon, 30 May 2016 10:01:54 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, page_alloc: prevent infinite loop in buffered_rmqueue()
Message-ID: <20160530090154.GM2527@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

From: Vlastimil Babka <vbabka@suse.cz>

In DEBUG_VM kernel, we can hit infinite loop for order == 0 in
buffered_rmqueue() when check_new_pcp() returns 1, because the bad page is
never removed from the pcp list. Fix this by removing the page before retrying.
Also we don't need to check if page is non-NULL, because we simply grab it from
the list which was just tested for being non-empty.

Fixes: http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-page_alloc-defer-debugging-checks-of-freed-pages-until-a-pcp-drain.patch
Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f8f3bfc435ee..bb320cde4d6d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2609,11 +2609,12 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 				page = list_last_entry(list, struct page, lru);
 			else
 				page = list_first_entry(list, struct page, lru);
-		} while (page && check_new_pcp(page));
 
-		__dec_zone_state(zone, NR_ALLOC_BATCH);
-		list_del(&page->lru);
-		pcp->count--;
+			__dec_zone_state(zone, NR_ALLOC_BATCH);
+			list_del(&page->lru);
+			pcp->count--;
+
+		} while (check_new_pcp(page));
 	} else {
 		/*
 		 * We most definitely don't want callers attempting to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
