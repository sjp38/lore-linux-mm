Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CD5DA900001
	for <linux-mm@kvack.org>; Sun,  1 May 2011 11:03:56 -0400 (EDT)
Received: by pvc12 with SMTP id 12so3861592pvc.14
        for <linux-mm@kvack.org>; Sun, 01 May 2011 08:03:55 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 1/2] Check PageUnevictable in lru_deactivate_fn
Date: Mon,  2 May 2011 00:03:30 +0900
Message-Id: <c7a7b3ceafe4fdc4bc038774374504827c01481f.1304261567.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1304261567.git.minchan.kim@gmail.com>
References: <cover.1304261567.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1304261567.git.minchan.kim@gmail.com>
References: <cover.1304261567.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, Minchan Kim <minchan.kim@gmail.com>

The lru_deactivate_fn should not move page which in on unevictable lru
into inactive list. Otherwise, we can meet BUG when we use isolate_lru_pages
as __isolate_lru_page could return -EINVAL.
It's really BUG and let's fix it.

Reported-by: Ying Han <yinghan@google.com>
Tested-by: Ying Han <yinghan@google.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/swap.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index a83ec5a..2e9656d 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -429,6 +429,9 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 	if (!PageLRU(page))
 		return;
 
+	if (PageUnevictable(page))
+		return;
+
 	/* Some processes are using the page */
 	if (page_mapped(page))
 		return;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
