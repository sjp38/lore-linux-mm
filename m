Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m64Ex1Qn094594
	for <linux-mm@kvack.org>; Fri, 4 Jul 2008 14:59:01 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m64Ex0If2883684
	for <linux-mm@kvack.org>; Fri, 4 Jul 2008 16:59:00 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m64Ewx0d016674
	for <linux-mm@kvack.org>; Fri, 4 Jul 2008 16:59:00 +0200
Subject: [PATCH] Make CONFIG_MIGRATION available for s390
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Content-Type: text/plain
Date: Fri, 04 Jul 2008 16:58:59 +0200
Message-Id: <1215183539.4834.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Subject: [PATCH] Make CONFIG_MIGRATION available for s390
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

From: Gerald Schaefer <gerald.schaefer@de.ibm.com>

We'd like to support CONFIG_MEMORY_HOTREMOVE on s390, which depends on
CONFIG_MIGRATION. So far, CONFIG_MIGRATION is only available with NUMA
support.

This patch makes CONFIG_MIGRATION selectable for s390. When MIGRATION
is enabled w/o NUMA, the kernel won't compile because of a missing
"migrate" member in vm_operations_struct and a missing "policy_zone"
definition. To avoid this, those are moved from an "#ifdef CONFIG_NUMA"
section to "#ifdef CONFIG_MIGRATION".

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---

 include/linux/mempolicy.h |    6 ++++--
 include/linux/mm.h        |    2 ++
 mm/Kconfig                |    2 +-
 3 files changed, 7 insertions(+), 3 deletions(-)

Index: mylinux-git/include/linux/mempolicy.h
===================================================================
--- mylinux-git.orig/include/linux/mempolicy.h
+++ mylinux-git/include/linux/mempolicy.h
@@ -62,6 +62,10 @@ enum {
 
 struct mm_struct;
 
+#ifdef CONFIG_MIGRATION
+extern enum zone_type policy_zone;
+#endif
+
 #ifdef CONFIG_NUMA
 
 /*
@@ -202,8 +206,6 @@ extern struct zonelist *huge_zonelist(st
 				struct mempolicy **mpol, nodemask_t **nodemask);
 extern unsigned slab_node(struct mempolicy *policy);
 
-extern enum zone_type policy_zone;
-
 static inline void check_highest_zone(enum zone_type k)
 {
 	if (k > policy_zone && k != ZONE_MOVABLE)
Index: mylinux-git/include/linux/mm.h
===================================================================
--- mylinux-git.orig/include/linux/mm.h
+++ mylinux-git/include/linux/mm.h
@@ -193,6 +193,8 @@ struct vm_operations_struct {
 	 */
 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
 					unsigned long addr);
+#endif
+#ifdef CONFIG_MIGRATION
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
 		const nodemask_t *to, unsigned long flags);
 #endif
Index: mylinux-git/mm/Kconfig
===================================================================
--- mylinux-git.orig/mm/Kconfig
+++ mylinux-git/mm/Kconfig
@@ -174,7 +174,7 @@ config SPLIT_PTLOCK_CPUS
 config MIGRATION
 	bool "Page migration"
 	def_bool y
-	depends on NUMA
+	depends on NUMA || S390
 	help
 	  Allows the migration of the physical location of pages of processes
 	  while the virtual addresses are not changed. This is useful for


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
