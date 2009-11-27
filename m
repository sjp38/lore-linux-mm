Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 504A56B0078
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 06:55:28 -0500 (EST)
Received: by mail-bw0-f215.google.com with SMTP id 7so369306bwz.6
        for <linux-mm@kvack.org>; Fri, 27 Nov 2009 03:55:26 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH RFC v1 3/3] memcg: implement memory thresholds
Date: Fri, 27 Nov 2009 13:55:04 +0200
Message-Id: <1da0c38407bb1fbd0b1da583b09d466e5a54f006.1259321503.git.kirill@shutemov.name>
In-Reply-To: <8524ba285f6dd59cda939c28da523f344cdab3da.1259321503.git.kirill@shutemov.name>
References: <cover.1259255307.git.kirill@shutemov.name>
 <bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259321503.git.kirill@shutemov.name>
 <8524ba285f6dd59cda939c28da523f344cdab3da.1259321503.git.kirill@shutemov.name>
In-Reply-To: <cover.1259321503.git.kirill@shutemov.name>
References: <cover.1259321503.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

It allows to register multiple memory and memsw thresholds and gets
notifications when it crosses.

To register a threshold application need:
- create an eventfd;
- open memory.usage_in_bytes or memory.memsw.usage_in_bytes;
- write string like "<event_fd> <memory.usage_in_bytes> <threshold>" to
  cgroup.event_control.

Application will be notified through eventfd when memory usage crosses
threshold in any direction.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |  224 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 224 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f99f599..333f67e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6,6 +6,10 @@
  * Copyright 2007 OpenVZ SWsoft Inc
  * Author: Pavel Emelianov <xemul@openvz.org>
  *
+ * Memory thresholds
+ * Copyright (C) 2009 Nokia Corporation
+ * Author: Kirill A. Shutemov
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
@@ -38,6 +42,7 @@
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
+#include <linux/eventfd.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -174,6 +179,12 @@ struct mem_cgroup_tree {
 
 static struct mem_cgroup_tree soft_limit_tree __read_mostly;
 
+struct mem_cgroup_threshold {
+	struct list_head list;
+	struct eventfd_ctx *eventfd;
+	u64 threshold;
+};
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -225,6 +236,12 @@ struct mem_cgroup {
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
 
+	struct list_head thresholds;
+	struct mem_cgroup_threshold *current_threshold;
+
+	struct list_head memsw_thresholds;
+	struct mem_cgroup_threshold *memsw_current_threshold;
+
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -2839,12 +2856,184 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
+static inline void mem_cgroup_set_thresholds(struct res_counter *counter,
+		u64 above, u64 below)
+{
+	BUG_ON(res_counter_set_thresholds(counter, above, below));
+}
+
+static void mem_cgroup_threshold(struct mem_cgroup *memcg,
+		struct res_counter *counter, u64 usage, u64 threshold)
+{
+	struct mem_cgroup_threshold *above, *below;
+	struct list_head *thresholds;
+	struct mem_cgroup_threshold **current_threshold;
+
+	if (&memcg->res == counter) {
+		thresholds = &memcg->thresholds;
+		current_threshold = &memcg->current_threshold;
+	} else if (&memcg->memsw == counter) {
+		thresholds = &memcg->memsw_thresholds;
+		current_threshold = &memcg->memsw_current_threshold;
+	} else
+		BUG();
+
+	above = below = *current_threshold;
+
+	if (threshold <= usage) {
+		list_for_each_entry_continue(above, thresholds, list) {
+			if (above->threshold > usage)
+				break;
+			below = above;
+			eventfd_signal(below->eventfd, 1);
+		}
+	} else {
+		list_for_each_entry_continue_reverse(below, thresholds, list) {
+			eventfd_signal(above->eventfd, 1);
+			if (below->threshold <= usage)
+				break;
+			above = below;
+		}
+	}
+
+	mem_cgroup_set_thresholds(counter, above->threshold, below->threshold);
+	*current_threshold = below;
+}
+
+static void mem_cgroup_mem_threshold(struct res_counter *counter, u64 usage,
+		u64 threshold)
+{
+	struct mem_cgroup *memcg = container_of(counter, struct mem_cgroup,
+			res);
+
+	mem_cgroup_threshold(memcg, counter, usage, threshold);
+}
+
+static void mem_cgroup_memsw_threshold(struct res_counter *counter, u64 usage,
+		u64 threshold)
+{
+	struct mem_cgroup *memcg = container_of(counter, struct mem_cgroup,
+			memsw);
+
+	mem_cgroup_threshold(memcg, counter, usage, threshold);
+}
+
+static void mem_cgroup_invalidate_thresholds(struct res_counter *counter,
+		struct list_head *thresholds,
+		struct mem_cgroup_threshold **current_threshold)
+{
+	struct mem_cgroup_threshold *tmp, *prev = NULL;
+
+	list_for_each_entry(tmp, thresholds, list) {
+		if (tmp->threshold > counter->usage) {
+			BUG_ON(!prev);
+			*current_threshold = prev;
+			break;
+		}
+		prev = tmp;
+	}
+
+	mem_cgroup_set_thresholds(counter, tmp->threshold, prev->threshold);
+}
+
+static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype *cft,
+		struct eventfd_ctx *eventfd, const char *args)
+{
+	u64 threshold;
+	struct mem_cgroup_threshold *new, *tmp;
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct list_head *thresholds;
+	struct mem_cgroup_threshold **current_threshold;
+	struct res_counter *counter;
+	int type = MEMFILE_TYPE(cft->private);
+	int ret;
+
+	/* XXX: Should we implement thresholds for root cgroup */
+	if (mem_cgroup_is_root(memcg))
+		return -EINVAL;
+
+	ret = res_counter_memparse_write_strategy(args, &threshold);
+	if (ret)
+		return ret;
+
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+	INIT_LIST_HEAD(&new->list);
+	new->eventfd = eventfd;
+	new->threshold = threshold;
+
+	switch (type) {
+	case _MEM:
+		thresholds = &memcg->thresholds;
+		current_threshold = &memcg->current_threshold;
+		counter = &memcg->res;
+		break;
+	case _MEMSWAP:
+		thresholds = &memcg->memsw_thresholds;
+		current_threshold = &memcg->memsw_current_threshold;
+		counter = &memcg->memsw;
+		break;
+	default:
+		BUG();
+		break;
+	}
+
+	list_for_each_entry(tmp, thresholds, list)
+		if (new->threshold < tmp->threshold) {
+			list_add_tail(&new->list, &tmp->list);
+			break;
+		}
+	mem_cgroup_invalidate_thresholds(counter, thresholds,
+			current_threshold);
+
+	return 0;
+}
+
+static int mem_cgroup_unregister_event(struct cgroup *cgrp, struct cftype *cft,
+		struct eventfd_ctx *eventfd)
+{
+	struct mem_cgroup_threshold *threshold, *tmp;
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct list_head *thresholds;
+	struct mem_cgroup_threshold **current_threshold;
+	struct res_counter *counter;
+	int type = MEMFILE_TYPE(cft->private);
+
+	switch (type) {
+	case _MEM:
+		thresholds = &memcg->thresholds;
+		current_threshold = &memcg->current_threshold;
+		counter = &memcg->res;
+		break;
+	case _MEMSWAP:
+		thresholds = &memcg->memsw_thresholds;
+		current_threshold = &memcg->memsw_current_threshold;
+		counter = &memcg->memsw;
+		break;
+	default:
+		BUG();
+		break;
+	}
+
+	list_for_each_entry_safe(threshold, tmp, thresholds, list)
+		if (threshold->eventfd == eventfd) {
+			list_del(&threshold->list);
+			kfree(threshold);
+		}
+	mem_cgroup_invalidate_thresholds(counter, thresholds,
+			current_threshold);
+
+	return 0;
+}
 
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
 		.read_u64 = mem_cgroup_read,
+		.register_event = mem_cgroup_register_event,
+		.unregister_event = mem_cgroup_unregister_event,
 	},
 	{
 		.name = "max_usage_in_bytes",
@@ -2896,6 +3085,8 @@ static struct cftype memsw_cgroup_files[] = {
 		.name = "memsw.usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
 		.read_u64 = mem_cgroup_read,
+		.register_event = mem_cgroup_register_event,
+		.unregister_event = mem_cgroup_unregister_event,
 	},
 	{
 		.name = "memsw.max_usage_in_bytes",
@@ -3080,6 +3271,33 @@ static int mem_cgroup_soft_limit_tree_init(void)
 	return 0;
 }
 
+
+static int mem_cgroup_thresholds_init(struct list_head *thresholds,
+		struct mem_cgroup_threshold **current_threshold)
+{
+	struct mem_cgroup_threshold *new;
+
+	INIT_LIST_HEAD(thresholds);
+
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+	INIT_LIST_HEAD(&new->list);
+	new->threshold = 0ULL;
+	list_add(&new->list, thresholds);
+
+	*current_threshold = new;
+
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+	INIT_LIST_HEAD(&new->list);
+	new->threshold = RESOURCE_MAX;
+	list_add_tail(&new->list, thresholds);
+
+	return 0;
+}
+
 static struct cgroup_subsys_state * __ref
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
@@ -3125,6 +3343,12 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	mem->last_scanned_child = 0;
 	spin_lock_init(&mem->reclaim_param_lock);
 
+	mem->res.threshold_notifier = mem_cgroup_mem_threshold;
+	mem->memsw.threshold_notifier = mem_cgroup_memsw_threshold;
+	mem_cgroup_thresholds_init(&mem->thresholds, &mem->current_threshold);
+	mem_cgroup_thresholds_init(&mem->memsw_thresholds,
+			&mem->memsw_current_threshold);
+
 	if (parent)
 		mem->swappiness = get_swappiness(parent);
 	atomic_set(&mem->refcnt, 1);
-- 
1.6.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
