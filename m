Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 76DDB900001
	for <linux-mm@kvack.org>; Sun,  1 May 2011 11:04:01 -0400 (EDT)
Received: by mail-pw0-f41.google.com with SMTP id 10so3171312pwi.14
        for <linux-mm@kvack.org>; Sun, 01 May 2011 08:04:00 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 2/2] Filter unevictable page out in deactivate_page
Date: Mon,  2 May 2011 00:03:31 +0900
Message-Id: <dc54a5771cf1f580a91d16816100d4a2bcf2cdf5.1304261567.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1304261567.git.minchan.kim@gmail.com>
References: <cover.1304261567.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1304261567.git.minchan.kim@gmail.com>
References: <cover.1304261567.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, Minchan Kim <minchan.kim@gmail.com>

It's pointless that deactive_page's pagevec operation about
unevictable page as it's nop.
This patch removes unnecessary overhead which might be a bit problem
in case that there are many unevictable page in system(ex, mprotect workload)

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/swap.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 2e9656d..b707694 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -511,6 +511,15 @@ static void drain_cpu_pagevecs(int cpu)
  */
 void deactivate_page(struct page *page)
 {
+
+	/*
+	 * In workload which system has many unevictable page(ex, mprotect),
+	 * unevictalge page deactivation for accelerating reclaim
+	 * is pointless.
+	 */
+	if (PageUnevictable(page))
+		return;
+
 	if (likely(get_page_unless_zero(page))) {
 		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
