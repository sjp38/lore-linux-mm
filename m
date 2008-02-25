Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1PC1RqK024850
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 07:01:27 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1PC1QQF247518
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 07:01:26 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1PC1QWZ002160
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 07:01:26 -0500
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Mon, 25 Feb 2008 17:25:50 +0530
Message-Id: <20080225115550.23920.43199.sendpatchset@localhost.localdomain>
In-Reply-To: <20080225115509.23920.66231.sendpatchset@localhost.localdomain>
References: <20080225115509.23920.66231.sendpatchset@localhost.localdomain>
Subject: [PATCH] Memory Resource Controller Add Boot Option
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
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

 Documentation/kernel-parameters.txt |    2 ++
 mm/memcontrol.c                     |   33 ++++++++++++++++++++++++++++++++-
 2 files changed, 34 insertions(+), 1 deletion(-)

diff -L mm/memcontrol.h -puN /dev/null /dev/null
diff -puN include/linux/memcontrol.h~memory-controller-add-boot-option include/linux/memcontrol.h
diff -puN mm/memcontrol.c~memory-controller-add-boot-option mm/memcontrol.c
--- linux-2.6.25-rc3/mm/memcontrol.c~memory-controller-add-boot-option	2008-02-25 15:55:58.000000000 +0530
+++ linux-2.6.25-rc3-balbir/mm/memcontrol.c	2008-02-25 17:10:50.000000000 +0530
@@ -35,6 +35,7 @@
 
 struct cgroup_subsys mem_cgroup_subsys;
 static const int MEM_CGROUP_RECLAIM_RETRIES = 5;
+static int mem_cgroup_on __read_mostly = 1;	/* turned on/off */
 
 /*
  * Statistics for memory cgroup.
@@ -578,6 +579,9 @@ static int mem_cgroup_charge_common(stru
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup_per_zone *mz;
 
+	if (!mem_cgroup_on)
+		return 0;
+
 	/*
 	 * Should page_cgroup's go to their own slab?
 	 * One could optimize the performance of the charging routine
@@ -729,7 +733,7 @@ void mem_cgroup_uncharge(struct page_cgr
 	/*
 	 * Check if our page_cgroup is valid
 	 */
-	if (!pc)
+	if (!pc || !mem_cgroup_on)
 		return;
 
 	if (atomic_dec_and_test(&pc->ref_cnt)) {
@@ -755,6 +759,9 @@ void mem_cgroup_uncharge(struct page_cgr
 
 void mem_cgroup_uncharge_page(struct page *page)
 {
+	if (!mem_cgroup_on)
+		return;
+
 	lock_page_cgroup(page);
 	mem_cgroup_uncharge(page_get_page_cgroup(page));
 	unlock_page_cgroup(page);
@@ -769,6 +776,10 @@ int mem_cgroup_prepare_migration(struct 
 {
 	struct page_cgroup *pc;
 	int ret = 0;
+
+	if (!mem_cgroup_on)
+		return 0;
+
 	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
 	if (pc && atomic_inc_not_zero(&pc->ref_cnt))
@@ -781,6 +792,9 @@ void mem_cgroup_end_migration(struct pag
 {
 	struct page_cgroup *pc;
 
+	if (!mem_cgroup_on)
+		return;
+
 	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
 	mem_cgroup_uncharge(pc);
@@ -881,6 +895,10 @@ int mem_cgroup_force_empty(struct mem_cg
 {
 	int ret = -EBUSY;
 	int node, zid;
+
+	if (!mem_cgroup_on)
+		return 0;
+
 	css_get(&mem->css);
 	/*
 	 * page reclaim code (kswapd etc..) will move pages between
@@ -1141,6 +1159,9 @@ static void mem_cgroup_destroy(struct cg
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
+	if (!mem_cgroup_on)
+		return 0;
+
 	return cgroup_add_files(cont, ss, mem_cgroup_files,
 					ARRAY_SIZE(mem_cgroup_files));
 }
@@ -1153,6 +1174,9 @@ static void mem_cgroup_move_task(struct 
 	struct mm_struct *mm;
 	struct mem_cgroup *mem, *old_mem;
 
+	if (!mem_cgroup_on)
+		return;
+
 	mm = get_task_mm(p);
 	if (mm == NULL)
 		return;
@@ -1189,3 +1213,10 @@ struct cgroup_subsys mem_cgroup_subsys =
 	.attach = mem_cgroup_move_task,
 	.early_init = 0,
 };
+
+static int __init mem_cgroup_startup_disable(char *str)
+{
+	mem_cgroup_on = 0;
+	return 1;
+}
+__setup("memcgroupoff", mem_cgroup_startup_disable);
diff -puN Documentation/kernel-parameters.txt~memory-controller-add-boot-option Documentation/kernel-parameters.txt
--- linux-2.6.25-rc3/Documentation/kernel-parameters.txt~memory-controller-add-boot-option	2008-02-25 15:55:58.000000000 +0530
+++ linux-2.6.25-rc3-balbir/Documentation/kernel-parameters.txt	2008-02-25 15:56:01.000000000 +0530
@@ -1114,6 +1114,8 @@ and is between 256 and 4096 characters. 
 	mem=nopentium	[BUGS=X86-32] Disable usage of 4MB pages for kernel
 			memory.
 
+	memcgroupoff	[KNL] Disable memory resource controller
+
 	memmap=exactmap	[KNL,X86-32,X86_64] Enable setting of an exact
 			E820 memory map, as specified by the user.
 			Such memmap=exactmap lines can be constructed based on
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
