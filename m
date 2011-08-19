Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C38EE6B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 03:48:57 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p7J7mtvb020263
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:55 -0700
Received: from gxk23 (gxk23.prod.google.com [10.202.11.23])
	by wpaz24.hot.corp.google.com with ESMTP id p7J7mpjG003255
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:54 -0700
Received: by gxk23 with SMTP id 23so2020602gxk.28
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:54 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 4/9] mm: use get_page in deactivate_page()
Date: Fri, 19 Aug 2011 00:48:26 -0700
Message-Id: <1313740111-27446-5-git-send-email-walken@google.com>
In-Reply-To: <1313740111-27446-1-git-send-email-walken@google.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

deactivate_page() already holds a reference to the page, so it can
use get_page() instead of get_page_unless_zero().

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/swap.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index ac617dc..11574b1 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -517,6 +517,8 @@ static void drain_cpu_pagevecs(int cpu)
  */
 void deactivate_page(struct page *page)
 {
+	struct pagevec *pvec;
+
 	/*
 	 * In a workload with many unevictable page such as mprotect, unevictable
 	 * page deactivation for accelerating reclaim is pointless.
@@ -524,13 +526,11 @@ void deactivate_page(struct page *page)
 	if (PageUnevictable(page))
 		return;
 
-	if (likely(get_page_unless_zero(page))) {
-		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
-
-		if (!pagevec_add(pvec, page))
-			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
-		put_cpu_var(lru_deactivate_pvecs);
-	}
+	get_page(page);
+	pvec = &get_cpu_var(lru_deactivate_pvecs);
+	if (!pagevec_add(pvec, page))
+		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+	put_cpu_var(lru_deactivate_pvecs);
 }
 
 void lru_add_drain(void)
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
