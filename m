Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 006CB8D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 21:42:54 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8F2DB3EE0B3
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:42:52 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D77245DE58
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:42:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C27E45DE55
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:42:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 18C16E18003
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:42:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B684EE08002
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:42:51 +0900 (JST)
Date: Tue, 18 Jan 2011 11:36:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/4] memcg: modify accounting function for supporting THP
 better
Message-Id: <20110118113657.9bed0165.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110118113528.fd24928f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110118113528.fd24928f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

mem_cgroup_charge_statisics() was designed for charging a page but
now, we have transparent hugepage. To fix problems (in following patch)
it's required to change the function to get the number of pages
as its arguments.

The new function gets following as argument.
  - type of page rather than 'pc'
  - size of page which is accounted.

Changelog:
 - use usual variable names for args.
 - removed unnecessary variable.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

Index: mmotm-0107/mm/memcontrol.c
===================================================================
--- mmotm-0107.orig/mm/memcontrol.c
+++ mmotm-0107/mm/memcontrol.c
@@ -600,23 +600,22 @@ static void mem_cgroup_swap_statistics(s
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
-					 struct page_cgroup *pc,
-					 bool charge)
+					 bool file, int nr_pages)
 {
-	int val = (charge) ? 1 : -1;
-
 	preempt_disable();
 
-	if (PageCgroupCache(pc))
-		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_CACHE], val);
+	if (file)
+		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_CACHE], nr_pages);
 	else
-		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_RSS], val);
+		__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_RSS], nr_pages);
 
-	if (charge)
+	/* pagein of a big page is an event. So, ignore page size */
+	if (nr_pages > 0)
 		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
 	else
 		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
-	__this_cpu_inc(mem->stat->count[MEM_CGROUP_EVENTS]);
+
+	__this_cpu_add(mem->stat->count[MEM_CGROUP_EVENTS], nr_pages);
 
 	preempt_enable();
 }
@@ -2115,7 +2114,7 @@ static void ____mem_cgroup_commit_charge
 		break;
 	}
 
-	mem_cgroup_charge_statistics(mem, pc, true);
+	mem_cgroup_charge_statistics(mem, PageCgroupCache(pc), 1);
 }
 
 static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
@@ -2186,14 +2185,14 @@ static void __mem_cgroup_move_account(st
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
@@ -2597,7 +2596,7 @@ __mem_cgroup_uncharge_common(struct page
 	}
 
 	for (i = 0; i < count; i++)
-		mem_cgroup_charge_statistics(mem, pc + i, false);
+		mem_cgroup_charge_statistics(mem, PageCgroupCache(pc), -1);
 
 	ClearPageCgroupUsed(pc);
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
