Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9B61E6B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 01:08:38 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4858ilq008147
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 8 May 2009 14:08:45 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A654C45DE5D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 14:08:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 722A345DE62
	for <linux-mm@kvack.org>; Fri,  8 May 2009 14:08:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 54A471DB803E
	for <linux-mm@kvack.org>; Fri,  8 May 2009 14:08:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E8286E38004
	for <linux-mm@kvack.org>; Fri,  8 May 2009 14:08:43 +0900 (JST)
Date: Fri, 8 May 2009 14:07:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/2] add mem cgroup is activated check
Message-Id: <20090508140713.e08827d8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090508140528.c34ae712.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090508140528.c34ae712.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
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
there are cases that this check is better than mem_cgroup_disabled().


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    7 +++++++
 mm/memcontrol.c            |   12 ++++++++++++
 2 files changed, 19 insertions(+)

Index: mmotm-2.6.30-May05/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.30-May05.orig/include/linux/memcontrol.h
+++ mmotm-2.6.30-May05/include/linux/memcontrol.h
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
Index: mmotm-2.6.30-May05/mm/memcontrol.c
===================================================================
--- mmotm-2.6.30-May05.orig/mm/memcontrol.c
+++ mmotm-2.6.30-May05/mm/memcontrol.c
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
