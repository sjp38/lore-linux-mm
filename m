Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id ED7B490010C
	for <linux-mm@kvack.org>; Tue,  3 May 2011 10:48:49 -0400 (EDT)
Received: by pxi7 with SMTP id 7so90313pxi.30
        for <linux-mm@kvack.org>; Tue, 03 May 2011 07:48:48 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 1/2] Check PageUnevictable in lru_deactivate_fn
Date: Tue,  3 May 2011 23:48:32 +0900
Message-Id: <bdccc644d628b8da0f1bc52332370191903371b2.1304433952.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1304433952.git.minchan.kim@gmail.com>
References: <cover.1304433952.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1304433952.git.minchan.kim@gmail.com>
References: <cover.1304433952.git.minchan.kim@gmail.com>
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
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Rik van Riel<riel@redhat.com>
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
