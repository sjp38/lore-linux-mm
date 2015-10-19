Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2A60F82F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 02:28:42 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so181336538pab.0
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 23:28:41 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id yb1si50255160pab.179.2015.10.18.23.28.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 Oct 2015 23:28:41 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 0/5] MADV_FREE refactoring and fix KSM page
Date: Mon, 19 Oct 2015 15:31:42 +0900
Message-Id: <1445236307-895-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

Hello, it's too late since I sent previos patch.
https://lkml.org/lkml/2015/6/3/37

This patch is alomost new compared to previos approach.
I think this is more simple, clear and easy to review.

One thing I should notice is that I have tested this patch
and couldn't find any critical problem so I rebased patchset
onto recent mmotm(ie, mmotm-2015-10-15-15-20) to send formal
patchset. Unfortunately, I start to see sudden discarding of
the page we shouldn't do. IOW, application's valid anonymous page
was disappeared suddenly.

When I look through THP changes, I think we could lose
dirty bit of pte between freeze_page and unfreeze_page
when we mark it as migration entry and restore it.
So, I added below simple code without enough considering
and cannot see the problem any more.
I hope it's good hint to find right fix this problem.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d5ea516ffb54..e881c04f5950 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3138,6 +3138,9 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
 		if (is_write_migration_entry(swp_entry))
 			entry = maybe_mkwrite(entry, vma);
 
+		if (PageDirty(page))
+			SetPageDirty(page);
+
 		flush_dcache_page(page);
 		set_pte_at(vma->vm_mm, address, pte + i, entry);
 

Although it fixes abvove problem, I can encounter below another bug
in several hours.

	BUG: Bad rss-counter state mm:ffff88007fc28000 idx:1 val:439
	BUG: Bad rss-counter state mm:ffff88007fc28000 idx:2 val:73

Or

	BUG: Bad rss-counter state mm:ffff88007fc28000 idx:1 val:512

It seems we are zapping THP page without decreasing MM_ANONPAGES
and MM_SWAPENTS. Of course, it could be a bug of MADV_FREE and
recent changes of THP reveals it. What I can say is I couldn't see
any problem until mmotm-2015-10-06-16-30 so I guess there is some
conflict with THP-refcount redesign of Kirill or it makes to reveal
MADV_FREE's hidden bug.

I will hunt it down but I hope Kirill might catch it up earlier than me.

Major thing with this patch is two things.

1. Work with MADV_FREE on PG_dirty page.

So far, MADV_FREE doesn't work with page which is not in swap cache
but has PG_dirty(ex, swapped-in page). Details are in [3/5].

2. Make MADV_FREE discard path simple

Current logic for discarding hinted page is really mess
so [4/5] makes it simple and clean.

3. Fix with KSM page

A process can have KSM page which is no dirty bit in page table
entry and no PG_dirty in page->flags so VM could discard it wrongly.
[5/5] fixes it.

Minchan Kim (5):
  [1/5] mm: MADV_FREE trivial clean up
  [2/5] mm: skip huge zero page in MADV_FREE
  [3/5] mm: clear PG_dirty to mark page freeable
  [4/5] mm: simplify reclaim path for MADV_FREE
  [5/5] mm: mark stable page dirty in KSM

 include/linux/rmap.h |  6 +----
 mm/huge_memory.c     |  9 ++++----
 mm/ksm.c             | 12 ++++++++++
 mm/madvise.c         | 29 +++++++++++-------------
 mm/rmap.c            | 46 +++++++------------------------------
 mm/swap_state.c      |  5 ++--
 mm/vmscan.c          | 64 ++++++++++++++++------------------------------------
 7 files changed, 60 insertions(+), 111 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
