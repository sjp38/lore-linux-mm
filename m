Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 73A726B025F
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 13:26:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y29so18963084pff.6
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 10:26:31 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q90si5943098pfk.278.2017.09.26.10.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 10:26:30 -0700 (PDT)
From: Shaohua Li <shli@kernel.org>
Subject: [PATCH V3 1/2] mm: avoid marking swap cached page as lazyfree
Date: Tue, 26 Sep 2017 10:26:25 -0700
Message-Id: <6537ef3814398c0073630b03f176263bc81f0902.1506446061.git.shli@fb.com>
In-Reply-To: <cover.1506446061.git.shli@fb.com>
References: <cover.1506446061.git.shli@fb.com>
In-Reply-To: <cover.1506446061.git.shli@fb.com>
References: <cover.1506446061.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: asavkov@redhat.com, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

From: Shaohua Li <shli@fb.com>

MADV_FREE clears pte dirty bit and then marks the page lazyfree (clear
SwapBacked). There is no lock to prevent the page is added to swap cache
between these two steps by page reclaim. Page reclaim could add the page
to swap cache and unmap the page. After page reclaim, the page is added
back to lru. At that time, we probably start draining per-cpu pagevec
and mark the page lazyfree. So the page could be in a state with
SwapBacked cleared and PG_swapcache set. Next time there is a refault in
the virtual address, do_swap_page can find the page from swap cache but
the page has PageSwapCache false because SwapBacked isn't set, so
do_swap_page will bail out and do nothing. The task will keep running
into fault handler.

Reported-and-tested-by: Artem Savkov <asavkov@redhat.com>
Fix: 802a3a92ad7a(mm: reclaim MADV_FREE pages)
Signed-off-by: Shaohua Li <shli@fb.com>
Cc: stable@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/swap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 9295ae9..a77d68f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -575,7 +575,7 @@ static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
 			    void *arg)
 {
 	if (PageLRU(page) && PageAnon(page) && PageSwapBacked(page) &&
-	    !PageUnevictable(page)) {
+	    !PageSwapCache(page) && !PageUnevictable(page)) {
 		bool active = PageActive(page);
 
 		del_page_from_lru_list(page, lruvec,
@@ -665,7 +665,7 @@ void deactivate_file_page(struct page *page)
 void mark_page_lazyfree(struct page *page)
 {
 	if (PageLRU(page) && PageAnon(page) && PageSwapBacked(page) &&
-	    !PageUnevictable(page)) {
+	    !PageSwapCache(page) && !PageUnevictable(page)) {
 		struct pagevec *pvec = &get_cpu_var(lru_lazyfree_pvecs);
 
 		get_page(page);
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
