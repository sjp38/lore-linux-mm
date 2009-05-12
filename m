Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1CEE46B004F
	for <linux-mm@kvack.org>; Mon, 11 May 2009 21:45:55 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4C1kZjl023627
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 May 2009 10:46:35 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6308B45DE58
	for <linux-mm@kvack.org>; Tue, 12 May 2009 10:46:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3104F45DE54
	for <linux-mm@kvack.org>; Tue, 12 May 2009 10:46:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E3D6A1DB803C
	for <linux-mm@kvack.org>; Tue, 12 May 2009 10:46:34 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 352BA1DB8043
	for <linux-mm@kvack.org>; Tue, 12 May 2009 10:46:34 +0900 (JST)
Date: Tue, 12 May 2009 10:45:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/3] add check for mem cgroup is activated
Message-Id: <20090512104504.4e722ccc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

There is a function "mem_cgroup_disabled()" which returns
  - memcg is configured ?
  - disabled by boot option ?
This is check is useful to confirm whether we have to call memcg's hook or not.

But, even when memcg is configured (and not disabled), it's not really used
until mounted. This patch adds mem_cgroup_activated() to check memcg is
mounted or not at least once.
(Will be used in later patch.)

IIUC, only very careful users set boot option of memcg to be disabled and
most of people will not be aware of that memcg is enabled at default.
So, if memcg wants to affect to global VM behavior or to add some overheads,
there is cases that this check is better than mem_cgroup_disabled().

Acked-by: Balbir Singh <balbir@linux.vnet.bim.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: mmotm-2.6.30-May07/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.30-May07.orig/include/linux/memcontrol.h
+++ mmotm-2.6.30-May07/include/linux/memcontrol.h
@@ -115,6 +115,8 @@ static inline bool mem_cgroup_disabled(v
 		return true;
 	return false;
 }
+/* Returns strue if mem_cgroup is enabled and really used (mounted). */
+bool mem_cgroup_activated(void);
 
 extern bool mem_cgroup_oom_called(struct task_struct *task);
 void mem_cgroup_update_mapped_file_stat(struct page *page, int val);
@@ -229,6 +231,11 @@ static inline bool mem_cgroup_disabled(v
 	return true;
 }
 
+static inline bool mem_cgroup_activated(void)
+{
+	return false;
+}
+
 static inline bool mem_cgroup_oom_called(struct task_struct *task)
 {
 	return false;
Index: mmotm-2.6.30-May07/mm/memcontrol.c
===================================================================
--- mmotm-2.6.30-May07.orig/mm/memcontrol.c
+++ mmotm-2.6.30-May07/mm/memcontrol.c
@@ -2577,6 +2577,17 @@ static void mem_cgroup_move_task(struct 
 	mutex_unlock(&memcg_tasklist);
 }
 
+static bool __mem_cgroup_activated = false;
+bool mem_cgroup_activated(void)
+{
+	return __mem_cgroup_activated;
+}
+
+static void mem_cgroup_bind(struct cgroup_subsys *ss, struct cgroup *root)
+{
+	__mem_cgroup_activated = true;
+}
+
 struct cgroup_subsys mem_cgroup_subsys = {
 	.name = "memory",
 	.subsys_id = mem_cgroup_subsys_id,
@@ -2585,6 +2596,7 @@ struct cgroup_subsys mem_cgroup_subsys =
 	.destroy = mem_cgroup_destroy,
 	.populate = mem_cgroup_populate,
 	.attach = mem_cgroup_move_task,
+	.bind = mem_cgroup_bind,
 	.early_init = 0,
 	.use_id = 1,
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
