Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9F13D6B004F
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 04:19:56 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n338KDJM002196
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Apr 2009 17:20:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F058145DE55
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:20:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A16145DE61
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:20:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 470071DB803C
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:20:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 71ED4E38002
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:20:11 +0900 (JST)
Date: Fri, 3 Apr 2009 17:18:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 9/9] more event filter depend on priority
Message-Id: <20090403171844.fb92308a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

I'll revisit this one before v3...

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reduce softlimit update ratio depends on its priority(usage).

After this.
  if priority=0,1 -> check once in 1024 page-in/out
  if priority=2,3 -> check once in 2048 page-in/out
  ...
  if priority=10,11 -> check once in 32k page-in/out

(Note: this is called only when the usage exceeds soft limit)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

Index: softlimit-test2/mm/memcontrol.c
===================================================================
--- softlimit-test2.orig/mm/memcontrol.c
+++ softlimit-test2/mm/memcontrol.c
@@ -940,7 +940,7 @@ static void record_last_oom(struct mem_c
 	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
 }
 
-#define SOFTLIMIT_EVENTS_THRESH (1024) /* 1024 times of page-in/out */
+#define SOFTLIMIT_EVENTS_THRESH (512) /* 512 times of page-in/out */
 /*
  * Returns true if sum of page-in/page-out events since last check is
  * over SOFTLIMIT_EVENT_THRESH. (counter is per-cpu.)
@@ -950,11 +950,15 @@ static bool mem_cgroup_soft_limit_check(
 	bool ret = false;
 	int cpu = get_cpu();
 	s64 val;
+	int thresh;
 	struct mem_cgroup_stat_cpu *cpustat;
 
 	cpustat = &mem->stat.cpustat[cpu];
 	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_EVENTS);
-	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH)) {
+	/* If usage is big, this check can be rough */
+	thresh = SOFTLIMIT_EVENTS_THRESH;
+	thresh <<= ((mem->soft_limit_priority >> 1) + 1);
+	if (unlikely(val > thresh)) {
 		__mem_cgroup_stat_reset_safe(cpustat, MEM_CGROUP_STAT_EVENTS);
 		ret = true;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
