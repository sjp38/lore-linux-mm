Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CF17D6B01AD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 23:02:40 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5432bBn022343
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Jun 2010 12:02:38 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9439A45DE4F
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 12:02:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 702C845DE4E
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 12:02:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FB181DB8048
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 12:02:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D98ED1DB804F
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 12:02:36 +0900 (JST)
Date: Fri, 4 Jun 2010 11:58:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg fix wake up in oom wait queue
Message-Id: <20100604115820.d7ec1008.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100604100811.31c45828.nishimura@mxp.nes.nec.co.jp>
References: <20100603172353.b5375879.kamezawa.hiroyu@jp.fujitsu.com>
	<20100604100811.31c45828.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Tested on mmotm-2010-06-03 and works well.
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

Changelog: 2010/06/04
Rebased onto mmotm-2010-06-03-16-36

Acked-by: Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: mmotm-2.6.34-Jun6/mm/memcontrol.c
===================================================================
--- mmotm-2.6.34-Jun6.orig/mm/memcontrol.c
+++ mmotm-2.6.34-Jun6/mm/memcontrol.c
@@ -1370,7 +1370,7 @@ static void memcg_wakeup_oom(struct mem_
 
 static void memcg_oom_recover(struct mem_cgroup *mem)
 {
-	if (mem->oom_kill_disable && atomic_read(&mem->oom_lock))
+	if (atomic_read(&mem->oom_lock))
 		memcg_wakeup_oom(mem);
 }
 
@@ -3781,6 +3781,8 @@ static int mem_cgroup_oom_control_write(
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
