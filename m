Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id CAF1082F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 02:28:50 -0400 (EDT)
Received: by pasz6 with SMTP id z6so20612182pas.2
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 23:28:50 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id fl9si139029pab.122.2015.10.18.23.28.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 Oct 2015 23:28:41 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 3/5] mm: clear PG_dirty to mark page freeable
Date: Mon, 19 Oct 2015 15:31:45 +0900
Message-Id: <1445236307-895-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1445236307-895-1-git-send-email-minchan@kernel.org>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

Basically, MADV_FREE relies on dirty bit in page table entry
to decide whether VM allows to discard the page or not.
IOW, if page table entry includes marked dirty bit, VM shouldn't
discard the page.

However, as a example, if swap-in by read fault happens,
page table entry doesn't have dirty bit so MADV_FREE could discard
the page wrongly.

For avoiding the problem, MADV_FREE did more checks with PageDirty
and PageSwapCache. It worked out because swapped-in page lives on
swap cache and since it is evicted from the swap cache, the page has
PG_dirty flag. So both page flags check effectively prevent
wrong discarding by MADV_FREE.

However, a problem in above logic is that swapped-in page has
PG_dirty still after they are removed from swap cache so VM cannot
consider the page as freeable any more even if madvise_free is
called in future.

Look at below example for detail.

    ptr = malloc();
    memset(ptr);
    ..
    ..
    .. heavy memory pressure so all of pages are swapped out
    ..
    ..
    var = *ptr; -> a page swapped-in and could be removed from
                   swapcache. Then, page table doesn't mark
                   dirty bit and page descriptor includes PG_dirty
    ..
    ..
    madvise_free(ptr); -> It doesn't clear PG_dirty of the page.
    ..
    ..
    ..
    .. heavy memory pressure again.
    .. In this time, VM cannot discard the page because the page
    .. has *PG_dirty*

To solve the problem, this patch clears PG_dirty if only the page
is owned exclusively by current process when madvise is called
because PG_dirty represents ptes's dirtiness in several processes
so we could clear it only if we own it exclusively.

Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index fdfb14a78c60..5db546431285 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -312,11 +312,19 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 		if (!page)
 			continue;
 
-		if (PageSwapCache(page)) {
+		if (PageSwapCache(page) || PageDirty(page)) {
 			if (!trylock_page(page))
 				continue;
+			/*
+			 * If page is shared with others, we couldn't clear
+			 * PG_dirty of the page.
+			 */
+			if (page_count(page) != 1 + !!PageSwapCache(page)) {
+				unlock_page(page);
+				continue;
+			}
 
-			if (!try_to_free_swap(page)) {
+			if (PageSwapCache(page) && !try_to_free_swap(page)) {
 				unlock_page(page);
 				continue;
 			}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
