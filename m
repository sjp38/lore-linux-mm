Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8784B60021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 10:58:22 -0500 (EST)
Received: by mail-fx0-f228.google.com with SMTP id 28so3274160fxm.6
        for <linux-mm@kvack.org>; Wed, 30 Dec 2009 07:58:20 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH v5 4/4] memcg: implement memory thresholds
Date: Wed, 30 Dec 2009 17:57:59 +0200
Message-Id: <0e92010cf06de5cd860df92f22fddbd23ece8a87.1262186099.git.kirill@shutemov.name>
In-Reply-To: <03152dd4f660cff87b16bb581718b1c53d4775aa.1262186098.git.kirill@shutemov.name>
References: <cover.1262186097.git.kirill@shutemov.name>
 <9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill@shutemov.name>
 <34fedc324199dd64149889ed6eac5d8f9441a9db.1262186098.git.kirill@shutemov.name>
 <03152dd4f660cff87b16bb581718b1c53d4775aa.1262186098.git.kirill@shutemov.name>
In-Reply-To: <cover.1262186097.git.kirill@shutemov.name>
References: <cover.1262186097.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
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

It's applicable for root and non-root cgroup.

It uses stats to track memory usage, simmilar to soft limits. It checks
if we need to send event to userspace on every 100 page in/out. I guess
it's good compromise between performance and accuracy of thresholds.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 Documentation/cgroups/memory.txt |   19 +++-
 mm/memcontrol.c                  |  312 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 330 insertions(+), 1 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index b871f25..195af07 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -414,7 +414,24 @@ NOTE1: Soft limits take effect over a long period of time, since they involve
 NOTE2: It is recommended to set the soft limit always below the hard limit,
        otherwise the hard limit will take precedence.
 
-8. TODO
+8. Memory thresholds
+
+Memory controler implements memory thresholds using cgroups notification
+API (see cgroups.txt). It allows to register multiple memory and memsw
+thresholds and gets notifications when it crosses.
+
+To register a threshold application need:
+ - create an eventfd using eventfd(2);
+ - open memory.usage_in_bytes or memory.memsw.usage_in_bytes;
+ - write string like "<event_fd> <memory.usage_in_bytes> <threshold>" to
+   cgroup.event_control.
+
+Application will be notified through eventfd when memory usage crosses
+threshold in any direction.
+
+It's applicable for root and non-root cgroup.
+
+9. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c36d4f3..5d4bd0b 100644
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
@@ -39,6 +43,8 @@
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
+#include <linux/eventfd.h>
+#include <linux/sort.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -56,6 +62,7 @@ static int really_do_swap_account __initdata = 1; /* for remember boot option*/
 #endif
 
 #define SOFTLIMIT_EVENTS_THRESH (1000)
+#define THRESHOLDS_EVENTS_THRESH (100)
 
 /*
  * Statistics for memory cgroup.
@@ -72,6 +79,8 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
 	MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
 					used by soft limit implementation */
+	MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
+					used by threshold implementation */
 
 	MEM_CGROUP_STAT_NSTATS,
 };
@@ -175,6 +184,23 @@ struct mem_cgroup_tree {
 
 static struct mem_cgroup_tree soft_limit_tree __read_mostly;
 
+struct mem_cgroup_threshold {
+	struct eventfd_ctx *eventfd;
+	u64 threshold;
+};
+
+struct mem_cgroup_threshold_ary {
+	/* An array index points to threshold just below usage. */
+	atomic_t current_threshold;
+	/* Size of entries[] */
+	unsigned int size;
+	/* Array of thresholds */
+	struct mem_cgroup_threshold entries[0];
+};
+
+static bool mem_cgroup_threshold_check(struct mem_cgroup* mem);
+static void mem_cgroup_threshold(struct mem_cgroup* mem);
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -226,6 +252,15 @@ struct mem_cgroup {
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
 
+	/* protect arrays of thresholds */
+	struct mutex thresholds_lock;
+
+	/* thresholds for memory usage. RCU-protected */
+	struct mem_cgroup_threshold_ary *thresholds;
+
+	/* thresholds for mem+swap usage. RCU-protected */
+	struct mem_cgroup_threshold_ary *memsw_thresholds;
+
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -518,6 +553,8 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 		__mem_cgroup_stat_add_safe(cpustat,
 				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
 	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SOFTLIMIT, -1);
+	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_THRESHOLDS, -1);
+
 	put_cpu();
 }
 
@@ -1503,6 +1540,8 @@ charged:
 	if (mem_cgroup_soft_limit_check(mem))
 		mem_cgroup_update_tree(mem, page);
 done:
+	if (mem_cgroup_threshold_check(mem))
+		mem_cgroup_threshold(mem);
 	return 0;
 nomem:
 	css_put(&mem->css);
@@ -2068,6 +2107,8 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 
 	if (mem_cgroup_soft_limit_check(mem))
 		mem_cgroup_update_tree(mem, page);
+	if (mem_cgroup_threshold_check(mem))
+		mem_cgroup_threshold(mem);
 	/* at swapout, this memcg will be accessed to record to swap */
 	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		css_put(&mem->css);
@@ -3064,12 +3105,280 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
+static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
+{
+	bool ret = false;
+	int cpu;
+	s64 val;
+	struct mem_cgroup_stat_cpu *cpustat;
+
+	cpu = get_cpu();
+	cpustat = &mem->stat.cpustat[cpu];
+	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_THRESHOLDS);
+	if (unlikely(val < 0)) {
+		__mem_cgroup_stat_set_safe(cpustat, MEM_CGROUP_STAT_THRESHOLDS,
+				THRESHOLDS_EVENTS_THRESH);
+		ret = true;
+	}
+	put_cpu();
+	return ret;
+}
+
+static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
+{
+	struct mem_cgroup_threshold_ary *t;
+	u64 usage;
+	int i;
+
+	rcu_read_lock();
+	if (!swap) {
+		t = rcu_dereference(memcg->thresholds);
+	} else {
+		t = rcu_dereference(memcg->memsw_thresholds);
+	}
+
+	if (!t)
+		goto unlock;
+
+	usage = mem_cgroup_usage(memcg, swap);
+
+	/*
+	 * current_threshold points to threshold just below usage.
+	 * If it's not true, a threshold was crossed after last
+	 * call of __mem_cgroup_threshold().
+	 */
+	i = atomic_read(&t->current_threshold);
+
+	/*
+	 * Iterate backward over array of thresholds starting from
+	 * current_threshold and check if a threshold is crossed.
+	 * If none of thresholds below usage is crossed, we read
+	 * only one element of the array here.
+	 */
+	for(; i > 0 && unlikely(t->entries[i].threshold > usage); i--) {
+		eventfd_signal(t->entries[i].eventfd, 1);
+	}
+
+	/* i = current_threshold + 1 */
+	i++;
+
+	/*
+	 * Iterate forward over array of thresholds starting from
+	 * current_threshold+1 and check if a threshold is crossed.
+	 * If none of thresholds above usage is crossed, we read
+	 * only one element of the array here.
+	 */
+	for(; i < t->size && unlikely(t->entries[i].threshold <= usage); i++) {
+		eventfd_signal(t->entries[i].eventfd, 1);
+	}
+
+	/* Update current_threshold */
+	atomic_set(&t->current_threshold, i - 1);
+unlock:
+	rcu_read_unlock();
+}
+
+static void mem_cgroup_threshold(struct mem_cgroup *memcg)
+{
+	__mem_cgroup_threshold(memcg, false);
+	if (do_swap_account)
+		__mem_cgroup_threshold(memcg, true);
+}
+
+static int compare_thresholds(const void *a, const void *b)
+{
+	const struct mem_cgroup_threshold *_a = a;
+	const struct mem_cgroup_threshold *_b = b;
+
+	return _a->threshold - _b->threshold;
+}
+
+static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype *cft,
+		struct eventfd_ctx *eventfd, const char *args)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
+	int type = MEMFILE_TYPE(cft->private);
+	u64 threshold, usage;
+	int size;
+	int i, ret;
+
+	ret = res_counter_memparse_write_strategy(args, &threshold);
+	if (ret)
+		return ret;
+
+	mutex_lock(&memcg->thresholds_lock);
+	if (type == _MEM)
+		thresholds = memcg->thresholds;
+	else if (type == _MEMSWAP)
+		thresholds = memcg->memsw_thresholds;
+	else
+		BUG();
+
+	usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
+
+	/* Check if a threshold crossed before adding a new one */
+	if (thresholds)
+		__mem_cgroup_threshold(memcg, type == _MEMSWAP);
+
+	if (thresholds)
+		size = thresholds->size + 1;
+	else
+		size = 1;
+
+	/* Allocate memory for new array of thresholds */
+	thresholds_new = kmalloc(sizeof(*thresholds_new) +
+			size * sizeof(struct mem_cgroup_threshold),
+			GFP_KERNEL);
+	if (!thresholds_new) {
+		ret = -ENOMEM;
+		goto unlock;
+	}
+	thresholds_new->size = size;
+
+	/* Copy thresholds (if any) to new array */
+	if (thresholds)
+		memcpy(thresholds_new->entries, thresholds->entries,
+				thresholds->size *
+				sizeof(struct mem_cgroup_threshold));
+	/* Add new threshold */
+	thresholds_new->entries[size - 1].eventfd = eventfd;
+	thresholds_new->entries[size - 1].threshold = threshold;
+
+	/* Sort thresholds. Registering of new threshold isn't time-critical */
+	sort(thresholds_new->entries, size,
+			sizeof(struct mem_cgroup_threshold),
+			compare_thresholds, NULL);
+
+	/* Find current threshold */
+	atomic_set(&thresholds_new->current_threshold, -1);
+	for(i = 0; i < size; i++) {
+		if (thresholds_new->entries[i].threshold < usage) {
+			/*
+			 * thresholds_new->current_threshold will not be used
+			 * until rcu_assign_pointer(), so it's safe to increment
+			 * it here.
+			 */
+			atomic_inc(&thresholds_new->current_threshold);
+		}
+	}
+
+	/*
+	 * We need to increment refcnt to be sure that all thresholds
+	 * will be unregistered before calling __mem_cgroup_free()
+	 */
+	mem_cgroup_get(memcg);
+
+	if (type == _MEM)
+		rcu_assign_pointer(memcg->thresholds, thresholds_new);
+	else
+		rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
+
+	/* To be sure that nobody uses thresholds before freeing it */
+	synchronize_rcu();
+
+	kfree(thresholds);
+unlock:
+	mutex_unlock(&memcg->thresholds_lock);
+
+	return ret;
+}
+
+static int mem_cgroup_unregister_event(struct cgroup *cgrp, struct cftype *cft,
+		struct eventfd_ctx *eventfd)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
+	int type = MEMFILE_TYPE(cft->private);
+	u64 usage;
+	int size = 0;
+	int i, j, ret;
+
+	mutex_lock(&memcg->thresholds_lock);
+	if (type == _MEM)
+		thresholds = memcg->thresholds;
+	else if (type == _MEMSWAP)
+		thresholds = memcg->memsw_thresholds;
+	else
+		BUG();
+
+	/*
+	 * Something went wrong if we trying to unregister a threshold
+	 * if we don't have thresholds
+	 */
+	BUG_ON(!thresholds);
+
+	usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
+
+	/* Check if a threshold crossed before removing */
+	__mem_cgroup_threshold(memcg, type == _MEMSWAP);
+
+	/* Calculate new number of threshold */
+	for(i = 0; i < thresholds->size; i++) {
+		if (thresholds->entries[i].eventfd != eventfd)
+			size++;
+	}
+
+	/* Set thresholds array to NULL if we don't have thresholds */
+	if (!size) {
+		thresholds_new = NULL;
+		goto assign;
+	}
+
+	/* Allocate memory for new array of thresholds */
+	thresholds_new = kmalloc(sizeof(*thresholds_new) +
+			size * sizeof(struct mem_cgroup_threshold),
+			GFP_KERNEL);
+	if (!thresholds_new) {
+		ret = -ENOMEM;
+		goto unlock;
+	}
+	thresholds_new->size = size;
+
+	/* Copy thresholds and find current threshold */
+	atomic_set(&thresholds_new->current_threshold, -1);
+	for(i = 0, j = 0; i < thresholds->size; i++) {
+		if (thresholds->entries[i].eventfd == eventfd)
+			continue;
+
+		thresholds_new->entries[j] = thresholds->entries[i];
+		if (thresholds_new->entries[j].threshold < usage) {
+			/*
+			 * thresholds_new->current_threshold will not be used
+			 * until rcu_assign_pointer(), so it's safe to increment
+			 * it here.
+			 */
+			atomic_inc(&thresholds_new->current_threshold);
+		}
+		j++;
+	}
+
+assign:
+	if (type == _MEM)
+		rcu_assign_pointer(memcg->thresholds, thresholds_new);
+	else
+		rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
+
+	/* To be sure that nobody uses thresholds before freeing it */
+	synchronize_rcu();
+
+	for(i = 0; i < thresholds->size - size; i++)
+		mem_cgroup_put(memcg);
+
+	kfree(thresholds);
+unlock:
+	mutex_unlock(&memcg->thresholds_lock);
+
+	return ret;
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
@@ -3121,6 +3430,8 @@ static struct cftype memsw_cgroup_files[] = {
 		.name = "memsw.usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
 		.read_u64 = mem_cgroup_read,
+		.register_event = mem_cgroup_register_event,
+		.unregister_event = mem_cgroup_unregister_event,
 	},
 	{
 		.name = "memsw.max_usage_in_bytes",
@@ -3360,6 +3671,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	if (parent)
 		mem->swappiness = get_swappiness(parent);
 	atomic_set(&mem->refcnt, 1);
+	mutex_init(&mem->thresholds_lock);
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
-- 
1.6.5.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
