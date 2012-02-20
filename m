Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 069A86B004D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:22:39 -0500 (EST)
Received: by bkty12 with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:22:37 -0800 (PST)
Subject: [PATCH v2 00/22] mm: lru_lock splitting
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:22:35 +0400
Message-ID: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

There complete patch-set with my lru_lock splitting
plus all related preparations and cleanups rebased to next-20120210

git: https://github.com/koct9i/linux/commits/lruvec

main changes:
* rebase
* sed -e 's/book/lruvec/g'
* fixed locking
* some cleaning and reordering

---

Konstantin Khlebnikov (22):
      memcg: rework inactive_ratio logic
      memcg: fix page_referencies cgroup filter on global reclaim
      memcg: use vm_swappiness from current memcg
      mm: drain percpu lru add/rotate page-vectors on cpu hot-unplug
      mm: replace per-cpu lru-add page-vectors with page-lists
      mm: deprecate pagevec lru-add functions
      mm: rename lruvec->lists into lruvec->pages_lru
      mm: add lruvec->pages_count
      mm: link lruvec with zone and node
      mm: unify inactive_list_is_low()
      mm: add lruvec->reclaim_stat
      mm: kill struct mem_cgroup_zone
      mm: move page-to-lruvec translation upper
      mm: push lruvec into update_page_reclaim_stat()
      mm: push lruvecs from pagevec_lru_move_fn() to iterator
      mm: introduce lruvec locking primitives
      mm: handle lruvec relocks on lumpy reclaim
      mm: handle lruvec relocks in compaction
      mm: handle lruvec relock in memory controller
      mm: optimize putback for 0-order reclaim
      mm: free lruvec in memcgroup via rcu
      mm: split zone->lru_lock


 fs/mpage.c                 |   21 +-
 fs/nfs/dir.c               |   10 -
 include/linux/memcontrol.h |   62 -------
 include/linux/mm.h         |   37 ++++
 include/linux/mm_inline.h  |   19 +-
 include/linux/mmzone.h     |   19 +-
 include/linux/pagevec.h    |    4 
 include/linux/swap.h       |    5 -
 mm/compaction.c            |   30 ++-
 mm/huge_memory.c           |   10 +
 mm/internal.h              |  226 +++++++++++++++++++++++++
 mm/memcontrol.c            |  320 ++++++++++++++---------------------
 mm/page_alloc.c            |   19 +-
 mm/readahead.c             |   15 +-
 mm/swap.c                  |  256 ++++++++++++++++------------
 mm/vmscan.c                |  402 +++++++++++++++++++++-----------------------
 16 files changed, 821 insertions(+), 634 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
