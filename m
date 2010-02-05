Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0C7BE6B0047
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 19:43:02 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o150gxfq014638
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Feb 2010 09:42:59 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 382BA45DE50
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 09:42:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 18C5245DE4E
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 09:42:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 006B81DB803B
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 09:42:59 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B13BE1DB8037
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 09:42:58 +0900 (JST)
Date: Fri, 5 Feb 2010 09:39:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other cgroup
Message-Id: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Please take this patch in different context with recent discussion.
This is a quick-fix for a terrible bug.

This patch itself is against mmotm but can be easily applied to mainline or
stable tree, I think. (But I don't CC stable tree until I get ack.)

==
Now, oom-killer kills process's chidlren at first. But this means
a child in other cgroup can be killed. But it's not checked now.

This patch fixes that.

CC: Balbir Singh <balbir@linux.vnet.ibm.com>
CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/oom_kill.c |    3 +++
 1 file changed, 3 insertions(+)

Index: mmotm-2.6.33-Feb03/mm/oom_kill.c
===================================================================
--- mmotm-2.6.33-Feb03.orig/mm/oom_kill.c
+++ mmotm-2.6.33-Feb03/mm/oom_kill.c
@@ -459,6 +459,9 @@ static int oom_kill_process(struct task_
 	list_for_each_entry(c, &p->children, sibling) {
 		if (c->mm == p->mm)
 			continue;
+		/* Children may be in other cgroup */
+		if (mem && !task_in_mem_cgroup(c, mem))
+			continue;
 		if (!oom_kill_task(c))
 			return 0;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
