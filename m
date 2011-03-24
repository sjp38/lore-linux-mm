Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8510A8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 05:32:26 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6423A3EE0BD
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:32:23 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 414DA45DE56
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:32:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E57145DE50
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:32:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DB296E7800E
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:32:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 859C7E78005
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:32:22 +0900 (JST)
Date: Thu, 24 Mar 2011 18:25:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/5] forkbomb killer config and documentation
Message-Id: <20110324182558.f5f811ab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>

Kconfig and Documentation for forkbomb killer.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/vm/forkbomb.txt |   62 ++++++++++++++++++++++++++++++++++++++++++
 mm/Kconfig                    |   16 ++++++++++
 2 files changed, 78 insertions(+)

Index: mm-work2/Documentation/vm/forkbomb.txt
===================================================================
--- /dev/null
+++ mm-work2/Documentation/vm/forkbomb.txt
@@ -0,0 +1,62 @@
+Forkbomb.txt
+
+1. Intruduction
+   Maybe many programmer have an experience to write a fork-bomb program.
+
+   One example of fork-bomb is a bomb which make system unstable by the
+   memory pressure caused by the number of tasks. This kind of fork-bomb
+   can be limited by ulimit(max user processes). If it happens, the user
+   who has the same owner ID of forkbomb will not be able to do anything
+   but other users(admin) may have a chance to kill them. (Of course,
+   if forkbomb is created by root, we have no chance to recover.)
+
+   Another example of fork-bomb is a bomb which eats much memory. This
+   kind of forkbomb causes huge swapout and make system slow and finally,
+   OOM. In swapless system, the system will see OOM soon. To prevent this
+   type of bomb, memory cgroup or overcommit_memory will be a help. But
+   troubles happen when we don't expected.....
+
+   To recover from fork-bomb, we need to kill all tasks which is in the
+   forkbomb tree, in general. But if the system is in OOM state, killing
+   them all tends to be difficult.
+
+2. Forkbomb Killer.
+   The kernel provides a forkbomb killer. (see mm/Kconfig FORKBOMB_KILLER)
+   If enabled, the forkbomb killer will provides 2 system files.
+
+   /sys/kernel/mm/oom/mm_tracking_enabled
+   /sys/kernel/mm/oom/mm_tracking_reset_interval_msecs
+
+
+   If /sys/kernel/mm/oom/mm_tracking_enabled == enabled, the kernel records
+   all fork/vfork/exec information by an extra structure than usual task
+   management. This information is used for tracking a task tree. Unlike
+   process tree, this doesn't discard parent<->children information even
+   when the parent exits before children and make children as orphan processes.
+   By this, even with following script, task tracking information can be
+   preserved and we have a chance to chase all proceesses in a fork bomb.
+
+   (example) # forkbomb(){ forkbomb|forkbomb & } ; forkbomb
+
+   But this information tracking adds a small overhead at fork/vfork/exec/exit.
+   Default is enabled.
+
+   /sys/kernel/mm/oom/mm_tracking_reset_interval_msecs
+
+   Because we cannot preserve all information since the system boot, we need
+   to forget information. Forkbomb killer checks the system status in each
+   period. What checked now is
+   1. the number of process.
+   2. the number of kswapd runs.
+   3. the number of alloc stalls. (memory reclaim)
+   If all of 1,2,3 aren't increased for mm_tracking_reset_interval_msecs,
+   all tracking information recorded before previous period will be
+   removed.
+   IOW, by making mm_tracking_reset_interval_msecs larger, you can check
+   forkbomb in a long period but will have more overheads. By making it
+   smaller, tracking records are removed earlier and tasks killed by
+   forkbomb killer will decrease (and you can avoid unnecessary kills.)
+   Default is 30secs.
+
+
+
Index: mm-work2/mm/Kconfig
===================================================================
--- mm-work2.orig/mm/Kconfig
+++ mm-work2/mm/Kconfig
@@ -274,6 +274,22 @@ config HWPOISON_INJECT
 	depends on MEMORY_FAILURE && DEBUG_KERNEL && PROC_FS
 	select PROC_PAGE_MONITOR
 
+config FORKBOMB_KILLER
+	bool "Killing a tree of tasks when a forkbomb is found"
+	depends on EXPERIMENTAL
+	default n
+	select MM_OWNER
+	help
+	  Provide a fork-bomb-killer, which is triggered at OOM.
+	  In usual case, OOM-Killer kills a memory eater processes.
+	  But it kills tasks in conservative way and cannot be a help
+          if forkbomb is running. The admin may need to reboot system
+	  if the influence of the bomb cannot be limited by rlimits or
+	  some security settings. FORKBOMB Killer kills a tree of process
+	  which have started recently and eats much memory. Please see,
+	  Documentation/vm/forkbomb.txt for details. If unsure, say N.
+
+
 config NOMMU_INITIAL_TRIM_EXCESS
 	int "Turn on mmap() excess space trimming before booting"
 	depends on !MMU

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
