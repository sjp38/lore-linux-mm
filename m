Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 6B1B66B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:51:42 -0500 (EST)
Received: by bkty12 with SMTP id y12so1365307bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 05:51:40 -0800 (PST)
Subject: [PATCH v3 00/21] mm: lru_lock splitting
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 23 Feb 2012 17:51:36 +0400
Message-ID: <20120223133728.12988.5432.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>

v3 changes:
* inactive-ratio reworked again, now it always calculated from from scratch
* hierarchical pte reference bits filter in memory-cgroup reclaimer
* fixed two bugs in locking, found by Hugh Dickins
* locking functions slightly simplified
* new patch for isolated pages accounting
* new patch with lru interleaving

This patchset is based on next-20120210

git: https://github.com/koct9i/linux/commits/lruvec-v3

---

Konstantin Khlebnikov (21):
      memcg: unify inactive_ratio calculation
      memcg: make mm_match_cgroup() hirarchical
      memcg: fix page_referencies cgroup filter on global reclaim
      memcg: use vm_swappiness from target memory cgroup
      mm: rename lruvec->lists into lruvec->pages_lru
      mm: lruvec linking functions
      mm: add lruvec->pages_count
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
      mm: add to lruvec isolated pages counters
      memcg: check lru vectors emptiness in pre-destroy
      mm: split zone->lru_lock
      mm: zone lru vectors interleaving


 include/linux/huge_mm.h    |    3 
 include/linux/memcontrol.h |   75 ------
 include/linux/mm.h         |   66 +++++
 include/linux/mm_inline.h  |   19 +-
 include/linux/mmzone.h     |   39 ++-
 include/linux/swap.h       |    6 
 mm/Kconfig                 |   16 +
 mm/compaction.c            |   31 +--
 mm/huge_memory.c           |   14 +
 mm/internal.h              |  204 +++++++++++++++++
 mm/ksm.c                   |    2 
 mm/memcontrol.c            |  343 +++++++++++-----------------
 mm/migrate.c               |    2 
 mm/page_alloc.c            |   70 +-----
 mm/rmap.c                  |    2 
 mm/swap.c                  |  217 ++++++++++--------
 mm/vmscan.c                |  534 ++++++++++++++++++++++++--------------------
 mm/vmstat.c                |    6 
 18 files changed, 932 insertions(+), 717 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
