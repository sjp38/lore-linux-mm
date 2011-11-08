Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0C90B6B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 16:25:21 -0500 (EST)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 00/10] memcg naturalization -rc5
Date: Tue,  8 Nov 2011 22:23:18 +0100
Message-Id: <1320787408-22866-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is version 5 of the memcg naturalization patches.

They enable traditional page reclaim to find pages from the per-memcg
LRU lists, thereby getting rid of the double-LRU scheme (per global
zone in addition to per memcg-zone) and the required extra list head
per each page in the system.

The only change from version 4 is using the name `memcg' instead of
`mem' for memcg pointers in code added in the series.

This series is based on v3.2-rc1.

memcg users and distributions are waiting for this because of the
memory savings.  The changes for regular users that do not create
memcgs in addition to the root memcg are minimal, and even smaller for
users that disable the memcg feature at compile time.  Lastly, ongoing
memcg development, like the breaking up of zone->lru_lock, fixing the
soft limit implementation/memory guarantees and per-memcg reclaim
statistics, is already based on this.

Thanks!

 include/linux/memcontrol.h  |   73 +++--
 include/linux/mm_inline.h   |   21 +-
 include/linux/mmzone.h      |   10 +-
 include/linux/page_cgroup.h |   34 ---
 mm/memcontrol.c             |  693 ++++++++++++++++++++-----------------------
 mm/page_alloc.c             |    2 +-
 mm/page_cgroup.c            |   58 +----
 mm/swap.c                   |   24 +-
 mm/vmscan.c                 |  389 +++++++++++++++----------
 9 files changed, 643 insertions(+), 661 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
