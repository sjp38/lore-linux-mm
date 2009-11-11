Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B40A16B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 20:45:01 -0500 (EST)
Date: Wed, 11 Nov 2009 10:39:06 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 3/3] memcg: remove memcg_tasklist
Message-Id: <20091111103906.5c3563bb.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091111103533.c634ff8d.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091111103533.c634ff8d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

memcg_tasklist was introduced at commit 7f4d454d(memcg: avoid deadlock caused
by race between oom and cpuset_attach) instead of cgroup_mutex to fix a deadlock
problem.  The cgroup_mutex, which was removed by the commit, in
mem_cgroup_out_of_memory() was originally introduced at commit c7ba5c9e
(Memory controller: OOM handling).

IIUC, the intention of this cgroup_mutex was to prevent task move during
select_bad_process() so that situations like below can be avoided.

  Assume cgroup "foo" has exceeded its limit and is about to trigger oom.
  1. Process A, which has been in cgroup "baa" and uses large memory, is just
     moved to cgroup "foo". Process A can be the candidates for being killed.
  2. Process B, which has been in cgroup "foo" and uses large memory, is just
     moved from cgroup "foo". Process B can be excluded from the candidates for
     being killed.

But these race window exists anyway even if we hold a lock, because
__mem_cgroup_try_charge() decides wether it should trigger oom or not outside
of the lock. So the original cgroup_mutex in mem_cgroup_out_of_memory and thus
current memcg_tasklist has no use. And IMHO, those races are not so critical
for users.

This patch removes it and make codes simpler.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2f1283b..a74fcc2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -55,7 +55,6 @@ static int really_do_swap_account __initdata = 1; /* for remember boot option*/
 #define do_swap_account		(0)
 #endif
 
-static DEFINE_MUTEX(memcg_tasklist);	/* can be hold under cgroup_mutex */
 #define SOFTLIMIT_EVENTS_THRESH (1000)
 
 /*
@@ -1475,9 +1474,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 
 		if (!nr_retries--) {
 			if (oom) {
-				mutex_lock(&memcg_tasklist);
 				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
-				mutex_unlock(&memcg_tasklist);
 				record_last_oom(mem_over_limit);
 			}
 			goto nomem;
@@ -3385,12 +3382,10 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct task_struct *p,
 				bool threadgroup)
 {
-	mutex_lock(&memcg_tasklist);
 	/*
 	 * FIXME: It's better to move charges of this process from old
 	 * memcg to new memcg. But it's just on TODO-List now.
 	 */
-	mutex_unlock(&memcg_tasklist);
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
