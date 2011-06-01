Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id BA6C46B0027
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 02:25:50 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/8] mm: memcg naturalization -rc2
Date: Wed,  1 Jun 2011 08:25:11 +0200
Message-Id: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

this is the second version of the memcg naturalization series.  The
notable changes since the first submission are:

    o the hierarchy walk is now intermittent and will abort and
      remember the last scanned child after sc->nr_to_reclaim pages
      have been reclaimed during the walk in one zone (Rik)

    o the global lru lists are never scanned when memcg is enabled
      after #2 'memcg-aware global reclaim', which makes this patch
      self-sufficient and complete without requiring the per-memcg lru
      lists to be exclusive (Michal)

    o renamed sc->memcg and sc->current_memcg to sc->target_mem_cgroup
      and sc->mem_cgroup and fixed their documentation, I hope this is
      better understandable now (Rik)

    o the reclaim statistic counters have been renamed.  there is no
      more distinction between 'pgfree' and 'pgsteal', it is now
      'pgreclaim' in both cases; 'kswapd' has been replaced by
      'background'

    o fixed a nasty crash in the hierarchical soft limit check that
      happened during global reclaim in memcgs that are hierarchical
      but have no hierarchical parents themselves

    o properly implemented the memcg-aware unevictable page rescue
      scanner, there were several blatant bugs in there

    o documentation on new public interfaces

Thanks for your input on the first version.

I ran microbenchmarks (sparse file catting, essentially) to stress
reclaim and LRU operations.  There is no measurable overhead for
!CONFIG_MEMCG, memcg disabled during boot, memcg enabled but no
configured groups, and hard limit reclaim.

I also ran single-threaded kernbenchs in four unlimited memcgs in
parallel, contained in a hard-limited hierarchical parent that put
constant pressure on the workload.  There is no measurable difference
in runtime, the pgpgin/pgpgout counters, and fairness among memcgs in
this test compared to an unpatched kernel.  Needs more evaluation,
especially with a higher number of memcgs.

The soft limit changes are also proven to work in so far that it is
possible to prioritize between children in a hierarchy under pressure
and that runtime differences corresponded directly to the soft limit
settings in the previously described kernbench setup with staggered
soft limits on the groups, but this needs quantification.

Based on v2.6.39.

 include/linux/memcontrol.h  |   91 +++--
 include/linux/mm_inline.h   |   14 +-
 include/linux/mmzone.h      |   10 +-
 include/linux/page_cgroup.h |   36 --
 include/linux/swap.h        |    4 -
 mm/memcontrol.c             |  889 ++++++++++++++-----------------------------
 mm/page_alloc.c             |    2 +-
 mm/page_cgroup.c            |   38 +--
 mm/swap.c                   |   20 +-
 mm/vmscan.c                 |  296 ++++++++-------
 10 files changed, 536 insertions(+), 864 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
