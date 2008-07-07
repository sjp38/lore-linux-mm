Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m67IPnk4246096
	for <linux-mm@kvack.org>; Mon, 7 Jul 2008 18:25:49 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m67IPnRf2281712
	for <linux-mm@kvack.org>; Mon, 7 Jul 2008 19:25:49 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m67IPmvK011872
	for <linux-mm@kvack.org>; Mon, 7 Jul 2008 19:25:48 +0100
Subject: [PATCH] Make CONFIG_MIGRATION available for s390
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
In-Reply-To: <48725480.1060808@linux-foundation.org>
References: <1215354957.9842.19.camel@localhost.localdomain>
	 <4872319B.9040809@linux-foundation.org>
	 <1215451689.8431.80.camel@localhost.localdomain>
	 <48725480.1060808@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 07 Jul 2008 20:25:48 +0200
Message-Id: <1215455148.8431.108.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-07-07 at 12:38 -0500, Christoph Lameter wrote:
> How does the compile break? It may be better to fix this where the function
> is used.

Good point, I did not look into this deep enough and tried to fix the
symptoms instead of the cause. There are two locations where the compile
breaks:
- mm/migrate.c: migrate_vmas() does not know vm_ops->migrate()
- inlcude/linux/migrate.h: vma_migratable() does not know policy_zone

Both functions are called from mm/mempolicy.c, which is NUMA-only.
vma_migratable() is also called from mm/migrate.c, but just inside a
'#ifdef CONFIG_NUMA' section. So I think it should be safe to just put
the definition of those two functions within '#ifdef CONFIG_NUMA',
and the compile error will be gone, see new patch below.

Thanks,
Gerald
---

Subject: [PATCH] Make CONFIG_MIGRATION available for s390

From: Gerald Schaefer <gerald.schaefer@de.ibm.com>

We'd like to support CONFIG_MEMORY_HOTREMOVE on s390, which depends on
CONFIG_MIGRATION. So far, CONFIG_MIGRATION is only available with NUMA
support.

This patch makes CONFIG_MIGRATION selectable for architectures that define
ARCH_ENABLE_MEMORY_HOTREMOVE. When MIGRATION is enabled w/o NUMA, the kernel
won't compile because migrate_vmas() does not know about vm_ops->migrate()
and vma_migratable() does not know about policy_zone. To avoid this, those
two functions can be restricted to "#ifdef CONFIG_NUMA" because they are
not being used w/o NUMA.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---

 include/linux/migrate.h |    2 ++
 mm/Kconfig              |    2 +-
 mm/migrate.c            |    2 +-
 3 files changed, 4 insertions(+), 2 deletions(-)

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
@@ -8,6 +8,7 @@
 typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
 #ifdef CONFIG_MIGRATION
+#ifdef CONFIG_NUMA
 /* Check if a vma is migratable */
 static inline int vma_migratable(struct vm_area_struct *vma)
 {
@@ -24,6 +25,7 @@ static inline int vma_migratable(struct 
 			return 0;
 	return 1;
 }
+#endif /* CONFIG_NUMA */
 
 extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
