Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 52DC4900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 02:15:49 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so108899pdj.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 23:15:49 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ms6si30062227pdb.76.2015.06.02.23.15.47
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 23:15:48 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 0/6] MADV_FREE: respect pte_dirty, not PG_dirty.
Date: Wed,  3 Jun 2015 15:15:39 +0900
Message-Id: <1433312145-19386-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

MADV_FREE relies on the dirty bit in page table entry to decide
whether VM allows to discard the page or not.
IOW, if page table entry includes marked dirty bit, VM shouldn't
discard the page.

However, as one of exmaple, if swap-in by read fault happens,
page table entry point out the page doesn't have marked dirty bit
so MADV_FREE might discard the page wrongly.

For avoiding the problem, MADV_FREE did more checks with PageDirty
and PageSwapCache. It worked out because swapped-in page lives
on swap cache and since it was evicted from the swap cache,
the page has PG_dirty flag. So both page flags checks effectively
prevent wrong discarding by MADV_FREE.

A problem in above logic is that swapped-in page has PG_dirty
since they are removed from swap cache so VM cannot consider
those pages as freeable any more alghouth madvise_free is
called in future. Look at below example for detail.

ptr = malloc();
memset(ptr);
..
..
.. heavy memory pressure so all of pages are swapped out
..
..
var = *ptr; -> a page swapped-in and removed from swapcache.
               page table doesn't mark dirty bit and page
               descriptor includes PG_dirty
..
..
madvise_free(ptr);
..
..
..
.. heavy memory pressure again.
.. In this time, VM cannot discard the page because the page
.. has *PG_dirty*

Rather than relying on the PG_dirty of page descriptor for
preventing discarding a page, dirty bit in page table is more
straightforward and simple.

So, this patch try to make page table entry's dirty bit mark so
it doesn't need to take care of PG_dirty.
For it, it fixes several cases(e.g, KSM, migration, swapin, swapoff)
then, finally it makes MADV_FREE simple.

With this, it removes complicated logic and makes freeable page
checking by madvise_free simple.(ie, +90/-108).
Of course, we could solve above mentioned PG_Dirty problem.

I tested this patchset(memcg, tmpfs, swapon/off, THP, KSM) and
found no problem but it still needs careful review.

Minchan Kim (6):
  mm: keep dirty bit on KSM page
  mm: keep dirty bit on anonymous page migration
  mm: mark dirty bit on swapped-in page
  mm: mark dirty bit on unuse_pte
  mm: decouple PG_dirty from MADV_FREE
  mm: MADV_FREE refactoring

 include/linux/rmap.h |  9 ++----
 mm/ksm.c             | 19 ++++++++++---
 mm/madvise.c         | 13 ---------
 mm/memory.c          |  6 ++--
 mm/migrate.c         |  4 +++
 mm/rmap.c            | 78 +++++++++++++++++++++++++---------------------------
 mm/swapfile.c        |  6 +++-
 mm/vmscan.c          | 63 ++++++++++++++----------------------------
 8 files changed, 90 insertions(+), 108 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
