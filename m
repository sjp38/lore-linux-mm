Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E27116B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 11:07:14 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/4] mm: vmscan: Do not use page_count without a page pin
Date: Tue,  7 Jun 2011 16:07:03 +0100
Message-Id: <1307459225-4481-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1307459225-4481-1-git-send-email-mgorman@suse.de>
References: <1307459225-4481-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Thomas Sattler <tsattler@gmx.de>, Ury Stankevich <urykhy@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

From: Andrea Arcangeli <aarcange@redhat.com>

From: Andrea Arcangeli <aarcange@redhat.com>

It is unsafe to run page_count during the physical pfn scan because
compound_head could trip on a dangling pointer when reading
page->first_page if the compound page is being freed by another CPU.

[mgorman@suse.de: Split out patch]
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index faa0a08..001a504 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1124,8 +1124,20 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 					nr_lumpy_dirty++;
 				scan++;
 			} else {
-				/* the page is freed already. */
-				if (!page_count(cursor_page))
+				/*
+				 * Check if the page is freed already.
+				 *
+				 * We can't use page_count() as that
+				 * requires compound_head and we don't
+				 * have a pin on the page here. If a
+				 * page is tail, we may or may not
+				 * have isolated the head, so assume
+				 * it's not free, it'd be tricky to
+				 * track the head status without a
+				 * page pin.
+				 */
+				if (!PageTail(cursor_page) &&
+				    !atomic_read(&cursor_page->_count))
 					continue;
 				break;
 			}
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
