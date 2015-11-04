Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id BA4606B0256
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 20:26:19 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so10742240pac.3
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 17:26:19 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id go6si39053052pbc.166.2015.11.03.17.26.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Nov 2015 17:26:13 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 06/13] mm: clear PG_dirty to mark page freeable
Date: Wed,  4 Nov 2015 10:26:00 +0900
Message-Id: <1446600367-7976-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1446600367-7976-1-git-send-email-minchan@kernel.org>
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>

Basically, MADV_FREE relies on dirty bit in page table entry to decide
whether VM allows to discard the page or not.  IOW, if page table entry
includes marked dirty bit, VM shouldn't discard the page.

However, as a example, if swap-in by read fault happens, page table entry
doesn't have dirty bit so MADV_FREE could discard the page wrongly.

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

To solve the problem, this patch clears PG_dirty if only the page is owned
exclusively by current process when madvise is called because PG_dirty
represents ptes's dirtiness in several processes so we could clear it only
if we own it exclusively.

Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 3462a3ca9690..4e67ba0b1104 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -304,11 +304,19 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
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
