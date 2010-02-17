Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E72236B0078
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 01:08:17 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1H68FgD018700
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Feb 2010 15:08:15 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1167845DE61
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 15:08:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C8F1845DD77
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 15:08:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 892DB1DB8041
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 15:08:14 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 27B79EF8002
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 15:08:14 +0900 (JST)
Date: Wed, 17 Feb 2010 15:04:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: handle panic_on_oom=always case
Message-Id: <20100217150445.1a40201d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, rientjes@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

tested on mmotm-Feb11.

Balbir-san, Nishimura-san, I want review from both of you.

==

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, if panic_on_oom=2, the whole system panics even if the oom happend
in some special situation (as cpuset, mempolicy....).
Then, panic_on_oom=2 means painc_on_oom_always.

Now, memcg doesn't check panic_on_oom flag. This patch adds a check.

Maybe someone doubts how it's useful. kdump+panic_on_oom=2 is the
last tool to investigate what happens in oom-ed system. If a task is killed,
the sysytem recovers and used memory were freed, there will be few hint
to know what happnes. In mission critical system, oom should never happen.
Then, investigation after OOM is very important.
Then, panic_on_oom=2+kdump is useful to avoid next OOM by knowing
precise information via snapshot.

TODO:
 - For memcg, it's for isolate system's memory usage, oom-notiifer and
   freeze_at_oom (or rest_at_oom) should be implemented. Then, management
   daemon can do similar jobs (as kdump) in safer way or taking snapshot
   per cgroup.

CC: Balbir Singh <balbir@linux.vnet.ibm.com>
CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
CC: David Rientjes <rientjes@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |    2 ++
 Documentation/sysctl/vm.txt      |    5 ++++-
 mm/oom_kill.c                    |    2 ++
 3 files changed, 8 insertions(+), 1 deletion(-)

Index: mmotm-2.6.33-Feb11/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-2.6.33-Feb11.orig/Documentation/cgroups/memory.txt
+++ mmotm-2.6.33-Feb11/Documentation/cgroups/memory.txt
@@ -182,6 +182,8 @@ list.
 NOTE: Reclaim does not work for the root cgroup, since we cannot set any
 limits on the root cgroup.
 
+Note2: When panic_on_oom is set to "2", the whole system will panic.
+
 2. Locking
 
 The memory controller uses the following hierarchy
Index: mmotm-2.6.33-Feb11/Documentation/sysctl/vm.txt
===================================================================
--- mmotm-2.6.33-Feb11.orig/Documentation/sysctl/vm.txt
+++ mmotm-2.6.33-Feb11/Documentation/sysctl/vm.txt
@@ -573,11 +573,14 @@ Because other nodes' memory may be free.
 may be not fatal yet.
 
 If this is set to 2, the kernel panics compulsorily even on the
-above-mentioned.
+above-mentioned. Even oom happens under memoyr cgroup, the whole
+system panics.
 
 The default value is 0.
 1 and 2 are for failover of clustering. Please select either
 according to your policy of failover.
+2 seems too strong but panic_on_oom=2+kdump gives you very strong
+tool to investigate a system which should never cause OOM.
 
 =============================================================
 
Index: mmotm-2.6.33-Feb11/mm/oom_kill.c
===================================================================
--- mmotm-2.6.33-Feb11.orig/mm/oom_kill.c
+++ mmotm-2.6.33-Feb11/mm/oom_kill.c
@@ -471,6 +471,8 @@ void mem_cgroup_out_of_memory(struct mem
 	unsigned long points = 0;
 	struct task_struct *p;
 
+	if (sysctl_panic_on_oom == 2)
+		panic("out of memory(memcg). panic_on_oom is selected.\n");
 	read_lock(&tasklist_lock);
 retry:
 	p = select_bad_process(&points, mem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
