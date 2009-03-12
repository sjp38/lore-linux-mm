Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id ED3426B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 20:59:57 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C0xsGY005213
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 09:59:54 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0757545DE52
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:59:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D45A345DE4F
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:59:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AC8A1E0800B
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:59:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D4561DB8012
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:59:53 +0900 (JST)
Date: Thu, 12 Mar 2009 09:58:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/5] memcg softlimit_priority
Message-Id: <20090312095831.e88b4556.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

An iterface to set/read softlimit priority of cgroup.

Changelog: v2->v3
 - removed complicated handling of hierarchy.
   i.e. Changes in priority doesn't affect children.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   31 +++++++++++++++++++++++++++++--
 1 file changed, 29 insertions(+), 2 deletions(-)

Index: mmotm-2.6.29-Mar10/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Mar10.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Mar10/mm/memcontrol.c
@@ -217,6 +217,8 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 #define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
 
+#define MEM_SOFTLIMIT_PRIO     (0x10)
+
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
@@ -2187,7 +2189,14 @@ static u64 mem_cgroup_read(struct cgroup
 	name = MEMFILE_ATTR(cft->private);
 	switch (type) {
 	case _MEM:
-		val = res_counter_read_u64(&mem->res, name);
+		switch (name) {
+		case MEM_SOFTLIMIT_PRIO:
+			val = mem->softlimit_priority;
+			break;
+		default:
+			val = res_counter_read_u64(&mem->res, name);
+			break;
+		}
 		break;
 	case _MEMSWAP:
 		if (do_swap_account)
@@ -2290,6 +2299,18 @@ static int mem_cgroup_reset(struct cgrou
 	return 0;
 }
 
+static int mem_cgroup_write_softlimit_priority(struct cgroup *cgrp,
+					struct cftype *cft,
+					u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	int priority = (int)val;
+
+	if ((priority < 0) || (priority > SOFTLIMIT_MAXPRI))
+		return -EINVAL;
+	memcg_softlimit_requeue(memcg, priority);
+	return 0;
+}
 
 /* For read statistics */
 enum {
@@ -2485,6 +2506,12 @@ static struct cftype mem_cgroup_files[] 
 		.read_u64 = mem_cgroup_read,
 	},
 	{
+		.name = "softlimit_priority",
+		.private = MEMFILE_PRIVATE(_MEM, MEM_SOFTLIMIT_PRIO),
+		.write_u64 = mem_cgroup_write_softlimit_priority,
+		.read_u64 = mem_cgroup_read,
+	},
+	{
 		.name = "failcnt",
 		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
 		.trigger = mem_cgroup_reset,
@@ -2711,8 +2738,8 @@ mem_cgroup_create(struct cgroup_subsys *
 		res_counter_init(&mem->res, NULL);
 		res_counter_init(&mem->memsw, NULL);
 	}
-	mem->last_scanned_child = 0;
 	mem->softlimit_priority = SOFTLIMIT_MAXPRI;
+	mem->last_scanned_child = 0;
 	mutex_init(&mem->softlimit_mutex);
 	spin_lock_init(&mem->reclaim_param_lock);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
