Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB6E6B00DD
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 04:24:47 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 0/6] *** memcg: make throttle_vm_writeout() cgroup aware ***
Date: Tue,  9 Nov 2010 01:24:25 -0800
Message-Id: <1289294671-6865-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

This series aims to:
- Make throttle_vm_writeout() cgroup aware.  Prior to this patch, cgroup reclaim
  would consider global dirty limits when deciding to throttle.  Now cgroup
  limits are used if the cgroup being reclaimed has dirty limits.

- Part of making throttle_vm_writeout() cgroup aware involves fixing a negative
  value signaling error in mem_cgroup_page_stat().  Previously,
  mem_cgroup_page_stat() could falsely return a negative value if a per-cpu
  counter sum was negative.  Calling routines considered negative a special
  "cgroup does not have limits" value.

Greg Thelen (6):
  memcg: add mem_cgroup parameter to mem_cgroup_page_stat()
  memcg: pass mem_cgroup to mem_cgroup_dirty_info()
  memcg: make throttle_vm_writeout() memcg aware
  memcg: simplify mem_cgroup_page_stat()
  memcg: simplify mem_cgroup_dirty_info()
  memcg: make mem_cgroup_page_stat() return value unsigned

 include/linux/memcontrol.h |    8 +++-
 include/linux/writeback.h  |    2 +-
 mm/memcontrol.c            |   92 ++++++++++++++++++++++---------------------
 mm/page-writeback.c        |   40 ++++++++++---------
 mm/vmscan.c                |    2 +-
 5 files changed, 77 insertions(+), 67 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
