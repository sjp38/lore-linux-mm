Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DBD116B004A
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 17:15:07 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/4] memcg: use native word to represent dirtyable pages
Date: Sun,  7 Nov 2010 23:14:36 +0100
Message-Id: <20101107220353.115646194@cmpxchg.org>
In-Reply-To: <20101107215030.007259800@cmpxchg.org>
References: <20101107215030.007259800@cmpxchg.org>
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com> <20101106010357.GD23393@cmpxchg.org> <AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com> <20101107215030.007259800@cmpxchg.org>
Content-Disposition: inline; filename=memcg-use-native-word-to-represent-dirtyable-pages.patch
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The memory cgroup dirty info calculation currently uses a signed
64-bit type to represent the amount of dirtyable memory in pages.

This can instead be changed to an unsigned word, which will allow the
formula to function correctly with up to 160G of LRU pages on a 32-bit
system, assuming 4k pages.  That should be plenty even when taking
racy folding of the per-cpu counters into account.

This fixes a compilation error on 32-bit systems as this code tries to
do 64-bit division.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reported-by: Dave Young <hidave.darkstar@gmail.com>
---
 mm/memcontrol.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1222,9 +1222,10 @@ static void __mem_cgroup_dirty_param(str
 bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
 			   struct dirty_info *info)
 {
-	s64 available_mem;
 	struct vm_dirty_param dirty_param;
+	unsigned long available_mem;
 	struct mem_cgroup *memcg;
+	s64 value;
 
 	if (mem_cgroup_disabled())
 		return false;
@@ -1238,11 +1239,11 @@ bool mem_cgroup_dirty_info(unsigned long
 	__mem_cgroup_dirty_param(&dirty_param, memcg);
 	rcu_read_unlock();
 
-	available_mem = mem_cgroup_page_stat(MEMCG_NR_DIRTYABLE_PAGES);
-	if (available_mem < 0)
+	value = mem_cgroup_page_stat(MEMCG_NR_DIRTYABLE_PAGES);
+	if (value < 0)
 		return false;
 
-	available_mem = min((unsigned long)available_mem, sys_available_mem);
+	available_mem = min((unsigned long)value, sys_available_mem);
 
 	if (dirty_param.dirty_bytes)
 		info->dirty_thresh =


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
