Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B07AD82F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 03:01:27 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so59554321pad.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 00:01:27 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id yi8si8653039pac.186.2015.10.30.00.01.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Oct 2015 00:01:23 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 6/8] mm: lru_deactivate_fn should clear PG_referenced
Date: Fri, 30 Oct 2015 16:01:42 +0900
Message-Id: <1446188504-28023-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1446188504-28023-1-git-send-email-minchan@kernel.org>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>

deactivate_page aims for accelerate for reclaiming through
moving pages from active list to inactive list so we should
clear PG_referenced for the goal.

Acked-by: Hugh Dickins <hughd@google.com>
Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/swap.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/swap.c b/mm/swap.c
index d0eacc5f62a3..4a6aec976ab1 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -810,6 +810,7 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
 
 		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
 		ClearPageActive(page);
+		ClearPageReferenced(page);
 		add_page_to_lru_list(page, lruvec, lru);
 
 		__count_vm_event(PGDEACTIVATE);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
