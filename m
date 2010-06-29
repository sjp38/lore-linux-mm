Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8D92F600227
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 07:34:55 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 01/14] vmscan: Fix mapping use after free
Date: Tue, 29 Jun 2010 12:34:35 +0100
Message-Id: <1277811288-5195-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: Nick Piggin <npiggin@suse.de>

Use lock_page_nosync in handle_write_error as after writepage we have no
reference to the mapping when taking the page lock.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9c7e57c..62a30fe 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -296,7 +296,7 @@ static int may_write_to_queue(struct backing_dev_info *bdi)
 static void handle_write_error(struct address_space *mapping,
 				struct page *page, int error)
 {
-	lock_page(page);
+	lock_page_nosync(page);
 	if (page_mapping(page) == mapping)
 		mapping_set_error(mapping, error);
 	unlock_page(page);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
