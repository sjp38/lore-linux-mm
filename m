Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CAFA76B01BB
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 02:47:08 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2O6l69P012771
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Mar 2010 15:47:06 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C16C945DE53
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 15:47:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 89E5145DE50
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 15:47:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5938DE38001
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 15:47:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A1311DB8049
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 15:47:05 +0900 (JST)
Date: Wed, 24 Mar 2010 15:43:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] fix race in file_mapped accounting in memcg
Message-Id: <20100324154324.6d27336e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, arighi@develer.com
List-ID: <linux-mm.kvack.org>

A fix for race in file_mapped statistics. I noticed this race while discussing
Andrea's dirty accounting patch series. 
At the end of discusstion, I said "please don't touch file mapped". So, this bugfix
should be posted as an independent patch.
Tested on the latest mmotm.

Thanks,
-Kame

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, memcg's FILE_MAPPED accounting has following race with
move_account (happens at rmdir()).

    increment page->mapcount (rmap.c)
    mem_cgroup_update_file_mapped()           move_account()
					      lock_page_cgroup()
					      check page_mapped() if
					      page_mapped(page)>1 {
						FILE_MAPPED -1 from old memcg
						FILE_MAPPED +1 to old memcg
					      }
					      .....
					      overwrite pc->mem_cgroup
					      unlock_page_cgroup()
    lock_page_cgroup()
    FILE_MAPPED + 1 to pc->mem_cgroup
    unlock_page_cgroup()

Then,
	old memcg (-1 file mapped)
	new memcg (+2 file mapped)


This happens because move_account see page_mapped() which is not guarded by
lock_page_cgroup(). This patch adds FILE_MAPPED flag to page_cgroup and
move account information based on it. Now, all checks are synchronous with
lock_page_cgroup().


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |    6 ++++++
 mm/memcontrol.c             |   18 +++++++++---------
 2 files changed, 15 insertions(+), 9 deletions(-)

Index: mmotm-2.6.34-Mar23/include/linux/page_cgroup.h
===================================================================
--- mmotm-2.6.34-Mar23.orig/include/linux/page_cgroup.h
+++ mmotm-2.6.34-Mar23/include/linux/page_cgroup.h
@@ -39,6 +39,7 @@ enum {
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
 	PCG_ACCT_LRU, /* page has been accounted for */
+	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
 };
 
 #define TESTPCGFLAG(uname, lname)			\
@@ -73,6 +74,11 @@ CLEARPCGFLAG(AcctLRU, ACCT_LRU)
 TESTPCGFLAG(AcctLRU, ACCT_LRU)
 TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
 
+
+SETPCGFLAG(FileMapped, FILE_MAPPED)
+CLEARPCGFLAG(FileMapped, FILE_MAPPED)
+TESTPCGFLAG(FileMapped, FILE_MAPPED)
+
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);
Index: mmotm-2.6.34-Mar23/mm/memcontrol.c
===================================================================
--- mmotm-2.6.34-Mar23.orig/mm/memcontrol.c
+++ mmotm-2.6.34-Mar23/mm/memcontrol.c
@@ -1430,16 +1430,19 @@ void mem_cgroup_update_file_mapped(struc
 
 	lock_page_cgroup(pc);
 	mem = pc->mem_cgroup;
-	if (!mem)
-		goto done;
-
-	if (!PageCgroupUsed(pc))
+	if (!mem || !PageCgroupUsed(pc))
 		goto done;
 
 	/*
 	 * Preemption is already disabled. We can use __this_cpu_xxx
 	 */
-	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
+	if (val > 0) {
+		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		SetPageCgroupFileMapped(pc);
+	} else {
+		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		ClearPageCgroupFileMapped(pc);
+	}
 
 done:
 	unlock_page_cgroup(pc);
@@ -1872,16 +1875,13 @@ static void __mem_cgroup_commit_charge(s
 static void __mem_cgroup_move_account(struct page_cgroup *pc,
 	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
 {
-	struct page *page;
-
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
 	VM_BUG_ON(!PageCgroupLocked(pc));
 	VM_BUG_ON(!PageCgroupUsed(pc));
 	VM_BUG_ON(pc->mem_cgroup != from);
 
-	page = pc->page;
-	if (page_mapped(page) && !PageAnon(page)) {
+	if (PageCgroupFileMapped(pc)) {
 		/* Update mapped_file data for mem_cgroup */
 		preempt_disable();
 		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
