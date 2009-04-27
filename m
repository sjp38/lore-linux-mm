Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D9B366B004D
	for <linux-mm@kvack.org>; Sun, 26 Apr 2009 20:54:22 -0400 (EDT)
Date: Mon, 27 Apr 2009 09:51:00 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [BUGFIX][PATCH] memcg: fix try_get_mem_cgroup_from_swapcache()
Message-Id: <20090427095100.29173bc1.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090426231752.36498c90.d-nishimura@mtf.biglobe.ne.jp>
References: <20090426231752.36498c90.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@in.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

memcg: fix try_get_mem_cgroup_from_swapcache()

This is a bugfix for commit 3c776e64660028236313f0e54f3a9945764422df(included 2.6.30-rc1).
Used bit of swapcache is solid under page lock, but considering move_account,
pc->mem_cgroup is not.

We need lock_page_cgroup() anyway.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ccc69b4..84f856c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1024,9 +1024,7 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
 		return NULL;
 
 	pc = lookup_page_cgroup(page);
-	/*
-	 * Used bit of swapcache is solid under page lock.
-	 */
+	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		if (mem && !css_tryget(&mem->css))
@@ -1040,6 +1038,7 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
 			mem = NULL;
 		rcu_read_unlock();
 	}
+	unlock_page_cgroup(pc);
 	return mem;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
