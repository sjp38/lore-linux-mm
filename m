Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 74D016B005A
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 05:35:32 -0400 (EDT)
Received: by pxi40 with SMTP id 40so1132747pxi.12
        for <linux-mm@kvack.org>; Thu, 25 Jun 2009 02:36:38 -0700 (PDT)
Date: Thu, 25 Jun 2009 18:36:16 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] prevent to reclaim anon page of lumpy reclaim for no swap
 space
Message-Id: <20090625183616.23b55b24.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch prevent to reclaim anon page in case of no swap space.
VM already prevent to reclaim anon page in various place.
But it doesnt't prevent it for lumpy reclaim.

It shuffles lru list unnecessary so that it is pointless.
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmscan.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 026f452..fb401fe 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -830,7 +830,13 @@ int __isolate_lru_page(struct page *page, int mode, int file)
 	 * When this function is being called for lumpy reclaim, we
 	 * initially look into all LRU pages, active, inactive and
 	 * unevictable; only give shrink_page_list evictable pages.
+
+	 * If we don't have enough swap space, reclaiming of anon page
+	 * is pointless.
 	 */
+	if (nr_swap_pages <= 0 && PageAnon(page))
+		return ret;
+
 	if (PageUnevictable(page))
 		return ret;
 
-- 
1.5.4.3




-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
