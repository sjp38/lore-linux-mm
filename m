Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id ABD906B007D
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 06:00:01 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8R9xxtb032731
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 27 Sep 2010 18:59:59 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 57E8F45DE60
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 18:59:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DE8045DE4D
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 18:59:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 167991DB8037
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 18:59:59 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B2AC5EF8005
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 18:59:55 +0900 (JST)
Date: Mon, 27 Sep 2010 18:54:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/4] memcg: per node info node hotplug support
Message-Id: <20100927185447.64ed0aec.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100927184821.f4bf2b2c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100924181302.7d764e0d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100927184821.f4bf2b2c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Support node hot plug (experimental).

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |   46 +++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 43 insertions(+), 3 deletions(-)

Index: mmotm-0922/mm/memcontrol.c
===================================================================
--- mmotm-0922.orig/mm/memcontrol.c
+++ mmotm-0922/mm/memcontrol.c
@@ -48,6 +48,7 @@
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
+#include <linux/memory.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -4212,8 +4213,12 @@ static int alloc_mem_cgroup_per_zone_inf
 		id = node_zone_idx(css_id(&mem->css), node, zone);
 		ret = radix_tree_insert(&memcg_lrus, id, mz);
 		spin_unlock_irq(&memcg_lrutable_lock);
-		if (ret)
-			break;
+		if (ret) {
+			if (ret != -EEXIST)
+				break;
+			kfree(mz);
+			continue;
+		}
 		for_each_lru(l)
 			INIT_LIST_HEAD(&mz->lists[l]);
 		mz->on_tree = false;
@@ -4372,6 +4377,40 @@ static int mem_cgroup_soft_limit_tree_in
 	return 0;
 }
 
+static int __meminit memcg_memory_hotplug_callback(struct notifier_block *self,
+		unsigned long action, void *arg)
+{
+	struct memory_notify *mn = arg;
+	struct mem_cgroup *mem;
+	int nid = mn->status_change_nid;
+	int ret = 0;
+
+	/* We just take care of node hotplug */
+	if (nid == -1)
+		return NOTIFY_OK;
+	switch(action) {
+	case MEM_GOING_ONLINE:
+		for_each_mem_cgroup_all(mem)
+			ret = alloc_mem_cgroup_per_zone_info(mem, nid);
+		break;
+	case MEM_OFFLINE:
+		for_each_mem_cgroup_all(mem)
+			free_mem_cgroup_per_zone_info(mem, nid);
+		break;
+	default:
+		break;
+	}
+
+	if (ret)
+		ret = notifier_from_errno(ret);
+	else
+		ret = NOTIFY_OK;
+
+	return ret;
+}
+
+
+
 static struct cgroup_subsys_state * __ref
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
@@ -4387,7 +4426,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (error)
 		goto free_out;
 
-	for_each_node_state(node, N_POSSIBLE)
+	for_each_node_state(node, N_HIGH_MEMORY)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
 			goto free_out;
 
@@ -4407,6 +4446,7 @@ mem_cgroup_create(struct cgroup_subsys *
 			INIT_WORK(&stock->work, drain_local_stock);
 		}
 		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
+		hotplug_memory_notifier(memcg_memory_hotplug_callback, 0);
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
