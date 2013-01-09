Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 6B9B16B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 01:21:19 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/2] mm: prevent to add a page to swap if may_writepage is unset
Date: Wed,  9 Jan 2013 15:21:13 +0900
Message-Id: <1357712474-27595-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1357712474-27595-1-git-send-email-minchan@kernel.org>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>

Recently, Luigi reported there are lots of free swap space when
OOM happens. It's easily reproduced on zram-over-swap, where
many instance of memory hogs are running and laptop_mode is enabled.

Luigi reported there was no problem when he disabled laptop_mode.
The problem when I investigate problem is following as.

try_to_free_pages disable may_writepage if laptop_mode is enabled.
shrink_page_list adds lots of anon pages in swap cache by
add_to_swap, which makes pages Dirty and rotate them to head of
inactive LRU without pageout. If it is repeated, inactive anon LRU
is full of Dirty and SwapCache pages.

In case of that, isolate_lru_pages fails because it try to isolate
clean page due to may_writepage == 0.

The may_writepage could be 1 only if total_scanned is higher than
writeback_threshold in do_try_to_free_pages but unfortunately,
VM can't isolate anon pages from inactive anon lru list by
above reason and we already reclaimed all file-backed pages.
So it ends up OOM killing.

This patch prevents to add a page to swap cache unnecessary when
may_writepage is unset so anoymous lru list isn't full of
Dirty/Swapcache page. So VM can isolate pages from anon lru list,
which ends up setting may_writepage to 1 and could swap out
anon lru pages. When OOM triggers, I confirmed swap space was full.

Reported-by: Luigi Semenzato <semenzato@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ff869d2..439cc47 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -780,6 +780,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (PageAnon(page) && !PageSwapCache(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
+			if (!sc->may_writepage)
+				goto keep_locked;
 			if (!add_to_swap(page))
 				goto activate_locked;
 			may_enter_fs = 1;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
