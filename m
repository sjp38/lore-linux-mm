Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C1B9E6B00C3
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 23:27:24 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9K3RKum021381
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 20 Oct 2010 12:27:20 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8842645DE53
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 12:27:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6159A45DE52
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 12:27:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 47EB51DB803C
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 12:27:20 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E9BDA1DB8038
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 12:27:19 +0900 (JST)
Date: Wed, 20 Oct 2010 12:21:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][memcg+dirtylimit] Fix  overwriting global vm dirty limit
 setting by memcg (Re: [PATCH v3 00/11] memcg: per cgroup dirty page
 accounting
Message-Id: <20101020122144.47f2b60b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287448784-25684-1-git-send-email-gthelen@google.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>


One bug fix here.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, at calculating dirty limit, vm_dirty_param() is called.
This function returns dirty-limit related parameters considering
memory cgroup settings.

Now, assume that vm_dirty_bytes=100M (global dirty limit) and
memory cgroup has 1G of pages and 40 dirty_ratio, dirtyable memory is
500MB.

In this case, global_dirty_limits will consider dirty_limt as
500 *0.4 = 200MB. This is bad...memory cgroup is not back door.

This patch limits the return value of vm_dirty_param() considring
global settings.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    4 ++--
 mm/memcontrol.c            |   29 ++++++++++++++++++++++++++++-
 mm/page-writeback.c        |    2 +-
 3 files changed, 31 insertions(+), 4 deletions(-)

Index: dirty_limit_new/mm/memcontrol.c
===================================================================
--- dirty_limit_new.orig/mm/memcontrol.c
+++ dirty_limit_new/mm/memcontrol.c
@@ -1171,9 +1171,10 @@ static void __mem_cgroup_dirty_param(str
  * can be moved after our access and writeback tends to take long time.  At
  * least, "memcg" will not be freed while holding rcu_read_lock().
  */
-void vm_dirty_param(struct vm_dirty_param *param)
+void vm_dirty_param(struct vm_dirty_param *param, unsigned long mem)
 {
 	struct mem_cgroup *memcg;
+	u64 limit, bglimit;
 
 	if (mem_cgroup_disabled()) {
 		global_vm_dirty_param(param);
@@ -1183,6 +1184,32 @@ void vm_dirty_param(struct vm_dirty_para
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(current);
 	__mem_cgroup_dirty_param(param, memcg);
+	/*
+ 	 * A limitation under memory cgroup is under global vm, too.
+ 	 */
+	if (vm_dirty_ratio)
+		limit = mem * vm_dirty_ratio / 100;
+	else
+		limit = vm_dirty_bytes;
+	if (param->dirty_ratio) {
+		param->dirty_bytes = mem * param->dirty_ratio / 100;
+		param->dirty_ratio = 0;
+	}
+	if (param->dirty_bytes > limit)
+		param->dirty_bytes = limit;
+
+	if (dirty_background_ratio)
+		bglimit = mem * dirty_background_ratio / 100;
+	else
+		bglimit = dirty_background_bytes;
+
+	if (param->dirty_background_ratio) {
+		param->dirty_background_bytes =
+			mem * param->dirty_background_ratio /100;
+		param->dirty_background_ratio = 0;
+	}
+	if (param->dirty_background_bytes > bglimit)
+		param->dirty_background_bytes = bglimit;
 	rcu_read_unlock();
 }
 
Index: dirty_limit_new/include/linux/memcontrol.h
===================================================================
--- dirty_limit_new.orig/include/linux/memcontrol.h
+++ dirty_limit_new/include/linux/memcontrol.h
@@ -171,7 +171,7 @@ static inline void mem_cgroup_dec_page_s
 }
 
 bool mem_cgroup_has_dirty_limit(void);
-void vm_dirty_param(struct vm_dirty_param *param);
+void vm_dirty_param(struct vm_dirty_param *param, u64 mem);
 s64 mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item);
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
@@ -360,7 +360,7 @@ static inline bool mem_cgroup_has_dirty_
 	return false;
 }
 
-static inline void vm_dirty_param(struct vm_dirty_param *param)
+static inline void vm_dirty_param(struct vm_dirty_param *param, u64 mem)
 {
 	global_vm_dirty_param(param);
 }
Index: dirty_limit_new/mm/page-writeback.c
===================================================================
--- dirty_limit_new.orig/mm/page-writeback.c
+++ dirty_limit_new/mm/page-writeback.c
@@ -466,7 +466,7 @@ void global_dirty_limits(unsigned long *
 	struct task_struct *tsk;
 	struct vm_dirty_param dirty_param;
 
-	vm_dirty_param(&dirty_param);
+	vm_dirty_param(&dirty_param, avialable_memory);
 
 	if (dirty_param.dirty_bytes)
 		dirty = DIV_ROUND_UP(dirty_param.dirty_bytes, PAGE_SIZE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
