Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m66EZxAm079612
	for <linux-mm@kvack.org>; Sun, 6 Jul 2008 14:35:59 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m66EZx7M2641980
	for <linux-mm@kvack.org>; Sun, 6 Jul 2008 16:35:59 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m66EZxNm013131
	for <linux-mm@kvack.org>; Sun, 6 Jul 2008 16:35:59 +0200
Subject: [PATCH] Make CONFIG_MIGRATION available for s390
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Reply-To: gerald.schaefer@de.ibm.com
Content-Type: text/plain
Date: Sun, 06 Jul 2008 16:35:57 +0200
Message-Id: <1215354957.9842.19.camel@localhost.localdomain>
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

This patch makes CONFIG_MIGRATION selectable for architectures that define
ARCH_ENABLE_MEMORY_HOTREMOVE. When MIGRATION is enabled w/o NUMA, the kernel
won't compile because of a missing migrate() function in vm_operations_struct
and a missing policy_zone reference in vma_migratable(). To avoid this,
"#ifdef CONFIG_NUMA" is added to vma_migratable() and the vm_ops migrate()
definition is moved from "#ifdef CONFIG_NUMA" to "#ifdef CONFIG_MIGRATION".

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---

 include/linux/migrate.h |    2 ++
 include/linux/mm.h      |    2 ++
 mm/Kconfig              |    2 +-
 3 files changed, 5 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/migrate.h
===================================================================
--- linux-2.6.orig/include/linux/migrate.h
+++ linux-2.6/include/linux/migrate.h
@@ -13,6 +13,7 @@ static inline int vma_migratable(struct 
 {
 	if (vma->vm_flags & (VM_IO|VM_HUGETLB|VM_PFNMAP|VM_RESERVED))
 		return 0;
+#ifdef CONFIG_NUMA
 	/*
 	 * Migration allocates pages in the highest zone. If we cannot
 	 * do so then migration (at least from node to node) is not
@@ -22,6 +23,7 @@ static inline int vma_migratable(struct 
 		gfp_zone(mapping_gfp_mask(vma->vm_file->f_mapping))
 								< policy_zone)
 			return 0;
+#endif
 	return 1;
 }
 
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -193,6 +193,8 @@ struct vm_operations_struct {
 	 */
 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
 					unsigned long addr);
+#endif
+#ifdef CONFIG_MIGRATION
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
 		const nodemask_t *to, unsigned long flags);
 #endif
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig
+++ linux-2.6/mm/Kconfig
@@ -174,7 +174,7 @@ config SPLIT_PTLOCK_CPUS
 config MIGRATION
 	bool "Page migration"
 	def_bool y
-	depends on NUMA
+	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE
 	help
 	  Allows the migration of the physical location of pages of processes
 	  while the virtual addresses are not changed. This is useful for

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
