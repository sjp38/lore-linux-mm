From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070618092901.7790.31240.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/7] Allow CONFIG_MIGRATION to be set without CONFIG_NUMA
Date: Mon, 18 Jun 2007 10:29:01 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

CONFIG_MIGRATION currently depends on CONFIG_NUMA. move_pages() is the only
user of migration today and as this system call is only meaningful on NUMA,
it makes sense. However, memory compaction will operate within a zone and is
useful on both NUMA and non-NUMA systems. This patch allows CONFIG_MIGRATION
to be used in all memory models. To preserve existing behaviour, move_pages()
is only available when CONFIG_NUMA is set.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 include/linux/migrate.h |    6 +++---
 include/linux/mm.h      |    2 ++
 mm/Kconfig              |    1 -
 3 files changed, 5 insertions(+), 4 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-005_migrationkernel/include/linux/migrate.h linux-2.6.22-rc4-mm2-015_migration_flatmem/include/linux/migrate.h
--- linux-2.6.22-rc4-mm2-005_migrationkernel/include/linux/migrate.h	2007-06-05 01:57:25.000000000 +0100
+++ linux-2.6.22-rc4-mm2-015_migration_flatmem/include/linux/migrate.h	2007-06-15 16:25:37.000000000 +0100
@@ -7,7 +7,7 @@
 
 typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
-#ifdef CONFIG_MIGRATION
+#ifdef CONFIG_NUMA
 /* Check if a vma is migratable */
 static inline int vma_migratable(struct vm_area_struct *vma)
 {
@@ -24,7 +24,9 @@ static inline int vma_migratable(struct 
 			return 0;
 	return 1;
 }
+#endif
 
+#ifdef CONFIG_MIGRATION
 extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
@@ -39,8 +41,6 @@ extern int migrate_vmas(struct mm_struct
 		const nodemask_t *from, const nodemask_t *to,
 		unsigned long flags);
 #else
-static inline int vma_migratable(struct vm_area_struct *vma)
-					{ return 0; }
 
 static inline int isolate_lru_page(struct page *p, struct list_head *list)
 					{ return -ENOSYS; }
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-005_migrationkernel/include/linux/mm.h linux-2.6.22-rc4-mm2-015_migration_flatmem/include/linux/mm.h
--- linux-2.6.22-rc4-mm2-005_migrationkernel/include/linux/mm.h	2007-06-13 23:43:12.000000000 +0100
+++ linux-2.6.22-rc4-mm2-015_migration_flatmem/include/linux/mm.h	2007-06-15 16:25:37.000000000 +0100
@@ -241,6 +241,8 @@ struct vm_operations_struct {
 	int (*set_policy)(struct vm_area_struct *vma, struct mempolicy *new);
 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
 					unsigned long addr);
+#endif /* CONFIG_NUMA */
+#ifdef CONFIG_MIGRATION
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
 		const nodemask_t *to, unsigned long flags);
 #endif
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc4-mm2-005_migrationkernel/mm/Kconfig linux-2.6.22-rc4-mm2-015_migration_flatmem/mm/Kconfig
--- linux-2.6.22-rc4-mm2-005_migrationkernel/mm/Kconfig	2007-06-13 23:43:12.000000000 +0100
+++ linux-2.6.22-rc4-mm2-015_migration_flatmem/mm/Kconfig	2007-06-15 16:25:37.000000000 +0100
@@ -145,7 +145,6 @@ config SPLIT_PTLOCK_CPUS
 config MIGRATION
 	bool "Page migration"
 	def_bool y
-	depends on NUMA
 	help
 	  Allows the migration of the physical location of pages of processes
 	  while the virtual addresses are not changed. This is useful for

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
