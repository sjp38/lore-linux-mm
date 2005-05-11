Date: Tue, 10 May 2005 21:38:28 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050511043828.10876.89510.72797@jackhammer.engr.sgi.com>
In-Reply-To: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.12-rc3 5/8] mm: manual page migration-rc2 -- sys_migrate_pages-xattr-support-rc2.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>
List-ID: <linux-mm.kvack.org>

This patch inspects the extended attribute "system.migration" of
each mapped file to determine which pages should be migrated, as
follows:

(1)  If the attribute is missing or does not have the value "libr"
     or "none", then all pages of the mapped file (on the eligible
     nodes) are migrated.

(2)  If the attribute has the value "none", then no pages of the
     mapped file are migrated.

(3)  If the attribute has the value "libr", then shared pages of
     the mapped file are not migrated.  Pages that have been
     modified by the process (and whose COW sharing with the library
     file have been broken) are migrated.  (These files have
     PageAnon() set.)

Signed-off-by: Ray Bryant <raybry@sgi.com>

 include/linux/mmigrate.h |    5 ++++
 mm/mmigrate.c            |   54 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 58 insertions(+), 1 deletion(-)

Index: linux-2.6.12-rc3-mhp1-page-migration-export/include/linux/mmigrate.h
===================================================================
--- linux-2.6.12-rc3-mhp1-page-migration-export.orig/include/linux/mmigrate.h	2005-05-10 10:59:46.000000000 -0700
+++ linux-2.6.12-rc3-mhp1-page-migration-export/include/linux/mmigrate.h	2005-05-10 11:09:07.000000000 -0700
@@ -6,6 +6,11 @@
 
 #define MIGRATE_NODE_ANY -1
 
+#define MIGRATION_XATTR_NAME		"system.migration"
+#define MIGRATION_XATTR_LIBRARY 	"libr"
+#define MIGRATION_XATTR_NOMIGRATE	"none"
+#define MIGRATION_XATTR_LENGTH		4
+
 #ifdef CONFIG_MEMORY_MIGRATE
 extern int generic_migrate_page(struct page *, struct page *,
 		int (*)(struct page *, struct page *, struct list_head *));
Index: linux-2.6.12-rc3-mhp1-page-migration-export/mm/mmigrate.c
===================================================================
--- linux-2.6.12-rc3-mhp1-page-migration-export.orig/mm/mmigrate.c	2005-05-10 10:59:46.000000000 -0700
+++ linux-2.6.12-rc3-mhp1-page-migration-export/mm/mmigrate.c	2005-05-10 11:09:07.000000000 -0700
@@ -593,6 +593,31 @@ int try_to_migrate_pages(struct list_hea
 	return nr_busy;
 }
 
+static int get_migration_xattr(struct file *file, char *xattr)
+{
+	int rc;
+
+	if (!file->f_mapping->host->i_op->getxattr ||
+	    !file->f_dentry)
+		return 0;
+
+   	rc = file->f_mapping->host->i_op->getxattr(file->f_dentry,
+		MIGRATION_XATTR_NAME, xattr, MIGRATION_XATTR_LENGTH);
+
+	return rc;
+
+}
+
+static inline int is_migration_xattr_libr(char *x)
+{
+	return strncmp(x, MIGRATION_XATTR_LIBRARY, MIGRATION_XATTR_LENGTH) == 0;
+}
+
+static inline int is_migration_xattr_none(char *x)
+{
+	return strncmp(x, MIGRATION_XATTR_NOMIGRATE, MIGRATION_XATTR_LENGTH) == 0;
+}
+
 static int
 migrate_vma(struct task_struct *task, struct mm_struct *mm,
 	struct vm_area_struct *vma, short *node_map)
@@ -600,14 +625,39 @@ migrate_vma(struct task_struct *task, st
 	struct page *page;
 	struct zone *zone;
 	unsigned long vaddr;
-	int count = 0, nid, pass = 0, nr_busy = 0;
+	int count = 0, nid, pass = 0, nr_busy = 0, library, rc;
 	LIST_HEAD(page_list);
+	char xattr[MIGRATION_XATTR_LENGTH];
 
 	/* can't migrate mlock()'d pages */
 	if (vma->vm_flags & VM_LOCKED)
 		return 0;
 
 	/*
+	 * if the vma is an anon vma, it is migratable.
+	 * if the vma maps a file, then:
+	 *
+	 * system.migration     PageAnon(page)     Migrate?
+	 * ----------------     --------------     --------
+	 *  "none"                not checked          No
+	 * not present            not checked         Yes
+  	 *  "libr"                    0                No
+  	 *  "libr"                    1               Yes
+	 * any other value        not checked         Yes
+	 */
+
+	library = 0;
+	if (vma->vm_file) {
+	        rc = get_migration_xattr(vma->vm_file, xattr);
+		if (rc > 0) {
+			if (is_migration_xattr_none(xattr))
+				return 0;
+			if (is_migration_xattr_libr(xattr))
+				library = 1;
+		}
+	}
+
+	/*
 	 * gather all of the pages to be migrated from this vma into page_list
 	 */
 	spin_lock(&mm->page_table_lock);
@@ -618,6 +668,8 @@ migrate_vma(struct task_struct *task, st
 		 * and NULL mapping.  Skip those pages as well
 		 */
 		if (page && page_mapcount(page)) {
+			if (library && !PageAnon(page))
+				continue;
 			nid = page_to_nid(page);
 			if (node_map[nid] >= 0) {
 				zone = page_zone(page);

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant                       raybry@sgi.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
