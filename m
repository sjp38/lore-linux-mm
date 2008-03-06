Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m26J1q6M023871
	for <linux-mm@kvack.org>; Thu, 6 Mar 2008 14:01:52 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m26J1mHo048322
	for <linux-mm@kvack.org>; Thu, 6 Mar 2008 12:01:48 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m26J1lUZ023767
	for <linux-mm@kvack.org>; Thu, 6 Mar 2008 12:01:47 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 07 Mar 2008 00:30:03 +0530
Message-Id: <20080306190003.23290.19449.sendpatchset@localhost.localdomain>
In-Reply-To: <20080306185952.23290.49571.sendpatchset@localhost.localdomain>
References: <20080306185952.23290.49571.sendpatchset@localhost.localdomain>
Subject: [PATCH] Make memory resource control aware of boot options
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


A boot option for the memory controller was discussed on lkml. It is a good
idea to add it, since it saves memory for people who want to turn off the
memory controller.

By default the option is on for the following two reasons

1. It provides compatibility with the current scheme where the memory
   controller turns on if the config option is enabled
2. It allows for wider testing of the memory controller, once the config
   option is enabled

We still allow the create, destroy callbacks to succeed, since they are
not aware of boot options. We do not populate the directory will
memory resource controller specific files.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff -puN mm/memcontrol.c~memory-controller-add-boot-option mm/memcontrol.c
--- linux-2.6.25-rc4/mm/memcontrol.c~memory-controller-add-boot-option	2008-03-07 00:14:10.000000000 +0530
+++ linux-2.6.25-rc4-balbir/mm/memcontrol.c	2008-03-07 00:14:10.000000000 +0530
@@ -533,6 +533,9 @@ static int mem_cgroup_charge_common(stru
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup_per_zone *mz;
 
+	if (mem_cgroup_subsys.disabled)
+		return 0;
+
 	/*
 	 * Should page_cgroup's go to their own slab?
 	 * One could optimize the performance of the charging routine
@@ -665,6 +668,9 @@ void mem_cgroup_uncharge_page(struct pag
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
 
+	if (mem_cgroup_subsys.disabled)
+		return;
+
 	/*
 	 * Check if our page_cgroup is valid
 	 */
@@ -705,6 +711,9 @@ int mem_cgroup_prepare_migration(struct 
 {
 	struct page_cgroup *pc;
 
+	if (mem_cgroup_subsys.disabled)
+		return 0;
+
 	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
 	if (pc)
@@ -803,6 +812,9 @@ static int mem_cgroup_force_empty(struct
 	int ret = -EBUSY;
 	int node, zid;
 
+	if (mem_cgroup_subsys.disabled)
+		return 0;
+
 	css_get(&mem->css);
 	/*
 	 * page reclaim code (kswapd etc..) will move pages between
@@ -1053,6 +1065,8 @@ static void mem_cgroup_destroy(struct cg
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
+	if (mem_cgroup_subsys.disabled)
+		return 0;
 	return cgroup_add_files(cont, ss, mem_cgroup_files,
 					ARRAY_SIZE(mem_cgroup_files));
 }
@@ -1065,6 +1079,9 @@ static void mem_cgroup_move_task(struct 
 	struct mm_struct *mm;
 	struct mem_cgroup *mem, *old_mem;
 
+	if (mem_cgroup_subsys.disabled)
+		return;
+
 	mm = get_task_mm(p);
 	if (mm == NULL)
 		return;
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
