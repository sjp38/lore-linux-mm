Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id CAADB6B00FA
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 18:26:57 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so8250313pbc.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 15:26:57 -0800 (PST)
Date: Mon, 20 Feb 2012 15:26:27 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/10] mm/memcg: per-memcg per-zone lru locking
Message-ID: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Here is my per-memcg per-zone LRU locking series, as promised last year.

zone->lru_lock is a heavily contended lock, and we expect that splitting
it across memcgs will show benefit on systems with many cpus.  Sorry, no
performance numbers included yet (I did try yesterday, but my own machines
are too small to show any advantage - it'll be a shame if the same proves
so for large ones!); but otherwise tested and ready.

Konstantin Khlebnikov posted RFC for a competing series a few days ago:
[PATCH RFC 00/15] mm: memory book keeping and lru_lock splitting
https://lkml.org/lkml/2012/2/15/445
and then today
[PATCH v2 00/22] mm: lru_lock splitting
https://lkml.org/lkml/2012/2/20/252

I haven't glanced at v2 yet, but judging by a quick look at the RFC:
the two series have lots of overlap and much in common, so I'd better
post this now before the numbers, to help us exchange ideas.  If you
choose to use either series, we shall probably want to add in pieces
from the other.

There should be a further patch, to update references to zone->lru_lock
in comments and Documentation; but that's just a distraction at the
moment, better held over until our final direction is decided.

These patches are based upon what I expect in the next linux-next with
an update from akpm: perhaps 3.3.0-rc4-next-20120222, or maybe later.
They were prepared on 3.3.0-rc3-next-20120217 plus recent mm-commits:

memcg-remove-export_symbolmem_cgroup_update_page_stat.patch
memcg-simplify-move_account-check.patch
memcg-simplify-move_account-check-fix.patch
memcg-remove-pcg_move_lock-flag-from-page_cgroup.patch
memcg-use-new-logic-for-page-stat-accounting.patch
memcg-use-new-logic-for-page-stat-accounting-fix.patch
memcg-remove-pcg_file_mapped.patch
memcg-fix-performance-of-mem_cgroup_begin_update_page_stat.patch
memcg-fix-performance-of-mem_cgroup_begin_update_page_stat-fix.patch
mm-memcontrolc-s-stealed-stolen.patch

mm-vmscan-handle-isolated-pages-with-lru-lock-released.patch
mm-vmscan-forcibly-scan-highmem-if-there-are-too-many-buffer_heads-pinning-highmem-fix.patch
mm-vmscan-forcibly-scan-highmem-if-there-are-too-many-buffer_heads-pinning-highmem-fix-fix.patch

But it looks like there are no clashes with the first ten of those,
the last three little rearrangements in vmscan.c should be enough.
I see Konstantin has based his v2 off 3.3.0-rc3-next-20120210: that
should be good for mine too, if you add the last three commits on first.

Per-memcg per-zone LRU locking series:

 1/10 mm/memcg: scanning_global_lru means mem_cgroup_disabled
 2/10 mm/memcg: move reclaim_stat into lruvec
 3/10 mm/memcg: add zone pointer into lruvec
 4/10 mm/memcg: apply add/del_page to lruvec
 5/10 mm/memcg: introduce page_relock_lruvec
 6/10 mm/memcg: take care over pc->mem_cgroup
 7/10 mm/memcg: remove mem_cgroup_reset_owner
 8/10 mm/memcg: nest lru_lock inside page_cgroup lock
 9/10 mm/memcg: move lru_lock into lruvec
10/10 mm/memcg: per-memcg per-zone lru locking

 include/linux/memcontrol.h |   67 +----
 include/linux/mm_inline.h  |   20 -
 include/linux/mmzone.h     |   33 +-
 include/linux/swap.h       |   68 +++++
 mm/compaction.c            |   64 +++--
 mm/huge_memory.c           |   13 -
 mm/ksm.c                   |   11 
 mm/memcontrol.c            |  402 +++++++++++++++++------------------
 mm/migrate.c               |    2 
 mm/page_alloc.c            |   11 
 mm/swap.c                  |  138 ++++--------
 mm/swap_state.c            |   10 
 mm/vmscan.c                |  396 +++++++++++++++++-----------------
 13 files changed, 605 insertions(+), 630 deletions(-)

Next step: I shall be looking at and trying Konstantin's,
and I hope he can look at and try mine.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
