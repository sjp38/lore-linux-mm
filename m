Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9N9BRFk006003
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 23 Oct 2008 18:11:28 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C59EC2AC028
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:11:27 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4798212C045
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:11:27 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id BA40C1DB8048
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:11:26 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 226C61DB8045
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:11:23 +0900 (JST)
Date: Thu, 23 Oct 2008 18:10:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 8/11] memcg: shmem account helper
Message-Id: <20081023181055.cb9f8685.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

In mem+swap controller, we also have to catch shmem's swap-in.

This patch adds hook to shmem's swap-in path.

And as a good effect, a charge done under spinlock(info->lock)
is moved out to outside of lock.
(do that under spinlock is bug...)

And this also fixes gfp mask of shmem's charge. Now, we don't
have to allocate page_cgroup dynamically, GFP_KERNEL is not suitable.

mem_cgroup_charge_cache_swapin() itself will be modified by following patch.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 include/linux/memcontrol.h |    3 +++
 mm/memcontrol.c            |   12 ++++++++++++
 mm/shmem.c                 |   17 ++++++++++++++---
 3 files changed, 29 insertions(+), 3 deletions(-)

Index: mmotm-2.6.27+/mm/shmem.c
===================================================================
--- mmotm-2.6.27+.orig/mm/shmem.c
+++ mmotm-2.6.27+/mm/shmem.c
@@ -920,8 +920,9 @@ found:
 	error = 1;
 	if (!inode)
 		goto out;
-	/* Precharge page using GFP_KERNEL while we can wait */
-	error = mem_cgroup_cache_charge(page, current->mm, GFP_KERNEL);
+	/* Precharge page using GFP_HIGHUSER_PAGECACHE while we can wait */
+	error = mem_cgroup_cache_charge_swapin(page, current->mm,
+			GFP_HIGHUSER_PAGECACHE);
 	if (error)
 		goto out;
 	error = radix_tree_preload(GFP_KERNEL);
@@ -1259,6 +1260,16 @@ repeat:
 			}
 			wait_on_page_locked(swappage);
 			page_cache_release(swappage);
+			/*
+			 * We want to charge agaisnt this page not-under
+			 * info->lock. do precharge here.
+			 */
+			if (mem_cgroup_cache_charge_swapin(swappage,
+					current->mm, gfp)) {
+				error = -ENOMEM;
+				goto failed;
+			}
+
 			goto repeat;
 		}
 
@@ -1371,7 +1382,7 @@ repeat:
 
 			/* Precharge page while we can wait, compensate after */
 			error = mem_cgroup_cache_charge(filepage, current->mm,
-							gfp & ~__GFP_HIGHMEM);
+							gfp);
 			if (error) {
 				page_cache_release(filepage);
 				shmem_unacct_blocks(info->flags, 1);
Index: mmotm-2.6.27+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27+.orig/mm/memcontrol.c
+++ mmotm-2.6.27+/mm/memcontrol.c
@@ -988,6 +988,18 @@ int mem_cgroup_cache_charge(struct page 
 				MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
 }
 
+int mem_cgroup_cache_charge_swapin(struct page *page, struct mm_struct *mm,
+				gfp_t gfp_mask)
+{
+	if (mem_cgroup_subsys.disabled)
+		return 0;
+	if (unlikely(!mm))
+		mm = &init_mm;
+	return mem_cgroup_charge_common(page, mm, gfp_mask,
+				MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
+
+}
+
 void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 {
 	struct page_cgroup *pc;
Index: mmotm-2.6.27+/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.27+.orig/include/linux/memcontrol.h
+++ mmotm-2.6.27+/include/linux/memcontrol.h
@@ -38,6 +38,9 @@ extern void mem_cgroup_cancel_charge_swa
 
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
+extern int mem_cgroup_cache_charge_swapin(struct page *page,
+			struct mm_struct *mm, gfp_t gfp_mask);
+
 extern void mem_cgroup_move_lists(struct page *page, enum lru_list lru);
 extern void mem_cgroup_uncharge_page(struct page *page);
 extern void mem_cgroup_uncharge_cache_page(struct page *page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
