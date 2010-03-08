Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 63AF46B00A2
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 06:48:28 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/3] page-allocator: Check zone pressure when batch of pages are freed
Date: Mon,  8 Mar 2010 11:48:22 +0000
Message-Id: <1268048904-19397-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Nick Piggin <npiggin@suse.de>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When a batch of pages have been freed to the buddy allocator, it is possible
that it is enough to push a zone above its watermarks. This patch puts a
check in the free path for zone pressure. It's in a common path but for
the most part, it should only be checking if a linked list is empty and
have minimal performance impact.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1383ff9..3c8e8b7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -562,6 +562,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		} while (--count && --batch_free && !list_empty(list));
 	}
 	spin_unlock(&zone->lock);
+
+	/* A batch of pages have been freed so check zone pressure */
+	check_zone_pressure(zone);
 }
 
 static void free_one_page(struct zone *zone, struct page *page, int order,
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
