Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m6BDcmQO617802
	for <linux-mm@kvack.org>; Fri, 11 Jul 2008 13:38:48 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6BDcmEU1896656
	for <linux-mm@kvack.org>; Fri, 11 Jul 2008 14:38:48 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6BDcmrN017662
	for <linux-mm@kvack.org>; Fri, 11 Jul 2008 14:38:48 +0100
Subject: [PATCH] Make CONFIG_MIGRATION available w/o CONFIG_NUMA
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Content-Type: text/plain
Date: Fri, 11 Jul 2008 15:38:47 +0200
Message-Id: <1215783527.4746.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Subject: [PATCH] Make CONFIG_MIGRATION available w/o CONFIG_NUMA
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: Gerald Schaefer <gerald.schaefer@de.ibm.com>

We'd like to support CONFIG_MEMORY_HOTREMOVE on s390, which depends on
CONFIG_MIGRATION. So far, CONFIG_MIGRATION is only available with NUMA
support.

This patch makes CONFIG_MIGRATION selectable for architectures that define
ARCH_ENABLE_MEMORY_HOTREMOVE. When MIGRATION is enabled w/o NUMA, the kernel
won't compile because migrate_vmas() does not know about vm_ops->migrate()
and vma_migratable() does not know about policy_zone. To fix this, those
two functions can be restricted to '#ifdef CONFIG_NUMA' because they are
not being used w/o NUMA. vma_migratable() is moved over from migrate.h to
mempolicy.h.

Acked-by: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---

 include/linux/mempolicy.h |   19 +++++++++++++++++++
 include/linux/migrate.h   |   21 ---------------------
 mm/Kconfig                |    2 +-
 mm/migrate.c              |    2 +-
 4 files changed, 21 insertions(+), 23 deletions(-)

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
Index: linux-2.6/include/linux/migrate.h
===================================================================
--- linux-2.6.orig/include/linux/migrate.h
+++ linux-2.6/include/linux/migrate.h
@@ -3,28 +3,10 @@
 
 #include <linux/mm.h>
 #include <linux/mempolicy.h>
-#include <linux/pagemap.h>
 
 typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
 #ifdef CONFIG_MIGRATION
-/* Check if a vma is migratable */
-static inline int vma_migratable(struct vm_area_struct *vma)
-{
-	if (vma->vm_flags & (VM_IO|VM_HUGETLB|VM_PFNMAP|VM_RESERVED))
-		return 0;
-	/*
-	 * Migration allocates pages in the highest zone. If we cannot
-	 * do so then migration (at least from node to node) is not
-	 * possible.
-	 */
-	if (vma->vm_file &&
-		gfp_zone(mapping_gfp_mask(vma->vm_file->f_mapping))
-								< policy_zone)
-			return 0;
-	return 1;
-}
-
 extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
@@ -39,9 +21,6 @@ extern int migrate_vmas(struct mm_struct
 		const nodemask_t *from, const nodemask_t *to,
 		unsigned long flags);
 #else
-static inline int vma_migratable(struct vm_area_struct *vma)
-					{ return 0; }
-
 static inline int isolate_lru_page(struct page *p, struct list_head *list)
 					{ return -ENOSYS; }
 static inline int putback_lru_pages(struct list_head *l) { return 0; }
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -1070,7 +1070,6 @@ out2:
 	mmput(mm);
 	return err;
 }
-#endif
 
 /*
  * Call migration functions in the vma_ops that may prepare
@@ -1092,3 +1091,4 @@ int migrate_vmas(struct mm_struct *mm, c
  	}
  	return err;
 }
+#endif
Index: linux-2.6/include/linux/mempolicy.h
===================================================================
--- linux-2.6.orig/include/linux/mempolicy.h
+++ linux-2.6/include/linux/mempolicy.h
@@ -2,6 +2,7 @@
 #define _LINUX_MEMPOLICY_H 1
 
 #include <linux/errno.h>
+#include <linux/pagemap.h>
 
 /*
  * NUMA memory policies for Linux.
@@ -220,6 +221,24 @@ extern int mpol_parse_str(char *str, str
 extern int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol,
 			int no_context);
 #endif
+
+/* Check if a vma is migratable */
+static inline int vma_migratable(struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & (VM_IO|VM_HUGETLB|VM_PFNMAP|VM_RESERVED))
+		return 0;
+	/*
+	 * Migration allocates pages in the highest zone. If we cannot
+	 * do so then migration (at least from node to node) is not
+	 * possible.
+	 */
+	if (vma->vm_file &&
+		gfp_zone(mapping_gfp_mask(vma->vm_file->f_mapping))
+								< policy_zone)
+			return 0;
+	return 1;
+}
+
 #else
 
 struct mempolicy {};


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
