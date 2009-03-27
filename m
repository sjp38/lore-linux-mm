Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B1E446B0047
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 01:07:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2R5Eode011504
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 27 Mar 2009 14:14:51 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 805B545DE5D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:14:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 55AAE45DE51
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:14:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A3BB1DB803F
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:14:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DED161DB8041
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:14:49 +0900 (JST)
Date: Fri, 27 Mar 2009 14:13:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 8/8] extends soft limit event filter
Message-Id: <20090327141322.6606cabe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Reduce softlimit update ratio depends on its priority(usage).

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: mmotm-2.6.29-Mar23/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Mar23.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Mar23/mm/memcontrol.c
@@ -945,11 +945,15 @@ static bool mem_cgroup_soft_limit_check(
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
+	thresh <<= (mem->soft_limit_priority >> 1);
+	if (unlikely(val > thresh)) {
 		__mem_cgroup_stat_reset_safe(cpustat, MEM_CGROUP_STAT_EVENTS);
 		ret = true;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
