Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C5AF86B0215
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 04:28:13 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o538SAXD006127
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Jun 2010 17:28:10 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 11F0445DE53
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 17:28:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E463D45DE4F
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 17:28:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B6B3CE38002
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 17:28:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 656081DB8015
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 17:28:09 +0900 (JST)
Date: Thu, 3 Jun 2010 17:23:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg fix wake up in oom wait queue
Message-Id: <20100603172353.b5375879.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Very sorry that my test wasn't enough and delayed.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

OOM-waitqueue should be waken up when oom_disable is canceled.
This is a fix for
 memcg-oom-kill-disable-and-oom-status.patch

How to test:
 Create a cgroup A...
 1. set memory.limit and memory.memsw.limit to be small value
 2. echo 1 > /cgroup/A/memory.oom_control, this disables oom-kill.
 3. run a program which must cause OOM.

A program executed in 3 will sleep by oom_waiqueue in memcg.
Then, how to wake it up is problem.

 1. echo 0 > /cgroup/A/memory.oom_control (enable OOM-killer)
 2. echo big mem > /cgroup/A/memory.memsw.limit_in_bytes(allow more swap)
etc..

Without the patch, a task in slept can not be waken up.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: mmotm-2.6.34-May21/mm/memcontrol.c
===================================================================
--- mmotm-2.6.34-May21.orig/mm/memcontrol.c
+++ mmotm-2.6.34-May21/mm/memcontrol.c
@@ -1413,7 +1413,7 @@ static void memcg_wakeup_oom(struct mem_
 
 static void memcg_oom_recover(struct mem_cgroup *mem)
 {
-	if (mem->oom_kill_disable && atomic_read(&mem->oom_lock))
+	if (atomic_read(&mem->oom_lock))
 		memcg_wakeup_oom(mem);
 }
 
@@ -3830,6 +3830,8 @@ static int mem_cgroup_oom_control_write(
 		return -EINVAL;
 	}
 	mem->oom_kill_disable = val;
+	if (!val)
+		memcg_oom_recover(mem);
 	cgroup_unlock();
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
