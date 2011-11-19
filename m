Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E8E7C6B0069
	for <linux-mm@kvack.org>; Sat, 19 Nov 2011 14:54:37 -0500 (EST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/8] mm: check if we isolated a compound page during lumpy scan
Date: Sat, 19 Nov 2011 20:54:15 +0100
Message-Id: <1321732460-14155-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1321635524-8586-1-git-send-email-mgorman@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org

Properly take into account if we isolated a compound page during the
lumpy scan in reclaim and break the loop if we've isolated enough.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/vmscan.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a1893c0..3421746 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1183,13 +1183,16 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 				break;
 
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
+				unsigned int isolated_pages;
 				list_move(&cursor_page->lru, dst);
 				mem_cgroup_del_lru(cursor_page);
-				nr_taken += hpage_nr_pages(page);
-				nr_lumpy_taken++;
+				isolated_pages = hpage_nr_pages(page);
+				nr_taken += isolated_pages;
+				nr_lumpy_taken += isolated_pages;
 				if (PageDirty(cursor_page))
-					nr_lumpy_dirty++;
+					nr_lumpy_dirty += isolated_pages;
 				scan++;
+				pfn += isolated_pages-1;
 			} else {
 				/*
 				 * Check if the page is freed already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
