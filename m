Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 311F26B0092
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 05:12:42 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 665D43EE0BC
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:12:39 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CA1045DE56
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:12:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 34C9245DE4D
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:12:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 28F91E18001
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:12:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB85B1DB8037
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:12:38 +0900 (JST)
Date: Fri, 14 Jan 2011 19:06:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/4] [BUGFIX] enhance charge_statistics function for
 fixising issues
Message-Id: <20110114190644.a222f60d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, hannes@cmpxchg.org, aarcange@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

mem_cgroup_charge_staistics() was designed for charging a page but
now, we have transparent hugepage. To fix problems (in following patch)
it's required to change the function to get the number of pages
as its arguments.

The new function gets following as argument.
  - type of page rather than 'pc'
  - size of page which is accounted.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   32 +++++++++++++++++++-------------
 1 file changed, 19 insertions(+), 13 deletions(-)

Index: mmotm-0107/mm/memcontrol.c
===================================================================
--- mmotm-0107.orig/mm/memcontrol.c
+++ mmotm-0107/mm/memcontrol.c
@@ -600,23 +600,23 @@ static void mem_cgroup_swap_statistics(s
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
-					 struct page_cgroup *pc,
-					 bool charge)
+					 bool file,
+					 int pages)
 {
-	int val = (charge) ? 1 : -1;
-
 	preempt_disable();
 
-	if (PageCgroupCache(pc))
-		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_CACHE], val);
+	if (file)
+		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_CACHE], pages);
 	else
-		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_RSS], val);
+		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_RSS], pages);
 
-	if (charge)
+	/* pagein of a big page is an event. So, ignore page size */
+	if (pages > 0)
 		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
 	else
 		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
-	__this_cpu_inc(mem->stat->count[MEM_CGROUP_EVENTS]);
+
+	__this_cpu_add(mem->stat->count[MEM_CGROUP_EVENTS], pages);
 
 	preempt_enable();
 }
@@ -2092,6 +2092,7 @@ static void ____mem_cgroup_commit_charge
 					 struct page_cgroup *pc,
 					 enum charge_type ctype)
 {
+	bool file = false;
 	pc->mem_cgroup = mem;
 	/*
 	 * We access a page_cgroup asynchronously without lock_page_cgroup().
@@ -2106,6 +2107,7 @@ static void ____mem_cgroup_commit_charge
 	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
 		SetPageCgroupCache(pc);
 		SetPageCgroupUsed(pc);
+		file = true;
 		break;
 	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
 		ClearPageCgroupCache(pc);
@@ -2115,7 +2117,7 @@ static void ____mem_cgroup_commit_charge
 		break;
 	}
 
-	mem_cgroup_charge_statistics(mem, pc, true);
+	mem_cgroup_charge_statistics(mem, file, 1);
 }
 
 static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
@@ -2186,14 +2188,14 @@ static void __mem_cgroup_move_account(st
 		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		preempt_enable();
 	}
-	mem_cgroup_charge_statistics(from, pc, false);
+	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -1);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
 		mem_cgroup_cancel_charge(from, PAGE_SIZE);
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
-	mem_cgroup_charge_statistics(to, pc, true);
+	mem_cgroup_charge_statistics(to, PageCgroupCache(pc), 1);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
 	 * can be under rmdir(). But in current implementation, caller of
@@ -2551,6 +2553,7 @@ __mem_cgroup_uncharge_common(struct page
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	int page_size = PAGE_SIZE;
+	bool file = false;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -2578,6 +2581,9 @@ __mem_cgroup_uncharge_common(struct page
 	if (!PageCgroupUsed(pc))
 		goto unlock_out;
 
+	if (PageCgroupCache(pc))
+		file = true;
+
 	switch (ctype) {
 	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
 	case MEM_CGROUP_CHARGE_TYPE_DROP:
@@ -2597,7 +2603,7 @@ __mem_cgroup_uncharge_common(struct page
 	}
 
 	for (i = 0; i < count; i++)
-		mem_cgroup_charge_statistics(mem, pc + i, false);
+		mem_cgroup_charge_statistics(mem, file, -1);
 
 	ClearPageCgroupUsed(pc);
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
