Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C13AF8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:41:02 -0400 (EDT)
Message-Id: <20110328093957.316076344@suse.cz>
Date: Mon, 28 Mar 2011 11:39:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 1/3] Add mem_cgroup->isolated and configuration knob
References: <20110328093957.089007035@suse.cz>
Content-Disposition: inline; filename=memcg_add_isolated_lru_knob.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

This is a first patch in the row and it just adds isolated boolean to the
mem_cgroup structure. The value says whether pages charged for this group
should be isolated from the rest of the system when they are charged (they are
not by default).

The patch adds a cgroup fs interface to modify the current isolation status
of a group. The value can be modified by /dev/memctl/memory.isolated knob.

Signed-off-by: Michal Hocko <mhocko@suse.cz>

--- 
 include/linux/memcontrol.h |    2 ++
 mm/memcontrol.c            |   40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 42 insertions(+)

Index: linux-2.6.38-rc8/mm/memcontrol.c
===================================================================
--- linux-2.6.38-rc8.orig/mm/memcontrol.c	2011-03-28 11:13:27.000000000 +0200
+++ linux-2.6.38-rc8/mm/memcontrol.c	2011-03-28 11:25:00.000000000 +0200
@@ -245,6 +245,10 @@ struct mem_cgroup {
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
 
+	/* is the group isolated from the global LRU? */
+	/* TODO can we place it into a hole */
+	bool		isolated;
+
 	/* protect arrays of thresholds */
 	struct mutex thresholds_lock;
 
@@ -4295,6 +4299,32 @@ static int mem_cgroup_oom_control_write(
 	return 0;
 }
 
+static int mem_cgroup_isolated_write(struct cgroup *cgrp, struct cftype *cft,
+				       u64 val)
+{
+	int ret = -EINVAL;
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+
+	/* We are not allowing isolation of the root memory cgroup as it has
+	 * a special purpose to collect all pages that do not belong to any
+	 * group.
+	 */
+	if (mem_cgroup_is_root(mem))
+		goto out;
+
+	mem->isolated = !!val;
+	ret = 0;
+out:
+	return ret;
+}
+
+static u64 mem_cgroup_isolated_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+
+	return is_mem_cgroup_isolated(mem);
+}
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -4358,6 +4388,11 @@ static struct cftype mem_cgroup_files[]
 		.unregister_event = mem_cgroup_oom_unregister_event,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
+	{
+		.name = "isolated",
+		.write_u64 = mem_cgroup_isolated_write,
+		.read_u64 = mem_cgroup_isolated_read,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -5168,6 +5203,11 @@ static void mem_cgroup_move_task(struct
 }
 #endif
 
+bool is_mem_cgroup_isolated(struct mem_cgroup *mem)
+{
+	return mem->isolated;
+}
+
 struct cgroup_subsys mem_cgroup_subsys = {
 	.name = "memory",
 	.subsys_id = mem_cgroup_subsys_id,
Index: linux-2.6.38-rc8/include/linux/memcontrol.h
===================================================================
--- linux-2.6.38-rc8.orig/include/linux/memcontrol.h	2011-03-28 11:13:27.000000000 +0200
+++ linux-2.6.38-rc8/include/linux/memcontrol.h	2011-03-28 11:25:00.000000000 +0200
@@ -155,6 +155,8 @@ void mem_cgroup_split_huge_fixup(struct
 bool mem_cgroup_bad_page_check(struct page *page);
 void mem_cgroup_print_bad_page(struct page *page);
 #endif
+
+bool is_mem_cgroup_isolated(struct mem_cgroup *mem);
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
