Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BF86C6B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 01:42:06 -0400 (EDT)
Date: Fri, 12 Jun 2009 14:33:46 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][BUGFIX] memcg: rmdir doesn't return
Message-Id: <20090612143346.68e1f006.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi.

I found a problem about rmdir: rmdir doesn't return(or take a very very long time).
Actually, I found this problem long ago, but I've not had enough time to
track it down until the stale swap cache problem has been fixed.

The cause of this problem is the commit ec64f51545fffbc4cb968f0cea56341a4b07e85a
(cgroup: fix frequent -EBUSY at rmdir) and memcg's behavior about swap-in.

The commit introduced cgroup_rmdir_waitq and make rmdir wait until someone
(who will decrement css->refcnt to 1) wake it up.
But even after we have succeeded pre_destroy, which means mem.usage has
become 0, a process which has moved to another cgroup from the cgroup being removed
can increment mem.usage(and css->refcnt as a result) by doing swap-in.
This css->refcnt won't be dropped, that is the rmdir process won't be woken up,
until the owner process frees the page.

So, just "waking up after a while" by a patch below can fix this problem.

===
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3737a68..2fe9645 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2722,7 +2722,7 @@ again:
 
 	if (!cgroup_clear_css_refs(cgrp)) {
 		mutex_unlock(&cgroup_mutex);
-		schedule();
+		schedule_timeout(HZ/10);	/* don't wait forever */
 		finish_wait(&cgroup_rmdir_waitq, &wait);
 		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
 		if (signal_pending(current))
===

But, is there any reason why we should charge a NEW swap-in'ed page to
"the group to which the swap has been charged", not to "the group in which
the process is now" ?
I agree that we should uncharge "swap" at swap-in from "the group to which
the swap has been charged", but IIUC, memcg before/without mem+swap controller behaves
as the latter about the charge of a swap-in'ed page.

I've confirmed that a patch below can also fix this rmdir problem.

===
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6ceb6f2..dbece65 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1063,7 +1063,7 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
 
 static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem = NULL;
 	struct page_cgroup *pc;
 	unsigned short id;
 	swp_entry_t ent;
@@ -1079,14 +1079,6 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
 		mem = pc->mem_cgroup;
 		if (mem && !css_tryget(&mem->css))
 			mem = NULL;
-	} else {
-		ent.val = page_private(page);
-		id = lookup_swap_cgroup(ent);
-		rcu_read_lock();
-		mem = mem_cgroup_lookup(id);
-		if (mem && !css_tryget(&mem->css))
-			mem = NULL;
-		rcu_read_unlock();
 	}
 	unlock_page_cgroup(pc);
 	return mem;
===


Any suggestions ?


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
