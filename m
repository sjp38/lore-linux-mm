Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7E3916B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 20:56:47 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C1ujbO027764
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Feb 2010 10:56:45 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 13BE845DE4F
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 10:56:45 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E6D901EF086
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 10:56:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BAA3DE18002
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 10:56:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AA962E18006
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 10:56:43 +0900 (JST)
Date: Fri, 12 Feb 2010 10:53:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg: fix oom killing a child process in an other
 cgroup
Message-Id: <20100212105318.caf37133.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, stable@kernel.org, minchan.kim@gmail.com, rientjes@google.com, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch itself is againt mmotm-Feb10 but can be applied to 2.6.32.8
without problem.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, oom-killer is memcg aware and it finds the worst process from
processes under memcg(s) in oom. Then, it kills victim's child at first.
It may kill a child in other cgroup and may not be any help for recovery.
And it will break the assumption users have...

This patch fixes it.

CC: stable@kernel.org
CC: Minchan Kim <minchan.kim@gmail.com>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/oom_kill.c |    2 ++
 1 file changed, 2 insertions(+)

Index: mmotm-2.6.33-Feb10/mm/oom_kill.c
===================================================================
--- mmotm-2.6.33-Feb10.orig/mm/oom_kill.c
+++ mmotm-2.6.33-Feb10/mm/oom_kill.c
@@ -459,6 +459,8 @@ static int oom_kill_process(struct task_
 	list_for_each_entry(c, &p->children, sibling) {
 		if (c->mm == p->mm)
 			continue;
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
