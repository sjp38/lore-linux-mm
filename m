Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C85628D0001
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 13:32:55 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id oA4HWNTT026670
	for <linux-mm@kvack.org>; Thu, 4 Nov 2010 10:32:23 -0700
Received: from pwj7 (pwj7.prod.google.com [10.241.219.71])
	by hpaq14.eem.corp.google.com with ESMTP id oA4HWJLe003985
	for <linux-mm@kvack.org>; Thu, 4 Nov 2010 10:32:22 -0700
Received: by pwj7 with SMTP id 7so285213pwj.19
        for <linux-mm@kvack.org>; Thu, 04 Nov 2010 10:32:19 -0700 (PDT)
Date: Thu, 4 Nov 2010 10:31:58 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [BUGFIX][PATCH] fix wrong VM_BUG_ON() in try_charge()'s mm->owner
 check
In-Reply-To: <AANLkTikCUdpx-jGhKdzueML39CnExumk1i_X_OZJihE2@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1011041016520.19411@tigran.mtv.corp.google.com>
References: <AANLkTikCUdpx-jGhKdzueML39CnExumk1i_X_OZJihE2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 3 Nov 2010, Hiroyuki Kamezawa wrote:
> I'm sorry for attached file, I have to use unusual mailer this time.
> This is a fix for wrong VM_BUG_ON() for mm/memcontol.c

Thanks, Kame, that's good: I've inlined it below with Balbir's Review,
my Ack, and a Cc: stable@kernel.org.

Hugh


[PATCH] memcg: fix wrong VM_BUG_ON() in try_charge()'s mm->owner check

At __mem_cgroup_try_charge(), VM_BUG_ON(!mm->owner) is checked.
But as commented in mem_cgroup_from_task(), mm->owner can be NULL in some racy
case. This check of VM_BUG_ON() is bad.

A possible story to hit this is at swapoff()->try_to_unuse(). It passes
mm_struct to mem_cgroup_try_charge_swapin() while mm->owner is NULL. If we
can't get proper mem_cgroup from swap_cgroup information, mm->owner is used
as charge target and we see NULL.

Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Acked-by: Hugh Dickins <hughd@google.com>
Cc: stable@kernel.org
---
 mm/memcontrol.c |   19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

Index: linux-2.6.36/mm/memcontrol.c
===================================================================
--- linux-2.6.36.orig/mm/memcontrol.c
+++ linux-2.6.36/mm/memcontrol.c
@@ -1729,19 +1729,18 @@ again:
 
 		rcu_read_lock();
 		p = rcu_dereference(mm->owner);
-		VM_BUG_ON(!p);
 		/*
-		 * because we don't have task_lock(), "p" can exit while
-		 * we're here. In that case, "mem" can point to root
-		 * cgroup but never be NULL. (and task_struct itself is freed
-		 * by RCU, cgroup itself is RCU safe.) Then, we have small
-		 * risk here to get wrong cgroup. But such kind of mis-account
-		 * by race always happens because we don't have cgroup_mutex().
-		 * It's overkill and we allow that small race, here.
+		 * Because we don't have task_lock(), "p" can exit.
+		 * In that case, "mem" can point to root or p can be NULL with
+		 * race with swapoff. Then, we have small risk of mis-accouning.
+		 * But such kind of mis-account by race always happens because
+		 * we don't have cgroup_mutex(). It's overkill and we allo that
+		 * small race, here.
+		 * (*) swapoff at el will charge against mm-struct not against
+		 * task-struct. So, mm->owner can be NULL.
 		 */
 		mem = mem_cgroup_from_task(p);
-		VM_BUG_ON(!mem);
-		if (mem_cgroup_is_root(mem)) {
+		if (!mem || mem_cgroup_is_root(mem)) {
 			rcu_read_unlock();
 			goto done;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
